# Bridge boundaries and API review

This review covers response-file writes, large lineage graphs, panel lifetime and
progressive construction of core specifications. Finding 2, restricting contract
file reads to a workspace or base directory, is explicitly excluded from this
change at the maintainer's request. Do not describe the bridge as a general
filesystem sandbox: the R session still runs with its user's permissions.

## Acceptance checklist

- [x] Resolve the configured response directory and destination parent to real
  paths before permitting a response-file write; reject sibling-prefix and
  symlink escapes, existing destinations and invalid filenames.
- [x] Keep contract file-read behavior unchanged (finding 2 excluded).
- [x] Reject oversized imported lineage payloads with a bounded validation error.
- [x] Compute lineage strongly connected components without recursive traversal.
- [x] Dispose each lineage panel's listeners and graph references when it closes;
  controller disposal also closes owned panels.
- [x] Expose consistent contract and source composition helpers through the
  metapackage, retaining existing supported calls.
- [x] Present `action` and `threshold` as the canonical quality vocabulary and
  retain compatible legacy `severity` and `max_failure` calls.
- [x] Record immutable component commits in the family compatibility manifest.
The merge gate requires complete remote family checks for the exact compatibility
manifest. The pull request's check results are authoritative; the
[workflow history](https://github.com/dataraft-r/dataraft/actions) records the
commit checked by every run.

## Response directory configuration

Trusted session setup chooses `ide_context(response_root = ...)`. Its default is
R's `tempdir()`. The directory must already exist. Request payloads cannot choose
or broaden this root. The response parent is resolved before the containment
check, so a similarly named sibling directory or a symlink to an outside
directory does not grant write access. Existing response destinations remain
invalid.

This is a response-write boundary. It intentionally does not change the files
that `validate_contract` can read and is not an operating-system sandbox.

## Migration principles

Existing scripts should continue to work. The canonical contract revision verb is
`dr_update_contract()` alongside `dr_update_product()` and `dr_update_recipe()`.
`dr_contract_update()` remains a compatibility entry point. A contract revision
still requires explicit review of its identity, version, keys and affected rules;
a naming change must not weaken those checks.

Prefer `action` and `threshold` in new quality rules. Legacy arguments remain
accepted on their own. Supplying both vocabularies for the same setting remains
an error, even when their values agree. This preserves the existing checks
instead of silently changing a blocking rule into a warning or quarantine rule.

The larger constructors remain available. Composition helpers provide smaller
steps when a specification grows; callers are not forced to migrate every
existing `dr_contract()` or `dr_product()` call.

## Small composition steps

```r
contract <- dr_contract("orders", columns = c(id = "integer"))
revised <- dr_update_contract(
  contract, version = "2", columns = c(amount = "numeric")
)
product <- dr_product("orders") |> dr_add_contract(contract)
product <- dr_update_contract(product, revised)
dr_extract_contract(product)

product <- product |> dr_add_source(data.frame(id = 1L, amount = 10))
product <- dr_update_source(product, data.frame(id = 2L, amount = 20))
dr_extract_source(product)

rule <- dr_quality_rule(~ amount >= 0, action = "block", threshold = 0)
```

`dr_remove_contract()` removes the attached contract while retaining additional
quality rules. `dr_remove_source()` edits the definition without reading a source
or deleting its underlying data. Constructors and legacy contract revision calls
continue to be supported.

## Verification boundaries

Automated tests can establish path rejection, graph bounds, lifecycle cleanup and
backward compatibility. They do not constitute human acceptance of the Positron
interface. The interactive manual acceptance item in the
[IDE integration plan](positron-ide.md) remains open.

## Recorded checks

Static checks confirmed the six new exports, inherited help topics, reference
index entries, component pins and minimum versions agree. Local R checks were
not run because this workspace has no R executable. The response-write boundary baseline at `39df7dc` passed bridge component CI
[run 35729701012](https://github.com/dataraft-r/dataraft.ide/actions/runs/35729701012)
in all three jobs, including Windows. The subsequent R lineage bounds change is
pinned separately in the compatibility manifest. The exact compatibility set
must pass the family merge gate above.
Consult its pull request checks for the current result.

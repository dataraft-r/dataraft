# Deep review implementation

Source: maintainer-supplied DataRaft-Tiefenreview.md, 22 September 2026.

## Findings and implementation

| Finding | Resolution |
| --- | --- |
| Undeclared schema reported as passed | Inferred schema/type rows, result metadata, release metadata, HTML and JSON reports say `unvalidated`. Explicit checks still gate publication. |
| Core calls sibling implementations | Executable core source has no sibling namespace calls. Public S3 backend protocols dispatch to provider-owned methods, including third-party target configuration. |
| Unstable quality evidence | Inspect known time/random calls, including namespaced and captured functions; repeat native and pointblank checks. Explicit volatile rules are labelled, non-cacheable and excluded from frozen report approvals. This is not a proof of arbitrary R code purity. |
| IDE file boundaries | Canonical trusted contract root, component-boundary containment, symlink/traversal rejection and request isolation tests. Response-write containment was already fixed on main. |
| Contract constructor overload | `dr_contract_policy()` and `dr_contract_meta()` separate composition. Entry examples use identity, columns and key. The legacy constructor remains for stored definitions and existing positional calls. |
| Competing quality policy vocabularies | Canonical `dr_quality()` accepts action/threshold and rejects legacy policy names. Pointblank uses the same entry. Legacy constructors remain compatible; execution no longer mutates quarantine policy. |
| Lazy check/write race | Generic execution materializes final output before the gate and passes that same snapshot to writers. Regression mutates the source during checking. |
| Quarantine candidate leaks | Cleanup matches candidate suffixes at a run-name boundary, preserves committed releases and avoids matching another run's prefix. |
| Untested run recovery | Abandoned/live/unknown writer cases, dry-run behavior, retained releases and recovery events now tested. |
| Panel lifetime and recursive graph traversal | Already fixed on main. Extension suite rerun: 49 tests pass. |
| Release integrity and registry identity | Schema v6 records typed row-multiset SHA-256 hashes. `dr_verify_releases()` reports changed/missing/inconsistent/unverifiable releases. DuckDB unique indexes; coordinated identity checks on DuckLake. Historical releases without hashes remain unverifiable. |
| Maintenance races and failed publication candidates | Shared PostgreSQL catalog-level writer lock covers publication and maintenance. Failed publication removes candidates only when no committed release marker exists. Killed processes still require recovery. |
| Duplicate catalog package | Implementation, assets and tests moved to adapters. Catalog package is a re-export facade; umbrella no longer imports it. |
| Parallel relational validation implementations | dm is a hard core dependency and the only lookup constraint implementation. Old native spelling remains an alias. dm remains the authoritative relationship model. |
| dbt templates and schema direction | Static example assets moved to inst/templates. New manifest import creates an explicitly unconfirmed R schema draft and requires overrides for unknown types. |
| Descriptive adapter capabilities | Explicit write=false is rejected; model targets require transaction/immutable capabilities. Conformance documents real guarantees and offers a failure injection/committed-state probe. Other flags remain descriptive, not proof of backend guarantees. |
| Repeated family pins | Only the umbrella owns the immutable CI manifest. Components consume it and record resolved SHAs. Development Remotes use the coordinated branch. |
| Entry API and documentation | Seventeen entry topics, separate administration and compatibility groups; product-first executable guide uses dr_run(write = FALSE), explicit contracts and ordinary dplyr/recipes. Guarantees distinguish execution, validation, integrity and retention. |

## Compatibility and architecture decisions

Breaking changes were permitted, not required. The following review proposals are
adapted explicitly rather than silently represented as completed deletions:

- `dr_trial()` is a thin wrapper over `dr_run(write = FALSE)`. Recursive target
  stripping is gone. Existing workflow definitions compile into the same product
  execution path. Their slot-editing compatibility API remains; new users need no
  workflow object. Data passed to an empty product now binds its first delivery.
- `severity` and `max_failure` remain in old serialized rule definitions and the
  compatibility constructors. New `dr_quality()` definitions use one vocabulary.
  Removing every old field and positional constructor argument is not part of this
  compatibility-preserving change.
- Relationships stay in dm rather than adding a second string-based contract
  relationship language. `dr_model_product()` makes the table/model distinction
  explicit. Automatic derivation of all relationships from table contracts is not
  implemented, and documentation does not claim it.
- Shared `dr_internal_*` exports remain a family implementation interface.
  R cannot `importFrom()` an unexported symbol, as the review proposes. Replacing
  them with `:::` would hide coupling rather than remove it. The harmful reverse
  calls from core to providers have been removed; the extension protocols are
  separately documented from the user entry API.
- dbt, metrics and IDE are not combined into a new `dataraft.ext` package. Their
  execution, dependency and process boundaries remain independent. Catalog
  implementation ownership is consolidated without deleting existing repositories.
- Single-process/local coordination and access control remain deployment
  requirements. Release hashes are not signatures; DuckLake uniqueness is not
  falsely documented as a supported database constraint. New and old writer
  versions must not operate concurrently during a coordinated upgrade.

## Verification

The private R 4.5.3 runtime runs the component and umbrella suites with DuckDB,
pointblank, dm, Arrow and targets available. Roxygen help is regenerated, Air
formats changed R source, the executable getting-started guide and pkgdown topic
coverage are checked. `R CMD check --no-manual --ignore-vignettes` uses
`_R_CHECK_FORCE_SUGGESTS_=false`; the ordinary test runs separately exercise
available optional engines. The full umbrella vignette build also succeeds.

Skipped external-service profiles and the Positron manual GUI acceptance are not
counted as passing tests. PostgreSQL multi-process, S3 service behavior, real dbt
CLI and OpenMetadata integration remain CI/deployment gates unless separately
recorded as executed. No performance benchmark or production load claim is made.


All eight packages completed the recorded R CMD check profile with **0 errors,
0 warnings and 0 notes**. Repository index access emitted network diagnostics;
the unavailable optional/service coverage remains identified below. All six
umbrella vignettes built successfully through R CMD build.

### Recorded local test runs

| Suite | Passed assertions | Skipped tests | Failures / warnings |
| --- | ---: | ---: | --- |
| dataraft.core | 1469 | 1 | 0 / 0 |
| dataraft.lake | 681 | 3 | 0 / 0 |
| dataraft.adapters | 314 | 11 | 0 / 0 |
| dataraft.catalog | 2 | 0 | 0 / 0 |
| dataraft.metrics | 175 | 0 | 0 / 0 |
| dataraft.dbt | 207 | 2 | 0 / 0 |
| dataraft.ide | 189 | 0 | 0 / 0 |
| dataraft | 292 | 4 | 0 / 0 |

The complete lake suite was also run against DuckLake: 694 assertions passed,
with zero skipped tests, failures or warnings. The unchanged Positron extension
suite passed all 49 tests. Additional final focused regressions passed: core
review guarantees (31 assertions), publication rollback/partition cleanup (12),
and report integrity including volatile cache/approval exclusion (12).
These focused runs overlap the table and must not be added as independent coverage.

The local installation uses R 4.5.3; CI remains pinned to its recorded R 4.5.1
and dated package snapshot. Windows and live PostgreSQL/S3/CLI execution still
need their CI/deployment profiles. HTTP mock tests requiring unavailable webfakes
and the optional hedgehog property test were explicitly skipped.

### Prepared delivery

Changes are committed on `fix/deep-review` in `dataraft` and its core, lake,
adapters, catalog, metrics, dbt and IDE repositories. The umbrella's
`family-lock.json` identifies the component commits; `scripts/check-family.py`
validates those local checkouts and dependency bounds.

The automated approval review rejected the first GitHub push because it did not
consider the current instruction explicit publication authorization for the
repository destination. No bypass was attempted. The user subsequently explicitly approved pushing these eight branches to
dataraft-r and creating draft PRs against main. Publication proceeds under that approval.
The Positron extension needs no new commit because the reviewed defects were
already fixed on its main branch.

# Ecosystem guarantees and API review

This plan tracks the 22 September 2026 ecosystem review against the merged
compatibility set, rather than treating every reported finding as still open.
Unchecked items require implementation and verification. Breaking changes are
permitted, but must preserve the capabilities they replace and document migration.

This review supersedes the earlier exclusion of contract-file read containment
in [review-boundaries.md](review-boundaries.md). Both read and write boundaries
are now in scope. The R session remains a process with its user's permissions;
these checks constrain bridge requests, not arbitrary code running in that session.

## Verified baseline

- [x] Response destinations are confined to the trusted context's real response
  root. Requests cannot broaden that root.
- [x] Imported lineage and producer output are bounded to 500 nodes and edges.
  Traversal uses iterative strongly connected components rather than recursion.
- [x] Lineage panel disposal releases message listeners and graph references;
  controller disposal closes owned panels, including pending-response races.
- [x] Only `ide_context()` and `ide_request()` are exported by the bridge.
  Metadata and diagnostics have separately named schemas.
- [x] Full remote backend and family checks have run, independently of the
  reviewer's installation limitations. The baseline family checks include
  DuckDB, DuckLake, PostgreSQL, Windows, macOS and minimal installation.
- [x] Native Positron tests exercise the active Ark R session and editor/lineage
  interactions. These automated checks do not sign off human usability.

Baseline evidence: [family PR 7](https://github.com/dataraft-r/dataraft/pull/7),
[family run 35731192317](https://github.com/dataraft-r/dataraft/actions/runs/35731192317),
[extension run 35731641749](https://github.com/dataraft-r/dataraft-positron/actions/runs/35731641749).
These results apply to their recorded commits, not to future changes in this plan.
Minimal-job skips must not be presented as missing full-backend coverage. See the
[IDE plan](positron-ide.md) for the separate human acceptance gate.

## Immediate guarantees

- [ ] Add trusted read-root configuration to the IDE context and realpath
  containment for contract reads. Do not reuse the private response directory
  as an implicit workspace. Cover outside files, sibling prefixes, traversal,
  symlinks, replaced roots and valid editor requests in R and extension tests.
- [ ] Represent absent contracts as `unvalidated` in retained evidence, status
  and reports. Inferred schema information must not be reported as an independent
  validation. Define write-gate and collection behavior explicitly; test both
  contract-free exploration and contract-backed publication.
- [ ] Reject recognized volatile predicates unless explicitly declared volatile.
  Cover time, RNG and SQL randomness, including aliases where detectable. Carry
  volatility into evidence and prevent cache or approval from treating it as
  reproducible validation. Document limits for arbitrary R closures and services.
- [ ] Materialize generic lazy candidates once before validation, and pass that
  same snapshot to the writer. Test a source mutation between gate and writer,
  quarantine behavior, and writer failure.
- [ ] Include run-owned quarantine candidate tables in cleanup without matching
  unrelated tables with similar prefixes. Test successful, blocked, retained and
  dry-run cases.
- [ ] Propagate new statuses and metadata through the bridge schemas, extension,
  metrics and metapackage, without converting unknown states into success.

## Persistence and recovery

- [ ] Test `dr_interrupted()` and run-oriented `dr_recover()` with interrupted
  records, writer-state checks, retry and preserved published releases.
- [ ] Coordinate destructive maintenance with supported shared writers. Test
  contention between publication and cleanup/recovery/expiry; retain the explicit
  local single-writer boundary. Describe `readers_quiescent` as a caller assertion.
- [ ] Clean failed publication candidates when ownership and diagnostic retention
  permit it. Keep crash recovery for failures that cannot run an exit handler.
- [ ] Enforce registry identity uniqueness through a history-preserving migration;
  reject or diagnose existing duplicates rather than silently dropping records.
- [ ] Record a versioned content fingerprint for newly published releases and
  implement `dr_verify_releases()` for missing data, row counts, fingerprints and
  registry consistency. Handle older unverifiable releases explicitly.
- [ ] Test tampering, missing tables, duplicate identity, publication rollback and
  concurrent writers against the relevant real backend.
- [ ] Clarify DuckDB storage location, atomic registry publication versus physical
  intermediate objects, and the limits of local and object-store coordination.

## Architecture and API consolidation

Implement protocol changes before migrating package layout or removing symbols.
The review proposes inconsistent package counts and both independent and combined
IDE modules. A coherent ownership graph and tested migration take precedence over
a numerical package target.

- [ ] Replace executable sibling calls from core with narrowly typed extension
  protocols and registered methods. Verify core alone and an independent adapter.
  Audit executable code separately from documentation examples: the initial
  inspection found roughly 30 executable calls, not 52.
- [ ] Replace privileged backend branches where an extension capability is needed;
  make each consumed capability's guarantees explicit.
- [ ] Remove internal exports only after all production consumers have moved to
  supported protocols. An `importFrom` cannot import an unexported symbol.
- [ ] Offer product-centered composition and `dr_run(write = FALSE)` while
  preserving the existing DAG workflow's dependency blocking and caching. The
  product wrapper and the DAG are different behaviors, not interchangeable names.
- [ ] Unify public quality configuration around `action` and `threshold`, including
  pointblank, with explicit migration and conflict errors instead of silent mutation.
- [ ] Separate contract identity/schema from policy and descriptive metadata through
  small constructors; preserve serialization, versioning and confirmation gates.
- [ ] Reconcile contract relationships and model keys into one source of truth.
  Check dm/native semantic parity and optional-dependency promises before removing
  either path or changing pointblank's default policy.
- [ ] Preserve structured transformation inspection and column lineage when
  simplifying recipe composition. Do not remove functionality to reduce verb count.
- [ ] Assess catalog consolidation after protocol decoupling. The existing catalog
  package owns a Shiny application as well as metadata sinks.
- [ ] Provide a small documented entry API and separate module/administration
  reference groups. Document aliases and migrations for removed entry points.

The existing trial's removal of targets and catalogs edits definitions; it is not
physical storage cleanup. Consolidation must retain its recursive no-write
guarantee, rather than claiming to fix destructive behavior that was not present.

## Integration, documentation and verification

- [ ] Document adapter conformance with normative write, retry, partial-failure and
  secret-handling guarantees; add failure-injection checks where executable.
- [ ] Distinguish observed adapter capabilities from guarantees actually enforced
  by core. Document metadata dispatch fields or replace them with typed protocols.
- [ ] Move dbt example scaffolding into templates and establish manifest ownership
  for imported SQL contracts. Preserve explicit loss reporting and release-bound
  source YAML when supporting export.
- [ ] Position metrics around release-bound computation and attestation; do not
  claim a full semantic layer with joins, ratios or time semantics not implemented.
- [ ] Audit `atomic`, `immutable`, `validated` and `no I/O` claims against regression
  tests or precise limits. Explain that a trial does not test target permissions,
  capacity or subsequent publication conflicts.
- [ ] Update examples and tests that expect successful publication to attach an
  explicit contract; keep deliberate contract-free tests proving `unvalidated`.
- [ ] Update affected immutable pins from one reviewed compatibility set and run
  component/full-family checks plus native Positron/R interaction on exact heads.
- [ ] Record human Positron acceptance with participant, platform and observations,
  including a twelve-product graph, blocked run and YAML editing workflow.

## Implementation constraints

Two equal predicate evaluations do not prove determinism. Static detection is a
guard against recognized volatility, not a proof about arbitrary user code.
`all.vars()` is not an equivalent replacement for `codetools` free-binding analysis.
Do not weaken closure fingerprints to remove a dependency.

Mutable `Remotes` branches would weaken reproducibility. Keep immutable tested
references and use the [pin maintenance policy](../pin-maintenance.md); simplify
their generation rather than replacing reviewable inputs with moving targets.

A release hash detects changes relative to its recorded reference. A user who can
alter both the data and registry can alter both hashes too; this is not an
authenticity proof or an independent audit ledger. Likewise `on.exit()` does not
run after an uncatchable process kill or machine failure. Recovery remains needed.

## Execution record

Status: implementation is present in the candidate compatibility set; complete
family verification is pending. The unchecked acceptance items above include
verification, not just code presence. Do not treat them as completed until the
exact set passes its required checks.

| Work stream | Implemented in the candidate | Verification boundary |
| --- | --- | --- |
| Core execution | Contract-free `unvalidated`, explicit volatility, one lazy candidate materialization, no-write execution | Current core full checks are not yet green |
| Core protocols and API | Registered extension protocols, contract policy/meta composition, canonical quality vocabulary | Component and downstream compatibility must pass together |
| IDE and extension | Trusted read containment, status propagation, transport and editor integration | Earlier candidate IDE/extension checks passed; new family pins require fresh checks |
| Lake | Candidate cleanup, maintenance gates, run recovery tests, registry migration and release verification | New real PostgreSQL gate tests and backend matrix remain pending |
| dbt and adapters | Editable starter templates, declared publication contracts, normative adapter conformance | R checks, real dbt build and conformance example await candidate CI |
| Metapackage | Exported builders/verification, explicit contract fixtures, honest guarantee documentation | Full compatibility matrix pending |
| Pin maintenance | Reviewed-lock DESCRIPTION generation and no-write check | Four local Python tests passed; workflow now invokes them |

`family-lock.json` and matching `DESCRIPTION` references identify the candidate.
The umbrella version is `0.1.0.9001`; a development version is not a published
release or a declaration that the candidate is already compatible. Catalog fixture
migration is included in the candidate; fresh family checks remain required.

### Assessed architecture choices

The implementation retains the DAG workflow: its independent branches, dependency
blocking and incremental retry are useful behavior, not a second name for a
product. Product-centered execution and a no-write argument simplify the common
path without deleting that orchestration capability.

Catalog packaging remains separate in this change because it includes the Shiny
application as well as sinks. Its integration is decoupled through protocols;
repository consolidation would require a separate dependency and migration plan.
Likewise the native relation checks remain available for installations without
dm. Removing them would change the optional-dependency guarantee. This work does
not claim that the review's proposed package fusions or all symbol removals have
been implemented.

Immutable references remain the reproducibility policy. A DESCRIPTION generator
now consumes the reviewed umbrella lock, with a no-write consistency mode and
standard-library regression tests. It does not fetch moving branches or rewrite
component lock snapshots. Generator tests are part of the family check workflow;
the four local Python tests passed during implementation. R/backend and interface
changes still require their exact-commit hosted checks.

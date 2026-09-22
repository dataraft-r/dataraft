# Positron IDE integration

The integration makes existing DataRaft metadata and diagnostics available in
the active R session. It keeps execution and governance in the R packages.
Publishing, approval and scheduling are outside this extension's command set.

## Phases and acceptance checks

| Phase | Deliverable | Acceptance evidence |
| --- | --- | --- |
| 0 | Register and close real lake Connections entries; explicit refresh; catalog viewer; `dr_review()` | Mock IDE lifecycle callbacks; close/refresh ownership; actual Shiny URL callback; bounded View diagnostics |
| 1 | Optional `dataraft.ide` package with version 1 metadata envelopes | Contract tests for products, product details, lineage, quality, releases, runs, freshness and incidents; JSON round trip and error envelope tests |
| 2 | Separate `dataraft-positron` TypeScript extension | Active R session request, private known response path with request ID, tree view, directed lineage, exact source diagnostics, View commands and refresh timestamps |
| 3 | YAML contract custom editor with sample profiling and quality feedback | YAML remains sole source, input validation and save tests, sample-only feedback, no R or recipe rewriting |

Implementation ownership is split between core (`dr_review()`), lake (connection
lifecycle), catalog (`dr_catalog_pane()`), the optional IDE R package and the
separate extension. The metapackage reexports the phase 0 helpers; adding the
optional IDE package does not make normal DataRaft use depend on an IDE.

- [x] Catalog pane returns a Shiny app when `launch = FALSE`.
- [x] Shiny's launch callback passes its real URL to the viewer.
- [x] Missing or failing viewers fall back to the system browser.
- [x] Catalog foreground execution and live connection lifetime are documented.
- [x] Compiler-free RDS example distinguishes file releases from a real lake.
- [x] Umbrella integration verifies that viewing a blocked delivery does not write its RDS target.
- [x] Phase 0 core and lake integration test results recorded.
- [x] Phase 1 R metadata and request transport tests recorded.
- [x] Phase 2 TypeScript compile and extension tests recorded.
- [x] Phase 3 editor/profile tests recorded.
- [x] Published phase 0 component SHAs recorded in the umbrella lock.
- [ ] Complete eight-package CI after new-repository publication.
- [ ] Interactive Positron manual acceptance checks.

## Architecture decisions

Metadata envelopes carry a schema version and request identifier. The extension
sends a request to the active R session and reads the response from a known,
private file. It does not scrape console output. Paths, contexts and requests
must be validated before use. Request IDs associate responses with their
originating action and prevent an old response being displayed as current.

The metadata reader returns only the requested context. It must not silently
scan or evaluate unrelated R objects. Directed lineage preserves edge direction;
source diagnostics use supplied file/line locations instead of inferred text
matches. Product inspection and diagnostic viewing do not publish data.

The existing Shiny catalog occupies the R session until stopped. A real live
connection stays in that process. A separate-process server could consume an
exported snapshot in future; the current wrapper makes no nonblocking claim.

The contract editor writes YAML only. R source and recipes retain their existing
ownership. Profiling and quality results describe the explicit sample used,
not an unexamined full dataset. The editor has no production publish, approval
or schedule controls.

The optional R package is planned as the seventh checked component, with the
umbrella as the eighth package. Pinned family checks, full optional dependencies, minimal
installation and coverage must include it. The lightweight IDE package does not
receive the duplicated standalone core implementation helpers.

## Current verification

| Scope | Recorded evidence | Boundary |
| --- | --- | --- |
| Core phase 0 | Full suite passed; 43 focused assertions | Data viewer behavior mocked, not a graphical session |
| Lake phase 0 | 79 focused assertions and regression tests passed | Automated lifecycle tests |
| Catalog and umbrella | Seven pane assertions plus four review integration assertions passed; RDS demo and ODCS sample generation/import passed | No real browser or IDE session launched |
| Existing component CI | Core, lake and catalog phase 0 PR #5 checks passed | Umbrella PR #5 checks were still running at this checkpoint |
| R bridge phase 1 | 70 assertions and 16 operation fixtures passed | Final package check result is recorded separately when complete |
| R/TypeScript interoperability | 20 real R responses passed strict JSON Schema and TypeScript validation: 15 workspace/lake operations plus five requests in one persistent R process | Proves the file/protocol boundary, not Positron UI behavior |
| Extension/editor | TypeScript build and 23 automated tests passed at the phase 3 checkpoint; selected profile columns, preview/apply, and failed-rule YAML AST diagnostics exercised | Graphical extension-host checks remain unrun |

These counts describe their respective test runs; they are not added into a
single total because some suites overlap. A real Positron GUI and graphical
extension-host environment were unavailable. Follow the
[manual installation and acceptance guide](../../examples/positron-ide/README.md)
to validate that remaining boundary. The R bridge and TypeScript source are
implemented; repository publication and the full eight-package CI remain blocked
by new-repository access, not replaced by the existing seven-package checks.

## Publication and CI handoff

GitHub App access currently permits the existing family repositories but not
the newly created IDE repositories. The standalone R package and VSIX can be
reviewed and installed from local deliverables. No empty repository or moving
branch is used as a compatibility pin.

`maintenance/positron-ide-ci.pending.patch` contains the separate eight-package
CI changes. Apply it only after `dataraft.ide` code has been published, add its
actual immutable commit and version to `family-lock.json`, and add that exact
commit to the umbrella's `Remotes`. Then run pinned family checks. The publishable
phase 0 metapackage retains its existing seven-package checks in the meantime.

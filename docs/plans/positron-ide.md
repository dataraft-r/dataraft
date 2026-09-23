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
- [x] Publish the IDE R bridge and configure immutable eight-package CI.
- [x] Confirm the first complete remote eight-package CI run (35694633104).
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

The optional R package is the seventh checked component, with the umbrella as
the eighth package. Pinned family checks, full optional dependencies, minimal
installation and coverage include it. The lightweight IDE package does not
receive the duplicated standalone core implementation helpers.

## Current verification

Evidence checked on 22 September 2026:

| Scope | Recorded evidence | Boundary |
| --- | --- | --- |
| Eight-package integration | [Run 35694633104](https://github.com/dataraft-r/dataraft/actions/runs/35694633104), commit `08a6bfd58bc3ffd81ce1109e6f51ad490b8d2474`: all seven jobs passed | Includes both DuckDB/DuckLake jobs, PostgreSQL writers, Windows, macOS, R 4.2.3 and minimal installation; subsequent compatibility sets need their own run |
| Native Positron | [Run 35707191483](https://github.com/dataraft-r/dataraft-positron/actions/runs/35707191483): all three jobs passed | Pinned Positron 2026.09.1-2, Ark R 4.5.1, eight automated user journeys, 43 extension tests and 28 persistent R responses; not a human usability study |
| Lake baseline full component CI | [Job 106637797508](https://github.com/dataraft-r/dataraft.lake/actions/runs/35694284653/job/106637797508): 660 passed assertions, zero failures/warnings, three skipped test blocks | All three skips required the explicit DuckLake flag; this review enables it and requires zero skipped blocks in full CI |
| Lake baseline minimal installation | [Job 106637797645](https://github.com/dataraft-r/dataraft.lake/actions/runs/35694284653/job/106637797645): 57 passed assertions, 99 skipped blocks | Deliberately has no optional engines; these counts do not describe full integration coverage |
| Metrics baseline full component CI | [Job 106562069672](https://github.com/dataraft-r/dataraft.metrics/actions/runs/35669335282/job/106562069672): 175 passed assertions, zero failures/warnings/skips | The reported 55% skip figure does not describe this full run |
| Metrics baseline minimal installation | [Job 106562070049](https://github.com/dataraft-r/dataraft.metrics/actions/runs/35669335282/job/106562070049): 29 passed assertions, 26 skipped blocks | Optional lake and other integration dependencies are deliberately absent |
| Interactive manual acceptance | Not signed off | Human assessment of readable lineage, understandable blocked-run state and usable YAML editing remains required |

Passed assertions and skipped test blocks are different units. Do not derive a
coverage percentage by dividing one by the other. Full lake and metrics checks
write `test-summary.csv` and `test-skips.csv` alongside their test logs, including
block names and reasons. `DATARAFT_REQUIRE_ALL_TESTS=true` makes skipped blocks
fail these packages' full CI and the Linux eight-package integration jobs.
Minimal dependency and portability jobs keep their explicit optional-backend
boundaries. They are reported separately from full integration tests.

The first remote family run is complete; the previous unchecked item was stale
documentation. Follow the [manual acceptance guide](../../examples/positron-ide/README.md)
for the remaining human gate. Automated GUI clicks and screenshots are useful
evidence but cannot sign off a person's comprehension or usability assessment.

## Bridge and dependency policy

The extension-facing R API consists of `ide_context()` and `ide_request()`.
Operation implementations are private. Metadata and diagnostics have separately
named schemas; the existing numeric wire versions remain unchanged. `ide_`
marks the IDE bridge boundary; user-facing DataRaft verbs remain `dr_`.

`dataraft.ide` intentionally remains in the metapackage's `Suggests`: ordinary
DataRaft workflows must install and work without IDE support. Development
versions are independent per package; `.9001` is not forced back to `.9000` to
make a family look uniform. `family-lock.json` records the exact versions and
commits that are checked together.

See [pin maintenance](../pin-maintenance.md) for ownership, update cadence and
the verification required before a compatibility set changes. The extension
remains a separately packaged VSIX; no marketplace release is implied.

The subsequent [current API guide](current-api.md) tracks
response-path restrictions, imported graph bounds, panel cleanup and compatible
core API composition. Contract file-read restrictions are explicitly outside
that review change.

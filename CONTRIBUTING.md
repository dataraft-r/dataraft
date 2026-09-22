# Contributing to DataRaft

This repository is the `dataraft` metapackage. Implementations live in the seven
component repositories under https://github.com/dataraft-r. The installation script
clones them into `packages/` when needed. Add behavior to its owning component;
keep the umbrella package free of engines. Use explicit namespace references
across package boundaries and register S3 methods with their generic's owner.

From the repository root:

```r
source("scripts/install-family.R")
source("scripts/check.R")
```

Use the Posit R package development and testing skills. Format R code with Air.
Edit roxygen source comments, then run `roxygen2::roxygenise()` for the changed
component and the root when re-exports change. Do not edit generated Rd or
NAMESPACE files. Update the owning package's NEWS for behavior changes.

The umbrella tests exercise interactions between packages; component tests
cover independent use. Integration fixtures may inspect internal functions,
but production code must use declared imports and extension protocols.
CI checks every source package, an installation with only core dependencies,
and PostgreSQL coordination. Coverage artifacts are reported per component.

Keep the three shared guides focused. Generate README.md from README.Rmd.
Before 1.0 there are no compatibility aliases, migration guides or stored-format
upgrades. Remove obsolete behavior and documentation with its replacement.


## Test the owning component

Run `testthat::test_local()` in the component you changed. Core tests cover
contracts, recipes and diagnostics without a lake. Adapter and integration tests
skip explicitly when their optional engine is unavailable. Keep tests that span
lake publication, measurement and catalogs in the metapackage.

The metapackage CI checks immutable component commits in `family-lock.json`.
The nightly workflow separately checks sibling `main` branches. Publish reviewed
component commits before updating the compatibility set; see
[pin maintenance](docs/pin-maintenance.md). Component CI remains responsible for
independent checks.

Public S3 protocols are supported extension interfaces. Exported helpers marked
`@keywords internal` are family implementation interfaces, not a separate user API;
do not remove them while another component imports or calls them. Changes to
these helpers need tests in their consumers as well as the defining component.


## Family implementation boundaries

Public user verbs and extension protocols use `dr_`. Names beginning with
`dr_internal_` are family implementation interfaces, not extension APIs.
Stateless helpers are private copies of
`dataraft.core/inst/standalone/standalone-dataraft.R`; run
`Rscript scripts/sync-standalone.R` from this repository to update all checkouts.
Execution state, connections and publication logic must not be copied.

Each component owns its unit and backend tests. Cross-component scenarios remain
here. The canonical lake fixture is `dataraft.lake/inst/test-fixtures/lake.R`;
other tests load it only when lake is installed. Changes to that fixture should
also update its local `tests/testthat/helper-fixture.R` copy.

Component CI runs its own check, the metapackage integration suite against that
component commit, and a separate job installing only hard dependencies. Sibling source is pinned in each component compatibility manifest.
The downstream check runs on every component push to main and pull request,
without a cross-repository dispatch token. The metapackage's full matrix remains
the cross-platform and PostgreSQL/DuckLake gate.

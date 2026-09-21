# Contributing to DataRaft

This repository is the `dataraft` metapackage. Implementations live in the six
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

The metapackage CI uses matching component branches on pull requests when they
exist, otherwise `main`. This allows coordinated family changes to be reviewed
before merging. Component CI remains responsible for independent checks.

Public S3 protocols are supported extension interfaces. Exported helpers marked
`@keywords internal` are family implementation interfaces, not a separate user API;
do not remove them while another component imports or calls them. Changes to
these helpers need tests in their consumers as well as the defining component.

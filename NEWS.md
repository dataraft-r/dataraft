# dataraft 0.1.0.9004

* Integrate the deep review hardening across the package family.
* Make product-first execution with write = FALSE the documented entry path.
* Expose unvalidated evidence, release integrity verification and bounded contract composition.
* Move catalog ownership to adapters and consolidate CI pins into this repository.
* Record compatibility decisions and remaining external acceptance gates in docs/plans/deep-review-implementation.md.

# dataraft 0.1.0.9000

* The optional `dataraft.ide` bridge joins the immutable family lock, full checks, minimal dependency checks, coverage and reference site.

* `dr_review()`, `dr_catalog_pane()` and `dr_refresh_connection()` expose IDE diagnostics, a foreground catalog viewer and live connection refresh.

* Family CI uses immutable sibling references and a dated CRAN snapshot; nightly checks exercise current sibling branches separately.
* The metapackage reference now includes inherited executable examples.

* `dr_demo()` demonstrates blocked and successful insurance deliveries entirely in memory.

* Replace combined reexport help with individual inherited references. Add an execution cheatsheet, open-contracts vignette, security policy, roadmap, compiler-free example, numeric CI coverage summaries and accessibility checks. CRAN submission remains deferred.

* Re-export session failure diagnostics and versioned RDS storage. Restore the relational insurance guide; keep component tests with their implementations.

* Add a guided API reference, motivation vignette, execution-path guide and local pins example. Move component unit tests to their owners and support matching component branches in pull-request CI.

* Start the DataRaft package family with the `dr_` API.
* Separate core definitions and execution from lake, adapters, dbt, catalogs
  and metrics. The `dataraft` package is the shared installation and API entry.
* Keep three guides: getting started, integrations, and guarantees and limits.
* Add a shared condition root and subsystem classes.

The predecessor's development history remains in Git. DataRaft does not promise
compatibility with earlier development APIs or storage formats before 1.0.

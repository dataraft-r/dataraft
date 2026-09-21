# dataraft 0.1.0.9000

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

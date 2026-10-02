# Insurance platform example

This is the runnable project used in Part VI of *Data Platforms with R*.
It stays local and credential-free: CSV inputs are checked in memory and the
final product can be published as immutable local RDS releases.

From the book root:

```sh
Rscript examples/insurance-platform/run.R
Rscript scripts/verify-examples.R
```

The example intentionally uses explicit component namespaces for functions that
are not re-exported by the `dataraft` metapackage.

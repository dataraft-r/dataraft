# Insurance platform example

This is the runnable project used in Part VI of *Data Platforms with R*.
It stays local and credential-free: checked-in CSV fixtures become six logical
products, the complete graph is validated in memory, and the final product can
be published as an immutable local RDS release.

The governed publication path also demonstrates:

- a publish policy requiring owner metadata;
- a declared `reporting_extract` output port;
- a daily delivery SLA recorded as run evidence;
- dataset lineage from the executed root product;
- exact versioned RDS read-back.

From the book root:

```sh
Rscript examples/insurance-platform/run.R
Rscript scripts/verify-examples.R
```

The example intentionally uses explicit component namespaces for functions that
are not re-exported by the `dataraft` metapackage. The fixed
`business_date = "2026-10-02"` in the publication example belongs to this
audited book edition and keeps the SLA example explicit.

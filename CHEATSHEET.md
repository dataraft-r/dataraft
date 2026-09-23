# DataRaft in one page

**Keep a report reproducible:** retain its metric definition, input release IDs,
quality evidence and report release. A saved number alone is not provenance.

| Your task | Call |
|---|---|
| Name an asset and its requirements | `dr_product()` + `dr_add_contract()` |
| Describe columns and keys | `dr_contract()` |
| Import a reviewable contract file | `dataraft.adapters::dr_contract_from_odcs()` |
| Define transformations | `dataraft.core::dr_recipe()` + `dr_step_*()` |
| Bind asset, recipe, source and target | `dataraft.core::dr_workflow()` + `dr_add_*()` |
| Check a delivery without writing | `dr_run(write = FALSE, )` |
| Inspect checks and rejected rows | `dr_quality_report()`, `dataraft.core::dr_quality_rows()` |
| Recover a failed piped run | `dr_last_failure()` |
| Collect checked output | `dr_collect()` |
| Execute the configured writer | `dr_run()` |
| Choose a destination at execution | `dr_publish(..., to = target)` |
| Freeze a versioned report | `dataraft.metrics::dr_report_release()` |

Start with `dr_run(write = FALSE, )`. If the delivery passes, bind a target and use `dr_run()`.
`dataraft.lake::dr_ingest()` is the lake-specific ingestion API. `dataraft.core::dr_write_target()` and
`dataraft.core::dr_publish_metadata()` are extension protocols, not additional beginner verbs.

| Quality action | Effect |
|---|---|
| `block` | Above `threshold`, no publication |
| `warn` | Above `threshold`, retain a warning and publish |
| `quarantine` | Remove every failing row; validate the remainder before writing |

`threshold = .02` tolerates a two-percent failure fraction for block/warn.
Quarantine always removes failures, including missing predicate values.
Inspect `dataraft.core::dr_quarantine_rows(result)` locally; saving sensitive rows is explicit.
Evaluation errors always block. Contracts still check keys, types and required
columns after quarantine. A fully rejected delivery needs `allow_empty = TRUE`.

Vocabulary: product = asset specification; recipe = transformation model;
trial = validation-only run; delivery = input batch; release = versioned snapshot;
measurement = evaluated metric. These labels describe roles, not a new storage standard.

Attach reusable preparation with `dataraft.core::dr_add_recipe(product, recipe)`.
Direct dplyr verbs on a product are a compact alternative. Sources, preparation,
checks and destinations all belong to the product definition.

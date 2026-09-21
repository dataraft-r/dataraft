# DataRaft in one page

**Keep a report reproducible:** retain its metric definition, input release IDs,
quality evidence and report release. A saved number alone is not provenance.

| Your task | Call |
|---|---|
| Name an asset and its requirements | `dr_product()` + `dr_add_contract()` |
| Describe columns and keys | `dr_contract()` |
| Import a reviewable contract file | `dr_contract_from_odcs()` |
| Define transformations | `dr_recipe()` + `dr_step_*()` |
| Bind asset, recipe, source and target | `dr_workflow()` + `dr_add_*()` |
| Check a delivery without writing | `dr_trial()` |
| Inspect checks and rejected rows | `dr_quality_report()`, `dr_quality_rows()` |
| Recover a failed piped run | `dr_last_failure()` |
| Collect checked output | `dr_collect()` |
| Execute the configured writer | `dr_run()` |
| Choose a destination at execution | `dr_publish(..., to = target)` |
| Freeze a versioned report | `dr_report_release()` |

Start with `dr_trial()`. If the delivery passes, bind a target and use `dr_run()`.
`dr_ingest()` is the lake-specific ingestion API. `dr_write_target()` and
`dr_publish_metadata()` are extension protocols, not additional beginner verbs.

| Quality action | Effect |
|---|---|
| `block` | Above `threshold`, no publication |
| `warn` | Above `threshold`, retain a warning and publish |
| `quarantine` | Remove every failing row; validate the remainder before writing |

`threshold = .02` tolerates a two-percent failure fraction for block/warn.
Quarantine always removes failures, including missing predicate values.
Inspect `dr_quarantine_rows(result)` locally; saving sensitive rows is explicit.
Evaluation errors always block. Contracts still check keys, types and required
columns after quarantine. A fully rejected delivery needs `allow_empty = TRUE`.

Vocabulary: product = asset specification; recipe = transformation model;
trial = validation-only run; delivery = input batch; release = versioned snapshot;
measurement = evaluated metric. These labels describe roles, not a new storage standard.

Use recipe composition for new work. Direct dplyr verbs on a product are a compact
alternative for standalone products. Move those steps into a recipe before adding
that product to a modular workflow with `dr_add_product()`.

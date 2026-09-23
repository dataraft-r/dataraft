# Current DataRaft API

The development family intentionally has no backward compatibility layer.
The metapackage exposes 17 product verbs and `dr_demo()`. Advanced capabilities
are available from their owning component namespaces.

- Compose sources with `dr_set_sources()`; named `NULL` removes a source and
  `sources = NULL` clears all sources. `.recursive = TRUE` replaces deliveries
  in dependency graphs.
- Attach or replace a contract with `dr_add_contract()`; `NULL` removes it.
  Read definitions through `product$contract` and `product$sources`.
- Declare contract identity, columns, key, rules and version with `dr_contract()`.
  Compose metadata with `dr_contract_meta()` and policy with `dr_contract_policy()`.
  Revise a contract explicitly with `dr_contract_update()`.
- Rules use `action` and `threshold` across native, pointblank and reference checks.
  Diagnostic evidence still uses `severity`; it is a result field, not a rule argument.
- Attach recipes directly to products. `dr_workflow()` is only for named function
  dependency graphs with an explicit code version.
- Check with `dr_run(x, write = FALSE)`; choose `stop_on_failure = FALSE` to inspect
  blocked results. Productive runs use a bounded session-local determinism cache;
  dry runs repeat checks, and changed rules are checked again.
- Catalog applications, freshness and metadata publishers live in `dataraft.adapters`.
- Lakes require registry schema v6. Unsupported registries are rejected without
  modification. Release verification still reports missing evidence instead of
  inventing an integrity guarantee.

The full CI profile rejects unapproved skipped tests, runs actual concurrent
PostgreSQL/DuckLake writers, and checks contract evolution between releases.
Positron tests cover containment errors and subsequent queue recovery.

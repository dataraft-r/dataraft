# Test bindings for this package; unavailable optional packages are not loaded.
family_owners <- c(
  "dr_source_api" = "dataraft.adapters",
  "dr_compare" = "dataraft.lake",
  "dr_source_database" = "dataraft.adapters",
  "dr_source_release" = "dataraft.lake",
  "dr_add_source" = "dataraft.core",
  "dr_add_transform" = "dataraft.core",
  "dr_add_contract" = "dataraft.core",
  "dr_add_quality" = "dataraft.core",
  "dr_set_target" = "dataraft.core",
  "dr_explain" = "dataraft.core",
  "dr_contract" = "dataraft.core",
  "dr_quality_rule" = "dataraft.core",
  "dr_pointblank_checks" = "dataraft.core",
  "dr_validate" = "dataraft.core",
  "quality_ok" = "dataraft.core",
  "dr_quality_errors" = "dataraft.core",
  "dr_dbt_contract" = "dataraft.dbt",
  "dr_dbt_init" = "dataraft.dbt",
  "dr_dbt_publish" = "dataraft.dbt",
  "dr_dbt_sources" = "dataraft.dbt",
  "dr_dbt_build" = "dataraft.dbt",
  "dr_check_delivery" = "dataraft.lake",
  "dr_status" = "dataraft.core",
  "dr_quality" = "dataraft.core",
  "dr_releases" = "dataraft.lake",
  "dr_execution_config" = "dataraft.core",
  "dr_publish" = "dataraft.core",
  "dr_collect" = "dataraft.core",
  "dr_ingest_data" = "dataraft.lake",
  "dr_ingest" = "dataraft.lake",
  "dr_add_lookup" = "dataraft.core",
  "dr_metric_set" = "dataraft.metrics",
  "dr_metric" = "dataraft.metrics",
  "dr_measure" = "dataraft.metrics",
  "dr_report_release" = "dataraft.metrics",
  "dr_report_read" = "dataraft.metrics",
  "dr_as_targets" = "dataraft.adapters",
  "dr_pipeline" = "dataraft.lake",
  "dr_step_land" = "dataraft.lake",
  "dr_step_extract" = "dataraft.lake",
  "dr_step_validate" = "dataraft.lake",
  "dr_step_publish" = "dataraft.lake",
  "new_run" = "dataraft.lake",
  "persist_quality" = "dataraft.lake",
  "dr_run" = "dataraft.core",
  "dr_add_product" = "dataraft.core",
  "dr_add_recipe" = "dataraft.core",
  "dr_extract_product" = "dataraft.core",
  "dr_product" = "dataraft.core",
  "dr_model" = "dataraft.core",
  "dr_init_project" = "dataraft.adapters",
  "dr_quality_rows" = "dataraft.core",
  "dr_recipe" = "dataraft.core",
  "dr_step_transform" = "dataraft.core",
  "dr_step_mutate" = "dataraft.core",
  "dr_step_lookup" = "dataraft.core",
  "writer_identity" = "dataraft.lake",
  "dr_recover" = "dataraft.lake",
  "dr_registry" = "dataraft.lake",
  "dr_register" = "dataraft.lake",
  "dr_tbl" = "dataraft.lake",
  "dr_replace_sources" = "dataraft.core",
  "dr_run_history" = "dataraft.core",
  "dr_registry_duckdb" = "dataraft.lake",
  "dr_storage_local" = "dataraft.lake",
  "dr_lake_config" = "dataraft.lake",
  "dr_connect_lake" = "dataraft.lake",
  "dr_disconnect_lake" = "dataraft.lake",
  "dr_open_lake" = "dataraft.lake",
  "dr_close_lake" = "dataraft.lake",
  "dr_write_data" = "dataraft.lake",
  "automatic_schema" = "dataraft.core",
  "dr_read_release" = "dataraft.lake",
  "dr_trial" = "dataraft.core",
  "uid" = "dataraft.core",
  "canonical" = "dataraft.core",
  "fingerprint" = "dataraft.core",
  "exec" = "dataraft.lake",
  "meta" = "dataraft.lake",
  "dr_workflow" = "dataraft.core",
  "pipeline_step_transform" = "dataraft.lake",
  "dr_plan" = "dataraft.core",
  "dr_execute" = "dataraft.core"
)
for (name in names(family_owners)) {
  owner <- family_owners[[name]]
  if (requireNamespace(owner, quietly = TRUE)) {
    assign(name, get(name, asNamespace(owner), inherits = FALSE))
  }
}
local_family_bindings <- function(..., .package = NULL, .env = parent.frame()) {
  bindings <- list(...)
  if (
    !is.null(.package) && !.package %in% c("dataraft", unique(family_owners))
  ) {
    return(do.call(
      testthat::local_mocked_bindings,
      c(bindings, list(.package = .package, .env = .env))
    ))
  }
  owners <- unname(family_owners[names(bindings)])
  if (anyNA(owners)) {
    stop("Unknown mocked family binding")
  }
  for (owner in unique(owners)) {
    do.call(
      testthat::local_mocked_bindings,
      c(bindings[owners == owner], list(.package = owner, .env = .env))
    )
  }
}

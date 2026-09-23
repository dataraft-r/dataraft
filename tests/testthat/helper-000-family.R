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
  "dr_add_recipe" = "dataraft.core",
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
    package_bindings <- bindings[owners == owner]
    aliases <- paste0("dr_internal_", names(package_bindings))
    shared <- aliases %in% getNamespaceExports(owner)
    package_bindings <- c(
      package_bindings,
      stats::setNames(package_bindings[shared], aliases[shared])
    )
    do.call(
      testthat::local_mocked_bindings,
      c(package_bindings, list(.package = owner, .env = .env))
    )
  }
}

# Advanced integration fixtures use component namespaces, not meta reexports.
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_add_catalog <- get("dr_add_catalog", asNamespace("dataraft.core"))
}

if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_add_recipe <- get("dr_add_recipe", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_add_source <- get("dr_add_source", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_as_targets <- get("dr_as_targets", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_capabilities <- get("dr_capabilities", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_app <- get("dr_catalog_app", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_export <- get(
    "dr_catalog_export",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_openlineage <- get(
    "dr_catalog_openlineage",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_openmetadata <- get(
    "dr_catalog_openmetadata",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_openmetadata_dbt <- get(
    "dr_catalog_openmetadata_dbt",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_check_component <- get("dr_check_component", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_check_delivery <- get("dr_check_delivery", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_cleanup <- get("dr_cleanup", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_close_lake <- get("dr_close_lake", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_commons_yaml <- get("dr_commons_yaml", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_compare <- get("dr_compare", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_component_capabilities <- get(
    "dr_component_capabilities",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_confirm <- get(
    "dr_contract_confirm",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_diff <- get("dr_contract_diff", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_from <- get("dr_contract_from", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_update <- get("dr_contract_update", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_contract_yaml <- get("dr_contract_yaml", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_build <- get("dr_dbt_build", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_contract <- get("dr_dbt_contract", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_init <- get("dr_dbt_init", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_lineage <- get("dr_dbt_lineage", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_model <- get("dr_dbt_model", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_project <- get("dr_dbt_project", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_publish <- get("dr_dbt_publish", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_sources <- get("dr_dbt_sources", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_status <- get("dr_dbt_status", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_test <- get("dr_dbt_test", asNamespace("dataraft.dbt"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_execute_transform <- get(
    "dr_execute_transform",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_execution_config <- get(
    "dr_execution_config",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_expect_quality <- get("dr_expect_quality", asNamespace("dataraft.core"))
}

if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_extract_recipe <- get("dr_extract_recipe", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_freshness <- get("dr_freshness", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_incidents <- get("dr_incidents", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_ingest <- get("dr_ingest", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_init_project <- get("dr_init_project", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_interrupted <- get("dr_interrupted", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_lake_config <- get("dr_lake_config", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_lookup_spec <- get("dr_lookup_spec", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_measure <- get("dr_measure", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_metric <- get("dr_metric", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_metric_set <- get("dr_metric_set", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_open_lake <- get("dr_open_lake", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_plan <- get("dr_plan", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_pointblank_checks <- get(
    "dr_pointblank_checks",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_pointblank_report <- get(
    "dr_pointblank_report",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_profile_data <- get("dr_profile_data", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_publish_metadata <- get(
    "dr_publish_metadata",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quality_counts <- get("dr_quality_counts", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quality_errors <- get("dr_quality_errors", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quality_reference <- get(
    "dr_quality_reference",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quality_rows <- get("dr_quality_rows", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quality_rule <- get("dr_quality_rule", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_read_release <- get("dr_read_release", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_read_run <- get("dr_read_run", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_read_source <- get("dr_read_source", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_recipe <- get("dr_recipe", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_recover <- get("dr_recover", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_register <- get("dr_register", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_registry <- get("dr_registry", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_registry_duckdb <- get("dr_registry_duckdb", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_registry_postgres <- get(
    "dr_registry_postgres",
    asNamespace("dataraft.lake")
  )
}

if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_remove_recipe <- get("dr_remove_recipe", asNamespace("dataraft.core"))
}

if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_report_read <- get("dr_report_read", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_report_release <- get("dr_report_release", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_retry_catalogs <- get("dr_retry_catalogs", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_run_history <- get("dr_run_history", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_run_quality <- get("dr_run_quality", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_set_engine <- get("dr_set_engine", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_api <- get("dr_source_api", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_database <- get(
    "dr_source_database",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_source_file <- get("dr_source_file", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_parquet <- get(
    "dr_source_parquet",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_pins <- get("dr_source_pins", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_source_release <- get("dr_source_release", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_sql_transform <- get("dr_sql_transform", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_status <- get("dr_status", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_arrange <- get("dr_step_arrange", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_distinct <- get("dr_step_distinct", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_filter <- get("dr_step_filter", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_lookup <- get("dr_step_lookup", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_mutate <- get("dr_step_mutate", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_rename <- get("dr_step_rename", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_select <- get("dr_step_select", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_summarise <- get("dr_step_summarise", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_step_transform <- get("dr_step_transform", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_storage_local <- get("dr_storage_local", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_storage_s3 <- get("dr_storage_s3", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_target_database <- get(
    "dr_target_database",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_target_lake <- get("dr_target_lake", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_target_parquet <- get(
    "dr_target_parquet",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_target_pins <- get("dr_target_pins", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_transform_dbt <- get("dr_transform_dbt", asNamespace("dataraft.dbt"))
}


if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_update_recipe <- get("dr_update_recipe", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_validate <- get("dr_validate", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_workflow <- get("dr_workflow", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_write_data <- get("dr_write_data", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_write_target <- get("dr_write_target", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_target_rds <- get("dr_target_rds", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_rds <- get("dr_source_rds", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_quarantine_rows <- get("dr_quarantine_rows", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_profile_snapshot <- get(
    "dr_profile_snapshot",
    asNamespace("dataraft.core")
  )
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_profile_compare <- get("dr_profile_compare", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_column_lineage <- get("dr_column_lineage", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_contract_odcs <- get("dr_contract_odcs", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_contract_from_odcs <- get(
    "dr_contract_from_odcs",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_project_yaml <- get("dr_project_yaml", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_source_iceberg <- get(
    "dr_source_iceberg",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_target_iceberg <- get(
    "dr_target_iceberg",
    asNamespace("dataraft.adapters")
  )
}
if (requireNamespace("dataraft.metrics", quietly = TRUE)) {
  dr_report_verify <- get("dr_report_verify", asNamespace("dataraft.metrics"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_expire_snapshots <- get(
    "dr_expire_snapshots",
    asNamespace("dataraft.lake")
  )
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_test_adapter <- get("dr_test_adapter", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_review <- get("dr_review", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.adapters", quietly = TRUE)) {
  dr_catalog_pane <- get("dr_catalog_pane", asNamespace("dataraft.adapters"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_refresh_connection <- get(
    "dr_refresh_connection",
    asNamespace("dataraft.lake")
  )
}


if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_policy <- get("dr_contract_policy", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_contract_meta <- get("dr_contract_meta", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.core", quietly = TRUE)) {
  dr_model_product <- get("dr_model_product", asNamespace("dataraft.core"))
}
if (requireNamespace("dataraft.lake", quietly = TRUE)) {
  dr_verify_releases <- get("dr_verify_releases", asNamespace("dataraft.lake"))
}
if (requireNamespace("dataraft.dbt", quietly = TRUE)) {
  dr_dbt_contract_from_manifest <- get(
    "dr_dbt_contract_from_manifest",
    asNamespace("dataraft.dbt")
  )
}

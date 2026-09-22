#' DataRaft: modular checked data products
#'
#' Install the family together, or install a component with its declared dependencies.
#' @section Choose an execution path:
#' Use [dr_trial()] to check a delivery without configured writers, [dr_run()]
#' to execute the configured target, or [dr_publish()] to save output with a
#' local lake as the default target. [dr_ingest()] delivers data into a lake.
#' Save `result <- dr_trial(...)` and inspect [dr_quality_report()] before
#' calling [dr_collect()]. [dr_quality_errors()] exposes local rule exceptions.
#' @keywords internal
"_PACKAGE"

#' @rdname dr_add_catalog
#' @inherit dataraft.core::dr_add_catalog title description details return params sections examples
#' @seealso [dataraft.core::dr_add_catalog()]
#' @importFrom dataraft.core dr_add_catalog
#' @export
dataraft.core::dr_add_catalog

#' @rdname dr_add_contract
#' @inherit dataraft.core::dr_add_contract title description details return params sections examples
#' @seealso [dataraft.core::dr_add_contract()]
#' @importFrom dataraft.core dr_add_contract
#' @export
dataraft.core::dr_add_contract

#' @rdname dr_add_product
#' @inherit dataraft.core::dr_add_product title description details return params sections examples
#' @seealso [dataraft.core::dr_add_product()]
#' @importFrom dataraft.core dr_add_product
#' @export
dataraft.core::dr_add_product

#' @rdname dr_add_quality
#' @inherit dataraft.core::dr_add_quality title description details return params sections examples
#' @seealso [dataraft.core::dr_add_quality()]
#' @importFrom dataraft.core dr_add_quality
#' @export
dataraft.core::dr_add_quality

#' @rdname dr_add_recipe
#' @inherit dataraft.core::dr_add_recipe title description details return params sections examples
#' @seealso [dataraft.core::dr_add_recipe()]
#' @importFrom dataraft.core dr_add_recipe
#' @export
dataraft.core::dr_add_recipe

#' @rdname dr_add_source
#' @inherit dataraft.core::dr_add_source title description details return params sections examples
#' @seealso [dataraft.core::dr_add_source()]
#' @importFrom dataraft.core dr_add_source
#' @export
dataraft.core::dr_add_source

#' @rdname dr_as_targets
#' @inherit dataraft.adapters::dr_as_targets title description details return params sections examples
#' @seealso [dataraft.adapters::dr_as_targets()]
#' @importFrom dataraft.adapters dr_as_targets
#' @export
dataraft.adapters::dr_as_targets

#' @rdname dr_capabilities
#' @inherit dataraft.core::dr_capabilities title description details return params sections examples
#' @seealso [dataraft.core::dr_capabilities()]
#' @importFrom dataraft.core dr_capabilities
#' @export
dataraft.core::dr_capabilities

#' @rdname dr_catalog_app
#' @inherit dataraft.catalog::dr_catalog_app title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_app()]
#' @importFrom dataraft.catalog dr_catalog_app
#' @export
dataraft.catalog::dr_catalog_app

#' @rdname dr_catalog_export
#' @inherit dataraft.catalog::dr_catalog_export title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_export()]
#' @importFrom dataraft.catalog dr_catalog_export
#' @export
dataraft.catalog::dr_catalog_export

#' @rdname dr_catalog_openlineage
#' @inherit dataraft.catalog::dr_catalog_openlineage title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_openlineage()]
#' @importFrom dataraft.catalog dr_catalog_openlineage
#' @export
dataraft.catalog::dr_catalog_openlineage

#' @rdname dr_catalog_openmetadata
#' @inherit dataraft.catalog::dr_catalog_openmetadata title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_openmetadata()]
#' @importFrom dataraft.catalog dr_catalog_openmetadata
#' @export
dataraft.catalog::dr_catalog_openmetadata

#' @rdname dr_catalog_openmetadata_dbt
#' @inherit dataraft.catalog::dr_catalog_openmetadata_dbt title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_openmetadata_dbt()]
#' @importFrom dataraft.catalog dr_catalog_openmetadata_dbt
#' @export
dataraft.catalog::dr_catalog_openmetadata_dbt

#' @rdname dr_check_component
#' @inherit dataraft.core::dr_check_component title description details return params sections examples
#' @seealso [dataraft.core::dr_check_component()]
#' @importFrom dataraft.core dr_check_component
#' @export
dataraft.core::dr_check_component

#' @rdname dr_check_delivery
#' @inherit dataraft.lake::dr_check_delivery title description details return params sections examples
#' @seealso [dataraft.lake::dr_check_delivery()]
#' @importFrom dataraft.lake dr_check_delivery
#' @export
dataraft.lake::dr_check_delivery

#' @rdname dr_cleanup
#' @inherit dataraft.lake::dr_cleanup title description details return params sections examples
#' @seealso [dataraft.lake::dr_cleanup()]
#' @importFrom dataraft.lake dr_cleanup
#' @export
dataraft.lake::dr_cleanup

#' @rdname dr_close_lake
#' @inherit dataraft.lake::dr_close_lake title description details return params sections examples
#' @seealso [dataraft.lake::dr_close_lake()]
#' @importFrom dataraft.lake dr_close_lake
#' @export
dataraft.lake::dr_close_lake

#' @rdname dr_collect
#' @inherit dataraft.core::dr_collect title description details return params sections examples
#' @seealso [dataraft.core::dr_collect()]
#' @importFrom dataraft.core dr_collect
#' @export
dataraft.core::dr_collect

#' @rdname dr_commons_yaml
#' @inherit dataraft.metrics::dr_commons_yaml title description details return params sections examples
#' @seealso [dataraft.metrics::dr_commons_yaml()]
#' @importFrom dataraft.metrics dr_commons_yaml
#' @export
dataraft.metrics::dr_commons_yaml

#' @rdname dr_compare
#' @inherit dataraft.lake::dr_compare title description details return params sections examples
#' @seealso [dataraft.lake::dr_compare()]
#' @importFrom dataraft.lake dr_compare
#' @export
dataraft.lake::dr_compare

#' @rdname dr_component_capabilities
#' @inherit dataraft.core::dr_component_capabilities title description details return params sections examples
#' @seealso [dataraft.core::dr_component_capabilities()]
#' @importFrom dataraft.core dr_component_capabilities
#' @export
dataraft.core::dr_component_capabilities

#' @rdname dr_contract
#' @inherit dataraft.core::dr_contract title description details return params sections examples
#' @seealso [dataraft.core::dr_contract()]
#' @importFrom dataraft.core dr_contract
#' @export
dataraft.core::dr_contract

#' @rdname dr_contract_confirm
#' @inherit dataraft.core::dr_contract_confirm title description details return params sections examples
#' @seealso [dataraft.core::dr_contract_confirm()]
#' @importFrom dataraft.core dr_contract_confirm
#' @export
dataraft.core::dr_contract_confirm

#' @rdname dr_contract_diff
#' @inherit dataraft.core::dr_contract_diff title description details return params sections examples
#' @seealso [dataraft.core::dr_contract_diff()]
#' @importFrom dataraft.core dr_contract_diff
#' @export
dataraft.core::dr_contract_diff

#' @rdname dr_contract_from
#' @inherit dataraft.core::dr_contract_from title description details return params sections examples
#' @seealso [dataraft.core::dr_contract_from()]
#' @importFrom dataraft.core dr_contract_from
#' @export
dataraft.core::dr_contract_from

#' @rdname dr_contract_update
#' @inherit dataraft.core::dr_contract_update title description details return params sections examples
#' @seealso [dataraft.core::dr_contract_update()]
#' @importFrom dataraft.core dr_contract_update
#' @export
dataraft.core::dr_contract_update

#' @rdname dr_contract_yaml
#' @inherit dataraft.adapters::dr_contract_yaml title description details return params sections examples
#' @seealso [dataraft.adapters::dr_contract_yaml()]
#' @importFrom dataraft.adapters dr_contract_yaml
#' @export
dataraft.adapters::dr_contract_yaml

#' @rdname dr_dbt_build
#' @inherit dataraft.dbt::dr_dbt_build title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_build()]
#' @importFrom dataraft.dbt dr_dbt_build
#' @export
dataraft.dbt::dr_dbt_build

#' @rdname dr_dbt_contract
#' @inherit dataraft.dbt::dr_dbt_contract title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_contract()]
#' @importFrom dataraft.dbt dr_dbt_contract
#' @export
dataraft.dbt::dr_dbt_contract

#' @rdname dr_dbt_init
#' @inherit dataraft.dbt::dr_dbt_init title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_init()]
#' @importFrom dataraft.dbt dr_dbt_init
#' @export
dataraft.dbt::dr_dbt_init

#' @rdname dr_dbt_lineage
#' @inherit dataraft.dbt::dr_dbt_lineage title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_lineage()]
#' @importFrom dataraft.dbt dr_dbt_lineage
#' @export
dataraft.dbt::dr_dbt_lineage

#' @rdname dr_dbt_model
#' @inherit dataraft.dbt::dr_dbt_model title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_model()]
#' @importFrom dataraft.dbt dr_dbt_model
#' @export
dataraft.dbt::dr_dbt_model

#' @rdname dr_dbt_project
#' @inherit dataraft.dbt::dr_dbt_project title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_project()]
#' @importFrom dataraft.dbt dr_dbt_project
#' @export
dataraft.dbt::dr_dbt_project

#' @rdname dr_dbt_publish
#' @inherit dataraft.dbt::dr_dbt_publish title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_publish()]
#' @importFrom dataraft.dbt dr_dbt_publish
#' @export
dataraft.dbt::dr_dbt_publish

#' @rdname dr_dbt_sources
#' @inherit dataraft.dbt::dr_dbt_sources title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_sources()]
#' @importFrom dataraft.dbt dr_dbt_sources
#' @export
dataraft.dbt::dr_dbt_sources

#' @rdname dr_dbt_status
#' @inherit dataraft.dbt::dr_dbt_status title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_status()]
#' @importFrom dataraft.dbt dr_dbt_status
#' @export
dataraft.dbt::dr_dbt_status

#' @rdname dr_dbt_test
#' @inherit dataraft.dbt::dr_dbt_test title description details return params sections examples
#' @seealso [dataraft.dbt::dr_dbt_test()]
#' @importFrom dataraft.dbt dr_dbt_test
#' @export
dataraft.dbt::dr_dbt_test

#' @rdname dr_execute_transform
#' @inherit dataraft.core::dr_execute_transform title description details return params sections examples
#' @seealso [dataraft.core::dr_execute_transform()]
#' @importFrom dataraft.core dr_execute_transform
#' @export
dataraft.core::dr_execute_transform

#' @rdname dr_execution_config
#' @inherit dataraft.core::dr_execution_config title description details return params sections examples
#' @seealso [dataraft.core::dr_execution_config()]
#' @importFrom dataraft.core dr_execution_config
#' @export
dataraft.core::dr_execution_config

#' @rdname dr_expect_quality
#' @inherit dataraft.core::dr_expect_quality title description details return params sections examples
#' @seealso [dataraft.core::dr_expect_quality()]
#' @importFrom dataraft.core dr_expect_quality
#' @export
dataraft.core::dr_expect_quality

#' @rdname dr_extract_product
#' @inherit dataraft.core::dr_extract_product title description details return params sections examples
#' @seealso [dataraft.core::dr_extract_product()]
#' @importFrom dataraft.core dr_extract_product
#' @export
dataraft.core::dr_extract_product

#' @rdname dr_extract_recipe
#' @inherit dataraft.core::dr_extract_recipe title description details return params sections examples
#' @seealso [dataraft.core::dr_extract_recipe()]
#' @importFrom dataraft.core dr_extract_recipe
#' @export
dataraft.core::dr_extract_recipe

#' @rdname dr_freshness
#' @inherit dataraft.catalog::dr_freshness title description details return params sections examples
#' @seealso [dataraft.catalog::dr_freshness()]
#' @importFrom dataraft.catalog dr_freshness
#' @export
dataraft.catalog::dr_freshness

#' @rdname dr_incidents
#' @inherit dataraft.core::dr_incidents title description details return params sections examples
#' @seealso [dataraft.core::dr_incidents()]
#' @importFrom dataraft.core dr_incidents
#' @export
dataraft.core::dr_incidents

#' @rdname dr_ingest
#' @inherit dataraft.lake::dr_ingest title description details return params sections examples
#' @seealso [dataraft.lake::dr_ingest()]
#' @importFrom dataraft.lake dr_ingest
#' @export
dataraft.lake::dr_ingest

#' @rdname dr_init_project
#' @inherit dataraft.adapters::dr_init_project title description details return params sections examples
#' @seealso [dataraft.adapters::dr_init_project()]
#' @importFrom dataraft.adapters dr_init_project
#' @export
dataraft.adapters::dr_init_project

#' @rdname dr_inspect
#' @inherit dataraft.core::dr_inspect title description details return params sections examples
#' @seealso [dataraft.core::dr_inspect()]
#' @importFrom dataraft.core dr_inspect
#' @export
dataraft.core::dr_inspect

#' @rdname dr_interrupted
#' @inherit dataraft.lake::dr_interrupted title description details return params sections examples
#' @seealso [dataraft.lake::dr_interrupted()]
#' @importFrom dataraft.lake dr_interrupted
#' @export
dataraft.lake::dr_interrupted

#' @rdname dr_lake_config
#' @inherit dataraft.lake::dr_lake_config title description details return params sections examples
#' @seealso [dataraft.lake::dr_lake_config()]
#' @importFrom dataraft.lake dr_lake_config
#' @export
dataraft.lake::dr_lake_config

#' @rdname dr_lineage
#' @inherit dataraft.core::dr_lineage title description details return params sections examples
#' @seealso [dataraft.core::dr_lineage()]
#' @importFrom dataraft.core dr_lineage
#' @export
dataraft.core::dr_lineage

#' @rdname dr_lookup_spec
#' @inherit dataraft.core::dr_lookup_spec title description details return params sections examples
#' @seealso [dataraft.core::dr_lookup_spec()]
#' @importFrom dataraft.core dr_lookup_spec
#' @export
dataraft.core::dr_lookup_spec

#' @rdname dr_measure
#' @inherit dataraft.metrics::dr_measure title description details return params sections examples
#' @seealso [dataraft.metrics::dr_measure()]
#' @importFrom dataraft.metrics dr_measure
#' @export
dataraft.metrics::dr_measure

#' @rdname dr_metric
#' @inherit dataraft.metrics::dr_metric title description details return params sections examples
#' @seealso [dataraft.metrics::dr_metric()]
#' @importFrom dataraft.metrics dr_metric
#' @export
dataraft.metrics::dr_metric

#' @rdname dr_metric_set
#' @inherit dataraft.metrics::dr_metric_set title description details return params sections examples
#' @seealso [dataraft.metrics::dr_metric_set()]
#' @importFrom dataraft.metrics dr_metric_set
#' @export
dataraft.metrics::dr_metric_set

#' @rdname dr_model
#' @inherit dataraft.core::dr_model title description details return params sections examples
#' @seealso [dataraft.core::dr_model()]
#' @importFrom dataraft.core dr_model
#' @export
dataraft.core::dr_model

#' @rdname dr_open_lake
#' @inherit dataraft.lake::dr_open_lake title description details return params sections examples
#' @seealso [dataraft.lake::dr_open_lake()]
#' @importFrom dataraft.lake dr_open_lake
#' @export
dataraft.lake::dr_open_lake

#' @rdname dr_plan
#' @inherit dataraft.core::dr_plan title description details return params sections examples
#' @seealso [dataraft.core::dr_plan()]
#' @importFrom dataraft.core dr_plan
#' @export
dataraft.core::dr_plan

#' @rdname dr_pointblank_checks
#' @inherit dataraft.core::dr_pointblank_checks title description details return params sections examples
#' @seealso [dataraft.core::dr_pointblank_checks()]
#' @importFrom dataraft.core dr_pointblank_checks
#' @export
dataraft.core::dr_pointblank_checks

#' @rdname dr_pointblank_report
#' @inherit dataraft.core::dr_pointblank_report title description details return params sections examples
#' @seealso [dataraft.core::dr_pointblank_report()]
#' @importFrom dataraft.core dr_pointblank_report
#' @export
dataraft.core::dr_pointblank_report

#' @rdname dr_product
#' @inherit dataraft.core::dr_product title description details return params sections examples
#' @seealso [dataraft.core::dr_product()]
#' @importFrom dataraft.core dr_product
#' @export
dataraft.core::dr_product

#' @rdname dr_profile_data
#' @inherit dataraft.core::dr_profile_data title description details return params sections examples
#' @seealso [dataraft.core::dr_profile_data()]
#' @importFrom dataraft.core dr_profile_data
#' @export
dataraft.core::dr_profile_data

#' @rdname dr_publish
#' @inherit dataraft.core::dr_publish title description details return params sections examples
#' @seealso [dataraft.core::dr_publish()]
#' @importFrom dataraft.core dr_publish
#' @export
dataraft.core::dr_publish

#' @rdname dr_publish_metadata
#' @inherit dataraft.core::dr_publish_metadata title description details return params sections examples
#' @seealso [dataraft.core::dr_publish_metadata()]
#' @importFrom dataraft.core dr_publish_metadata
#' @export
dataraft.core::dr_publish_metadata

#' @rdname dr_quality
#' @inherit dataraft.core::dr_quality title description details return params sections examples
#' @seealso [dataraft.core::dr_quality()]
#' @importFrom dataraft.core dr_quality
#' @export
dataraft.core::dr_quality

#' @rdname dr_quality_counts
#' @inherit dataraft.core::dr_quality_counts title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_counts()]
#' @importFrom dataraft.core dr_quality_counts
#' @export
dataraft.core::dr_quality_counts

#' @rdname dr_quality_errors
#' @inherit dataraft.core::dr_quality_errors title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_errors()]
#' @importFrom dataraft.core dr_quality_errors
#' @export
dataraft.core::dr_quality_errors

#' @rdname dr_quality_reference
#' @inherit dataraft.core::dr_quality_reference title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_reference()]
#' @importFrom dataraft.core dr_quality_reference
#' @export
dataraft.core::dr_quality_reference

#' @rdname dr_quality_report
#' @inherit dataraft.core::dr_quality_report title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_report()]
#' @importFrom dataraft.core dr_quality_report
#' @export
dataraft.core::dr_quality_report

#' @rdname dr_quality_rows
#' @inherit dataraft.core::dr_quality_rows title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_rows()]
#' @importFrom dataraft.core dr_quality_rows
#' @export
dataraft.core::dr_quality_rows

#' @rdname dr_quality_rule
#' @inherit dataraft.core::dr_quality_rule title description details return params sections examples
#' @seealso [dataraft.core::dr_quality_rule()]
#' @importFrom dataraft.core dr_quality_rule
#' @export
dataraft.core::dr_quality_rule

#' @rdname dr_read_release
#' @inherit dataraft.lake::dr_read_release title description details return params sections examples
#' @seealso [dataraft.lake::dr_read_release()]
#' @importFrom dataraft.lake dr_read_release
#' @export
dataraft.lake::dr_read_release

#' @rdname dr_read_run
#' @inherit dataraft.core::dr_read_run title description details return params sections examples
#' @seealso [dataraft.core::dr_read_run()]
#' @importFrom dataraft.core dr_read_run
#' @export
dataraft.core::dr_read_run

#' @rdname dr_read_source
#' @inherit dataraft.core::dr_read_source title description details return params sections examples
#' @seealso [dataraft.core::dr_read_source()]
#' @importFrom dataraft.core dr_read_source
#' @export
dataraft.core::dr_read_source

#' @rdname dr_recipe
#' @inherit dataraft.core::dr_recipe title description details return params sections examples
#' @seealso [dataraft.core::dr_recipe()]
#' @importFrom dataraft.core dr_recipe
#' @export
dataraft.core::dr_recipe

#' @rdname dr_recover
#' @inherit dataraft.lake::dr_recover title description details return params sections examples
#' @seealso [dataraft.lake::dr_recover()]
#' @importFrom dataraft.lake dr_recover
#' @export
dataraft.lake::dr_recover

#' @rdname dr_register
#' @inherit dataraft.lake::dr_register title description details return params sections examples
#' @seealso [dataraft.lake::dr_register()]
#' @importFrom dataraft.lake dr_register
#' @export
dataraft.lake::dr_register

#' @rdname dr_registry
#' @inherit dataraft.lake::dr_registry title description details return params sections examples
#' @seealso [dataraft.lake::dr_registry()]
#' @importFrom dataraft.lake dr_registry
#' @export
dataraft.lake::dr_registry

#' @rdname dr_registry_duckdb
#' @inherit dataraft.lake::dr_registry_duckdb title description details return params sections examples
#' @seealso [dataraft.lake::dr_registry_duckdb()]
#' @importFrom dataraft.lake dr_registry_duckdb
#' @export
dataraft.lake::dr_registry_duckdb

#' @rdname dr_registry_postgres
#' @inherit dataraft.lake::dr_registry_postgres title description details return params sections examples
#' @seealso [dataraft.lake::dr_registry_postgres()]
#' @importFrom dataraft.lake dr_registry_postgres
#' @export
dataraft.lake::dr_registry_postgres

#' @rdname dr_releases
#' @inherit dataraft.lake::dr_releases title description details return params sections examples
#' @seealso [dataraft.lake::dr_releases()]
#' @importFrom dataraft.lake dr_releases
#' @export
dataraft.lake::dr_releases

#' @rdname dr_remove_product
#' @inherit dataraft.core::dr_remove_product title description details return params sections examples
#' @seealso [dataraft.core::dr_remove_product()]
#' @importFrom dataraft.core dr_remove_product
#' @export
dataraft.core::dr_remove_product

#' @rdname dr_remove_recipe
#' @inherit dataraft.core::dr_remove_recipe title description details return params sections examples
#' @seealso [dataraft.core::dr_remove_recipe()]
#' @importFrom dataraft.core dr_remove_recipe
#' @export
dataraft.core::dr_remove_recipe

#' @rdname dr_replace_sources
#' @inherit dataraft.core::dr_replace_sources title description details return params sections examples
#' @seealso [dataraft.core::dr_replace_sources()]
#' @importFrom dataraft.core dr_replace_sources
#' @export
dataraft.core::dr_replace_sources

#' @rdname dr_report_read
#' @inherit dataraft.metrics::dr_report_read title description details return params sections examples
#' @seealso [dataraft.metrics::dr_report_read()]
#' @importFrom dataraft.metrics dr_report_read
#' @export
dataraft.metrics::dr_report_read

#' @rdname dr_report_release
#' @inherit dataraft.metrics::dr_report_release title description details return params sections examples
#' @seealso [dataraft.metrics::dr_report_release()]
#' @importFrom dataraft.metrics dr_report_release
#' @export
dataraft.metrics::dr_report_release

#' @rdname dr_retry_catalogs
#' @inherit dataraft.core::dr_retry_catalogs title description details return params sections examples
#' @seealso [dataraft.core::dr_retry_catalogs()]
#' @importFrom dataraft.core dr_retry_catalogs
#' @export
dataraft.core::dr_retry_catalogs

#' @rdname dr_run
#' @inherit dataraft.core::dr_run title description details return params sections examples
#' @seealso [dataraft.core::dr_run()]
#' @importFrom dataraft.core dr_run
#' @export
dataraft.core::dr_run

#' @rdname dr_run_history
#' @inherit dataraft.core::dr_run_history title description details return params sections examples
#' @seealso [dataraft.core::dr_run_history()]
#' @importFrom dataraft.core dr_run_history
#' @export
dataraft.core::dr_run_history

#' @rdname dr_run_quality
#' @inherit dataraft.core::dr_run_quality title description details return params sections examples
#' @seealso [dataraft.core::dr_run_quality()]
#' @importFrom dataraft.core dr_run_quality
#' @export
dataraft.core::dr_run_quality

#' @rdname dr_set_engine
#' @inherit dataraft.core::dr_set_engine title description details return params sections examples
#' @seealso [dataraft.core::dr_set_engine()]
#' @importFrom dataraft.core dr_set_engine
#' @export
dataraft.core::dr_set_engine

#' @rdname dr_set_target
#' @inherit dataraft.core::dr_set_target title description details return params sections examples
#' @seealso [dataraft.core::dr_set_target()]
#' @importFrom dataraft.core dr_set_target
#' @export
dataraft.core::dr_set_target

#' @rdname dr_source_api
#' @inherit dataraft.adapters::dr_source_api title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_api()]
#' @importFrom dataraft.adapters dr_source_api
#' @export
dataraft.adapters::dr_source_api

#' @rdname dr_source_database
#' @inherit dataraft.adapters::dr_source_database title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_database()]
#' @importFrom dataraft.adapters dr_source_database
#' @export
dataraft.adapters::dr_source_database

#' @rdname dr_source_file
#' @inherit dataraft.core::dr_source_file title description details return params sections examples
#' @seealso [dataraft.core::dr_source_file()]
#' @importFrom dataraft.core dr_source_file
#' @export
dataraft.core::dr_source_file

#' @rdname dr_source_parquet
#' @inherit dataraft.adapters::dr_source_parquet title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_parquet()]
#' @importFrom dataraft.adapters dr_source_parquet
#' @export
dataraft.adapters::dr_source_parquet

#' @rdname dr_source_pins
#' @inherit dataraft.adapters::dr_source_pins title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_pins()]
#' @importFrom dataraft.adapters dr_source_pins
#' @export
dataraft.adapters::dr_source_pins

#' @rdname dr_source_release
#' @inherit dataraft.lake::dr_source_release title description details return params sections examples
#' @seealso [dataraft.lake::dr_source_release()]
#' @importFrom dataraft.lake dr_source_release
#' @export
dataraft.lake::dr_source_release

#' @rdname dr_sql_transform
#' @inherit dataraft.adapters::dr_sql_transform title description details return params sections examples
#' @seealso [dataraft.adapters::dr_sql_transform()]
#' @importFrom dataraft.adapters dr_sql_transform
#' @export
dataraft.adapters::dr_sql_transform

#' @rdname dr_status
#' @inherit dataraft.core::dr_status title description details return params sections examples
#' @seealso [dataraft.core::dr_status()]
#' @importFrom dataraft.core dr_status
#' @export
dataraft.core::dr_status

#' @rdname dr_step_arrange
#' @inherit dataraft.core::dr_step_arrange title description details return params sections examples
#' @seealso [dataraft.core::dr_step_arrange()]
#' @importFrom dataraft.core dr_step_arrange
#' @export
dataraft.core::dr_step_arrange

#' @rdname dr_step_distinct
#' @param .keep_all Arguments with their dplyr meanings.
#' @inherit dataraft.core::dr_step_distinct title description details return params sections examples
#' @seealso [dataraft.core::dr_step_distinct()]
#' @importFrom dataraft.core dr_step_distinct
#' @export
dataraft.core::dr_step_distinct

#' @rdname dr_step_filter
#' @param .by,.preserve Arguments with their dplyr meanings.
#' @inherit dataraft.core::dr_step_filter title description details return params sections examples
#' @seealso [dataraft.core::dr_step_filter()]
#' @importFrom dataraft.core dr_step_filter
#' @export
dataraft.core::dr_step_filter

#' @rdname dr_step_lookup
#' @inherit dataraft.core::dr_step_lookup title description details return params sections examples
#' @seealso [dataraft.core::dr_step_lookup()]
#' @importFrom dataraft.core dr_step_lookup
#' @export
dataraft.core::dr_step_lookup

#' @rdname dr_step_mutate
#' @inherit dataraft.core::dr_step_mutate title description details return params sections examples
#' @seealso [dataraft.core::dr_step_mutate()]
#' @importFrom dataraft.core dr_step_mutate
#' @export
dataraft.core::dr_step_mutate

#' @rdname dr_step_rename
#' @inherit dataraft.core::dr_step_rename title description details return params sections examples
#' @seealso [dataraft.core::dr_step_rename()]
#' @importFrom dataraft.core dr_step_rename
#' @export
dataraft.core::dr_step_rename

#' @rdname dr_step_select
#' @inherit dataraft.core::dr_step_select title description details return params sections examples
#' @seealso [dataraft.core::dr_step_select()]
#' @importFrom dataraft.core dr_step_select
#' @export
dataraft.core::dr_step_select

#' @rdname dr_step_summarise
#' @param .by,.groups Arguments with their dplyr meanings.
#' @inherit dataraft.core::dr_step_summarise title description details return params sections examples
#' @seealso [dataraft.core::dr_step_summarise()]
#' @importFrom dataraft.core dr_step_summarise
#' @export
dataraft.core::dr_step_summarise

#' @rdname dr_step_transform
#' @inherit dataraft.core::dr_step_transform title description details return params sections examples
#' @seealso [dataraft.core::dr_step_transform()]
#' @importFrom dataraft.core dr_step_transform
#' @export
dataraft.core::dr_step_transform

#' @rdname dr_storage_local
#' @inherit dataraft.lake::dr_storage_local title description details return params sections examples
#' @seealso [dataraft.lake::dr_storage_local()]
#' @importFrom dataraft.lake dr_storage_local
#' @export
dataraft.lake::dr_storage_local

#' @rdname dr_storage_s3
#' @inherit dataraft.lake::dr_storage_s3 title description details return params sections examples
#' @seealso [dataraft.lake::dr_storage_s3()]
#' @importFrom dataraft.lake dr_storage_s3
#' @export
dataraft.lake::dr_storage_s3

#' @rdname dr_target_database
#' @inherit dataraft.adapters::dr_target_database title description details return params sections examples
#' @seealso [dataraft.adapters::dr_target_database()]
#' @importFrom dataraft.adapters dr_target_database
#' @export
dataraft.adapters::dr_target_database

#' @rdname dr_target_lake
#' @inherit dataraft.lake::dr_target_lake title description details return params sections examples
#' @seealso [dataraft.lake::dr_target_lake()]
#' @importFrom dataraft.lake dr_target_lake
#' @export
dataraft.lake::dr_target_lake

#' @rdname dr_target_parquet
#' @inherit dataraft.adapters::dr_target_parquet title description details return params sections examples
#' @seealso [dataraft.adapters::dr_target_parquet()]
#' @importFrom dataraft.adapters dr_target_parquet
#' @export
dataraft.adapters::dr_target_parquet

#' @rdname dr_target_pins
#' @inherit dataraft.adapters::dr_target_pins title description details return params sections examples
#' @seealso [dataraft.adapters::dr_target_pins()]
#' @importFrom dataraft.adapters dr_target_pins
#' @export
dataraft.adapters::dr_target_pins

#' @rdname dr_tbl
#' @inherit dataraft.lake::dr_tbl title description details return params sections examples
#' @seealso [dataraft.lake::dr_tbl()]
#' @importFrom dataraft.lake dr_tbl
#' @export
dataraft.lake::dr_tbl

#' @rdname dr_transform_dbt
#' @inherit dataraft.dbt::dr_transform_dbt title description details return params sections examples
#' @seealso [dataraft.dbt::dr_transform_dbt()]
#' @importFrom dataraft.dbt dr_transform_dbt
#' @export
dataraft.dbt::dr_transform_dbt

#' @rdname dr_trial
#' @inherit dataraft.core::dr_trial title description details return params sections examples
#' @seealso [dataraft.core::dr_trial()]
#' @importFrom dataraft.core dr_trial
#' @export
dataraft.core::dr_trial

#' @rdname dr_update_product
#' @inherit dataraft.core::dr_update_product title description details return params sections examples
#' @seealso [dataraft.core::dr_update_product()]
#' @importFrom dataraft.core dr_update_product
#' @export
dataraft.core::dr_update_product

#' @rdname dr_update_recipe
#' @inherit dataraft.core::dr_update_recipe title description details return params sections examples
#' @seealso [dataraft.core::dr_update_recipe()]
#' @importFrom dataraft.core dr_update_recipe
#' @export
dataraft.core::dr_update_recipe

#' @rdname dr_validate
#' @inherit dataraft.core::dr_validate title description details return params sections examples
#' @seealso [dataraft.core::dr_validate()]
#' @importFrom dataraft.core dr_validate
#' @export
dataraft.core::dr_validate

#' @rdname dr_workflow
#' @inherit dataraft.core::dr_workflow title description details return params sections examples
#' @seealso [dataraft.core::dr_workflow()]
#' @importFrom dataraft.core dr_workflow
#' @export
dataraft.core::dr_workflow

#' @rdname dr_write_data
#' @inherit dataraft.lake::dr_write_data title description details return params sections examples
#' @seealso [dataraft.lake::dr_write_data()]
#' @importFrom dataraft.lake dr_write_data
#' @export
dataraft.lake::dr_write_data

#' @rdname dr_write_target
#' @inherit dataraft.core::dr_write_target title description details return params sections examples
#' @seealso [dataraft.core::dr_write_target()]
#' @importFrom dataraft.core dr_write_target
#' @export
dataraft.core::dr_write_target

#' @rdname dr_last_failure
#' @inherit dataraft.core::dr_last_failure title description details return params sections examples
#' @seealso [dataraft.core::dr_last_failure()]
#' @importFrom dataraft.core dr_last_failure
#' @export
dataraft.core::dr_last_failure

#' @rdname dr_target_rds
#' @inherit dataraft.adapters::dr_target_rds title description details return params sections examples
#' @seealso [dataraft.adapters::dr_target_rds()]
#' @importFrom dataraft.adapters dr_target_rds
#' @export
dataraft.adapters::dr_target_rds

#' @rdname dr_source_rds
#' @inherit dataraft.adapters::dr_source_rds title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_rds()]
#' @importFrom dataraft.adapters dr_source_rds
#' @export
dataraft.adapters::dr_source_rds

#' @rdname dr_quarantine_rows
#' @inherit dataraft.core::dr_quarantine_rows title description details return params sections examples
#' @seealso [dataraft.core::dr_quarantine_rows()]
#' @importFrom dataraft.core dr_quarantine_rows
#' @export
dataraft.core::dr_quarantine_rows

#' @rdname dr_profile_snapshot
#' @inherit dataraft.core::dr_profile_snapshot title description details return params sections examples
#' @seealso [dataraft.core::dr_profile_snapshot()]
#' @importFrom dataraft.core dr_profile_snapshot
#' @export
dataraft.core::dr_profile_snapshot

#' @rdname dr_profile_compare
#' @inherit dataraft.core::dr_profile_compare title description details return params sections examples
#' @seealso [dataraft.core::dr_profile_compare()]
#' @importFrom dataraft.core dr_profile_compare
#' @export
dataraft.core::dr_profile_compare

#' @rdname dr_column_lineage
#' @inherit dataraft.core::dr_column_lineage title description details return params sections examples
#' @seealso [dataraft.core::dr_column_lineage()]
#' @importFrom dataraft.core dr_column_lineage
#' @export
dataraft.core::dr_column_lineage

#' @rdname dr_contract_odcs
#' @inherit dataraft.adapters::dr_contract_odcs title description details return params sections examples
#' @seealso [dataraft.adapters::dr_contract_odcs()]
#' @importFrom dataraft.adapters dr_contract_odcs
#' @export
dataraft.adapters::dr_contract_odcs

#' @rdname dr_contract_from_odcs
#' @inherit dataraft.adapters::dr_contract_from_odcs title description details return params sections examples
#' @seealso [dataraft.adapters::dr_contract_from_odcs()]
#' @importFrom dataraft.adapters dr_contract_from_odcs
#' @export
dataraft.adapters::dr_contract_from_odcs

#' @rdname dr_project_yaml
#' @inherit dataraft.adapters::dr_project_yaml title description details return params sections examples
#' @seealso [dataraft.adapters::dr_project_yaml()]
#' @importFrom dataraft.adapters dr_project_yaml
#' @export
dataraft.adapters::dr_project_yaml

#' @rdname dr_source_iceberg
#' @inherit dataraft.adapters::dr_source_iceberg title description details return params sections examples
#' @seealso [dataraft.adapters::dr_source_iceberg()]
#' @importFrom dataraft.adapters dr_source_iceberg
#' @export
dataraft.adapters::dr_source_iceberg

#' @rdname dr_target_iceberg
#' @inherit dataraft.adapters::dr_target_iceberg title description details return params sections examples
#' @seealso [dataraft.adapters::dr_target_iceberg()]
#' @importFrom dataraft.adapters dr_target_iceberg
#' @export
dataraft.adapters::dr_target_iceberg

#' @rdname dr_report_verify
#' @inherit dataraft.metrics::dr_report_verify title description details return params sections examples
#' @seealso [dataraft.metrics::dr_report_verify()]
#' @importFrom dataraft.metrics dr_report_verify
#' @export
dataraft.metrics::dr_report_verify

#' @rdname dr_expire_snapshots
#' @inherit dataraft.lake::dr_expire_snapshots title description details return params sections examples
#' @seealso [dataraft.lake::dr_expire_snapshots()]
#' @importFrom dataraft.lake dr_expire_snapshots
#' @export
dataraft.lake::dr_expire_snapshots

#' @rdname dr_test_adapter
#' @inherit dataraft.adapters::dr_test_adapter title description details return params sections examples
#' @seealso [dataraft.adapters::dr_test_adapter()]
#' @importFrom dataraft.adapters dr_test_adapter
#' @export
dataraft.adapters::dr_test_adapter

#' @rdname dr_review
#' @inherit dataraft.core::dr_review title description details return params sections examples
#' @seealso [dataraft.core::dr_review()]
#' @importFrom dataraft.core dr_review
#' @export
dataraft.core::dr_review

#' @rdname dr_catalog_pane
#' @inherit dataraft.catalog::dr_catalog_pane title description details return params sections examples
#' @seealso [dataraft.catalog::dr_catalog_pane()]
#' @importFrom dataraft.catalog dr_catalog_pane
#' @export
dataraft.catalog::dr_catalog_pane

#' @rdname dr_refresh_connection
#' @inherit dataraft.lake::dr_refresh_connection title description details return params sections examples
#' @seealso [dataraft.lake::dr_refresh_connection()]
#' @importFrom dataraft.lake dr_refresh_connection
#' @export
dataraft.lake::dr_refresh_connection

#' @rdname dr_extract_contract
#' @inherit dataraft.core::dr_extract_contract title description details return params sections examples
#' @seealso [dataraft.core::dr_extract_contract()]
#' @importFrom dataraft.core dr_extract_contract
#' @export
dataraft.core::dr_extract_contract

#' @rdname dr_remove_contract
#' @inherit dataraft.core::dr_remove_contract title description details return params sections examples
#' @seealso [dataraft.core::dr_remove_contract()]
#' @importFrom dataraft.core dr_remove_contract
#' @export
dataraft.core::dr_remove_contract

#' @rdname dr_update_contract
#' @inherit dataraft.core::dr_update_contract title description details return params sections examples
#' @seealso [dataraft.core::dr_update_contract()]
#' @importFrom dataraft.core dr_update_contract
#' @export
dataraft.core::dr_update_contract

#' @rdname dr_extract_source
#' @inherit dataraft.core::dr_extract_source title description details return params sections examples
#' @seealso [dataraft.core::dr_extract_source()]
#' @importFrom dataraft.core dr_extract_source
#' @export
dataraft.core::dr_extract_source

#' @rdname dr_remove_source
#' @inherit dataraft.core::dr_remove_source title description details return params sections examples
#' @seealso [dataraft.core::dr_remove_source()]
#' @importFrom dataraft.core dr_remove_source
#' @export
dataraft.core::dr_remove_source

#' @rdname dr_update_source
#' @inherit dataraft.core::dr_update_source title description details return params sections examples
#' @seealso [dataraft.core::dr_update_source()]
#' @importFrom dataraft.core dr_update_source
#' @export
dataraft.core::dr_update_source

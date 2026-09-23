#' DataRaft: checked data products
#'
#' Define a product, inspect a run with `write = FALSE`, then publish it.
#' The meta-package exposes 18 entry points, including [dr_demo()].
#' Use the owning component namespace for advanced operations.
#' @importFrom dataraft.adapters dr_init_project
#' @importFrom dataraft.metrics dr_metric
#' @keywords internal
"_PACKAGE"

#' @rdname dr_product
#' @inherit dataraft.core::dr_product title description params return
#' @seealso [dataraft.core::dr_product()]
#' @importFrom dataraft.core dr_product
#' @export
dataraft.core::dr_product

#' @rdname dr_contract
#' @inherit dataraft.core::dr_contract title description params return
#' @seealso [dataraft.core::dr_contract()]
#' @importFrom dataraft.core dr_contract
#' @export
dataraft.core::dr_contract

#' @rdname dr_add_contract
#' @inherit dataraft.core::dr_add_contract title description params return
#' @seealso [dataraft.core::dr_add_contract()]
#' @importFrom dataraft.core dr_add_contract
#' @export
dataraft.core::dr_add_contract

#' @rdname dr_set_sources
#' @inherit dataraft.core::dr_set_sources title description params return
#' @seealso [dataraft.core::dr_set_sources()]
#' @importFrom dataraft.core dr_set_sources
#' @export
dataraft.core::dr_set_sources

#' @rdname dr_set_target
#' @inherit dataraft.core::dr_set_target title description params return
#' @seealso [dataraft.core::dr_set_target()]
#' @importFrom dataraft.core dr_set_target
#' @export
dataraft.core::dr_set_target

#' @rdname dr_add_quality
#' @inherit dataraft.core::dr_add_quality title description params return
#' @seealso [dataraft.core::dr_add_quality()]
#' @importFrom dataraft.core dr_add_quality
#' @export
dataraft.core::dr_add_quality

#' @rdname dr_quality
#' @inherit dataraft.core::dr_quality title description params return
#' @seealso [dataraft.core::dr_quality()]
#' @importFrom dataraft.core dr_quality
#' @export
dataraft.core::dr_quality

#' @rdname dr_run
#' @inherit dataraft.core::dr_run title description params return
#' @seealso [dataraft.core::dr_run()]
#' @importFrom dataraft.core dr_run
#' @export
dataraft.core::dr_run

#' @rdname dr_publish
#' @inherit dataraft.core::dr_publish title description params return
#' @seealso [dataraft.core::dr_publish()]
#' @importFrom dataraft.core dr_publish
#' @export
dataraft.core::dr_publish

#' @rdname dr_collect
#' @inherit dataraft.core::dr_collect title description params return
#' @seealso [dataraft.core::dr_collect()]
#' @importFrom dataraft.core dr_collect
#' @export
dataraft.core::dr_collect

#' @rdname dr_model
#' @inherit dataraft.core::dr_model title description params return
#' @seealso [dataraft.core::dr_model()]
#' @importFrom dataraft.core dr_model
#' @export
dataraft.core::dr_model

#' @rdname dr_tbl
#' @inherit dataraft.lake::dr_tbl title description params return
#' @seealso [dataraft.lake::dr_tbl()]
#' @importFrom dataraft.lake dr_tbl
#' @export
dataraft.lake::dr_tbl

#' @rdname dr_releases
#' @inherit dataraft.lake::dr_releases title description params return
#' @seealso [dataraft.lake::dr_releases()]
#' @importFrom dataraft.lake dr_releases
#' @export
dataraft.lake::dr_releases

#' @rdname dr_lineage
#' @inherit dataraft.core::dr_lineage title description params return
#' @seealso [dataraft.core::dr_lineage()]
#' @importFrom dataraft.core dr_lineage
#' @export
dataraft.core::dr_lineage

#' @rdname dr_inspect
#' @inherit dataraft.core::dr_inspect title description params return
#' @seealso [dataraft.core::dr_inspect()]
#' @importFrom dataraft.core dr_inspect
#' @export
dataraft.core::dr_inspect

#' @rdname dr_last_failure
#' @inherit dataraft.core::dr_last_failure title description params return
#' @seealso [dataraft.core::dr_last_failure()]
#' @importFrom dataraft.core dr_last_failure
#' @export
dataraft.core::dr_last_failure

#' @rdname dr_quality_report
#' @inherit dataraft.core::dr_quality_report title description params return
#' @seealso [dataraft.core::dr_quality_report()]
#' @importFrom dataraft.core dr_quality_report
#' @export
dataraft.core::dr_quality_report

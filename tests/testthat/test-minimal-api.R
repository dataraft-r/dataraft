test_that("the meta-package has an enforced small entry surface", {
  expected <- c(
    "dr_product",
    "dr_contract",
    "dr_add_contract",
    "dr_set_sources",
    "dr_set_target",
    "dr_add_quality",
    "dr_quality",
    "dr_run",
    "dr_publish",
    "dr_collect",
    "dr_model",
    "dr_tbl",
    "dr_releases",
    "dr_lineage",
    "dr_inspect",
    "dr_last_failure",
    "dr_quality_report",
    "dr_demo"
  )
  expect_setequal(getNamespaceExports("dataraft"), expected)
})

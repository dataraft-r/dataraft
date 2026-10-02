book_root <- getOption("dataraft.book_root")
stopifnot(is.character(book_root), length(book_root) == 1L)
source(file.path(book_root, "examples", "insurance-platform", "R", "products.R"))

testthat::test_that("the complete local platform produces a checked result", {
  products <- insurance_products(book_root)
  result <- dataraft::dr_run(
    products$monthly_performance,
    write = FALSE,
    stop_on_failure = FALSE
  )
  testthat::expect_identical(result$status, "completed")
  output <- dataraft::dr_collect(result)
  testthat::expect_named(
    output,
    c(
      "policy_id", "broker_id", "premium", "status", "region",
      "paid", "outstanding"
    )
  )
  testthat::expect_equal(nrow(output), 4L)

  lineage <- dataraft::dr_lineage(result)
  testthat::expect_gt(nrow(lineage), 0L)
  testthat::expect_true(all(lineage$to_id == "monthly_performance"))
})

testthat::test_that("a bad policy delivery is blocked before reuse", {
  products <- insurance_products(book_root)
  bad <- data.frame(
    policy_id = 1L,
    broker_id = 10L,
    premium = -1,
    status = "active"
  )
  result <- dataraft::dr_run(
    products$policies,
    data = bad,
    write = FALSE,
    stop_on_failure = FALSE
  )
  testthat::expect_identical(result$status, "blocked")
  rows <- dataraft.core::dr_quality_rows(result, rule = "premium_non_negative")
  testthat::expect_equal(rows$premium, -1)
})

testthat::test_that("publication records release, policy and SLA evidence", {
  products <- insurance_products(book_root)
  path <- withr::local_tempdir()
  publishable <- insurance_release_product(products, path)

  policy_decisions <- dataraft.core::dr_check_policies(
    publishable,
    event = "publish"
  )
  testthat::expect_identical(policy_decisions$decision, "pass")

  published <- dataraft::dr_publish(
    publishable,
    business_date = "2026-10-02"
  )

  testthat::expect_identical(published$status, "published")
  testthat::expect_identical(
    published$port_outputs$reporting_extract$status,
    "published"
  )
  testthat::expect_identical(
    published$metadata$policies$decision,
    "pass"
  )
  testthat::expect_true(
    published$metadata$sla$reporting_extract$status[[1]] %in%
      c("met", "late")
  )

  version <- published$outputs$version
  reread <- dataraft.core::dr_read_source(
    dataraft.adapters::dr_source_rds(path, version)
  )
  testthat::expect_equal(nrow(reread), 4L)
})

testthat::test_that("the complete project exposes explicit product lineage", {
  products <- insurance_products(book_root)
  result <- dataraft::dr_run(
    products$monthly_performance,
    write = FALSE
  )

  lineage <- dataraft::dr_lineage(result)
  testthat::expect_true(
    all(c("from_id", "to_id", "relation") %in% names(lineage))
  )
  testthat::expect_true("monthly_performance" %in% lineage$to_id)
})

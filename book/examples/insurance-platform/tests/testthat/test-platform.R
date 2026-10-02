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

testthat::test_that("RDS publication creates a versioned readable release", {
  products <- insurance_products(book_root)
  path <- withr::local_tempdir()
  published <- products$monthly_performance |>
    dataraft::dr_set_target(dataraft.adapters::dr_target_rds(path)) |>
    dataraft::dr_publish()
  testthat::expect_identical(published$status, "published")
  version <- published$outputs$version
  reread <- dataraft.core::dr_read_source(
    dataraft.adapters::dr_source_rds(path, version)
  )
  testthat::expect_equal(nrow(reread), 4L)
})

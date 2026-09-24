portfolio_example <- function() {
  example <- new.env(parent = baseenv())
  sys.source(system.file("examples", "portfolio-case.R", package = "dataraft",
                         mustWork = TRUE), envir = example)
  example$portfolio_case(withr::local_tempdir())
}

test_that("the synthetic portfolio has coherent six-table business grains", {
  case <- portfolio_example()
  expect_setequal(names(case$inputs),
    c("customers", "brokers", "policies", "monthly_status", "premiums", "claims"))
  expect_equal(nrow(case$inputs$monthly_status), 108L)
  expect_equal(nrow(case$inputs$policies), 36L)
  expect_equal(anyDuplicated(case$inputs$monthly_status[c("policy_id", "month")]), 0L)
  expect_setequal(case$inputs$policies$customer_id, case$inputs$customers$customer_id)
  expect_true(all(case$inputs$claims$policy_id %in% case$inputs$policies$policy_id))
  expect_equal(sum(case$inputs$monthly_status$new_lapse[
    case$inputs$monthly_status$month == as.Date("2026-03-01")]), 4L)
})

test_that("one invalid cash receipt blocks a checked delivery", {
  case <- portfolio_example()
  result <- dr_run(case$products$invalid_premiums,
                   write = FALSE, stop_on_failure = FALSE)
  expect_identical(result$status, "blocked")
  rule <- dr_quality(result)
  rule <- rule[rule$rule == "nonnegative_cash", ]
  expect_equal(rule$n_failed, 1L)
  expect_equal(rule$n_total, 108L)
  expect_equal(dataraft.core::dr_quality_rows(result, "nonnegative_cash")$cash_amount,
               -125)
  corrected <- dr_run(case$products$premiums, write = FALSE)
  expect_identical(corrected$status, "completed")
  expect_equal(nrow(dr_collect(corrected)), 108L)
})

test_that("relational portfolio checks keys and foreign keys together", {
  skip_if_not_installed("dm")
  case <- portfolio_example()
  expect_s3_class(case$model, "dm")
  valid <- dr_run(case$products$model, write = FALSE, stop_on_failure = FALSE)
  expect_identical(valid$status, "completed")
  expect_s3_class(dr_collect(valid), "dm")
  missing <- case$inputs$customers[-1L, ]
  broken <- dr_run(case$products$model, sources = list(customers = missing),
                   write = FALSE, stop_on_failure = FALSE)
  expect_identical(broken$status, "blocked")
})

test_that("channel lapse rate uses the prior exposed population", {
  case <- portfolio_example()
  expect_s3_class(dataraft.core::dr_validate(case$products$lapse_rate), "dr_product")
  result <- dr_run(case$products$lapse_rate, write = FALSE)
  expect_identical(result$status, "completed")
  data <- dr_collect(result)
  march <- data[data$month == as.Date("2026-03-01"), ]
  expect_equal(sum(march$exposed), 33L)
  expect_equal(sum(march$lapses), 4L)
  expect_equal(sum(march$lapses) / sum(march$exposed), 4 / 33)
  expect_setequal(unique(data$channel), c("Partner", "Broker", "Direct"))
  expect_equal(nrow(data), 9L)
  expect_equal(length(case$products$lapse_rate$output_ports), 1L)
  expect_equal(names(case$products$lapse_rate$policies), "named_owner")
})

test_that("reviewing a blocked delivery never writes its RDS target", {
  target <- withr::local_tempfile()
  product <- dr_product("policies", data.frame(premium = c(-2, 10))) |>
    dr_add_contract(c(premium = "numeric")) |>
    dr_add_quality(list(nonnegative = ~ premium >= 0)) |>
    dr_set_target(dr_target_rds(target))
  result <- dr_trial(product, stop_on_failure = FALSE)
  viewed <- NULL
  testthat::local_mocked_bindings(
    View = function(x, title, ...) viewed <<- x,
    .package = "utils"
  )
  reviewed <- dr_review(result, rule = "nonnegative", limit = 1)
  expect_equal(reviewed$premium, -2)
  expect_identical(reviewed, viewed)
  expect_identical(dir.exists(target), FALSE)
  expect_identical(result$status, "blocked")
})

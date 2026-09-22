test_that("demo blocks bad insurance input and collects corrected data", {
  demo <- dr_demo(quiet = TRUE)
  expect_identical(demo$blocked$status, "blocked")
  expect_equal(dr_collect(demo$passed)$premium, c(120, 80, 100))
  expect_gt(nrow(dr_quality_rows(demo$blocked)), 0L)
  expect_message(dr_demo(), "Negative premium: blocked; corrected delivery:")
})

test_that("a lake primary release and a second adapter share a checked delivery", {
  skip_if_not_installed("dataraft.adapters")
  f <- fixture()
  withr::defer(fixture_cleanup(f))
  second <- withr::local_tempfile()
  contract <- dataraft.core::dr_contract("ports.integration",
    columns = c(id = "integer"), key = "id")
  product <- dataraft.core::dr_product("ports.integration",
    data.frame(id = 1:2), contract = contract) |>
    dataraft.core::dr_add_output(dataraft.core::dr_output("lake",
      dataraft.lake::dr_target_lake(f$lake))) |>
    dataraft.core::dr_add_output(dataraft.core::dr_output("rds",
      dataraft.adapters::dr_target_rds(second)))
  result <- dataraft.core::dr_run(product)
  expect_equal(result$status, "published")
  expect_equal(result$port_outputs$lake$output$release_id, result$release_id)
  expect_equal(result$port_outputs$rds$status, "published")
  expect_equal(dataraft.core::dr_collect(result)$id, 1:2)
  expect_true(dir.exists(second))
})

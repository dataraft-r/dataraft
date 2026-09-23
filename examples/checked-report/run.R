library(dataraft.core)
library(dataraft.adapters)
root <- Sys.getenv("DATARAFT_EXAMPLE_OUTPUT", tempfile("dataraft-example-"))
product <- dr_product("orders", data.frame(id = 1:3, amount = c(25, 75, 50))) |>
  dr_add_contract(dr_contract(
    columns = c(id = "integer", amount = "numeric"),
    key = "id"
  )) |>
  dr_add_quality(~ amount >= 0) |>
  dr_set_target(dr_target_rds(file.path(root, "orders")))
result <- dr_run(product)
stopifnot(result$status == "published", sum(dr_collect(result)$amount) == 150)
profile <- dr_profile_snapshot(dr_collect(result), result$outputs$version)
dr_contract_odcs(product$contract, file.path(root, "orders.odcs.json"))
dr_quality_report(result, file.path(root, "quality.html"))
print(result$outputs$version)

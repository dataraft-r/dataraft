stopifnot(!requireNamespace("duckdb", quietly = TRUE))
library(dataraft.core)
family_extensions <- paste0(
  "dataraft.",
  c("lake", "adapters", "dbt", "metrics", "ide")
)
stopifnot(!any(family_extensions %in% loadedNamespaces()))
flow <- dr_product("orders") |>
  dr_add_contract(c(id = "integer", amount = "numeric")) |>
  dr_add_quality(~ amount >= 0) |>
  dataraft.core::dr_add_recipe(
    dataraft.core::dr_recipe() |>
      dataraft.core::dr_step_mutate(amount = round(amount, 2))
  )
bad <- dr_run(
  write = FALSE,
  stop_on_failure = FALSE,
  flow,
  data = data.frame(id = 1:3, amount = c(25, -75, 50))
)
stopifnot(
  identical(bad$status, "blocked"),
  nrow(dataraft.core::dr_quality_rows(bad)) > 0L
)
good <- dr_run(
  write = FALSE,
  stop_on_failure = FALSE,
  flow,
  data = data.frame(id = 1:3, amount = c(25, 75, 50))
)
stopifnot(sum(dr_collect(good)$amount) == 150)
stopifnot(!any(family_extensions %in% loadedNamespaces()))
cat("Independent core workflow passed.\n")

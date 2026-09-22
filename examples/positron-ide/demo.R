# Compiler-free checked delivery. Run in an interactive R session.
# This uses versioned RDS files, not a DuckDB/DuckLake connection.
library(dataraft)

policy_product <- dr_product("policies") |>
  dr_add_contract(c(policy_id = "integer", premium = "numeric")) |>
  dr_add_quality(list(nonnegative_premium = ~ premium >= 0))

bad_delivery <- data.frame(policy_id = 1:3, premium = c(120, -80, 100))
workflow <- dr_workflow() |> dr_add_product(policy_product)
checked <- dr_trial(
  workflow,
  data = bad_delivery,
  stop_on_failure = FALSE
)
stopifnot(identical(checked$status, "blocked"))

# dr_review() opens a bounded diagnostic table using the IDE data viewer.
if (interactive()) {
  dr_review(checked, rule = "nonnegative_premium", limit = 20)
}

# An explicit publish remains an R operation initiated by the user.
# The IDE extension itself does not add a production-publish action.
release_directory <- tempfile("dataraft-ide-rds-")
good_delivery <- transform(bad_delivery, premium = abs(premium))
published <- policy_product |>
  dr_add_source(good_delivery) |>
  dr_set_target(dr_target_rds(release_directory)) |>
  dr_publish()

pinned_source <- dr_source_rds(release_directory, published$outputs$version)
stopifnot(identical(dr_read_source(pinned_source)$premium, c(120, 80, 100)))
cat("Local checked RDS release:", release_directory, "\n")

# No Connections entry or live lake catalog is fabricated for these files.
# Delete the temporary demonstration release when you have finished inspecting it.

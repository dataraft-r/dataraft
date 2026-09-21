source(
  system.file("test-fixtures", "lake.R", package = "dataraft.lake"),
  local = TRUE
)
reserve_metric <- function(product = "risk.validated") {
  dr_metric(
    "risk.reserve",
    product,
    expr = sum(reserve, na.rm = TRUE),
    dimensions = "company",
    time_column = "date",
    unit = "EUR",
    owner = "Risk",
    description = "Sum of reserves at one date",
    approved = TRUE,
    code_version = "metric-v1"
  )
}

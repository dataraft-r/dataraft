dir.create("accessibility-artifacts", showWarnings = FALSE)
contract <- dataraft.core::dr_contract(
  "orders",
  columns = c(id = "integer", amount = "numeric"),
  rules = list(
    dataraft.core::dr_quality_rule(~ amount >= 0),
    dataraft.core::dr_quality_rule(~ amount < 100, action = "warn")
  )
)
dataraft.adapters::dr_contract_odcs(
  contract,
  "accessibility-artifacts/contract.odcs.json"
)
checks <- dataraft.core::dr_validate(
  data.frame(id = 1:3, amount = c(-1, 10, 200)),
  contract
)
dataraft.core::dr_quality_report(
  checks,
  "accessibility-artifacts/quality.html",
  overwrite = TRUE
)
jsonlite::write_json(
  list(
    exported_at = "2026-01-01T00:00:00Z",
    assets = list(list(
      id = "orders",
      version = "1.0.0",
      kind = "contract",
      owner = "Reporting",
      description = "Synthetic orders",
      definition = '{"id":"orders","version":"1.0.0"}'
    )),
    runs = list(list(
      run_id = "run-1",
      asset = "orders",
      status = "blocked",
      started_at = "2026-01-01T00:00:00Z"
    )),
    releases = list(list(
      asset = "orders",
      release_id = "release-1",
      release_order = "1",
      published_at = "2026-01-01T00:00:00Z",
      quality = "passed",
      contract = "orders@1.0.0"
    )),
    quality_results = transform(checks, run_id = "run-1")
  ),
  "accessibility-artifacts/catalog.json",
  auto_unbox = TRUE
)
if (identical(Sys.getenv("DATARAFT_A11Y_SERVE"), "true")) {
  shiny::runApp(
    dataraft.adapters::dr_catalog_app(
      snapshot = "accessibility-artifacts/catalog.json",
      launch = FALSE
    ),
    host = "127.0.0.1",
    port = 8766,
    launch.browser = FALSE
  )
}

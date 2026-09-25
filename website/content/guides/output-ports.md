# Publish to multiple output ports

A product may expose the same checked table through more than one target. The first output port is the primary release. Each later port uses an adapter with `dr_write_target()`. Sources and transformations run once, and every output receives the checked delivery.

```r
contract <- dataraft.core::dr_contract("customers",
  columns = c(id = "integer"), key = "id")
product <- dataraft.core::dr_product("customers",
  data.frame(id = 1:3), contract = contract) |>
  dataraft.core::dr_add_output(dataraft.core::dr_output(
    "primary", dataraft.adapters::dr_target_rds("customers-primary"),
    sla = dataraft.core::dr_sla(
      available_by = "08:00", timezone = "Europe/Berlin"))) |>
  dataraft.core::dr_add_output(dataraft.core::dr_output(
    "secondary", dataraft.adapters::dr_target_rds("customers-secondary")))

result <- dataraft.core::dr_run(product,
  business_date = as.character(Sys.Date()), evidence = "run-evidence")
result$port_outputs
result$metadata$sla$primary
dataraft.core::dr_read_run("run-evidence", result$run_id)$port_outputs
```

The SLA check uses the successful publication time and the explicit business date. A late delivery remains published and records `late` in the result and durable evidence. `dr_check_sla()` also evaluates missing deliveries when no run takes place.

## Recover from a partial publication

Outputs commit in order. They do not share a transaction across destinations. If a later writer fails, the run has status `error`, while `result$port_outputs` names the committed and failed ports. The primary release remains available. Inspect each destination and the saved run evidence before retrying, especially when a target appends data. Use `stop_on_failure = FALSE` to receive the result directly; the default error includes it as `condition$result`.

```r
result <- dataraft.core::dr_run(product,
  business_date = as.character(Sys.Date()),
  stop_on_failure = FALSE, evidence = "run-evidence")
result$status
result$port_outputs
# After repairing the failed destination, resume only unpublished ports:
resumed <- dataraft.core::dr_retry_ports(product, result,
  evidence = "run-evidence")
resumed$port_outputs
```

Keep the original in-memory `result`: the saved JSON evidence contains no data rows.
The retry retains the run ID and never rewrites a port marked `published`.
If an unpublished port has an SLA, provide `business_date` again. If a writer
fails during retry, its receipt stays `failed` and later ports remain pending.

Cache reuse is disabled for products with multiple output ports, so an unchanged primary release cannot silently skip a secondary publication. RDS, database and Parquet targets are available through `dataraft.adapters`; choose a target with publication behavior that fits each consumer.

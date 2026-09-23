# A bounded input and allocation regression gate, not a hardware speed contest.
library(dataraft)
set.seed(20260921)
rows <- 10000L
data <- data.frame(policy_id = seq_len(rows), premium = runif(rows, 0, 1000))
workflow <- dr_product("benchmark") |>
  dr_add_contract(c(policy_id = "integer", premium = "numeric")) |>
  dr_add_quality(~ premium >= 0)
elapsed <- system.time(
  result <- dr_run(
    write = FALSE,
    stop_on_failure = FALSE,
    workflow,
    data = data
  )
)[["elapsed"]]
stopifnot(nrow(dr_collect(result)) == rows)
# Bound retained result size generously; do not fail on shared-runner wall time.
stopifnot(as.numeric(object.size(result)) < 100 * 1024^2)
dir.create("check", showWarnings = FALSE)
write.csv(
  data.frame(
    rows = rows,
    elapsed_seconds = elapsed,
    retained_bytes = as.numeric(object.size(result))
  ),
  "check/benchmark-smoke.csv",
  row.names = FALSE
)

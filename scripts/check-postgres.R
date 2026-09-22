# Run against a dedicated, disposable PostgreSQL database and shared test folder.
# The database must be empty; never point this script at an existing lake.
library(dataraft)
stopifnot(nzchar(Sys.getenv("DATARAFT_TEST_PG_CONNECTION")))
root <- normalizePath("check/postgres", mustWork = FALSE)
dir.create(root, recursive = TRUE, showWarnings = FALSE)
root <- tempfile("run-", tmpdir = normalizePath(root))
dir.create(root)
publication_number <- 0L
publish <- function(...) {
  args <- list(...)
  publication_number <<- publication_number + 1L
  label <- paste("Publication", publication_number, "asset", args[[1]]$id)
  cat(label, "\n")
  tryCatch(do.call(dataraft::dr_publish, args), error = function(e) {
    condition <- e$result$error
    if (is.null(condition)) {
      condition <- e
    }
    details <- list(
      phase = label,
      error_class = class(condition),
      message = conditionMessage(condition)
    )
    print(details)
    saveRDS(details, file.path(root, "main-error.rds"))
    stop(e)
  })
}
config <- dr_lake_config(
  dr_registry_postgres("DATARAFT_TEST_PG_CONNECTION", lock_timeout = 30),
  dr_storage_local(file.path(root, "data")),
  landing = file.path(root, "landing"),
  backend = "ducklake"
)
lake <- dr_open_lake(config)
stopifnot(nrow(dr_releases(lake)) == 0L)
dr_close_lake(lake)
worker <- normalizePath("scripts/postgres-worker.R")
launch <- function(job, number) {
  input <- file.path(root, paste0("job-", number, ".rds"))
  output <- file.path(root, paste0("out-", number, ".rds"))
  saveRDS(c(list(config = config, output = output), job), input)
  process <- processx::process$new(
    file.path(R.home("bin"), "Rscript"),
    c(worker, input),
    stdout = file.path(root, paste0(number, ".log")),
    stderr = "2>&1"
  )
  list(process = process, output = output)
}
finish <- function(job) {
  job$process$wait(timeout = 120000)
  if (job$process$is_alive()) {
    job$process$kill()
    stop("Worker timed out")
  }
  stopifnot(job$process$get_exit_status() == 0L)
  result <- readRDS(job$output)
  print(result)
  result
}
# A filesystem barrier inside preparation proves that distinct assets overlap.
# A whole-run global lock deadlocks this test before either publication starts.
await_ready <- function(paths) {
  deadline <- Sys.time() + 60
  while (!all(file.exists(paths)) && Sys.time() < deadline) {
    Sys.sleep(0.05)
  }
  if (!all(file.exists(paths))) stop("Preparation barrier timed out")
}
left_ready <- file.path(root, "left-ready")
right_ready <- file.path(root, "right-ready")
parallel_go <- file.path(root, "parallel-go")
a <- launch(
  list(
    action = "publish",
    asset = "left",
    value = 1L,
    ready = left_ready,
    proceed = parallel_go
  ),
  1
)
b <- launch(
  list(
    action = "publish",
    asset = "right",
    value = 2L,
    ready = right_ready,
    proceed = parallel_go
  ),
  2
)
await_ready(c(left_ready, right_ready))
stopifnot(file.create(parallel_go))
left <- finish(a)
right <- finish(b)
stopifnot(left$status == "published", right$status == "published")
lake <- dr_open_lake(config, read_only = TRUE)
orders <- dr_releases(lake)
stopifnot(
  setequal(orders$release_id, c(left$release, right$release)),
  identical(as.character(orders$release_order), c("2", "1")),
  identical(dr_read_release(lake, "left")$id, 1L),
  identical(dr_read_release(lake, "right")$id, 2L)
)
dr_close_lake(lake)
# Nested publication must not wait on a lock already owned by this process.
upstream <- dr_product("upstream", data.frame(id = 1L)) |> dr_set_target(config)
stopifnot(
  publish(dr_product("downstream", upstream), to = config)$status == "published"
)
# Force a stale correction AFTER its initial previous check and BEFORE candidate
# construction: checking only the later candidate parent would accept this write.
first <- publish(dr_product("shared", data.frame(id = 1L)), to = config)
stale_ready <- file.path(root, "stale-ready")
stale_go <- file.path(root, "stale-go")
a <- launch(
  list(
    action = "publish",
    asset = "shared",
    value = 2L,
    previous = first,
    ready = stale_ready,
    proceed = stale_go
  ),
  3
)
await_ready(stale_ready)
newer <- publish(
  dr_product("shared", data.frame(id = 3L)),
  to = config,
  previous = first
)
stopifnot(newer$status == "published", file.create(stale_go))
stale <- finish(a)
stopifnot(
  stale$status == "error",
  "dr_publication_conflict" %in% stale$error_class
)
lake <- dr_open_lake(config, read_only = TRUE)
stopifnot(
  identical(dr_read_release(lake, "shared")$id, 3L),
  identical(
    dr_releases(lake, "shared")$release_id,
    c(newer$release_id, first$release_id)
  )
)
dr_close_lake(lake)
# Same reviewed report is idempotent even when two clients issue it together.
a <- launch(list(action = "report", previous = first), 5)
b <- launch(list(action = "report", previous = first), 6)
stopifnot(finish(a)$status == "reported", finish(b)$status == "reported")
# An interrupted session relinquishes the database lock; no manual lock-file cleanup.
ready <- file.path(root, "writer-ready")
holder <- launch(list(action = "hold", asset = "busy", ready = ready), 7)
deadline <- Sys.time() + 15
while (!file.exists(ready) && Sys.time() < deadline) {
  Sys.sleep(0.1)
}
stopifnot(file.exists(ready))
# A held asset lock allows another asset to finish, not just to open a connection.
stopifnot(
  publish(
    dr_product("unrelated", data.frame(id = 1L)),
    to = config
  )$status ==
    "published"
)
short_wait <- config
short_wait$catalog$lock_timeout <- 0
busy <- tryCatch(
  publish(dr_product("busy", data.frame(id = 1L)), to = short_wait),
  error = identity
)
stopifnot(inherits(busy$result$error, "dr_writer_busy"))
reader <- dr_open_lake(config, read_only = TRUE)
stopifnot(dr_read_release(reader, "shared", first$release_id)$id == 1L)
dr_close_lake(reader)
holder$process$kill()
holder$process$wait(timeout = 10000)
stopifnot(
  publish(
    dr_product("busy", data.frame(id = 1L)),
    to = config
  )$status ==
    "published"
)
lake <- dr_open_lake(config)
stopifnot(
  nrow(dr_releases(lake, "shared")) == 2L,
  sum(dr_registry(lake, "reports")$id == "same-report") == 1L,
  identical(dr_collect(first)$id, 1L),
  !anyDuplicated(as.character(dr_releases(lake)$release_order))
)
model <- dm::dm(
  customers = data.frame(id = 1:2),
  policies = data.frame(id = 1:2)
) |>
  dm::dm_add_pk(customers, id) |>
  dm::dm_add_fk(policies, id, customers)
original <- publish(dr_product("portfolio", model), to = lake)
blocked <- publish(
  dr_product("portfolio", model),
  to = lake,
  sources = list(customers = data.frame(id = 1L)),
  stop_on_failure = FALSE
)
stopifnot(
  blocked$status == "blocked",
  nrow(dr_releases(lake, "portfolio")) == 1L,
  identical(dr_collect(original)$policies$id, 1:2)
)
dr_close_lake(lake)
cat(
  "PostgreSQL/DuckLake: overlapping preparation, ordered commits, stale correction, report identity, asset lock recovery and model gate passed.\n"
)

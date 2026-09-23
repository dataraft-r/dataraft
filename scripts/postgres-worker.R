library(dataraft)
job <- readRDS(commandArgs(trailingOnly = TRUE)[[1]])
result <- tryCatch(
  {
    if (job$action == "hold") {
      hold <- function() {
        lake <- dataraft.lake::dr_open_lake(job$config)
        on.exit(dataraft.lake::dr_close_lake(lake), add = TRUE)
        dataraft.lake::dr_internal_acquire_lake_writer(
          lake,
          environment(),
          job$asset
        )
        file.create(job$ready)
        repeat {
          Sys.sleep(1)
        }
      }
      hold()
      list(status = "held")
    } else if (job$action == "report") {
      metrics <- dataraft.metrics::dr_metric_set(
        "shared",
        count = dplyr::n(),
        approved = TRUE,
        code_version = "v1"
      )
      set.seed(101)
      values <- dataraft.metrics::dr_measure(
        job$previous,
        metrics = metrics,
        by = character()
      )
      dataraft.metrics::dr_report_release(
        values,
        "same-report",
        code_version = "v1"
      )
      list(status = "reported")
    } else {
      product <- dr_product(job$asset, data.frame(id = job$value))
      if (!is.null(job$ready)) {
        barrier <- function(ready, proceed) {
          force(ready)
          force(proceed)
          function(data) {
            if (!file.create(ready)) {
              stop("Cannot signal preparation barrier")
            }
            deadline <- Sys.time() + 90
            while (!file.exists(proceed) && Sys.time() < deadline) {
              Sys.sleep(0.05)
            }
            if (!file.exists(proceed)) {
              stop("Preparation barrier timed out")
            }
            data
          }
        }
        product <- dataraft.core::dr_add_recipe(
          product,
          dataraft.core::dr_recipe() |>
            dataraft.core::dr_step_transform(barrier(job$ready, job$proceed))
        )
      }
      result <- dr_publish(
        product,
        to = job$config,
        previous = job$previous
      )
      list(status = result$status, release = result$release_id)
    }
  },
  error = function(e) {
    condition <- e$result$error
    if (is.null(condition)) {
      condition <- e
    }
    list(
      status = "error",
      error_class = class(condition),
      message = conditionMessage(condition)
    )
  }
)
saveRDS(result, job$output)

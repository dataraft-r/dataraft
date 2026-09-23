#' Try a checked insurance delivery in memory
#'
#' Runs synthetic policy data through the same contract and quality gate twice.
#' A negative premium blocks the first delivery; the corrected delivery passes.
#' No database, files, network, credentials or optional engines are required.
#' @param quiet Suppress the short status message.
#' @returns Invisibly, a list with `blocked` and `passed` trial results, and the
#'   shared `workflow`. Use [dataraft.core::dr_quality_rows()] to inspect the blocked result or
#'   [dr_collect()] to collect the passed result.
#' @export
#' @examples
#' demo <- dr_demo()
#' demo$blocked$status
#' dr_collect(demo$passed)
dr_demo <- function(quiet = FALSE) {
  workflow <- dr_product("policy_delivery") |>
    dr_add_contract(c(policy_id = "integer", premium = "numeric")) |>
    dr_add_quality(~ premium >= 0)
  blocked <- dr_run(
    write = FALSE,
    stop_on_failure = FALSE,
    workflow,
    data = data.frame(policy_id = 1:3, premium = c(120, -80, 100))
  )
  passed <- dr_run(
    write = FALSE,
    stop_on_failure = FALSE,
    workflow,
    data = data.frame(policy_id = 1:3, premium = c(120, 80, 100))
  )
  if (!quiet) {
    message(
      "Negative premium: ",
      blocked$status,
      "; corrected delivery: ",
      passed$status,
      "."
    )
  }
  invisible(list(blocked = blocked, passed = passed, workflow = workflow))
}

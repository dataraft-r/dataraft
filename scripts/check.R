# Check each independent source package, then the umbrella integration suite.
source("scripts/install-family.R")
results <- lapply(paths, function(path) {
  name <- read.dcf(file.path(path, "DESCRIPTION"), fields = "Package")[[1L]]
  rcmdcheck::rcmdcheck(
    path = path,
    args = "--no-manual",
    error_on = "never",
    check_dir = file.path("check", name)
  )
})
failed <- vapply(
  results,
  function(result) {
    length(result$errors) + length(result$warnings) > 0L
  },
  logical(1)
)
if (any(failed)) {
  logs <- list.files(
    "check",
    pattern = "[.]Rout[.]fail$",
    recursive = TRUE,
    full.names = TRUE
  )
  for (log in logs) {
    cat("\nTest log: ", log, "\n", sep = "")
    cat(readLines(log), sep = "\n")
  }
  stop("Package checks failed: ", paste(paths[failed], collapse = ", "))
}

# Surface successful test summaries too: R CMD check otherwise prints only OK.
for (path in list.files(
  "check",
  pattern = "^test-summary[.]csv$",
  recursive = TRUE,
  full.names = TRUE
)) {
  summary <- utils::read.csv(path)
  cat(sprintf(
    "%s: %d test blocks, %d passed assertions, %d skipped blocks\n",
    path,
    nrow(summary),
    sum(summary$passed),
    sum(summary$skipped)
  ))
  if (grepl("dataraft[.]lake", path, fixed = FALSE) &&
      sum(summary$skipped) > 107L) {
    stop(sprintf("Lake skipped %d test blocks; review and lower the skip budget (107).",
      sum(summary$skipped)))
  }
}

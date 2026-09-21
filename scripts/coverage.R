# Instrument one component while exercising the shared integration suite.
component <- Sys.getenv("DATARAFT_COVERAGE_PACKAGE", "core")
stopifnot(
  component %in% c("core", "lake", "adapters", "metrics", "dbt", "catalog")
)
root <- normalizePath(".", winslash = "/")
code <- sprintf(
  'library(dataraft); testthat::test_dir(%s, stop_on_failure = TRUE)',
  encodeString(file.path(root, "tests", "testthat"), quote = '"')
)
dir.create("coverage", showWarnings = FALSE)
coverage <- tryCatch(
  covr::package_coverage(
    path = file.path("packages", paste0("dataraft.", component)),
    type = "all",
    code = code,
    quiet = FALSE,
    clean = FALSE,
    install_path = file.path(root, "coverage", paste0("library-", component))
  ),
  error = function(e) {
    logs <- list.files(
      "coverage",
      pattern = "[.]Rout[.]fail$",
      recursive = TRUE,
      full.names = TRUE
    )
    for (log in logs) {
      cat(readLines(log), sep = "\n")
    }
    stop(e)
  }
)
dir.create("coverage", showWarnings = FALSE)
covr::to_cobertura(
  coverage,
  filename = file.path("coverage", paste0(component, ".xml"))
)
print(coverage)

percent <- covr::percent_coverage(coverage)
summary <- sprintf(
  "| %s | %.1f%% | %s |\n",
  component,
  percent,
  Sys.getenv("GITHUB_SHA", "local")
)
cat(summary, file = file.path("coverage", paste0(component, "-summary.md")))
if (nzchar(Sys.getenv("GITHUB_STEP_SUMMARY"))) {
  cat(
    "| Component | Line coverage | Commit |\n|---|---:|---|\n",
    summary,
    file = Sys.getenv("GITHUB_STEP_SUMMARY"),
    append = TRUE
  )
}

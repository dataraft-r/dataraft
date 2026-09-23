# Instrument one component while exercising the shared integration suite.
component <- Sys.getenv("DATARAFT_COVERAGE_PACKAGE", "core")
stopifnot(
  component %in%
    c("core", "lake", "adapters", "metrics", "dbt", "catalog", "ide")
)
root <- normalizePath(".", winslash = "/")
code <- sprintf(
  'library(dataraft); testthat::test_dir(%s, stop_on_failure = TRUE)',
  encodeString(file.path(root, "tests", "testthat"), quote = '"')
)
dir.create("coverage", showWarnings = FALSE)
# The catalog package contains only adapter reexports. Check that invariant and
# its compatibility tests instead of reporting a fictitious line percentage.
if (component == "catalog") {
  namespace <- asNamespace("dataraft.catalog")
  exports <- getNamespaceExports(namespace)
  stopifnot(length(exports) > 0L)
  stopifnot(all(vapply(
    exports,
    function(name) {
      identical(
        getExportedValue("dataraft.catalog", name),
        getExportedValue("dataraft.adapters", name)
      )
    },
    logical(1)
  )))
  owned_functions <- Filter(
    function(name) {
      value <- get(name, envir = namespace, inherits = FALSE)
      is.function(value) && identical(environment(value), namespace)
    },
    ls(namespace, all.names = TRUE)
  )
  stopifnot(length(owned_functions) == 0L)
  testthat::test_local("packages/dataraft.catalog", stop_on_failure = TRUE)
  summary <- paste0(
    "Catalog: N/A (pure reexports); compatibility tests passed. ",
    "Implementation coverage is measured in dataraft.adapters.\n"
  )
  cat(summary, file = "coverage/catalog-summary.md")
  if (nzchar(Sys.getenv("GITHUB_STEP_SUMMARY"))) {
    cat(summary, file = Sys.getenv("GITHUB_STEP_SUMMARY"), append = TRUE)
  }
  cat(summary)
  quit(status = 0L)
}
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
# Every component has exercised code. A zero result here indicates broken
# instrumentation, not a meaningful coverage measurement.
if (!is.finite(percent) || percent == 0) {
  stop("Coverage instrumentation recorded no executed component code.")
}
summary <- sprintf(
  "| %s | %.1f%% | %s |\n",
  component,
  percent,
  withr::with_dir(
    file.path("packages", paste0("dataraft.", component)),
    system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  )
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

# Run from the repository root.
family <- c("core", "lake", "adapters", "metrics", "dbt", "catalog", "ide")
paths <- c(file.path("packages", paste0("dataraft.", family)), ".")
if (any(!file.exists(file.path(head(paths, -1L), "DESCRIPTION")))) {
  status <- system2("python", "scripts/checkout-family.py")
  if (status != 0L) stop("Could not obtain locked family sources.")
}
descriptions <- lapply(paths, function(path) {
  read.dcf(file.path(path, "DESCRIPTION"), fields = c("Package", "Imports"))
})
family_names <- vapply(descriptions, function(x) x[1L, "Package"], character(1))
dependencies <- unique(trimws(unlist(strsplit(
  paste(
    vapply(descriptions, function(x) x[1L, "Imports"], character(1)),
    collapse = ","
  ),
  ","
))))
dependencies <- trimws(sub(" \\(.*", "", dependencies))
missing <- setdiff(
  dependencies,
  c(family_names, rownames(installed.packages()))
)
if (length(missing)) {
  # Respect setup-r's dated platform-specific repository, including Linux
  # binaries. Fall back to the same source snapshot only outside configured CI.
  repos <- getOption("repos")
  repos <- repos[!is.na(repos) & nzchar(repos) & repos != "@CRAN@"]
  if (!length(repos)) {
    repos <- c(CRAN = "https://packagemanager.posit.co/cran/2026-09-18")
  }
  install.packages(missing, repos = repos)
}
for (path in paths) {
  status <- system2(
    file.path(R.home("bin"), "R"),
    c("CMD", "INSTALL", shQuote(path))
  )
  if (status != 0L) stop("Installation failed: ", path)
}

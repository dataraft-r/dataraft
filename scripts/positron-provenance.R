# Record the sources actually installed by install-family.R, not older extension pins.
lock <- jsonlite::read_json("family-lock.json", simplifyVector = FALSE)
mode <- Sys.getenv("DATARAFT_FAMILY_MODE", "pinned")
resolved <- jsonlite::read_json("check/resolved-family.json", simplifyVector = FALSE)
packages <- lapply(names(lock$packages), function(package) {
  entry <- lock$packages[[package]]
  path <- if (package == "dataraft") "." else file.path("packages", package)
  sha <- withr::with_dir(
    path,
    system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  )
  stopifnot(length(sha) == 1L)
  if (mode == "head") {
    stopifnot(identical(sha, resolved$packages[[package]]$ref))
  } else if (entry$ref != "self") {
    stopifnot(identical(sha, entry$ref))
  }
  stopifnot(identical(
    as.character(utils::packageVersion(package)),
    entry$version
  ))
  list(name = package, version = entry$version, source_sha = sha)
})
for (package in c("duckdb", "bit64", "dm", "yaml")) {
  stopifnot(requireNamespace(package, quietly = TRUE))
  packages <- c(
    packages,
    list(list(
      name = package,
      version = as.character(utils::packageVersion(package))
    ))
  )
}
stopifnot(utils::packageVersion("duckdb") >= "1.5.5")
stopifnot(as.character(getRversion()) == lock$r_version)
dir.create("extension/.vscode-test", recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(
  list(
    r_version = as.character(getRversion()),
    repository = unname(getOption("repos")[["CRAN"]]),
    packages = packages
  ),
  "extension/.vscode-test/r-provenance.json",
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

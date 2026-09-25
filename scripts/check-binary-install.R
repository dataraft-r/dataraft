# Smoke test the published family and prove the installed bytes came from its archives.
platform <- Sys.getenv("BINARY_PLATFORM")
base <- "https://dataraft-r.github.io/dataraft/packages"
minor <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1L]][1L], sep = ".")
stopifnot(identical(minor, Sys.getenv("BINARY_R_VERSION")))
windows <- startsWith(platform, "windows-")
if (windows) {
  repo <- paste0(base, "/", platform)
  if (platform == "windows-arm64") {
    stopifnot(grepl("aarch64|arm64", R.version$arch, ignore.case = TRUE))
    subdir <- if (minor == "4.4") "bin/windows/contrib" else "bin/windows/clang-aarch64/contrib"
  } else {
    stopifnot(grepl("x86_64|x64", R.version$arch, ignore.case = TRUE))
    subdir <- "bin/windows/contrib"
  }
} else {
  arch <- if (platform == "linux-arm64") "arm64" else "x86_64"
  stopifnot(grepl(if (arch == "arm64") "aarch64|arm64" else "x86_64", R.version$arch, ignore.case = TRUE))
  repo <- paste0(base, "/linux/noble-", arch, "/", minor)
  subdir <- "src/contrib"
}
cran <- getOption("repos")[["CRAN"]]
if (platform == "windows-arm64") cran <- "https://cran.r-universe.dev"
options(repos = c(DataRaft = repo, CRAN = cran))
index <- paste(repo, subdir, sep = "/")
records <- available.packages(contriburl = index)
family <- c(paste0("dataraft.", c("core", "lake", "adapters", "metrics", "dbt", "ide")), "dataraft")
stopifnot(all(family %in% rownames(records)))
if (!requireNamespace("pak", quietly = TRUE)) {
  pak_repo <- sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s",
    .Platform$pkgType, R.Version()$os, R.Version()$arch)
  install.packages("pak", repos = pak_repo)
}
# Dependencies are allowed to come from CRAN. Family packages are installed
# exclusively from the seven exact, published archives below.
imports <- unique(unlist(tools::package_dependencies(family, db = records,
  which = c("Depends", "Imports"), recursive = FALSE), use.names = FALSE))
imports <- imports[!is.na(imports) & nzchar(imports)]
imports <- setdiff(imports, c(family, "R"))
if (length(imports)) pak::pkg_install(imports, ask = FALSE)

archive_dir <- tempfile("published-family-")
dir.create(archive_dir)
for (name in family) {
  filename <- records[name, "File"]
  if (is.na(filename) || !nzchar(filename)) {
    filename <- paste0(name, "_", records[name, "Version"], if (windows) ".zip" else ".tar.gz")
  }
  stopifnot(identical(basename(filename), filename),
    grepl(if (windows) "\\.zip$" else "\\.tar\\.gz$", filename))
  archive <- file.path(archive_dir, filename)
  url <- paste(index, filename, sep = "/")
  status <- download.file(url, archive, mode = "wb", quiet = TRUE)
  stopifnot(identical(status, 0L), file.info(archive)$size > 0L)
  # The archive must already contain installed-package metadata, so a source
  # tarball with the same version can never satisfy this smoke test.
  member <- paste0(name, "/Meta/package.rds")
  members <- if (windows) unzip(archive, list = TRUE)$Name else untar(archive, list = TRUE)
  stopifnot(member %in% members)
  extraction <- tempfile("archive-meta-")
  dir.create(extraction)
  if (windows) unzip(archive, files = member, exdir = extraction) else untar(archive, files = member, exdir = extraction)
  expected <- file.path(extraction, member)
  # Explicit local binary installation prevents a source fallback by pak or R.
  if (windows) {
    install.packages(archive, repos = NULL, type = "win.binary", quiet = TRUE)
  } else {
    status <- system2(file.path(R.home("bin"), "R"),
      c("CMD", "INSTALL", shQuote(archive)))
    stopifnot(identical(status, 0L))
  }
  installed <- system.file("Meta", "package.rds", package = name)
  stopifnot(nzchar(installed),
    identical(unname(tools::md5sum(expected)), unname(tools::md5sum(installed))),
    identical(as.character(utils::packageVersion(name)), records[name, "Version"]))
  cat("Verified published binary:", name, url, "\n")
  unlink(extraction, recursive = TRUE)
}
unlink(archive_dir, recursive = TRUE)

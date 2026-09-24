# Build the locked family in dependency order. Run from the metapackage root.
paths <- c(file.path("packages", paste0("dataraft.",
  c("core", "lake", "adapters", "metrics", "dbt", "ide"))), ".")
if (any(!file.exists(file.path(paths, "DESCRIPTION")))) {
  stop("Run scripts/checkout-family.py before building the family.")
}

output <- normalizePath(Sys.getenv("DATARAFT_BINARY_OUTPUT", "binary-output"),
  mustWork = FALSE)
dir.create(output, recursive = TRUE, showWarnings = FALSE)
if (length(list.files(output))) stop("Binary output must be empty.")

family <- vapply(paths, function(path) {
  read.dcf(file.path(path, "DESCRIPTION"), fields = "Package")[[1L]]
}, character(1))
# Install third-party imports before compiling the family. Never install a
# DataRaft package from GitHub here: all builds use the locked checkout.
imports <- unique(unlist(lapply(paths, function(path) {
  value <- read.dcf(file.path(path, "DESCRIPTION"), fields = "Imports")[[1L]]
  trimws(sub("\\s*\\(.*", "", strsplit(value, ",")[[1L]]))
})))
imports <- setdiff(imports[nzchar(imports)], family)
missing <- setdiff(imports, rownames(installed.packages()))
if (length(missing)) pak::pkg_install(missing, ask = FALSE)

r_bin <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "R.exe" else "R")
for (path in paths) {
  name <- read.dcf(file.path(path, "DESCRIPTION"), fields = "Package")[[1L]]
  before <- list.files(".", full.names = TRUE)
  status <- system2(r_bin, c("CMD", "INSTALL", "--build", shQuote(path)))
  if (!identical(status, 0L)) stop("Could not build ", name)
  after <- setdiff(list.files(".", full.names = TRUE), before)
  after <- after[startsWith(basename(after), paste0(name, "_")) &
    grepl("\\.(zip|tar\\.gz)$", after)]
  if (length(after) != 1L) stop("Expected one binary archive for ", name)
  file.copy(after, output, overwrite = FALSE)
}
archives <- list.files(output, full.names = TRUE)
if (length(archives) != length(paths)) stop("Incomplete family binaries")
writeLines(sprintf("%s %s", basename(archives),
  unname(tools::md5sum(archives))), file.path(output, "checksums.txt"))

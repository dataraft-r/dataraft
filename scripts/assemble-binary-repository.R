# Assemble platform-specific CRAN-like repositories from immutable release assets.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: Rscript assemble-binary-repository.R ASSETS OUTPUT")
assets <- list.files(args[[1L]], full.names = TRUE)
output <- args[[2L]]
if (!length(assets)) stop("No binary assets available")
matrix <- expand.grid(
  platform = c("windows-x64", "windows-arm64", "linux-x64-noble", "linux-arm64-noble"),
  r = paste0("4.", 2:6), stringsAsFactors = FALSE
)
matrix <- subset(matrix, platform != "windows-arm64" | r >= "4.4")
for (i in seq_len(nrow(matrix))) {
  platform <- matrix$platform[[i]]
  minor <- matrix$r[[i]]
  prefix <- paste0("dataraft-", platform, "-r", minor, "--")
  selected <- assets[startsWith(basename(assets), prefix)]
  if (length(selected) != 7L) stop("Incomplete binary release: ", prefix)
  if (startsWith(platform, "windows-")) {
    # Separate roots prevent x64 and ARM ZIP files from sharing an index.
    destination <- file.path(output, platform, "bin", "windows", "contrib", minor)
    kind <- "win.binary"
  } else {
    arch <- if (platform == "linux-arm64-noble") "arm64" else "x86_64"
    destination <- file.path(output, "linux", paste0("noble-", arch), minor, "src", "contrib")
    kind <- "source"
  }
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)
  for (archive in selected) {
    filename <- substring(basename(archive), nchar(prefix) + 1L)
    if (!file.copy(archive, file.path(destination, filename))) {
      stop("Could not copy ", filename)
    }
  }
  tools::write_PACKAGES(destination, type = kind, latestOnly = TRUE,
    addFiles = TRUE)
  if (!file.exists(file.path(destination, "PACKAGES"))) {
    stop("Missing package index: ", destination)
  }
}

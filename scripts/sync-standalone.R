# Run from the family workspace, or from the metapackage with packages/ checkouts.
root <- if (dir.exists("packages/dataraft.core")) "packages" else ".."
source <- file.path(root, "dataraft.core/inst/standalone/standalone-dataraft.R")
for (component in c("core", "lake", "adapters", "metrics", "dbt")) {
  destination <- file.path(
    root,
    paste0("dataraft.", component),
    "R/standalone-dataraft.R"
  )
  if (!file.copy(source, destination, overwrite = TRUE)) {
    stop("Cannot sync: ", destination)
  }
}

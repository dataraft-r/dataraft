# Run from book/, using the same immutable family as package and binary CI.
root <- normalizePath("..", mustWork = TRUE)
if (!requireNamespace("jsonlite", quietly = TRUE)) pak::pak("jsonlite")
lock <- jsonlite::fromJSON(file.path(root, "family-lock.json"),
                           simplifyVector = FALSE)
components <- setdiff(names(lock$packages), "dataraft")
repos <- vapply(components, function(name) {
  spec <- lock$packages[[name]]
  stopifnot(grepl("^[0-9a-f]{40}$", spec$ref))
  paste0(spec$repository, "@", spec$ref)
}, character(1L))

pak::pak(c(
  repos,
  root,
  "testthat",
  "withr",
  "knitr",
  "rmarkdown"
))

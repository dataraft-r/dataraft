book_root <- normalizePath(
  Sys.getenv("DATARAFT_BOOK_ROOT", unset = "."),
  winslash = "/",
  mustWork = TRUE
)
source(file.path(book_root, "examples", "insurance-platform", "R", "products.R"))

products <- insurance_products(book_root)

checked <- dataraft::dr_run(
  products$monthly_performance,
  write = FALSE,
  stop_on_failure = FALSE
)
print(dataraft::dr_quality_report(checked))
stopifnot(identical(checked$status, "completed"))
print(dataraft::dr_collect(checked))

release_root <- file.path(
  book_root,
  "examples",
  "insurance-platform",
  "releases",
  "monthly-performance"
)
dir.create(dirname(release_root), recursive = TRUE, showWarnings = FALSE)

published <- products$monthly_performance |>
  dataraft::dr_set_target(dataraft.adapters::dr_target_rds(release_root)) |>
  dataraft::dr_publish()

stopifnot(identical(published$status, "published"))
print(published$outputs)

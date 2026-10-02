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
print(dataraft::dr_lineage(checked))

release_root <- file.path(
  book_root,
  "examples",
  "insurance-platform",
  "releases",
  "monthly-performance"
)
dir.create(dirname(release_root), recursive = TRUE, showWarnings = FALSE)

publishable <- insurance_release_product(products, release_root)

print(dataraft.core::dr_check_policies(
  publishable,
  event = "publish"
))

published <- dataraft::dr_publish(
  publishable,
  business_date = "2026-10-02"
)

stopifnot(identical(published$status, "published"))
print(published$outputs)
print(published$port_outputs)
print(published$metadata$sla)

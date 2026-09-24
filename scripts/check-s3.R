# Run only against the disposable S3-compatible service provisioned by CI.
library(dataraft)

check_s3 <- function() {

endpoint <- Sys.getenv("DATARAFT_TEST_S3_ENDPOINT")
bucket <- Sys.getenv("DATARAFT_TEST_S3_BUCKET")
stopifnot(
  nzchar(endpoint), nzchar(bucket),
  nzchar(Sys.getenv("AWS_ACCESS_KEY_ID")),
  nzchar(Sys.getenv("AWS_SECRET_ACCESS_KEY"))
)
root <- tempfile("dataraft-s3-")
dir.create(root)
on.exit(unlink(root, recursive = TRUE), add = TRUE)
config <- dataraft.lake::dr_lake_config(
  dataraft.lake::dr_registry_duckdb(file.path(root, "metadata.ducklake")),
  dataraft.lake::dr_storage_s3(
    bucket, prefix = "integration", endpoint = endpoint, region = "us-east-1"
  ),
  landing = file.path(root, "landing"),
  backend = "ducklake"
)
lake <- dataraft.lake::dr_open_lake(config)
stopifnot(identical(lake$config$storage$type, "s3"))
first <- dataraft::dr_publish(
  # Above DuckLake's small-table inline threshold, so Parquet must reach S3.
  dr_product("s3_orders", data.frame(id = 1:10000, amount = 1:10000)),
  to = lake
)
stopifnot(
  first$status == "published",
  identical(dataraft.lake::dr_read_release(lake, "s3_orders")$id, 1:10000)
)
path <- file.path(root, "incoming.csv")
utils::write.csv(data.frame(id = 4L, amount = 40), path, row.names = FALSE)
ingested <- dataraft.lake::dr_ingest(
  path, lake, "s3_incoming", reader = utils::read.csv
)
stopifnot(ingested$status == "published", length(ingested$inputs$landed_path) > 0L)
dataraft.lake::dr_close_lake(lake)

# A fresh connection must retrieve data from S3, not from the original process.
lake <- dataraft.lake::dr_open_lake(config, read_only = TRUE)
on.exit(dataraft.lake::dr_close_lake(lake), add = TRUE)
stopifnot(
  identical(dataraft.lake::dr_read_release(lake, "s3_orders")$id, 1:10000),
  identical(dataraft.lake::dr_read_release(lake, "s3_incoming")$id, 4L),
  nrow(dataraft.lake::dr_releases(lake)) == 2L
)
cat("S3 DuckLake publication, landing upload and fresh-connection read passed.\n")

}
check_s3()

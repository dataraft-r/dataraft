book_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
options(dataraft.book_root = book_root)

testthat::test_dir(
  file.path(book_root, "examples", "insurance-platform", "tests", "testthat"),
  reporter = "summary"
)

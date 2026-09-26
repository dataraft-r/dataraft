test_that("README first example runs", {
  # The CI workspace points to the checked-out source, while R CMD check can
  # place test files beside a different README in its temporary directory.
  workspace <- Sys.getenv("GITHUB_WORKSPACE")
  readme <- if (nzchar(workspace)) {
    file.path(workspace, "README.md")
  } else {
    test_path("..", "..", "README.md")
  }
  if (!file.exists(readme)) skip("README source is unavailable here")
  lines <- readLines(readme, warn = FALSE)
  heading <- match("## See a delivery pass or fail", lines)
  expect_false(is.na(heading))
  opening <- which(lines == "```r" & seq_along(lines) > heading)[1L]
  closing <- which(lines == "```" & seq_along(lines) > opening)[1L]
  expect_false(is.na(opening))
  expect_false(is.na(closing))
  code <- paste(lines[seq.int(opening + 1L, closing - 1L)], collapse = "\n")
  expect_no_error(eval(parse(text = code), envir = new.env(parent = globalenv())))
})

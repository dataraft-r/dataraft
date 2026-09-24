# Binary installation

The binary repository is published only after every build in the matrix passes.
It contains the seven active packages: `dataraft`, `dataraft.core`,
`dataraft.lake`, `dataraft.adapters`, `dataraft.metrics`, `dataraft.dbt`,
and `dataraft.ide`.

Do not use `pak::pkg_install("dataraft-r/dataraft")` when you want a binary:
GitHub package references install a source checkout. Select the DataRaft
binary repository, then install by package name.

## Windows x64, R 4.2 to 4.6

```r
options(repos = c(
  DataRaft = "https://dataraft-r.github.io/dataraft/packages/windows-x64",
  CRAN = "https://cloud.r-project.org"
))
pak::pkg_install("dataraft")
```

## Native Windows ARM64, R 4.4 to 4.6

```r
stopifnot(grepl("aarch64|arm64", R.version$arch, ignore.case = TRUE))
options(repos = c(
  DataRaft = "https://dataraft-r.github.io/dataraft/packages/windows-arm64",
  CRAN = "https://cran.r-universe.dev"
))
pak::pkg_install("dataraft")
```

R 4.2 and 4.3 have no native Windows ARM build. If you run x64 R in
Windows ARM emulation, use the Windows x64 repository instead.

## Ubuntu 24.04, x64 or ARM64, R 4.2 to 4.6

```r
minor <- paste(R.version$major, strsplit(R.version$minor, "\\.")[[1]][1], sep = ".")
arch <- if (grepl("aarch64|arm64", R.version$arch, ignore.case = TRUE)) {
  "arm64"
} else {
  "x86_64"
}
options(repos = c(
  DataRaft = sprintf(
    "https://dataraft-r.github.io/dataraft/packages/linux/noble-%s/%s",
    arch, minor
  ),
  CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"
))
pak::pkg_install("dataraft")
```

Linux binaries are tied to the distribution ABI. The Noble builds are not
promised to work on Debian, Fedora, other Ubuntu releases, or custom R builds.
CRAN dependencies can still require source installation if a compatible
third-party binary is unavailable. A binary-only installation of the entire
dependency graph must be tested separately for each platform.

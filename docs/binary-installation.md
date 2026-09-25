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

## Native Windows ARM64, R 4.6

```r
stopifnot(grepl("aarch64|arm64", R.version$arch, ignore.case = TRUE))
options(repos = c(
  DataRaft = "https://dataraft-r.github.io/dataraft/packages/windows-arm64",
  CRAN = "https://cran.r-universe.dev"
))
pak::pkg_install("dataraft")
```

R 4.6 uses the native `windows.binary.clang-aarch64` repository layout.

## Native Windows ARM64, R 4.4 and 4.5

These R releases do not advertise the new ARM binary package type to `pak`.
Install third-party dependencies with `pak`, then install the seven DataRaft
ARM ZIPs from the versioned repository. This installs the DataRaft family as
binaries even when third-party dependencies need to be built from source.

```r
stopifnot(grepl("aarch64|arm64", R.version$arch, ignore.case = TRUE))
repo <- "https://dataraft-r.github.io/dataraft/packages/windows-arm64"
options(repos = c(CRAN = "https://cran.r-universe.dev"))
index <- contrib.url(repo, type = "win.binary")
records <- available.packages(contriburl = index)
family <- c("dataraft.core", "dataraft.lake", "dataraft.adapters",
            "dataraft.metrics", "dataraft.dbt", "dataraft.ide", "dataraft")
stopifnot(all(family %in% rownames(records)))
fields <- as.character(records[family, c("Depends", "Imports")])
fields <- fields[!is.na(fields)]
deps <- unique(trimws(sub("\\s*\\(.*", "",
  unlist(strsplit(paste(fields, collapse = ","), ",", fixed = TRUE)))))
deps <- setdiff(deps[nzchar(deps)], c("R", family, rownames(installed.packages())))
if (length(deps)) pak::pkg_install(deps)
files <- records[family, "File"]
stopifnot(all(files == paste0(family, "_", records[family, "Version"], ".zip")))
install.packages(paste0(index, "/", files), repos = NULL, type = "win.binary")
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

# Data Platforms with R

**From scripts to governed data products with DataRaft**

This directory contains the Quarto source, runnable local case study, architecture diagrams, repository audit, and reproducible build configuration for the DataRaft companion book.

## What is in this edition

- 22 chapters in seven parts plus eight appendices
- one continuous synthetic insurance example
- a runnable local platform project in `examples/insurance-platform/`
- source-controlled Graphviz diagrams with checked-in SVG renders
- exact DataRaft source revisions in `AUDIT.md`
- CI that installs those pinned revisions, runs the example tests, and renders HTML/PDF with Quarto
- a Pandoc/LibreOffice fallback for environments without R or Quarto

## Native Quarto build

Requirements:

- Quarto 1.9 or newer
- R 4.2 or newer
- the DataRaft packages used by executable examples

Install the audited package revisions and verify the example project:

```sh
Rscript scripts/install-dataraft.R
Rscript scripts/verify-examples.R
```

Then render:

```sh
quarto render
```

The HTML book is the primary format. PDF is also configured.

## Runnable companion project

The complete local case study is in `examples/insurance-platform/`.

```sh
Rscript examples/insurance-platform/run.R
```

It uses the synthetic CSV files in `data/`, runs a multi-product dependency graph, checks the final result, and publishes a versioned local RDS release. It requires no external credentials or services.

## Fallback build

When Quarto or R is unavailable:

```sh
bash scripts/build-fallback.sh
```

The fallback concatenates the QMD sources, uses the checked-in static SVG diagrams, applies citations with Pandoc, creates HTML and DOCX, and converts the DOCX to PDF with LibreOffice. It does **not** execute R code, so it proves manuscript renderability rather than DataRaft execution.

## Source of truth

Read `AUDIT.md` for package status, supported backends, implementation boundaries, and the exact source revisions used for this edition.

`BOOK_THESIS.md` records the editorial thesis and central mental model. `LEARNING_MAP.md` records the chapter dependency path.
## Published location

The book is maintained in `book/` of the `dataraft-r/dataraft` repository and is published with the main documentation site at:

`https://dataraft-r.github.io/dataraft/book/`

The source tree remains self-contained so it can be moved into a dedicated repository later without changing the chapter structure.


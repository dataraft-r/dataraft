repos <- c(
  "dataraft-r/dataraft.core@d9cb454d0b60a7d1ba23ff7298b064f16af80c05",
  "dataraft-r/dataraft.adapters@87a39686af0bafa40e64f9130a3ef2877ed64423",
  "dataraft-r/dataraft.lake@113c17913fe326145b285a6c5720a0753a207b2c",
  "dataraft-r/dataraft@1053863d0c3eb94f5d8356c59a4cb1701e700991"
)

pak::pak(c(
  repos,
  "testthat",
  "withr",
  "knitr",
  "rmarkdown"
))

# Exercise the exact script offered by the website, including catalog construction.
options(dataraft.training = list(lake = TRUE, install_extensions = TRUE))
source("website/content/training/dataraft_training.R", echo = FALSE)
dir.create("check", showWarnings = FALSE)
utils::write.csv(
  training_summary,
  "check/training-summary.csv",
  row.names = FALSE
)
main <- training_summary[startsWith(training_summary$section, "H"), ]
stopifnot(all(sprintf("H%02d", 1:39) %in% main$section))
if (any(main$status != "ok")) {
  print(main[main$status != "ok", ])
  stop(
    "Every main-path course step must execute successfully; skips are failures."
  )
}
cat(nrow(main), "main-path course steps passed.\n")

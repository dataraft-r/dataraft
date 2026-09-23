# How to use this course ----
# Each main-path step takes about 5-10 minutes. Longer modules are split into smaller substeps.
# Stop whenever you have learned enough for today.
# H01-H24 start locally; H25-H39 cover the lake and reporting; E modules are manual editor
# exercises; V modules are optional deep dives. Prerequisites appear before each block.
# Default: local exercises run if their packages are installed. Packages and database extensions
# are never installed automatically. DuckLake, GUI and external services are initially disabled.
# Set options BEFORE running the script, for example:
# options(dataraft.training = list(lake = TRUE, extras = TRUE))
# options(dataraft.training = list(lake = TRUE, install_extensions = TRUE))
# Available switches: lake, extras, gui, dbt, api, catalogs, postgres, s3, iceberg,
# install_extensions. Enable only prepared integrations. V25 offers a separate offline DuckDB
# alternative.
# Install optional components only when needed: adapters for persistence; metrics for metrics;
# lake for DuckLake; ide for the extension; dbt for dbt. dataraft.catalog is not needed. Exact
# source commits appear at the end. Install components analogously to the core setup, with
# Depends/Imports/LinkingTo only, in order: core, lake, metrics, dbt, adapters, ide. Use a
# coordinated version set.
# For durable course output, set options(dataraft.training_root = "~/dataraft-training"). Each
# full run gets a new subdirectory. Without this option, files go into tempdir() and may
# disappear after the session. Use training resources only; do not put credentials in this
# script.
# Try each task before reading its solution. Keep experiments in new objects. training_step is a
# COURSE HELPER, not a DataRaft API. It skips disabled or missing prerequisites, retains objects
# in the course workspace and records results. Local errors stop; optional errors are recorded
# and dependent exercises are skipped.


# DataRaft step by step ----
# Complete course: H01-H39, E01-E15, V01-V25. Source and test snapshot: September 23, 2026.
# English website edition.
# Open this file in Positron and execute sections from top to bottom. Read the explanation, run
# the small block, inspect the result and try the task. Section marks support navigation in the
# editor outline. You need basic R knowledge: assignment, function calls and tables. No lake or
# extension is needed at the beginning.
# H01-H11 create R objects only. Data is synthetic and reproducible. A complete rerun resets the
# named course objects; use a separate R session.
# Underlying code validation: H01-H24, H34 and H38 executed in a fresh R session. H25-H39 also
# executed with DuckDB 1.5.5 and DuckLake. Report integrity, environment and replay checks
# returned match.
# Local deep dives executed with pointblank, Excel, SQLite, Parquet, pins and targets; the dbt
# starter including contract and publication was executed. The API adapter was checked against a
# local HTTP fixture. E-module R preparation was executed, but no actual Positron click tests
# were performed for this course.
# Not tested end to end: PostgreSQL, S3, OpenLineage, OpenMetadata, Iceberg, the two-process
# writing experiment and a custom dbt transformation project.
# Original test environment: R 4.5.3, dm 1.1.2.9017, dplyr 1.2.1, dbt-core 1.12.5, dbt-duckdb
# 1.11.0. All DataRaft components were 0.1.0.9005; exact SHAs appear below. An earlier base test
# also used R 4.4.3. Translation preserves the executable exercises apart from English display
# labels and messages.
# Follow data, product definition, run result and explicit contract first. Then add quality,
# recipes, persistence, customers and brokers, metrics, DuckLake, the extension and optional
# integrations.


# 00 Optional setup: only for missing packages ----
# These installation commands are deliberately commented out. Run them separately only when
# needed, then restart R. They require internet access; some dependencies need binaries or build
# tools.
# install.packages("remotes", repos = "https://cloud.r-project.org")
# remotes::install_github(
#   "dataraft-r/dataraft.core@67e4ac9d2c7e506253d9dde733787372003f2d19",
#   dependencies = c("Depends", "Imports", "LinkingTo"),
#   upgrade = "never", build_vignettes = FALSE
# )
# Only core and its required dependencies are needed initially. Optional family packages and
# their Remotes are not requested here. This commented remotes installation path was not
# executed during validation; pinned sources were installed locally for the tests.


# 00 Preparation: load the package ----
# Check the R and package versions before starting. The pinned core version is 0.1.0.9005. Newer
# versions may differ, so keep the result checks.
if (getRversion() < "4.2.0") {
  stop("This course requires R >= 4.2.0.", call. = FALSE)
}
if (!requireNamespace("dataraft.core", quietly = TRUE)) {
  stop("dataraft.core is missing. Run the optional setup first.", call. = FALSE)
}
if (utils::packageVersion("dataraft.core") < "0.1.0.9005") {
  stop("Please update dataraft.core to at least 0.1.0.9005.", call. = FALSE)
}
library(dataraft.core)
utils::packageVersion("dataraft.core")

# H01 Understand a small policy delivery ----
# Goal: Recognize the three columns of our first dataset.
# Prerequisites: Setup complete.
#
# Each row represents an insurance policy. policy_id is its unique integer identifier; premium
# is a synthetic monthly amount in EUR. cancelled marks a cancellation. Dates and the precise
# rate definition come later, so this flag alone is not a KPI.
policies <- data.frame(
  policy_id = 1:6,
  premium = c(100, 150, 80, 200, 120, 90),
  cancelled = c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
)
print(policies)

stopifnot(nrow(policies) == 6L, sum(policies$premium) == 740)
stopifnot(identical(policies$policy_id, 1:6), sum(policies$cancelled) == 1L)
# Expected result: Six rows and three columns; policy 3 is marked as cancelled.
# Task: How many policies are marked, and what is the total premium? Try sum(policies$cancelled)
# and sum(policies$premium).
# Solution: One policy and EUR 740. The silent stopifnot checks confirm the result. Next, give
# this table a reusable product definition.

# H02 Turn data into a product definition ----
# Goal: Distinguish data from a reusable definition.
# Prerequisites: policies from H01.
#
# dr_product assigns an identity and source. Rules, preparation and a target can be added later.
# Constructing or inspecting a product does not execute it. A product ID is not a file path.
policy_product <- dr_product("policies", data = policies)
product_info <- dr_inspect(policy_product)
print(product_info[c("id", "status", "sources")])

stopifnot(identical(product_info$id, "policies"))
stopifnot(identical(product_info$status, "defined"))
# Expected result: The inspection shows id policies, status defined and a table source.
# Task: Have we saved a file or checked whether premiums are sensible?
# Solution: Neither. We have described a product with a local source. Next, execute that
# definition.

# H03 Run without saving data ----
# Goal: Distinguish a product, a run result and an output table.
# Prerequisites: policy_product from H02.
#
# dr_run(write=FALSE) reads the source and runs configured preparation and checks, while
# suppressing DataRaft target and evidence writes. Sources and custom callbacks still execute
# and can have their own side effects. dr_collect retrieves the output.
policy_run <- dr_run(policy_product, write = FALSE)
print(policy_run)
policy_rows <- dr_collect(policy_run)
print(policy_rows)

stopifnot(identical(policy_run$status, "completed"))
stopifnot(identical(policy_run$validation_status, "unvalidated"))
stopifnot(isTRUE(all.equal(as.data.frame(policy_rows), policies)))
# Expected result: Status completed and six unchanged rows. Without an explicit contract,
# validation is unvalidated; completion alone does not prove business quality.
# Task: Which object is the definition, which holds run status, and which is a table?
# Solution: policy_product, policy_run and policy_rows respectively. Next, declare the expected
# structure.

# H04 Agree on columns and keys ----
# Goal: Express the expected table structure as a contract.
# Prerequisites: H02 and H03.
#
# A contract declares names, types and a key. integer means whole numbers, numeric means
# numerical values, and logical means TRUE/FALSE. policy_id must be unique and nonmissing. This
# version defaults to required columns, nonmissing values and no extra columns. None of this
# establishes a sensible premium.
policy_contract <- dr_contract(
  "policies.contract",
  columns = c(policy_id = "integer", premium = "numeric", cancelled = "logical"),
  key = "policy_id"
)
policy_product <- dr_add_contract(policy_product, policy_contract)
policy_run <- dr_run(policy_product, write = FALSE)
policy_rows <- dr_collect(policy_run)
print(policy_contract)
print(policy_run)

stopifnot(identical(policy_run$status, "completed"))
stopifnot(identical(policy_run$validation_status, "passed"))
stopifnot(isTRUE(all.equal(as.data.frame(policy_rows), policies)))
# Expected result: Three columns, key policy_id, run status completed and validation passed. The
# six rows are unchanged.
# Task: Would a negative premium fail this contract? Could policy_id contain a duplicate?
# Solution: A negative number is still numeric, so it needs a business rule. A duplicate key
# fails. Add the business rule next.

# Course runner for the following modules ----
# Run this after H04. It creates a fresh course directory, applies your opt-in switches and
# defines training_step. The helper checks prerequisites before evaluating code in the current
# course workspace. A skipped step is not a successful test.
training_options <- utils::modifyList(list(
  lake = FALSE, extras = FALSE, gui = FALSE, dbt = FALSE, api = FALSE,
  catalogs = FALSE, postgres = FALSE, s3 = FALSE, iceberg = FALSE,
  install_extensions = FALSE
), getOption("dataraft.training", list()))
training_parent <- path.expand(getOption("dataraft.training_root", tempdir()))
dir.create(training_parent, recursive = TRUE, showWarnings = FALSE)
training_root <- tempfile("dataraft-course-", tmpdir = training_parent)
dir.create(training_root, recursive = TRUE)
message("Your course directory: ", training_root)
training_log <- new.env(parent = emptyenv())
for (id in sprintf("H%02d", 1:4)) training_log[[id]] <- "ok"
training_step <- function(id, code, needs = character(), packages = character(),
                          enabled = TRUE, optional = FALSE) {
  reason <- if (!isTRUE(enabled)) "disabled" else NULL
  if (is.null(reason) && length(needs)) {
    missing <- needs[!vapply(needs, function(x) identical(training_log[[x]], "ok"), logical(1))]
    if (length(missing)) reason <- paste("Missing prerequisite:", paste(missing, collapse = ", "))
  }
  if (is.null(reason) && length(packages)) {
    missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
    if (length(missing)) reason <- paste("Missing package:", paste(missing, collapse = ", "))
  }
  if (!is.null(reason)) {
    training_log[[id]] <- paste("skipped:", reason)
    message(id, " | ", training_log[[id]])
    return(invisible(NULL))
  }
  expr <- substitute(code)
  scope <- parent.frame()
  tryCatch({
    eval(expr, envir = scope)
    training_log[[id]] <- "ok"
    message(id, " | completed")
  }, error = function(e) {
    training_log[[id]] <- paste("Error:", conditionMessage(e))
    if (!optional) stop(id, ": ", conditionMessage(e), call. = FALSE)
    message(id, " | ", training_log[[id]])
  })
  invisible(NULL)
}

# H05 Add a business rule ----
# Goal: Require nonnegative premiums.
# Prerequisites: H04 and the course runner immediately after H04.
#
# The contract checks structure. The named rule checks business content. Extend the definition,
# then run it again.
training_step("H05", {
  policy_product <- dr_add_quality(policy_product, list(nonnegative = ~ premium >= 0))
  policy_run <- dr_run(policy_product, write = FALSE)
  print(dr_quality_report(policy_run))
  stopifnot(policy_run$validation_status == "passed")
}, needs = c("H04"))
# Expected result: All configured checks pass.
# Task: Is zero allowed?
# Solution: Yes: the rule is >= 0, not > 0. Next, introduce a bad delivery.

# H06 Inspect a failed delivery ----
# Goal: Find the exact failing row.
# Prerequisites: H05.
#
# stop_on_failure=FALSE returns a blocked run that you can inspect. Do not collect a blocked run
# with dr_collect.
training_step("H06", {
  bad_policies <- policies
  bad_policies$premium[2] <- -150
  failed_run <- dr_run(policy_product, data = bad_policies, write = FALSE, stop_on_failure = FALSE)
  print(dr_quality_report(failed_run))
  print(dr_quality_rows(failed_run))
  last_failure <- dr_last_failure()
  stopifnot(failed_run$status == "blocked", last_failure$run_id == failed_run$run_id)
}, needs = c("H05"))
# Expected result: Policy 2 violates nonnegative; the course continues.
# Task: In a copy, also give policy 4 a negative premium.
# Solution: Two rows now fail. Keep failed_run as the original single-row example for later
# exercises.

# H07 Correct data without redefining the product ----
# Goal: Replace a source while keeping its rules.
# Prerequisites: H06.
#
# The source name policies comes from the original product ID. Requirements remain attached
# while the source is replaced.
training_step("H07", {
  corrected_policies <- bad_policies
  corrected_policies$premium[2] <- 150
  policy_product <- dr_set_sources(policy_product, policies = corrected_policies)
  policy_run <- dr_run(policy_product, write = FALSE)
  print(dr_collect(policy_run))
  stopifnot(policy_run$validation_status == "passed")
}, needs = c("H06"))
# Expected result: Six accepted policies.
# Task: Did we have to rewrite the rule?
# Solution: No. Sources and requirements are separate. Next, add preparation.

# H08 Define a recipe ----
# Goal: Store preparation as a reusable object.
# Prerequisites: H07.
#
# A recipe is an ordered sequence of transformations. Constructing it does not execute it.
training_step("H08", {
  rounding_recipe <- dr_recipe() |> dr_step_mutate(premium = round(premium, 2))
  print(rounding_recipe)
  precise_policies <- policies
  precise_policies$premium[1] <- 100.126
}, needs = c("H07"))
# Expected result: A recipe containing a mutate step.
# Task: What should 100.126 become?
# Solution: 100.13. We check that during execution in H09.

# H09 Attach a recipe to a product ----
# Goal: Compose a definition and inspect its plan.
# Prerequisites: H08.
#
# Attach the recipe directly to the product. There is no need for an empty workflow builder.
training_step("H09", {
  prepared_product <- policy_product |> dr_add_recipe(rounding_recipe)
  print(dr_plan(prepared_product))
  prepared_run <- dr_run(prepared_product, data = precise_policies, write = FALSE)
  prepared_rows <- dr_collect(prepared_run)
  print(prepared_rows)
  stopifnot(prepared_rows$premium[1] == 100.13, policies$premium[1] == 100)
}, needs = c("H08"))
# Expected result: Rounded output; the original delivery remains unchanged.
# Task: When are product checks applied?
# Solution: They check the prepared candidate. Separate RAW input checks come later.

# H10 Select rows ----
# Goal: Create a deliberate subset.
# Prerequisites: H09.
#
# Use a separate product variant so the complete portfolio remains available for metrics.
training_step("H10", {
  active_recipe <- rounding_recipe |> dr_step_filter(!cancelled)
  active_product <- policy_product |> dr_add_recipe(active_recipe)
  active_rows <- dr_collect(dr_run(active_product, write = FALSE))
  print(active_rows)
  stopifnot(nrow(active_rows) == 5L)
}, needs = c("H09"))
# Expected result: Five rows, excluding the marked policy.
# Task: Can this subset alone give us a cancellation rate?
# Solution: No: it excludes cancellations. Later we return to the full population.

# H11 Select columns ----
# Goal: Deliberately narrow the output.
# Prerequisites: H10.
#
# A strict contract must match the output. Create a separate two-column product rather than
# silently violating the original contract.
training_step("H11", {
  small_recipe <- dr_recipe() |> dr_step_select(policy_id, premium)
  small_contract <- dr_contract("policy.amounts", c(policy_id = "integer", premium = "numeric"), key = "policy_id")
  small_product <- dr_product("policy.amounts", policies, contract = small_contract) |> dr_add_recipe(small_recipe)
  small_rows <- dr_collect(dr_run(small_product, write = FALSE))
  print(small_rows)
  stopifnot(identical(names(small_rows), c("policy_id", "premium")))
}, needs = c("H10"))
# Expected result: Six rows and two columns.
# Task: What would happen with the original three-column contract?
# Solution: The missing cancelled column would block the run. Next, save the complete product.

# H12 Configure a local target ----
# Goal: Describe storage without writing.
# Prerequisites: H09; dataraft.adapters.
#
# The RDS adapter manages versions in a directory. Its constructor only describes the target.
training_step("H12", {
  rds_path <- file.path(training_root, "policies-rds")
  rds_target <- dataraft.adapters::dr_target_rds(rds_path)
  rds_product <- prepared_product |> dr_set_target(rds_target)
  rds_trial <- dr_run(rds_product, write = FALSE)
  stopifnot(!dir.exists(rds_path))
  print(rds_trial)
}, needs = c("H09"), packages = c("dataraft.adapters"))
# Expected result: The check-only run creates no output directory.
# Task: Why explicitly set write=FALSE?
# Solution: Otherwise dr_run can execute the configured target.

# H13 Save checked data ----
# Goal: Create the first persistent local output.
# Prerequisites: H12.
#
# dr_publish requires a target and writes after successful checks.
training_step("H13", {
  rds_first <- dr_publish(rds_product)
  print(rds_first$outputs)
  stopifnot(dir.exists(rds_path))
}, needs = c("H12"))
# Expected result: Output metadata includes an RDS version.
# Task: Where is the output?
# Solution: Under policies-rds in the printed training_root. Read that exact version next.

# H14 Read saved data ----
# Goal: Use a fixed output version as a source.
# Prerequisites: H13.
#
# An explicit version pins the data. Omitting it would read the current version.
training_step("H14", {
  rds_source <- dataraft.adapters::dr_source_rds(rds_path, version = rds_first$outputs$version)
  reloaded_product <- dr_product("policies.reloaded", rds_source, contract = policy_contract)
  reloaded_rows <- dr_collect(dr_run(reloaded_product, write = FALSE))
  print(reloaded_rows)
  stopifnot(sum(reloaded_rows$premium) == 740)
}, needs = c("H13"))
# Expected result: The original premium total is still 740.
# Task: What happens to this source after another delivery?
# Solution: It stays pinned to the first version. Test that next.

# H15 Process a second delivery ----
# Goal: Distinguish old and new versions.
# Prerequisites: H14.
#
# Change one value and reuse the same product definition.
training_step("H15", {
  second_policies <- policies
  second_policies$premium[1] <- 110
  rds_second <- dr_run(rds_product, data = second_policies)
  old_rows <- dr_collect(dr_run(reloaded_product, write = FALSE))
  latest_source <- dataraft.adapters::dr_source_rds(rds_path)
  latest_rows <- dr_collect(dr_run(dr_product("latest", latest_source), write = FALSE))
  stopifnot(sum(old_rows$premium) == 740, sum(latest_rows$premium) == 750)
  print(c(old = sum(old_rows$premium), latest = sum(latest_rows$premium)))
}, needs = c("H14"))
# Expected result: The old total is 740; the current total is 750.
# Task: Is a version the same thing as a business month?
# Solution: No. Multiple technical versions can correct the same business period.

# H16a Add a customer table ----
# Goal: Prepare a shared key.
# Prerequisites: H07.
#
# Add IDs in a new delivery variant. Each of three customers holds two policies.
training_step("H16a", {
  customers <- data.frame(customer_id = 1:3, region = c("North", "South", "West"))
  linked_policies <- policies
  linked_policies$customer_id <- c(1L, 1L, 2L, 2L, 3L, 3L)
  linked_policies$broker_id <- c(1L, 2L, 1L, 2L, 1L, 2L)
  print(customers)
}, needs = c("H07"))
# Expected result: Three unique customer IDs.
# Task: Why keep regions in a separate customer table?
# Solution: Customer attributes can be maintained independently and added by lookup.

# H16 Look up customers ----
# Goal: Enrich data through a checked relationship.
# Prerequisites: H16a.
#
# The output contract includes the added region. The dm-based lookup checks the key
# relationship.
training_step("H16", {
  linked_contract <- dr_contract("policies.linked", c(policy_id="integer", premium="numeric", cancelled="logical", customer_id="integer", broker_id="integer", region="character"), key="policy_id")
  customer_recipe <- dr_recipe() |> dr_step_lookup(customers, by = "customer_id")
  customer_product <- dr_product("policies.linked", linked_policies, contract = linked_contract) |> dr_add_recipe(customer_recipe)
  customer_rows <- dr_collect(dr_run(customer_product, write = FALSE))
  print(customer_rows)
  stopifnot(nrow(customer_rows) == 6L)
}, needs = c("H16a"))
# Expected result: Six policies with regions.
# Task: What should happen for an unknown customer_id?
# Solution: The default unmatched=error blocks the lookup instead of silently losing the
# relationship.

# H17 Look up brokers ----
# Goal: Add a second attribute.
# Prerequisites: H16.
#
# Extend the same recipe approach and revise the output contract.
training_step("H17", {
  brokers <- data.frame(broker_id = 1:2, broker_name = c("Makler A", "Makler B"))
  enriched_contract <- dr_contract_update(linked_contract, version = "2.0.0", columns = c(broker_name = "character"))
  enrichment_recipe <- customer_recipe |> dr_step_lookup(brokers, by = "broker_id")
  enriched_product <- dr_product("policies.enriched", linked_policies, contract = enriched_contract) |> dr_add_recipe(enrichment_recipe)
  enriched_rows <- dr_collect(dr_run(enriched_product, write = FALSE))
  print(enriched_rows)
  stopifnot(nrow(enriched_rows) == 6L, !anyNA(enriched_rows$broker_name))
}, needs = c("H16"))
# Expected result: Broker names without multiplying rows.
# Task: Why is a duplicate broker_id in brokers a problem?
# Solution: It could duplicate a policy. The checked lookup protects this relationship.

# H18 Define a relational model ----
# Goal: Describe tables and their relationships together.
# Prerequisites: H17; dm is a core dependency.
#
# A dm model retains multiple tables. It does not automatically flatten them into one output
# table.
training_step("H18", {
  portfolio_model <- dm::dm(policies = linked_policies, customers = customers, brokers = brokers) |>
    dm::dm_add_pk(policies, policy_id) |>
    dm::dm_add_pk(customers, customer_id) |>
    dm::dm_add_pk(brokers, broker_id) |>
    dm::dm_add_fk(policies, customer_id, customers) |>
    dm::dm_add_fk(policies, broker_id, brokers)
  print(portfolio_model)
}, needs = c("H17"))
# Expected result: Three tables and two foreign-key relationships.
# Task: Which table holds the region?
# Solution: customers. The model preserves that normalized structure.

# H19 Check a model as a product ----
# Goal: Validate relationships together.
# Prerequisites: H18.
#
# dr_model_product binds a dm model. The failure exercise replaces just one member table.
training_step("H19", {
  model_product <- dr_model_product("portfolio", portfolio_model)
  model_run <- dr_run(model_product, write = FALSE)
  print(dr_collect(model_run))
  orphan_run <- dr_run(model_product, sources = list(customers = customers[1:2, ]), write = FALSE, stop_on_failure = FALSE)
  print(dr_quality_report(orphan_run))
  stopifnot(model_run$status == "completed", orphan_run$status == "blocked")
}, needs = c("H18"))
# Expected result: The complete model runs; removing customer 3 breaks the relationship. Without
# explicit table contracts this is not complete business validation.
# Task: Which policies are affected?
# Solution: Policies 5 and 6 refer to customer 3.

# H20 Reuse one model table ----
# Goal: Select a member table deliberately.
# Prerequisites: H19.
#
# The table argument selects one table from a successful model result.
training_step("H20", {
  selected_product <- dr_product("portfolio.policies", model_run, table = "policies")
  selected_run <- dr_run(selected_product, write = FALSE)
  selected_rows <- dr_collect(selected_run)
  print(selected_rows)
  stopifnot(nrow(selected_rows) == 6L)
}, needs = c("H19"))
# Expected result: Six policies with customer and broker IDs.
# Task: Have we lost the dm model?
# Solution: No. model_run is still available; the new product is a selected view.

# H21a Define the period and population ----
# Goal: State the business meaning before calculating.
# Prerequisites: H20.
#
# Teaching convention: August 2026. The denominator is policies active on August 1. The
# numerator is cancellations among those policies after August 1 and through August 31
# inclusive. A policy already terminated on August 1 is excluded. New business during August is
# excluded. This is a simplified teaching definition.
training_step("H21a", {
  dated_policies <- selected_rows
   dated_policies$start_date <- as.Date(rep("2026-01-01", 6))
  dated_policies$cancel_date <- as.Date(c(NA, NA, "2026-08-15", NA, NA, NA))
  period_start <- as.Date("2026-08-01")
  period_end <- as.Date("2026-08-31")
  print(dated_policies)
}, needs = c("H20"))
# Expected result: Six policies in the opening population and one cancellation date.
# Task: Why is cancelled alone insufficient?
# Solution: Without a date, the period of the cancellation is unknown.

# H21 Prepare numerator and denominator ----
# Goal: Calculate two explicit indicators.
# Prerequisites: H21a.
#
# The recipe makes business logic visible before defining a metric. Its output has a dedicated
# contract.
training_step("H21", {
  cohort_recipe <- dr_recipe() |>
    dr_step_mutate(in_opening = start_date <= period_start & (is.na(cancel_date) | cancel_date > period_start)) |>
    dr_step_mutate(in_cancellations = in_opening & !is.na(cancel_date) & cancel_date <= period_end)
  cohort_contract <- dr_contract("cohort", c(policy_id="integer", premium="numeric", cancelled="logical", customer_id="integer", broker_id="integer", start_date="Date", cancel_date="Date", in_opening="logical", in_cancellations="logical"), key="policy_id") |>
    dr_contract_policy(required = c("policy_id", "premium", "customer_id", "broker_id", "start_date", "in_opening", "in_cancellations"))
  cohort_product <- dr_product("policies.cohort", dated_policies, contract=cohort_contract) |> dr_add_recipe(cohort_recipe) |> dr_add_quality(list(nonempty_denominator=~ sum(in_opening) > 0))
  cohort_run <- dr_run(cohort_product, write=FALSE)
  cohort_rows <- dr_collect(cohort_run)
  stopifnot(sum(cohort_rows$in_opening)==6L, sum(cohort_rows$in_cancellations)==1L)
}, needs = c("H21a"))
# Expected result: Denominator 6 and numerator 1. cancel_date may be missing for ongoing
# policies.
# Task: What happens to a policy starting on August 10?
# Solution: in_opening is FALSE. Try it in a copy and preserve the original data.

# H22 Define the cancellation rate ----
# Goal: Create a reusable metric.
# Prerequisites: H21; dataraft.metrics.
#
# The metric references the product ID. The product rule nonempty_denominator already blocks an
# empty population, rather than reporting a zero rate. Initially the metric is exploratory and
# not approved for frozen reports.
training_step("H22", {
  cancellation_metric <- dataraft.metrics::dr_metric(
    "policies.cancellation_rate", "policies.cohort",
    expr = sum(in_cancellations) / sum(in_opening),
    dimensions = "broker_id", unit = "ratio", approved = FALSE
  )
  print(cancellation_metric)
}, needs = c("H21"), packages = c("dataraft.metrics"))
# Expected result: A definition with broker_id as an allowed grouping dimension.
# Task: Has defining the metric calculated it?
# Solution: No. dr_measure executes it.

# H23 Calculate the rate locally ----
# Goal: Reproduce the hand calculation.
# Prerequisites: H22.
#
# A successful in-memory run supports exploratory measurement, but not an approved frozen
# report.
training_step("H23", {
  local_rate <- dataraft.metrics::dr_measure(cohort_run, cancellation_metric, by = character())
  print(local_rate)
  stopifnot(isTRUE(all.equal(local_rate$value, 1/6)))
}, needs = c("H22"))
# Expected result: A ratio of 0.1666667, or about 16.67 percent.
# Task: Why not multiply by 100 in the definition?
# Solution: Keeping unit ratio makes the meaning explicit; percentage formatting can be
# separate.

# H23a Handle an empty opening population ----
# Goal: Prevent a rate without a valid denominator.
# Prerequisites: H21; do not collect a metric from a blocked run.
#
# A population with no eligible policies cannot support this rate. Run the counterexample, then
# return to cohort_run.
training_step("H23a", {
  no_opening_data <- dated_policies
  no_opening_data$start_date <- as.Date("2026-08-10")
  no_opening_run <- dr_run(cohort_product, data=no_opening_data, write=FALSE, stop_on_failure=FALSE)
  print(dr_quality_report(no_opening_run))
  stopifnot(no_opening_run$status=="blocked")
}, needs=c("H21"))
# Expected result: nonempty_denominator blocks output.
# Task: Why would zero be misleading?
# Solution: It would suggest an observed population with no cancellations. Here the opening
# population is absent.

# H24 Group by broker ----
# Goal: Reuse a metric with a different grouping.
# Prerequisites: H23.
#
# dimensions permits a dimension; by selects it for this measurement.
training_step("H24", {
  broker_rates <- dataraft.metrics::dr_measure(cohort_run, cancellation_metric, by = "broker_id")
  print(broker_rates)
  stopifnot(nrow(broker_rates) == 2L)
  stopifnot(isTRUE(all.equal(sort(broker_rates$value), c(0, 1/3))))
}, needs = c("H23"))
# Expected result: Broker 1 has a rate of 1/3; broker 2 has 0.
# Task: Can subgroup rates always be averaged directly?
# Solution: No. Different populations require denominator weighting or reaggregation of
# numerator and denominator.

# H25 Configure a local DuckLake ----
# Goal: Separate metadata from data-file storage.
# Prerequisites: lake=TRUE; dataraft.lake.
#
# DuckDB is the execution engine. DuckLake manages tables through a metadata catalog and data
# files. The local path shorthand defaults to DuckDB without an explicit backend. This creates a
# new DuckLake; it does not migrate an existing DuckDB directory.
training_step("H25", {
  lake_config <- dataraft.lake::dr_lake_config(
    path = file.path(training_root, "ducklake"), backend = "ducklake",
    install_extensions = training_options$install_extensions
  )
  print(lake_config)
}, packages = c("dataraft.lake"), enabled = training_options$lake, optional = TRUE)
# Expected result: Configuration only, with no open connection.
# Task: Where will the data live?
# Solution: Inside the course directory. PostgreSQL and S3 are separate later variants.

# H26 Connect, close and reconnect ----
# Goal: Understand a connection lifecycle.
# Prerequisites: H25; duckdb >=1.5.5; bit64; available DuckLake extension.
#
# A missing extension is installed only when install_extensions is explicitly enabled. If this
# optional setup fails, dependent lake exercises are skipped.
training_step("H26", {
  stopifnot(utils::packageVersion("duckdb") >= "1.5.5")
  training_lake <- dataraft.lake::dr_connect_lake(lake_config)
  print(training_lake)
  dataraft.lake::dr_disconnect_lake(training_lake)
  training_lake <- dataraft.lake::dr_connect_lake(lake_config)
  stopifnot(DBI::dbIsValid(training_lake$con))
}, needs = c("H25"), packages = c("duckdb", "bit64"), enabled = training_options$lake, optional = TRUE)
# Expected result: The reopened lake has a valid connection.
# Task: Does closing delete the data?
# Solution: No. It closes the connection, not the lake.

# H27 Publish the same product to the lake ----
# Goal: Change only the destination.
# Prerequisites: H09 and H26.
#
# Reuse the product, contract and recipe. The lake adds managed releases.
training_step("H27", {
  lake_product <- prepared_product |> dr_set_target(dataraft.lake::dr_target_lake(training_lake))
  lake_first <- dr_publish(lake_product, business_date = "2026-08-31")
  print(lake_first)
  stopifnot(lake_first$status == "published")
}, needs = c("H09", "H26"), enabled = training_options$lake, optional = TRUE)
# Expected result: A published release with a fixed ID.
# Task: Which business definition did we rewrite?
# Solution: None. We changed the storage destination.

# H28 Read a specific release ----
# Goal: Distinguish a pinned release from the current one.
# Prerequisites: H27.
#
# An explicit release ID prevents an unintended switch to newer data.
training_step("H28", {
  print(dataraft.lake::dr_releases(training_lake, "policies"))
  first_lake_rows <- dataraft.lake::dr_read_release(training_lake, "policies", release=lake_first$release_id)
  print(first_lake_rows)
  stopifnot(sum(first_lake_rows$premium) == 740)
}, needs = c("H27"), enabled = training_options$lake, optional = TRUE)
# Expected result: The first delivery still totals 740.
# Task: Which is stable: latest or an explicit ID?
# Solution: The ID. latest is a moving selection.

# H29 Compare deliveries ----
# Goal: Retain a deliberate data change in history.
# Prerequisites: H28.
#
# The comparison uses policy_id as the business key.
training_step("H29", {
  lake_second_data <- policies
  lake_second_data$premium[1] <- 110
  lake_second <- dr_publish(lake_product, data=lake_second_data, business_date="2026-08-31")
  lake_difference <- dataraft.lake::dr_compare(lake_first, lake_second, key="policy_id")
  print(lake_difference)
  stopifnot(sum(dr_collect(lake_second)$premium) == 750)
}, needs = c("H28"), enabled = training_options$lake, optional = TRUE)
# Expected result: Policy 1 changed; the new total is 750.
# Task: Why do both runs have the same business_date?
# Solution: They are different delivery versions for the same business date.

# H30 Publish a correction ----
# Goal: Name the expected previous release.
# Prerequisites: H29.
#
# previous protects a correction against an unexpectedly changed starting release.
training_step("H30", {
  lake_correction_data <- lake_second_data
  lake_correction_data$premium[1] <- 105
  lake_corrected <- dr_publish(lake_product, data=lake_correction_data, previous=lake_second, business_date="2026-08-31")
  print(dataraft.lake::dr_compare(lake_second, lake_corrected, key="policy_id"))
  stopifnot(sum(dr_collect(lake_first)$premium)==740, sum(dr_collect(lake_corrected)$premium)==745)
}, needs = c("H29"), enabled = training_options$lake, optional = TRUE)
# Expected result: The correction totals 745; the first version remains 740.
# Task: Does a correction overwrite a historical release?
# Solution: No. It creates another traceable version.

# H31 Check raw data at ingestion ----
# Goal: Distinguish received input from accepted RAW data.
# Prerequisites: H26 and H06.
#
# dr_ingest archives the incoming delivery and checks before RAW publication. Archiving does not
# mean acceptance.
training_step("H31", {
  raw_accepted <- dataraft.lake::dr_ingest(policies, to=training_lake, name="policies.raw", contract=policy_contract, quality=~ premium >= 0)
  raw_rejected <- dataraft.lake::dr_ingest(bad_policies, to=training_lake, name="policies.raw", contract=policy_contract, quality=~ premium >= 0, stop_on_failure=FALSE)
  print(dr_quality_report(raw_rejected))
  stopifnot(raw_accepted$status=="published", raw_rejected$status=="blocked")
  stopifnot(sum(dr_collect(raw_accepted)$premium)==740)
}, needs = c("H26", "H06"), enabled = training_options$lake, optional = TRUE)
# Expected result: Only the valid delivery is accepted.
# Task: How does this differ from H09?
# Solution: This checks before RAW publication; H09 checks a prepared product.

# H32 Build on checked releases ----
# Goal: Use a fixed RAW dependency.
# Prerequisites: H31.
#
# The source references the exact accepted input. A derived product can add transformations.
training_step("H32", {
  raw_source <- dataraft.lake::dr_source_release(training_lake, "policies.raw", raw_accepted$release_id)
  clean_product <- dr_product("policies.clean", raw_source, contract=policy_contract) |> dr_add_recipe(rounding_recipe)
  clean_release <- dr_publish(clean_product, to=training_lake)
  print(dr_collect(clean_release))
  stopifnot(sum(dr_collect(clean_release)$premium)==740)
}, needs = c("H31", "H08"), enabled = training_options$lake, optional = TRUE)
# Expected result: A derived release with a source in the RAW layer.
# Task: What changes for a newer delivery?
# Solution: Bind the source to that delivery's accepted release ID.

# H33a Publish three member tables ----
# Goal: Store the model building blocks.
# Prerequisites: H26 and H18.
#
# Use separate asset IDs for the relational member tables.
training_step("H33a", {
  model_policy_release <- dr_publish(dr_product("model.policies", linked_policies), to=training_lake)
  model_customer_release <- dr_publish(dr_product("model.customers", customers), to=training_lake)
  model_broker_release <- dr_publish(dr_product("model.brokers", brokers), to=training_lake)
  print(c(policies=model_policy_release$release_id, customers=model_customer_release$release_id, brokers=model_broker_release$release_id))
}, needs = c("H26", "H18"), enabled = training_options$lake, optional = TRUE)
# Expected result: Three fixed release IDs. Without explicit table contracts only the structure
# is captured automatically.
# Task: Are these three publications one transaction?
# Solution: No. A complete model product can be published together; this exercise deliberately
# publishes individual tables.

# H33 Build a model from lake releases ----
# Goal: Pin every member table.
# Prerequisites: H33a.
#
# dr_model builds a dm model from stored tables, with each member release ID specified
# explicitly.
training_step("H33", {
  lake_model <- dr_model(training_lake,
    tables=c(policies="model.policies", customers="model.customers", brokers="model.brokers"),
    releases=c(policies=model_policy_release$release_id, customers=model_customer_release$release_id, brokers=model_broker_release$release_id),
    primary_keys=list(policies="policy_id", customers="customer_id", brokers="broker_id"),
    foreign_keys=list(list(table="policies", columns="customer_id", ref_table="customers", ref_columns="customer_id"), list(table="policies", columns="broker_id", ref_table="brokers", ref_columns="broker_id")))
  print(lake_model)
}, needs = c("H33a"), enabled = training_options$lake, optional = TRUE)
# Expected result: Three related tables on fixed releases.
# Task: Is the model automatically flattened?
# Solution: No. Joins remain a deliberate transformation.

# H34 Define related metrics together ----
# Goal: Describe population, cancellations and rate.
# Prerequisites: H21; dataraft.metrics.
#
# The teaching definition is now explicitly marked approved. In a real project this requires
# actual business review; the flag does not perform that review.
training_step("H34", {
  portfolio_metrics <- dataraft.metrics::dr_metric_set("policies.cohort",
    opening=sum(in_opening), cancellations=sum(in_cancellations),
    rate=sum(in_cancellations)/sum(in_opening),
    dimensions="broker_id", units=c(opening="contracts", cancellations="contracts", rate="ratio"),
    approved=TRUE, code_version="training-metrics-v1")
  local_metrics <- dataraft.metrics::dr_measure(cohort_run, metrics=portfolio_metrics, by=character())
  print(dr_collect(local_metrics))
}, needs = c("H21"), packages = c("dataraft.metrics"))
# Expected result: Three exploratory measurements from the local run. A frozen report requires
# published inputs.
# Task: Does approved=TRUE make an in-memory run report-ready?
# Solution: No. Published input releases are still missing.

# H35 Freeze a report ----
# Goal: Bind metrics to published inputs.
# Prerequisites: H34 and H26.
#
# Publish the checked cohort product so each measurement carries its exact data version.
training_step("H35", {
  cohort_release <- dr_publish(cohort_product, to=training_lake)
  report_values <- dataraft.metrics::dr_measure(cohort_release, metrics=portfolio_metrics, by=character())
  frozen_report <- dataraft.metrics::dr_report_release(report_values, id="training.august.v1", code_version="training-report-v1", to=training_lake)
  print(frozen_report)
}, needs = c("H34", "H26"), enabled = training_options$lake, optional = TRUE)
# Expected result: A stored report with ID training.august.v1.
# Task: Can the same ID later represent different values?
# Solution: No. Report IDs identify immutable versions.

# H36 Read and verify a report ----
# Goal: Reproduce results after a later delivery.
# Prerequisites: H35.
#
# Report values stay bound to the original release. Integrity and business correctness are
# separate questions.
training_step("H36", {
  report_before <- dataraft.metrics::dr_report_read(training_lake, "training.august.v1", values_only=TRUE)
  changed_dates <- dated_policies
  changed_dates$cancel_date[1] <- as.Date("2026-08-20")
  cohort_later <- dr_publish(cohort_product, data=changed_dates, to=training_lake)
  report_after <- dataraft.metrics::dr_report_read(training_lake, "training.august.v1", values_only=TRUE)
  stopifnot(identical(report_before, report_after))
  report_verification <- dataraft.metrics::dr_report_verify(training_lake, "training.august.v1", metrics=portfolio_metrics)
  print(report_verification)
  stopifnot(all(report_verification$integrity=="match"), all(report_verification$replay=="match"))
}, needs = c("H35"), enabled = training_options$lake, optional = TRUE)
# Expected result: Historical report values remain identical.
# Task: Does successful integrity verification prove the cancellation definition is correct?
# Solution: No. The business definition needs separate review.

# H37 Trace lineage ----
# Goal: Read recorded dependencies.
# Prerequisites: H32.
#
# The derived release has an explicit source. Lineage records origin; it does not automatically
# capture the complete meaning of arbitrary R code.
training_step("H37", {
  clean_lineage <- dr_lineage(training_lake, asset="policies.clean")
  print(clean_lineage)
}, needs = c("H32"), enabled = training_options$lake, optional = TRUE)
# Expected result: policies.raw appears in the recorded origin path.
# Task: Is a file read outside the adapters automatically fully documented?
# Solution: Not necessarily. Sources must be modeled explicitly to be recorded.

# H38 Inspect run history and incidents ----
# Goal: Write persistent run evidence deliberately.
# Prerequisites: H06; independent of the lake.
#
# write=FALSE also suppresses persistent evidence. Here a product without a data target uses
# write=TRUE and an explicit evidence directory to write run metadata.
training_step("H38", {
  evidence_path <- file.path(training_root, "run-evidence")
  evidence_good <- dr_run(policy_product, evidence=evidence_path)
  evidence_bad <- dr_run(policy_product, data=bad_policies, evidence=evidence_path, stop_on_failure=FALSE)
  print(dr_run_history(evidence_path))
  print(dr_incidents(evidence_path))
  stopifnot(nrow(dr_run_history(evidence_path))==2L, evidence_bad$status=="blocked")
}, needs = c("H06"))
# Expected result: One successful and one blocked run.
# Task: Does the evidence directory contain every source row?
# Solution: No. It contains descriptive metadata and check counts, not the complete source data.

# H39 Explore the local catalog ----
# Goal: Browse existing metadata.
# Prerequisites: H26; adapters, shiny, bslib; gui=TRUE to launch.
#
# First construct the app without launching it. Interactive use occupies the R console until the
# app stops.
training_step("H39", {
  catalog_app <- dataraft.adapters::dr_catalog_app(training_lake, launch=FALSE)
  print(class(catalog_app))
  if (training_options$gui && interactive()) shiny::runApp(catalog_app)
}, needs = c("H26"), packages = c("dataraft.adapters", "shiny", "bslib"), enabled = training_options$lake, optional = TRUE)
# Expected result: An app object; a catalog window when GUI is enabled.
# Task: Open a product and compare its metadata with H37.
# Solution: The views describe registered products and runs. Stop the app before continuing the
# script.

# V01 Suggest a contract from data ----
# Goal: Review inferred types deliberately.
# Prerequisites: H01; extras=TRUE.
#
# Inference observes types; it cannot reliably infer business rules or ownership.
training_step("V01", {
  contract_draft <- dr_contract_from(policies, "policies.draft", owner="Training", grain="One policy", key="policy_id")
  print(contract_draft)
  confirmed_contract <- dr_contract_confirm(contract_draft)
  print(confirmed_contract)
}, needs = c("H01"), enabled = training_options$extras, optional = TRUE)
# Expected result: A confirmed contract after explicit review.
# Task: Does confirm execute a delivery?
# Solution: No. It confirms the specification draft. dr_run checks data.

# V02a Add descriptive metadata ----
# Goal: Document ownership and grain.
# Prerequisites: H04; extras.
#
# Descriptive metadata does not enforce access control or approval policies.
training_step("V02a", {
  owned_contract <- policy_contract |> dr_contract_meta(owner="Risk Analytics", description="Synthetic training policies", grain="One policy")
  print(owned_contract)
}, needs = c("H04"), enabled = training_options$extras, optional = TRUE)
# Expected result: Owner and grain are documented.
# Task: Does owner grant read access?
# Solution: No. Authorization is outside this metadata.

# V02b Choose a validation policy ----
# Goal: Allow extra columns deliberately.
# Prerequisites: V02a.
#
# Contract policy should be explicit, rather than hidden in transformations.
training_step("V02b", {
  flexible_contract <- owned_contract |> dr_contract_policy(allow_extra=TRUE)
  print(flexible_contract$allow_extra)
}, needs = c("V02a"), enabled = training_options$extras, optional = TRUE)
# Expected result: Additional columns are allowed; declared keys remain binding.
# Task: Should every delivery use this policy?
# Solution: Only when extra fields are acceptable to the business.

# V02 Compare contract versions ----
# Goal: Review a change before using it.
# Prerequisites: V02b.
#
# A new version makes the revision explicit. A diff may require review instead of declaring
# every change compatible.
training_step("V02", {
  contract_v2 <- dr_contract_update(owned_contract, version="2.0.0", columns=c(channel="character"))
  print(dr_contract_diff(owned_contract, contract_v2))
  stopifnot(!"channel" %in% names(owned_contract$columns))
}, needs = c("V02b"), enabled = training_options$extras, optional = TRUE)
# Expected result: The diff shows the change; the old contract is unchanged.
# Task: Is a newly added column automatically required?
# Solution: Not with dr_contract_update. Maintain required explicitly.

# V03a Warn instead of blocking ----
# Goal: Distinguish quality actions.
# Prerequisites: H06; extras.
#
# A warning allows data to continue. This is a business decision, not a repair.
training_step("V03a", {
  warning_rule <- dr_quality_rule("nonnegative", ~ premium >= 0, action="warn", threshold=0)
  warning_product <- dr_product("policies.warning", bad_policies, contract=policy_contract) |> dr_add_quality(warning_rule)
  warning_run <- dr_run(warning_product, write=FALSE)
  print(dr_quality_report(warning_run))
}, needs = c("H06"), enabled = training_options$extras, optional = TRUE)
# Expected result: A warning status and unchanged data.
# Task: Has the value -150 disappeared?
# Solution: No. Warning does not change data.

# V03b Quarantine failing rows ----
# Goal: Retain rejected rows separately.
# Prerequisites: H06; extras.
#
# A row-level formula can exclude failing rows from the accepted candidate.
training_step("V03b", {
  quarantine_rule <- dr_quality_rule("nonnegative", ~ premium >= 0, action="quarantine", threshold=0)
  quarantine_product <- dr_product("policies.quarantine", bad_policies, contract=policy_contract) |> dr_add_quality(quarantine_rule)
  quarantine_run <- dr_run(quarantine_product, write=FALSE)
  print(dr_quarantine_rows(quarantine_run))
  stopifnot(nrow(dr_collect(quarantine_run))==5L)
}, needs = c("H06"), enabled = training_options$extras, optional = TRUE)
# Expected result: Five accepted rows; the negative premium remains visible in quarantine.
# Task: Why can this be risky for a portfolio rate?
# Solution: Removing policies changes the population. Reporting needs an explicit handling rule.

# V03 Check reference data ----
# Goal: Validate allowed customer IDs.
# Prerequisites: H16a; extras.
#
# A reference rule checks membership without enriching columns through a lookup.
training_step("V03", {
  reference_rule <- dr_quality_reference(customers, by="customer_id", name="known_customer")
  reference_product <- dr_product("policies.reference", linked_policies) |> dr_add_quality(reference_rule)
  reference_run <- dr_run(reference_product, write=FALSE)
  print(dr_quality_report(reference_run))
}, needs = c("H16a"), enabled = training_options$extras, optional = TRUE)
# Expected result: All customer IDs are found.
# Task: How does this differ from lookup?
# Solution: It checks membership without adding region to the policies.

# V04a Sort rows ----
# Goal: Apply one additional recipe verb.
# Prerequisites: H01 and H08; extras.
#
# These variants use separate objects. There is no explicit output contract for these isolated
# verb demonstrations, so validation is unvalidated.
training_step("V04a", {
  variant_recipe <- dr_step_arrange(dr_recipe(), dplyr::desc(premium))
  variant_product <- dr_product("policies.variant", policies) |> dr_add_recipe(variant_recipe)
  print(dr_collect(dr_run(variant_product, write=FALSE)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: Policy 4 appears first.
# Task: Does sorting change the business key?
# Solution: No, only the order.

# V04b Remove duplicates ----
# Goal: Apply a distinct step.
# Prerequisites: H01 and H08; extras.
#
# Use a separate object. With no explicit output contract, validation is unvalidated.
training_step("V04b", {
  variant_recipe <- dr_step_distinct(dr_recipe(), policy_id, .keep_all=TRUE)
  variant_product <- dr_product("policies.variant", policies) |> dr_add_recipe(variant_recipe)
  print(dr_collect(dr_run(variant_product, write=FALSE)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: Each ID appears once.
# Task: Should bad duplicates always be silently removed?
# Solution: No. First decide which row is valid for the business.

# V04c Rename columns ----
# Goal: Make an output name explicit.
# Prerequisites: H01 and H08; extras.
#
# Use a separate object. This verb demonstration has no explicit output contract, so validation
# is unvalidated.
training_step("V04c", {
  variant_recipe <- dr_step_rename(dr_recipe(), monthly_premium=premium)
  variant_product <- dr_product("policies.variant", policies) |> dr_add_recipe(variant_recipe)
  print(dr_collect(dr_run(variant_product, write=FALSE)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: monthly_premium replaces premium.
# Task: What must happen to an existing contract?
# Solution: Explicitly revise its columns and rules to match.

# V04d Aggregate data ----
# Goal: Change the output grain.
# Prerequisites: H01 and H08; extras.
#
# Use a separate object. This verb demonstration has no explicit output contract, so validation
# is unvalidated.
training_step("V04d", {
  variant_recipe <- dr_step_summarise(dr_recipe(), total=sum(premium))
  variant_product <- dr_product("policies.variant", policies) |> dr_add_recipe(variant_recipe)
  print(dr_collect(dr_run(variant_product, write=FALSE)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: One row with total=740.
# Task: Is policy_id still the correct key?
# Solution: No. The grain is now the whole portfolio.

# V04 Use a custom transformation ----
# Goal: Apply an ordinary R function.
# Prerequisites: H01 and H08; extras.
#
# This separate demonstration has no explicit output contract, so validation is unvalidated.
training_step("V04", {
  variant_recipe <- dr_step_transform(dr_recipe(), function(data) dplyr::mutate(data, premium=premium*1.01))
  variant_product <- dr_product("policies.variant", policies) |> dr_add_recipe(variant_recipe)
  print(dr_collect(dr_run(variant_product, write=FALSE)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: Every premium increases by one percent.
# Task: Can a custom function have side effects?
# Solution: Yes. write=FALSE does not prevent side effects inside callbacks.

# V05a Extract a recipe ----
# Goal: Reuse preparation on another product.
# Prerequisites: H09; extras.
#
# Extracting a recipe does not execute it.
training_step("V05a", {
  reused_recipe <- dr_extract_recipe(prepared_product)
  reused_product <- dr_product("policies.reused", precise_policies, contract=policy_contract) |> dr_add_recipe(reused_recipe)
  print(dr_collect(dr_run(reused_product, write=FALSE)))
}, needs = c("H09"), enabled = training_options$extras, optional = TRUE)
# Expected result: The first policy has premium 100.13.
# Task: Is the recipe tied to the old product ID?
# Solution: No. Preparation is a reusable object of its own.

# V05 Replace and remove a recipe ----
# Goal: Change definitions deliberately.
# Prerequisites: V05a.
#
# update replaces existing steps. remove removes preparation entirely.
training_step("V05", {
  replaced_product <- dr_update_recipe(reused_product, dr_recipe() |> dr_step_mutate(premium=round(premium, 0)))
  plain_product <- dr_remove_recipe(reused_product)
  print(dr_collect(dr_run(replaced_product, write=FALSE)))
  print(dr_collect(dr_run(plain_product, write=FALSE)))
}, needs = c("V05a"), enabled = training_options$extras, optional = TRUE)
# Expected result: 100 after replacement; 100.126 without a recipe.
# Task: Was reused_product itself modified?
# Solution: No. Both calls produce new definition objects.

# V06a Inspect a data profile ----
# Goal: Separate observation from rules.
# Prerequisites: H01; extras.
#
# A profile describes types, missingness and ranges. It does not create quality rules.
training_step("V06a", {
  profile_now <- dr_profile_data(policies)
  print(profile_now)
}, needs = c("H01"), enabled = training_options$extras, optional = TRUE)
# Expected result: Three profile rows, each describing six observations.
# Task: Is an observed maximum a business limit?
# Solution: No. A limit needs justification and an explicit rule.

# V06 Detect profile drift ----
# Goal: Compare deliveries for change.
# Prerequisites: V06a.
#
# Change only the share of missing premiums.
training_step("V06", {
  profile_baseline <- dr_profile_snapshot(policies, "delivery-1")
  missing_delivery <- policies
  missing_delivery$premium[1:2] <- NA_real_
  profile_current <- dr_profile_snapshot(missing_delivery, "delivery-2")
  print(dr_profile_compare(profile_baseline, profile_current))
}, needs = c("V06a"), enabled = training_options$extras, optional = TRUE)
# Expected result: Increased missingness in premium.
# Task: Is the delivery automatically rejected?
# Solution: No. A profile comparison gives evidence; an execution policy needs rules.

# V07a Switch the quality engine ----
# Goal: Run the same formula with pointblank.
# Prerequisites: H06; pointblank; extras.
#
# dr_set_engine selects the implementation of a rule, not the storage backend.
training_step("V07a", {
  pointblank_rule <- dr_quality_rule("nonnegative", ~ premium >= 0) |> dr_set_engine("pointblank")
  pointblank_product <- dr_product("policies.pointblank", bad_policies, contract=policy_contract) |> dr_add_quality(pointblank_rule)
  pointblank_run <- dr_run(pointblank_product, write=FALSE, stop_on_failure=FALSE)
  print(dr_quality_report(pointblank_run))
}, needs = c("H06"), packages = c("pointblank"), enabled = training_options$extras, optional = TRUE)
# Expected result: The negative premium is still detected.
# Task: Has the lake switched to pointblank?
# Solution: No. Quality and storage are independent components.

# V07 Use a pointblank agent ----
# Goal: Reuse existing pointblank checks.
# Prerequisites: V07a.
#
# An agent builder is supplied through a rule adapter. The action remains explicitly blocking.
training_step("V07", {
  agent_rule <- dr_pointblank_checks("premium_agent", function(data) {
    pointblank::create_agent(data) |> pointblank::col_vals_gte(columns="premium", value=0)
  }, action="block", threshold=0)
  agent_product <- dr_product("policies.agent", bad_policies, contract=policy_contract) |> dr_add_quality(agent_rule)
  agent_run <- dr_run(agent_product, write=FALSE, stop_on_failure=FALSE)
  print(dr_quality_report(agent_run))
  agent_contract <- dr_contract("agent.report", c(policy_id="integer", premium="numeric", cancelled="logical"), rules=list(agent_rule))
  agent_quality <- dr_validate(bad_policies, agent_contract, keep_agents=TRUE)
  dr_pointblank_report(agent_quality, "premium_agent", file.path(training_root, "pointblank.html"), overwrite=TRUE)
}, needs = c("V07a"), enabled = training_options$extras, optional = TRUE)
# Expected result: A pointblank report about the invalid premium.
# Task: Must all native rules be replaced?
# Solution: No. The optional integration complements native quality checks.

# V08a Read a CSV source ----
# Goal: Separate file reading from definition.
# Prerequisites: H04; extras.
#
# Create a small reproducible CSV. The source reads it when executed.
training_step("V08a", {
  csv_path <- file.path(training_root, "policies.csv")
  utils::write.csv(policies, csv_path, row.names=FALSE)
  csv_source <- dr_source_file("policies.file", csv_path)
  csv_product <- dr_product("policies.csv", csv_source, contract=policy_contract)
  print(dr_collect(dr_run(csv_product, write=FALSE)))
}, needs = c("H04"), enabled = training_options$extras, optional = TRUE)
# Expected result: Six rows read from a file.
# Task: What if the file changes between definition and execution?
# Solution: The next run reads the changed file. Pinning a fixed release is a separate choice.

# V08 Read an Excel source ----
# Goal: Use an appropriate reader.
# Prerequisites: H04; readxl, writexl; extras.
#
# writexl only creates the fixture. DataRaft reads Excel through readxl.
training_step("V08", {
  xlsx_path <- file.path(training_root, "policies.xlsx")
  writexl::write_xlsx(policies, xlsx_path)
  xlsx_source <- dr_source_file("policies.excel", xlsx_path, reader=readxl::read_excel)
  xlsx_product <- dr_product("policies.excel", xlsx_source) |> dr_add_recipe(dr_recipe() |> dr_step_mutate(policy_id=as.integer(policy_id))) |> dr_add_contract(policy_contract)
  print(dr_collect(dr_run(xlsx_product, write=FALSE)))
}, needs = c("H04"), packages = c("readxl", "writexl"), enabled = training_options$extras, optional = TRUE)
# Expected result: Policy IDs are explicitly converted to integer.
# Task: Why is this conversion needed?
# Solution: Excel does not have R's integer class; imported numbers can be doubles.

# V09a Read a database source ----
# Goal: Try a DBI backend locally.
# Prerequisites: H04; adapters, RSQLite; extras.
#
# The training database is in-memory SQLite. The owner of the connection must close it later.
training_step("V09a", {
  adapter_con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(adapter_con, "policies", policies)
  database_source <- dataraft.adapters::dr_source_database(adapter_con, table="policies", lazy=FALSE)
  database_rows <- dr_read_source(database_source)
  print(database_rows)
}, needs = c("H04"), packages = c("dataraft.adapters", "RSQLite"), enabled = training_options$extras, optional = TRUE)
# Expected result: Six rows. SQLite may return logical values as 0/1; align types deliberately
# before applying a contract.
# Task: May the adapter close this caller-owned connection?
# Solution: No. We close it after the adapter exercises.

# V09b Write to a database target ----
# Goal: Publish checked data to a table.
# Prerequisites: V09a.
#
# SQLite stores logical values as INTEGER. The recipe and output contract represent this
# explicitly. A database target is not a managed lake release.
training_step("V09b", {
  database_contract <- dr_contract("policies.sqlite", c(policy_id="integer", premium="numeric", cancelled="integer"), key="policy_id")
  database_recipe <- dr_recipe() |> dr_step_mutate(cancelled=as.integer(cancelled))
  database_product <- dr_product("policies.sqlite", policies, contract=database_contract) |> dr_add_recipe(database_recipe) |> dr_add_quality(~ premium >= 0) |> dr_set_target(dataraft.adapters::dr_target_database(adapter_con, "checked_policies"))
  database_result <- dr_publish(database_product)
  print(DBI::dbReadTable(adapter_con, "checked_policies"))
}, needs = c("V09a"), enabled = training_options$extras, optional = TRUE)
# Expected result: An output table in the training database.
# Task: Does this automatically provide DuckLake history?
# Solution: No. Guarantees belong to the chosen target adapter.

# V09c Transform with SQL ----
# Goal: Prepare a table using DuckDB SQL.
# Prerequisites: V09a.
#
# The SQL adapter exposes the input through its documented table placeholder.
training_step("V09c", {
  sql_source <- policies
  sql_recipe <- dr_recipe() |> dr_step_transform(dataraft.adapters::dr_sql_transform("SELECT * FROM data WHERE premium >= 100"))
  sql_product <- dr_product("policies.sql", sql_source) |> dr_add_recipe(sql_recipe)
  print(dr_collect(dr_run(sql_product, write=FALSE)))
}, needs = c("V09a"), packages = c("duckdb"), enabled = training_options$extras, optional = TRUE)
# Expected result: Four policies with premiums of at least 100.
# Task: Is R code automatically translated into SQL?
# Solution: No. You write the SQL expression explicitly.

# V09d Write Parquet ----
# Goal: Change the output file format.
# Prerequisites: H07; adapters, arrow; extras.
#
# Parquet is a storage choice; the product and its rules remain reusable.
training_step("V09d", {
  parquet_path <- file.path(training_root, "policies.parquet")
  parquet_product <- policy_product |> dr_set_target(dataraft.adapters::dr_target_parquet(parquet_path, overwrite=TRUE))
  parquet_run <- dr_publish(parquet_product)
  print(parquet_run$outputs)
}, needs = c("H07"), packages = c("dataraft.adapters", "arrow"), enabled = training_options$extras, optional = TRUE)
# Expected result: A Parquet output in the course directory.
# Task: Why use overwrite=TRUE here?
# Solution: The path belongs exclusively to this course run. This is not a versioning strategy.

# V09e Read Parquet ----
# Goal: Read stored columns back.
# Prerequisites: V09d.
#
# Reading is a separate source operation.
training_step("V09e", {
  parquet_source <- dataraft.adapters::dr_source_parquet(parquet_path)
  parquet_rows <- dr_collect(dr_run(dr_product("policies.parquet", parquet_source), write=FALSE))
  print(parquet_rows)
  stopifnot(nrow(parquet_rows)==6L)
}, needs = c("V09d"), enabled = training_options$extras, optional = TRUE)
# Expected result: Six rows.
# Task: Is a filename a lake release ID?
# Solution: No. A file and a managed release have different identities.

# V09f Publish to a pins board ----
# Goal: Use a versioned board.
# Prerequisites: H07; adapters, pins; extras.
#
# A temporary board is enough for this local integration exercise.
training_step("V09f", {
  training_board <- pins::board_temp(versioned=TRUE)
  pins_product <- policy_product |> dr_set_target(dataraft.adapters::dr_target_pins(training_board, "policies"))
  pins_run <- dr_publish(pins_product)
  print(pins_run$outputs)
}, needs = c("H07"), packages = c("dataraft.adapters", "pins"), enabled = training_options$extras, optional = TRUE)
# Expected result: A pin in the temporary board.
# Task: Will this board persist after the session?
# Solution: No. Configure a persistent board when durability is needed.

# V09g Read a pin ----
# Goal: Use a board as a source.
# Prerequisites: V09f.
#
# Without an explicit version, the source reads the current pin.
training_step("V09g", {
  pins_source <- dataraft.adapters::dr_source_pins(training_board, "policies")
  pins_rows <- dr_collect(dr_run(dr_product("policies.pin", pins_source), write=FALSE))
  print(pins_rows)
  stopifnot(nrow(pins_rows)==6L)
}, needs = c("V09f"), enabled = training_options$extras, optional = TRUE)
# Expected result: The familiar policy delivery.
# Task: How do you pin an earlier version?
# Solution: Supply its pin version through version, on a board that supports versioning.

# V09 Read an API source ----
# Goal: Execute an HTTP request deliberately.
# Prerequisites: api=TRUE; adapters, httr2; TRAINING_API_URL returning a JSON list of records.
#
# Use your own test API. No public example service is assumed. Add authentication to the request
# if needed, rather than storing it in the product.
training_step("V09", {
  api_url <- Sys.getenv("TRAINING_API_URL")
  stopifnot(nzchar(api_url))
  api_request <- httr2::request(api_url) |> httr2::req_timeout(15)
  api_source <- dataraft.adapters::dr_source_api(api_request, parse=function(response) {
    dplyr::bind_rows(httr2::resp_body_json(response, simplifyVector=FALSE))
  })
  api_product <- dr_product("policies.api", api_source)
  print(dr_collect(dr_run(api_product, write=FALSE)))
}, packages = c("dataraft.adapters", "httr2"), enabled = training_options$api, optional = TRUE)
# Expected result: A table from your test response; no universal response schema is assumed.
# Task: What if the response wraps records in a data field?
# Solution: Adapt the parser to select that field, then write a matching contract.

# V10a Export an ODCS contract ----
# Goal: Save a portable contract.
# Prerequisites: H04; adapters, yaml; extras or gui.
#
# The resulting ODCS document is also used in the YAML editor exercises.
training_step("V10a", {
  odcs_path <- file.path(training_root, "policies.contract.yaml")
  if (!file.exists(odcs_path)) dataraft.adapters::dr_contract_odcs(policy_contract, path=odcs_path)
  cat(readLines(odcs_path), sep="
  ")
}, needs = c("H04"), packages = c("dataraft.adapters", "yaml"), enabled = training_options$extras || training_options$gui, optional = TRUE)
# Expected result: Readable YAML with contract metadata and columns.
# Task: Why use the suffix .contract.yaml?
# Solution: It allows the extension to offer its contract editor.

# V10 Import an ODCS contract ----
# Goal: Execute the supported subset.
# Prerequisites: V10a.
#
# Unknown executable rules are not evaluated as arbitrary R. Unsupported constructs must be
# rejected explicitly.
training_step("V10", {
  imported_contract <- dataraft.adapters::dr_contract_from_odcs(odcs_path)
  odcs_product <- dr_product("policies.odcs", policies, contract=imported_contract)
  print(dr_run(odcs_product, write=FALSE))
}, needs = c("V10a"), enabled = training_options$extras || training_options$gui, optional = TRUE)
# Expected result: The saved contract is used for our data.
# Task: Can dr_contract_yaml replace this roundtrip?
# Solution: No. That other export describes metadata; it is not an executable ODCS contract.

# V11a Export a catalog snapshot ----
# Goal: Inspect metadata without the app.
# Prerequisites: H26; adapters; extras.
#
# An export is a metadata snapshot, not a live data source.
training_step("V11a", {
  catalog_path <- file.path(training_root, "catalog.json")
  dataraft.adapters::dr_catalog_export(training_lake, catalog_path)
  print(file.info(catalog_path)[, "size", drop=FALSE])
}, needs = c("H26"), packages = c("dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: A nonempty snapshot file.
# Task: Does the file update automatically?
# Solution: No. Export again when a new snapshot is needed.

# V11b Read freshness metadata ----
# Goal: Interpret freshness in context.
# Prerequisites: H26; adapters; extras.
#
# Without agreed business deadlines, lateness has no defined meaning.
training_step("V11b", {
  print(dataraft.adapters::dr_freshness(training_lake))
}, needs = c("H26"), packages = c("dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: Available freshness metadata, possibly without a deadline.
# Task: Does fresh mean correct?
# Solution: No. Timeliness and content quality are separate dimensions.

# V11c Connect OpenLineage ----
# Goal: Configure a destination for lineage events.
# Prerequisites: catalogs=TRUE; TRAINING_OPENLINEAGE_URL; adapters, httr2.
#
# Use your test instance. dr_run sends metadata; write=FALSE suppresses delivery.
training_step("V11c", {
  lineage_endpoint <- Sys.getenv("TRAINING_OPENLINEAGE_URL")
  stopifnot(nzchar(lineage_endpoint))
  lineage_catalog <- dataraft.adapters::dr_catalog_openlineage(lineage_endpoint, namespace="dataraft-training")
  lineage_product <- policy_product |> dr_add_catalog(lineage_catalog)
  lineage_run <- dr_run(lineage_product, evidence=file.path(training_root, "lineage-evidence"))
  print(lineage_run)
}, needs = c("H07"), packages = c("dataraft.adapters", "httr2"), enabled = training_options$catalogs, optional = TRUE)
# Expected result: Delivery or a diagnosed delivery failure.
# Task: What identity should retries use for deduplication?
# Solution: The stable event or run identity, not a newly invented timestamp.

# V11d Connect OpenMetadata ----
# Goal: Use a separate catalog destination.
# Prerequisites: catalogs=TRUE; TRAINING_OPENMETADATA_URL and TRAINING_OPENMETADATA_SCHEMA;
# optional TRAINING_OPENMETADATA_TOKEN.
#
# The schema must match your prepared test instance. Credentials stay in the request and are not
# written into course files.
training_step("V11d", {
  om_url <- Sys.getenv("TRAINING_OPENMETADATA_URL")
  om_schema <- Sys.getenv("TRAINING_OPENMETADATA_SCHEMA")
  stopifnot(nzchar(om_url), nzchar(om_schema))
  om_request <- httr2::request(om_url)
  if (nzchar(Sys.getenv("TRAINING_OPENMETADATA_TOKEN"))) om_request <- httr2::req_auth_bearer_token(om_request, Sys.getenv("TRAINING_OPENMETADATA_TOKEN"))
  om_catalog <- dataraft.adapters::dr_catalog_openmetadata(om_url, database_schema=om_schema, request=om_request)
  om_run <- dr_run(dr_add_catalog(policy_product, om_catalog), evidence=file.path(training_root, "om-evidence"))
  print(om_run)
}, needs = c("H07"), packages = c("dataraft.adapters", "httr2"), enabled = training_options$catalogs, optional = TRUE)
# Expected result: Metadata in the prepared schema, or a diagnosed delivery failure.
# Task: Is catalog delivery equivalent to data publication?
# Solution: No. Delivery can fail separately after successful processing.

# V11 Retry catalog delivery ----
# Goal: Retry pending delivery deliberately.
# Prerequisites: V11c.
#
# Already acknowledged deliveries are not sent again. Use only the evidence path created in
# V11c.
training_step("V11", {
  retry_history <- dr_retry_catalogs(file.path(training_root, "lineage-evidence"), list(lineage_catalog))
  print(retry_history)
}, needs = c("V11c"), enabled = training_options$catalogs, optional = TRUE)
# Expected result: Pending deliveries are retried; if none are pending there is nothing to
# resend.
# Task: Must the data product be recalculated?
# Solution: No. Delivery can be retried from retained evidence.

# V12a Prepare a local dbt backend ----
# Goal: Prepare separate CLI access.
# Prerequisites: dbt=TRUE; dataraft.dbt, lake, duckdb>=1.5.5, bit64, yaml; dbt-duckdb CLI.
#
# A separate local DuckDB lake avoids conflicts with the main connection. It uses the same
# policy data. The starter's technical names order_id and amount deliberately map to policy_id
# and premium.
training_step("V12a", {
  stopifnot(utils::packageVersion("duckdb") >= "1.5.5")
  dbt_config <- dataraft.lake::dr_lake_config(path=file.path(training_root, "dbt-lake"), backend="duckdb", layers=c("raw", "staging", "core", "marts"))
  dbt_input <- data.frame(order_id=linked_policies$policy_id, customer_id=linked_policies$customer_id, amount=linked_policies$premium)
  dbt_raw <- dataraft.lake::dr_ingest(dbt_input, to=dbt_config, name="training.policies")
  print(dbt_raw)
}, needs = c("H16a"), packages = c("dataraft.dbt", "dataraft.lake", "duckdb", "bit64", "yaml"), enabled = training_options$dbt, optional = TRUE)
# Expected result: An accepted RAW release, with no R connection left open to that backend.
# Task: Does orders introduce a new business domain?
# Solution: No. It is the starter template's technical interface for the same policy delivery.

# V12 Create a dbt project and bind its source ----
# Goal: Generate a minimal SQL workflow.
# Prerequisites: V12a; CLI in PATH or TRAINING_DBT_EXECUTABLE.
#
# dr_dbt_init supports this local dbt-duckdb profile. It does not configure arbitrary dbt
# versions or cloud catalogs.
training_step("V12", {
  dbt_executable <- Sys.getenv("TRAINING_DBT_EXECUTABLE", "dbt")
  stopifnot(nzchar(Sys.which(dbt_executable)) || file.exists(dbt_executable))
  dbt_project <- dataraft.dbt::dr_dbt_init(file.path(training_root, "dbt-project"), dbt_config, name="training_policies", executable=dbt_executable, sources=list(orders=dbt_raw))
  dbt_project <- dataraft.dbt::dr_dbt_sources(dbt_project, list(orders=dbt_raw))
  print(dbt_project)
}, needs = c("V12a"), enabled = training_options$dbt, optional = TRUE)
# Expected result: Project files and a source binding to the exact RAW release.
# Task: Will a later RAW delivery be selected automatically?
# Solution: No. Update the source binding deliberately.

# V13a Run dbt build ----
# Goal: Execute SQL models and tests.
# Prerequisites: V12; processx.
#
# Build runs in a separate CLI process. A failure can be inspected as a result before the course
# marks the step unsuccessful.
training_step("V13a", {
  dbt_result <- dataraft.dbt::dr_dbt_build(dbt_project, echo=TRUE, stop_on_failure=FALSE)
  print(dataraft.dbt::dr_dbt_status(dbt_result))
  stopifnot(isTRUE(dbt_result$success))
}, needs = c("V12"), packages = c("processx"), enabled = training_options$dbt, optional = TRUE)
# Expected result: Successful model and test nodes.
# Task: What should you inspect after a failed build?
# Solution: Status, stdout/stderr and artifact errors. Do not mistake old artifacts for a new
# success.

# V13 Inspect dbt tests and lineage ----
# Goal: Read the corresponding artifacts.
# Prerequisites: V13a.
#
# A separate test run checks the built models. Lineage comes from their artifacts.
training_step("V13", {
  dbt_test_result <- dataraft.dbt::dr_dbt_test(dbt_project, echo=FALSE)
  print(dataraft.dbt::dr_dbt_status(dbt_test_result))
  print(dataraft.dbt::dr_dbt_lineage(dbt_result))
}, needs = c("V13a"), enabled = training_options$dbt, optional = TRUE)
# Expected result: Test results and directed model dependencies.
# Task: Is an R rule automatically covered by a dbt test?
# Solution: No. Tests must be explicitly defined or translated.

# V14a Read a dbt result as a model ----
# Goal: Bring SQL output into R.
# Prerequisites: V13.
#
# Reopen the R connection only after the CLI process finishes.
training_step("V14a", {
  dbt_lake <- dataraft.lake::dr_connect_lake(dbt_config)
  dbt_model_id <- "model.training_policies.customer_revenue"
  dbt_dm <- dataraft.dbt::dr_dbt_model(dbt_lake, dbt_result, tables=c(premiums=dbt_model_id), primary_keys=list(premiums="customer_id"))
  premium_totals <- dplyr::collect(dbt_dm$premiums)
  print(premium_totals)
  stopifnot(sum(premium_totals$revenue)==740)
}, needs = c("V13"), enabled = training_options$dbt, optional = TRUE)
# Expected result: Customer premium totals of 250, 280 and 210. revenue is the template's
# technical output name.
# Task: What is the output grain?
# Solution: One row per customer, not per policy.

# V14b Derive a dbt output contract ----
# Goal: Review and version the output schema.
# Prerequisites: V14a.
#
# A manifest only contains its declared metadata. For this teaching product, confirm a contract
# derived from the actual result.
training_step("V14b", {
  dbt_output_contract <- dr_contract_from(premium_totals, "customer.premiums", grain="Ein Kunde", key="customer_id", required=c("customer_id", "revenue")) |> dr_contract_confirm()
  dbt_contract_spec <- dataraft.dbt::dr_dbt_contract(dbt_output_contract, name="customer_revenue")
  print(dbt_contract_spec)
}, needs = c("V14a"), enabled = training_options$dbt, optional = TRUE)
# Expected result: A contract matching the aggregated table.
# Task: Are inferred types a business approval?
# Solution: No. Review keys, grain and rules separately.

# V14 Publish dbt output ----
# Goal: Expose SQL results as a managed release.
# Prerequisites: V14b.
#
# Publication links the dbt artifact to the actual output table.
training_step("V14", {
  dbt_release <- dataraft.dbt::dr_dbt_publish(dbt_lake, dbt_result, dbt_model_id, contract=dbt_output_contract, asset="customer.premiums", code_version="training-dbt-v1")
  print(dr_collect(dbt_release))
  stopifnot(dbt_release$status=="published")
  dataraft.lake::dr_disconnect_lake(dbt_lake)
}, needs = c("V14b"), enabled = training_options$dbt, optional = TRUE)
# Expected result: A managed release of customer premium totals.
# Task: Is dr_transform_dbt the same workflow?
# Solution: No. That alternative embeds a prepared dbt model as a transformation step. The
# following exercise explains its prerequisites.

# V14c Inspect a manifest contract ----
# Goal: Read declared dbt metadata.
# Prerequisites: V13a.
#
# Missing types in a manifest can prevent derivation. Show the concrete error instead of
# inventing a schema.
training_step("V14c", {
  manifest_contract <- tryCatch(dataraft.dbt::dr_dbt_contract_from_manifest(dbt_result, "model.training_policies.customer_revenue"), error=identity)
  print(manifest_contract)
}, needs = c("V13a"), enabled = training_options$dbt, optional = TRUE)
# Expected result: A contract or a specific diagnostic about missing or unsuitable declarations.
# Task: How do you fix a missing type declaration?
# Solution: Declare it in the dbt model schema, rebuild and use the new artifacts.

# V14d Use dbt as a transformation adapter ----
# Goal: Bind your own prepared model.
# Prerequisites: dbt=TRUE; TRAINING_DBT_TRANSFORM_PROJECT, TRAINING_DBT_TRANSFORM_MODEL and
# TRAINING_DBT_TRANSFORM_DB.
#
# The model must read training_input in the specified DuckDB. This exercise does not silently
# rewrite the starter. Provide a separate test project with that interface and profile.
training_step("V14d", {
  transform_path <- Sys.getenv("TRAINING_DBT_TRANSFORM_PROJECT")
  transform_model <- Sys.getenv("TRAINING_DBT_TRANSFORM_MODEL")
  transform_db <- Sys.getenv("TRAINING_DBT_TRANSFORM_DB")
  stopifnot(nzchar(transform_path), nzchar(transform_model), nzchar(transform_db))
  transform_factory <- function() DBI::dbConnect(duckdb::duckdb(), transform_db)
  {
    transform_project <- dataraft.dbt::dr_dbt_project(transform_path, profiles_dir=transform_path, executable=Sys.getenv("TRAINING_DBT_EXECUTABLE", "dbt"))
    dbt_transform <- dataraft.dbt::dr_transform_dbt(transform_project, model=transform_model, connection=transform_factory, input="training_input")
    print(dr_collect(dr_run(dr_product("policies.dbt.transform", policies) |> dr_add_recipe(dr_recipe() |> dr_step_transform(dbt_transform)), write=FALSE)))
  }
}, packages = c("dataraft.dbt", "duckdb", "processx"), enabled = training_options$dbt && nzchar(Sys.getenv("TRAINING_DBT_TRANSFORM_PROJECT")), optional = TRUE)
# Expected result: The configured model output. write=FALSE does not prevent dbt's own side
# effects.
# Task: Why is this excluded from the default run?
# Solution: It needs a prepared project-specific SQL model and profile.

# V14e Deliver dbt artifacts to OpenMetadata ----
# Goal: Send models, tests and SQL lineage through ingestion.
# Prerequisites: V13a; catalogs=TRUE; prepared OpenMetadata database service;
# TRAINING_OPENMETADATA_URL, TRAINING_OPENMETADATA_SERVICE, OPENMETADATA_JWT_TOKEN; metadata CLI
# in PATH or TRAINING_METADATA_EXECUTABLE.
#
# The service and its tables must already exist. Refresh database ingestion after adding RAW
# relations. delivered means CLI success, not proof that every expected edge exists.
training_step("V14e", {
  om_dbt_url <- Sys.getenv("TRAINING_OPENMETADATA_URL")
  om_service <- Sys.getenv("TRAINING_OPENMETADATA_SERVICE")
  stopifnot(nzchar(om_dbt_url), nzchar(om_service), nzchar(Sys.getenv("OPENMETADATA_JWT_TOKEN")))
  om_dbt <- dataraft.adapters::dr_catalog_openmetadata_dbt(om_dbt_url, service=om_service,
    executable=Sys.getenv("TRAINING_METADATA_EXECUTABLE", "metadata"))
  om_receipt <- dr_publish_metadata(om_dbt, dbt_result)
  print(om_receipt)
}, needs=c("V13a"), packages=c("dataraft.adapters", "processx"),
   enabled=training_options$catalogs && training_options$dbt, optional=TRUE)
# Expected result: A delivery receipt, or pending/blocked with diagnostics.
# Task: Which prerequisite should you check if an edge is missing despite CLI success?
# Solution: Check that both tables are inventoried in the service. After refreshing table
# ingestion, an explicit dr_publish_metadata(om_dbt, dbt_result, force=TRUE) retry may be
# appropriate.

# V15 Orchestrate named steps ----
# Goal: Express dependencies through function arguments.
# Prerequisites: H07; extras.
#
# The current dr_workflow form uses named functions to define a sequential dependency graph. The
# old empty builder is not used.
training_step("V15", {
  training_flow <- dr_workflow(
    checked=function(delivery) dr_run(policy_product, data=delivery, write=FALSE),
    total=function(checked) sum(dr_collect(checked)$premium),
    inputs=list(delivery=policies), code_version="training-flow-v1")
  flow_first <- dr_run(training_flow)
  print(flow_first$status)
  stopifnot(flow_first$results$total==740)
}, needs = c("H07"), enabled = training_options$extras, optional = TRUE)
# Expected result: checked runs before total; the total is 740.
# Task: Is this a scheduler?
# Solution: No. It is explicitly invoked sequential orchestration.

# V16 Rerun after a correction ----
# Goal: Provide prior results for reuse.
# Prerequisites: V15.
#
# Unchanged successful branches can be reused. Changed inputs and their consumers run again.
training_step("V16", {
  flow_corrected_data <- policies
  flow_corrected_data$premium[1] <- 105
  flow_second <- dr_run(training_flow, inputs=list(delivery=flow_corrected_data), previous=flow_first)
  print(flow_second$status)
  stopifnot(flow_first$results$total==740, flow_second$results$total==745)
}, needs = c("V15"), enabled = training_options$extras, optional = TRUE)
# Expected result: A corrected total of 745.
# Task: What happens to an earlier publication if a later step fails?
# Solution: There is no distributed transaction across the workflow. Completed publications
# remain.

# V17a Create a project scaffold ----
# Goal: Generate repeatable project files.
# Prerequisites: extras; adapters.
#
# The scaffold uses a new subdirectory and does not overwrite an existing project.
training_step("V17a", {
  project_root <- file.path(training_root, "starter-project")
  dataraft.adapters::dr_init_project(project_root, name="policies", renv=FALSE, targets=FALSE, connect=FALSE)
  print(list.files(project_root, recursive=TRUE))
}, packages = c("dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: Files for a local project.
# Task: Why leave renv=FALSE here?
# Solution: Package environments are a separate step; the course should not install packages
# implicitly.

# V17b Define a file-based YAML project ----
# Goal: Connect source, contract and target declaratively.
# Prerequisites: V10a and V08a; adapters, yaml.
#
# Referenced files use paths relative to the project file in the same course directory.
training_step("V17b", {
  project_yaml_path <- file.path(training_root, "project.yaml")
  yaml::write_yaml(list(id="policies.fileproject", contract="policies.contract.yaml", source="policies.csv", target="yaml-rds"), project_yaml_path)
  yaml_product <- dataraft.adapters::dr_project_yaml(project_yaml_path)
  print(dr_run(yaml_product, write=FALSE))
}, needs = c("V10a", "V08a"), packages = c("yaml", "dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: An executable product based on declarative paths.
# Task: Does loading the definition write the RDS target?
# Solution: No. That requires a writing run or dr_publish.

# V17 Generate a targets graph ----
# Goal: Hand orchestration to targets.
# Prerequisites: H07; adapters, targets; extras.
#
# Only generate the graph here. To use tar_make, place it in its own _targets.R. targets then
# provides caching and scheduling.
training_step("V17", {
  policy_targets <- dataraft.adapters::dr_as_targets(policy_product)
  print(policy_targets)
}, needs = c("H07"), packages = c("dataraft.adapters", "targets"), enabled = training_options$extras, optional = TRUE)
# Expected result: A list of ordinary targets objects.
# Task: Does targets detect every external API change?
# Solution: No. External sources need appropriate cues, often mode=always.

# V18a Configure a PostgreSQL catalog ----
# Goal: Store metadata externally.
# Prerequisites: postgres=TRUE; TRAINING_PG_CONNECTION with a libpq connection to an isolated
# test database.
#
# Only the environment-variable name is stored in configuration. Multiple hosts need shared
# access to both data files and landing storage.
training_step("V18a", {
  stopifnot(nzchar(Sys.getenv("TRAINING_PG_CONNECTION")))
  pg_catalog <- dataraft.lake::dr_registry_postgres("TRAINING_PG_CONNECTION", lock_timeout=10)
  pg_config <- dataraft.lake::dr_lake_config(catalog=pg_catalog,
    storage=dataraft.lake::dr_storage_local(file.path(training_root, "pg-data")),
    landing=file.path(training_root, "pg-landing"), backend="ducklake",
    install_extensions=training_options$install_extensions)
  print(pg_config)
}, packages = c("dataraft.lake", "RPostgres", "duckdb", "bit64"), enabled = training_options$postgres, optional = TRUE)
# Expected result: Configuration without an embedded password.
# Task: Does local file storage suffice for two machines?
# Solution: Only if the same paths are genuinely shared. Two processes on one host can use one
# local directory.

# V18 Publish with PostgreSQL ----
# Goal: Use the configured backend.
# Prerequisites: V18a and H07.
#
# The publication call opens and closes its own connection, using a separate training asset ID.
training_step("V18", {
  pg_release <- dr_publish(dr_product("training.pg.policies", policies, contract=policy_contract), to=pg_config)
  print(pg_release)
  stopifnot(pg_release$status=="published")
}, needs = c("V18a", "H07"), enabled = training_options$postgres, optional = TRUE)
# Expected result: A release in the test database.
# Task: What stays the same after changing the backend?
# Solution: The product and contract. Operations and storage access change.

# V19a Configure S3 storage ----
# Goal: Separate file storage from the metadata catalog.
# Prerequisites: s3=TRUE; the environment variables checked in this block; an available
# credential chain.
#
# Use a training bucket or prefix. The exercise does not delete the bucket. This variant has a
# local metadata catalog, so it is not a multi-host setup.
training_step("V19a", {
  s3_bucket <- Sys.getenv("TRAINING_S3_BUCKET")
  s3_endpoint <- Sys.getenv("TRAINING_S3_ENDPOINT")
  stopifnot(nzchar(s3_bucket), nzchar(s3_endpoint))
  s3_storage <- dataraft.lake::dr_storage_s3(s3_bucket, prefix=paste0("dataraft-training/", basename(training_root)), endpoint=s3_endpoint, credential_provider="credential_chain")
  s3_config <- dataraft.lake::dr_lake_config(catalog=dataraft.lake::dr_registry_duckdb(file.path(training_root, "s3-metadata.ducklake")), storage=s3_storage, landing=file.path(training_root, "s3-landing"), backend="ducklake", install_extensions=training_options$install_extensions)
  print(s3_config)
}, packages = c("dataraft.lake", "duckdb", "bit64", "paws.storage"), enabled = training_options$s3, optional = TRUE)
# Expected result: A separate S3 prefix for this run.
# Task: Does S3 configuration also create a PostgreSQL catalog?
# Solution: No. Metadata catalog and file storage are separate settings.

# V19 Read output from S3 ----
# Goal: Reuse a stored release.
# Prerequisites: V19a and H07.
#
# Credentials are resolved at execution. Only synthetic policy data is published.
training_step("V19", {
  s3_release <- dr_publish(dr_product("training.s3.policies", policies, contract=policy_contract), to=s3_config)
  print(dr_collect(s3_release))
  stopifnot(sum(dr_collect(s3_release)$premium)==740)
}, needs = c("V19a", "H07"), enabled = training_options$s3, optional = TRUE)
# Expected result: The familiar total of 740.
# Task: What does a distributed team need?
# Solution: A shared metadata catalog, jointly accessible storage and a coordinated writing
# protocol.

# V20 Prepare two writer processes ----
# Goal: Observe coordinated publication.
# Prerequisites: V18a; postgres=TRUE; two local R processes with matching packages and
# TRAINING_PG_CONNECTION.
#
# The current writer lock is catalog-wide and serializes coordinated write sections. This is a
# manually started two-process experiment, not an automated load test.
training_step("V20", {
  writer_config_path <- file.path(training_root, "writer-config.rds")
  saveRDS(pg_config, writer_config_path)
  writer_path <- file.path(training_root, "writer.R")
  writer_code <- c('args <- commandArgs(TRUE)', 'config <- readRDS(args[1])', 'writer <- args[2]', 'data <- data.frame(policy_id=1L, premium=as.numeric(args[3]), cancelled=FALSE)', 'product <- dataraft.core::dr_product(paste0("training.writer.", writer), data)', 'print(dataraft.core::dr_publish(product, to=config))')
  writeLines(writer_code, writer_path)
  cat("Terminal A: Rscript ", shQuote(writer_path), " ", shQuote(writer_config_path), " A 100
  ", sep="")
  cat("Terminal B: Rscript ", shQuote(writer_path), " ", shQuote(writer_config_path), " B 200
  ", sep="")
}, needs = c("V18a"), enabled = training_options$postgres, optional = TRUE)
# Expected result: Two commands to run in separate terminals. Depending on timing, both finish
# sequentially or one times out on the lock. Tiny deliveries may not visibly overlap.
# Task: Can direct SQL bypass the DataRaft lock?
# Solution: Yes. All writers must use the coordinated protocol; this is not a universal database
# lock.

# V21a Check a delivery deadline ----
# Goal: Evaluate a business deadline.
# Prerequisites: H27; extras.
#
# Fixed UTC deadline and observation times keep the question reproducible.
training_step("V21a", {
  delivery_check <- dataraft.lake::dr_check_delivery(training_lake, "policies", policy_contract,
    business_date=as.Date("2026-08-31"), due_at=as.POSIXct("2026-09-01 12:00:00", tz="UTC"),
    at=as.POSIXct("2026-09-02 12:00:00", tz="UTC"), record=FALSE)
  print(delivery_check)
}, needs = c("H27"), enabled = training_options$extras, optional = TRUE)
# Expected result: A deadline finding from available metadata. Newly generated technical receipt
# times may be after the example deadline.
# Task: Why use record=FALSE?
# Solution: This is a retrospective exercise, not a new operational monitoring incident.

# V21b Inspect interrupted runs ----
# Goal: Review recovery before acting.
# Prerequisites: H26; extras.
#
# Do not deliberately crash the database. An empty finding is expected for a clean course run.
training_step("V21b", {
  print(dataraft.lake::dr_interrupted(training_lake))
  print(dataraft.lake::dr_recover(training_lake, dry_run=TRUE))
}, needs = c("H26"), enabled = training_options$extras, optional = TRUE)
# Expected result: No interruption, or a recovery plan only.
# Task: May you simply declare an unknown writer stopped?
# Solution: No. Establish the process state first. This exercise does not execute recovery.

# V21c Verify release integrity ----
# Goal: Compare stored content with retained evidence.
# Prerequisites: H27; extras.
#
# Verification may collect data in memory; the course datasets are small.
training_step("V21c", {
  integrity <- dataraft.lake::dr_verify_releases(training_lake)
  print(integrity)
}, needs = c("H27"), enabled = training_options$extras, optional = TRUE)
# Expected result: Per-release status and diagnostics.
# Task: Is a hash an externally tamper-proof seal?
# Solution: No. An administrator able to change both data and registry could change both.

# V21d Plan cleanup ----
# Goal: Inspect cleanup actions before execution.
# Prerequisites: H26; extras.
#
# dry_run=TRUE makes no changes.
training_step("V21d", {
  print(dataraft.lake::dr_cleanup(training_lake, older_than_days=30, dry_run=TRUE))
}, needs = c("H26"), enabled = training_options$extras, optional = TRUE)
# Expected result: A cleanup plan, often empty for a new training lake.
# Task: Should cleanup be applied blindly to production data?
# Solution: No. Review age, references and operational state first.

# V21 Preview snapshot expiry ----
# Goal: Handle retention deliberately.
# Prerequisites: H26; a real DuckLake backend; extras.
#
# Snapshot retention and file cleanup are operational choices. This exercise only previews them.
training_step("V21", {
  print(dataraft.lake::dr_expire_snapshots(training_lake, older_than_days=30, file_retention_days=7, dry_run=TRUE))
}, needs = c("H26"), enabled = training_options$extras, optional = TRUE)
# Expected result: A plan without deletion.
# Task: What must be checked before actual cleanup?
# Solution: Active readers and the snapshots they need. This exercise deletes nothing.

# V22a Use an experimental Iceberg source ----
# Goal: Understand a separate table adapter.
# Prerequisites: iceberg=TRUE; adapters, duckdb; prepared connection in option
# dataraft.training_iceberg_connection; TRAINING_ICEBERG_PATH.
#
# The connection must already have the Iceberg extension loaded. REST catalog configuration and
# authentication are installation-specific.
training_step("V22a", {
  iceberg_con <- getOption("dataraft.training_iceberg_connection")
  iceberg_path <- Sys.getenv("TRAINING_ICEBERG_PATH")
  stopifnot(!is.null(iceberg_con), DBI::dbIsValid(iceberg_con), nzchar(iceberg_path))
  iceberg_source <- dataraft.adapters::dr_source_iceberg(iceberg_con, iceberg_path)
  print(dr_collect(dr_run(dr_product("training.iceberg", iceberg_source), write=FALSE)))
}, packages = c("dataraft.adapters", "duckdb"), enabled = training_options$iceberg, optional = TRUE)
# Expected result: Data from the configured test table version.
# Task: Is this a DataRaft lake release?
# Solution: No. The adapter has separate experimental guarantees.

# V22 Use an experimental Iceberg target ----
# Goal: Create an explicit test table.
# Prerequisites: V22a; TRAINING_ICEBERG_CATALOG and TRAINING_ICEBERG_SCHEMA; transactional REST
# catalog.
#
# create refuses an existing table. The new table belongs only to the course. This does not
# promise replacement, lake registry history or atomicity across tables.
training_step("V22", {
  iceberg_catalog <- Sys.getenv("TRAINING_ICEBERG_CATALOG")
  iceberg_schema <- Sys.getenv("TRAINING_ICEBERG_SCHEMA")
  stopifnot(nzchar(iceberg_catalog), nzchar(iceberg_schema))
  iceberg_target <- dataraft.adapters::dr_target_iceberg(iceberg_con, DBI::Id(catalog=iceberg_catalog, schema=iceberg_schema, table="dataraft_training_policies"), mode="create")
  print(dr_publish(policy_product |> dr_set_target(iceberg_target)))
}, needs = c("V22a", "H07"), enabled = training_options$iceberg, optional = TRUE)
# Expected result: A new test table or an explicit backend error.
# Task: Why is iceberg_con not closed automatically?
# Solution: It is caller-owned and remains the user's responsibility.

# V23a Define a custom source ----
# Goal: Understand R's S3 extension protocol.
# Prerequisites: H01; extras.
#
# Create an in-memory source with a declared read capability. Register methods with their
# generics without editing package files. R's S3 method system here is unrelated to Amazon S3
# storage.
training_step("V23a", {
  training_source <- structure(list(data=policies), class="training_source")
  dr_check_component.training_source <- function(x, ...) invisible(x)
  dr_read_source.training_source <- function(source, ...) source$data
  dr_inspect.training_source <- function(x, ...) list(type="training_source")
  dr_capabilities.training_source <- function(x, ...) dr_component_capabilities(read=TRUE)
  for (generic in c("dr_check_component", "dr_read_source", "dr_inspect", "dr_capabilities")) registerS3method(generic, "training_source", get(paste0(generic, ".training_source")), envir=asNamespace("dataraft.core"))
  print(dr_inspect(training_source))
}, needs = c("H01"), enabled = training_options$extras, optional = TRUE)
# Expected result: A safe description without data contents.
# Task: Should dr_inspect read the actual data?
# Solution: No. Inspection describes the component without executing it.

# V23b Use the custom source ----
# Goal: Plug an adapter into an ordinary product.
# Prerequisites: V23a; adapters.
#
# A custom adapter should work through the same product and contract interface.
training_step("V23b", {
  custom_product <- dr_product("policies.custom", training_source, contract=policy_contract)
  print(dr_collect(dr_run(custom_product, write=FALSE)))
  print(dataraft.adapters::dr_test_adapter(training_source, expected=policies))
}, needs = c("V23a"), packages = c("dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: Six unchanged policy rows.
# Task: Which new function did the product need to learn?
# Solution: None. The S3 protocols connect product and source.

# V23 Test a target roundtrip ----
# Goal: Read back what was written.
# Prerequisites: H04; adapters; extras.
#
# The target test needs read_back and a contract. A successful write alone does not prove a
# correct roundtrip.
training_step("V23", {
  conformance_path <- file.path(training_root, "adapter-conformance")
  conformance <- dataraft.adapters::dr_test_adapter(dataraft.adapters::dr_target_rds(conformance_path),
    data=policies, context=list(contract=policy_contract),
    read_back=function(output) dr_read_source(dataraft.adapters::dr_source_rds(conformance_path, output$version)))
  print(conformance)
}, needs = c("H04"), packages = c("dataraft.adapters"), enabled = training_options$extras, optional = TRUE)
# Expected result: A comparison of written and reread values.
# Task: What additional failure test would be useful?
# Solution: A writer failure that demonstrably leaves no partially committed output.

# V24a Inspect column lineage ----
# Goal: Read static output-column dependencies.
# Prerequisites: H08; extras.
#
# Static analysis can be incomplete for dynamic R code. It is not presented as complete
# knowledge.
training_step("V24a", {
  column_recipe <- dr_recipe() |> dr_step_mutate(annual_premium=premium*12) |> dr_step_select(policy_id, annual_premium)
  print(dr_column_lineage(column_recipe, names(policies)))
}, needs = c("H08"), enabled = training_options$extras, optional = TRUE)
# Expected result: annual_premium depends on premium.
# Task: Must the recipe execute for this analysis?
# Solution: No. It is static analysis with corresponding limits.

# V24b Select diagnostics ----
# Goal: Separate run status from rule execution errors.
# Prerequisites: H06; extras.
#
# These functions inspect retained results without starting another run.
training_step("V24b", {
  print(dr_status(failed_run))
  print(dr_quality_errors(failed_run))
  print(dr_quality_counts(n_failed=1, n_total=6))
}, needs = c("H06"), enabled = training_options$extras, optional = TRUE)
# Expected result: Blocked status. quality_errors may be empty because FALSE is not an R
# exception. quality_counts constructs counts for custom rules; it does not count a run
# automatically.
# Task: Is a failure rate of 1/6 automatically acceptable?
# Solution: Only if an explicit business policy allows it.

# V24c Use quality as a test expectation ----
# Goal: Reuse the quality decision in tests.
# Prerequisites: H05; testthat; extras.
#
# dr_expect_quality uses the framework's quality decision in automated tests.
training_step("V24c", {
  quality_test_run <- dr_run(policy_product, write=FALSE)
  dr_expect_quality(quality_test_run)
}, needs = c("H05"), packages = c("testthat"), enabled = training_options$extras, optional = TRUE)
# Expected result: No test failure for valid data.
# Task: Should an intentional test failure go uncaught in the main path?
# Solution: No. Expect errors explicitly in testthat or inspect them as course results.

# V24 Review in the Data Viewer ----
# Goal: Open diagnostics interactively.
# Prerequisites: H06; gui=TRUE; interactive R session.
#
# The viewer shows bounded failing rows. No UI starts in batch mode.
training_step("V24", {
  if (interactive()) dr_review(failed_run, what="rows", limit=10)
  if (interactive()) dr_review(failed_run, what="report")
}, needs = c("H06"), enabled = training_options$gui, optional = TRUE)
# Expected result: Failing rows or a quality report in the viewer.
# Task: Does this start a new run?
# Solution: No. It uses the existing result.

# V25 Use the offline DuckDB alternative ----
# Goal: Practice lake concepts without DuckLake.
# Prerequisites: extras=TRUE; lake, duckdb>=1.5.5, bit64.
#
# Use a separate directory for this backend. This does not migrate the main course lake.
training_step("V25", {
  stopifnot(utils::packageVersion("duckdb") >= "1.5.5")
  offline_lake <- dataraft.lake::dr_open_lake(file.path(training_root, "offline-duckdb"), backend="duckdb")
  tryCatch({
    offline_release <- dr_publish(policy_product, to=offline_lake)
    print(dataraft.lake::dr_releases(offline_lake, "policies"))
    stopifnot(sum(dr_collect(offline_release)$premium)==740)
  }, finally=dataraft.lake::dr_close_lake(offline_lake))
}, needs = c("H07"), packages = c("dataraft.lake", "duckdb", "bit64"), enabled = training_options$extras, optional = TRUE)
# Expected result: A managed local release without the DuckLake extension.
# Task: How does this differ from H25?
# Solution: The backend is DuckDB. This does not test the DuckLake format or its snapshot
# management.

# Extension exercises: Positron and VS Code ----
# These are manual UI exercises. R blocks only prepare data and do not claim to automate clicks.
# Install the VSIX from the extension commit recorded below using Extensions: Install from VSIX.
# For live R, install dataraft.ide, start an R console and run the extension on the same host.
# VS Code supports offline JSON and YAML, but not live R commands. For these preparation blocks
# set training_options$gui <- TRUE, or rerun the whole script with
# options(dataraft.training=list(gui=TRUE)). Open the Command Palette and enter each command
# name as written. Refresh does not publish a product. Trial is an explicit check.
# The script places optional V modules before E modules so V10a can prepare the YAML file. On
# the website the extension is introduced first; follow its prerequisite links when needed.


# E01 Select R Session ----
# Goal: Connect the existing console.
# Prerequisites: H05; Positron and dataraft.ide.
#
# MANUAL: Open the Command Palette and run DataRaft: Select R Session. Choose the console where
# you ran H01-H05. The extension does not start an R session.
training_step("E01", {
  print(utils::packageVersion("dataraft.ide"))
  print(policy_product)
}, needs = c("H05"), packages = c("dataraft.ide"), enabled = training_options$gui, optional = TRUE)
# Expected result: The selected session is your running course console.
# Task: Try selecting a different existing R session.
# Solution: It has a different workspace. Select the course console again.

# E02 Select Workspace or Lake ----
# Goal: Choose the correct context.
# Prerequisites: E01; optionally H26.
#
# MANUAL: Run DataRaft: Select Workspace or Lake. Start with Workspace. After H26, try the
# already opened training_lake. Selection does not open a new lake.
training_step("E02", {
  print(ls(pattern="product$|training_lake$"))
}, needs = c("E01"), enabled = training_options$gui, optional = TRUE)
# Expected result: Workspace products or lake metadata according to the selected context.
# Task: Why can the entries differ?
# Solution: Workspace definitions and published lake assets are different inventories.

# E03 Refresh Metadata ----
# Goal: Update the five views deliberately.
# Prerequisites: E01.
#
# MANUAL: Run DataRaft: Refresh Metadata. Open Data Products, then inspect Quality, Runs,
# Freshness and Incidents individually. An empty view is valid when no corresponding evidence
# exists.
training_step("E03", {
  print(dr_status(policy_run))
  print(dr_status(failed_run))
}, needs = c("E01", "H06"), enabled = training_options$gui, optional = TRUE)
# Expected result: An explicit refresh updates metadata and its timestamp.
# Task: Change an R object. Are checks automatically rerun in the tree?
# Solution: No. Refresh again. Refresh itself does not execute quality checks.

# E03a Inspect the Data Products view ----
# Goal: Connect a tree entry to its definition.
# Prerequisites: E03.
#
# MANUAL: Expand policy_product and count its three contract columns.

# Expected result: The tree matches the product definition.
# Task: Which R run or lake version explains this entry?
# Solution: Compare the ID and status with the corresponding R result, then move to the next
# view without starting a run.

# E03b Inspect the Quality view ----
# Goal: Compare retained check evidence.
# Prerequisites: E03.
#
# MANUAL: Compare nonnegative for the valid and failed runs.

# Expected result: Evidence reflects the selected run.
# Task: Which run explains the failing rule?
# Solution: Compare IDs and statuses with the corresponding R results before moving to the next
# view.

# E03c Inspect the Runs view ----
# Goal: Distinguish execution states.
# Prerequisites: E03.
#
# MANUAL: Compare completed, blocked and, after lake exercises, published.

# Expected result: States match the retained run results.
# Task: Does completed always mean published?
# Solution: No. Compare the status with the actual R result and target behavior.

# E03d Inspect the Freshness view ----
# Goal: Read timing without inventing a deadline.
# Prerequisites: E03.
#
# MANUAL: Inspect the generation timestamp. Do not infer lateness without a configured deadline.

# Expected result: Available freshness metadata.
# Task: Does a recent timestamp prove good quality?
# Solution: No. Compare the metadata with the corresponding run; timeliness and quality are
# distinct.

# E03e Inspect the Incidents view ----
# Goal: Read a retained rule problem.
# Prerequisites: E03.
#
# MANUAL: Find the negative premium as a rule problem, not as an automatically deleted row.

# Expected result: The incident matches the failed run evidence.
# Task: Was the row automatically removed?
# Solution: No. Compare the rule action and result in R before continuing.

# E04 Open Metadata JSON ----
# Goal: Open a real offline snapshot.
# Prerequisites: E01; jsonlite.
#
# The R block exports a bounded product snapshot through the IDE bridge. MANUAL: Then run
# DataRaft: Open Metadata JSON and choose the printed file. This also works in VS Code.
training_step("E04", {
  bridge_root <- file.path(training_root, "bridge")
  dir.create(bridge_root, showWarnings=FALSE)
  metadata_path <- file.path(bridge_root, "products.json")
  bridge_context <- dataraft.ide::ide_context(workspace=environment(), response_root=bridge_root, contract_root=training_root)
  request <- list(version=1L, operation="products", request_id="training-products", response_path=metadata_path)
  encoded_request <- jsonlite::base64_enc(charToRaw(as.character(jsonlite::toJSON(request, auto_unbox=TRUE))))
  dataraft.ide::ide_request(gsub("[[:space:]]", "", encoded_request), bridge_context)
  print(metadata_path)
}, needs = c("E01"), packages = c("jsonlite"), enabled = training_options$gui, optional = TRUE)
# Expected result: A snapshot of the actual workspace, not a live connection.
# Task: Can this start a live R trial in VS Code?
# Solution: No. Live trials need the Positron R connection.

# E05 Inspect Product ----
# Goal: Understand a definition in the UI.
# Prerequisites: E03.
#
# MANUAL: Select policies in Data Products and run Inspect Product. Compare its contract,
# columns, rules and source with the R definition.
training_step("E05", {
  inspection_for_ui <- dr_inspect(policy_product)
  print(inspection_for_ui[c("id", "contract", "quality")])
}, needs = c("E03"), enabled = training_options$gui, optional = TRUE)
# Expected result: UI and R inspection describe the same definition.
# Task: Does Inspect prove data quality?
# Solution: No. Inspection describes rules; a run applies them to data.

# E06 Trial Product ----
# Goal: Start an explicit check from the UI.
# Prerequisites: E03 and H06.
#
# MANUAL: After the R preparation, Refresh, select ui_bad_product and run Trial Product. Despite
# the retained UI name, it uses dr_run(write=FALSE, stop_on_failure=FALSE).
training_step("E06", {
  ui_bad_product <- dr_product("policies.ui.bad", bad_policies, contract=policy_contract) |> dr_add_quality(list(nonnegative=~ premium >= 0))
  print(ui_bad_product)
}, needs = c("E03"), enabled = training_options$gui, optional = TRUE)
# Expected result: A blocked trial result in the tree.
# Task: Was the configured destination published?
# Solution: No. It is a check without a DataRaft target write.

# E07 View Bounded Rows in R ----
# Goal: Inspect a bounded data preview.
# Prerequisites: E03; successful policy_run.
#
# MANUAL: Select the successful result and run DataRaft: View Bounded Rows in R. Do not use the
# blocked result from E06.
training_step("E07", {
  print(dr_collect(policy_run))
}, needs = c("E03"), enabled = training_options$gui, optional = TRUE)
# Expected result: Six rows in the R Data Explorer. Rows are not sent through the extension
# metadata channel.
# Task: What does the row limit imply?
# Solution: A preview is not a complete quality check; large tables are displayed with a bound.

# E08 Show Directed Lineage ----
# Goal: Read origin as a directed graph.
# Prerequisites: E03; H37 for lake lineage.
#
# MANUAL: Select the lake context, select policies.clean and run DataRaft: Show Directed
# Lineage. Select a source node and follow its relation to the product tree.
training_step("E08", {
  if (identical(training_log[["H37"]], "ok")) print(clean_lineage)
}, needs = c("E03", "H37"), enabled = training_options$gui, optional = TRUE)
# Expected result: After H37, a graph with a RAW dependency. Without lake exercises, no lake
# edges are assumed.
# Task: What does the arrow direction represent?
# Solution: Data dependency. Nodes can navigate to the corresponding product view.

# E09 Show Frozen Report Metadata ----
# Goal: Find frozen reports in the UI.
# Prerequisites: E03 and H35.
#
# MANUAL: Select the lake context and run DataRaft: Show Frozen Report Metadata.
training_step("E09", {
  print("training.august.v1")
}, needs = c("E03", "H35"), enabled = training_options$gui, optional = TRUE)
# Expected result: Report ID and timestamps. This view does not display metric values or verify
# reports.
# Task: Where do you inspect the actual values?
# Solution: Use dr_report_read in H36, and dr_report_verify for integrity.

# E10 Open Contract YAML Editor ----
# Goal: Edit a saved contract.
# Prerequisites: V10a; Positron or VS Code; plain editing needs no live R connection.
#
# MANUAL: Open policies.contract.yaml and run DataRaft: Open Contract YAML Editor. Change a
# description, inspect Preview and try Discard. Edit again and Apply. Apply leaves the buffer
# unsaved; save deliberately afterward.
training_step("E10", {
  print(odcs_path)
}, needs = c("V10a"), enabled = training_options$gui, optional = TRUE)
# Expected result: You can distinguish preview, discarded edits and applied edits. Saving is not
# automatic.
# Task: Why change only a description first?
# Solution: It lets you learn the editor without changing the business schema.

# E11 Compare YAML with Saved File ----
# Goal: Distinguish the buffer from disk.
# Prerequisites: E10.
#
# MANUAL: Change the description without saving. Run DataRaft: Compare YAML with Saved File.
# Save and compare again. If the file changed externally, preserve your edits and reopen the
# editor first.
training_step("E11", {
  print(file.info(odcs_path)[, c("size", "mtime")])
}, needs = c("E10"), enabled = training_options$gui, optional = TRUE)
# Expected result: A diff before saving; a new saved baseline afterward.
# Task: Which version does the next R validation use?
# Solution: The saved file, not the unsaved buffer.

# E12 Validate Saved ODCS Contract in R ----
# Goal: Check the saved contract version.
# Prerequisites: E10 and E01.
#
# MANUAL: Save the file and run DataRaft: Validate Saved ODCS Contract in R. The file and R
# session must be accessible on the same host.
training_step("E12", {
  print(dataraft.adapters::dr_contract_from_odcs(odcs_path))
}, needs = c("E10", "E01"), enabled = training_options$gui, optional = TRUE)
# Expected result: Import and validation of the supported ODCS subset.
# Task: Does a successful import prove all data is valid?
# Solution: No. It establishes a supported contract; data checks are separate.

# E13 Profile Selected Workspace Table ----
# Goal: Inspect the current table schema.
# Prerequisites: E01 and H01.
#
# MANUAL: Run DataRaft: Profile Selected Workspace Table and select policies.
training_step("E13", {
  print(dr_profile_data(policies))
}, needs = c("E01", "H01"), enabled = training_options$gui, optional = TRUE)
# Expected result: Schema metadata for three columns, without data cells in the metadata
# channel.
# Task: Are inferred types already a confirmed contract?
# Solution: No. Inference and an agreed business specification are separate.

# E14 Check Bounded Table Sample against Saved Contract ----
# Goal: Check a deliberately bounded sample.
# Prerequisites: E12; policies and bad_policies in the workspace.
#
# MANUAL: Select the saved contract, run DataRaft: Check Bounded Table Sample against Saved
# Contract and choose a table. Try policies, then bad_policies.
training_step("E14", {
  print(nrow(policies))
}, needs = c("E12"), enabled = training_options$gui, optional = TRUE)
# Expected result: Counts for a bounded sample. The H04 contract has no nonnegative rule, so a
# negative premium need not fail.
# Task: Why can bad_policies pass this structural contract?
# Solution: The business rule was attached to the product in H05, not exported into the H04 ODCS
# file.

# E15 Show R Rule Diagnostics ----
# Goal: Trace a rule to its R source location.
# Prerequisites: E01; add or open the course directory as a workspace folder.
#
# MANUAL: Open the generated R file in the workspace. Refresh, select source_rule_product and
# run Trial Product. Select the retained result and run Show R Rule Diagnostics. Do not modify
# the rule file during this sequence. Formula rules do not provide verified source locations.
training_step("E15", {
  rule_path <- file.path(training_root, "training-rule.R")
  writeLines(c("training_nonnegative <- function(data) {", "  data$premium >= 0", "}"), rule_path)
  source(rule_path, local=environment(), keep.source=TRUE)
  source_rule_product <- dr_product("policies.source.rule", bad_policies, contract=policy_contract) |> dr_add_quality(list(nonnegative=training_nonnegative))
  print(rule_path)
}, needs = c("E01", "H06"), enabled = training_options$gui, optional = TRUE)
# Expected result: The extension can mark a rule in an unchanged saved UTF-8 workspace file.
# Otherwise it reports skipped locations.
# Task: Does a missing marker mean the rule passed?
# Solution: No. The source may be unverifiable. The retained result determines the check status.

# Additional package-family reference ----
# The dataraft metapackage exposes 18 entry points. These exercises load core and address
# specialists with ::, making optional dependencies and function ownership visible.
# library(dataraft) does not attach every advanced function.
# Optional inspection: getNamespaceExports("dataraft") and
# intersect(getNamespaceExports("dataraft"), getNamespaceExports("dataraft.core")).
# Constructors and dr_inspect describe; dr_run executes; dr_publish requires a target; dr_ingest
# checks RAW inputs. These roles are independent of frontend or storage backend.


# Finish: inspect actual execution coverage ----
# An ok entry means the block executed successfully in YOUR current run. skipped is not a
# passing test. Optional integration failures are explicitly recorded as errors. UI clicks are
# manual: a successful E preparation block does not prove a GUI exercise was completed.
training_summary <- data.frame(
  section = sort(ls(training_log)),
  status = vapply(sort(ls(training_log)), function(id) training_log[[id]], character(1)),
  row.names = NULL
)
print(training_summary, row.names=FALSE)
message("Course files: ", training_root)

# Close connections deliberately ----
# Run this closing cell only after the UI and catalog exercises. To inspect the lake again,
# reconnect in H26 and refresh the UI. iceberg_con is caller-owned and is not closed here.
# Course files are not deleted automatically; a complete rerun uses a new directory.
if (exists("adapter_con", inherits=FALSE) && DBI::dbIsValid(adapter_con)) DBI::dbDisconnect(adapter_con)
if (exists("training_lake", inherits=FALSE) && DBI::dbIsValid(training_lake$con)) dataraft.lake::dr_disconnect_lake(training_lake)
if (exists("dbt_lake", inherits=FALSE) && DBI::dbIsValid(dbt_lake$con)) dataraft.lake::dr_disconnect_lake(dbt_lake)

# Reference: pinned component commits ----
# These are the component commits underlying the course. dr_internal_* functions are technical
# family interfaces, and S3 methods are used through their generics. Deprecated dr_trial and the
# empty dr_workflow builder are excluded from new course code. dataraft.catalog is a deprecated
# facade; use adapters for catalog integrations.

# dataraft.core: 67e4ac9d2c7e506253d9dde733787372003f2d19
# https://github.com/dataraft-r/dataraft.core/tree/67e4ac9d2c7e506253d9dde733787372003f2d19
# dataraft.lake: 8a05759be028f4550ed82fd2ea88db1600cdd08b
# https://github.com/dataraft-r/dataraft.lake/tree/8a05759be028f4550ed82fd2ea88db1600cdd08b
# dataraft.metrics: 3814be47ddc7878288a8470a661e169b289674ed
# https://github.com/dataraft-r/dataraft.metrics/tree/3814be47ddc7878288a8470a661e169b289674ed
# dataraft.adapters: 5f2b7844605324f313a474f493e901dde850da01
# https://github.com/dataraft-r/dataraft.adapters/tree/5f2b7844605324f313a474f493e901dde850da01
# dataraft.dbt: 9bf79f78c905c8399c4982bc23a623b16569f5c2
# https://github.com/dataraft-r/dataraft.dbt/tree/9bf79f78c905c8399c4982bc23a623b16569f5c2
# dataraft.ide: 58e2bfac623b08c8a217f5855763cc8bc329947b
# https://github.com/dataraft-r/dataraft.ide/tree/58e2bfac623b08c8a217f5855763cc8bc329947b
# dataraft-positron: 19e1e4783c6c8d282224acf10c9fab26584e23ed
# https://github.com/dataraft-r/dataraft-positron/tree/19e1e4783c6c8d282224acf10c9fab26584e23ed

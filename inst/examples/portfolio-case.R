# A deterministic, synthetic insurance portfolio for framework and Positron tests.
# All names and numbers are invented. Source this file, then call portfolio_case().
portfolio_case <- function(output_root = tempfile("portfolio-case-")) {
  idx <- seq_len(36L)
  months <- as.Date(c("2026-01-01", "2026-02-01", "2026-03-01"))
  customers <- data.frame(
    customer_id = sprintf("C%03d", seq_len(18L)),
    region = rep(c("North", "South", "West"), each = 6L),
    segment = rep(c("Household", "Small business"), 9L)
  )
  brokers <- data.frame(
    broker_id = sprintf("B%02d", seq_len(6L)),
    broker_name = c("Harbor Partners", "Oak Advisory", "River Direct",
                    "North Bridge", "Cedar Group", "City Desk"),
    channel = c("Partner", "Broker", "Direct", "Broker", "Partner", "Direct")
  )
  policies <- data.frame(
    policy_id = sprintf("P%04d", idx),
    customer_id = rep(customers$customer_id, each = 2L),
    broker_id = rep(brokers$broker_id, length.out = length(idx)),
    annual_premium = as.numeric(240 + 30 * (idx %% 9L)),
    inception_date = as.Date("2024-01-01") + 30L * idx
  )
  status <- expand.grid(policy_id = policies$policy_id, month = months,
                        KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  status$exposed_at_start <- with(status,
    month == months[[1L]] | month == months[[2L]] |
      (month == months[[3L]] & as.integer(sub("P", "", policy_id)) %% 11L != 0L))
  id_number <- as.integer(sub("P", "", status$policy_id))
  status$new_lapse <- with(status,
    (month == months[[2L]] & id_number %% 11L == 0L) |
      (month == months[[3L]] & id_number %% 8L == 0L & id_number %% 11L != 0L))
  status$status <- ifelse(
    id_number %% 11L == 0L & status$month >= months[[2L]] |
      id_number %% 8L == 0L & status$month >= months[[3L]],
    "Lapsed", "Active"
  )
  status$exposed_at_start <- as.logical(status$exposed_at_start)
  status$new_lapse <- as.logical(status$new_lapse)
  premiums <- data.frame(
    payment_id = sprintf("PAY%04d", seq_len(nrow(status))),
    policy_id = status$policy_id,
    month = as.Date(status$month),
    cash_amount = as.numeric(rep(policies$annual_premium / 12, 3L) *
      as.numeric(status$exposed_at_start))
  )
  claims <- data.frame(
    claim_id = sprintf("CLM%03d", seq_len(8L)),
    policy_id = policies$policy_id[c(2L, 5L, 9L, 14L, 20L, 25L, 31L, 35L)],
    reported_month = rep(months[2:3], each = 4L),
    claim_amount = as.numeric(c(120, 380, 95, 540, 220, 75, 410, 160))
  )
  invalid_premiums <- premiums
  invalid_premiums$cash_amount[[18L]] <- -125

  inputs <- list(customers = customers, brokers = brokers, policies = policies,
                 monthly_status = status, premiums = premiums, claims = claims)
  contracts <- list(
    customers = dataraft.core::dr_contract("customer.registry.v1",
      c(customer_id = "character", region = "character", segment = "character"),
      key = "customer_id"),
    brokers = dataraft.core::dr_contract("broker.directory.v1",
      c(broker_id = "character", broker_name = "character", channel = "character"),
      key = "broker_id"),
    policies = dataraft.core::dr_contract("policy.terms.v1",
      c(policy_id = "character", customer_id = "character", broker_id = "character",
        annual_premium = "numeric", inception_date = "Date"), key = "policy_id"),
    monthly_status = dataraft.core::dr_contract("policy.status.v1",
      c(policy_id = "character", month = "Date", exposed_at_start = "logical",
        new_lapse = "logical", status = "character"), key = c("policy_id", "month")),
    premiums = dataraft.core::dr_contract("cash.receipts.v1",
      c(payment_id = "character", policy_id = "character", month = "Date",
        cash_amount = "numeric"), key = "payment_id"),
    claims = dataraft.core::dr_contract("claim.notices.v1",
      c(claim_id = "character", policy_id = "character", reported_month = "Date",
        claim_amount = "numeric"), key = "claim_id")
  )
  ids <- c(customers = "portfolio.customer_registry", brokers = "portfolio.broker_directory",
           policies = "portfolio.policy_terms", monthly_status = "portfolio.monthly_exposure",
           premiums = "portfolio.premium_ledger", claims = "portfolio.claims_ledger")
  products <- lapply(names(inputs), function(name) {
    dataraft.core::dr_product(ids[[name]], inputs[[name]],
      contract = contracts[[name]], owner = "Portfolio Analytics",
      description = paste("Synthetic", gsub("_", " ", name), "for monthly lapse reporting"))
  })
  names(products) <- names(inputs)
  products$premiums <- products$premiums |>
    dataraft.core::dr_add_quality(
      dataraft.core::dr_quality_rule("nonnegative_cash", ~ cash_amount >= 0))
  products$monthly_status <- products$monthly_status |>
    dataraft.core::dr_add_quality(
      dataraft.core::dr_quality_rule("lapse_requires_exposure",
        ~ !new_lapse | exposed_at_start))

  invalid <- dataraft.core::dr_product("portfolio.invalid_cash_receipts",
    invalid_premiums, contract = contracts$premiums, owner = "Portfolio Analytics") |>
    dataraft.core::dr_add_quality(
      dataraft.core::dr_quality_rule("nonnegative_cash", ~ cash_amount >= 0))
  products$invalid_premiums <- invalid

  model <- NULL
  if (requireNamespace("dm", quietly = TRUE)) {
    model <- dm::dm(customers = customers, brokers = brokers, policies = policies,
                    monthly_status = status, premiums = premiums, claims = claims) |>
      dm::dm_add_pk(customers, customer_id) |>
      dm::dm_add_pk(brokers, broker_id) |>
      dm::dm_add_pk(policies, policy_id) |>
      dm::dm_add_pk(monthly_status, c(policy_id, month)) |>
      dm::dm_add_pk(premiums, payment_id) |>
      dm::dm_add_pk(claims, claim_id) |>
      dm::dm_add_fk(policies, customer_id, customers) |>
      dm::dm_add_fk(policies, broker_id, brokers) |>
      dm::dm_add_fk(monthly_status, policy_id, policies) |>
      dm::dm_add_fk(premiums, policy_id, policies) |>
      dm::dm_add_fk(claims, policy_id, policies)
    products$model <- dataraft.core::dr_product("portfolio.relational_model", model,
      contracts = contracts, owner = "Portfolio Analytics",
      description = "Six related tables with primary and foreign keys")
  }

  products$lapse_rate <- dataraft.core::dr_product(
    "portfolio.lapse_rate_by_channel", products$monthly_status,
    owner = "Portfolio Analytics",
    description = "New lapses divided by policies exposed at the start of each month"
  ) |>
    dataraft.core::dr_add_recipe(
      dataraft.core::dr_recipe() |>
        dataraft.core::dr_step_lookup(products$policies, by = "policy_id",
                                       name = "policy_terms") |>
        dataraft.core::dr_step_lookup(products$brokers, by = "broker_id",
                                       name = "broker_directory")
    ) |>
    dplyr::group_by(month, channel) |>
    dplyr::summarise(exposed = sum(exposed_at_start),
                     lapses = sum(new_lapse), .groups = "drop") |>
    dplyr::mutate(lapse_rate = lapses / exposed) |>
    dataraft.core::dr_add_contract(dataraft.core::dr_contract("lapse.rate.v1",
      c(month = "Date", channel = "character", exposed = "integer",
        lapses = "integer", lapse_rate = "numeric"), key = c("month", "channel"))) |>
    dataraft.core::dr_add_quality(dataraft.core::dr_quality_rule(
      "rate_between_zero_and_one", ~ lapse_rate >= 0 & lapse_rate <= 1)) |>
    dataraft.core::dr_add_policy(dataraft.core::dr_policy(
      "named_owner", when = "validate", require = "owner", version = "1")) |>
    dataraft.core::dr_add_output(dataraft.core::dr_output(
      "reporting", dataraft.adapters::dr_target_rds(file.path(output_root, "reporting")),
      sla = dataraft.core::dr_sla(available_by = "08:00", timezone = "UTC")))

  list(inputs = inputs, contracts = contracts, model = model,
       products = products, invalid_premiums = invalid_premiums,
       expected = list(monthly_rows = 108L, policies = 36L,
                       february_lapses = 3L, march_new_lapses = 4L,
                       march_exposure = 33L, march_rate = 4 / 33))
}

insurance_products <- function(book_root = ".") {
  book_root <- normalizePath(book_root, winslash = "/", mustWork = TRUE)
  data_path <- function(file) file.path(book_root, "data", file)

  policies_source <- dataraft.core::dr_source_file(
    "source.policies",
    data_path("policies.csv"),
    reader = utils::read.csv
  )
  brokers_source <- dataraft.core::dr_source_file(
    "source.brokers",
    data_path("brokers.csv"),
    reader = utils::read.csv
  )
  payments_source <- dataraft.core::dr_source_file(
    "source.payments",
    data_path("payments.csv"),
    reader = utils::read.csv
  )

  policies_contract <- dataraft::dr_contract(
    "policies",
    columns = c(
      policy_id = "integer",
      broker_id = "integer",
      premium = "numeric",
      status = "character"
    ),
    key = "policy_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Risk Analytics",
      grain = "One row per policy"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  policies <- dataraft::dr_product("policies", policies_source) |>
    dataraft::dr_add_contract(policies_contract) |>
    dataraft::dr_add_quality(dataraft.core::dr_quality_rule(
      "premium_non_negative",
      ~ premium >= 0,
      action = "block"
    )) |>
    dataraft::dr_add_quality(dataraft.core::dr_quality_rule(
      "known_status",
      ~ status %in% c("active", "paid_up", "lapsed"),
      action = "block"
    ))

  brokers_contract <- dataraft::dr_contract(
    "brokers",
    columns = c(broker_id = "integer", region = "character"),
    key = "broker_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Sales Operations",
      grain = "One row per broker"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  brokers <- dataraft::dr_product("brokers", brokers_source) |>
    dataraft::dr_add_contract(brokers_contract) |>
    dataraft::dr_add_quality(~ nzchar(region))

  payments_contract <- dataraft::dr_contract(
    "payments",
    columns = c(
      payment_id = "integer",
      policy_id = "integer",
      payment_date = "character",
      amount = "numeric"
    ),
    key = "payment_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Finance",
      grain = "One row per payment event"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  payments <- dataraft::dr_product("payments", payments_source) |>
    dataraft::dr_add_contract(payments_contract) |>
    dataraft::dr_add_quality(~ amount >= 0)

  portfolio_contract <- dataraft::dr_contract(
    "portfolio",
    columns = c(
      policy_id = "integer",
      broker_id = "integer",
      premium = "numeric",
      status = "character",
      region = "character"
    ),
    key = "policy_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Risk Analytics",
      grain = "One row per policy with broker region"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  portfolio_recipe <- dataraft.core::dr_recipe() |>
    dataraft.core::dr_step_lookup(
      brokers,
      by = "broker_id",
      name = "brokers"
    )

  portfolio <- dataraft::dr_product("portfolio", policies) |>
    dataraft::dr_add_contract(portfolio_contract) |>
    dataraft.core::dr_add_recipe(portfolio_recipe) |>
    dataraft::dr_add_quality(~ nzchar(region))

  payment_totals_contract <- dataraft::dr_contract(
    "payment_totals",
    columns = c(policy_id = "integer", paid = "numeric"),
    key = "policy_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Finance",
      grain = "One row per policy"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  payment_totals_recipe <- dataraft.core::dr_recipe() |>
    dataraft.core::dr_step_summarise(
      paid = sum(amount),
      .by = policy_id
    )

  payment_totals <- dataraft::dr_product("payment_totals", payments) |>
    dataraft::dr_add_contract(payment_totals_contract) |>
    dataraft.core::dr_add_recipe(payment_totals_recipe) |>
    dataraft::dr_add_quality(~ paid >= 0)

  performance_contract <- dataraft::dr_contract(
    "monthly_performance",
    columns = c(
      policy_id = "integer",
      broker_id = "integer",
      premium = "numeric",
      status = "character",
      region = "character",
      paid = "numeric",
      outstanding = "numeric"
    ),
    key = "policy_id"
  ) |>
    dataraft.core::dr_contract_meta(
      owner = "Risk Analytics",
      grain = "One row per policy for the reporting month"
    ) |>
    dataraft.core::dr_contract_policy(allow_extra = FALSE)

  performance_recipe <- dataraft.core::dr_recipe() |>
    dataraft.core::dr_step_lookup(
      payment_totals,
      by = "policy_id",
      name = "payment_totals",
      unmatched = "keep"
    ) |>
    dataraft.core::dr_step_mutate(
      paid = dplyr::coalesce(paid, 0),
      outstanding = premium - paid
    )

  monthly_performance <- dataraft::dr_product(
    "monthly_performance",
    portfolio
  ) |>
    dataraft::dr_add_contract(performance_contract) |>
    dataraft.core::dr_add_recipe(performance_recipe) |>
    dataraft::dr_add_quality(~ outstanding >= 0) |>
    dataraft.core::dr_add_policy(
      dataraft.core::dr_policy(
        "require-owner",
        when = "publish",
        require = "owner",
        action = "block"
      )
    )

  list(
    policies = policies,
    brokers = brokers,
    payments = payments,
    portfolio = portfolio,
    payment_totals = payment_totals,
    monthly_performance = monthly_performance
  )
}


insurance_release_product <- function(products, release_root) {
  if (!inherits(products$monthly_performance, "dr_product")) {
    stop("products must come from insurance_products().")
  }

  delivery_sla <- dataraft.core::dr_sla(
    freshness = 24,
    refresh = "daily",
    available_by = "09:00",
    timezone = "UTC"
  )

  output <- dataraft.core::dr_output(
    "reporting_extract",
    target = dataraft.adapters::dr_target_rds(release_root),
    version = "1",
    access = "internal",
    sla = delivery_sla
  )

  dataraft.core::dr_add_output(
    products$monthly_performance,
    output
  )
}

# Run in the existing Positron R console, with a writable workspace directory.
# This creates an ODCS YAML file and in-memory definitions; it publishes no data.
library(dataraft.core)
library(dataraft.adapters)

policies_sample <- data.frame(
  policy_id = 1:3,
  premium = c(120, -80, 100)
)
policy_contract <- dr_contract(
  "policies",
  version = "1.0.0",
  columns = c(policy_id = "integer", premium = "numeric"),
  key = "policy_id",
  rules = list(dataraft.core::dr_quality_rule(
    "nonnegative_premium",
    ~ premium >= 0
  ))
) |>
  dataraft.core::dr_contract_meta(grain = "one policy")
policies <- dr_product("policies", policies_sample, contract = policy_contract)
policies_downstream <- dr_product("policies_downstream") |>
  dataraft.core::dr_add_source(policies)

# The custom editor opens executable ODCS, not dataraft.adapters::dr_contract_yaml() metadata.
dataraft.adapters::dr_contract_odcs(policy_contract, "policies.odcs.yaml")
cat(
  "Created policies.odcs.yaml and workspace objects for the DataRaft views.\n"
)

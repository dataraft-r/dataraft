## Require metadata before publication
A product policy checks whether a product carries information that your team needs before it is published. Give the policy a stable ID and version so a later rule change can be traced.

```r
library(dataraft.core)
customers <- dr_product("customers", data.frame(id = 1L)) |>
  dr_add_policy(dr_policy("owner", require = "owner", version = "2"))

dr_check_policies(customers)
# Publication is blocked while the owner is missing.
customers$owner <- "Analytics"
dr_check_policies(customers)
```

Policies may run during validation or publication. `action = "warn"` records a warning instead of blocking. A policy checks product metadata; a contract describes rows and columns; quality rules test a delivery's data.

[Read the policy reference](/packages/dataraft.core/reference/dr_policy/) for lifecycle events and supported requirements.

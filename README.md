
# DataRaft

[![R-CMD-check](https://github.com/dataraft-r/dataraft/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dataraft-r/dataraft/actions/workflows/R-CMD-check.yaml)
[![Coverage](https://github.com/dataraft-r/dataraft/actions/workflows/coverage.yaml/badge.svg)](https://github.com/dataraft-r/dataraft/actions/workflows/coverage.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

Keep R-based reports reproducible with checked data and pinned input
versions. DataRaft is the contract, quality and reproducibility layer
for teams whose business logic lives in R. Use your existing database or
an open lakehouse, or start with compiler-free RDS releases. A changed
column type or a negative amount blocks a delivery before its target is
written. The result retains the checks and offending rows for diagnosis.

See the [one-page cheatsheet](CHEATSHEET.md), [roadmap](ROADMAP.md) and
[security policy](SECURITY.md). Numeric coverage is published per
component and commit in the [Coverage workflow
summaries](https://github.com/dataraft-r/dataraft/actions/workflows/coverage.yaml).

DataRaft is under development. Before 1.0 the current API is the
supported API.

``` r
library(dataraft)

orders <- dr_product("orders") |>
  dr_add_contract(c(id = "integer", amount = "numeric")) |>
  dr_add_quality(~ amount >= 0)

flow <- dr_workflow() |>
  dr_add_product(orders) |>
  dr_add_recipe(dr_recipe() |> dr_step_mutate(amount = round(amount, 2)))

bad_delivery <- data.frame(id = 1:3, amount = c(25, -75, 50))
checked <- dr_trial(flow, data = bad_delivery)
checked$status
#> [1] "blocked"
dr_quality_rows(checked)
#> # A tibble: 1 × 2
#>      id amount
#>   <int>  <dbl>
#> 1     2    -75
```

Correct the delivery and reuse the same workflow:

``` r
next_delivery <- data.frame(id = 1:3, amount = c(25, 75, 50))
result <- dr_trial(flow, data = next_delivery)
dr_collect(result)
#> # A tibble: 3 × 2
#>      id amount
#>   <int>  <dbl>
#> 1     1     25
#> 2     2     75
#> 3     3     50
```

A **product** defines identity, contract and quality requirements. A
**recipe** defines preparation in step order. A **workflow** binds these
definitions to sources and a target. Definitions do no I/O. `dr_trial()`
checks without writing; `dr_run()` executes the configured target.
`dr_collect()` retrieves the output.

## Start with the essentials

Start with twelve functions: `dr_product()`, `dr_contract()`,
`dr_add_contract()`, `dr_add_quality()`, `dr_recipe()`,
`dr_step_mutate()`, `dr_workflow()`, `dr_add_product()`,
`dr_add_recipe()`, `dr_trial()`, `dr_collect()` and `dr_publish()`. Add
specialized components as your workflow grows.

<figure>
<img src="man/figures/composition-architecture.svg"
alt="Products define requirements; recipes define preparation; workflows connect them to a delivery and execution." />
<figcaption aria-hidden="true">Products define requirements; recipes
define preparation; workflows connect them to a delivery and
execution.</figcaption>
</figure>

| Your goal                                                   | Function                           |
|-------------------------------------------------------------|------------------------------------|
| Check a delivery without framework writers                  | `dr_trial()`                       |
| Execute the configured sources, checks and destination      | `dr_run()`                         |
| Save checked output, using a local lake if no target is set | `dr_publish()`                     |
| Deliver data directly into an existing lake                 | `dr_ingest()` from `dataraft.lake` |
| Retrieve output after a successful run                      | `dr_collect()`                     |

Start with [why
DataRaft](https://dataraft-r.github.io/dataraft/articles/why-dataraft.html)
and the [guided
introduction](https://dataraft-r.github.io/dataraft/articles/get-started.html).

## Packages

| Package             | Responsibility                                                     |
|---------------------|--------------------------------------------------------------------|
| `dataraft`          | Metapackage and shared introduction                                |
| `dataraft.core`     | Products, contracts, recipes, workflows and quality                |
| `dataraft.lake`     | Lake storage, releases, coordinated publication and recovery       |
| `dataraft.adapters` | Database, API, RDS, Parquet and pins adapters; targets integration |
| `dataraft.dbt`      | dbt execution and artifacts                                        |
| `dataraft.catalog`  | Catalog applications and metadata publication                      |
| `dataraft.metrics`  | Metrics and frozen report evidence                                 |

Use `library(dataraft.core)` for in-memory work without the extensions.
Each extension can be installed with its declared dependencies. The
metapackage re-exports the public family API; its own R code contains no
engine.

Install the development version:

``` r
install.packages("pak")
pak::pak("dataraft-r/dataraft")
```

## When to use it

Use DataRaft when repeated deliveries need a reusable preparation
definition, quality gates and an inspectable execution result. Use
pointblank for standalone data validation, targets for pipeline
scheduling, pins for board-based object storage and dbt for SQL model
development. DataRaft adapters connect these tools to a checked delivery
workflow.

See the
[introduction](https://dataraft-r.github.io/dataraft/articles/get-started.html),
[integration
guide](https://dataraft-r.github.io/dataraft/articles/integrations.html)
and [guarantees and
limits](https://dataraft-r.github.io/dataraft/articles/guarantees.html).

For persistence without an optional storage engine, use
`dr_publish(flow, data = delivery, to = dr_target_rds("data/orders"))`.
The result’s `outputs$version` pins that delivery for `dr_source_rds()`.
After a failed pipe, `dr_last_failure()` retrieves the failed result for
diagnosis.

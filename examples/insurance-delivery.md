# One negative premium should stop a policy delivery

An insurer receives policy data every month. Before these values enter a report,
the delivery must satisfy a shared schema and the premium must be nonnegative.
This example uses synthetic data and works entirely in memory.

```r
library(dataraft)
demo <- dr_demo()
demo$blocked$status
dataraft.core::dr_quality_rows(demo$blocked)
dr_collect(demo$passed)
```

The first delivery contains a premium of -80. The trial returns a blocked result
with check evidence. Correcting that row to 80 allows the same product definition
to pass. No target is written by either trial.

For a lapse-rate calculation, checking a nonnegative premium is only the first
control. You also need a unique policy key, valid status codes, a consistent
observation period and an explicit definition of the denominator. For example,
if the portfolio is the set of policies exposed at the beginning of the year,
the simple count ratio is:

```r
policies <- data.frame(
  policy_id = 1:4,
  exposed_at_start = c(TRUE, TRUE, TRUE, FALSE),
  lapsed_in_period = c(FALSE, TRUE, FALSE, FALSE)
)
stopifnot(!anyDuplicated(policies$policy_id))
with(policies, sum(lapsed_in_period & exposed_at_start) / sum(exposed_at_start))
# 1 / 3
```

That count ratio is illustrative, not an actuarial exposure-weighted estimate.
The treatment of entries, partial-year exposure and reinstatements must be part
of the agreed definition before use in reporting. DataRaft's role is to make the
agreed controls inspectable and to block invalid deliveries. A lake release can
then retain the checked input version; governed metrics can preserve approved
results. Storage and experimental integrations can be added after this small
workflow is useful to another person.

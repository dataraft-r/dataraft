**DataRaft helps a team turn incoming data into checked, reusable results whose origins can still be explained later.**

Imagine an insurer preparing a cancellation report every month. It receives policy data, checks it, calculates a cancellation rate and puts the number in a report. In December, someone asks: “Why did the September report show 8.1%?” To answer, the team needs the September input, the checks it passed and the agreed definition of the rate. DataRaft helps keep those pieces together.

The 8.1% below is an **illustrative number**, not a result calculated by this page.

## First, what is an R package?

**R** is a language people use to work with data. An **R package** is a set of ready-made tools for R. A team can define a recurring reporting process once and use the same definition for each new delivery.

DataRaft does not decide what “cancellation” means for the business. People define that rule. DataRaft helps record it, apply it consistently and inspect what happened.

## One story from input to report

<ol class="story-flow" aria-label="Illustrative monthly reporting flow">
<li><strong>Receive</strong><span>September policy data arrives from a database or file.</span></li>
<li><strong>Define</strong><span>A contract says which fields and values are expected.</span></li>
<li><strong>Check</strong><span>A negative premium is found, corrected and checked again.</span></li>
<li><strong>Keep</strong><span>The accepted September version gets a reference.</span></li>
<li><strong>Explain</strong><span>A defined rate and its reporting evidence point back to that version.</span></li>
</ol>

This is a picture of a possible workflow, not a single command that runs every component automatically. You choose the parts your project needs.

## What is the `dataraft` metapackage?

Think of the metapackage as the **front door to a set of tools**. It offers the common R commands for products, contracts, checks and runs. Specialist commands remain in separate component packages. You can use just `dataraft.core` for a small in-memory check, or install the family when your workflow grows.

| Tool | Plain-English job | In the September report |
|---|---|---|
| `dataraft` | Common starting point | Gives R users a small shared set of commands. |
| [`dataraft.core`](/packages/dataraft.core/) | Define and check a product | States what a valid policy delivery is and finds bad rows. |
| [`dataraft.adapters`](/packages/dataraft.adapters/) | Connect sources and destinations | Reads a database or file and can send output to a chosen target. Catalog connectors live here too. |
| [`dataraft.lake`](/packages/dataraft.lake/) | Keep governed versions | Publishes and finds the accepted September delivery. |
| [`dataraft.metrics`](/packages/dataraft.metrics/) | Define and retain reported measures | Helps explain which definition and inputs supported a reported rate. |
| [`dataraft.dbt`](/packages/dataraft.dbt/) | Connect existing SQL preparation | Incorporates an existing dbt process when the team uses one. |
| [`dataraft.ide`](/packages/dataraft.ide/) | Translate R context for the editor | Supplies product and run information to a supported editor. |
| [Positron extension](/extension/) | Show that context in the editor | Lets a person inspect products, checks and relationships in a visual interface. |

There is no active `dataraft.catalog` R package in this family. Catalog connectors belong to `dataraft.adapters`. The dbt, metrics and IDE integrations are experimental.

## `dataraft.core`: Define what valid data looks like

A **data product** is a named, reusable description of a delivery and what should happen to it. Our example product might be called “checked policies for the cancellation report.” A **data contract** spells out expectations: each policy has an ID, the premium is numeric, and the status is meaningful. **Quality rules** check an actual delivery against further conditions, such as “premium must be at least zero.”

| Policy ID | Premium | Status |
|---|---:|---|
| A123 | €100 | Active |
| A124 | €80 | Cancelled |
| A125 | −€500 | Active |

The last row violates the premium rule. A blocking check prevents this delivery from being accepted by that run; the team can inspect the offending row, correct the input and check again. A warning rule is different: it may allow the run to continue. A completed run without a declared contract does **not** mean the data has passed contract validation.

DataRaft can also describe preparation that should happen the same way each month. For example, two sources might use different words for a cancelled policy. The team decides how to map those words before calculating a shared rate.

**Next:** [Define a product and run your first check](/start/2/).

## `dataraft.adapters`: Connect the data

Policy records might come from a database and customer records from a file. An adapter is a connector for such a source or destination. The product can use the appropriate connector without first moving all company data into a new platform.

Adapters also include catalog connections. A catalog is like an index of available data: what a dataset is for, who is responsible for it and how to find it. Publishing catalog metadata is a separate configured action, not something that happens whenever someone opens a product.

For a small local start, an RDS target can save checked results as versions without a database service. [See the local publishing chapter](/start/4/).

## `dataraft.lake`: Find the same version later

Once the September delivery has passed the chosen checks, a team can publish it as a lake release. The release reference helps them find that exact accepted version again, even after later deliveries and corrections. This supports the December question: which September policies were used?

| Report month | Example retained input |
|---|---|
| July | Accepted July policy version |
| August | Accepted August policy version |
| September | Accepted September policy version |

The lake supports governed releases and coordination for supported configurations. A local RDS target is a smaller alternative with different guarantees. A check with `write = FALSE` checks the current delivery but does not create a release or reserve a future read of the source. [Read the guarantees and limits](/learn/guarantees/).

## `dataraft.metrics`: Explain a reported number

The cancellation rate may look simple: **cancelled policies ÷ policies considered**. Yet a team must decide what counts as cancelled, which period applies, what enters the denominator and how corrections are handled. Different definitions can produce different numbers with the same label.

The metrics package provides tools to define and measure a metric and to retain evidence for a frozen report result. For the illustrative September rate, a useful explanation would identify the definition, the checked input version and the report that used it. These details must be configured and recorded by the workflow; DataRaft cannot infer a business definition or automatically prove an arbitrary number in a report.

The metrics integration is experimental. [See the package and its exact functions](/packages/dataraft.metrics/).

## `dataraft.dbt`: Include an existing SQL workflow

Some teams already use **dbt** to prepare data with SQL. DataRaft can connect to that process and its artifacts instead of asking the team to re-create SQL preparation in R. A reporting workflow might use prepared dbt data as an input, check a delivery and then publish a result. This integration is optional and experimental. [See `dataraft.dbt`](/packages/dataraft.dbt/).

## `dataraft.ide` and the Positron extension: Inspect the work

`dataraft.ide` is a bridge that makes selected R information available to an editor. The [DataRaft extension](/extension/) is the visible interface in Positron: a person can open a product, inspect its contract, view quality results and follow relationships. The extension also offers guided contract editing. Reading a view does not publish a data release; a trial or write is a deliberate action.

The extension's YAML editor also works in VS Code. Live R inspection needs Positron, the optional bridge and an appropriate R session. The [feature gallery](/extension/) shows real captures and explains the supported actions.

## Putting the pieces together

1. **Connect:** `dataraft.adapters` reads policy records and, if needed, customer data.
2. **Describe:** `dataraft.core` defines the policy product, its contract and checks.
3. **Investigate:** A negative premium blocks the delivery; someone corrects it and runs the check again.
4. **Retain:** `dataraft.lake` publishes the accepted September version, if the team has chosen a lake. A smaller setup can publish to an RDS target instead.
5. **Measure:** `dataraft.metrics` uses an agreed cancellation definition and retains report evidence, if that integration is part of the workflow.
6. **Inspect:** `dataraft.ide` and the Positron extension help people explore products, results and relationships. If SQL preparation already uses dbt, `dataraft.dbt` can connect to it.

The practical result is a clearer answer to “Where did 8.1% come from?”: the team can point to the definition and retained evidence **when it has configured and published those pieces**. The first useful step can be much smaller: define one product, check one delivery and inspect one bad row.

[Start with the five-chapter tutorial](/start/) · [Explore the packages](/packages/) · [See the Positron extension](/extension/)

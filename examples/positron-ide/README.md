# Install and manually check DataRaft in Positron

The deliverables are `dataraft.ide_0.1.0.9002.tar.gz`,
`dataraft-positron.vsix` and `dataraft-ide-source.zip`. The ZIP contains the
`dataraft.ide` and `dataraft-positron` source folders. The R bridge is also
available from its published immutable review commit. Install the extension
from the supplied VSIX; no marketplace listing is required.

Automated tests do not replace the manual checks below. Hosted extension CI,
including the graphical extension-host smoke test, passed. A real Positron GUI
manual acceptance session remains unrun.

## Install the R bridge and VSIX

Use R 4.2 or newer; the automated family checks use R 4.5.1. Run the following in
the R installation used by your Positron console. The two GitHub references are
verified merged component commits. `fs`, `jsonlite` and `rlang` are bridge
imports; `yaml` and the adapters package enable the ODCS editor workflow.

```r
install.packages("pak", repos = "https://cloud.r-project.org")
pak::pkg_install(c(
  "dataraft-r/dataraft.core@6fca8a7f5882ae13f14613739f9adaf586a7d105",
  "dataraft-r/dataraft.adapters@11de81f09e5ce05d55379a7e4670527f1717e411",
  "fs", "jsonlite", "rlang", "yaml"
), dependencies = NA)
install.packages(
  "/path/to/dataraft.ide_0.1.0.9002.tar.gz",
  repos = NULL,
  type = "source"
)
stopifnot(requireNamespace("dataraft.ide", quietly = TRUE))
```

Replace the archive path with its actual local path. Instead of installing the
local archive, install the same reviewed bridge from GitHub:

```r
pak::pkg_install(
  "dataraft-r/dataraft.ide@4de09339a5262baa73e5c4c02112d9143f357e78",
  dependencies = NA
)
```

Alternatively, after
installing the dependencies, run `R CMD INSTALL /path/to/dataraft.ide` against
the extracted source folder. The bridge has no native code to compile, although
some dependencies may need system libraries when installed from source.

In Positron run **Extensions: Install from VSIX**, select
`dataraft-positron.vsix`, and reload the window if prompted. Open a trusted,
writable workspace and start an R console. The extension selects an existing
idle console; it does not start a new R session.

In Workbench or another remote workspace, install the workspace extension on
the same host as R. The extension and R must share the temporary directory and
saved YAML paths. A local extension host with a separately hosted R session is
not supported. Ordinary VS Code supports offline JSON viewing and YAML editing;
live R commands require Positron.

## Create the sample workspace

Run [workspace.R](workspace.R) in that R console, with the workspace directory as
the working directory. It creates:

- `policies_sample`, a three-row table with one negative premium;
- `policies`, a product with an explicit `nonnegative_premium` quality rule;
- `policies_downstream`, a product that depends on `policies`;
- `policies.odcs.yaml`, an executable ODCS 3.2 contract.

No lake is opened and no data is published. The YAML is generated with
`dr_contract_odcs()`. The portable `dr_contract_yaml()` metadata export is not an
executable ODCS contract and is not the input for this editor.

## Manual checks and expected observations

1. Run **DataRaft: Select R Session**, then **DataRaft: Select Workspace or Lake**
   and choose the R workspace. Run **DataRaft: Refresh Metadata**. The Data
   Products view should show the sample table and both products. Check the
   metadata capture timestamp; refresh is manual, not polling.
2. Select `policies` and run **DataRaft: Inspect Product**. Inspect the contract,
   columns, explicit rule and source metadata. Run **DataRaft: Trial Product**
   deliberately. The negative premium should block this trial. This command
   executes product code and source reads, but does not publish its target.
3. Select the sample table or a trial result and run **DataRaft: View Bounded
   Rows in R**. Rows should open in R's data viewer. Table cells are not sent
   through the extension's metadata transport.
4. Run **DataRaft: Show Directed Lineage** for `policies_downstream`. Check the
   edge direction from its `policies` input to the downstream product. Selecting
   a graph node should focus its matching product in the tree. Workspace
   definitions do not imply persisted lake releases or run history.
5. Run **DataRaft: Open Contract YAML Editor** and open `policies.odcs.yaml`.
   Change a supported field, inspect the proposed diff and choose **Apply
   preview to document**. The YAML buffer should become dirty, without silently
   saving. **Compare with saved file** should show your unsaved change. Save
   explicitly before an R validation request.
6. To demonstrate a profile-driven column addition, run this in the selected R
   console, then return to the contract editor:

   ```r
   policies_sample$policy_status <- c("active", "lapsed", "active")
   ```

   Click **Propose columns from R sample** and choose `policies_sample`. In
   **Select inferred columns to preview**, explicitly select `policy_status`.
   Review the proposed YAML diff, choose **Apply preview to document**, and save.
   Inferred required flags describe this sample only. The separate command
   **DataRaft: Profile Selected Workspace Table** displays profile metadata.
7. Click **Validate saved contract in R**, then **Check selected R sample** and
   choose `policies_sample`. The saved contract should import, while the sample
   check should report `nonnegative_premium` failing. The corresponding YAML
   diagnostic should point to that uniquely named rule. The equivalent palette
   command is **DataRaft: Check Bounded Table Sample against Saved Contract**.
   Counts describe a bounded sample, not full-data quality or a governed run.
8. Confirm that dirty YAML must be saved before R validation and that edits
   made while a request is outstanding invalidate its old result. Diagnostics
   must not guess source locations for unnamed, ambiguous or unmapped rules.
   Aliases and custom YAML tags require plain YAML editing rather than the form.
9. If using a separately configured real lake, inspect its releases, Runs,
   Freshness and Incidents views. **DataRaft: Show Frozen Report Metadata** lists
   report identifiers and timestamps. The small workspace example has no
   persisted lake evidence, so empty lake-only results are expected.

Record your Positron version, operating system, R version, installation host,
which checks passed and any actual error messages. A busy or missing R session,
untrusted workspace or unavailable shared path should produce an explanatory
error, not a fabricated successful refresh.

## Optional native phase 0 helpers

The reviewed phase 0 metapackage and its pinned family dependencies provide
`dr_review()`, `dr_catalog_pane()` and `dr_refresh_connection()`. Its installation
command is recorded below using the published immutable review commit:

```r
pak::pkg_install("dataraft-r/dataraft@9df6d47dd2ebcfbedef368b2bbfa7fbddb404ac7")
```

Run [demo.R](demo.R) for a blocked in-memory delivery, bounded failure inspection
and a versioned local RDS delivery. It needs no database server. The generated
release directory is temporary; remove it when finished. In an interactive
session, `dr_review()` opens the diagnostic table through the IDE's `View()`.

RDS is a file adapter. It does not provide a DBI connection, registry, live lake
catalog or Connections entry. Use `dr_lake_config()` and `dr_connect_lake()` for
a real DuckDB/DuckLake lake. Its Connections entry follows the connection's
lifecycle; `dr_refresh_connection(lake)` explicitly refreshes the tree.

For a metadata snapshot you previously exported with `dr_catalog_export()`:

```r
app <- dr_catalog_pane(snapshot = "catalog.json", launch = FALSE)
# Foreground execution in an interactive session:
dr_catalog_pane(snapshot = "catalog.json")
```

Shiny supplies its actual listening URL to the IDE viewer and falls back to a
browser if the viewer is unavailable. The R session is occupied until Shiny
stops. Keep a supplied live lake connection open throughout. `launch = FALSE`
returns the app object; it does not start a background server.

The [phase checklist](../../docs/plans/positron-ide.md) separates implemented
features, automated evidence, unrun manual checks and the eight-package CI
acceptance gate. The first eight-package remote run and native Positron
automation have passed; human usability sign-off remains separate. There are
no production publish, approval or scheduling controls in the extension.

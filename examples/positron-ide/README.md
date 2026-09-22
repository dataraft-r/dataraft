# Work with DataRaft in Positron

Run `demo.R` in your R console for an in-memory contract check, bounded failure
inspection and a versioned local RDS delivery. It needs no database server or
compiler. The output directory is temporary; remove it when finished.

`dr_review(result, rule = "nonnegative_premium", limit = 20)` opens the offending
rows through the IDE's `View()` implementation. Use `what = "report"` or
`what = "lineage"` for the corresponding diagnostic metadata. The default row
limit prevents accidental collection of an entire failed large dataset.

The RDS example is deliberately a file adapter. It does not provide the DBI
connection, registry, live lake metadata or Connections entry of a connected
DuckDB/DuckLake lake. To use those capabilities, configure and open a real lake
using `dr_lake_config()` and `dr_connect_lake()`. Its IDE connection registration
follows the live connection lifecycle. `dr_refresh_connection(lake)` explicitly
refreshes the IDE tree after changes.

For a catalog snapshot produced by `dr_catalog_export()`:

```r
# The path must refer to your existing exported metadata snapshot.
app <- dr_catalog_pane(snapshot = "catalog.json", launch = FALSE)
# In an interactive session, the following starts Shiny in the foreground:
dr_catalog_pane(snapshot = "catalog.json")
```

When a live lake is supplied instead, keep the lake open until Shiny stops.
Shiny provides the listening URL to the IDE viewer; an unavailable viewer falls
back to your browser. The R session is occupied while the app runs. This is not
a background server sharing the connection. `launch = FALSE` returns the app
object for your own hosting workflow.

Install the optional `dataraft.ide` package from the supplied local source bundle
(`R CMD INSTALL /path/to/dataraft.ide`) and install the supplied
`dataraft-positron` VSIX through Positron's extension installer. New-repository
publication is pending GitHub App access; there is not yet a published pinned
IDE package installation to recommend. The extension
uses the selected active R session. It asks that session for versioned metadata
through `dataraft.ide::ide_request()` and a private response file, not by parsing
console output. Refresh explicitly after changing R objects; a timestamp shows
when metadata was captured. Metadata are a snapshot of that session, not a
background scheduler or an alternative source of truth.

The contract editor uses YAML as its sole writable source. It does not rewrite
R source or create a separate recipe definition. A supplied data sample can
support profiling and quality feedback; it does not establish production data
quality. Source diagnostics require explicit, exact source locations and are
not attached to guessed lines. See the
[implementation checklist](../../docs/plans/positron-ide.md) for scope and checks.

# DataRaft repository audit

Audit date: 2026-10-02

## Scope

The audit covered the active repositories visible in the `dataraft-r` organization and the organization profile. The code, README, DESCRIPTION, NAMESPACE, NEWS, source tree, representative source files, tests, examples, and current package boundaries were inspected through GitHub. The book treats source code and current tests as authoritative when older descriptions differ.

## Repository map

| Repository | Version / status | Verified purpose |
|---|---|---|
| dataraft | 0.1.0.9006 | Metapackage, 18 common verbs including demo |
| dataraft.core | 0.1.0.9006 | Products, contracts, quality, recipes, execution, diagnostics, lineage, policies, ports, SLAs |
| dataraft.adapters | 0.1.0.9006 | RDS, database, Parquet, pins, API, Iceberg, OpenMetadata, OpenLineage, ODCS, catalog UI |
| dataraft.lake | 0.1.0.9006 | DuckDB / DuckLake releases, registries, lifecycle, recovery, integrity |
| dataraft.metrics | 0.1.0.9006, experimental | Reusable metrics and retained report evidence, not a full semantic layer |
| dataraft.dbt | 0.1.0.9006, experimental | dbt project/build/artifact integration and managed lake publication |
| dataraft.ide | 0.1.0.9007, experimental | Bounded metadata bridge for IDE clients |
| dataraft-positron | 0.2.0, optional | Positron extension for product/quality/lineage views and contract editing |
| dataraft.catalog | moved | No active R package; catalog functionality moved to adapters |
| .github | active | Organization profile |

## Dependency model

Core is the logical center. Adapters and lake import core. Metrics imports core and uses lake for retained reports. dbt imports core and lake. IDE imports core and optionally lake/adapters. The Positron extension depends on the IDE bridge for live metadata.

## Public API findings that changed the proposed book

1. `dr_trial()` is retired and tested to be absent. The book uses `dr_run()`.
2. `dr_contract()` currently has five core arguments: id, columns, key, rules, version.
3. Contract metadata and validation policy are composed separately with `dr_contract_meta()` and `dr_contract_policy()`.
4. Quality rules support block, warn, and quarantine actions plus thresholds.
5. `dr_last_failure()` and `dr_review()` are implemented diagnostic tools.
6. Static column lineage is conservative and explicitly reports incomplete analysis.
7. Governance policies, input/output ports, and SLAs are implemented in core.
8. Multiple output ports are sequential and not atomic across destinations.
9. Catalog integrations are owned exclusively by adapters.
10. Metrics, dbt, and IDE remain experimental and are presented that way.

## Supported physical categories

Verified categories include in-memory data, local RDS releases, DBI database adapters, Parquet/Arrow, pins, API sources, experimental Iceberg, local DuckDB lakes, DuckLake, local/S3 storage, DuckDB/PostgreSQL registries, OpenMetadata, OpenLineage, and experimental dbt integration.

## Current lifecycle

The current code supports the conceptual path:

`define -> validate -> execute -> quality gate -> completed/published/blocked/error -> collect or diagnose -> optional durable release`

Lake publication adds immutable landing/candidate/release behavior, registry metadata, recovery, integrity verification, and product lifecycle state.

## Important limitations

- DataRaft is not a distributed compute engine.
- Cross-destination publication is not a distributed transaction.
- Static column lineage is intentionally incomplete for opaque transformations.
- `dataraft.metrics` is not a general semantic layer.
- Catalog integrations require external services and do not replace local executable contracts.
- RDS checksums detect accidental modification, not malicious replacement by an actor able to rewrite both data and evidence.
- Experimental packages may evolve faster than the core surface.

## Verification model

The book has two executable verification layers. First, the companion insurance project is tested with testthat, including a blocked delivery, product lineage, governed RDS publication, publish-policy evidence, an output port, and SLA evidence. Second, selected core teaching examples are native Quarto R cells and execute while HTML and PDF are rendered in CI against the pinned DataRaft revisions.

The Pandoc/LibreOffice fallback remains available for environments without R or Quarto. Fallback artifacts prove manuscript and static-diagram renderability only; they do not execute R. Upstream DataRaft repositories independently test their package behavior and README examples.


## Audited source revisions

The audit used the following default-branch revisions as its source-state markers:

| Repository | Revision |
|---|---|
| dataraft | `1053863d0c3eb94f5d8356c59a4cb1701e700991` |
| dataraft.core | `d9cb454d0b60a7d1ba23ff7298b064f16af80c05` |
| dataraft.adapters | `87a39686af0bafa40e64f9130a3ef2877ed64423` |
| dataraft.lake | `113c17913fe326145b285a6c5720a0753a207b2c` |
| dataraft.metrics | `513e09ea8143aaaefae5db319ebd7a807744f123` |
| dataraft.dbt | `3a9d744a5c79ae4a436c661ea9f1ffb92a84ffaa` |
| dataraft.ide | `282f1297253915cd4644d349b18da09629aecd5c` |
| dataraft-positron | `a05a8040d310b305f37ffde438f44b3e2ba44178` |

## Publication model

The book is integrated under `book/` of the umbrella `dataraft` repository. A dedicated book workflow verifies the pinned package family, runs the runnable example tests, and renders HTML and PDF. The existing website workflow renders the HTML book into `website/dist/book`, so the public URL is `https://dataraft-r.github.io/dataraft/book/`. This hosting choice does not change package ownership or API status.


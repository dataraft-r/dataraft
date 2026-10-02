# Book thesis and mental model

## Thesis

A reliable R data platform does not begin with a lake, catalog, or orchestrator. It begins when a recurring delivery becomes an explicit product: named, prepared, checked against a contract, diagnosable when it fails, and publishable through a replaceable physical target.

## Central mental model

`source -> product definition -> preparation -> contract + quality gate -> accepted run -> collect or publish -> evidence + lineage -> consumption`

The model separates three layers:

1. **Meaning**: product identity, contract, business metadata, policies, ports.
2. **Execution**: sources, recipes, checks, run state, diagnostics.
3. **Physical realization**: RDS, databases, Parquet, pins, DuckDB/DuckLake, S3, catalogs.

## Learning progression

The reader first sees a complete in-memory workflow, then learns contracts and quality, then preparation and execution, then storage and product composition, then evidence and governance, and only then the larger platform architecture.

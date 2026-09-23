# Roadmap and release criteria

DataRaft is an experimental R-native contract, quality and reproducibility layer.
The seven-package structure remains. The existing lake supports current users;
open storage adapters let teams keep their database or lakehouse.

## Data-product lifecycle expansion

The current development family includes registered product transitions, input and
output ports, organization policies, registered-dependency impact analysis,
scheduled delivery SLA evaluation, bounded date backfills, lifecycle hooks and
two starter blueprints. Port SLAs are evaluated on publication and retained in
run evidence. Several output ports can publish one checked delivery in sequence.

Publication across separate targets is not atomic. A failed later output records
which ports committed and requires inspection before retrying. Impact analysis
covers registered dependencies, not unknown external consumers. The bounded
Lake backfill replaces complete date partitions; general CDC and orchestration
remain outside DataRaft. The registry blocks releases for retired products;
enrolling previously unregistered products in an active-only publication policy
is still a separate lifecycle decision.

## This review

- Individual reference pages, execution cheatsheet and standard vocabulary.
- ODCS 3.2 interchange with an explicit executable subset and fail-closed imports.
- Block, warn and local quarantine, plus descriptive governance metadata.
- Conservative static column lineage and versioned aggregate profile comparison.
- Experimental Iceberg REST publication and snapshot reads through DuckDB.
- File-first projects, automated accessibility checks and manual audit procedure.

## Before a stable release

- Exercise Iceberg writes, rollback and concurrent changes against supported REST
  catalogs. Do not infer storage guarantees from unit tests alone.
- Expand ODCS executable coverage with schema-backed fixtures from other engines.
- Add distribution-based drift methods with calibrated false-positive behavior;
  missingness comparisons alone are not an anomaly-detection service.
- Record manual keyboard and assistive-technology audit results. Automated checks
  cover only part of WCAG 2.2 AA.
- Recruit a consenting second maintainer. Review contributions, agree support and
  release responsibilities, then grant least-privilege repository access. Do not
  list anyone as maintainer before agreement and accepted responsibility.
- Review exported extension interfaces and coordinate compatibility changes
  across component releases.

CRAN submission is explicitly deferred. There are no promised release dates or
production certifications. Coverage reports and CI show their tested commit and
environment; neither demonstrates an untested backend's reliability.

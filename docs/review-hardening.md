# Review hardening status

This work addresses correctness and reproducibility before expanding integrations.
It does not constitute a stable public release.

| Review priority | Change | Boundary |
| --- | --- | --- |
| Closure-sensitive fingerprints | Referenced closure bindings enter canonical identity; unsupported mutable state fails explicitly | A fingerprint is evidence identity, not an R environment archive |
| Release order | Catalog publication order replaces client wall-clock ordering | Legacy history is retained; historical clock order cannot be reconstructed with certainty |
| Frozen report verification | `dr_report_verify()` recomputes against pinned inputs and stored hashes; manifests record environment identity | Environment mismatch is reported; a fingerprint does not install an old runtime |
| Reproducible CI | Immutable sibling baselines, version bounds, fixed R and dated CRAN repository | Runner images and Python transitive dependencies are not fully locked |
| Cross-repo detection | Separate nightly family HEAD compatibility job | Nightly intentionally tests moving commits and records resolved IDs |
| Rule engine changes | Engine selection preserves rule metadata and action | Optional engines retain their declared capability limits |
| Retention | Explicit retention/expiry and file cleanup interface | Cleanup is opt-in and honors reader safety and retained release references |
| Writer concurrency | Asset-scoped explicit writer locking | Backend catalog concurrency limits still apply |
| Integration identity | Source-based OpenLineage identity and source-based dbt code hashes | dbt builds are not atomic DataRaft releases |
| Contract robustness | Randomized edge-case coverage and typed condition assertions | This is not exhaustive proof across every driver/type combination |
| Onboarding | `dr_demo()`, inherited examples, insurance walkthrough and adapter guide | Demo is an in-memory quality gate, not a production storage benchmark |

The hardening focus is core, lake and adapters. dbt, catalog and metrics are
experimental. Metrics provides governed definitions and frozen approved results,
not a full entity/join/time-granularity semantic engine. A bounded benchmark
checks retained result size and correctness while recording elapsed time;
it does not enforce a machine-dependent speed threshold.

Not claimed complete: governed Iceberg releases with rollback and partition or
schema evolution; general incremental or CDC writes; a full MetricFlow/Cube
semantic compiler; a packaged Python API; fully locked external service/container
dependencies; CRAN submission; public family tags and release publication.
The Python interoperability guide demonstrates existing interfaces rather than
advertising a new Python package. Actual external adoption must be established
through use, not inferred from tests.

See each component's tests, NEWS and reference for precise behavior. Local tests
provide development evidence; GitHub integration jobs must pass on the final
remote commit set before a supported release is announced.

## Review branches and validation evidence

The coordinated component pull requests are
[core #4](https://github.com/dataraft-r/dataraft.core/pull/4),
[lake #4](https://github.com/dataraft-r/dataraft.lake/pull/4),
[adapters #4](https://github.com/dataraft-r/dataraft.adapters/pull/4),
[dbt #4](https://github.com/dataraft-r/dataraft.dbt/pull/4),
[catalog #4](https://github.com/dataraft-r/dataraft.catalog/pull/4), and
[metrics #4](https://github.com/dataraft-r/dataraft.metrics/pull/4).
The umbrella family lock identifies the exact component commits under review.

Local component suites recorded 2,640 passing assertions, seven skipped tests
and three existing SQL warnings. The final umbrella suite recorded 288 passing
assertions, no failures or errors, four skips and one existing SQL warning.
Across all seven packages this is 2,928 passing assertions, 11 skipped tests and
four existing warnings. Skips and warnings are retained in test output and are
not counted as passing assertions.

The pinned checkout and manifest checker passed against the actual six remote
component commits. Their tracked contents matched the locally tested sources.
All six component packaging checks found code, Rd and NAMESPACE checks clean.
Core and adapters reported missing installed vignette documentation because
vignette builds were deliberately skipped; lake noted optional paws.storage;
the other three component checks reported Status OK. These limited packaging
checks do not substitute for complete documentation and integration CI.

The adapters minimal-dependency job passed on GitHub. Full external integration
CI remains pending on the final pinned set; local results do not claim otherwise.

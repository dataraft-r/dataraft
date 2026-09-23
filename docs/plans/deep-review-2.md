# Second review implementation

The public entry surface is enforced by a namespace test: 17 product-oriented
verbs plus `dr_demo()`. Advanced functions require their component namespace.
`dr_set_sources()` adds or replaces named primary inputs; named `NULL` removes
one, and `sources = NULL` clears all. `dr_add_contract(x, NULL)` removes a contract.
The redundant source/contract CRUD accessors are no longer public exports.

Rules store `action` and `threshold`. Legacy constructor arguments warn through
lifecycle; native and pointblank rules use the same policy vocabulary. Diagnostic
`severity` remains part of the versioned evidence/IDE schema, not rule state.

A dry run repeats nonvolatile checks. Productive runs use a process-local,
bounded cache keyed by the serialized rule definition. A rule without a cached
comparison is checked twice before caching; a changed definition gets a new key.
Static rejection of known nondeterministic operations always runs. The cache is
not a proof of purity, does not certify external state, and is never persisted
as an approval. Live reference checks remain ineligible. New R sessions must
verify anew. No rows or unit vectors are retained by this cache.

`dr_trial()` is soft-deprecated and now uses the same failure default as
`dr_run()`. Use `dr_run(x, write = FALSE, stop_on_failure = FALSE)` to inspect
failures without throwing. Removal is scheduled for 2027-01-01.
The catalog compatibility package is scheduled for retirement on 2027-01-01.
Use the catalog functions in dataraft.adapters immediately.

Lookup constraint checks use dm exclusively. `native` is no longer an accepted
lookup engine. The unused partition capability is removed; partitioned lake
publication remains available through `partition_by`.

The full CI profile rejects every skipped test except two named optional
OpenMetadata SDK/CLI integration cases. Their names, reasons and counts remain
in test-skips.csv. The PostgreSQL job runs real concurrent processes, lock
contention, stale correction and killed-writer recovery. A new two-release test
covers contract schema evolution and preservation of old releases.
The extension rejects attempts to override its response channel, and its real R
integration verifies containment errors do not stall later requests.

The modular workflow wrapper and its run/publish/validate/inspect S3 methods
are removed. The deprecated empty builder returns a product, and adding a
specification merges its slots directly. Function dependency graphs remain a
distinct orchestration API in core: they have a real dependency/status model.
`dr_contract()` exposes identity, columns, key, rules and version; legacy metadata
in `...` is deprecated. Compose metadata and policy explicitly instead.
Recursive source replacement is available through `dr_set_sources(...,
.recursive = TRUE)`; the old graph-replacement name is no longer exported.

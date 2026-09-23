# Development family compatibility

`family-lock.json` records full immutable Git commit IDs, package versions,
R 4.5.1 and a dated Posit Package Manager CRAN snapshot. It is a development
compatibility set, not a release announcement. R package dependencies have
explicit minimum family versions. Development `Remotes` select the coordinated
branch; exact compatibility is established only by this umbrella's lockfile.
There are no duplicated component lockfiles.

Component CI obtains the umbrella's matching PR branch when present, otherwise
main, then checks out every sibling at the immutable SHA in that manifest. It
records the actual umbrella and component commits in `check/resolved-family.json`.
The tested component itself is the PR checkout. Matching branch selection chooses
a manifest, never a moving sibling baseline. The umbrella entry uses `ref: "self"`
because a commit cannot contain its own hash. `scripts/check-family.py` validates
the resolved component SHAs, package set and dependency bounds.

The separate nightly HEAD workflow intentionally fetches all seven `main`
branches, then runs the family check. This discovers cross-repository breaking
changes without making ordinary checks depend on changing sibling branches.
All resolved commits are printed in the job log.

The full component job installs all declared Suggests and fails a dependency
preflight if any cannot load. Its minimal job tests graceful absence of optional
engines; a passing minimal job is not evidence that integrations ran. R CMD check
logs retain explicit test skip reasons. Real service tests remain separate from
in-memory tests, including the umbrella dbt executable and PostgreSQL jobs.

Before publishing a family release:

1. Finish component checks and record immutable component commit IDs in the
   umbrella manifest. Move development Remotes to the intended stable branch when merging.
2. Run pinned family checks, the real dbt and PostgreSQL checks, documentation
   examples, and the benchmark smoke job on this exact set.
3. Update versions and dependency lower bounds together, then tag components
   and record the resulting supported combination. Never move an existing tag.
4. Publish the install instructions for that set and retain its CI evidence.

All GitHub Actions are pinned to immutable commit IDs; Python uses patch version 3.12.13.
The dated CRAN snapshot fixes available package versions, but runner images and external service behavior can still change. Python dbt
packages are pinned directly; their complete transitive environment is not yet
locked. Do not describe this setup as a bit-for-bit reproducible build.

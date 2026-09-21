# DataRaft package boundaries

Each package lives in its own repository under https://github.com/dataraft-r.
This repository owns the metapackage, shared documentation and integration tests.
CI checks out component repositories into `packages/` and installs them in dependency
order. That directory is excluded from the metapackage build.

The core owns definitions, recipes, execution protocols, in-memory execution and
quality gates. Lake, adapter, dbt, catalog and metrics packages own their respective
implementations. Their Imports graph is acyclic. Optional core methods can call
an installed extension, but an in-memory workflow does not load one.

Shared implementation helpers are currently exported with internal documentation
so cross-package calls use declared interfaces rather than `:::`. They are not
re-exported by the umbrella. Further reducing that helper surface is separate
from the user-facing API and requires replacing remaining concrete integration
branches with narrower protocols.

The shared integration suite lives in the umbrella; its test-only helper binds
implementation functions from their owning namespace. That fixture is never
installed as production code. The core additionally has standalone tests and a
CI job with no extension or optional engine installed.

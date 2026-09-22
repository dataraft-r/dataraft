# Maintaining the pinned compatibility set

Owner: the DataRaft maintainer, currently Jan-Hendrik Weinert. Review upstream
Positron stable releases, the R/CRAN snapshot and family compatibility at least
monthly and before any public release. Review security fixes promptly rather
than waiting for that cadence. The nightly family HEAD workflow detects sibling
breakage; it does not automatically rewrite reviewed pins.

Pinning is a deliberate trade-off: repeatable builds cost coordinated updates.
Do not replace SHAs with moving branches to make updates easier.

1. Publish component changes as review commits. Update the affected entries in
   `family-lock.json`, matching `Remotes` references in `DESCRIPTION`, and any
   extension R installation manifest that consumes those components.
2. Record each package's actual `DESCRIPTION` version. Different development
   suffixes are valid; run `python scripts/check-family.py` on the checked-out
   compatibility set. Never require version equality between siblings.
3. For a Positron upgrade, use the official stable release and checksum manifest.
   Update the extension's `positron-release.json` URL, SHA-256 and packaged
   executable size together. Inspect the downloaded, checksum-verified artifact
   to obtain size and product identity; do not guess or weaken verification.
4. Run component full/minimal checks, the complete eight-package matrix and the
   extension's native Positron/Ark R user journeys for the proposed combination.
   Keep failure logs, screenshot artifacts and resolved version evidence.
5. Review the pin diff and successful run links before merge. Preserve the
   prior combination in Git so rollback is a normal revert. Human Positron
   acceptance is recorded separately with person, platform and observed results.

The extension owns its desktop runtime pin. The umbrella owns the supported
family compatibility set. Each component owns its independent test baseline.
They serve different boundaries; an update does not imply every pin must move.

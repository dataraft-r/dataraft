"""Generate existing DESCRIPTION family references from a reviewed lockfile.

This command never fetches commits, changes package versions, adds dependencies,
or rewrites component lockfiles. All target files are validated before writing.
"""
import argparse
import json
from pathlib import Path
import re
import sys

FIELD = re.compile(r"^([A-Za-z][A-Za-z0-9/]*):([^\n]*(?:\n[ \t]+[^\n]*)*)", re.M)
SHA = re.compile(r"[0-9a-f]{40}")
VERSION = re.compile(r"[0-9]+(?:[.-][0-9]+)+")


def validate_lock(lock):
    if lock.get("schema_version") != 1 or not isinstance(lock.get("packages"), dict):
        raise ValueError("Expected family-lock schema version 1")
    packages = lock["packages"]
    for name, spec in packages.items():
        if not re.fullmatch(r"dataraft(?:\.[a-z]+)?", name):
            raise ValueError(f"Unexpected family package: {name}")
        if spec.get("repository") != "dataraft-r/" + name:
            raise ValueError(f"Unexpected repository for {name}")
        if not VERSION.fullmatch(spec.get("version", "")):
            raise ValueError(f"Invalid package version: {name}")
        ref = spec.get("ref", "")
        if not (name == "dataraft" and ref == "self") and not SHA.fullmatch(ref):
            raise ValueError(f"An immutable commit is required for {name}")
    return packages


def synchronize(text, packages):
    fields = {match[1]: match[2].strip() for match in FIELD.finditer(text)}
    name = fields.get("Package")
    if name not in packages:
        raise ValueError(f"DESCRIPTION is not a locked family package: {name}")

    def replace(match):
        field, value = match[1], match[2]
        if field == "Remotes":
            entries = [entry.strip() for entry in value.split(",")]
            updated = []
            for entry in entries:
                remote = re.fullmatch(r"(?:github::)?(dataraft-r/dataraft(?:\.[a-z]+)?)(?:@[^\s]+)?", entry)
                if remote:
                    sibling = remote[1].split("/")[1]
                    if sibling not in packages:
                        raise ValueError(f"Family remote missing from lock: {sibling}")
                    ref = packages[sibling]["ref"]
                    if ref == "self":
                        raise ValueError("Cannot use umbrella 'self' as a dependency commit")
                    entry = remote[1] + "@" + ref
                elif "dataraft-r/dataraft" in entry:
                    raise ValueError(f"Unsupported family remote syntax: {entry}")
                updated.append(entry)
            return field + ": " + ",\n    ".join(updated)
        if field in ("Imports", "Suggests", "Depends", "LinkingTo"):
            def dependency(dep):
                sibling = dep[1]
                if sibling not in packages:
                    raise ValueError(f"Family dependency missing from lock: {sibling}")
                if dep[2] and not re.fullmatch(r"\s*\(>=\s*[0-9]+(?:[.-][0-9]+)+\)", dep[2]):
                    raise ValueError(f"Refusing to replace a non-minimum constraint: {sibling}")
                return sibling + " (>= " + packages[sibling]["version"] + ")"
            value = re.sub(
                r"(?<![A-Za-z0-9._])((?:dataraft\.[a-z]+)|dataraft)(?![A-Za-z0-9._])(\s*\([^)]*\))?",
                dependency, value,
            )
        return field + ":" + value

    return FIELD.sub(replace, text)


def main(argv=None):
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repositories", nargs="*", type=Path,
                        help="Repository directories; defaults to this umbrella")
    parser.add_argument("--lock", type=Path, default=root / "family-lock.json")
    parser.add_argument("--check", action="store_true", help="Report drift without writing")
    args = parser.parse_args(argv)
    try:
        packages = validate_lock(json.loads(args.lock.read_text()))
        changes = []
        for repository in args.repositories or [root]:
            path = repository / "DESCRIPTION"
            before = path.read_text()
            after = synchronize(before, packages)
            if before != after:
                changes.append((path, after))
        for path, after in changes:
            if not args.check:
                path.write_text(after)
            print(("Out of sync: " if args.check else "Updated: ") + str(path))
        return 1 if args.check and changes else 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())

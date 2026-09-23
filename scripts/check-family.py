"""Validate a development family compatibility manifest without publishing it."""
import json
import os
import subprocess
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[1]
lock = json.loads((root / "family-lock.json").read_text())
mode = os.environ.get("DATARAFT_FAMILY_MODE", "pinned")
assert mode in ("pinned", "head"), "Unknown family mode"
expected = {"dataraft"} | {"dataraft." + x for x in ("core", "lake", "adapters", "metrics", "dbt", "ide")}
assert lock["schema_version"] == 1
assert set(lock["packages"]) == expected
assert re.fullmatch(r"\d+\.\d+\.\d+", lock["r_version"])
assert re.fullmatch(r"https://packagemanager\.posit\.co/cran/\d{4}-\d{2}-\d{2}", lock["cran_snapshot"])
resolved_packages = {}
for name, spec in lock["packages"].items():
    assert spec["repository"] == "dataraft-r/" + name
    if name == "dataraft":
        assert spec["ref"] == "self", "Umbrella must identify its containing commit"
    else:
        assert re.fullmatch(r"[0-9a-f]{40}", spec["ref"]), name
    path = root if name == "dataraft" else root / "packages" / name
    description = path / "DESCRIPTION"
    if not description.exists():
        raise SystemExit("Missing checkout: " + str(path))
    resolved = subprocess.check_output(
        ["git", "-C", str(path), "rev-parse", "HEAD"], text=True
    ).strip()
    resolved_packages[name] = {**spec, "ref": resolved}
    if name != "dataraft" and mode == "pinned":
        assert resolved == spec["ref"], (name, resolved, spec["ref"])
    text = description.read_text()
    assert re.search(r"^Package: " + re.escape(name) + "$", text, re.M)
    version = re.search(r"^Version: (.+)$", text, re.M)[1]
    assert version == spec["version"], (name, version, spec["version"])
    # Imported siblings need an explicit supported lower version.
    imports = re.search(r"^Imports:(.*(?:\n +.*)*)", text, re.M)[1]
    for sibling in re.findall(r"dataraft\.[a-z]+", imports):
        assert re.search(re.escape(sibling) + r" \(>= [^)]+\)", imports), (name, sibling)
(root / "check").mkdir(exist_ok=True)
(root / "check" / "resolved-family.json").write_text(json.dumps(
    {"mode": mode, "packages": resolved_packages}, indent=2
) + "\n")
print("Family manifest and dependency version bounds are consistent.")

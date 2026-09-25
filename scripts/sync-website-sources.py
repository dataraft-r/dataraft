"""Refresh immutable website source copies and their file-level provenance."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "website/content"
LOCK = json.loads((ROOT / "family-lock.json").read_text())
SOURCES = SITE / "sources.json"
MANIFEST = SITE / "source-manifest.json"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def refresh(name, ref, source):
    destination = SITE / "upstream" / name
    destination.mkdir(parents=True, exist_ok=True)
    for file in destination.iterdir():
        if file.is_file():
            original = source / file.name
            if name == "dataraft" and file.name == "insurance-delivery.md":
                original = source / "examples" / file.name
            if original.is_file():
                shutil.copyfile(original, file)
            else:
                file.unlink()
    for folder in ("man", "vignettes"):
        if (destination / folder).exists():
            shutil.rmtree(destination / folder)
        if (source / folder).exists() and name != "dataraft-positron":
            shutil.copytree(source / folder, destination / folder)
    # Product policies and other new reference topics must enter the snapshot.
    for file in ("README.md", "DESCRIPTION", "NAMESPACE", "NEWS.md"):
        original = source / file
        if original.exists() and name != "dataraft-positron":
            shutil.copyfile(original, destination / file)
    if name == "dataraft-positron":
        shutil.copyfile(source / "README.md", destination / "README.md")
    return ref


def checked_out(name, ref, scratch):
    target = scratch / name
    subprocess.run(["git", "init", "-q", str(target)], check=True)
    subprocess.run(["git", "-C", str(target), "fetch", "-q", "--depth=1",
                    f"https://github.com/dataraft-r/{name}.git", ref], check=True)
    subprocess.run(["git", "-C", str(target), "checkout", "-q", "--detach", "FETCH_HEAD"], check=True)
    actual = subprocess.check_output(["git", "-C", str(target), "rev-parse", "HEAD"], text=True).strip()
    if actual != ref:
        raise ValueError(f"Unexpected {name} checkout: {actual}")
    return target


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", action="append", required=True)
    parser.add_argument("--extension-ref", help="Immutable Positron commit SHA")
    args = parser.parse_args()
    sources = json.loads(SOURCES.read_text())
    with tempfile.TemporaryDirectory() as tmp:
        for name in args.package:
            if name == "dataraft":
                ref = subprocess.check_output(["git", "-C", str(ROOT), "rev-parse", "HEAD"], text=True).strip()
                path = ROOT
            else:
                ref = args.extension_ref if name == "dataraft-positron" else LOCK["packages"][name]["ref"]
                if not ref or len(ref) != 40:
                    raise ValueError(f"Provide a full immutable ref for {name}")
                path = checked_out(name, ref, Path(tmp))
            sources[name] = refresh(name, ref, path)
            print(name, ref)
    SOURCES.write_text(json.dumps(sources, indent=2) + "\n")
    manifest = {name: {str(path.relative_to(SITE / "upstream" / name)): sha(path)
                       for path in sorted((SITE / "upstream" / name).rglob("*")) if path.is_file()}
                for name in sorted(sources)}
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()

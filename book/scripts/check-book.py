from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
qmds = sorted(ROOT.rglob("*.qmd"))
executable_cells = 0

required_runnable = [
    "part-2/04-first-workflow.qmd",
    "part-2/05-contracts.qmd",
    "part-2/06-quality.qmd",
    "part-3/07-recipes.qmd",
    "part-3/09-storage.qmd",
    "part-4/12-lineage.qmd",
]

for path in qmds:
    text = path.read_text(encoding="utf-8")
    executable_cells += len(re.findall(r"^\\`\\`\\`\\{r(?:\\s[^}]*)?\\}\\s*$", text, flags=re.M))
    if "sandbox:/mnt/data/" in text or "/mnt/data/" in text:
        errors.append(f"{path.relative_to(ROOT)} contains a local build path")
    if "\u2014" in text:
        errors.append(f"{path.relative_to(ROOT)} contains an em dash")

    for match in re.finditer(r"!\\[[^\\]]*\\]\\(([^)]+)\\)(\\{[^}]*\\})?", text):
        target, attrs = match.group(1), match.group(2) or ""
        if re.match(r"^[a-z]+://", target):
            continue
        asset = (path.parent / target).resolve()
        if not asset.exists():
            errors.append(f"{path.relative_to(ROOT)} references missing image {target}")
        if "fig-alt=" not in attrs:
            errors.append(f"{path.relative_to(ROOT)} image {target} has no fig-alt text")

for rel in required_runnable:
    text = (ROOT / rel).read_text(encoding="utf-8")
    if not re.search(r"^\\`\\`\\`\\{r(?:\\s[^}]*)?\\}\\s*$", text, flags=re.M):
        errors.append(f"{rel} must contain at least one executable R cell")

if executable_cells < 8:
    errors.append(
        f"Only {executable_cells} executable R cells found; core teaching examples must run in CI"
    )

config = (ROOT / "_quarto.yml").read_text(encoding="utf-8")
for rel in re.findall(r"(?m)^\\s*-?\\s*(?:part:\\s*)?([A-Za-z0-9_./-]+\\.qmd)\\s*$", config):
    if not (ROOT / rel).exists():
        errors.append(f"_quarto.yml references missing file {rel}")

retired = {
    "dr_trial", "dr_add_product", "dr_update_product", "dr_remove_product",
    "dr_extract_product", "dr_replace_sources", "dr_update_contract",
    "dr_remove_contract", "dr_extract_contract", "dr_update_source",
    "dr_remove_source", "dr_extract_source"
}
code_pattern = r"\\`\\`\\`(?:\\{r(?:\\s[^}]*)?\\}|\\{\\.r\\}|r)\\s*\\n(.*?)\\`\\`\\`"
for path in qmds:
    text = path.read_text(encoding="utf-8")
    for block in re.findall(code_pattern, text, flags=re.S):
        for name in retired:
            if re.search(rf"\\b{re.escape(name)}\\s*\\(", block):
                errors.append(f"{path.relative_to(ROOT)} uses retired call {name}()")

for rel in ["data/policies.csv", "data/brokers.csv", "data/payments.csv"]:
    if not (ROOT / rel).exists():
        errors.append(f"Runnable companion fixture is missing: {rel}")

if not (ROOT / "references.bib").exists():
    errors.append("references.bib is missing")

if errors:
    print("Book checks failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print(
    f"Checked {len(qmds)} QMD files and {executable_cells} executable R cells: "
    "paths, fixtures, images, alt text, and retired API calls are clean."
)

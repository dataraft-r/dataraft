from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
qmds = sorted(ROOT.rglob('*.qmd'))

# Keep rendering independent from R. Runnable behavior is tested separately.
for path in qmds:
    text = path.read_text(encoding='utf-8')
    if re.search(r'^```\{r(?:\s|\})', text, flags=re.M):
        errors.append(f'{path.relative_to(ROOT)} contains an executable R cell')
    if 'sandbox:/mnt/data/' in text or '/mnt/data/' in text:
        errors.append(f'{path.relative_to(ROOT)} contains a local build path')
    if '—' in text:
        errors.append(f'{path.relative_to(ROOT)} contains an em dash')

    for match in re.finditer(r'!\[[^\]]*\]\(([^)]+)\)(\{[^}]*\})?', text):
        target, attrs = match.group(1), match.group(2) or ''
        if re.match(r'^[a-z]+://', target):
            continue
        asset = (path.parent / target).resolve()
        if not asset.exists():
            errors.append(f'{path.relative_to(ROOT)} references missing image {target}')
        if 'fig-alt=' not in attrs:
            errors.append(f'{path.relative_to(ROOT)} image {target} has no fig-alt text')

# Check that every qmd path named in the Quarto book config exists.
config = (ROOT / '_quarto.yml').read_text(encoding='utf-8')
for rel in re.findall(r'(?m)^\s*-?\s*(?:part:\s*)?([A-Za-z0-9_./-]+\.qmd)\s*$', config):
    if not (ROOT / rel).exists():
        errors.append(f'_quarto.yml references missing file {rel}')

# Retired calls must not return in runnable teaching code.
retired = {
    'dr_trial', 'dr_add_product', 'dr_update_product', 'dr_remove_product',
    'dr_extract_product', 'dr_replace_sources', 'dr_update_contract',
    'dr_remove_contract', 'dr_extract_contract', 'dr_update_source',
    'dr_remove_source', 'dr_extract_source'
}
for path in qmds:
    text = path.read_text(encoding='utf-8')
    for block in re.findall(r'```(?:\{\.r\}|r)\s*\n(.*?)```', text, flags=re.S):
        for name in retired:
            if re.search(rf'\b{re.escape(name)}\s*\(', block):
                errors.append(f'{path.relative_to(ROOT)} uses retired call {name}()')

if not (ROOT / 'references.bib').exists():
    errors.append('references.bib is missing')

if errors:
    print('Book checks failed:')
    for error in errors:
        print(f'- {error}')
    sys.exit(1)

print(f'Checked {len(qmds)} QMD files: paths, images, alt text, code cells, and retired API calls are clean.')

from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
q = (root / '_quarto.yml').read_text(encoding='utf-8')
# Keep the canonical order explicit so the fallback is stable.
files = [
'index.qmd',
'part-1/index.qmd',
'part-1/01-bigger-than-a-data-frame.qmd','part-1/02-from-scripts-to-products.qmd','part-1/03-architecture.qmd',
'part-2/index.qmd',
'part-2/04-first-workflow.qmd','part-2/05-contracts.qmd','part-2/06-quality.qmd',
'part-3/index.qmd',
'part-3/07-recipes.qmd','part-3/08-execution.qmd','part-3/09-storage.qmd','part-3/10-composition.qmd',
'part-4/index.qmd',
'part-4/11-diagnostics.qmd','part-4/12-lineage.qmd','part-4/13-metadata.qmd','part-4/14-governance.qmd',
'part-5/index.qmd',
'part-5/15-logical-physical.qmd','part-5/16-modern-stack.qmd','part-5/17-environments-testing-cicd.qmd',
'part-6/index.qmd',
'part-6/18-small-platform.qmd','part-6/19-change-safely.qmd','part-6/20-operating-platform.qmd',
'part-7/index.qmd',
'part-7/21-design-principles.qmd','part-7/22-when-not-to-use.qmd',
'appendices/a-installation.qmd','appendices/b-package-map.qmd','appendices/c-api-map.qmd','appendices/d-configuration.qmd','appendices/e-compatibility.qmd','appendices/f-troubleshooting.qmd','appendices/g-glossary.qmd','appendices/h-further-reading.qmd','references.qmd']
parts=[]
for f in files:
    s=(root/f).read_text(encoding='utf-8')
    # Quarto-specific Mermaid cells become fenced code in the fallback.
    s=s.replace('```{mermaid}','```mermaid')
    s=re.sub(r'^%%\|.*$', '', s, flags=re.M)
    # R executable cells become ordinary highlighted code for Pandoc fallback.
    s=s.replace('```{r}','```r')
    s=re.sub(r'^#\|.*$', '', s, flags=re.M)
    # Resolve project assets after concatenating nested chapters.
    s=s.replace('../diagrams/', 'diagrams/')
    s=re.sub(r'(diagrams/[^)\s]+)\.svg', r'\1.png', s)
    # Remove Quarto callout wrappers while retaining text.
    s=re.sub(r'^:::\s*\{[^}]+\}\s*$', '', s, flags=re.M)
    s=re.sub(r'^:::\s*$', '', s, flags=re.M)
    parts.append(s)
(root/'_build'/'book.md').write_text('\n\n'.join(parts), encoding='utf-8')

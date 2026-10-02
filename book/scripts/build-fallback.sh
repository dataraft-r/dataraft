#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p _build
python3 scripts/assemble.py
python3 scripts/make_reference_docx.py >/dev/null

common=(
  --standalone
  --toc
  --toc-depth=2
  --number-sections
  --citeproc
  --bibliography=references.bib
  --resource-path=.
  --metadata title="Data Platforms with R"
  --metadata subtitle="From scripts to governed data products with DataRaft"
  --metadata author="DataRaft Contributors"
)

pandoc _build/book.md "${common[@]}" \
  --css=custom.css \
  --embed-resources \
  -o _build/Data-Platforms-with-R.html

# Keep a DOCX build as a portable secondary format.
pandoc _build/book.md "${common[@]}" \
  --reference-doc=reference.docx \
  -o _build/Data-Platforms-with-R.docx

# Prefer print CSS for the fallback PDF because it preserves wide tables and
# source-controlled diagrams more faithfully than office conversion.
rm -f _build/Data-Platforms-with-R.pdf
if command -v weasyprint >/dev/null 2>&1; then
  weasyprint _build/Data-Platforms-with-R.html _build/Data-Platforms-with-R.pdf
elif command -v chromium >/dev/null 2>&1; then
  python /home/oai/skills/pdfs/scripts/html_to_pdf.py \
    _build/Data-Platforms-with-R.html \
    --output _build/Data-Platforms-with-R.pdf \
    --format A4
else
  libreoffice --headless --convert-to pdf --outdir _build \
    _build/Data-Platforms-with-R.docx >/dev/null
fi

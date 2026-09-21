# Accessibility checks

The documentation workflow runs axe against a real Shiny catalog session and
HTML quality output, including keyboard interaction with catalog tabs and search.
All detected WCAG 2 A/AA, 2.1 AA and 2.2 AA violations fail the gate. Results,
incomplete checks and screenshots are uploaded for review. This is an automated
regression check, not a claim of full WCAG 2.2 AA conformance.

Before release, record browser, assistive technology, OS and package versions,
then manually check populated and empty catalogs and long quality reports:

- Keyboard-only traversal, visible focus, tab activation and no focus traps.
- NVDA/Firefox or VoiceOver/Safari: headings, landmarks, table headers, status
  text, dynamically updated results and form labels.
- 200% and 400% zoom, narrow viewport, contrast and high-contrast mode.
- No meaning conveyed solely by color or icons; report statuses have text.
- Console with NO_COLOR=1 and redirected plain output remains understandable.
- Architecture diagrams have meaningful descriptions and equivalent nearby prose.

Do not close an incomplete axe result without a documented manual decision.
The repository does not yet claim a completed independent accessibility audit.

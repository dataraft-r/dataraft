# DataRaft documentation website

A static English documentation site for the DataRaft package family and editor extension.

## Build

```sh
python -m pip install -r requirements.txt
BASE_PATH=/dataraft python build.py
BASE_PATH=/dataraft python check.py
```

The generated HTML in `dist/` is deployable on any static host. Every route has its own HTML page; JavaScript adds search, copying and mobile navigation. Reading and navigation also work without JavaScript.

## Sources

`content/upstream/` contains documentation snapshots, not executable package implementations. `content/sources.json` records exact upstream commits. Update those snapshots intentionally and rebuild. Curated introductory chapters and the shared renderer are in `build.py`. Styles and client-side behavior are in `assets/`.

The reference renderer preserves documented signatures, arguments, values, details, named sections and examples from Rd files. It does not execute R or claim examples have been rerun for this website build.

Screenshots are original Positron captures from successful native extension-host CI run 35942174468, extension commit fa33c697d8b8cbc80db83e8c7955a032fc7eea9e. They show synthetic fixtures in the actual application, not a recreated UI. VS Code supports offline metadata and YAML editing; the native R flows shown require Positron.

## Validation

`check.py` validates every internal page link, fragment and local asset. The website build does not establish R-package or extension runtime correctness.

MIT license. Package documentation and extension assets are by Jan-Hendrik Weinert and contributors; original notices are retained in the upstream snapshots.

## GitHub Pages

`.github/workflows/website.yaml` builds and publishes this site after website changes on main. The older Documentation workflow still validates the R/pkgdown examples and archives its output, but does not overwrite Pages. The renderer rewrites links and search URLs using BASE_PATH, and retains redirects from the prior pkgdown article and reference URLs.

## Extension feature gallery

The feature guides are maintained in `content/extension/features.json`. `content/extension/screenshots.json` records the successful native capture run, extension commit, original dimensions and SHA-256 for each PNG. The documentation captures are produced by the native Positron click suite in dataraft-positron. Images are not cropped or composited.

## Hands-on training

`/training/` is an English course with 39 main modules, 15 extension modules and
25 optional deep dives, split into 133 small steps. `training.py` renders the
commented R source in `content/training/dataraft_training.R` into chapter indexes
and individual module pages. That same source is copied to
`/downloads/dataraft_training.R`, so downloadable and displayed code stay aligned.
Keep section IDs, goals, prerequisites, expected results, tasks and solutions when
adding exercises. Solutions use native HTML details and remain usable without JS.
The existing search, copy controls and responsive shell apply to course pages.

The course runs locally in R, not in the browser. The source records component
commits, runtime validation and untested integrations. The English edition's
local default path was also executed successfully; website builds only render
and check the content. Optional switches remain off by default.

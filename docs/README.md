# Product page (scaffold)

`index.html` is a placeholder for the public Peel product page. It's self-contained, so there
are no external assets, fonts, or scripts to load. Light and dark both work automatically.

## Status

Not launched yet. Two things are deliberately still off:

1. **GitHub Pages isn't enabled** on this repo. Turn it on under Settings → Pages → Source:
   `main` / `/docs` when we're ready.
2. **`index.html` carries `<meta name="robots" content="noindex">`.** Delete that line at
   launch. It's there so an unfinished placeholder doesn't get indexed.

## Screenshots

The page has labelled screenshot slots and no images. That's on purpose, and it's the main
thing blocking launch.

Every screenshot has to come from a clean demo profile seeded with public repos. Not from a
working machine. Peel's app state holds real repository and pull-request names, and those
render straight into the Repositories sidebar, the Inbox, Boards, and the swarm views. The
source code is clean. The runtime state isn't, so a screenshot taken from a real install leaks
by default.

Captures go in `docs/assets/screenshots/` using the filenames the slots already reference.

Before any image lands here it needs to pass a denylist and OCR check, and someone has to look
at it at full resolution. Don't skip that. A leak on a public Pages site is permanent.

## Copy

Text here draws on `README.md`, `FEATURES.md`, and `SWARMS.md`, but it isn't a straight copy.
Voice follows `STYLE_GUIDE.md` in the crunchy-blog repo. Keep the claims in sync with those
files even when the wording differs.

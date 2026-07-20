# Product page (scaffold)

`index.html` is a placeholder for the public Peel product page. It is self-contained — no
external assets, fonts, or scripts — and supports light and dark automatically.

## Status

**Not launched.** Two things are deliberately still pending:

1. **GitHub Pages is not enabled** on this repository. Enable it under
   Settings → Pages → Source: `main` / `/docs` when ready to publish.
2. **`index.html` carries `<meta name="robots" content="noindex">`.** Remove that line at
   launch. It exists so an unfinished placeholder does not get indexed.

## Screenshots

The page has labelled screenshot slots and no images. This is intentional and is the main
blocker to launch.

Every screenshot must be captured from a **sanitized demo profile** seeded with public
repositories only — never from a working machine. Peel's app state includes real repository
and pull-request names, which render into the Repositories sidebar, Inbox, Boards, RAG
catalog, and swarm views. The source code is clean; the *runtime state* is not, so a
screenshot taken from a working machine leaks by default.

Captures go in `docs/assets/screenshots/` using the filenames already referenced in the slots.

Before any image lands here, a denylist + OCR check must pass, and every image needs a
full-resolution human review. Do not skip this — a leak on a public Pages site is permanent.

## Copy

Text is drawn from `README.md`, `FEATURES.md`, and `SWARMS.md` in this repository. Keep them
in sync; those files are the source of truth.

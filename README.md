# gh-pages

This branch is published output, not source. GitHub Pages serves it at the repo root.

**Don't edit files here.** Edit `docs/` on `main`, then run `scripts/publish-page.sh` from `main`
to rebuild this branch. Anything you change here directly gets overwritten on the next publish.

`.nojekyll` stops GitHub from running the content through Jekyll. The site is plain static HTML
and doesn't need it.

## Turning Pages on

Settings → Pages → Source: **Deploy from a branch** → Branch: `gh-pages` / `/ (root)`.

## Before you call it launched

`index.html` still carries `<meta name="robots" content="noindex">`. That's deliberate while the
page is a placeholder with no screenshots. Remove the line in `docs/index.html` on `main` and
republish when the real thing is ready.

Screenshots are the remaining blocker. They have to come from a clean demo profile rather than a
working machine, because Peel's runtime state holds private repo names even though its source
doesn't. See `docs/README.md` on `main`.

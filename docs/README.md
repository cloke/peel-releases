# Product page (source)

`index.html` is the public Peel product page. It's self-contained, so there are no external
assets, fonts, or scripts to load. Light and dark both work automatically.

This directory is the **source**. The published copy lives on the `gh-pages` branch. Edit here,
never there.

## Publishing

```bash
./scripts/publish-page.sh            # check, then publish to gh-pages
./scripts/publish-page.sh --check    # run the safety gate only
```

The script copies `docs/` to the root of `gh-pages` and pushes. It refuses to publish if the
safety gate fails.

To serve it: Settings → Pages → Source: **Deploy from a branch** → Branch: `gh-pages` / `/ (root)`.

## Status

Not launched yet. Two things are deliberately still off:

1. **`index.html` carries `<meta name="robots" content="noindex">`.** Delete that line at launch.
   It's there so an unfinished placeholder doesn't get indexed.
2. **No screenshots.** The page has labelled empty slots. This is the real blocker.

## The safety gate

Every screenshot has to come from a clean demo profile seeded with public repos. Not from a
working machine. Peel's app state holds real repository and pull-request names, and those render
straight into the Repositories sidebar, the Inbox, Boards, and the swarm views. The source code is
clean. The runtime state isn't, so a screenshot from a real install leaks by default.

`publish-page.sh` enforces this in three passes:

- greps all site text against a denylist
- checks filenames, which OCR can't catch
- OCRs every image against the same denylist

The denylist comes from `~/.peel/off-scope-markers.txt`, one token per line. That file is never
committed. Override the path with `PEEL_OFF_SCOPE_MARKERS` if you need to.

Two deliberate behaviors worth knowing. Publishing images without a marker file is a hard failure,
because images are the high-risk surface. Publishing images without `tesseract` installed is also
a hard failure, so run `brew install tesseract` before the first screenshot lands. A text-only
publish with no marker file only warns, since a page with no images can't leak one.

**Automation doesn't replace looking.** Check every image at full resolution before it goes out.
OCR misses low-contrast and small text routinely, and a leak on a public Pages site is permanent.

Captures go in `docs/assets/screenshots/` using the filenames the slots already reference.

## Copy

Text here draws on `README.md`, `FEATURES.md`, and `SWARMS.md`, but it isn't a straight copy.
Voice follows `STYLE_GUIDE.md` in the crunchy-blog repo. Keep the claims in sync with those files
even when the wording differs.

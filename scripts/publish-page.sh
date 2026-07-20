#!/usr/bin/env bash
# Publish docs/ to the gh-pages branch.
#
# gh-pages is built output. docs/ on main is the source. Run this from main
# after editing docs/, and never hand-edit gh-pages.
#
# Everything is checked before it goes out, because a leak on a public Pages
# site is permanent. Text gets grepped against a denylist and images get OCR'd
# against the same one.
#
#   ./scripts/publish-page.sh            publish
#   ./scripts/publish-page.sh --check    run the gate only, publish nothing

set -euo pipefail

MARKERS="${PEEL_OFF_SCOPE_MARKERS:-$HOME/.peel/off-scope-markers.txt}"
BRANCH="gh-pages"
SRC="docs"
CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

[[ -d "$SRC" ]] || { echo "error: no $SRC/ directory here" >&2; exit 1; }
[[ -f "$SRC/index.html" ]] || { echo "error: $SRC/index.html is missing" >&2; exit 1; }

fail() { echo "GATE FAILED: $*" >&2; exit 1; }

# ---------------------------------------------------------------- the gate

images=()
while IFS= read -r -d '' f; do images+=("$f"); done \
  < <(find "$SRC" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) -print0)

if [[ ! -f "$MARKERS" ]]; then
  if (( ${#images[@]} > 0 )); then
    fail "$MARKERS not found, and there are ${#images[@]} image(s) to publish.
       Images are the high-risk surface. Create the marker file (one token per
       line, # for comments) before publishing any screenshot."
  fi
  echo "warning: $MARKERS not found. Text-only publish, so continuing."
  echo "         Create it before the first screenshot lands."
  patterns=""
else
  patterns="$(grep -vE '^\s*(#|$)' "$MARKERS" || true)"
  [[ -n "$patterns" ]] || echo "warning: $MARKERS is empty."
fi

if [[ -n "$patterns" ]]; then
  echo "Scanning text in $SRC/ ..."
  while IFS= read -r token; do
    # Left word boundary only, so "tio" catches "tio-api" but not "ratio".
    if grep -rinE "\\b${token}[-_/.[:alnum:]]*" "$SRC" \
         --include='*.html' --include='*.md' --include='*.css' \
         --include='*.js' --include='*.json' --include='*.svg' 2>/dev/null; then
      fail "denylist token '${token}' appears in $SRC/ text (above)."
    fi
  done <<< "$patterns"
  echo "  text clean"

  # Filenames before OCR. This one is cheap and needs no tooling, so it should
  # never be skipped just because tesseract is missing.
  while IFS= read -r token; do
    if find "$SRC" -iname "*${token}*" -print -quit | grep -q .; then
      fail "denylist token '${token}' appears in a filename under $SRC/"
    fi
  done <<< "$patterns"
  echo "  filenames clean"

  if (( ${#images[@]} > 0 )); then
    command -v tesseract >/dev/null 2>&1 \
      || fail "${#images[@]} image(s) to publish but tesseract is not installed.
       Install it with: brew install tesseract"
    echo "OCR over ${#images[@]} image(s) ..."
    for img in "${images[@]}"; do
      text="$(tesseract "$img" - 2>/dev/null || true)"
      while IFS= read -r token; do
        if grep -qiE "\\b${token}" <<< "$text"; then
          fail "denylist token '${token}' found by OCR in $img"
        fi
      done <<< "$patterns"
    done
    echo "  images clean"
  fi
fi

if grep -rq 'robots' "$SRC/index.html" && grep -q 'noindex' "$SRC/index.html"; then
  echo "note: index.html still carries robots noindex, so the page will not be indexed."
fi

if (( ${#images[@]} == 0 )); then
  echo "note: no screenshots yet. The page publishes with empty slots."
fi

if $CHECK_ONLY; then
  echo
  echo "Gate passed. Nothing published (--check)."
  exit 0
fi

# --------------------------------------------------------------- publish

command -v rsync >/dev/null 2>&1 || { echo "error: rsync not found" >&2; exit 1; }

git show-ref --verify --quiet "refs/heads/$BRANCH" \
  || git fetch origin "$BRANCH:$BRANCH" 2>/dev/null \
  || { echo "error: no $BRANCH branch locally or on origin" >&2; exit 1; }

work="$(mktemp -d)"
cleanup() { git worktree remove --force "$work" 2>/dev/null || true; rm -rf "$work"; }
trap cleanup EXIT

git worktree add --quiet "$work" "$BRANCH"

# --delete so removed files actually disappear from the published site.
# Keep .git and the branch README, which documents the branch itself.
rsync -a --delete --exclude='.git' --exclude='README.md' "$SRC"/ "$work"/
touch "$work/.nojekyll"

cd "$work"
if git diff --quiet && git diff --cached --quiet && [[ -z "$(git status --porcelain)" ]]; then
  echo "No changes to publish."
  exit 0
fi

git add -A
git commit -q -m "Publish from docs/ ($(git -C "$repo_root" rev-parse --short HEAD))"
git push -q origin "$BRANCH"

echo
echo "Published $BRANCH from $SRC/ at $(git -C "$repo_root" rev-parse --short HEAD)."

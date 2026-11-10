#!/usr/bin/env bash
# Shrink old manubot versions on a gh-pages checkout (see manubot/rootstock#523)
# - PDFs: Ghostscript /ebook (lossy, ~20x smaller)
# - PNGs: downscale to <= 1000 px on the long side, then oxipng
# Keeps untouched: root files, v/latest, v/freeze, the current build, v1.0
#
# Usage: ci/shrink_gh_pages.sh <gh-pages checkout> <sha of the current build>
#   git worktree add --detach ../gh-pages origin/gh-pages
#   ci/shrink_gh_pages.sh ../gh-pages "$(git rev-parse origin/main)"
# Then commit there (with [ci skip]) and `git push origin HEAD:gh-pages`.
# Safe to re-run: a file is only replaced if the new version is smaller.
set -euo pipefail
cd "$1"
current=$2   # sha of the current build
keep="latest freeze $current 68187e670d8c36a43c17880574237ae40fd857ed"

dirs=()
for d in v/*/; do
  name=$(basename "$d")
  [[ " $keep " == *" $name "* ]] && continue
  dirs+=("$d")
done
echo "Shrinking ${#dirs[@]} versions" >&2

pdf() {
  tmp="$1.tmp.pdf"
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 \
     -dPDFSETTINGS=/ebook -sOutputFile="$tmp" "$1"
  # only replace if it got smaller
  if [ "$(stat -c%s "$tmp")" -lt "$(stat -c%s "$1")" ]; then mv "$tmp" "$1"; else rm "$tmp"; fi
}
png() {
  convert "$1" -resize '1000x1000>' -strip "$1.tmp.png"
  oxipng -q -o 2 "$1.tmp.png"
  if [ "$(stat -c%s "$1.tmp.png")" -lt "$(stat -c%s "$1")" ]; then mv "$1.tmp.png" "$1"; else rm "$1.tmp.png"; fi
}
export -f pdf png

find "${dirs[@]}" -name '*.pdf' -print0 | xargs -0 -n1 -P8 bash -c 'pdf "$0"'
echo "PDFs done" >&2
find "${dirs[@]}" -name '*.png' -print0 | xargs -0 -n1 -P8 bash -c 'png "$0"'
echo "PNGs done" >&2
du -sh --exclude=.git . >&2

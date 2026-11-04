#!/usr/bin/env bash
# Rebuilds keymaps-cheatsheet.pdf at the repo root.
#
# The entries live by hand in build-cheatsheet.py. Edit them there when keymaps change, then run this
# script. It dumps the live keymaps, fails if a listed key no longer exists, and prints the PDF with
# Chrome. It doesn't notice new mappings, so anything you add must be added to build-cheatsheet.py too.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

cd "$root"
OUT="$work/maps.tsv" nvim --headless -c "luafile $here/dump-keymaps.lua" >/dev/null 2>&1
[ -s "$work/maps.tsv" ] || { echo "keymap dump failed: no output from nvim" >&2; exit 1; }

python3 "$here/verify-cheatsheet.py" "$work/maps.tsv"

python3 "$here/build-cheatsheet.py" "$(date +%F)" >"$work/keymaps-cheatsheet.html"
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --user-data-dir="$work/chrome-profile" \
  --print-to-pdf="$work/keymaps-cheatsheet.pdf" \
  "file://$work/keymaps-cheatsheet.html" >/dev/null 2>&1
[ -s "$work/keymaps-cheatsheet.pdf" ] || { echo "Chrome did not produce a PDF" >&2; exit 1; }

if command -v pdfinfo >/dev/null; then
  pages="$(pdfinfo "$work/keymaps-cheatsheet.pdf" | awk '/^Pages:/ {print $2}')"
  if [ "$pages" != "2" ]; then
    echo "expected 2 pages, got $pages: tighten the layout in build-cheatsheet.py (PDF not replaced)" >&2
    exit 1
  fi
fi

cp "$work/keymaps-cheatsheet.pdf" "$root/keymaps-cheatsheet.pdf"
echo "wrote $root/keymaps-cheatsheet.pdf"

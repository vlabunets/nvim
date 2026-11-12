#!/usr/bin/env bash
# Verify the Neovim config starts cleanly. Run from anywhere.
# Exit code 0 = clean, 1 = startup produced output/errors.
set -u

HEALTH_FILE="${TMPDIR:-/tmp}/nvim-health.txt"

echo "==> Syncing plugins to match specs"
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1

echo "==> Headless startup (must print nothing)"
out="$(nvim --headless "+qa" 2>&1)"
if [ -n "$out" ]; then
  echo "$out"
  echo "FAIL: startup produced output"
  status=1
else
  echo "OK"
  status=0
fi

echo "==> :checkhealth lazy"
nvim --headless "+checkhealth lazy" "+w! $HEALTH_FILE" +qa >/dev/null 2>&1
grep -E "ERROR|WARNING" "$HEALTH_FILE" || echo "No errors or warnings"

exit "$status"

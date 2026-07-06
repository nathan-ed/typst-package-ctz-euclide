#!/usr/bin/env bash
# Rebuild gallery SVGs. Gallery .typ files import @preview/ctz-euclide at the
# released version, so the version must be present in the preview cache
# (rsync the working tree there first when testing unreleased changes).
set -u
cd "$(dirname "$0")/.."
fail=0
for f in gallery/*.typ; do
  if out=$(typst compile --format svg "$f" "${f%.typ}.svg" 2>&1); then
    echo "OK   $f"
  else
    echo "FAIL $f"; echo "$out" | head -6; fail=1
  fi
done
exit $fail

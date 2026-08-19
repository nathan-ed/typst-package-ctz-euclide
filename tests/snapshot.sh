#!/usr/bin/env bash
# Renders the whole visual corpus (gallery, manual, test fixtures) to PNG in
# the given directory. Run it before a change and after it, then diff the two
# directories: every pixel that moved must be an intended change.
#
#   bash tests/snapshot.sh /tmp/before
#   ...edit...
#   bash tests/snapshot.sh /tmp/after
#   bash tests/compare-snapshots.sh /tmp/before /tmp/after
set -euo pipefail
cd "$(dirname "$0")/.."
out=${1:?usage: snapshot.sh <dir>}
mkdir -p "$out"

for f in gallery/*.typ tests/*.typ \
         docs/manual.typ; do
  [ -f "$f" ] || continue
  name=$(echo "${f%.typ}" | tr '/' '-')
  if ! typst compile "$f" "$out/$name-{0p}.png" --root . --ppi 96 2>"$out/$name.err"; then
    echo "ÉCHEC $f"; cat "$out/$name.err"; exit 1
  fi
  rm -f "$out/$name.err"
  echo "ok  $f"
done

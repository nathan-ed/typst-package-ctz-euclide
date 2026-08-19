#!/usr/bin/env bash
# The default point marker is a circle (issue #6), and the other shapes stay
# reachable. The fixture asserts the default in Typst itself, so a change to it
# fails the compile; the render is there to be looked at.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
if typst compile tests/test-point-marker.typ "$tmp/p.png" --root . --ppi 150 2>"$tmp/err"; then
  echo "ok    marqueur par defaut : cercle"
else
  echo "FAIL  marqueur par defaut"
  cat "$tmp/err"
  exit 1
fi

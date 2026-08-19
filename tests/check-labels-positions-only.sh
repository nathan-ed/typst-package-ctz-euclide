#!/usr/bin/env bash
# ctz-draw-labels must accept positions without repeating the point names
# (issue #5). Both spellings have to produce the same picture.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! python3 -c "import PIL" 2>/dev/null; then
  echo "skip  labels-positions-only (python3 Pillow absent)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
typst compile tests/test-labels-positions-only.typ "$tmp/p-{p}.png" --root . --ppi 150

python3 - "$tmp" <<'PY'
import sys
from PIL import Image, ImageChops
a = Image.open(sys.argv[1] + "/p-1.png").convert("RGB")
b = Image.open(sys.argv[1] + "/p-2.png").convert("RGB")
if a.size != b.size:
    print("FAIL  tailles differentes : %s vs %s" % (a.size, b.size))
    raise SystemExit(1)
if ImageChops.difference(a, b).getbbox() is None:
    # guard against both being blank
    ink = sum(1 for p in list(a.convert("L").getdata()) if p < 128)
    if ink < 200:
        print("FAIL  les deux figures sont vides (%d px d'encre)" % ink)
        raise SystemExit(1)
    print("ok    positions seules et liste explicite rendent la meme figure")
else:
    print("FAIL  les deux ecritures ne rendent pas la meme figure")
    raise SystemExit(1)
PY

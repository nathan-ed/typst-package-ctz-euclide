#!/usr/bin/env bash
# ctz-def-triangle-center must land on exactly the same points as the historic
# ctz-def-<centre> functions (issue #6). The fixture draws the historic ones as
# black circles and the new ones as red crosses on top: every cross has to sit
# inside a circle, so counting the red marks that fall outside any black one
# tells whether the two spellings agree.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! python3 -c "import PIL" 2>/dev/null; then
  echo "skip  triangle-center (python3 Pillow absent)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# the fixture asserts the dispatch itself; a wrong wiring fails here
typst compile tests/test-triangle-center.typ "$tmp/p.png" --root . --ppi 200

python3 - "$tmp" <<'PY'
import sys
from PIL import Image

im = Image.open(sys.argv[1] + "/p.png").convert("RGB")
w, h = im.size
px = im.load()

red = [(x, y) for y in range(h) for x in range(w)
       if px[x, y][0] > 150 and px[x, y][1] < 90 and px[x, y][2] < 90]
black = [(x, y) for y in range(h) for x in range(w)
         if max(px[x, y]) < 90]

if not red:
    print("FAIL  aucune croix rouge tracee")
    raise SystemExit(1)
if not black:
    print("FAIL  aucun cercle noir trace")
    raise SystemExit(1)

# every red pixel must have black ink within a few pixels: the circle it sits in
black_set = set(black)
stray = 0
for (x, y) in red:
    near = any((x + dx, y + dy) in black_set
               for dx in range(-6, 7) for dy in range(-6, 7))
    if not near:
        stray += 1

if stray == 0:
    print("ok    les deux ecritures donnent les memes centres (%d px de croix, tous dans un cercle)" % len(red))
else:
    print("FAIL  %d px de croix rouge hors de tout cercle noir" % stray)
    raise SystemExit(1)
PY

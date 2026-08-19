#!/usr/bin/env bash
# The four angle types must draw arcs of the expected size: for a 26.57° angle,
# complementary is 63.43°, supplementary 153.43°, reflex 333.43°. Measured as
# the count of red pixels on the render, which is proportional to arc length.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! python3 -c "import PIL" 2>/dev/null; then
  echo "skip  angle-types (python3 Pillow absent)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
typst compile tests/test-angle-types.typ "$tmp/p-{p}.png" --root . --ppi 200

python3 - "$tmp" <<'PY'
import sys
from PIL import Image

def red_pixels(n):
    im = Image.open("%s/p-%d.png" % (sys.argv[1], n)).convert("RGB")
    w, h = im.size
    px = im.load()
    return sum(1 for y in range(h) for x in range(w)
               if px[x, y][0] > 150 and px[x, y][1] < 100 and px[x, y][2] < 100)

interior, complementary, supplementary, reflex = (red_pixels(n) for n in (1, 2, 3, 4))
if interior == 0:
    print("FAIL  aucun arc rouge sur la page interior")
    raise SystemExit(1)

status = 0
# expected ratios against the interior arc, +-20% for stroke ends and antialiasing
for name, got, want in (
    ("complementary", complementary, 63.43 / 26.57),
    ("supplementary", supplementary, 153.43 / 26.57),
    ("reflex", reflex, 333.43 / 26.57),
):
    ratio = got / interior
    if abs(ratio - want) / want < 0.2:
        print("ok    %-14s arc %.2fx l'interieur (attendu %.2fx)" % (name, ratio, want))
    else:
        print("FAIL  %-14s arc %.2fx l'interieur, attendu %.2fx" % (name, ratio, want))
        status = 1
raise SystemExit(status)
PY

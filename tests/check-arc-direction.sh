#!/usr/bin/env bash
# An arc given two points must sweep the same way as the angle form: counter-
# clockwise from start to end (issue #4, second report). The fixture draws the
# same pair of arcs both ways; the two pages have to match.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! python3 -c "import PIL" 2>/dev/null; then
  echo "skip  arc-direction (python3 Pillow absent)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
typst compile tests/test-arc-direction.typ "$tmp/p-{p}.png" --root . --ppi 150

python3 - "$tmp" <<'PY'
import sys
from PIL import Image

a = Image.open(sys.argv[1] + "/p-1.png").convert("RGB")
b = Image.open(sys.argv[1] + "/p-2.png").convert("RGB")
if a.size != b.size:
    print("FAIL  tailles differentes : %s vs %s" % (a.size, b.size))
    raise SystemExit(1)

def coloured(im):
    """Pixels of each arc colour, as sets of positions."""
    w, h = im.size
    px = im.load()
    green, red = set(), set()
    for y in range(h):
        for x in range(w):
            r, g, bl = px[x, y]
            if g > 100 and r < 100 and bl < 100:
                green.add((x, y))
            elif r > 150 and g < 100 and bl < 100:
                red.add((x, y))
    return green, red

ga, ra = coloured(a)
gb, rb = coloured(b)
if not ga or not ra:
    print("FAIL  la page de reference ne montre pas les deux arcs")
    raise SystemExit(1)

def close(s1, s2, name):
    inter = len(s1 & s2)
    union = len(s1 | s2)
    ratio = inter / union if union else 0
    if ratio > 0.9:
        return True
    print("FAIL  arc %s : recouvrement de %.0f%% seulement entre les deux formes" % (name, ratio * 100))
    return False

ok = close(ga, gb, "vert") and close(ra, rb, "rouge")
# and the two arcs must not sit on each other
overlap = len(rb & gb) / max(1, len(gb))
if overlap > 0.1:
    print("FAIL  l'arc rouge recouvre le vert (%.0f%%)" % (overlap * 100))
    ok = False
if ok:
    print("ok    l'arc par points suit le meme sens que par angles")
raise SystemExit(0 if ok else 1)
PY

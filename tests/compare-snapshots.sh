#!/usr/bin/env bash
# Compares two directories produced by snapshot.sh, pixel by pixel.
set -euo pipefail
a=${1:?usage: compare-snapshots.sh <before> <after>}
b=${2:?usage: compare-snapshots.sh <before> <after>}
python3 - "$a" "$b" <<'PY'
import sys, os, glob
from PIL import Image, ImageChops

a, b = sys.argv[1], sys.argv[2]
names = sorted(set(os.path.basename(f) for f in glob.glob(a + "/*.png")) |
               set(os.path.basename(f) for f in glob.glob(b + "/*.png")))
changed = same = 0
for n in names:
    fa, fb = os.path.join(a, n), os.path.join(b, n)
    if not os.path.exists(fa):
        print("NOUVEAU  %s" % n); changed += 1; continue
    if not os.path.exists(fb):
        print("DISPARU  %s" % n); changed += 1; continue
    ia, ib = Image.open(fa).convert("RGB"), Image.open(fb).convert("RGB")
    if ia.size != ib.size:
        print("TAILLE   %s : %s -> %s" % (n, ia.size, ib.size)); changed += 1; continue
    diff = ImageChops.difference(ia, ib)
    box = diff.getbbox()
    if box is None:
        same += 1
    else:
        px = sum(1 for p in diff.convert("L").getdata() if p > 8)
        print("DIFFÈRE  %-40s %d px, zone %s" % (n, px, box))
        changed += 1
print("---")
print("%d pages identiques, %d pages modifiées" % (same, changed))
PY

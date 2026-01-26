#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    content = f.read()

# Pattern 1: Simple single-line labels
replacements = [
    # ("A", "B", "M") patterns
    (r'ctz-draw-points\("A", "B", "M"\)\s*\n\s*ctz-draw-labels\("A", "B", "M", A: "left", B: "right", M: "above"\)',
     'ctz-draw(points: ("A", "B", "M"), labels: (A: "left", B: "right", M: "above"))'),

    (r'ctz-draw-points\("A", "B", "M"\)\s*\n\s*ctz-draw-labels\("A", "B", "M", A: "left", B: "right", M: "below"\)',
     'ctz-draw(points: ("A", "B", "M"), labels: (A: "left", B: "right", M: "below"))'),

    # ("A", "B", "C") patterns
    (r'ctz-draw-points\("A", "B", "C"\)\s*\n\s*ctz-draw-labels\("A", "B", "C", A: "left", B: "right", C: "above"\)',
     'ctz-draw(points: ("A", "B", "C"), labels: (A: "left", B: "right", C: "above"))'),

    (r'ctz-draw-points\("A", "B", "C"\)\s*\n\s*ctz-draw-labels\("A", "B", "C", A: "below", B: "below", C: "above"\)',
     'ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))'),

    # ("O1", "O2", "I1", "I2") pattern
    (r'ctz-draw-points\("O1", "O2", "I1", "I2"\)\s*\n\s*ctz-draw-labels\("I1", "I2", I1: "above", I2: "below"\)',
     'ctz-draw(points: ("O1", "O2", "I1", "I2"), labels: (I1: "above", I2: "below"))'),
]

for pattern, replacement in replacements:
    content = re.sub(pattern, replacement, content)

# Standalone points without labels
content = re.sub(
    r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)(?!\s*\n\s*ctz-draw-labels)',
    lambda m: f'ctz-draw(points: ({m.group(1).strip()}))',
    content
)

with open('docs/manual.typ', 'w') as f:
    f.write(content)

print("Basic replacements done")

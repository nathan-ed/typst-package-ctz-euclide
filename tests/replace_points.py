#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    content = f.read()

# Pattern 1: Simple inline format
# ctz-draw-points("A", "B", "C")
# ctz-draw-labels("A", "B", "C", A: "x", B: "y", C: "z")
pattern1 = r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)\s*\n\s*ctz-draw-labels\(((?:"[^"]+",?\s*)+)((?:,?\s*\w+:\s*"[^"]+"\s*)+)\)'

def replace1(match):
    points = match.group(1).strip()
    labels_names = match.group(2).strip()
    label_positions = match.group(3).strip()

    # Clean up trailing commas
    if label_positions.startswith(','):
        label_positions = label_positions[1:].strip()

    return f'ctz-draw(points: ({points}), labels: ({label_positions}))'

content = re.sub(pattern1, replace1, content)

# Pattern 2: Multiline labels format
# ctz-draw-points("A", "B")
# ctz-draw-labels("A", "B",
#   A: "x", B: "y")
pattern2 = r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)\s*\n\s*ctz-draw-labels\([^)]+\n[^)]+\)'

def replace2(match):
    full_match = match.group(0)

    # Extract points
    points_match = re.search(r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)', full_match)
    if not points_match:
        return full_match
    points = points_match.group(1).strip()

    # Extract label positions (everything after the point names in ctz-draw-labels)
    labels_match = re.search(r'ctz-draw-labels\([^)]*?((?:\w+:\s*"[^"]+",?\s*)+)\)', full_match, re.DOTALL)
    if not labels_match:
        # No labels, just points
        return f'ctz-draw(points: ({points}))'

    label_positions = labels_match.group(1).strip()
    # Remove leading/trailing commas and newlines
    label_positions = re.sub(r'^,\s*', '', label_positions)
    label_positions = re.sub(r',\s*$', '', label_positions)

    return f'ctz-draw(points: ({points}), labels: ({label_positions}))'

# This is too complex, let me just handle specific known patterns

# Standalone ctz-draw-points without following labels
content = re.sub(
    r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)(?!\s*\n\s*ctz-draw-labels)',
    lambda m: f'ctz-draw(points: ({m.group(1).strip()}))',
    content
)

with open('docs/manual.typ', 'w') as f:
    f.write(content)

print("Replacements done!")

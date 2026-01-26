#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    content = f.read()

# Fix malformed line: calls that have extra arguments after the tuple
# Pattern: ctz-draw(line: ("A", "B", "C"), "B", "C", ...)
# Should be: ctz-draw(line: ("A", "B", "C"), ...)

# Match ctz-draw(line: (...), followed by quoted strings that duplicate the points
content = re.sub(
    r'ctz-draw\(line: \(((?:"[^"]+",?\s*)+)\), ((?:"[^"]+",?\s*)+)(.*?)\)',
    r'ctz-draw(line: (\1), \3)',
    content
)

# Fix similar issue with segment:
content = re.sub(
    r'ctz-draw\(segment: \(((?:"[^"]+",?\s*)+)\), ((?:"[^"]+",?\s*)+)(.*?)\)',
    r'ctz-draw(segment: (\1), \3)',
    content
)

with open('docs/manual.typ', 'w') as f:
    f.write(content)

print("Fixed malformed ctz-draw calls")

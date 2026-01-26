#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    content = f.read()

# Replace ctz-draw-line with polylines (3+ points)
# Pattern: ctz-draw-line("A", "B", "C", ..., stroke: ...)
content = re.sub(
    r'ctz-draw-line\(((?:"[^"]+",\s*){2,})(.*?)\)',
    lambda m: f'ctz-draw(line: ({m.group(1).rstrip(", ")}), {m.group(2)})',
    content
)

# Replace ctz-draw-circle-through
content = re.sub(
    r'ctz-draw-circle-through\("([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(circle-through: ("\1", "\2")\3)',
    content
)

# Replace ctz-draw-circle-r
content = re.sub(
    r'ctz-draw-circle-r\("([^"]+)",\s*([^,]+)(.*?)\)',
    r'ctz-draw(circle-r: (_pt("\1"), \2)\3)',
    content
)

# Replace ctz-draw-circle-r with raw coordinates
content = re.sub(
    r'ctz-draw-circle-r\((\([^)]+\)),\s*([^,]+)(.*?)\)',
    r'ctz-draw(circle-r: (\1, \2)\3)',
    content
)

# Replace ctz-draw-incircle
content = re.sub(
    r'ctz-draw-incircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(incircle: ("\1", "\2", "\3")\4)',
    content
)

# Replace ctz-draw-circumcircle
content = re.sub(
    r'ctz-draw-circumcircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(circumcircle: ("\1", "\2", "\3")\4)',
    content
)

# Replace ctz-draw-semicircle
content = re.sub(
    r'ctz-draw-semicircle\("([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(semicircle: ("\1", "\2")\3)',
    content
)

with open('docs/manual.typ', 'w') as f:
    f.write(content)

print("Type-specific draw functions replaced!")

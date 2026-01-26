#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    content = f.read()

# 1. Replace polylines (3+ points): ctz-draw-line("A", "B", "C", ...)
def replace_polyline(match):
    points = re.findall(r'"([^"]+)"', match.group(0))
    remaining = match.group(0).split(')', 1)[0].split(points[-1] + '"', 1)[1]
    if remaining.strip().startswith(','):
        remaining = remaining.strip()[1:].strip()

    points_str = ', '.join([f'"{p}"' for p in points])

    if remaining:
        return f'ctz-draw(line: ({points_str}), {remaining})'
    else:
        return f'ctz-draw(line: ({points_str}))'

# Match ctz-draw-line with 3+ points (but not special functions like -global-clip)
content = re.sub(
    r'ctz-draw-line\((?:"[^"]+",\s*){2,}"[^"]+"\s*(?:,\s*[^)]+)?\)',
    replace_polyline,
    content
)

# 2. Replace simple segments (2 points): ctz-draw-line("A", "B", ...)
content = re.sub(
    r'ctz-draw-line\("([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(segment: ("\1", "\2")\3)',
    content
)

# 3. Replace ctz-draw-circle-through
content = re.sub(
    r'ctz-draw-circle-through\("([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(circle-through: ("\1", "\2")\3)',
    content
)

# 4. Replace ctz-draw-circle-r with named point
content = re.sub(
    r'ctz-draw-circle-r\("([^"]+)",\s*([^,)]+)(.*?)\)',
    r'ctz-draw(circle-r: (_pt("\1"), \2)\3)',
    content
)

# 5. Replace ctz-draw-circle-r with raw coordinates
content = re.sub(
    r'ctz-draw-circle-r\((\([^)]+\)),\s*([^,)]+)(.*?)\)',
    r'ctz-draw(circle-r: (\1, \2)\3)',
    content
)

# 6. Replace ctz-draw-incircle
content = re.sub(
    r'ctz-draw-incircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(incircle: ("\1", "\2", "\3")\4)',
    content
)

# 7. Replace ctz-draw-circumcircle
content = re.sub(
    r'ctz-draw-circumcircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(circumcircle: ("\1", "\2", "\3")\4)',
    content
)

# 8. Replace ctz-draw-semicircle
content = re.sub(
    r'ctz-draw-semicircle\("([^"]+)",\s*"([^"]+)"(.*?)\)',
    r'ctz-draw(semicircle: ("\1", "\2")\3)',
    content
)

# 9. Replace named circles: ctz-draw-circle("name", ...)
# But NOT ctz-draw-circle-r or ctz-draw-circle-through (already handled)
content = re.sub(
    r'(?<!draw-)ctz-draw-circle\("([^"]+)"(.*?)\)',
    r'ctz-draw("\1"\2)',
    content
)

# 10. Replace named polygons
content = re.sub(
    r'ctz-draw-polygon\("([^"]+)"(.*?)\)',
    r'ctz-draw("\1"\2)',
    content
)

with open('docs/manual.typ', 'w') as f:
    f.write(content)

print("Complete replacement done!")

#!/usr/bin/env python3
import re
import os

gallery_dir = 'gallery'

for filename in os.listdir(gallery_dir):
    if not filename.endswith('.typ'):
        continue

    filepath = os.path.join(gallery_dir, filename)
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Replace polylines (3+ points): ctz-draw-line("A", "B", "C", ...)
    def replace_polyline(match):
        points = re.findall(r'"([^"]+)"', match.group(0))
        # Find everything after the last point up to the closing paren
        remaining = match.group(0).split(')', 1)[0].split(points[-1] + '"', 1)[1]
        if remaining.strip().startswith(','):
            remaining = remaining.strip()[1:].strip()

        points_str = ', '.join([f'"{p}"' for p in points])

        if remaining:
            return f'ctz-draw(line: ({points_str}), {remaining})'
        else:
            return f'ctz-draw(line: ({points_str}))'

    # Match ctz-draw-line with 3+ points
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

    # 5. Replace ctz-draw-incircle
    content = re.sub(
        r'ctz-draw-incircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
        r'ctz-draw(incircle: ("\1", "\2", "\3")\4)',
        content
    )

    # 6. Replace ctz-draw-circumcircle
    content = re.sub(
        r'ctz-draw-circumcircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
        r'ctz-draw(circumcircle: ("\1", "\2", "\3")\4)',
        content
    )

    # 7. Replace ctz-draw-semicircle
    content = re.sub(
        r'ctz-draw-semicircle\("([^"]+)",\s*"([^"]+)"(.*?)\)',
        r'ctz-draw(semicircle: ("\1", "\2")\3)',
        content
    )

    # 8. Replace ctz-draw-points followed by ctz-draw-labels
    # This is trickier - look for pattern where they're on consecutive lines
    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if this is a ctz-draw-points line
        points_match = re.match(r'(\s*)ctz-draw-points\((.*?)\)\s*$', line)
        if points_match and i + 1 < len(lines):
            indent = points_match.group(1)
            points_args = points_match.group(2)

            # Check if next line is ctz-draw-labels
            next_line = lines[i + 1]
            labels_match = re.match(r'\s*ctz-draw-labels\((.*)\)', next_line, re.DOTALL)

            if labels_match:
                # Combine them
                labels_content = labels_match.group(1)
                # Extract the labels arguments (everything after point names)
                # This is complex - we need to find where point names end and options begin

                # For now, simple approach: if labels has same point names, extract options
                point_names = [p.strip() for p in re.findall(r'"([^"]+)"', points_args)]

                # Check if labels content starts with same point names
                labels_parts = labels_content.split(',', len(point_names))
                if len(labels_parts) > len(point_names):
                    # Has options
                    options = ','.join(labels_parts[len(point_names):]).strip()
                    new_lines.append(f'{indent}ctz-draw(points: ({points_args}), labels: ({options}))')
                else:
                    # No options, just labels: true
                    new_lines.append(f'{indent}ctz-draw(points: ({points_args}), labels: true)')

                i += 2  # Skip both lines
                continue

        # Not a combined pattern, keep line as is
        new_lines.append(line)
        i += 1

    content = '\n'.join(new_lines)

    # 9. Replace standalone ctz-draw-points (not followed by labels)
    content = re.sub(
        r'ctz-draw-points\((.*?)\)',
        r'ctz-draw(points: (\1))',
        content
    )

    # 10. Replace standalone ctz-draw-labels (not preceded by points)
    content = re.sub(
        r'ctz-draw-labels\((.*?)\)',
        r'ctz-draw(labels: (\1))',
        content
    )

    with open(filepath, 'w') as f:
        f.write(content)

    print(f"Updated {filename}")

print("Gallery update complete!")

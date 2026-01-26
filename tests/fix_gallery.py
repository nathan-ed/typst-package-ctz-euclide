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

    # First, fix malformed line: calls that have extra arguments after the tuple
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

    # Replace remaining ctz-draw-line (from previous incomplete conversion)
    # This handles multi-line cases
    def replace_drawline_multiline(match):
        full_text = match.group(0)
        # Extract everything between the parentheses
        inner = match.group(1)

        # Find all quoted strings (point names)
        points = re.findall(r'"([^"]+)"', inner)

        if len(points) >= 3:
            # Polyline
            points_str = ', '.join([f'"{p}"' for p in points])
            # Find remaining arguments after last point
            last_point_pos = inner.rfind(f'"{points[-1]}"')
            remaining = inner[last_point_pos + len(f'"{points[-1]}"'):].strip()
            if remaining.startswith(','):
                remaining = remaining[1:].strip()

            if remaining:
                return f'ctz-draw(line: ({points_str}), {remaining})'
            else:
                return f'ctz-draw(line: ({points_str}))'
        elif len(points) == 2:
            # Segment
            # Find remaining arguments after second point
            second_point_pos = inner.rfind(f'"{points[1]}"')
            remaining = inner[second_point_pos + len(f'"{points[1]}"'):].strip()
            if remaining.startswith(','):
                remaining = remaining[1:].strip()

            if remaining:
                return f'ctz-draw(segment: ("{points[0]}", "{points[1]}"), {remaining})'
            else:
                return f'ctz-draw(segment: ("{points[0]}", "{points[1]}"))'
        else:
            return full_text

    # Match ctz-draw-line with multiline support
    content = re.sub(
        r'ctz-draw-line\(((?:[^()]+|\([^)]*\))*)\)',
        replace_drawline_multiline,
        content,
        flags=re.DOTALL
    )

    # Replace ctz-draw-labels with labels: parameter
    content = re.sub(
        r'ctz-draw-labels\(((?:[^()]+|\([^)]*\))*)\)',
        r'ctz-draw(labels: (\1))',
        content,
        flags=re.DOTALL
    )

    with open(filepath, 'w') as f:
        f.write(content)

    print(f"Fixed {filename}")

print("Gallery fix complete!")

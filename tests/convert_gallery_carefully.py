#!/usr/bin/env python3
import re
import os

def convert_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Check for ctz-draw-points followed by ctz-draw-labels on next line
        points_match = re.match(r'(\s*)ctz-draw-points\((.*)\)\s*$', line)
        if points_match and i + 1 < len(lines):
            indent = points_match.group(1)
            points_args = points_match.group(2)

            # Collect all continuation lines for ctz-draw-labels
            labels_lines = []
            j = i + 1
            while j < len(lines):
                labels_lines.append(lines[j])
                if lines[j].strip().endswith(')'):
                    # Check if this closes the ctz-draw-labels call
                    combined = ''.join(labels_lines)
                    if combined.count('(') == combined.count(')'):
                        break
                j += 1

            # Check if we have a ctz-draw-labels
            combined_labels = ''.join(labels_lines)
            labels_match = re.match(r'\s*ctz-draw-labels\((.*)\)\s*$', combined_labels, re.DOTALL)

            if labels_match:
                labels_args = labels_match.group(1)

                # Extract point names from labels_args
                # Point names are the initial quoted strings before any named arguments
                point_names_in_labels = re.findall(r'^(\s*"[^"]+",?\s*)+', labels_args)

                # Check if labels has the same point names as points
                # If so, we can combine them
                # For simplicity, just check if labels starts with quotes (has point names)
                if point_names_in_labels:
                    # Remove point names from labels_args
                    # Find where named arguments start (look for pattern like A:, B:, etc.)
                    named_match = re.search(r'\s*([A-Z][a-z0-9]*:)', labels_args)
                    if named_match:
                        # Get position of first named argument
                        named_start = named_match.start()
                        labels_options = labels_args[named_start:].rstrip()
                    else:
                        # No named arguments, just point names
                        labels_options = None

                    # Combine into single call
                    if labels_options:
                        new_lines.append(f'{indent}ctz-draw(points: ({points_args}), labels: (\n    {labels_options}\n{indent}))\n')
                    else:
                        new_lines.append(f'{indent}ctz-draw(points: ({points_args}), labels: true)\n')

                    i = j + 1
                    continue
                else:
                    # labels doesn't have point names, just options
                    # This means it's using the point names from a previous call
                    # Just convert both separately
                    new_lines.append(f'{indent}ctz-draw(points: ({points_args}))\n')
                    new_lines.append(f'{indent}ctz-draw(labels: ({labels_args}))\n')
                    i = j + 1
                    continue

        # Convert standalone ctz-draw-points
        line = re.sub(r'ctz-draw-points\((.*?)\)', r'ctz-draw(points: (\1))', line)

        # Convert standalone ctz-draw-labels
        line = re.sub(r'ctz-draw-labels\((.*?)\)', r'ctz-draw(labels: (\1))', line)

        # Convert ctz-draw-line with 2 points (segment)
        line = re.sub(
            r'ctz-draw-line\("([^"]+)",\s*"([^"]+)"(,\s*.*?)\)',
            r'ctz-draw(segment: ("\1", "\2")\3)',
            line
        )

        # Convert ctz-draw-line with 3+ points (polyline)
        def replace_polyline(match):
            full = match.group(0)
            # Extract points and options
            content = match.group(1)
            points = re.findall(r'"([^"]+)"', content)
            if len(points) >= 3:
                points_str = ', '.join([f'"{p}"' for p in points])
                # Find options after last point
                last_point_pos = content.rfind(f'"{points[-1]}"')
                remaining = content[last_point_pos + len(f'"{points[-1]}"'):].strip()
                if remaining.startswith(','):
                    remaining = remaining[1:].strip()
                if remaining:
                    return f'ctz-draw(line: ({points_str}), {remaining})'
                else:
                    return f'ctz-draw(line: ({points_str}))'
            return full

        line = re.sub(r'ctz-draw-line\(((?:[^()]*|\([^)]*\))*)\)', replace_polyline, line)

        # Convert ctz-draw-circle-through
        line = re.sub(
            r'ctz-draw-circle-through\("([^"]+)",\s*"([^"]+)"(.*?)\)',
            r'ctz-draw(circle-through: ("\1", "\2")\3)',
            line
        )

        # Convert ctz-draw-circle-r
        line = re.sub(
            r'ctz-draw-circle-r\("([^"]+)",\s*([^,)]+)(.*?)\)',
            r'ctz-draw(circle-r: (_pt("\1"), \2)\3)',
            line
        )

        # Convert ctz-draw-incircle
        line = re.sub(
            r'ctz-draw-incircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
            r'ctz-draw(incircle: ("\1", "\2", "\3")\4)',
            line
        )

        # Convert ctz-draw-circumcircle
        line = re.sub(
            r'ctz-draw-circumcircle\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"(.*?)\)',
            r'ctz-draw(circumcircle: ("\1", "\2", "\3")\4)',
            line
        )

        # Convert ctz-draw-semicircle
        line = re.sub(
            r'ctz-draw-semicircle\("([^"]+)",\s*"([^"]+)"(.*?)\)',
            r'ctz-draw(semicircle: ("\1", "\2")\3)',
            line
        )

        # Convert ctz-draw-circle("name", ...) - named circle
        line = re.sub(
            r'ctz-draw-circle\("([^"]+)"(.*?)\)',
            r'ctz-draw("\1"\2)',
            line
        )

        # Convert ctz-draw-polygon("name", ...) - named polygon
        line = re.sub(
            r'ctz-draw-polygon\("([^"]+)"(.*?)\)',
            r'ctz-draw("\1"\2)',
            line
        )

        new_lines.append(line)
        i += 1

    with open(filepath, 'w') as f:
        f.writelines(new_lines)

# Process all gallery files
gallery_dir = 'gallery'
for filename in sorted(os.listdir(gallery_dir)):
    if filename.endswith('.typ'):
        filepath = os.path.join(gallery_dir, filename)
        print(f"Converting {filename}...")
        convert_file(filepath)

print("Gallery conversion complete!")

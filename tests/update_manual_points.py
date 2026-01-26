#!/usr/bin/env python3
"""
Script to replace ctz-draw-points + ctz-draw-labels with unified ctz-draw(points: ..., labels: ...)
"""
import re

def read_file(filepath):
    with open(filepath, 'r') as f:
        return f.read()

def write_file(filepath, content):
    with open(filepath, 'w') as f:
        f.write(content)

def extract_point_names(points_line):
    """Extract point names from ctz-draw-points line"""
    match = re.search(r'ctz-draw-points\((.*?)\)', points_line)
    if match:
        args = match.group(1)
        # Extract quoted strings
        names = re.findall(r'"([^"]+)"', args)
        return names
    return []

def parse_labels_args(labels_section):
    """Parse label positioning arguments"""
    # This is complex because labels can span multiple lines
    # Extract key: value pairs
    label_dict = {}
    # Find patterns like: A: "below left" or A: "above"
    matches = re.findall(r'(\w+):\s*"([^"]+)"', labels_section)
    for name, pos in matches:
        label_dict[name] = pos
    return label_dict

def replace_points_labels_pair(content):
    """Replace consecutive ctz-draw-points + ctz-draw-labels with unified syntax"""

    # Pattern 1: Simple single-line format
    pattern1 = r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)\s*\n\s*ctz-draw-labels\(((?:"[^"]+",?\s*)+)((?:\w+:\s*"[^"]+",?\s*)+)\)'

    def replacer1(match):
        points_args = match.group(1)
        labels_names = match.group(2)
        labels_pos = match.group(3)

        # Extract point names
        point_names = re.findall(r'"([^"]+)"', points_args)

        # Parse label positions
        label_positions = {}
        pos_matches = re.findall(r'(\w+):\s*"([^"]+)"', labels_pos)
        for name, pos in pos_matches:
            label_positions[name] = pos

        # Build new syntax
        points_str = ', '.join([f'"{p}"' for p in point_names])

        if label_positions:
            labels_items = [f'{name}: "{pos}"' for name, pos in label_positions.items()]
            labels_str = ', '.join(labels_items)
            return f'ctz-draw(points: ({points_str}), labels: ({labels_str}))'
        else:
            return f'ctz-draw(points: ({points_str}))'

    content = re.sub(pattern1, replacer1, content)

    return content

def main():
    filepath = 'docs/manual.typ'
    content = read_file(filepath)

    # First pass: handle simple cases
    # Replace standalone ctz-draw-points("A") with ctz-draw(points: ("A"))
    content = re.sub(
        r'ctz-draw-points\(((?:"[^"]+",?\s*)+)\)(?!\s*\n\s*ctz-draw-labels)',
        lambda m: f'ctz-draw(points: ({m.group(1)}))',
        content
    )

    print("Manual replacement script - this is complex, doing it manually instead")

if __name__ == '__main__':
    main()

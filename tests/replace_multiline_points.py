#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    lines = f.readlines()

output = []
i = 0
while i < len(lines):
    line = lines[i]

    # Check if this line contains ctz-draw-points
    if 'ctz-draw-points(' in line and '`ctz-draw-points' not in line and 'use `ctz-def-points` and `ctz-draw-points`' not in line and 'Points — `ctz-draw-points`' not in line:
        # Extract points
        points_match = re.search(r'ctz-draw-points\((.*?)\)', line)
        if points_match:
            points = points_match.group(1)
            indent = len(line) - len(line.lstrip())
            indent_str = ' ' * indent

            # Look ahead for ctz-draw-labels
            if i + 1 < len(lines) and 'ctz-draw-labels' in lines[i + 1]:
                # Parse multiline labels
                labels_start = i + 1
                labels_lines = [lines[labels_start]]
                j = labels_start + 1

                # Continue reading until we find the closing parenthesis
                while j < len(lines):
                    labels_lines.append(lines[j])
                    if ')' in lines[j]:
                        break
                    j += 1

                # Extract label positions
                labels_text = ''.join(labels_lines)
                # Find all key: value pairs
                label_matches = re.findall(r'(\w+):\s*"([^"]+)"', labels_text)

                if label_matches:
                    # Build new format
                    label_strs = [f'{name}: "{pos}"' for name, pos in label_matches]
                    output.append(f'{indent_str}ctz-draw(points: ({points}), labels: (\n')
                    for label_str in label_strs:
                        output.append(f'{indent_str}  {label_str},\n')
                    output.append(f'{indent_str}))\n')

                    # Skip the label lines we just processed
                    i = j + 1
                    continue
                else:
                    # No label positions found, just points
                    output.append(f'{indent_str}ctz-draw(points: ({points}))\n')
                    i = j + 1
                    continue
            else:
                # No labels following, just replace points
                output.append(f'{indent_str}ctz-draw(points: ({points}))\n')
                i += 1
                continue

    output.append(line)
    i += 1

with open('docs/manual.typ', 'w') as f:
    f.writelines(output)

print("Multiline replacement done!")

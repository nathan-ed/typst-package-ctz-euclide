#!/usr/bin/env python3
import re

with open('docs/manual.typ', 'r') as f:
    lines = f.readlines()

output = []
i = 0
skip_until = -1

while i < len(lines):
    if i < skip_until:
        i += 1
        continue

    line = lines[i]

    # Skip section headers and documentation references
    if ('`ctz-draw-points`' in line or
        '`ctz-def-points` and `ctz-draw-points`' in line or
        '- `ctz-draw-points(names...)' in line or
        '- `ctz-draw-labels(names' in line):
        output.append(line)
        i += 1
        continue

    # Check if this line contains ctz-draw-points
    if 'ctz-draw-points(' in line:
        # Extract the indentation and points
        indent = len(line) - len(line.lstrip())
        indent_str = ' ' * indent

        points_match = re.search(r'ctz-draw-points\((.*?)\)', line)
        if not points_match:
            output.append(line)
            i += 1
            continue

        points = points_match.group(1)

        # Look ahead for ctz-draw-labels
        if i + 1 < len(lines) and 'ctz-draw-labels' in lines[i + 1]:
            # Collect all label lines
            j = i + 1
            label_lines = []
            paren_count = 0
            started = False

            while j < len(lines):
                label_lines.append(lines[j])
                for char in lines[j]:
                    if char == '(':
                        paren_count += 1
                        started = True
                    elif char == ')':
                        paren_count -= 1
                        if started and paren_count == 0:
                            break
                if started and paren_count == 0:
                    break
                j += 1

            # Parse labels
            label_text = ''.join(label_lines)
            # Extract label positions (key: value pairs)
            label_matches = re.findall(r'(\w+):\s*(?:"([^"]+)"|(\([^)]+\)))', label_text)

            if label_matches:
                # Build the unified syntax
                output.append(f'{indent_str}ctz-draw(points: ({points}), labels: (\n')
                for name, simple_pos, complex_pos in label_matches:
                    pos = simple_pos if simple_pos else complex_pos
                    output.append(f'{indent_str}  {name}: {"\"" + pos + "\"" if simple_pos else pos},\n')
                # Remove trailing comma from last line
                if output[-1].endswith(',\n'):
                    output[-1] = output[-1][:-2] + '\n'
                output.append(f'{indent_str}))\n')

                # Skip processed lines
                skip_until = j + 1
                i = j + 1
                continue
            else:
                # No labels found, just points
                output.append(f'{indent_str}ctz-draw(points: ({points}))\n')
                skip_until = j + 1
                i = j + 1
                continue
        else:
            # No labels following
            output.append(f'{indent_str}ctz-draw(points: ({points}))\n')
            i += 1
            continue

    output.append(line)
    i += 1

with open('docs/manual.typ', 'w') as f:
    f.writelines(output)

print("Complete multiline replacement done!")

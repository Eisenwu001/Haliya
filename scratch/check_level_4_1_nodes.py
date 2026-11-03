import re

with open('scenes/cave/level_4_1.tscn') as f:
    text = f.read()

matches = re.finditer(r'\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?\]\s*(?:position = Vector2\(([^)]+)\))?', text)
for m in matches:
    name, ntype, parent, pos = m.group(1), m.group(2), m.group(3) or ".", m.group(4)
    if pos:
        coords = [float(p.strip()) for p in pos.split(',')]
        if 1000 <= coords[0] <= 1400:
            print(f"{name:20} {ntype:20} parent={parent:20} pos={coords}")

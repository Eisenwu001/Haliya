import re

with open(r'scenes\cave\level_4_1.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

for block in text.split('[node name='):
    if not block.strip():
        continue
    lines = block.strip().split('\n')
    name = lines[0].split('"')[1] if '"' in lines[0] else ''
    pos = None
    for l in lines:
        if 'position = Vector2(' in l:
            m = re.search(r'position = Vector2\(([^,\)]+),\s*([^\)]+)\)', l)
            if m:
                pos = (float(m.group(1)), float(m.group(2)))
                break
    if pos:
        if any(k in name for k in ['Platform', 'Flora', 'Spire', 'Geode', 'Light', 'Crystal', 'Ledge']):
            print(f'{name:25} pos={pos}')

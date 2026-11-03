import re

scenes = [
    r'scenes\cave\level_4_1.tscn',
    r'scenes\cave\level_4_2.tscn',
    r'scenes\cave\level_4_3.tscn',
    r'scenes\cave\level_5.tscn'
]

for s_path in scenes:
    with open(s_path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    print('=== ' + s_path + ' ===')
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
        if pos and any(k in name for k in ['Flora', 'Spire', 'Stele', 'Geode', 'Light']):
            # Print props that are in LevelProps
            if 'CrystalSpire' in name or 'CavernFlora' in name:
                print(f'  Prop: {name:20} pos={pos}')

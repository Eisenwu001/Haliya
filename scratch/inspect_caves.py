import base64
import struct
import re
import os

def inspect_tscn(path):
    print('=== Inspecting', path, '===')
    if not os.path.exists(path):
        print("  File not found!")
        return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # find tile_map_data
    matches = re.findall(r'\[node name="([^"]+)" type="TileMapLayer"[^\]]*\][\s\S]*?tile_map_data = PackedByteArray\("([^"]*)"\)', content)
    for name, b64 in matches:
        raw = base64.b64decode(b64)
        if len(raw) < 2:
            print(f'  Layer {name}: empty')
            continue
        cells = []
        for i in range(2, len(raw), 12):
            col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', raw[i:i+12])
            cells.append((col, row, src, ax, ay, alt))
        print(f'  Layer {name}: {len(cells)} cells')
        if not cells:
            continue
        min_c = min(c[0] for c in cells)
        max_c = max(c[0] for c in cells)
        min_r = min(c[1] for c in cells)
        max_r = max(c[1] for c in cells)
        print(f'    Col range: {min_c}..{max_c} (X: {min_c*32}..{max_c*32})')
        print(f'    Row range: {min_r}..{max_r} (Y: {min_r*32}..{max_r*32})')
        # Print distinct atlas coords
        atlas_coords = set((c[3], c[4]) for c in cells)
        print(f'    Atlas coords used: {sorted(atlas_coords)}')

    # check staticbodies / collision
    bodies = re.findall(r'\[node name="([^"]+)" type="StaticBody2D" parent="([^"]*)"[^\]]*\][\s\S]*?(?=\[node|\Z)', content)
    print(f'  StaticBodies count: {len(bodies)}')
    for bname, parent in bodies[:10]:
        print(f'    Body: {parent}/{bname}')

for p in ['scenes/cave/level_4_1.tscn', 'scenes/cave/level_4_2.tscn', 'scenes/cave/level_4_3.tscn', 'scenes/cave/level_5.tscn', 'scenes/cave/level_4.tscn']:
    inspect_tscn(p)

import base64
import struct
import re

for level_path in ['scenes/forest/level_1_1.tscn', 'scenes/rice_field/level_2_1.tscn', 'scenes/rainy_forest/level_3_1.tscn']:
    with open(level_path, 'r', encoding='utf-8') as f:
        text = f.read()

    m = re.search(r'\[node name="BaseGround" type="TileMapLayer"[^\]]*\][\s\S]*?tile_map_data = PackedByteArray\("([^"]*)"\)', text)
    if m:
        raw = base64.b64decode(m.group(1))
        cells = []
        for i in range(2, len(raw), 12):
            col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', raw[i:i+12])
            cells.append((col, row, src, ax, ay, alt))
        min_r = min(c[1] for c in cells)
        print(f'{level_path}: min row = {min_r} (Y={min_r*32})')
        row_cells = [c for c in cells if c[1] == min_r]
        print('  Sample cells at min_r:', row_cells[:5])

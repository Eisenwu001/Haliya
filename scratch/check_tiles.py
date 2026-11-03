import os
import re
import base64
import struct

def check_scene(path):
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    for m in re.finditer(r'tile_map_data = PackedByteArray\("([^"]+)"\)', text):
        data = base64.b64decode(m.group(1))
        cells = []
        for i in range(2, len(data), 12):
            col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', data[i:i+12])
            cells.append((col, row, src, ax, ay, alt))
        if cells:
            rows = [r for c, r, *rest in cells]
            cols = [c for c, r, *rest in cells]
            print(f"{path}: {len(cells)} cells, cols {min(cols)}..{max(cols)}, rows {min(rows)}..{max(rows)}")

check_scene("scenes/forest/level_1_1.tscn")
check_scene("scenes/rice_field/level_2_1.tscn")
check_scene("scenes/rainy_forest/level_3_1.tscn")

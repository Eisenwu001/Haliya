import base64
import struct
import re

with open('scenes/cave/level_4_1.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r'\[node name="BaseGround" type="TileMapLayer"[^\]]*\][\s\S]*?tile_map_data = PackedByteArray\("([^"]*)"\)', text)
if m:
    raw = base64.b64decode(m.group(1))
    cells = []
    for i in range(2, len(raw), 12):
        col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', raw[i:i+12])
        cells.append((col, row, src, ax, ay, alt))
    
    # check cells with col between 48 and 70
    bastion_cells = [c for c in cells if 48 <= c[0] <= 70]
    min_r = min(c[1] for c in bastion_cells)
    print(f"Bastion (cols 48..70) min row: {min_r} (Y={min_r*32})")
    for r in range(min_r, min_r + 3):
        row_c = [c for c in bastion_cells if c[1] == r]
        print(f"  Row {r}: {len(row_c)} cells, sample: {row_c[0] if row_c else None}")

import base64
import struct
import re

with open('scenes/rice_field/level_2_1.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r'PackedByteArray\("([^"]+)"\)', text)
if m:
    data = base64.b64decode(m.group(1))
    cells = []
    for i in range(2, len(data), 12):
        col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', data[i:i+12])
        cells.append((col, row, src, ax, ay, alt))
    print('Total cells:', len(cells))
    unique_tiles = set((c[2], c[3], c[4]) for c in cells)
    print('Unique tiles (src, ax, ay):', unique_tiles)
    print('Cols:', min(c[0] for c in cells), 'to', max(c[0] for c in cells))
    print('Rows:', min(c[1] for c in cells), 'to', max(c[1] for c in cells))

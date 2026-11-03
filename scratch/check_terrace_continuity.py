import base64
import struct

with open("scenes/rice_field/level_2_1.tscn", "r", encoding="utf-8") as f:
    text = f.read()

import re
m = re.search(r'name="BaseGround"[\s\S]*?PackedByteArray\("([^"]+)"\)', text)
data = base64.b64decode(m.group(1))

cells = {}
for i in range(2, len(data), 12):
    col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', data[i:i+12])
    cells[(col, row)] = (src, ax, ay, alt)

print(f"Total cells: {len(cells)}")
min_col = min(c for c, r in cells)
max_col = max(c for c, r in cells)
min_row = min(r for c, r in cells)
max_row = max(r for c, r in cells)
print(f"Cols: {min_col}..{max_col}, Rows: {min_row}..{max_row}")

# Check for any column without a surface tile:
for c in range(min_col, max_col + 1):
    c_rows = [r for (col, r) in cells if col == c]
    top_r = min(c_rows)
    # check that all rows from top_r to max_row exist:
    missing = [r for r in range(top_r, max_row + 1) if (c, r) not in cells]
    if missing:
        print(f"Col {c} MISSING rows: {missing}")

# Check terrace boundaries:
# E.g. where top_r changes
for c in range(min_col, max_col):
    top1 = min(r for (col, r) in cells if col == c)
    top2 = min(r for (col, r) in cells if col == c + 1)
    if top1 != top2:
        print(f"Transition at col {c}->{c+1}: top_row {top1} -> {top2}. Cell at ({c}, {top1})={cells.get((c, top1))}, ({c+1}, {top2})={cells.get((c+1), top2)}")

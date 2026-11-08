import base64
import struct

with open('scenes/forest/level_1_1.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

# Find BaseGround tile_map_data
import re
m = re.search(r'\[node name="BaseGround"[^\]]*\]\s*tile_map_data = PackedByteArray\("([^"]+)"\)', text)
if m:
    data = base64.b64decode(m.group(1))
    print('BaseGround raw byte length:', len(data))
    # In Godot 4.3+, TileMapLayer tile_map_data is packed format:
    # 12 bytes per tile cell:
    # int16 x, int16 y, int16 source_id, int16 atlas_coords_x, int16 atlas_coords_y, int16 alternative_tile
    num_tiles = len(data) // 12
    print(f'Total tiles in BaseGround: {num_tiles}')
    y_coords = []
    x_coords = []
    sources = set()
    for i in range(num_tiles):
        x, y, src, ax, ay, alt = struct.unpack_from('<hhhhhh', data, i * 12)
        y_coords.append(y)
        x_coords.append(x)
        sources.add(src)
    print(f'x range: [{min(x_coords)}, {max(x_coords)}]')
    print(f'y range: [{min(y_coords)}, {max(y_coords)}]')
    print('Sources:', sources)
    # y * 32 gives world coordinates in pixels!
    print(f'Pixel y range: [{min(y_coords)*32}, {max(y_coords)*32}]')

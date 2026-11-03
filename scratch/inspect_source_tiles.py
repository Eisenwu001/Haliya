import re

with open('scenes/tileset.tres', 'r', encoding='utf-8') as f:
    text = f.read()

# Find sub_resource 0 (TileSetAtlasSource_kbenk)
m = re.search(r'\[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_kbenk"\](.*?)\[sub_resource', text, re.DOTALL)
if m:
    tiles_0 = re.findall(r'(\d+):(\d+)/0\s*=', m.group(1))
    print(f"Source 0 (Floor Tiles1) has {len(tiles_0)} tiles:")
    print("Coordinates:", sorted(set((int(c), int(r)) for c, r in tiles_0)))

# Find source 1 (Other Tiles1)
m1 = re.search(r'\[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_y1c8q"\](.*?)\[sub_resource', text, re.DOTALL)
if m1:
    tiles_1 = re.findall(r'(\d+):(\d+)/0\s*=', m1.group(1))
    print(f"\nSource 1 (Other Tiles1) has {len(tiles_1)} tiles:")
    print("Coordinates:", sorted(set((int(c), int(r)) for c, r in tiles_1)))

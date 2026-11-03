import re

with open("scenes/tileset.tres", "r", encoding="utf-8") as f:
    text = f.read()

sources = re.findall(r'\[sub_resource type="TileSetAtlasSource" id="([^"]+)"\]\ntexture = ExtResource\("([^"]+)"\)([\s\S]*?)(?=\n\[sub_resource|\Z)', text)

for s_id, ext_res, body in sources:
    coords = re.findall(r'^(\d+:\d+)/0 = 0', body, re.MULTILINE)
    print(f"Source {s_id} (resource {ext_res}): {len(coords)} tiles")
    print("  Tiles:", ", ".join(coords[:15]), f"... (total {len(coords)})")

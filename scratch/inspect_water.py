with open('scenes/scene_01.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r'\[sub_resource type="TileSetAtlasSource" id="([^"]+)"\]\ntexture = ExtResource\("([^"]+)"\)', text)
print("Sources:")
for mid, eid in matches:
    print(mid, "->", eid)

for line in text.split('\n'):
    if 'sources/' in line or '3_mxulj' in line:
        print(line)

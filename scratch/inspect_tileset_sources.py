import re

with open('scenes/tileset.tres', 'r', encoding='utf-8') as f:
    text = f.read()

ext_map = {}
for m in re.finditer(r'\[ext_resource [^\]]*path="([^"]+)" id="([^"]+)"\]', text):
    ext_map[m.group(2)] = m.group(1)

for m in re.finditer(r'\[sub_resource type="TileSetAtlasSource" id="([^"]+)"\]\ntexture = ExtResource\("([^"]+)"\)', text):
    sid = m.group(1)
    eid = m.group(2)
    path = ext_map.get(eid, eid)
    print(f'{sid} -> {path}')

print('--- Sources Map ---')
for m in re.finditer(r'sources/(\d+) = SubResource\("([^"]+)"\)', text):
    print(f'source {m.group(1)} -> {m.group(2)}')

print('--- Decor Source 6 Tiles ---')
m = re.search(r'\[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_l50s2"\]\n([\s\S]*?)(?=\n\[sub_resource|\n\[resource\])', text)
if m:
    lines = m.group(1).splitlines()
    print('\n'.join(lines[:30]))

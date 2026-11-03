import re

with open('scenes/cave/level_4.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

# map ext_resource id to path
res_map = {}
for m in re.finditer(r'\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]', text):
    res_map[m.group(3)] = m.group(2)

print("Resources:", res_map)

# find all sprites and their texture & region_rect
sprites = re.findall(r'\[node name="([^"]+)" type="Sprite2D" parent="([^"]+)"[^\]]*\]\s*([^\[]*)', text)
print(f"Total sprites: {len(sprites)}")

from collections import Counter
regions_by_tex = {}
for name, parent, body in sprites:
    tex_m = re.search(r'texture = ExtResource\("([^"]+)"\)', body)
    reg_m = re.search(r'region_rect = Rect2\(([^)]+)\)', body)
    if tex_m:
        tex_id = tex_m.group(1)
        tex_path = res_map.get(tex_id, tex_id)
        reg = reg_m.group(1) if reg_m else "no_region"
        if tex_path not in regions_by_tex:
            regions_by_tex[tex_path] = Counter()
        regions_by_tex[tex_path][reg] += 1

for tex, counter in regions_by_tex.items():
    print(f"\nTexture: {tex} (total sprites {sum(counter.values())})")
    for reg, count in counter.most_common(15):
        print(f"  {reg}: {count}")

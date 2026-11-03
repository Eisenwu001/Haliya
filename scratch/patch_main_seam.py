with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix scale multiplier 1.001 -> exact scale_factor
old1 = 'spr.scale = Vector2(scale_factor * 1.001, scale_factor)'
new1 = 'spr.scale = Vector2(scale_factor, scale_factor)'
assert old1 in content, 'old1 not found'
content = content.replace(old1, new1, 1)

# 2. Hide shared sky sprite during Rice Field so cyan background_layer_5 doesn't leak behind Mayon
old2 = 'sky_parallax_layer.visible = not is_cave'
new2 = 'sky_parallax_layer.visible = not is_cave and not (theme_name == "Rice Field")'
assert old2 in content, 'old2 not found'
content = content.replace(old2, new2, 1)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(content)
print('scripts/main.gd updated successfully!')

import re

def update_scene(scene_path):
    print("Updating:", scene_path)
    with open(scene_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update SubResource_p_ sizes from (w, 14) to (w, 12)
    def fix_subresource(match):
        res_id = match.group(1)
        w = match.group(2)
        return f'[sub_resource type="RectangleShape2D" id="{res_id}"]\nsize = Vector2({w}, 12)'

    content = re.sub(
        r'\[sub_resource type="RectangleShape2D" id="(SubResource_p_\d+)"\]\s+size = Vector2\(([\d\.]+),\s*14\)',
        fix_subresource,
        content
    )

    # 2. Update Platform nodes:
    def fix_platform(match):
        full_block = match.group(0)
        p_name = match.group(1)
        cx = float(match.group(2))
        old_cy = float(match.group(3))
        sx = float(match.group(4))
        old_sy = float(match.group(5))
        rx = float(match.group(6))
        ry = float(match.group(7))
        rw = float(match.group(8))
        old_rh = float(match.group(9))

        py = round(old_cy - 7.0, 1)
        new_cy = py + 6.0

        # Determine new region and sprite y based on style/width
        if rw == 96.0 and ry == 0.0:
            # island_md: new height is 48
            new_rh = 48.0
            new_sy = py + 24.0
        elif rw == 128.0 and ry == 0.0:
            # island_lg: new height is 56
            new_rh = 56.0
            new_sy = py + 28.0
        elif rw == 128.0 and ry == 64.0:
            # bridge: height 40
            new_rh = 40.0
            new_sy = py + 20.0
        elif rw == 160.0 and ry == 104.0:
            # sanctuary: height 56
            new_rh = 56.0
            new_sy = py + 28.0
        else:
            new_rh = old_rh
            new_sy = py + (new_rh / 2.0)

        # Replace in block
        # Replace CollisionShape2D position
        new_block = re.sub(
            rf'(parent="ElevatedPlatforms/{p_name}"\]\s+position = Vector2\(){re.escape(match.group(2))},\s*{re.escape(match.group(3))}(\))',
            rf'\g<1>{cx:.1f}, {new_cy:.1f}\2',
            full_block
        )
        # Replace Sprite2D position
        new_block = re.sub(
            rf'(parent="ElevatedPlatforms/{p_name}"\][\s\S]*?position = Vector2\(){re.escape(match.group(4))},\s*{re.escape(match.group(5))}(\))',
            rf'\g<1>{sx:.1f}, {new_sy:.1f}\2',
            new_block
        )
        # Replace region_rect
        new_block = re.sub(
            rf'(region_rect = Rect2\(){int(rx)},\s*{int(ry)},\s*{int(rw)},\s*{int(old_rh)}(\))',
            rf'\g<1>{int(rx)}, {int(ry)}, {int(rw)}, {int(new_rh)}\2',
            new_block
        )

        print(f"  Fixed {p_name}: py={py:.1f} -> col_y={new_cy:.1f}, spr_y={new_sy:.1f}, rh={new_rh:.0f}")
        return new_block

    plat_pattern = re.compile(
        r'\[node name="(Platform_\d+)" type="StaticBody2D" parent="ElevatedPlatforms"\][\s\S]*?'
        r'\[node name="CollisionShape2D" type="CollisionShape2D" parent="ElevatedPlatforms/\1"\]\s+'
        r'position = Vector2\(([\d\.]+),\s*([\d\.]+)\)[\s\S]*?'
        r'\[node name="Sprite2D" type="Sprite2D" parent="ElevatedPlatforms/\1"\][\s\S]*?'
        r'position = Vector2\(([\d\.]+),\s*([\d\.]+)\)\s+'
        r'region_rect = Rect2\(([\d\.]+),\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\)'
    )

    new_content = plat_pattern.sub(fix_platform, content)
    
    with open(scene_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Done:", scene_path)

update_scene("scenes/cave/level_4.tscn")
update_scene("scenes/cave/level_5.tscn")

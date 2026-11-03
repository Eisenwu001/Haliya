import re

def analyze_platforms(scene_path):
    print("ANALYSIS OF:", scene_path)
    with open(scene_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to find each platform:
    # [node name="Platform_X" type="StaticBody2D" parent="ElevatedPlatforms"]
    # ...
    # [node name="CollisionShape2D" type="CollisionShape2D" parent="ElevatedPlatforms/Platform_X"]
    # position = Vector2(cx, cy)
    # shape = SubResource("SubResource_p_X")
    # ...
    # [node name="Sprite2D" type="Sprite2D" parent="ElevatedPlatforms/Platform_X"]
    # position = Vector2(sx, sy)
    # region_rect = Rect2(rx, ry, rw, rh)
    
    pattern = re.compile(
        r'\[node name="(Platform_\d+)" type="StaticBody2D" parent="ElevatedPlatforms"\][\s\S]*?'
        r'position = Vector2\(([\d\.]+),\s*([\d\.]+)\)[\s\S]*?'
        r'shape = SubResource\("(SubResource_p_\d+)"\)[\s\S]*?'
        r'position = Vector2\(([\d\.]+),\s*([\d\.]+)\)[\s\S]*?'
        r'region_rect = Rect2\(([\d\.]+),\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\)'
    )
    
    matches = pattern.findall(content)
    print(f"Found {len(matches)} platform patterns")
    for m in matches:
        p_name, col_x, col_y, shape_id, spr_x, spr_y, rx, ry, rw, rh = m
        print(f"{p_name}: col=({col_x}, {col_y}), spr=({spr_x}, {spr_y}), region=({rx},{ry},{rw},{rh})")

analyze_platforms("scenes/cave/level_4.tscn")
analyze_platforms("scenes/cave/level_5.tscn")

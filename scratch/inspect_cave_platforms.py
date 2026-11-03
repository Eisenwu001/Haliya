import re

for scene_path in ['scenes/cave/level_4.tscn', 'scenes/cave/level_5.tscn']:
    print('=== ' + scene_path + ' ===')
    with open(scene_path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    m = re.search(r'\[node name="ElevatedPlatforms"[\s\S]*?(?=\[node name="(?:PogoCrystals|LevelProps|LevelTorches|Enemies)")', text)
    if m:
        elev_text = m.group(0)
        regions = re.findall(r'region_rect = Rect2\((.*?)\)', elev_text)
        print('Regions in ElevatedPlatforms:', set(regions))
        col_shapes = re.findall(r'\[sub_resource type="RectangleShape2D" id="(SubResource_p_\d+)"\]\s+size = Vector2\((.*?)\)', text)
        print('SubResource shapes for platforms:', col_shapes[:10])
        
        # Let's inspect each platform node and sprite
        # E.g. Platform_0 with shape and sprite
        p_nodes = re.findall(r'\[node name="(Platform_\d+)"[\s\S]*?(?=\[node|\Z)', elev_text)
        print(f'Found {len(p_nodes)} platform chunks')

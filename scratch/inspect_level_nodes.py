import re

for level_file in ['scenes/forest/level_1_1.tscn', 'scenes/forest/level_1_2.tscn', 'scenes/forest/level_1_3.tscn']:
    with open(level_file, 'r', encoding='utf-8') as f:
        text = f.read()
    print(f'=== {level_file} ===')
    tilemap_layers = re.findall(r'\[node name="([^"]+)" type="TileMapLayer"[^\]]*\]', text)
    print('TileMapLayers:', tilemap_layers)
    ground_segments = re.findall(r'GroundSegments', text)
    print('GroundSegments found in file:', len(ground_segments))

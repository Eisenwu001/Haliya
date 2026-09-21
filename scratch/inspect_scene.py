with open('scenes/scene_03.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
print('\n'.join(re.findall(r'sources/\d+\s*=\s*SubResource\([^\)]+\)', text)))
print('\n'.join(re.findall(r'\[sub_resource type=\"TileSetAtlasSource\" id=\"([^\"]+)\"\]', text)))

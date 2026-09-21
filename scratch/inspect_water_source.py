with open('scenes/scene_01.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
idx = text.find('TileSetAtlasSource_vxpot')
print(text[idx:idx+2500])

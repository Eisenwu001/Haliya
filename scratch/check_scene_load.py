with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r'(\w*level_builder\w*)', text, re.IGNORECASE)
print('level_builder references in main.gd:', set(matches))

# Let's search for how scene_path is instantiated in main.gd
for i, line in enumerate(text.splitlines()):
    if 'scene_path' in line or 'load_level' in line or 'change_scene' in line:
        print(f'{i+1}: {line.strip()[:100]}')

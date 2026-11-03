import re

with open('scripts/level_builder.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Find get_level_layout forest and rice field sections
m = re.search(r'if theme == "Forest":.*?(?=func build_level)', text, re.DOTALL)
if m:
    print(m.group(0)[:3000])

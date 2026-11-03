import re

with open('scripts/tutorial_stage.gd', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r'res://assets/[^\"]+', text)
for m in sorted(set(matches)):
    print(m)

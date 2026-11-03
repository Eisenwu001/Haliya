import re
from collections import Counter

with open('scenes/cave/level_4.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

nodes = re.findall(r'\[node name="([^"]+)" type="([^"]+)"', text)
print('First 20 nodes:', nodes[:20])
print('Node types count:', Counter(t for n, t in nodes))

res = re.findall(r'\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]', text)
for r in res:
    print('Resource:', r)

# Look for top-level groups
children = re.findall(r'\[node name="([^"]+)" type="([^"]+)" parent="\."', text)
print('Direct children of root:', children)

# Look at breakables, enemies, torches, props
for group in ['Props', 'Torches', 'Breakables', 'Enemies', 'Platforms', 'GroundSegments', 'Hazards']:
    items = re.findall(r'\[node name="([^"]+)" type="([^"]+)" parent="' + group + r'(\/[^"]*)?"', text)
    print(f'{group} count: {len(items)}')
    if len(items) <= 15:
        print(f'{group} items:', items)

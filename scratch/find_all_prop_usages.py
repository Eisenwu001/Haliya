import os, glob

matches = []
for ext in ['*.gd', '*.tscn']:
    for path in glob.glob(f'**/{ext}', recursive=True):
        if path.startswith('.git') or path.startswith('scratch'):
            continue
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            for prop in ['prop_wooden_fence', 'prop_firewood', 'prop_mossy_rocks', 'prop_banana_tree', 'prop_rooster', 'prop_sleeping_cat']:
                if prop in content:
                    matches.append((path, prop))
        except Exception as e:
            pass

for p, m in sorted(set(matches)):
    print(f'{p}: {m}')

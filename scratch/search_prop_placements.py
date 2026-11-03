with open('scripts/tutorial_stage.gd', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if any(k in line for k in ['prop_', 'fence', 'firewood', 'rocks', 'banana', 'platform', 'crouch', 'rooster', 'cat', 'rack']):
        print(f'{i+1:4d}: {line.rstrip()}')

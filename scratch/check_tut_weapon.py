with open('scripts/tutorial_stage.gd', 'r', encoding='utf-8', errors='ignore') as f:
    for i, line in enumerate(f):
        if 'weapon' in line.lower():
            print(f'{i+1:4d}: {line.rstrip()[:100]}')

with open('scripts/player.gd', 'r', encoding='utf-8', errors='ignore') as f:
    for i, line in enumerate(f):
        if any(k in line.lower() for k in ['canvaslayer', 'weapon', 'unarmed', 'badge', 'hud']):
            print(f'{i+1:4d}: {line.rstrip()[:100]}')

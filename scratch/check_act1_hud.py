with open('scripts/act1_bahay_kubo.gd', 'r', encoding='utf-8', errors='ignore') as f:
    for i, line in enumerate(f):
        if 'hp' in line.lower() or 'health' in line.lower() or 'stamina' in line.lower():
            if 'bar' in line.lower() or 'fill' in line.lower() or 'hud' in line.lower():
                print(f'{i+1:4d}: {line.rstrip()[:100]}')

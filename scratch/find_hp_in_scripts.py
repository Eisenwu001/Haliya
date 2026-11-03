import glob

for p in glob.glob('scripts/*.gd'):
    with open(p, 'r', encoding='utf-8', errors='ignore') as f:
        c = f.read()
    if 'hud_hp_fill' in c:
        print('Found in:', p)

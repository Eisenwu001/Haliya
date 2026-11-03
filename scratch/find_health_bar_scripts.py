import glob

for p in glob.glob('scripts/*.gd'):
    with open(p, 'r', encoding='utf-8', errors='ignore') as f:
        c = f.read()
    if 'health_bar' in c or 'hp_bar' in c:
        print('Found in:', p)

import glob, re

for p in glob.glob('scripts/*.gd'):
    with open(p, 'r', encoding='utf-8', errors='ignore') as f:
        c = f.read()
    if 'Unarmed' in c:
        print('Found Unarmed in:', p)

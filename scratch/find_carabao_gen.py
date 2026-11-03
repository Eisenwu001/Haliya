with open('scripts/build_flawless_layers.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if 'carabao' in line.lower():
        print(f"flawless L{i+1}: {line.strip()}")

with open('scripts/build_artistic_rice_field.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if 'carabao' in line.lower():
        print(f"artistic L{i+1}: {line.strip()}")

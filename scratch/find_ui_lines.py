with open('scripts/tutorial_stage.gd', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if any(k in line for k in ['func setup_ui', 'objective_panel', 'hp_bar', 'stamina_bar']):
        safe_line = line.rstrip().encode('ascii', errors='replace').decode('ascii')
        print(f'{i+1:4d}: {safe_line}')

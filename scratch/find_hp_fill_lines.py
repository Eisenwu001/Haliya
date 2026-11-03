with open('scripts/tutorial_stage.gd', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if any(k in line for k in ['HP_FILL_MAX_WIDTH', 'STA_FILL_MAX_WIDTH', '_update_hp_bar_display', 'hp_fill_clip']):
        safe_line = line.rstrip().encode('ascii', errors='replace').decode('ascii')
        print(f'{i+1:4d}: {safe_line}')

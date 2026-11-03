with open("scripts/main.gd", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'elif cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:' in line:
        lines[i] = '\telif cur_title_guar == "Level 2-5":\n'
    elif 'elif cur_lvl_title in ["Level 4-3", "Level 4-4"]:' in line:
        if i < 2000:
            lines[i] = '\telif cur_title_guar == "Level 4-4":\n'
        else:
            lines[i] = '\telif LEVELS_DATA[current_level_idx].get("theme", "") == "Cave":\n'
    elif 'if current_level_idx == 5:' in line and i > 3600:
        lines[i] = '\tif LEVELS_DATA[current_level_idx].get("theme", "") == "Rice Field":\n'

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.writelines(lines)

print("Line replacements applied successfully!")

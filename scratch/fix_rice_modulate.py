with open("scripts/main.gd", "r", encoding="utf-8") as f:
    text = f.read()

old_block = """\t\tif current_level_idx == 3: # Level 2-1: Emerald Terraces (Sunlit golden hour)
\t\t\tbase_modulate_color = Color(1.02, 1.01, 0.98, 1.0)
\t\telif current_level_idx == 4: # Level 2-2: Stilt Farmstead (Rosy twilight)
\t\t\tbase_modulate_color = Color(0.94, 0.88, 0.96, 1.0)
\telif cur_title_guar == "Level 2-5":
\t\t\tbase_modulate_color = Color(0.96, 0.82, 0.76, 1.0)
\t\telse:
\t\t\tbase_modulate_color = Color(1.0, 1.0, 1.0, 1.0)"""

new_block = """\t\tif cur_lvl_title == "Level 2-1":
\t\t\tbase_modulate_color = Color(1.02, 1.01, 0.98, 1.0)
\t\telif cur_lvl_title == "Level 2-2":
\t\t\tbase_modulate_color = Color(0.94, 0.88, 0.96, 1.0)
\t\telif cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:
\t\t\tbase_modulate_color = Color(0.96, 0.82, 0.76, 1.0)
\t\telse:
\t\t\tbase_modulate_color = Color(1.0, 1.0, 1.0, 1.0)"""

assert old_block in text, "old_block not found in main.gd"
text = text.replace(old_block, new_block)

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("Fixed lines 1001-1008 in main.gd!")

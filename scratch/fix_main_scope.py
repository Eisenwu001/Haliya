with open("scripts/main.gd", "r", encoding="utf-8") as f:
    text = f.read()

# Fix 1
text = text.replace('elif cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:', 'elif cur_title_guar == "Level 2-5":')
text = text.replace('elif cur_lvl_title in ["Level 4-3", "Level 4-4"]:', 'elif cur_title_guar == "Level 4-4":')

# Fix 2
old_mb = """\tvar title := "CORRUPTED SENTINEL: FOREST BRUTE"
\tvar color := Color(0.95, 0.55, 0.20, 1.0)
\tif current_level_idx == 5:
\t\ttitle = "MAYON FLAME VANGUARD"
\t\tcolor = Color(1.0, 0.45, 0.15, 1.0)
\telif cur_lvl_title in ["Level 4-3", "Level 4-4"]:
\t\ttitle = "ABYSSAL LUNAR WARDEN: SANCTUM VANGUARD"
\t\tcolor = Color(0.52, 0.85, 1.0, 1.0)"""

new_mb = """\tvar title := "CORRUPTED SENTINEL: FOREST BRUTE"
\tvar color := Color(0.95, 0.55, 0.20, 1.0)
\tvar cur_theme_mb = LEVELS_DATA[current_level_idx].get("theme", "")
\tif cur_theme_mb == "Rice Field":
\t\ttitle = "MAYON FLAME VANGUARD"
\t\tcolor = Color(1.0, 0.45, 0.15, 1.0)
\telif cur_theme_mb == "Cave":
\t\ttitle = "ABYSSAL LUNAR WARDEN: SANCTUM VANGUARD"
\t\tcolor = Color(0.52, 0.85, 1.0, 1.0)"""

assert old_mb in text, "old_mb target not found"
text = text.replace(old_mb, new_mb)

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("Fixed main.gd variable scopes successfully!")

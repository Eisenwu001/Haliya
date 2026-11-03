with open("scripts/main.gd", "r", encoding="utf-8") as f:
    text = f.read()

# 1. Remove duplicate Low-HP pulse inside trigger_game_win
dup_pulse = """\t# Low HP Desperation Pulse (when player is at 1 HP)
\tif low_hp_vignette:
\t\tif is_instance_valid(player) and player.current_hp == 1 and not player.is_locked_transition:
\t\t\tvar t_pulse = sin(Time.get_ticks_msec() * 0.007)
\t\t\tvar target_alpha = 0.14 + 0.12 * max(0.0, t_pulse)
\t\t\tlow_hp_vignette.color.a = lerp(low_hp_vignette.color.a, target_alpha, delta * 8.0)
\t\telse:
\t\t\tlow_hp_vignette.color.a = lerp(low_hp_vignette.color.a, 0.0, delta * 6.0)"""

text = text.replace(dup_pulse, "")

# 2. Add cur_lvl_title declaration at start of set_background_theme
set_bg_anchor = """func set_background_theme(theme_name: String) -> void:"""
set_bg_replacement = """func set_background_theme(theme_name: String) -> void:
\tvar cur_lvl_title: String = LEVELS_DATA[current_level_idx].get("level_title", "") if current_level_idx < LEVELS_DATA.size() else \"\""""

assert set_bg_anchor in text
text = text.replace(set_bg_anchor, set_bg_replacement)

# Replace any cur_title_guar inside set_background_theme with cur_lvl_title
text = text.replace('cur_title_guar == "Level 2-5"', 'cur_lvl_title in ["Level 2-3", "Level 2-4", "Level 2-5"]')
text = text.replace('cur_title_guar == "Level 4-4"', 'cur_lvl_title in ["Level 4-3", "Level 4-4"]')

# 3. Fix miniboss banner title check around line 3720
mb_title_anchor = """\tvar title := "CORRUPTED SENTINEL: FOREST BRUTE"
\tvar color := Color(0.95, 0.55, 0.20, 1.0)
\tif current_level_idx == 5:
\t\ttitle = "MAYON FLAME VANGUARD"
\t\tcolor = Color(1.0, 0.45, 0.15, 1.0)
\telif cur_title_guar == "Level 4-4":"""

mb_title_replacement = """\tvar title := "CORRUPTED SENTINEL: FOREST BRUTE"
\tvar color := Color(0.95, 0.55, 0.20, 1.0)
\tvar cur_mb_title = LEVELS_DATA[current_level_idx].get("level_title", "")
\tif cur_mb_title in ["Level 2-3", "Level 2-4", "Level 2-5"]:
\t\ttitle = "MAYON FLAME VANGUARD"
\t\tcolor = Color(1.0, 0.45, 0.15, 1.0)
\telif cur_mb_title in ["Level 4-3", "Level 4-4"]:"""

if mb_title_anchor in text:
    text = text.replace(mb_title_anchor, mb_title_replacement)
else:
    # Fallback direct replacement
    text = text.replace('elif cur_title_guar == "Level 4-4":', 'elif cur_mb_title in ["Level 4-3", "Level 4-4"]:')

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated scripts/main.gd clean!")

# Remove duplicate UIDs from new scenes
for sc_path in ["scenes/rice_field/level_2_4.tscn", "scenes/rice_field/level_2_5.tscn", "scenes/cave/level_4_4.tscn"]:
    with open(sc_path, "r", encoding="utf-8") as f:
        s_data = f.read()
    s_data = s_data.split("\n", 1)[1] # Drop line 1 with duplicate UID
    s_data = "[gd_scene format=3]\n" + s_data
    with open(sc_path, "w", encoding="utf-8") as f:
        f.write(s_data)
    print(f"Cleaned UID in {sc_path}")

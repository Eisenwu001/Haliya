import re

with open("scripts/main.gd", "r", encoding="utf-8") as f:
    text = f.read()

# ── 1. Update LEVELS_DATA to include Level 2-4, Level 2-5, Level 4-4 ─────────
lvl_2_3_block = """\t{\n\t\t"theme": "Rice Field",\n\t\t"scene_title": "The Mayon Crossing",\n\t\t"level_title": "Level 2-3",\n\t\t"full_title": "Rice Field Scene — Level 2-3: The Mayon Crossing",\n\t\t"scene_path": "res://scenes/rice_field/level_2_3.tscn"\n\t},"""

lvl_2_expansion = """\t{\n\t\t"theme": "Rice Field",\n\t\t"scene_title": "The Mayon Crossing",\n\t\t"level_title": "Level 2-3",\n\t\t"full_title": "Rice Field Scene — Level 2-3: The Mayon Crossing",\n\t\t"scene_path": "res://scenes/rice_field/level_2_3.tscn"\n\t},\n\t{\n\t\t"theme": "Rice Field",\n\t\t"scene_title": "The Caldera Foothills",\n\t\t"level_title": "Level 2-4",\n\t\t"full_title": "Rice Field Scene — Level 2-4: The Caldera Foothills",\n\t\t"scene_path": "res://scenes/rice_field/level_2_4.tscn"\n\t},\n\t{\n\t\t"theme": "Rice Field",\n\t\t"scene_title": "The Burning Kiln Village",\n\t\t"level_title": "Level 2-5",\n\t\t"full_title": "Rice Field Scene — Level 2-5: The Burning Kiln Village",\n\t\t"scene_path": "res://scenes/rice_field/level_2_5.tscn"\n\t},"""

assert lvl_2_3_block in text, "lvl_2_3_block not found in main.gd"
text = text.replace(lvl_2_3_block, lvl_2_expansion)

lvl_4_3_block = """\t{\n\t\t"theme": "Cave",\n\t\t"scene_title": "The Abyssal Gauntlet",\n\t\t"level_title": "Level 4-3",\n\t\t"full_title": "Lapis Caverns — Level 4-3: The Abyssal Gauntlet",\n\t\t"scene_path": "res://scenes/cave/level_4_3.tscn"\n\t},"""

lvl_4_expansion = """\t{\n\t\t"theme": "Cave",\n\t\t"scene_title": "The Abyssal Gauntlet",\n\t\t"level_title": "Level 4-3",\n\t\t"full_title": "Lapis Caverns — Level 4-3: The Abyssal Gauntlet",\n\t\t"scene_path": "res://scenes/cave/level_4_3.tscn"\n\t},\n\t{\n\t\t"theme": "Cave",\n\t\t"scene_title": "The Chasm of Devoured Moons",\n\t\t"level_title": "Level 4-4",\n\t\t"full_title": "Lapis Caverns — Level 4-4: The Chasm of Devoured Moons",\n\t\t"scene_path": "res://scenes/cave/level_4_4.tscn"\n\t},"""

assert lvl_4_3_block in text, "lvl_4_3_block not found in main.gd"
text = text.replace(lvl_4_3_block, lvl_4_expansion)

# ── 2. Add low_hp_vignette variable ─────────────────────────────────────────
assert "var damage_flash_overlay: ColorRect" in text
text = text.replace(
    "var damage_flash_overlay: ColorRect",
    "var damage_flash_overlay: ColorRect\nvar low_hp_vignette: ColorRect"
)

# ── 3. Add low_hp_vignette in setup_ui() ─────────────────────────────────────
target_flash = """\tdamage_flash_overlay = ColorRect.new()\n\tdamage_flash_overlay.name = "DamageFlashOverlay"\n\tdamage_flash_overlay.color = Color(0.85, 0.05, 0.10, 0.0)\n\tdamage_flash_overlay.size = Vector2(640, 360)\n\tdamage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE\n\tui_layer.add_child(damage_flash_overlay)"""

replacement_flash = target_flash + """\n\n\t# ── 6b. Pulsating Low-HP Attrition Vignette ──────────────────────────────\n\tlow_hp_vignette = ColorRect.new()\n\tlow_hp_vignette.name = "LowHpVignette"\n\tlow_hp_vignette.color = Color(0.65, 0.02, 0.05, 0.0)\n\tlow_hp_vignette.size = Vector2(640, 360)\n\tlow_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE\n\tui_layer.add_child(low_hp_vignette)"""

assert target_flash in text, "target_flash not found in main.gd"
text = text.replace(target_flash, replacement_flash)

# ── 4. Add Low-HP pulse in _process() ────────────────────────────────────────
process_target = """\tif is_game_won:\n\t\treturn"""
process_replacement = """\tif is_game_won:\n\t\treturn\n\n\t# Low HP Desperation Pulse (when player is at 1 HP)\n\tif low_hp_vignette:\n\t\tif is_instance_valid(player) and player.current_hp == 1 and not player.is_locked_transition:\n\t\t\tvar t_pulse = sin(Time.get_ticks_msec() * 0.007)\n\t\t\tvar target_alpha = 0.14 + 0.12 * max(0.0, t_pulse)\n\t\t\tlow_hp_vignette.color.a = lerp(low_hp_vignette.color.a, target_alpha, delta * 8.0)\n\t\telse:\n\t\t\tlow_hp_vignette.color.a = lerp(low_hp_vignette.color.a, 0.0, delta * 6.0)"""

assert process_target in text, "process_target not found in main.gd"
text = text.replace(process_target, process_replacement)

# ── 5. Disconnect auto-regen in advance_to_next_level() ───────────────────────
regen_target = """\t\tif player.has_method("reset_combat_state"):\n\t\t\tplayer.reset_combat_state()"""
regen_replacement = """\t\tif player.has_method("reset_combat_state"):\n\t\t\tplayer.reset_combat_state(false) # Retain damage across levels (true attrition!)"""

assert regen_target in text, "regen_target not found in main.gd"
text = text.replace(regen_target, regen_replacement, 1)

# ── 6. Update Climax & Boss Check Points by cur_lvl_title ─────────────────────
# Replace old miniboss lockdown check: (current_level_idx in [2, 5, 13])
miniboss_target = """\t\t\tif (current_level_idx in [2, 5, 13]) and not is_miniboss_arena_locked and not is_player_dead:\n\t\t\t\tif player.global_position.x >= 4050.0:\n\t\t\t\t\ttrigger_miniboss_arena_lockdown()\n\n\t\t\tif current_level_idx == 10:\n\t\t\t\tif not is_boss_active and player.global_position.x >= 3800.0:\n\t\t\t\t\tstart_boss_encounter()\n\t\t\telif current_level_idx == 14:\n\t\t\t\tif not is_boss_active and player.global_position.x >= 3800.0:\n\t\t\t\t\tstart_bakunawa_encounter()\n\t\t\telif player.global_position.x >= current_level_transition_x:\n\t\t\t\tstart_level_transition()"""

miniboss_replacement = """\t\t\tvar cur_title_chk = LEVELS_DATA[current_level_idx].get("level_title", "")\n\t\t\tif (cur_title_chk in ["Level 1-3", "Level 2-5", "Level 4-4"]) and not is_miniboss_arena_locked and not is_player_dead:\n\t\t\t\tif player.global_position.x >= 4050.0:\n\t\t\t\t\ttrigger_miniboss_arena_lockdown()\n\n\t\t\tif cur_title_chk == "Level 3-5":\n\t\t\t\tif not is_boss_active and player.global_position.x >= 3800.0:\n\t\t\t\t\tstart_boss_encounter()\n\t\t\telif cur_title_chk == "Level 5":\n\t\t\t\tif not is_boss_active and player.global_position.x >= 3800.0:\n\t\t\t\t\tstart_bakunawa_encounter()\n\t\t\telif player.global_position.x >= current_level_transition_x:\n\t\t\t\tstart_level_transition()"""

assert miniboss_target in text, "miniboss_target not found in main.gd"
text = text.replace(miniboss_target, miniboss_replacement)

# Replace boss spawn check in spawn_level_enemies
boss_spawn_target = """\tif is_boss_active or current_level_idx == 10 or current_level_idx == 14:"""
boss_spawn_replacement = """\tvar cur_title_spawn = LEVELS_DATA[current_level_idx].get("level_title", "")\n\tif is_boss_active or cur_title_spawn == "Level 3-5" or cur_title_spawn == "Level 5":"""

assert boss_spawn_target in text, "boss_spawn_target not found in main.gd"
text = text.replace(boss_spawn_target, boss_spawn_replacement)

# Replace miniboss guarantee check
guarantee_target = """\t# Guarantee Miniboss at climax for Level 1-3 (idx 2) and Level 2-3 (idx 5)\n\tif current_level_idx == 2:"""
guarantee_replacement = """\t# Guarantee Miniboss at climax for Level 1-3, Level 2-5, and Level 4-4\n\tvar cur_title_guar = LEVELS_DATA[current_level_idx].get("level_title", "")\n\tif cur_title_guar == "Level 1-3":"""

assert guarantee_target in text, "guarantee_target not found in main.gd"
text = text.replace(guarantee_target, guarantee_replacement)

# Replace elif current_level_idx == 5 with elif cur_title_guar == "Level 2-5"
vanguard_guar_target = """\telif current_level_idx == 5:"""
vanguard_guar_replacement = """\telif cur_title_guar == "Level 2-5":"""
assert vanguard_guar_target in text, "vanguard_guar_target not found in main.gd"
text = text.replace(vanguard_guar_target, vanguard_guar_replacement)

# Replace elif current_level_idx == 13 with elif cur_title_guar == "Level 4-4"
cave_guar_target = """\telif current_level_idx == 13:"""
cave_guar_replacement = """\telif cur_title_guar == "Level 4-4":"""
assert cave_guar_target in text, "cave_guar_target not found in main.gd"
text = text.replace(cave_guar_target, cave_guar_replacement)

# Replace storm prelude trigger:
# var is_lvl_2_3: bool = (current_level_idx == 5)
prelude_target = """\tvar is_lvl_2_3: bool = (current_level_idx == 5)"""
prelude_replacement = """\tvar is_lvl_2_3: bool = (current_data.get("level_title", "") == "Level 2-5")"""
assert prelude_target in text, "prelude_target not found in main.gd"
text = text.replace(prelude_target, prelude_replacement)

# Save updated main.gd
with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("scripts/main.gd updated cleanly with all features and 18-level expansion!")

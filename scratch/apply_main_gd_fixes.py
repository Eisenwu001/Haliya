import sys

def apply_fixes():
    with open("scripts/main.gd", "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Update setup_boss_hud()
    # Check current setup_boss_hud block
    start_str = "func setup_boss_hud() -> void:"
    end_str = "func setup_pause_menu() -> void:"
    assert start_str in content, "setup_boss_hud start not found"
    assert end_str in content, "setup_pause_menu not found"

    hud_start_idx = content.index(start_str)
    hud_end_idx = content.index(end_str)

    new_setup_boss_hud = """func setup_boss_hud() -> void:
\tboss_hud_root = Control.new()
\tboss_hud_root.name = "BossHUDRoot"
\tboss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
\tboss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tboss_hud_root.modulate.a = 0.0
\tboss_hud_root.visible = false
\thud_container.add_child(boss_hud_root)

\tvar custom_font = load("res://alagard.ttf")

\t# Bottom Center Anchor Container - Always centered on any screen size/stretch
\tvar bottom_box := Control.new()
\tbottom_box.name = "BossBottomBox"
\tbottom_box.anchor_left = 0.5
\tbottom_box.anchor_right = 0.5
\tbottom_box.anchor_top = 1.0
\tbottom_box.anchor_bottom = 1.0
\tbottom_box.offset_left = -210.0
\tbottom_box.offset_right = 210.0
\tbottom_box.offset_top = -56.0
\tbottom_box.offset_bottom = -12.0
\tbottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tboss_hud_root.add_child(bottom_box)

\t# 1. Main Title Label (Clean Roman Font, no Baybayin)
\tboss_title_label = Label.new()
\tboss_title_label.name = "BossTitle"
\tboss_title_label.text = "CORRUPTED SENTINEL: FOREST BRUTE"
\tboss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tboss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tboss_title_label.add_theme_font_override("font", custom_font)
\tboss_title_label.add_theme_font_size_override("font_size", 12)
\tboss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
\tboss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tboss_title_label.add_theme_constant_override("shadow_offset_x", 1)
\tboss_title_label.add_theme_constant_override("shadow_offset_y", 1)
\tboss_title_label.position = Vector2(0, 0)
\tboss_title_label.size = Vector2(420, 16)
\tbottom_box.add_child(boss_title_label)

\t# 2. Outer Dark Obsidian Frame
\tvar bar_frame = ColorRect.new()
\tbar_frame.name = "BossBarFrame"
\tbar_frame.position = Vector2(18, 18)
\tbar_frame.size = Vector2(384, 16)
\tbar_frame.color = Color(0.04, 0.05, 0.07, 0.96)
\tbottom_box.add_child(bar_frame)

\t# 3. Gilded Gold Filigree Border
\tvar border_rect = ReferenceRect.new()
\tborder_rect.position = Vector2(18, 18)
\tborder_rect.size = Vector2(384, 16)
\tborder_rect.border_color = Color(0.72, 0.60, 0.35, 1.0)
\tborder_rect.border_width = 1.0
\tborder_rect.editor_only = false
\tbottom_box.add_child(border_rect)

\t# Decorative Left & Right Diamond Jewels
\tfor side in [-1.0, 1.0]:
\t\tvar dia = Polygon2D.new()
\t\tdia.polygon = PackedVector2Array([Vector2(-3.5, 0), Vector2(0, -3.5), Vector2(3.5, 0), Vector2(0, 3.5)])
\t\tdia.color = Color(0.92, 0.78, 0.42, 1.0)
\t\tdia.position = Vector2(18 if side < 0 else 402, 26)
\t\tbottom_box.add_child(dia)

\t# 4. Background Channel
\tvar bar_bg = ColorRect.new()
\tbar_bg.position = Vector2(20, 20)
\tbar_bg.size = Vector2(380, 12)
\tbar_bg.color = Color(0.12, 0.04, 0.06, 0.88)
\tbottom_box.add_child(bar_bg)

\t# 5. Amber Ghost Lag Bar
\tboss_hp_ghost = ColorRect.new()
\tboss_hp_ghost.name = "BossHPGhost"
\tboss_hp_ghost.position = Vector2(20, 20)
\tboss_hp_ghost.size = Vector2(380, 12)
\tboss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.95)
\tbottom_box.add_child(boss_hp_ghost)

\t# 6. Primary HP Fill
\tboss_hp_fill = ColorRect.new()
\tboss_hp_fill.name = "BossHPFill"
\tboss_hp_fill.position = Vector2(20, 20)
\tboss_hp_fill.size = Vector2(380, 12)
\tboss_hp_fill.color = Color(0.20, 0.83, 0.60, 1.0)
\tbottom_box.add_child(boss_hp_fill)

\t# 7. 10% Phase Threshold Notch (20 + round(380 * 0.10) = 58)
\tboss_phase_notch = Control.new()
\tboss_phase_notch.name = "BossPhaseNotch"
\tboss_phase_notch.position = Vector2(58, 18)
\tboss_phase_notch.size = Vector2(2, 16)
\tbottom_box.add_child(boss_phase_notch)

\tvar notch_line = ColorRect.new()
\tnotch_line.position = Vector2(0, 1)
\tnotch_line.size = Vector2(1.5, 14)
\tnotch_line.color = Color(0.85, 0.75, 0.40, 0.95)
\tboss_phase_notch.add_child(notch_line)

\tvar notch_gem = Polygon2D.new()
\tnotch_gem.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2.5), Vector2(2, 0), Vector2(0, 2.5)])
\tnotch_gem.color = Color(1.0, 0.88, 0.45, 1.0)
\tnotch_gem.position = Vector2(1, 0)
\tboss_phase_notch.add_child(notch_gem)

\t# 8. Numeric HP Percentage Readout (Centered in bar)
\tboss_hp_num_label = Label.new()
\tboss_hp_num_label.name = "BossHPNumLabel"
\tboss_hp_num_label.text = "100%"
\tboss_hp_num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tboss_hp_num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tboss_hp_num_label.add_theme_font_override("font", custom_font)
\tboss_hp_num_label.add_theme_font_size_override("font_size", 9)
\tboss_hp_num_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
\tboss_hp_num_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
\tboss_hp_num_label.add_theme_constant_override("shadow_offset_x", 1)
\tboss_hp_num_label.add_theme_constant_override("shadow_offset_y", 1)
\tboss_hp_num_label.position = Vector2(20, 18)
\tboss_hp_num_label.size = Vector2(380, 16)
\tbottom_box.add_child(boss_hp_num_label)


"""
    content = content[:hud_start_idx] + new_setup_boss_hud + content[hud_end_idx:]

    # 2. Update _on_player_died() and respawn_player_at_checkpoint()
    old_death_section = """func _on_player_died() -> void:
\tdeath_count += 1
\tis_player_dead = true
\tvar cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
\tvar elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
\tif is_instance_valid(game_over_ui):
\t\tvar stats_data = {
\t\t\t"deepest_stage": cur_title,
\t\t\t"kills": UpgradeManager.total_kills_this_run,
\t\t\t"elapsed_sec": elapsed,
\t\t\t"bosses_defeated": bosses_slain_this_run,
\t\t\t"parries": parries_this_run,
\t\t\t"pearls": pearls_collected_this_run,
\t\t\t"stage_idx": current_level_idx,
\t\t\t"upgrades": UpgradeManager.active_upgrades
\t\t}
\t\tgame_over_ui.display_defeat(stats_data)
\telse:
\t\trespawn_player_at_checkpoint()
\t\tshow_respawn_message()"""

    new_death_section = """func _on_player_died() -> void:
\tdeath_count += 1
\tis_player_dead = true

\tif is_instance_valid(boss_hud_root):
\t\tboss_hud_root.visible = false
\t\tboss_hud_root.modulate.a = 0.0

\t# Stop player physics and dissolve character smoothly
\tif is_instance_valid(player):
\t\tplayer.velocity = Vector2.ZERO
\t\tplayer.set_physics_process(false)
\t\tvar tw_player = create_tween()
\t\ttw_player.tween_property(player, "modulate:a", 0.0, 0.40)
\t\ttw_player.tween_callback(func():
\t\t\tif is_instance_valid(player):
\t\t\t\tplayer.visible = false
\t\t)

\t# Stop active world enemies
\tfor enemy in active_enemies:
\t\tif is_instance_valid(enemy):
\t\t\tif enemy.has_method("set_physics_process"):
\t\t\t\tenemy.set_physics_process(false)
\t\t\tif enemy.has_node("AnimationPlayer"):
\t\t\t\tvar ap: AnimationPlayer = enemy.get_node("AnimationPlayer")
\t\t\t\tif ap:
\t\t\t\t\tap.pause()

\tvar cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
\tvar elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
\tif is_instance_valid(game_over_ui):
\t\tvar stats_data = {
\t\t\t"deepest_stage": cur_title,
\t\t\t"kills": UpgradeManager.total_kills_this_run,
\t\t\t"elapsed_sec": elapsed,
\t\t\t"bosses_defeated": bosses_slain_this_run,
\t\t\t"parries": parries_this_run,
\t\t\t"pearls": pearls_collected_this_run,
\t\t\t"stage_idx": current_level_idx,
\t\t\t"upgrades": UpgradeManager.active_upgrades
\t\t}
\t\tgame_over_ui.display_defeat(stats_data)
\telse:
\t\trespawn_player_at_checkpoint()
\t\tshow_respawn_message()"""

    assert old_death_section in content, "old_death_section not found"
    content = content.replace(old_death_section, new_death_section)

    # 3. Update respawn_player_at_checkpoint() to restore player visibility & physics
    old_respawn_player = """\tif player:
\t\tvar target_spawn: Vector2 = Vector2(BOSS_CHECKPOINT_X, 260.0) if has_activated_boss_checkpoint else SPAWN_POS
\t\tplayer.global_position = target_spawn
\t\tplayer.velocity = Vector2.ZERO
\t\tlast_player_x = player.global_position.x
\t\tif player.has_method("reset_combat_state"):
\t\t\tplayer.reset_combat_state()"""

    new_respawn_player = """\tif player:
\t\tvar target_spawn: Vector2 = Vector2(BOSS_CHECKPOINT_X, 260.0) if has_activated_boss_checkpoint else SPAWN_POS
\t\tplayer.global_position = target_spawn
\t\tplayer.velocity = Vector2.ZERO
\t\tplayer.visible = true
\t\tplayer.modulate = Color(1, 1, 1, 1)
\t\tplayer.set_physics_process(true)
\t\tis_player_dead = false
\t\tlast_player_x = player.global_position.x
\t\tif player.has_method("reset_combat_state"):
\t\t\tplayer.reset_combat_state()"""

    assert old_respawn_player in content, "old_respawn_player not found"
    content = content.replace(old_respawn_player, new_respawn_player)

    # 4. Update trigger_miniboss_arena_lockdown() HUD block
    old_miniboss_hud = """\tif is_instance_valid(boss_hud_root):
\t\tif is_instance_valid(boss_title_label):
\t\t\tboss_title_label.text = title
\t\t\tboss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
\t\tif is_instance_valid(boss_baybayin_label):
\t\t\tboss_baybayin_label.text = baybayin
\t\tif is_instance_valid(boss_hp_fill):
\t\t\tboss_hp_fill.color = bar_color
\t\t\tboss_hp_fill.size.x = 380.0
\t\tif is_instance_valid(boss_hp_ghost):
\t\t\tboss_hp_ghost.size.x = 380.0
\t\tif is_instance_valid(boss_hp_num_label):
\t\t\tvar m_hp = active_miniboss.get("MAX_HEALTH")
\t\t\tvar init_hp = m_hp if m_hp != null else 28
\t\t\tboss_hp_num_label.text = "%d / %d" % [init_hp, init_hp]
\t\tboss_hud_root.visible = true
\t\tvar tw = create_tween()
\t\ttw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)"""

    new_miniboss_hud = """\tif is_instance_valid(boss_hud_root):
\t\tif is_instance_valid(boss_title_label):
\t\t\tboss_title_label.text = title
\t\t\tboss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
\t\tif is_instance_valid(boss_hp_fill):
\t\t\tboss_hp_fill.color = bar_color
\t\t\tboss_hp_fill.size.x = 380.0
\t\tif is_instance_valid(boss_hp_ghost):
\t\t\tboss_hp_ghost.size.x = 380.0
\t\tif is_instance_valid(boss_hp_num_label):
\t\t\tboss_hp_num_label.text = "100%"
\t\tboss_hud_root.visible = true
\t\tvar tw = create_tween()
\t\ttw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)"""

    assert old_miniboss_hud in content, "old_miniboss_hud not found"
    content = content.replace(old_miniboss_hud, new_miniboss_hud)

    # 5. Update _on_boss_hp_changed() to percentage
    old_boss_hp_changed = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
\tif not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
\t\treturn
\tvar pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
\tvar target_w: float = 380.0 * pct

\tboss_hp_fill.size.x = target_w
\tif is_instance_valid(boss_hp_num_label):
\t\tboss_hp_num_label.text = "%d / %d" % [max(0, cur_hp), max_hp]

\tif is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
\t\tboss_hp_tween.kill()
\tboss_hp_tween = create_tween()
\tboss_hp_tween.tween_interval(0.25)
\tboss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

    new_boss_hp_changed = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
\tif not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
\t\treturn
\tvar pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
\tvar target_w: float = 380.0 * pct

\tboss_hp_fill.size.x = target_w
\tif is_instance_valid(boss_hp_num_label):
\t\tvar pct_int: int = int(round(pct * 100.0)) if cur_hp > 0 else 0
\t\tboss_hp_num_label.text = "%d%%" % pct_int

\tif is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
\t\tboss_hp_tween.kill()
\tboss_hp_tween = create_tween()
\tboss_hp_tween.tween_interval(0.25)
\tboss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

    assert old_boss_hp_changed in content, "old_boss_hp_changed not found"
    content = content.replace(old_boss_hp_changed, new_boss_hp_changed)

    # 6. Update start_bakunawa_encounter()
    old_baku_hud = """\tif is_instance_valid(boss_hud_root):
\t\tif is_instance_valid(boss_baybayin_label):
\t\t\tboss_baybayin_label.text = "ᜊᜃᜓᜈᜏ  •  BAKUNAWA"
\t\tif is_instance_valid(boss_title_label):
\t\t\tboss_title_label.text = "BAKUNAWA — THE MOON DEVOURER"
\t\t\tboss_title_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
\t\tif is_instance_valid(boss_hp_fill):
\t\t\tboss_hp_fill.color = Color(0.2, 0.65, 0.95, 1.0)
\t\t\tboss_hp_fill.size.x = 380.0
\t\tif is_instance_valid(boss_hp_ghost):
\t\t\tboss_hp_ghost.size.x = 380.0
\t\tif is_instance_valid(boss_hp_num_label):
\t\t\tboss_hp_num_label.text = "70 / 70"
\t\tboss_hud_root.visible = true
\t\tvar tw = create_tween()
\t\ttw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)"""

    new_baku_hud = """\tif is_instance_valid(boss_hud_root):
\t\tif is_instance_valid(boss_title_label):
\t\t\tboss_title_label.text = "BAKUNAWA — THE MOON DEVOURER"
\t\t\tboss_title_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
\t\tif is_instance_valid(boss_hp_fill):
\t\t\tboss_hp_fill.color = Color(0.2, 0.65, 0.95, 1.0)
\t\t\tboss_hp_fill.size.x = 380.0
\t\tif is_instance_valid(boss_hp_ghost):
\t\t\tboss_hp_ghost.size.x = 380.0
\t\tif is_instance_valid(boss_hp_num_label):
\t\t\tboss_hp_num_label.text = "100%"
\t\tboss_hud_root.visible = true
\t\tvar tw = create_tween()
\t\ttw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)"""

    assert old_baku_hud in content, "old_baku_hud not found"
    content = content.replace(old_baku_hud, new_baku_hud)

    with open("scripts/main.gd", "w", encoding="utf-8") as f:
        f.write(content)

    print("SUCCESS: All main.gd fixes cleanly applied!")

if __name__ == "__main__":
    apply_fixes()

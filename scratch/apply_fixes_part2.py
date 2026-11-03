import sys

# ─────────────────────────────────────────────────────────────
# 1. Update scripts/game_over_ui.gd
# ─────────────────────────────────────────────────────────────
with open("scripts/game_over_ui.gd", "r", encoding="utf-8") as f:
    go_code = f.read()

# Replace setup_ui to use compact 470x245 panel and clean lore without baybayin
old_go_panel = """	panel = PanelContainer.new()
	panel.name = "DefeatPanel"
	panel.custom_minimum_size = Vector2(520, 310)"""

new_go_panel = """	panel = PanelContainer.new()
	panel.name = "DefeatPanel"
	panel.custom_minimum_size = Vector2(470, 245)"""

assert old_go_panel in go_code, "old_go_panel not found"
go_code = go_code.replace(old_go_panel, new_go_panel, 1)

# Remove baybayin from lore_lbl
old_lore = """	var lore_lbl := Label.new()
	lore_lbl.text = "ᜑᜎᜒᜌ ᜐ ᜃᜇᜒᜎᜒᜋᜈ᜔  •  Haliya has fallen. The seven moons remain in Bakunawa's thrall."
	lore_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_lbl.add_theme_font_override("font", FONT_RES)
	lore_lbl.add_theme_font_size_override("font_size", 10)
	lore_lbl.add_theme_color_override("font_color", Color(0.80, 0.75, 0.80, 0.85))
	vbox.add_child(lore_lbl)"""

new_lore = """	var lore_lbl := Label.new()
	lore_lbl.text = "Haliya has fallen. The seven moons remain in Bakunawa's thrall."
	lore_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_lbl.add_theme_font_override("font", FONT_RES)
	lore_lbl.add_theme_font_size_override("font_size", 10)
	lore_lbl.add_theme_color_override("font_color", Color(0.80, 0.75, 0.80, 0.85))
	vbox.add_child(lore_lbl)"""

assert old_lore in go_code, "old_lore not found"
go_code = go_code.replace(old_lore, new_lore, 1)

# Fix score integer formatting and the pop-out animation
old_display = """	score_label.text = "FINAL SCORE: %s PTS" % String.num(final_score)
	rank_label.text = "RANK [%s] — %s" % [rank_info["letter"], rank_info["title"]]
	rank_label.add_theme_color_override("font_color", rank_info["color"])

	stat_stage_lbl.text = "Deepest Realm:   %s" % stage_name
	stat_bosses_lbl.text = "Bosses Vanquished: %d" % bosses_defeated
	stat_time_lbl.text = "Time Survived:   %02d:%02d" % [minutes, seconds]
	stat_pearls_lbl.text = "Pearls Secured:    %d" % pearls_count
	stat_kills_lbl.text = "Nightmares Slain: %d" % total_kills
	stat_parries_lbl.text = "Perfect Parries:   %d" % parries_count

	var tier_str = "Ascension Tier: %d" % UpgradeManager.current_tier
	if acquired_upgrades.is_empty():
		upgrades_label.text = "%s  •  Blessings: None" % tier_str
	else:
		var list_str = ""
		for u_id in acquired_upgrades.keys():
			var info = UpgradeManager.CATALOG.get(u_id, {})
			var u_name = info.get("name", u_id)
			var stk = acquired_upgrades[u_id]
			list_str += "%s x%d, " % [u_name, stk]
		if list_str.ends_with(", "):
			list_str = list_str.left(list_str.length() - 2)
		upgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]

	play_somber_drone()

	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

new_display = """	# Format score as clean integer without decimal places
	score_label.text = "FINAL SCORE: %s PTS" % String.num(int(round(float(final_score))))
	rank_label.text = "RANK [%s] — %s" % [rank_info["letter"], rank_info["title"]]
	rank_label.add_theme_color_override("font_color", rank_info["color"])

	stat_stage_lbl.text = "Deepest Realm:   %s" % stage_name
	stat_bosses_lbl.text = "Bosses Vanquished: %d" % bosses_defeated
	stat_time_lbl.text = "Time Survived:   %02d:%02d" % [minutes, seconds]
	stat_pearls_lbl.text = "Pearls Secured:    %d" % pearls_count
	stat_kills_lbl.text = "Nightmares Slain: %d" % total_kills
	stat_parries_lbl.text = "Perfect Parries:   %d" % parries_count

	var tier_str = "Ascension Tier: %d" % UpgradeManager.current_tier
	if acquired_upgrades.is_empty():
		upgrades_label.text = "%s  •  Blessings: None" % tier_str
	else:
		var list_str = ""
		for u_id in acquired_upgrades.keys():
			var info = UpgradeManager.CATALOG.get(u_id, {})
			var u_name = info.get("name", u_id)
			var stk = acquired_upgrades[u_id]
			list_str += "%s x%d, " % [u_name, stk]
		if list_str.ends_with(", "):
			list_str = list_str.left(list_str.length() - 2)
		upgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]

	play_somber_drone()

	# Two-stage cinematic death animation:
	# 1. Screen slowly fades to complete darkness over 0.75s
	# 2. DefeatPanel smoothly pops out into the center with ease-out scaling
	overlay.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.pivot_offset = Vector2(235.0, 122.5)
	panel.scale = Vector2(0.78, 0.78)

	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# After 0.35s into darkness fade, start panel pop-out
	var tw_panel = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_panel.tween_interval(0.35)
	tw_panel.parallel().tween_property(panel, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_panel.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.50).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)"""

assert old_display in go_code, "old_display not found"
go_code = go_code.replace(old_display, new_display, 1)

with open("scripts/game_over_ui.gd", "w", encoding="utf-8") as f:
    f.write(go_code)
print("Updated game_over_ui.gd successfully!")


# ─────────────────────────────────────────────────────────────
# 2. Update scripts/main.gd
# ─────────────────────────────────────────────────────────────
with open("scripts/main.gd", "r", encoding="utf-8") as f:
    main_code = f.read()

# Replace setup_boss_hud() with centered bar, percentage readout in the dead center, 10% notch, no baybayin
old_main_hud = """func setup_boss_hud() -> void:
	boss_hud_root = Control.new()
	boss_hud_root.name = "BossHUDRoot"
	boss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.modulate.a = 0.0
	boss_hud_root.visible = false
	hud_container.add_child(boss_hud_root)

	var custom_font = load("res://alagard.ttf")

	# Bottom Center Anchor Container - Always centered on any screen size/stretch
	var bottom_box := Control.new()
	bottom_box.name = "BossBottomBox"
	bottom_box.anchor_left = 0.5
	bottom_box.anchor_right = 0.5
	bottom_box.anchor_top = 1.0
	bottom_box.anchor_bottom = 1.0
	bottom_box.offset_left = -210.0
	bottom_box.offset_right = 210.0
	bottom_box.offset_top = -56.0
	bottom_box.offset_bottom = -12.0
	bottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.add_child(bottom_box)

	# 1. Baybayin Subtitle Label
	boss_baybayin_label = Label.new()
	boss_baybayin_label.name = "BossBaybayinLabel"
	boss_baybayin_label.text = "ᜑᜒᜄᜈ᜔ᜆᜒᜅ᜔ ᜄᜓᜊᜆ᜔"
	boss_baybayin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_baybayin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_baybayin_label.add_theme_font_override("font", custom_font)
	boss_baybayin_label.add_theme_font_size_override("font_size", 10)
	boss_baybayin_label.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42, 0.85))
	boss_baybayin_label.position = Vector2(0, -14)
	boss_baybayin_label.size = Vector2(420, 14)
	bottom_box.add_child(boss_baybayin_label)

	# 2. Main Title Label
	boss_title_label = Label.new()
	boss_title_label.name = "BossTitle"
	boss_title_label.text = "CORRUPTED SENTINEL: FOREST BRUTE"
	boss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_title_label.add_theme_font_override("font", custom_font)
	boss_title_label.add_theme_font_size_override("font_size", 12)
	boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	boss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	boss_title_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_title_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_title_label.position = Vector2(0, 0)
	boss_title_label.size = Vector2(420, 16)
	bottom_box.add_child(boss_title_label)

	# 3. Outer Dark Obsidian Frame
	var bar_frame = ColorRect.new()
	bar_frame.name = "BossBarFrame"
	bar_frame.position = Vector2(18, 18)
	bar_frame.size = Vector2(384, 14)
	bar_frame.color = Color(0.04, 0.05, 0.07, 0.96)
	bottom_box.add_child(bar_frame)

	# 4. Gilded Gold Filigree Border
	var border_rect = ReferenceRect.new()
	border_rect.position = Vector2(18, 18)
	border_rect.size = Vector2(384, 14)
	border_rect.border_color = Color(0.72, 0.60, 0.35, 1.0)
	border_rect.border_width = 1.0
	border_rect.editor_only = false
	bottom_box.add_child(border_rect)

	# Decorative Left & Right Diamond Jewels
	for side in [-1.0, 1.0]:
		var dia = Polygon2D.new()
		dia.polygon = PackedVector2Array([Vector2(-3.5, 0), Vector2(0, -3.5), Vector2(3.5, 0), Vector2(0, 3.5)])
		dia.color = Color(0.92, 0.78, 0.42, 1.0)
		dia.position = Vector2(18 if side < 0 else 402, 25)
		bottom_box.add_child(dia)

	# 5. Background Channel
	var bar_bg = ColorRect.new()
	bar_bg.position = Vector2(20, 20)
	bar_bg.size = Vector2(380, 10)
	bar_bg.color = Color(0.12, 0.04, 0.06, 0.88)
	bottom_box.add_child(bar_bg)

	# 6. Amber Ghost Lag Bar
	boss_hp_ghost = ColorRect.new()
	boss_hp_ghost.name = "BossHPGhost"
	boss_hp_ghost.position = Vector2(20, 20)
	boss_hp_ghost.size = Vector2(380, 10)
	boss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.95)
	bottom_box.add_child(boss_hp_ghost)

	# 7. Primary HP Fill
	boss_hp_fill = ColorRect.new()
	boss_hp_fill.name = "BossHPFill"
	boss_hp_fill.position = Vector2(20, 20)
	boss_hp_fill.size = Vector2(380, 10)
	boss_hp_fill.color = Color(0.20, 0.83, 0.60, 1.0)
	bottom_box.add_child(boss_hp_fill)

	# 8. 50% Phase Threshold Notch
	boss_phase_notch = Control.new()
	boss_phase_notch.name = "BossPhaseNotch"
	boss_phase_notch.position = Vector2(210, 17)
	boss_phase_notch.size = Vector2(2, 16)
	bottom_box.add_child(boss_phase_notch)

	var notch_line = ColorRect.new()
	notch_line.position = Vector2(0, 2)
	notch_line.size = Vector2(1.5, 12)
	notch_line.color = Color(0.85, 0.75, 0.40, 0.95)
	boss_phase_notch.add_child(notch_line)

	var notch_gem = Polygon2D.new()
	notch_gem.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2.5), Vector2(2, 0), Vector2(0, 2.5)])
	notch_gem.color = Color(1.0, 0.88, 0.45, 1.0)
	notch_gem.position = Vector2(1, 1)
	boss_phase_notch.add_child(notch_gem)

	# 9. Numeric HP Readout
	boss_hp_num_label = Label.new()
	boss_hp_num_label.name = "BossHPNumLabel"
	boss_hp_num_label.text = "28 / 28"
	boss_hp_num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_hp_num_label.add_theme_font_override("font", custom_font)
	boss_hp_num_label.add_theme_font_size_override("font_size", 9)
	boss_hp_num_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	boss_hp_num_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	boss_hp_num_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_hp_num_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_hp_num_label.position = Vector2(20, 20)
	boss_hp_num_label.size = Vector2(380, 10)
	bottom_box.add_child(boss_hp_num_label)"""

new_main_hud = """func setup_boss_hud() -> void:
	boss_hud_root = Control.new()
	boss_hud_root.name = "BossHUDRoot"
	boss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.modulate.a = 0.0
	boss_hud_root.visible = false
	hud_container.add_child(boss_hud_root)

	var custom_font = load("res://alagard.ttf")

	# Bottom Center Anchor Container - Perfectly centered at bottom
	var bottom_box := Control.new()
	bottom_box.name = "BossBottomBox"
	bottom_box.anchor_left = 0.5
	bottom_box.anchor_right = 0.5
	bottom_box.anchor_top = 1.0
	bottom_box.anchor_bottom = 1.0
	bottom_box.offset_left = -200.0
	bottom_box.offset_right = 200.0
	bottom_box.offset_top = -48.0
	bottom_box.offset_bottom = -12.0
	bottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.add_child(bottom_box)

	# 1. Main Title Label
	boss_title_label = Label.new()
	boss_title_label.name = "BossTitle"
	boss_title_label.text = "CORRUPTED SENTINEL: FOREST BRUTE"
	boss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_title_label.add_theme_font_override("font", custom_font)
	boss_title_label.add_theme_font_size_override("font_size", 12)
	boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	boss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	boss_title_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_title_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_title_label.position = Vector2(0, 0)
	boss_title_label.size = Vector2(400, 16)
	bottom_box.add_child(boss_title_label)

	# 2. Outer Dark Obsidian Frame (384 x 16, centered at x = 8)
	var bar_frame = ColorRect.new()
	bar_frame.name = "BossBarFrame"
	bar_frame.position = Vector2(8, 18)
	bar_frame.size = Vector2(384, 16)
	bar_frame.color = Color(0.04, 0.05, 0.07, 0.96)
	bottom_box.add_child(bar_frame)

	# 3. Gilded Gold Filigree Border
	var border_rect = ReferenceRect.new()
	border_rect.position = Vector2(8, 18)
	border_rect.size = Vector2(384, 16)
	border_rect.border_color = Color(0.72, 0.60, 0.35, 1.0)
	border_rect.border_width = 1.0
	border_rect.editor_only = false
	bottom_box.add_child(border_rect)

	# Decorative Left & Right Diamond Jewels
	for side in [-1.0, 1.0]:
		var dia = Polygon2D.new()
		dia.polygon = PackedVector2Array([Vector2(-3.5, 0), Vector2(0, -3.5), Vector2(3.5, 0), Vector2(0, 3.5)])
		dia.color = Color(0.92, 0.78, 0.42, 1.0)
		dia.position = Vector2(8 if side < 0 else 392, 26)
		bottom_box.add_child(dia)

	# 4. Background Channel (380 x 12, at x = 10, y = 20)
	var bar_bg = ColorRect.new()
	bar_bg.position = Vector2(10, 20)
	bar_bg.size = Vector2(380, 12)
	bar_bg.color = Color(0.12, 0.04, 0.06, 0.88)
	bottom_box.add_child(bar_bg)

	# 5. Amber Ghost Lag Bar
	boss_hp_ghost = ColorRect.new()
	boss_hp_ghost.name = "BossHPGhost"
	boss_hp_ghost.position = Vector2(10, 20)
	boss_hp_ghost.size = Vector2(380, 12)
	boss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.95)
	bottom_box.add_child(boss_hp_ghost)

	# 6. Primary HP Fill
	boss_hp_fill = ColorRect.new()
	boss_hp_fill.name = "BossHPFill"
	boss_hp_fill.position = Vector2(10, 20)
	boss_hp_fill.size = Vector2(380, 12)
	boss_hp_fill.color = Color(0.20, 0.83, 0.60, 1.0)
	bottom_box.add_child(boss_hp_fill)

	# 7. 10% Phase Threshold Notch (at 10% of 380px: 10 + 38 = 48px)
	boss_phase_notch = Control.new()
	boss_phase_notch.name = "BossPhaseNotch"
	boss_phase_notch.position = Vector2(48, 17)
	boss_phase_notch.size = Vector2(2, 18)
	bottom_box.add_child(boss_phase_notch)

	var notch_line = ColorRect.new()
	notch_line.position = Vector2(0, 2)
	notch_line.size = Vector2(1.5, 14)
	notch_line.color = Color(0.85, 0.75, 0.40, 0.95)
	boss_phase_notch.add_child(notch_line)

	var notch_gem = Polygon2D.new()
	notch_gem.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2.5), Vector2(2, 0), Vector2(0, 2.5)])
	notch_gem.color = Color(1.0, 0.88, 0.45, 1.0)
	notch_gem.position = Vector2(1, 1)
	boss_phase_notch.add_child(notch_gem)

	# 8. Percentage HP Readout in the EXACT CENTER of the Health Bar
	boss_hp_num_label = Label.new()
	boss_hp_num_label.name = "BossHPNumLabel"
	boss_hp_num_label.text = "100%"
	boss_hp_num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_hp_num_label.add_theme_font_override("font", custom_font)
	boss_hp_num_label.add_theme_font_size_override("font_size", 10)
	boss_hp_num_label.add_theme_color_override("font_color", Color(1, 1, 1, 1.0))
	boss_hp_num_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	boss_hp_num_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_hp_num_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_hp_num_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.06, 0.95))
	boss_hp_num_label.add_theme_constant_override("outline_size", 2)
	boss_hp_num_label.position = Vector2(10, 18)
	boss_hp_num_label.size = Vector2(380, 16)
	bottom_box.add_child(boss_hp_num_label)"""

assert old_main_hud in main_code, "old_main_hud not found"
main_code = main_code.replace(old_main_hud, new_main_hud, 1)

# Update _on_boss_hp_changed to calculate percentage
old_main_hp_chg = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 380.0 * pct

	boss_hp_fill.size.x = target_w
	if is_instance_valid(boss_hp_num_label):
		boss_hp_num_label.text = "%d / %d" % [max(0, cur_hp), max_hp]"""

new_main_hp_chg = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 380.0 * pct

	boss_hp_fill.size.x = target_w
	if is_instance_valid(boss_hp_num_label):
		var pct_int = int(round(pct * 100.0))
		if cur_hp <= 0:
			pct_int = 0
		boss_hp_num_label.text = "%d%%" % pct_int"""

assert old_main_hp_chg in main_code, "old_main_hp_chg not found"
main_code = main_code.replace(old_main_hp_chg, new_main_hp_chg, 1)

# Update trigger_miniboss_arena_lockdown: no baybayin, set "100%"
old_lockdown_hud = """		if is_instance_valid(boss_baybayin_label):
			boss_baybayin_label.text = baybayin
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = bar_color
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			var m_hp = active_miniboss.get("MAX_HEALTH")
			var init_hp = m_hp if m_hp != null else 28
			boss_hp_num_label.text = "%d / %d" % [init_hp, init_hp]"""

new_lockdown_hud = """		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = bar_color
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			boss_hp_num_label.text = "100%" """

assert old_lockdown_hud in main_code, "old_lockdown_hud not found"
main_code = main_code.replace(old_lockdown_hud, new_lockdown_hud, 1)

# Update start_bakunawa_encounter: no baybayin, set "100%"
old_baku_labels = """		if is_instance_valid(boss_baybayin_label):
			boss_baybayin_label.text = "ᜊᜃᜓᜈᜏ  •  BAKUNAWA"
		if is_instance_valid(boss_title_label):
			boss_title_label.text = "BAKUNAWA — THE MOON DEVOURER"
			boss_title_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(0.2, 0.65, 0.95, 1.0)
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			boss_hp_num_label.text = "70 / 70" """

new_baku_labels = """		if is_instance_valid(boss_title_label):
			boss_title_label.text = "BAKUNAWA — THE MOON DEVOURER"
			boss_title_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(0.2, 0.65, 0.95, 1.0)
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			boss_hp_num_label.text = "100%" """

assert old_baku_labels in main_code, "old_baku_labels not found"
main_code = main_code.replace(old_baku_labels, new_baku_labels, 1)

# Update _on_player_died(): freeze everything, dissolve/disappear character, hide boss HUD
old_died = """func _on_player_died() -> void:
	death_count += 1
	is_player_dead = true
	var cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
	var elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
	if is_instance_valid(game_over_ui):
		var stats_data = {
			"deepest_stage": cur_title,
			"kills": UpgradeManager.total_kills_this_run,
			"elapsed_sec": elapsed,
			"bosses_defeated": bosses_slain_this_run,
			"parries": parries_this_run,
			"pearls": pearls_collected_this_run,
			"stage_idx": current_level_idx,
			"upgrades": UpgradeManager.active_upgrades
		}
		game_over_ui.display_defeat(stats_data)
	else:
		respawn_player_at_checkpoint()
		show_respawn_message()"""

new_died = """func _on_player_died() -> void:
	death_count += 1
	is_player_dead = true

	# 1. Freeze everything & make character dissolve and disappear
	if is_instance_valid(player):
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		# Shadow dissipation effect
		VFX.spawn_guard_impact(self, player.global_position + Vector2(0, -32.0))
		var tw_p = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw_p.tween_property(player, "modulate", Color(0.3, 0.05, 0.08, 0.0), 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw_p.tween_callback(func():
			if is_instance_valid(player):
				player.visible = false
		)

	# Freeze active enemies
	for e in active_enemies:
		if is_instance_valid(e):
			e.set_physics_process(false)

	# Hide boss HUD so it never peeks under the defeat menu
	if is_instance_valid(boss_hud_root):
		boss_hud_root.visible = false

	var cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
	var elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
	if is_instance_valid(game_over_ui):
		var stats_data = {
			"deepest_stage": cur_title,
			"kills": UpgradeManager.total_kills_this_run,
			"elapsed_sec": elapsed,
			"bosses_defeated": bosses_slain_this_run,
			"parries": parries_this_run,
			"pearls": pearls_collected_this_run,
			"stage_idx": current_level_idx,
			"upgrades": UpgradeManager.active_upgrades
		}
		game_over_ui.display_defeat(stats_data)
	else:
		respawn_player_at_checkpoint()
		show_respawn_message()"""

assert old_died in main_code, "old_died not found"
main_code = main_code.replace(old_died, new_died, 1)

# Ensure respawn_player_at_checkpoint restores player visible & process
old_respawn = """	if player:
		var target_spawn: Vector2 = Vector2(BOSS_CHECKPOINT_X, 260.0) if has_activated_boss_checkpoint else SPAWN_POS
		player.global_position = target_spawn
		player.velocity = Vector2.ZERO
		last_player_x = player.global_position.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()"""

new_respawn = """	if player:
		player.visible = true
		player.modulate = Color(1, 1, 1, 1)
		player.set_physics_process(true)
		var target_spawn: Vector2 = Vector2(BOSS_CHECKPOINT_X, 260.0) if has_activated_boss_checkpoint else SPAWN_POS
		player.global_position = target_spawn
		player.velocity = Vector2.ZERO
		last_player_x = player.global_position.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()"""

assert old_respawn in main_code, "old_respawn not found"
main_code = main_code.replace(old_respawn, new_respawn, 1)

with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(main_code)
print("Updated main.gd successfully!")

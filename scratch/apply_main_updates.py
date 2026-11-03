import sys

MAIN_GD = "scripts/main.gd"

with open(MAIN_GD, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Variables
old_vars = """var boss_hud_root: Control
var boss_hp_fill: ColorRect
var boss_hp_ghost: ColorRect
var boss_title_label: Label
var boss_hp_tween: Tween"""

new_vars = """var boss_hud_root: Control
var boss_hp_fill: ColorRect
var boss_hp_ghost: ColorRect
var boss_title_label: Label
var boss_baybayin_label: Label
var boss_hp_num_label: Label
var boss_phase_notch: Control
var boss_hp_tween: Tween
var active_encounter_type: String = ""

# ── Run Statistics for Score Calculation ──────────────────────────────────────
var bosses_slain_this_run: int = 0
var parries_this_run: int = 0
var pearls_collected_this_run: int = 0"""

assert old_vars in text, "old_vars not found!"
text = text.replace(old_vars, new_vars, 1)

# 2. setup_boss_hud()
old_setup_hud = """func setup_boss_hud() -> void:
	boss_hud_root = Control.new()
	boss_hud_root.name = "BossHUDRoot"
	boss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.modulate.a = 0.0
	boss_hud_root.visible = false
	hud_container.add_child(boss_hud_root)

	var custom_font = load("res://alagard.ttf")

	# Title Label
	boss_title_label = Label.new()
	boss_title_label.name = "BossTitle"
	boss_title_label.text = "SINAG-ULAP — THE CORRUPTED MATRIARCH"
	boss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_title_label.add_theme_font_override("font", custom_font)
	boss_title_label.add_theme_font_size_override("font_size", 12)
	boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.72, 1.0))
	boss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	boss_title_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_title_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_title_label.position = Vector2(120, 314)
	boss_title_label.size = Vector2(400, 18)
	boss_hud_root.add_child(boss_title_label)

	# Outer Dark Frame
	var bar_frame = ColorRect.new()
	bar_frame.name = "BossBarFrame"
	bar_frame.position = Vector2(144, 334)
	bar_frame.size = Vector2(352, 12)
	bar_frame.color = Color(0.05, 0.05, 0.07, 0.95)
	boss_hud_root.add_child(bar_frame)

	# Inner Gold Border
	var border_rect = ReferenceRect.new()
	border_rect.position = Vector2(144, 334)
	border_rect.size = Vector2(352, 12)
	border_rect.border_color = Color(0.72, 0.60, 0.35, 0.9)
	border_rect.border_width = 1.0
	border_rect.editor_only = false
	boss_hud_root.add_child(border_rect)

	# Background fill
	var bar_bg = ColorRect.new()
	bar_bg.position = Vector2(145, 335)
	bar_bg.size = Vector2(350, 10)
	bar_bg.color = Color(0.18, 0.05, 0.07, 0.85)
	boss_hud_root.add_child(bar_bg)

	# Ghost lag bar
	boss_hp_ghost = ColorRect.new()
	boss_hp_ghost.name = "BossHPGhost"
	boss_hp_ghost.position = Vector2(145, 335)
	boss_hp_ghost.size = Vector2(350, 10)
	boss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.9)
	boss_hud_root.add_child(boss_hp_ghost)

	# Primary crimson fill
	boss_hp_fill = ColorRect.new()
	boss_hp_fill.name = "BossHPFill"
	boss_hp_fill.position = Vector2(145, 335)
	boss_hp_fill.size = Vector2(350, 10)
	boss_hp_fill.color = Color(0.88, 0.14, 0.18, 1.0)
	boss_hud_root.add_child(boss_hp_fill)"""

new_setup_hud = """func setup_boss_hud() -> void:
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

assert old_setup_hud in text, "old_setup_hud not found!"
text = text.replace(old_setup_hud, new_setup_hud, 1)

# 3. trigger_miniboss_arena_lockdown
old_lockdown = """func trigger_miniboss_arena_lockdown() -> void:
	var active_miniboss: CharacterBody2D = null
	for e in active_enemies:
		if is_instance_valid(e) and e.is_in_group("miniboss") and not e.get("is_dead"):
			active_miniboss = e as CharacterBody2D
			break
	if not active_miniboss:
		return

	is_miniboss_arena_locked = true

	if is_instance_valid(miniboss_rear_barrier):
		miniboss_rear_barrier.queue_free()

	miniboss_rear_barrier = StaticBody2D.new()
	miniboss_rear_barrier.name = "MinibossRearBarrier"
	miniboss_rear_barrier.collision_layer = 1
	miniboss_rear_barrier.collision_mask = 2 # Blocks player

	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(32.0, 600.0)
	col.shape = rect_shape
	miniboss_rear_barrier.add_child(col)
	miniboss_rear_barrier.global_position = Vector2(3980.0, 150.0)
	add_child(miniboss_rear_barrier)

	add_screen_shake(0.50)
	apply_hit_stop(0.04)

	var title := "CORRUPTED SENTINEL: FOREST BRUTE"
	var color := Color(0.95, 0.55, 0.20, 1.0)
	if LEVELS_DATA[current_level_idx].get("theme", "") == "Rice Field":
		title = "MAYON FLAME VANGUARD"
		color = Color(1.0, 0.45, 0.15, 1.0)
	elif LEVELS_DATA[current_level_idx].get("theme", "") == "Cave":
		title = "ABYSSAL LUNAR WARDEN: SANCTUM VANGUARD"
		color = Color(0.52, 0.85, 1.0, 1.0)
	show_exit_banner(title, color)"""

new_lockdown = """func trigger_miniboss_arena_lockdown() -> void:
	var active_miniboss: CharacterBody2D = null
	for e in active_enemies:
		if is_instance_valid(e) and e.is_in_group("miniboss") and not e.get("is_dead"):
			active_miniboss = e as CharacterBody2D
			break
	if not active_miniboss:
		return

	is_miniboss_arena_locked = true

	if is_instance_valid(miniboss_rear_barrier):
		miniboss_rear_barrier.queue_free()

	miniboss_rear_barrier = StaticBody2D.new()
	miniboss_rear_barrier.name = "MinibossRearBarrier"
	miniboss_rear_barrier.collision_layer = 1
	miniboss_rear_barrier.collision_mask = 2 # Blocks player

	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(32.0, 600.0)
	col.shape = rect_shape
	miniboss_rear_barrier.add_child(col)
	miniboss_rear_barrier.global_position = Vector2(3980.0, 150.0)
	add_child(miniboss_rear_barrier)

	add_screen_shake(0.50)
	apply_hit_stop(0.04)

	var cur_theme = LEVELS_DATA[current_level_idx].get("theme", "")
	var title := "CORRUPTED SENTINEL: FOREST BRUTE"
	var baybayin := "ᜑᜒᜄᜈ᜔ᜆᜒᜅ᜔ ᜄᜓᜊᜆ᜔"
	var bar_color := Color(0.20, 0.83, 0.60, 1.0)
	active_encounter_type = "forest_brute"
	if cur_theme == "Rice Field":
		title = "MAYON FLAME VANGUARD"
		baybayin = "ᜊᜅ᜔ᜄᜓᜏᜇ᜔ᜇᜒᜌ ᜅ᜔ ᜋᜌᜓᜈ᜔"
		bar_color = Color(1.0, 0.45, 0.15, 1.0)
		active_encounter_type = "mayon_vanguard"
	elif cur_theme == "Cave":
		title = "ABYSSAL LUNAR WARDEN: SANCTUM VANGUARD"
		baybayin = "ᜆᜈᜓᜇ᜔ ᜅ᜔ ᜎᜎᜓᜋ᜔"
		bar_color = Color(0.52, 0.85, 1.0, 1.0)
		active_encounter_type = "abyssal_warden"

	# Connect miniboss to boss health bar
	if active_miniboss.has_signal("boss_hp_changed"):
		if not active_miniboss.boss_hp_changed.is_connected(_on_boss_hp_changed):
			active_miniboss.boss_hp_changed.connect(_on_boss_hp_changed)
	if active_miniboss.has_signal("boss_phase_changed"):
		if not active_miniboss.boss_phase_changed.is_connected(_on_boss_phase_changed):
			active_miniboss.boss_phase_changed.connect(_on_boss_phase_changed)

	if is_instance_valid(boss_hud_root):
		if is_instance_valid(boss_title_label):
			boss_title_label.text = title
			boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
		if is_instance_valid(boss_baybayin_label):
			boss_baybayin_label.text = baybayin
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = bar_color
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			var m_hp = active_miniboss.get("MAX_HEALTH")
			var init_hp = m_hp if m_hp != null else 28
			boss_hp_num_label.text = "%d / %d" % [init_hp, init_hp]
		boss_hud_root.visible = true
		var tw = create_tween()
		tw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)

	show_exit_banner(title, bar_color)"""

assert old_lockdown in text, "old_lockdown not found!"
text = text.replace(old_lockdown, new_lockdown, 1)

# 4. handle_miniboss_defeated
old_defeated = """func handle_miniboss_defeated(_enemy: Node) -> void:
	is_miniboss_arena_locked = false"""

new_defeated = """func handle_miniboss_defeated(_enemy: Node) -> void:
	bosses_slain_this_run += 1
	is_miniboss_arena_locked = false
	if is_instance_valid(boss_hud_root):
		var tw_hud = create_tween()
		tw_hud.tween_property(boss_hud_root, "modulate:a", 0.0, 0.60)
		tw_hud.tween_callback(func():
			if is_instance_valid(boss_hud_root):
				boss_hud_root.visible = false
		)"""

assert old_defeated in text, "old_defeated not found!"
text = text.replace(old_defeated, new_defeated, 1)

# 5. _on_boss_hp_changed
old_hp_changed = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 350.0 * pct

	boss_hp_fill.size.x = target_w

	if is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
		boss_hp_tween.kill()
	boss_hp_tween = create_tween()
	boss_hp_tween.tween_interval(0.25)
	boss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

new_hp_changed = """func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 380.0 * pct

	boss_hp_fill.size.x = target_w
	if is_instance_valid(boss_hp_num_label):
		boss_hp_num_label.text = "%d / %d" % [max(0, cur_hp), max_hp]

	if is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
		boss_hp_tween.kill()
	boss_hp_tween = create_tween()
	boss_hp_tween.tween_interval(0.25)
	boss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

assert old_hp_changed in text, "old_hp_changed not found!"
text = text.replace(old_hp_changed, new_hp_changed, 1)

# 6. _on_boss_phase_changed
old_phase_changed = """func _on_boss_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		add_screen_shake(0.85)
		trigger_parry_slowmo(0.35)
		if is_instance_valid(boss_title_label):
			boss_title_label.text = "SINAG-ULAP — THE ENRAGED MATRIARCH"
			boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(1.2, 0.2, 0.2, 1.0)"""

new_phase_changed = """func _on_boss_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		add_screen_shake(0.85)
		trigger_parry_slowmo(0.35)
		if is_instance_valid(boss_title_label):
			if active_encounter_type == "forest_brute":
				boss_title_label.text = "HIGANTENG GUBAT — ENRAGED TIMBER COLOSSUS"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			elif active_encounter_type == "mayon_vanguard":
				boss_title_label.text = "MAYON FLAME VANGUARD — INFERNAL FURY"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.15, 1.0))
			elif active_encounter_type == "abyssal_warden":
				boss_title_label.text = "ABYSSAL LUNAR WARDEN — ECLIPSE CHAMPION"
				boss_title_label.add_theme_color_override("font_color", Color(0.65, 0.90, 1.0, 1.0))
			elif active_encounter_type == "bakunawa":
				boss_title_label.text = "BAKUNAWA — ECLIPSE OF SEVEN MOONS"
				boss_title_label.add_theme_color_override("font_color", Color(0.95, 0.3, 0.6, 1.0))
			else:
				boss_title_label.text = "SINAG-ULAP — THE ENRAGED MATRIARCH"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		if is_instance_valid(boss_hp_fill):
			var tw_col = create_tween()
			tw_col.tween_property(boss_hp_fill, "color", Color(0.94, 0.22, 0.22, 1.0), 0.35)"""

assert old_phase_changed in text, "old_phase_changed not found!"
text = text.replace(old_phase_changed, new_phase_changed, 1)

# 7. start_bakunawa_encounter - match with find and slice
pos_baku = text.find("func start_bakunawa_encounter() -> void:")
assert pos_baku != -1, "start_bakunawa_encounter not found!"
pos_hud = text.find("if is_instance_valid(boss_hud_root):", pos_baku)
pos_lock = text.find("# Lock the arena with physical barrier walls", pos_hud)

old_baku_block = text[pos_hud:pos_lock]
new_baku_block = """active_encounter_type = "bakunawa"
	if is_instance_valid(boss_hud_root):
		if is_instance_valid(boss_baybayin_label):
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
			boss_hp_num_label.text = "70 / 70"
		boss_hud_root.visible = true
		var tw = create_tween()
		tw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)

	"""

text = text[:pos_hud] + new_baku_block + text[pos_lock:]

# 8. _on_bakunawa_died
old_bakunawa_died = """func _on_bakunawa_died(_boss: CharacterBody2D) -> void:"""
new_bakunawa_died = """func _on_bakunawa_died(_boss: CharacterBody2D) -> void:
	bosses_slain_this_run += 1
	if is_instance_valid(boss_hud_root):
		var tw_b = create_tween()
		tw_b.tween_property(boss_hud_root, "modulate:a", 0.0, 0.60)
		tw_b.tween_callback(func():
			if is_instance_valid(boss_hud_root):
				boss_hud_root.visible = false
		)"""

assert old_bakunawa_died in text, "old_bakunawa_died not found!"
text = text.replace(old_bakunawa_died, new_bakunawa_died, 1)

# 9. Parries in _on_player_damage_taken
old_parry_hit = """	if is_blocked and amount == 0:
		add_screen_shake(0.40)"""

new_parry_hit = """	if is_blocked and amount == 0:
		parries_this_run += 1
		add_screen_shake(0.40)"""

assert old_parry_hit in text, "old_parry_hit not found!"
text = text.replace(old_parry_hit, new_parry_hit, 1)

# 10. Pearls collected tracking
text = text.replace("MetaProgression.add_moon_pearls(drop_pearls)\n\t\tspawn_pearl_particles",
                    "MetaProgression.add_moon_pearls(drop_pearls)\n\t\tpearls_collected_this_run += drop_pearls\n\t\tspawn_pearl_particles")
text = text.replace("MetaProgression.add_moon_pearls(drop_pearls)\n\t\tif is_boss",
                    "MetaProgression.add_moon_pearls(drop_pearls)\n\t\tpearls_collected_this_run += drop_pearls\n\t\tif is_boss")

# 11. _on_player_died call to display_defeat
old_died_call = """	if is_instance_valid(game_over_ui):
		game_over_ui.display_defeat(cur_title, UpgradeManager.total_kills_this_run, elapsed, UpgradeManager.active_upgrades)"""

new_died_call = """	if is_instance_valid(game_over_ui):
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
		game_over_ui.display_defeat(stats_data)"""

assert old_died_call in text, "old_died_call not found!"
text = text.replace(old_died_call, new_died_call, 1)

# 12. Reset stats in restart_game()
old_restart = """	UpgradeManager.init_run()
	aswang_kills = 0"""

new_restart = """	UpgradeManager.init_run()
	bosses_slain_this_run = 0
	parries_this_run = 0
	pearls_collected_this_run = 0
	aswang_kills = 0"""

if old_restart in text:
    text = text.replace(old_restart, new_restart, 1)

with open(MAIN_GD, "w", encoding="utf-8") as f:
    f.write(text)

print("Successfully applied main.gd updates!")

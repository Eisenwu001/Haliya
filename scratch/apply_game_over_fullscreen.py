import sys

content = """class_name GameOverUI
extends CanvasLayer

signal restart_run_requested
signal return_to_title_requested

const FONT_RES = preload("res://alagard.ttf")
const UpgradeManager = preload("res://scripts/upgrade_manager.gd")

var overlay: ColorRect
var center_container: CenterContainer
var panel: PanelContainer
var title_box: Control
var title_lbl: Label
var lore_lbl: Label
var stats_group: VBoxContainer
var btn_row: HBoxContainer
var score_label: Label
var rank_label: Label
var stat_stage_lbl: Label
var stat_time_lbl: Label
var stat_kills_lbl: Label
var stat_bosses_lbl: Label
var stat_pearls_lbl: Label
var stat_parries_lbl: Label
var upgrades_label: Label
var is_active: bool = false
var audio_player: AudioStreamPlayer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 130
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	setup_ui()
	visible = false


func setup_ui() -> void:
	# 1. Full-screen slow dark veil (deep midnight crimson abyss, no small red box)
	overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.005, 0.015, 0.98)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Full-screen CenterContainer guarantees 100% centering across ALL display resolutions & stretch modes
	center_container = CenterContainer.new()
	center_container.name = "CenterContainer"
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center_container)

	# PanelContainer kept as main content root for compatibility, but with NO red borders (seamless full-screen)
	panel = PanelContainer.new()
	panel.name = "DefeatPanel"
	panel.custom_minimum_size = Vector2(500, 260)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.01, 0.02, 0.50) # Subtle atmospheric midground tint
	sb.border_width_left = 0
	sb.border_width_right = 0
	sb.border_width_top = 0
	sb.border_width_bottom = 0
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	center_container.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# 1. Rising "YOU DIED" Title Wrapper (enables smooth Y-rise animation without fighting VBoxContainer)
	title_box = Control.new()
	title_box.name = "TitleBox"
	title_box.custom_minimum_size = Vector2(500, 40)
	title_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_box)

	title_lbl = Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = "YOU DIED"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_lbl.size = Vector2(500, 40)
	title_lbl.position = Vector2(0, 0)
	title_lbl.add_theme_font_override("font", FONT_RES)
	title_lbl.add_theme_font_size_override("font_size", 30)
	title_lbl.add_theme_color_override("font_color", Color(0.92, 0.18, 0.22, 1.0))
	title_lbl.add_theme_color_override("font_shadow_color", Color(0.35, 0.02, 0.04, 1.0))
	title_lbl.add_theme_constant_override("shadow_offset_x", 2)
	title_lbl.add_theme_constant_override("shadow_offset_y", 2)
	title_box.add_child(title_lbl)

	# 2. Lore Subtitle
	lore_lbl = Label.new()
	lore_lbl.name = "LoreLabel"
	lore_lbl.text = "Haliya has fallen. The seven moons remain in Bakunawa's thrall."
	lore_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_lbl.add_theme_font_override("font", FONT_RES)
	lore_lbl.add_theme_font_size_override("font_size", 10)
	lore_lbl.add_theme_color_override("font_color", Color(0.78, 0.72, 0.78, 0.85))
	vbox.add_child(lore_lbl)

	# 3. Stats & Details Group (Score, Breakdown, Blessings)
	stats_group = VBoxContainer.new()
	stats_group.name = "StatsGroup"
	stats_group.add_theme_constant_override("separation", 8)
	vbox.add_child(stats_group)

	# 3a. Elegant Gilded Score & Rank Banner
	var banner_panel := PanelContainer.new()
	banner_panel.name = "ScoreBanner"
	var banner_sb := StyleBoxFlat.new()
	banner_sb.bg_color = Color(0.04, 0.015, 0.025, 0.95)
	banner_sb.border_width_left = 1
	banner_sb.border_width_right = 1
	banner_sb.border_width_top = 1
	banner_sb.border_width_bottom = 1
	banner_sb.border_color = Color(0.78, 0.65, 0.36, 0.85)
	banner_sb.corner_radius_bottom_left = 4
	banner_sb.corner_radius_bottom_right = 4
	banner_sb.corner_radius_top_left = 4
	banner_sb.corner_radius_top_right = 4
	banner_sb.content_margin_left = 12
	banner_sb.content_margin_right = 12
	banner_sb.content_margin_top = 6
	banner_sb.content_margin_bottom = 6
	banner_panel.add_theme_stylebox_override("panel", banner_sb)
	stats_group.add_child(banner_panel)

	var banner_hbox := HBoxContainer.new()
	banner_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	banner_hbox.add_theme_constant_override("separation", 10)
	banner_panel.add_child(banner_hbox)

	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "FINAL SCORE: 0 PTS"
	score_label.add_theme_font_override("font", FONT_RES)
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	score_label.add_theme_constant_override("shadow_offset_x", 1)
	score_label.add_theme_constant_override("shadow_offset_y", 1)
	banner_hbox.add_child(score_label)

	var div_lbl := Label.new()
	div_lbl.text = "•"
	div_lbl.add_theme_font_override("font", FONT_RES)
	div_lbl.add_theme_font_size_override("font_size", 12)
	div_lbl.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4, 0.8))
	banner_hbox.add_child(div_lbl)

	rank_label = Label.new()
	rank_label.name = "RankLabel"
	rank_label.text = "RANK [B] — SHADOW STALKER"
	rank_label.add_theme_font_override("font", FONT_RES)
	rank_label.add_theme_font_size_override("font_size", 13)
	rank_label.add_theme_color_override("font_color", Color(0.40, 0.90, 0.55, 1.0))
	rank_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	rank_label.add_theme_constant_override("shadow_offset_x", 1)
	rank_label.add_theme_constant_override("shadow_offset_y", 1)
	banner_hbox.add_child(rank_label)

	# 3b. Statistical Breakdown Grid
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 32)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_group.add_child(grid)

	stat_stage_lbl = create_stat_label("Deepest Realm:")
	grid.add_child(stat_stage_lbl)
	stat_bosses_lbl = create_stat_label("Bosses Vanquished:")
	grid.add_child(stat_bosses_lbl)

	stat_time_lbl = create_stat_label("Time Survived:")
	grid.add_child(stat_time_lbl)
	stat_pearls_lbl = create_stat_label("Moon Pearls Secured:")
	grid.add_child(stat_pearls_lbl)

	stat_kills_lbl = create_stat_label("Nightmares Slain:")
	grid.add_child(stat_kills_lbl)
	stat_parries_lbl = create_stat_label("Perfect Parries:")
	grid.add_child(stat_parries_lbl)

	# 3c. Blessings & Ascension Summary
	upgrades_label = Label.new()
	upgrades_label.name = "UpgradesLabel"
	upgrades_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrades_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrades_label.add_theme_font_override("font", FONT_RES)
	upgrades_label.add_theme_font_size_override("font_size", 10)
	upgrades_label.add_theme_color_override("font_color", Color(0.70, 0.85, 0.95, 0.90))
	stats_group.add_child(upgrades_label)

	# 4. Action Button Row
	btn_row = HBoxContainer.new()
	btn_row.name = "ButtonRow"
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	var btn_restart := Button.new()
	btn_restart.text = "  RISE AGAIN (LEVEL 1-1) [R]  "
	btn_restart.custom_minimum_size = Vector2(190, 30)
	btn_restart.add_theme_font_override("font", FONT_RES)
	btn_restart.add_theme_font_size_override("font_size", 12)
	btn_restart.pressed.connect(func(): on_restart_pressed())
	btn_row.add_child(btn_restart)

	var btn_menu := Button.new()
	btn_menu.text = "  RETURN TO TITLE  "
	btn_menu.custom_minimum_size = Vector2(160, 30)
	btn_menu.add_theme_font_override("font", FONT_RES)
	btn_menu.add_theme_font_size_override("font_size", 12)
	btn_menu.pressed.connect(func(): on_menu_pressed())
	btn_row.add_child(btn_menu)


func create_stat_label(prefix: String) -> Label:
	var lbl := Label.new()
	lbl.text = prefix + " --"
	lbl.add_theme_font_override("font", FONT_RES)
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.92, 0.85, 0.72, 1.0))
	return lbl


func calculate_score(kills: int, bosses: int, pearls: int, stage_idx: int, parries: int, elapsed_sec: float) -> int:
	var time_bonus = max(0, int(3000.0 - elapsed_sec * 5.0))
	var score = (kills * 250) + (bosses * 2500) + (pearls * 50) + (stage_idx * 1000) + (parries * 300) + time_bonus
	return max(0, score)


func get_rank_info(score: int) -> Dictionary:
	if score >= 20000:
		return {"letter": "S", "title": "CELESTIAL CHAMPION", "color": Color(1.0, 0.85, 0.25, 1.0)}
	elif score >= 14000:
		return {"letter": "A", "title": "LUNAR GUARDIAN", "color": Color(0.45, 0.88, 1.0, 1.0)}
	elif score >= 8000:
		return {"letter": "B", "title": "SHADOW STALKER", "color": Color(0.40, 0.90, 0.55, 1.0)}
	elif score >= 4000:
		return {"letter": "C", "title": "FALLEN SENTINEL", "color": Color(0.85, 0.60, 0.35, 1.0)}
	else:
		return {"letter": "D", "title": "LOST SOUL", "color": Color(0.70, 0.70, 0.75, 1.0)}


func display_defeat(stage_or_data: Variant, kills: int = 0, elapsed_sec: float = 0.0, upgrades: Dictionary = {}, extra_stats: Dictionary = {}) -> void:
	is_active = true
	visible = true

	var stage_name: String = "Level 1-1"
	var total_kills: int = kills
	var time_survived: float = elapsed_sec
	var acquired_upgrades = upgrades
	var bosses_defeated: int = extra_stats.get("bosses_defeated", 0)
	var pearls_count: int = extra_stats.get("pearls", 0)
	var parries_count: int = extra_stats.get("parries", 0)
	var stage_idx: int = extra_stats.get("stage_idx", 0)

	if stage_or_data is Dictionary:
		var d = stage_or_data as Dictionary
		stage_name = d.get("deepest_stage", "Level 1-1")
		total_kills = d.get("kills", 0)
		time_survived = d.get("elapsed_sec", 0.0)
		acquired_upgrades = d.get("upgrades", {})
		bosses_defeated = d.get("bosses_defeated", 0)
		pearls_count = d.get("pearls", 0)
		parries_count = d.get("parries", 0)
		stage_idx = d.get("stage_idx", 0)
	elif stage_or_data is String:
		stage_name = stage_or_data

	var minutes: int = int(time_survived) / 60
	var seconds: int = int(time_survived) % 60

	# Calculate Score & Rank
	var final_score = calculate_score(total_kills, bosses_defeated, pearls_count, stage_idx, parries_count, time_survived)
	var rank_info = get_rank_info(final_score)

	# Format score as clean integer without decimal places
	score_label.text = "FINAL SCORE: %d PTS" % int(round(float(final_score)))
	rank_label.text = "RANK [%s] — %s" % [rank_info["letter"], rank_info["title"]]
	rank_label.add_theme_color_override("font_color", rank_info["color"])

	stat_stage_lbl.text = "Deepest Realm:   %s" % stage_name
	stat_bosses_lbl.text = "Bosses Vanquished: %d" % bosses_defeated
	stat_time_lbl.text = "Time Survived:   %02d:%02d" % [minutes, seconds]
	stat_pearls_lbl.text = "Pearls Secured:    %d" % pearls_count
	stat_kills_lbl.text = "Nightmares Slain: %d" % total_kills
	stat_parries_lbl.text = "Perfect Parries:   %d" % parries_count

	var tier_str = "Ascension Tier: %d" % UpgradeManager.current_tier
	if acquired_upgrades == null or acquired_upgrades.is_empty():
		upgrades_label.text = "%s  •  Blessings: None" % tier_str
	elif acquired_upgrades is Dictionary:
		var list_str = ""
		for u_id in acquired_upgrades.keys():
			var info = UpgradeManager.CATALOG.get(u_id, {})
			var u_name = info.get("name", u_id)
			var stk = acquired_upgrades[u_id]
			list_str += "%s x%d, " % [u_name, stk]
		if list_str.ends_with(", "):
			list_str = list_str.left(list_str.length() - 2)
		upgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]
	elif acquired_upgrades is Array:
		var list_str = ", ".join(acquired_upgrades)
		upgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]

	play_somber_drone()

	# ── Cinematic Dark Souls / Elden Ring Sequential Death Animation ────────────────
	# Reset states
	overlay.modulate.a = 0.0
	panel.modulate.a = 1.0 # Panel is transparent; its contents fade in sequentially

	title_lbl.modulate.a = 0.0
	title_lbl.position = Vector2(0, 26.0) # Start lower down to rise up

	lore_lbl.modulate.a = 0.0
	stats_group.modulate.a = 0.0
	btn_row.modulate.a = 0.0
	btn_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 1. Slow, somber fade to darkness across 2.0s
	var tw_veil = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_veil.tween_property(overlay, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. At 0.45s, 'YOU DIED' slowly rises up and burns into view
	var tw_title = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_title.tween_interval(0.45)
	tw_title.parallel().tween_property(title_lbl, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw_title.parallel().tween_property(title_lbl, "position:y", 0.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 3. At 1.15s, Lore Subtitle smoothly fades in
	var tw_lore = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_lore.tween_interval(1.15)
	tw_lore.tween_property(lore_lbl, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 4. At 1.50s, Run Statistics & Score Banner slowly appear
	var tw_stats = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_stats.tween_interval(1.50)
	tw_stats.tween_property(stats_group, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 5. At 1.95s, Action Buttons appear and become clickable
	var tw_btns = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw_btns.tween_interval(1.95)
	tw_btns.tween_property(btn_row, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_btns.tween_callback(func():
		if is_instance_valid(btn_row):
			btn_row.mouse_filter = Control.MOUSE_FILTER_STOP
	)


func on_restart_pressed() -> void:
	if not is_active:
		return
	is_active = false
	visible = false
	restart_run_requested.emit()


func on_menu_pressed() -> void:
	if not is_active:
		return
	is_active = false
	visible = false
	return_to_title_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		on_menu_pressed()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_viewport().set_input_as_handled()
			on_restart_pressed()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			on_restart_pressed()


func play_somber_drone() -> void:
	if not is_instance_valid(audio_player):
		return
	var sample_rate: int = 22050
	var duration: float = 3.5
	var total_samples: int = int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	var f1: float = 55.0  # A1 sub drone
	var f2: float = 82.41 # E2 dark fifth
	var f3: float = 110.0 # A2 octave

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0
		if t < 0.8:
			env = t / 0.8
		elif t > 2.2:
			env = (duration - t) / 1.3

		var s: float = (
			sin(TAU * f1 * t) * 0.45 +
			sin(TAU * f2 * t) * 0.30 +
			sin(TAU * f3 * t) * 0.15
		) * env * 0.75

		var val: int = clampi(int(s * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data

	audio_player.stream = stream
	audio_player.play()
"""

with open('scripts/game_over_ui.gd', 'w', encoding='utf-8') as f:
    f.write(content)

print("SUCCESS: scripts/game_over_ui.gd updated to cinematic fullscreen!")

class_name BestiaryCodexUI
extends CanvasLayer

signal closed

const FONT_ALAGARD = preload("res://alagard.ttf")
const MetaProgression = preload("res://scripts/meta_progression.gd")

var overlay: ColorRect
var panel: PanelContainer
var pearls_label: Label
var bestiary_container: VBoxContainer
var is_active: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 126
	setup_ui()
	visible = false


func setup_ui() -> void:
	overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.03, 0.06, 0.94)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	panel = PanelContainer.new()
	panel.name = "CodexPanel"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_right = 260.0
	panel.offset_top = -155.0
	panel.offset_bottom = 155.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.11, 0.98)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.72, 0.38, 0.90) # Radiant antique gold border
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	overlay.add_child(panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)
	panel.add_child(main_vbox)

	# 1. Header
	var header_lbl := Label.new()
	header_lbl.name = "CodexHeader"
	header_lbl.text = "LORE CODEX"
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_lbl.add_theme_font_override("font", FONT_ALAGARD)
	header_lbl.add_theme_font_size_override("font_size", 18)
	header_lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.52, 1.0))
	header_lbl.add_theme_color_override("font_shadow_color", Color(0.35, 0.04, 0.06, 0.95))
	header_lbl.add_theme_constant_override("shadow_offset_x", 1)
	header_lbl.add_theme_constant_override("shadow_offset_y", 1)
	main_vbox.add_child(header_lbl)

	# 2. Subheader
	var sub_lbl := Label.new()
	sub_lbl.name = "CodexSubHeader"
	sub_lbl.text = "— ❖ — MYTHOLOGICAL BESTIARY OF IBALONG — ❖ —"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_override("font", FONT_ALAGARD)
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.78, 0.74, 0.64, 0.85))
	main_vbox.add_child(sub_lbl)

	# 3. Discovered Moon Pearls Tally
	pearls_label = Label.new()
	pearls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pearls_label.add_theme_font_override("font", FONT_ALAGARD)
	pearls_label.add_theme_font_size_override("font_size", 11)
	pearls_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.60, 0.90))
	main_vbox.add_child(pearls_label)

	# 4. Bestiary Scroll Container
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 185)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)

	bestiary_container = VBoxContainer.new()
	bestiary_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bestiary_container.add_theme_constant_override("separation", 8)
	scroll.add_child(bestiary_container)

	# 5. Close Button
	var btn_box := HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(btn_box)

	var btn_close := Button.new()
	btn_close.text = "  CLOSE [Esc]  "
	btn_close.custom_minimum_size = Vector2(140, 24)
	btn_close.add_theme_font_override("font", FONT_ALAGARD)
	btn_close.add_theme_font_size_override("font_size", 11)
	btn_close.pressed.connect(close_menu)
	btn_box.add_child(btn_close)


func open_menu() -> void:
	is_active = true
	visible = true
	MetaProgression.load_meta()
	refresh_display()

	overlay.modulate.a = 0.0
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.20)


func close_menu() -> void:
	if not is_active:
		return
	is_active = false
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 0.0, 0.15)
	tw.tween_callback(func():
		visible = false
		closed.emit()
	)


func refresh_display() -> void:
	pearls_label.text = "LUNAR PEARLS DISCOVERED: %d" % MetaProgression.moon_pearls

	# Refresh Bestiary entries
	for c in bestiary_container.get_children():
		c.queue_free()

	for key in MetaProgression.BESTIARY_DATA.keys():
		var data = MetaProgression.BESTIARY_DATA[key]
		var is_unlocked = MetaProgression.unlocked_bestiary.get(key, false)

		var card := PanelContainer.new()
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color(0.06, 0.09, 0.16, 0.90) if is_unlocked else Color(0.03, 0.04, 0.07, 0.70)
		csb.border_width_left = 1
		csb.border_width_top = 1
		csb.border_width_right = 1
		csb.border_width_bottom = 1
		csb.border_color = Color(0.60, 0.75, 0.90, 0.75) if is_unlocked else Color(0.20, 0.25, 0.35, 0.40)
		csb.corner_radius_bottom_left = 4
		csb.corner_radius_bottom_right = 4
		csb.corner_radius_top_left = 4
		csb.corner_radius_top_right = 4
		csb.content_margin_left = 12
		csb.content_margin_right = 12
		csb.content_margin_top = 8
		csb.content_margin_bottom = 8
		card.add_theme_stylebox_override("panel", csb)
		bestiary_container.add_child(card)

		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 3)
		card.add_child(cvbox)

		if is_unlocked:
			var header_row := HBoxContainer.new()
			cvbox.add_child(header_row)

			var name_lbl := Label.new()
			name_lbl.text = data.get("name", key)
			name_lbl.add_theme_font_override("font", FONT_ALAGARD)
			name_lbl.add_theme_font_size_override("font_size", 13)
			name_lbl.add_theme_color_override("font_color", Color(0.98, 0.90, 0.65, 1.0))
			header_row.add_child(name_lbl)

			var baybayin_text: String = data.get("baybayin", "")
			if baybayin_text != "":
				var bay_lbl := Label.new()
				bay_lbl.text = "  [%s]" % baybayin_text
				bay_lbl.add_theme_font_override("font", FONT_ALAGARD)
				bay_lbl.add_theme_font_size_override("font_size", 11)
				bay_lbl.add_theme_color_override("font_color", Color(0.70, 0.85, 1.0, 0.80))
				header_row.add_child(bay_lbl)

			var lore_lbl := Label.new()
			lore_lbl.text = data.get("lore", "")
			lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lore_lbl.add_theme_font_override("font", FONT_ALAGARD)
			lore_lbl.add_theme_font_size_override("font_size", 10)
			lore_lbl.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92, 0.85))
			cvbox.add_child(lore_lbl)
		else:
			var locked_lbl := Label.new()
			locked_lbl.text = "??? (Undiscovered Mythological Night Terror)\nDefeat this creature during your journey to decipher its ancient lore."
			locked_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			locked_lbl.add_theme_font_override("font", FONT_ALAGARD)
			locked_lbl.add_theme_font_size_override("font_size", 10)
			locked_lbl.add_theme_color_override("font_color", Color(0.40, 0.45, 0.55, 0.70))
			cvbox.add_child(locked_lbl)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_menu()
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()

class_name UpgradeSelectUI
extends CanvasLayer

signal upgrade_selected(upgrade_id: String)

const FONT_RES = preload("res://alagard.ttf")
const UpgradeManager = preload("res://scripts/upgrade_manager.gd")

var overlay: ColorRect
var modal_panel: PanelContainer
var cards_container: HBoxContainer
var cards: Array[PanelContainer] = []
var card_data: Array[Dictionary] = []
var selected_index: int = 0
var is_active: bool = false
var audio_player: AudioStreamPlayer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	setup_ui()
	visible = false


func setup_ui() -> void:
	overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0.02, 0.03, 0.07, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 10)
	overlay.add_child(main_vbox)
	
	# Header Labels
	var title_lbl := Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = "ANCESTRAL LUNAR SHRINE"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", FONT_RES)
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.90, 0.55, 1.0))
	title_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	title_lbl.add_theme_constant_override("shadow_offset_x", 2)
	title_lbl.add_theme_constant_override("shadow_offset_y", 2)
	main_vbox.add_child(title_lbl)
	
	var subtitle_lbl := Label.new()
	subtitle_lbl.name = "SubtitleLabel"
	subtitle_lbl.text = "The spirits of the seven moons grant Haliya ancient vigor. Choose your blessing:"
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.add_theme_font_override("font", FONT_RES)
	subtitle_lbl.add_theme_font_size_override("font_size", 12)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.80, 0.85, 0.95, 0.90))
	main_vbox.add_child(subtitle_lbl)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	main_vbox.add_child(spacer)
	
	# Cards Row
	cards_container = HBoxContainer.new()
	cards_container.name = "CardsContainer"
	cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_container.add_theme_constant_override("separation", 16)
	main_vbox.add_child(cards_container)
	
	# Footer hint
	var hint_lbl := Label.new()
	hint_lbl.name = "HintLabel"
	hint_lbl.text = "Press [A / D] or [Arrows] to browse • [Space / Enter] or [1, 2, 3] or Click to Select"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_override("font", FONT_RES)
	hint_lbl.add_theme_font_size_override("font_size", 11)
	hint_lbl.add_theme_color_override("font_color", Color(0.60, 0.65, 0.75, 0.80))
	main_vbox.add_child(hint_lbl)


func display_draft(drafted_upgrades: Array[Dictionary], tier: int = 1) -> void:
	card_data = drafted_upgrades
	cards.clear()
	selected_index = 0
	is_active = true
	visible = true
	overlay.modulate.a = 0.0
	
	# Clear previous cards
	for child in cards_container.get_children():
		child.queue_free()
	
	for i in range(drafted_upgrades.size()):
		var data = drafted_upgrades[i]
		var card = build_card(data, i)
		cards_container.add_child(card)
		cards.append(card)
	
	update_card_focus()
	
	# Fade-in animation
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func build_card(data: Dictionary, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Card_%d" % index
	card.custom_minimum_size = Vector2(172, 215)
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.14, 0.95)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.30, 0.40, 0.55, 0.85)
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", sb)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)
	
	# Category Badge
	var cat_lbl := Label.new()
	cat_lbl.text = "[ %s ]" % data.get("category", "BLESSING")
	cat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_lbl.add_theme_font_override("font", FONT_RES)
	cat_lbl.add_theme_font_size_override("font_size", 10)
	var cat_col: Color = data.get("color", Color(0.8, 0.9, 1.0))
	cat_lbl.add_theme_color_override("font_color", cat_col)
	vbox.add_child(cat_lbl)
	
	# Icon - Authentic Philippine Mythology Pixel-Art Relic
	var icon_container := CenterContainer.new()
	icon_container.custom_minimum_size = Vector2(44, 44)
	vbox.add_child(icon_container)
	
	var icon_rect := TextureRect.new()
	icon_rect.name = "UpgradeIcon"
	icon_rect.custom_minimum_size = Vector2(40, 40)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var icon_path: String = data.get("icon_path", "")
	var icon_tex: Texture2D = null
	if icon_path != "":
		if ResourceLoader.exists(icon_path):
			var res = load(icon_path)
			if res is Texture2D:
				icon_tex = res
		if not icon_tex:
			var global_p = ProjectSettings.globalize_path(icon_path)
			if FileAccess.file_exists(global_p):
				var img = Image.new()
				if img.load(global_p) == OK:
					icon_tex = ImageTexture.create_from_image(img)
	if icon_tex:
		icon_rect.texture = icon_tex
	icon_container.add_child(icon_rect)
	
	# Title
	var name_lbl := Label.new()
	name_lbl.text = data.get("name", "Unknown")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_override("font", FONT_RES)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88, 1.0))
	vbox.add_child(name_lbl)
	
	# Rank
	var cur_stk: int = data.get("current_stacks", 0)
	var max_stk: int = data.get("max_stacks", 1)
	var rank_lbl := Label.new()
	rank_lbl.text = "Rank: %d / %d" % [cur_stk + 1, max_stk]
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_lbl.add_theme_font_override("font", FONT_RES)
	rank_lbl.add_theme_font_size_override("font_size", 10)
	rank_lbl.add_theme_color_override("font_color", Color(0.65, 0.70, 0.80, 0.85))
	vbox.add_child(rank_lbl)
	
	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = data.get("description", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.add_theme_font_override("font", FONT_RES)
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92, 0.92))
	vbox.add_child(desc_lbl)
	
	# Select Button
	var btn := Button.new()
	btn.name = "SelectBtn"
	btn.text = "SELECT [%d]" % (index + 1)
	btn.custom_minimum_size = Vector2(0, 24)
	btn.add_theme_font_override("font", FONT_RES)
	btn.add_theme_font_size_override("font_size", 11)
	btn.pressed.connect(func(): select_upgrade(index))
	vbox.add_child(btn)
	
	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_upgrade(index)
	)
	
	card.mouse_entered.connect(func():
		selected_index = index
		update_card_focus()
	)
	
	return card


func update_card_focus() -> void:
	for i in range(cards.size()):
		var card = cards[i]
		var sb: StyleBoxFlat = card.get_theme_stylebox("panel")
		if i == selected_index:
			sb.border_color = Color(1.0, 0.88, 0.40, 1.0)
			sb.border_width_left = 3
			sb.border_width_right = 3
			sb.border_width_top = 3
			sb.border_width_bottom = 3
			sb.bg_color = Color(0.08, 0.13, 0.22, 0.98)
			card.scale = Vector2(1.04, 1.04)
			card.pivot_offset = card.custom_minimum_size * 0.5
		else:
			sb.border_color = Color(0.25, 0.35, 0.48, 0.75)
			sb.border_width_left = 2
			sb.border_width_right = 2
			sb.border_width_top = 2
			sb.border_width_bottom = 2
			sb.bg_color = Color(0.05, 0.08, 0.14, 0.95)
			card.scale = Vector2(1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	
	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and (event.keycode == KEY_A or event.keycode == KEY_LEFT)):
		selected_index = (selected_index - 1 + cards.size()) % cards.size()
		update_card_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and (event.keycode == KEY_D or event.keycode == KEY_RIGHT)):
		selected_index = (selected_index + 1) % cards.size()
		update_card_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		select_upgrade(selected_index)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and cards.size() >= 1:
			select_upgrade(0)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2 and cards.size() >= 2:
			select_upgrade(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_3 and cards.size() >= 3:
			select_upgrade(2)
			get_viewport().set_input_as_handled()


func select_upgrade(index: int) -> void:
	if not is_active or index < 0 or index >= card_data.size():
		return
	
	is_active = false
	var chosen = card_data[index]
	var chosen_id = chosen["id"]
	
	# Chime sound effect
	play_chime()
	
	# Emit signal immediately for instant progression response
	upgrade_selected.emit(chosen_id)
	
	# Animation: Selected card flashes bright gold, other cards fade
	for i in range(cards.size()):
		var card = cards[i]
		if is_instance_valid(card):
			var tw = card.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			if i == index:
				tw.tween_property(card, "scale", Vector2(1.10, 1.10), 0.20)
				tw.parallel().tween_property(card, "modulate", Color(1.8, 1.6, 1.0, 1.0), 0.20)
			else:
				tw.tween_property(card, "modulate:a", 0.0, 0.20)
	
	var fade_tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tw.tween_interval(0.30)
	fade_tw.tween_property(overlay, "modulate:a", 0.0, 0.20)
	fade_tw.tween_callback(func():
		visible = false
	)


func play_chime() -> void:
	if not is_instance_valid(audio_player) or not is_inside_tree():
		return
	# Resonant synthesized chime generator
	var sample_rate: int = 22050
	var duration: float = 0.55
	var total_samples: int = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	var byte_array = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	var f1: float = 587.33 # D5
	var f2: float = 880.00 # A5
	var f3: float = 1174.66 # D6
	
	for s in range(total_samples):
		var t: float = float(s) / float(sample_rate)
		var env: float = exp(-t * 6.5)
		var val: float = (sin(TAU * f1 * t) * 0.5 + sin(TAU * f2 * t) * 0.35 + sin(TAU * f3 * t) * 0.25) * env
		var val_int: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		byte_array.encode_s16(s * 2, val_int)
	
	stream.data = byte_array
	audio_player.stream = stream
	audio_player.play()

class_name SettingsMenu
extends CanvasLayer

signal closed

const FONT_ALAGARD = preload("res://alagard.ttf")
const GameSettings = preload("res://scripts/game_settings.gd")

var overlay: ColorRect
var panel: PanelContainer
var is_active: bool = false
var rebind_action: String = ""
var rebind_button: Button = null

# Tabs
var general_container: VBoxContainer
var controls_container: VBoxContainer
var tab_btn_general: Button
var tab_btn_controls: Button
var control_buttons: Dictionary = {}

# Sliders & Value Labels
var master_slider: HSlider
var master_val_lbl: Label
var music_slider: HSlider
var music_val_lbl: Label
var sfx_slider: HSlider
var sfx_val_lbl: Label
var shake_slider: HSlider
var shake_val_lbl: Label
var fullscreen_btn: CheckButton
var damage_nums_btn: CheckButton
var lang_btn: OptionButton


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 125
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
	panel.name = "SettingsPanel"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_right = 260.0
	panel.offset_top = -175.0
	panel.offset_bottom = 175.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.14, 0.98)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.75, 0.40, 0.90)
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sb)
	overlay.add_child(panel)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)
	panel.add_child(main_vbox)
	
	# Header
	var header_lbl := Label.new()
	header_lbl.name = "SettingsHeader"
	header_lbl.text = "SETTINGS & OPTIONS"
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_lbl.add_theme_font_override("font", FONT_ALAGARD)
	header_lbl.add_theme_font_size_override("font_size", 16)
	header_lbl.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
	header_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	header_lbl.add_theme_constant_override("shadow_offset_x", 1)
	header_lbl.add_theme_constant_override("shadow_offset_y", 1)
	main_vbox.add_child(header_lbl)
	
	# Tab Switcher
	var tab_bar := HBoxContainer.new()
	tab_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_bar.add_theme_constant_override("separation", 16)
	main_vbox.add_child(tab_bar)

	tab_btn_general = Button.new()
	tab_btn_general.text = "AUDIO & DISPLAY"
	tab_btn_general.add_theme_font_override("font", FONT_ALAGARD)
	tab_btn_general.add_theme_font_size_override("font_size", 11)
	tab_btn_general.pressed.connect(func(): _switch_tab(false))
	tab_bar.add_child(tab_btn_general)

	tab_btn_controls = Button.new()
	tab_btn_controls.text = "CONTROLS & GAMEPAD"
	tab_btn_controls.add_theme_font_override("font", FONT_ALAGARD)
	tab_btn_controls.add_theme_font_size_override("font_size", 11)
	tab_btn_controls.pressed.connect(func(): _switch_tab(true))
	tab_bar.add_child(tab_btn_controls)

	# ── Tab 1: General (Audio & Display) ──────────────────────────────────────
	general_container = VBoxContainer.new()
	general_container.name = "GeneralContainer"
	general_container.add_theme_constant_override("separation", 6)
	main_vbox.add_child(general_container)

	# Settings grid
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 4)
	general_container.add_child(grid)
	
	# 1. Master Volume
	add_slider_row(grid, "Master Volume", func(sl, val_lbl):
		master_slider = sl
		master_val_lbl = val_lbl
		sl.value = GameSettings.master_volume * 100.0
		val_lbl.text = "%d%%" % int(sl.value)
		sl.value_changed.connect(func(v):
			GameSettings.master_volume = v / 100.0
			val_lbl.text = "%d%%" % int(v)
			GameSettings.apply_settings()
		)
	)
	
	# 2. Music Volume
	add_slider_row(grid, "Music (Kulintang)", func(sl, val_lbl):
		music_slider = sl
		music_val_lbl = val_lbl
		sl.value = GameSettings.music_volume * 100.0
		val_lbl.text = "%d%%" % int(sl.value)
		sl.value_changed.connect(func(v):
			GameSettings.music_volume = v / 100.0
			val_lbl.text = "%d%%" % int(v)
			GameSettings.apply_settings()
		)
	)
	
	# 3. SFX Volume
	add_slider_row(grid, "Sound Effects", func(sl, val_lbl):
		sfx_slider = sl
		sfx_val_lbl = val_lbl
		sl.value = GameSettings.sfx_volume * 100.0
		val_lbl.text = "%d%%" % int(sl.value)
		sl.value_changed.connect(func(v):
			GameSettings.sfx_volume = v / 100.0
			val_lbl.text = "%d%%" % int(v)
			GameSettings.apply_settings()
		)
	)
	
	# 4. Screen Shake Intensity
	add_slider_row(grid, "Screen Shake", func(sl, val_lbl):
		shake_slider = sl
		shake_val_lbl = val_lbl
		sl.value = GameSettings.screen_shake_intensity * 100.0
		val_lbl.text = "%d%%" % int(sl.value)
		sl.value_changed.connect(func(v):
			GameSettings.screen_shake_intensity = v / 100.0
			val_lbl.text = "%d%%" % int(v)
		)
	)
	
	# Toggles row
	var toggles_hbox := HBoxContainer.new()
	toggles_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	toggles_hbox.add_theme_constant_override("separation", 24)
	general_container.add_child(toggles_hbox)
	
	fullscreen_btn = CheckButton.new()
	fullscreen_btn.text = "Fullscreen"
	fullscreen_btn.add_theme_font_override("font", FONT_ALAGARD)
	fullscreen_btn.add_theme_font_size_override("font_size", 12)
	fullscreen_btn.button_pressed = GameSettings.fullscreen
	fullscreen_btn.toggled.connect(func(b):
		GameSettings.fullscreen = b
		GameSettings.apply_settings()
	)
	toggles_hbox.add_child(fullscreen_btn)
	
	damage_nums_btn = CheckButton.new()
	damage_nums_btn.text = "Damage Numbers"
	damage_nums_btn.add_theme_font_override("font", FONT_ALAGARD)
	damage_nums_btn.add_theme_font_size_override("font_size", 12)
	damage_nums_btn.button_pressed = GameSettings.damage_numbers
	damage_nums_btn.toggled.connect(func(b):
		GameSettings.damage_numbers = b
	)
	toggles_hbox.add_child(damage_nums_btn)
	
	# Language row
	var lang_hbox := HBoxContainer.new()
	lang_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	lang_hbox.add_theme_constant_override("separation", 10)
	general_container.add_child(lang_hbox)
	
	var lang_lbl := Label.new()
	lang_lbl.text = "Language / Wika:"
	lang_lbl.add_theme_font_override("font", FONT_ALAGARD)
	lang_lbl.add_theme_font_size_override("font_size", 12)
	lang_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
	lang_hbox.add_child(lang_lbl)
	
	lang_btn = OptionButton.new()
	lang_btn.add_theme_font_override("font", FONT_ALAGARD)
	lang_btn.add_theme_font_size_override("font_size", 12)
	lang_btn.add_item("English (Default)", 0)
	lang_btn.add_item("Filipino / Tagalog", 1)
	lang_btn.add_item("Central Bikolano", 2)
	if GameSettings.language == "tl":
		lang_btn.selected = 1
	elif GameSettings.language == "bcl":
		lang_btn.selected = 2
	else:
		lang_btn.selected = 0
	lang_btn.item_selected.connect(func(idx):
		if idx == 1:
			GameSettings.language = "tl"
		elif idx == 2:
			GameSettings.language = "bcl"
		else:
			GameSettings.language = "en"
	)
	lang_hbox.add_child(lang_btn)

	# ── Tab 2: Controls & Gamepad Rebinding ───────────────────────────────────
	controls_container = VBoxContainer.new()
	controls_container.name = "ControlsContainer"
	controls_container.add_theme_constant_override("separation", 4)
	controls_container.visible = false
	main_vbox.add_child(controls_container)

	var hint_lbl = Label.new()
	hint_lbl.text = "Click an action to rebind, then press any Key or Gamepad Button:"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_override("font", FONT_ALAGARD)
	hint_lbl.add_theme_font_size_override("font_size", 11)
	hint_lbl.add_theme_color_override("font_color", Color(0.75, 0.80, 0.90, 0.90))
	controls_container.add_child(hint_lbl)

	var ctrl_grid = GridContainer.new()
	ctrl_grid.columns = 2
	ctrl_grid.add_theme_constant_override("h_separation", 18)
	ctrl_grid.add_theme_constant_override("v_separation", 4)
	controls_container.add_child(ctrl_grid)

	var actions_to_bind = [
		{"action": "move_left", "label": "Move Left"},
		{"action": "move_right", "label": "Move Right"},
		{"action": "jump", "label": "Jump"},
		{"action": "attack", "label": "Attack / Slash"},
		{"action": "guard", "label": "Guard / Parry"},
		{"action": "run", "label": "Sprint / Dash"},
		{"action": "crouch", "label": "Crouch"},
		{"action": "dodge", "label": "Evade Dodge"},
		{"action": "interact", "label": "Interact / Meditate"}
	]

	control_buttons.clear()
	for item in actions_to_bind:
		var row_hbox = HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 8)
		ctrl_grid.add_child(row_hbox)

		var a_lbl = Label.new()
		a_lbl.text = item["label"]
		a_lbl.custom_minimum_size = Vector2(100, 20)
		a_lbl.add_theme_font_override("font", FONT_ALAGARD)
		a_lbl.add_theme_font_size_override("font_size", 11)
		a_lbl.add_theme_color_override("font_color", Color(0.92, 0.90, 0.82))
		row_hbox.add_child(a_lbl)

		var a_btn = Button.new()
		a_btn.custom_minimum_size = Vector2(120, 22)
		a_btn.add_theme_font_override("font", FONT_ALAGARD)
		a_btn.add_theme_font_size_override("font_size", 11)
		var act = item["action"]
		a_btn.text = GameSettings.get_bound_display_text(act)
		a_btn.pressed.connect(func(): _start_rebinding(act, a_btn))
		row_hbox.add_child(a_btn)
		control_buttons[act] = a_btn

	var ctrl_actions_hbox = HBoxContainer.new()
	ctrl_actions_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_actions_hbox.add_theme_constant_override("separation", 12)
	controls_container.add_child(ctrl_actions_hbox)

	var btn_reset_ctrl = Button.new()
	btn_reset_ctrl.text = "RESET CONTROLS"
	btn_reset_ctrl.add_theme_font_override("font", FONT_ALAGARD)
	btn_reset_ctrl.add_theme_font_size_override("font_size", 11)
	btn_reset_ctrl.pressed.connect(_reset_controls)
	ctrl_actions_hbox.add_child(btn_reset_ctrl)
	
	# Close button
	var btn_box := HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(btn_box)
	
	var btn_close := Button.new()
	btn_close.text = "  SAVE & RETURN [Esc]  "
	btn_close.custom_minimum_size = Vector2(170, 26)
	btn_close.add_theme_font_override("font", FONT_ALAGARD)
	btn_close.add_theme_font_size_override("font_size", 12)
	btn_close.pressed.connect(close_menu)
	btn_box.add_child(btn_close)

	_switch_tab(false)


func _switch_tab(show_controls: bool) -> void:
	if is_instance_valid(general_container):
		general_container.visible = not show_controls
	if is_instance_valid(controls_container):
		controls_container.visible = show_controls
	if is_instance_valid(tab_btn_general):
		tab_btn_general.modulate = Color(1.2, 1.1, 0.8, 1.0) if not show_controls else Color(0.7, 0.7, 0.7, 0.8)
	if is_instance_valid(tab_btn_controls):
		tab_btn_controls.modulate = Color(1.2, 1.1, 0.8, 1.0) if show_controls else Color(0.7, 0.7, 0.7, 0.8)
	if show_controls:
		_refresh_control_labels()


func _start_rebinding(action: String, btn: Button) -> void:
	rebind_action = action
	rebind_button = btn
	btn.text = "[PRESS KEY/PAD]"
	btn.modulate = Color(1.5, 1.3, 0.4, 1.0)


func _reset_controls() -> void:
	rebind_action = ""
	GameSettings.reset_default_keybinds()
	_refresh_control_labels()


func _refresh_control_labels() -> void:
	for act in control_buttons.keys():
		var btn = control_buttons[act] as Button
		if is_instance_valid(btn):
			btn.text = GameSettings.get_bound_display_text(act)
			btn.modulate = Color(1, 1, 1, 1)


func _input(event: InputEvent) -> void:
	if rebind_action == "":
		return
	if (event is InputEventKey and event.pressed and not event.echo) or \
	   (event is InputEventJoypadButton and event.pressed):
		GameSettings.set_custom_bind(rebind_action, event)
		if is_instance_valid(rebind_button):
			rebind_button.text = GameSettings.get_bound_display_text(rebind_action)
			rebind_button.modulate = Color(1, 1, 1, 1)
		rebind_action = ""
		rebind_button = null
		get_viewport().set_input_as_handled()


func add_slider_row(parent: GridContainer, label_text: String, setup_cb: Callable) -> void:
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(130, 20)
	lbl.add_theme_font_override("font", FONT_ALAGARD)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.92, 0.90, 0.85))
	parent.add_child(lbl)
	
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.custom_minimum_size = Vector2(180, 20)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(slider)
	
	var val_lbl := Label.new()
	val_lbl.text = "100%"
	val_lbl.custom_minimum_size = Vector2(40, 20)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_lbl.add_theme_font_override("font", FONT_ALAGARD)
	val_lbl.add_theme_font_size_override("font_size", 11)
	val_lbl.add_theme_color_override("font_color", Color(0.80, 0.85, 0.95))
	parent.add_child(val_lbl)
	
	setup_cb.call(slider, val_lbl)


func open_menu() -> void:
	is_active = true
	visible = true
	GameSettings.load_settings()
	if master_slider:
		master_slider.value = GameSettings.master_volume * 100.0
		master_val_lbl.text = "%d%%" % int(master_slider.value)
	if music_slider:
		music_slider.value = GameSettings.music_volume * 100.0
		music_val_lbl.text = "%d%%" % int(music_slider.value)
	if sfx_slider:
		sfx_slider.value = GameSettings.sfx_volume * 100.0
		sfx_val_lbl.text = "%d%%" % int(sfx_slider.value)
	if shake_slider:
		shake_slider.value = GameSettings.screen_shake_intensity * 100.0
		shake_val_lbl.text = "%d%%" % int(shake_slider.value)
	if fullscreen_btn:
		var is_fs = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		GameSettings.fullscreen = is_fs
		fullscreen_btn.button_pressed = is_fs
	if damage_nums_btn:
		damage_nums_btn.button_pressed = GameSettings.damage_numbers
	_refresh_control_labels()
	_switch_tab(false)
		
	overlay.modulate.a = 0.0
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 1.0, 0.20)


func close_menu() -> void:
	if not is_active:
		return
	rebind_action = ""
	GameSettings.save_settings()
	GameSettings.apply_settings()
	
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(overlay, "modulate:a", 0.0, 0.15)
	tw.tween_callback(func():
		visible = false
		closed.emit()
	)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if rebind_action != "":
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_menu()
		get_viewport().set_input_as_handled()

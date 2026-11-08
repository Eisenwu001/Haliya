class_name HaliyaSettingsScreen
extends "res://ui/components/haliya_panel_dialog.gd"

## HaliyaSettingsScreen
## Sub-screen for Audio, Video, and Controls configuration.
## Uses pixel sliders, checkboxes, and an interactive key-rebinding list.
## Inherits all styling from res://ui/theme/haliya_theme.tres.

const GameSettings = preload("res://scripts/game_settings.gd")

var tab_btn_audio: Button
var tab_btn_video: Button
var tab_btn_controls: Button

var audio_tab: VBoxContainer
var video_tab: VBoxContainer
var controls_tab: VBoxContainer

var master_slider: HSlider
var master_val_label: Label
var music_slider: HSlider
var music_val_label: Label
var sfx_slider: HSlider
var sfx_val_label: Label

var fullscreen_check: CheckBox
var damage_nums_check: CheckBox
var skip_intro_check: CheckBox
var shake_slider: HSlider
var shake_val_label: Label

var keybind_buttons: Dictionary = {}
var awaiting_rebind_action: String = ""
var awaiting_rebind_button: Button = null


func _init() -> void:
	super._init()
	dialog_title = "SETTINGS"
	panel_size = Vector2(548, 316)
	_build_settings_content()


func _build_settings_content() -> void:
	# Tab Selector Row
	var tab_bar := HBoxContainer.new()
	tab_bar.name = "TabBar"
	tab_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_bar.add_theme_constant_override("separation", C.SPACING_MD)
	body_container.add_child(tab_bar)

	tab_btn_audio = _make_tab_button("AUDIO", 0)
	tab_btn_video = _make_tab_button("VIDEO", 1)
	tab_btn_controls = _make_tab_button("CONTROLS", 2)
	tab_bar.add_child(tab_btn_audio)
	tab_bar.add_child(tab_btn_video)
	tab_bar.add_child(tab_btn_controls)

	# Content Holder
	var content_panel := PanelContainer.new()
	content_panel.theme_type_variation = &"InnerPanelContainer"
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_container.add_child(content_panel)

	# ── 1. AUDIO TAB ─────────────────────────────────────────────────────────
	audio_tab = VBoxContainer.new()
	audio_tab.name = "AudioTab"
	audio_tab.add_theme_constant_override("separation", C.SPACING_LG)
	content_panel.add_child(audio_tab)

	var audio_hdr := Label.new()
	audio_hdr.text = "SOUND AND KULINTANG HARMONICS"
	audio_hdr.theme_type_variation = &"SectionHeaderLabel"
	audio_tab.add_child(audio_hdr)

	var m_row := _create_slider_row("MASTER VOLUME", GameSettings.master_volume, func(val: float):
		GameSettings.master_volume = val
		master_val_label.text = "%d%%" % int(round(val * 100.0))
		GameSettings.apply_settings()
		GameSettings.save_settings()
	)
	master_slider = m_row["slider"]
	master_val_label = m_row["val_label"]
	audio_tab.add_child(m_row["row"])

	var mu_row := _create_slider_row("MUSIC VOLUME", GameSettings.music_volume, func(val: float):
		GameSettings.music_volume = val
		music_val_label.text = "%d%%" % int(round(val * 100.0))
		GameSettings.apply_settings()
		GameSettings.save_settings()
	)
	music_slider = mu_row["slider"]
	music_val_label = mu_row["val_label"]
	audio_tab.add_child(mu_row["row"])

	var s_row := _create_slider_row("SFX VOLUME", GameSettings.sfx_volume, func(val: float):
		GameSettings.sfx_volume = val
		sfx_val_label.text = "%d%%" % int(round(val * 100.0))
		GameSettings.apply_settings()
		GameSettings.save_settings()
	)
	sfx_slider = s_row["slider"]
	sfx_val_label = s_row["val_label"]
	audio_tab.add_child(s_row["row"])

	# ── 2. VIDEO TAB ─────────────────────────────────────────────────────────
	video_tab = VBoxContainer.new()
	video_tab.name = "VideoTab"
	video_tab.visible = false
	video_tab.add_theme_constant_override("separation", C.SPACING_LG)
	content_panel.add_child(video_tab)

	var video_hdr := Label.new()
	video_hdr.text = "DISPLAY AND VISUAL FEEDBACK"
	video_hdr.theme_type_variation = &"SectionHeaderLabel"
	video_tab.add_child(video_hdr)

	fullscreen_check = CheckBox.new()
	fullscreen_check.text = "  FULLSCREEN DISPLAY MODE"
	fullscreen_check.button_pressed = GameSettings.fullscreen
	fullscreen_check.toggled.connect(func(pressed: bool):
		GameSettings.fullscreen = pressed
		GameSettings.apply_settings()
		GameSettings.save_settings()
	)
	video_tab.add_child(fullscreen_check)

	damage_nums_check = CheckBox.new()
	damage_nums_check.text = "  FLOATING COMBAT DAMAGE NUMBERS"
	damage_nums_check.button_pressed = GameSettings.damage_numbers
	damage_nums_check.toggled.connect(func(pressed: bool):
		GameSettings.damage_numbers = pressed
		GameSettings.save_settings()
	)
	video_tab.add_child(damage_nums_check)

	skip_intro_check = CheckBox.new()
	skip_intro_check.text = "  SKIP INTRO CARDS ON LAUNCH"
	skip_intro_check.button_pressed = GameSettings.skip_intro
	skip_intro_check.toggled.connect(func(pressed: bool):
		GameSettings.skip_intro = pressed
		GameSettings.save_settings()
	)
	video_tab.add_child(skip_intro_check)

	var reduce_motion_check := CheckBox.new()
	reduce_motion_check.text = "  REDUCE MOTION (FREEZE SWAY AND ATMOSPHERE)"
	reduce_motion_check.button_pressed = GameSettings.reduce_motion
	reduce_motion_check.toggled.connect(func(pressed: bool):
		GameSettings.reduce_motion = pressed
		GameSettings.save_settings()
	)
	video_tab.add_child(reduce_motion_check)

	var sh_row := _create_slider_row("SCREEN SHAKE INTENSITY", GameSettings.screen_shake_intensity, func(val: float):
		GameSettings.screen_shake_intensity = val
		shake_val_label.text = "%d%%" % int(round(val * 100.0))
		GameSettings.save_settings()
	)
	shake_slider = sh_row["slider"]
	shake_val_label = sh_row["val_label"]
	video_tab.add_child(sh_row["row"])

	# ── 3. CONTROLS TAB ──────────────────────────────────────────────────────
	controls_tab = VBoxContainer.new()
	controls_tab.name = "ControlsTab"
	controls_tab.visible = false
	controls_tab.add_theme_constant_override("separation", C.SPACING_SM)
	content_panel.add_child(controls_tab)

	var ctrl_top := HBoxContainer.new()
	controls_tab.add_child(ctrl_top)

	var ctrl_hdr := Label.new()
	ctrl_hdr.text = "KEY REBINDING (CLICK OR ENTER TO REBIND)"
	ctrl_hdr.theme_type_variation = &"SectionHeaderLabel"
	ctrl_hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl_top.add_child(ctrl_hdr)

	var reset_btn := Button.new()
	reset_btn.text = "RESET DEFAULTS"
	reset_btn.theme_type_variation = &"ActionButton"
	reset_btn.pressed.connect(func():
		GameSettings.reset_default_keybinds()
		_refresh_keybind_labels()
	)
	ctrl_top.add_child(reset_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_tab.add_child(scroll)

	var bind_list := VBoxContainer.new()
	bind_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bind_list.add_theme_constant_override("separation", C.SPACING_XS)
	scroll.add_child(bind_list)

	var actions_meta := [
		{"action": "move_left", "label": "MOVE LEFT"},
		{"action": "move_right", "label": "MOVE RIGHT"},
		{"action": "jump", "label": "JUMP / ASCEND"},
		{"action": "crouch", "label": "CROUCH / DESCEND"},
		{"action": "attack", "label": "STRIKE (KAMPILAN)"},
		{"action": "guard", "label": "GUARD / DEFLECT"},
		{"action": "dodge", "label": "SHADOW DASH"},
		{"action": "interact", "label": "COMMUNE / INTERACT"}
	]

	for item in actions_meta:
		var act_id: String = item["action"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", C.SPACING_MD)
		bind_list.add_child(row)

		var name_lbl := Label.new()
		name_lbl.text = item["label"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var key_btn := Button.new()
		key_btn.theme_type_variation = &"ActionButton"
		key_btn.custom_minimum_size = Vector2(148, 18)
		key_btn.text = GameSettings.get_bound_display_text(act_id)
		key_btn.pressed.connect(func(): _begin_rebind(act_id, key_btn))
		row.add_child(key_btn)
		keybind_buttons[act_id] = key_btn


func _make_tab_button(label_str: String, idx: int) -> Button:
	var btn := Button.new()
	btn.text = label_str
	btn.theme_type_variation = &"ActionButton"
	btn.custom_minimum_size = Vector2(116, 20)
	btn.pressed.connect(func(): switch_tab(idx))
	btn.focus_entered.connect(func(): switch_tab(idx))
	return btn


func _create_slider_row(title_str: String, initial_val: float, on_changed: Callable) -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", C.SPACING_MD)

	var lbl := Label.new()
	lbl.text = title_str
	lbl.custom_minimum_size = Vector2(190, 16)
	row.add_child(lbl)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial_val
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(180, 16)
	row.add_child(slider)

	var val_lbl := Label.new()
	val_lbl.text = "%d%%" % int(round(initial_val * 100.0))
	val_lbl.theme_type_variation = &"SectionHeaderLabel"
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_lbl.custom_minimum_size = Vector2(48, 16)
	row.add_child(val_lbl)

	slider.value_changed.connect(on_changed)
	return {"row": row, "slider": slider, "val_label": val_lbl}


func switch_tab(idx: int) -> void:
	awaiting_rebind_action = ""
	audio_tab.visible = (idx == 0)
	video_tab.visible = (idx == 1)
	controls_tab.visible = (idx == 2)
	if idx == 0 and is_instance_valid(tab_btn_audio) and not tab_btn_audio.has_focus():
		tab_btn_audio.grab_focus()
	elif idx == 1 and is_instance_valid(tab_btn_video) and not tab_btn_video.has_focus():
		tab_btn_video.grab_focus()
	elif idx == 2 and is_instance_valid(tab_btn_controls) and not tab_btn_controls.has_focus():
		tab_btn_controls.grab_focus()


func _begin_rebind(act_id: String, btn: Button) -> void:
	awaiting_rebind_action = act_id
	awaiting_rebind_button = btn
	btn.text = "[ PRESS ANY KEY ]"


func _refresh_keybind_labels() -> void:
	for act_id in keybind_buttons.keys():
		var btn: Button = keybind_buttons[act_id]
		if is_instance_valid(btn):
			btn.text = GameSettings.get_bound_display_text(act_id)


func on_screen_opened() -> void:
	GameSettings.load_settings()
	master_slider.value = GameSettings.master_volume
	music_slider.value = GameSettings.music_volume
	sfx_slider.value = GameSettings.sfx_volume
	fullscreen_check.button_pressed = GameSettings.fullscreen
	damage_nums_check.button_pressed = GameSettings.damage_numbers
	if is_instance_valid(skip_intro_check):
		skip_intro_check.button_pressed = GameSettings.skip_intro
	shake_slider.value = GameSettings.screen_shake_intensity
	_refresh_keybind_labels()
	switch_tab(0)
	if is_instance_valid(tab_btn_audio):
		tab_btn_audio.grab_focus()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if not awaiting_rebind_action.is_empty():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode != KEY_ESCAPE:
				GameSettings.set_custom_bind(awaiting_rebind_action, event)
			awaiting_rebind_action = ""
			awaiting_rebind_button = null
			_refresh_keybind_labels()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_requested.emit()

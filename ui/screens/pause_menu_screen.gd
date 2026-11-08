class_name HaliyaPauseMenuScreen
extends Control

## HaliyaPauseMenuScreen
## Unified Pause Menu for "HALIYA: Mask of Sorrows".
## Inherits 100% of its styling from res://ui/theme/haliya_theme.tres.
## Features:
## - Flat dark charcoal overlay (#1e2420 at 65% opacity) + 35% desaturation of the frozen game via screen shader.
## - Soft left-to-right Bayer-dithered gradient behind the menu column (no full-screen checkerboard).
## - Left column: "PAUSED" title in clean pixel font over carved zigzag divider + text-only menu buttons
##   with 2-frame crescent selectors (Resume, Settings, Lore Codex, Restart Level, SAVE AND QUIT).
## - Confirmation modal (Yes/No) for Restart Level and SAVE AND QUIT to prevent accidental activation.
## - Dim hint line at bottom-left: "[ESC] RESUME".
## - Full keyboard (Arrows / WASD / Enter / Space / Esc) and mouse navigation.
## - Integrated sub-screens (Settings and Lore Codex) extending HaliyaPanelDialog.

signal resume_requested()
signal restart_requested()
signal save_and_quit_requested()

const C = preload("res://ui/theme/ui_theme_constants.gd")
const HaliyaMenuButtonScene = preload("res://ui/components/haliya_menu_button.tscn")
const SettingsScreenScene = preload("res://ui/screens/settings_screen.tscn")
const LoreCodexScreenScene = preload("res://ui/screens/lore_codex_screen.tscn")
const SHADER_PAUSE_BACKDROP = preload("res://shaders/pause_backdrop.gdshader")

var backdrop_rect: ColorRect
var left_gradient_rect: TextureRect
var content_root: Control
var title_box: VBoxContainer
var title_label: Label
var divider_rect: TextureRect
var menu_vbox: VBoxContainer
var menu_buttons: Array[HaliyaMenuButton] = []
var resume_hint: Label

# Sub-screens
var settings_screen: Control
var lore_codex_screen: Control
var last_focused_btn: HaliyaMenuButton = null

# Confirmation Modal (Restart Level / SAVE AND QUIT)
var confirm_modal: Control
var confirm_title_label: Label
var confirm_prompt_label: Label
var btn_confirm_no: HaliyaMenuButton
var btn_confirm_yes: HaliyaMenuButton
var confirm_action: String = ""

var sfx_player: AudioStreamPlayer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = load(C.PATH_THEME)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _ready() -> void:
	_setup_audio()
	_wire_focus_neighbors()


func _setup_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "PauseSFXPlayer"
	sfx_player.bus = "Master"
	add_child(sfx_player)


func _play_hover_sfx() -> void:
	if not is_inside_tree() or not visible:
		return
	if is_instance_valid(sfx_player):
		var sfx = ProceduralAudio.get_ui_hover()
		if sfx:
			sfx_player.stream = sfx
			sfx_player.volume_db = -6.0
			sfx_player.play()


func _play_select_sfx() -> void:
	if not is_inside_tree() or not visible:
		return
	if is_instance_valid(sfx_player):
		var sfx = ProceduralAudio.get_ui_select()
		if sfx:
			sfx_player.stream = sfx
			sfx_player.volume_db = -4.0
			sfx_player.play()


func _build_ui() -> void:
	# 1. Full-Screen Backdrop: Flat Charcoal #1e2420 at 65% opacity + 35% desaturation of frozen game
	backdrop_rect = ColorRect.new()
	backdrop_rect.name = "BackdropRect"
	backdrop_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	var mat := ShaderMaterial.new()
	mat.shader = SHADER_PAUSE_BACKDROP
	backdrop_rect.material = mat
	backdrop_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop_rect)

	# 2. Soft left-to-right Bayer-dithered gradient behind the menu column ONLY
	left_gradient_rect = TextureRect.new()
	left_gradient_rect.name = "LeftDitherGradient"
	left_gradient_rect.texture = load(C.TEX_LEFT_GRADIENT)
	left_gradient_rect.position = Vector2.ZERO
	left_gradient_rect.size = Vector2(260, 360)
	left_gradient_rect.stretch_mode = TextureRect.STRETCH_SCALE
	left_gradient_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_gradient_rect)

	# 3. Main Content Container
	content_root = Control.new()
	content_root.name = "ContentRoot"
	content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content_root)

	# ── Left Column: Title in Settings Header style (clean font + zigzag divider) ──
	title_box = VBoxContainer.new()
	title_box.name = "TitleBox"
	title_box.position = Vector2(C.MENU_LEFT_EDGE_X, C.MENU_BLOCK_TOP_Y)
	title_box.size = Vector2(220, 36)
	title_box.add_theme_constant_override("separation", C.SPACING_SM)
	title_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_root.add_child(title_box)

	title_label = Label.new()
	title_label.name = "PauseTitle"
	title_label.text = "PAUSED"
	title_label.theme_type_variation = &"PanelHeaderLabel"
	title_box.add_child(title_label)

	divider_rect = TextureRect.new()
	divider_rect.name = "ZigzagDivider"
	divider_rect.texture = load(C.TEX_DIVIDER_ZIGZAG)
	divider_rect.stretch_mode = TextureRect.STRETCH_KEEP
	divider_rect.custom_minimum_size = Vector2(160, 9)
	title_box.add_child(divider_rect)

	# ── Menu Items Column ──────────────────────────────────────────────────
	menu_vbox = VBoxContainer.new()
	menu_vbox.name = "MenuVBox"
	menu_vbox.position = Vector2(C.MENU_LEFT_EDGE_X, 86.0)
	menu_vbox.size = Vector2(240, 210)
	menu_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	content_root.add_child(menu_vbox)

	# Items: Resume (PRIMARY, gold on select), Settings, Lore Codex, Restart Level, SAVE AND QUIT (MUTED, separated)
	var _btn_resume := _create_menu_item("Resume", C.MenuTier.PRIMARY, "", _on_resume_pressed)
	var _btn_settings := _create_menu_item("Settings", C.MenuTier.SMALL, "", _on_settings_pressed)
	var _btn_codex := _create_menu_item("Lore Codex", C.MenuTier.SMALL, "", _on_codex_pressed)
	var _btn_restart := _create_menu_item("Restart Level", C.MenuTier.MEDIUM, "", _on_restart_pressed)
	var _btn_quit := _create_menu_item("SAVE AND QUIT", C.MenuTier.MUTED, "", _on_save_quit_pressed)

	# ── Bottom-Left Hint: [ESC] RESUME ─────────────────────────────────────
	resume_hint = Label.new()
	resume_hint.name = "ResumeHint"
	resume_hint.text = "[ESC] RESUME"
	resume_hint.theme_type_variation = &"MutedBodyLabel"
	resume_hint.position = Vector2(C.MENU_LEFT_EDGE_X, 336.0)
	resume_hint.size = Vector2(180, 16)
	resume_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_root.add_child(resume_hint)

	# ── Sub-Screens: Settings and Lore Codex ────────────────────────────────
	settings_screen = SettingsScreenScene.instantiate()
	settings_screen.visible = false
	settings_screen.close_requested.connect(_on_subscreen_closed)
	add_child(settings_screen)

	lore_codex_screen = LoreCodexScreenScene.instantiate()
	lore_codex_screen.visible = false
	lore_codex_screen.close_requested.connect(_on_subscreen_closed)
	add_child(lore_codex_screen)

	# ── Confirmation Modal (Restart Level / SAVE AND QUIT) ──────────────────
	_build_confirm_modal()


func _create_menu_item(text: String, tier: int, caption: String, callback: Callable) -> HaliyaMenuButton:
	var item: HaliyaMenuButton = HaliyaMenuButtonScene.instantiate()
	item.setup(text, tier, caption)
	item.item_selected.connect(_play_hover_sfx)
	item.item_activated.connect(func():
		_play_select_sfx()
		callback.call()
	)
	menu_vbox.add_child(item)
	menu_buttons.append(item)
	return item


func _build_confirm_modal() -> void:
	confirm_modal = Control.new()
	confirm_modal.name = "ConfirmModal"
	confirm_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	confirm_modal.visible = false
	confirm_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(confirm_modal)

	var dim_bg := ColorRect.new()
	dim_bg.name = "ConfirmDimBG"
	dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_bg.color = C.COLOR_CHARCOAL_OVERLAY
	dim_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	confirm_modal.add_child(dim_bg)

	var panel := PanelContainer.new()
	panel.name = "ConfirmPanel"
	panel.theme_type_variation = &"InnerPanelContainer"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -140.0
	panel.offset_right = 140.0
	panel.offset_top = -75.0
	panel.offset_bottom = 75.0
	panel.custom_minimum_size = Vector2(280, 150)
	confirm_modal.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "ConfirmVBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", C.SPACING_SM)
	panel.add_child(vbox)

	confirm_title_label = Label.new()
	confirm_title_label.name = "ConfirmTitle"
	confirm_title_label.text = "CONFIRM"
	confirm_title_label.theme_type_variation = &"PanelHeaderLabel"
	confirm_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(confirm_title_label)

	var divider := TextureRect.new()
	divider.texture = load(C.TEX_DIVIDER_ZIGZAG)
	divider.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	divider.custom_minimum_size = Vector2(160, 9)
	vbox.add_child(divider)

	var prompt_spacer := Control.new()
	prompt_spacer.custom_minimum_size = Vector2(0, 2)
	vbox.add_child(prompt_spacer)

	confirm_prompt_label = Label.new()
	confirm_prompt_label.name = "ConfirmPrompt"
	confirm_prompt_label.text = "Are you sure?"
	confirm_prompt_label.theme_type_variation = &"MutedBodyLabel"
	confirm_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(confirm_prompt_label)

	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(btn_spacer)

	var options_box := VBoxContainer.new()
	options_box.name = "OptionsVBox"
	options_box.alignment = BoxContainer.ALIGNMENT_CENTER
	options_box.add_theme_constant_override("separation", C.SPACING_SM)
	vbox.add_child(options_box)

	btn_confirm_no = HaliyaMenuButtonScene.instantiate()
	btn_confirm_no.setup("NO — RETURN", C.MenuTier.MEDIUM)
	btn_confirm_no.item_selected.connect(_play_hover_sfx)
	btn_confirm_no.item_activated.connect(func():
		_play_select_sfx()
		_close_confirm()
	)
	options_box.add_child(btn_confirm_no)

	btn_confirm_yes = HaliyaMenuButtonScene.instantiate()
	btn_confirm_yes.setup("YES — CONFIRM", C.MenuTier.SMALL)
	btn_confirm_yes.item_selected.connect(_play_hover_sfx)
	btn_confirm_yes.item_activated.connect(func():
		_play_select_sfx()
		_on_confirm_accepted()
	)
	options_box.add_child(btn_confirm_yes)

	# Wire neighbors between NO and YES
	var no_btn: Button = btn_confirm_no.button
	var yes_btn: Button = btn_confirm_yes.button
	no_btn.focus_neighbor_top = no_btn.get_path_to(yes_btn)
	no_btn.focus_neighbor_bottom = no_btn.get_path_to(yes_btn)
	yes_btn.focus_neighbor_top = yes_btn.get_path_to(no_btn)
	yes_btn.focus_neighbor_bottom = yes_btn.get_path_to(no_btn)


func _open_confirm(action: String) -> void:
	confirm_action = action
	if action == "restart":
		confirm_title_label.text = "RESTART LEVEL?"
		confirm_prompt_label.text = "Restart current stage from the beginning? Unsaved progress will be lost."
		btn_confirm_no.label_text = "NO — RETURN"
		btn_confirm_yes.label_text = "YES — RESTART"
	elif action == "quit":
		confirm_title_label.text = "SAVE AND QUIT?"
		confirm_prompt_label.text = "Save your journey and return to the main menu?"
		btn_confirm_no.label_text = "NO — RETURN"
		btn_confirm_yes.label_text = "YES — SAVE AND QUIT"

	confirm_modal.visible = true
	btn_confirm_no.call_deferred("grab_item_focus")


func _close_confirm() -> void:
	confirm_modal.visible = false
	var act := confirm_action
	confirm_action = ""
	if act == "restart" and menu_buttons.size() > 3:
		menu_buttons[3].call_deferred("grab_item_focus")
	elif act == "quit" and menu_buttons.size() > 4:
		menu_buttons[4].call_deferred("grab_item_focus")
	elif not menu_buttons.is_empty():
		menu_buttons[0].call_deferred("grab_item_focus")


func _on_confirm_accepted() -> void:
	confirm_modal.visible = false
	var act := confirm_action
	confirm_action = ""
	if act == "restart":
		restart_requested.emit()
	elif act == "quit":
		save_and_quit_requested.emit()


func _wire_focus_neighbors() -> void:
	var count := menu_buttons.size()
	for i in range(count):
		var curr_btn: Button = menu_buttons[i].button
		var prev_btn: Button = menu_buttons[(i - 1 + count) % count].button
		var next_btn: Button = menu_buttons[(i + 1) % count].button
		curr_btn.focus_neighbor_top = curr_btn.get_path_to(prev_btn)
		curr_btn.focus_neighbor_bottom = curr_btn.get_path_to(next_btn)


func open_menu() -> void:
	visible = true
	content_root.visible = true
	confirm_modal.visible = false
	confirm_action = ""
	if is_instance_valid(settings_screen):
		settings_screen.visible = false
	if is_instance_valid(lore_codex_screen):
		lore_codex_screen.visible = false
	if not menu_buttons.is_empty():
		menu_buttons[0].call_deferred("grab_item_focus")


func close_menu() -> void:
	confirm_modal.visible = false
	confirm_action = ""
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") and not event.echo:
		get_viewport().set_input_as_handled()
		if confirm_modal.visible:
			_close_confirm()
			return
		if is_instance_valid(settings_screen) and settings_screen.visible:
			_on_subscreen_closed()
			return
		if is_instance_valid(lore_codex_screen) and lore_codex_screen.visible:
			_on_subscreen_closed()
			return
		_on_resume_pressed()


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_settings_pressed() -> void:
	last_focused_btn = menu_buttons[1]
	content_root.visible = false
	if is_instance_valid(settings_screen):
		settings_screen.visible = true
		if settings_screen.has_method("on_screen_opened"):
			settings_screen.on_screen_opened()


func _on_codex_pressed() -> void:
	last_focused_btn = menu_buttons[2]
	content_root.visible = false
	if is_instance_valid(lore_codex_screen):
		lore_codex_screen.visible = true
		if lore_codex_screen.has_method("on_screen_opened"):
			lore_codex_screen.on_screen_opened()


func _on_restart_pressed() -> void:
	_open_confirm("restart")


func _on_save_quit_pressed() -> void:
	_open_confirm("quit")


func _on_subscreen_closed() -> void:
	if is_instance_valid(settings_screen):
		settings_screen.visible = false
	if is_instance_valid(lore_codex_screen):
		lore_codex_screen.visible = false
	content_root.visible = true
	if is_instance_valid(last_focused_btn):
		last_focused_btn.call_deferred("grab_item_focus")
	elif not menu_buttons.is_empty():
		menu_buttons[0].call_deferred("grab_item_focus")

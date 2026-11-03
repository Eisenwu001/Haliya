class_name HaliyaQuitConfirmScreen
extends "res://ui/components/haliya_panel_dialog.gd"

## HaliyaQuitConfirmScreen
## Small centered confirmation dialog with Yes / No options.
## Inherits all styling from res://ui/theme/haliya_theme.tres.

signal quit_confirmed()

const MenuBtnScript = preload("res://ui/components/haliya_menu_button.gd")

var btn_no: HaliyaMenuButton
var btn_yes: HaliyaMenuButton


func _init() -> void:
	super._init()
	dialog_title = "QUIT GAME?"
	panel_size = Vector2(284, 152)
	show_back_button = false
	_build_quit_ui()


func _build_quit_ui() -> void:
	var prompt_lbl := Label.new()
	prompt_lbl.text = "Rest by the moonlit altar and return to desktop?"
	prompt_lbl.theme_type_variation = &"MutedBodyLabel"
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_container.add_child(prompt_lbl)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	body_container.add_child(spacer)

	var options_vbox := VBoxContainer.new()
	options_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	options_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	options_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	body_container.add_child(options_vbox)

	btn_no = MenuBtnScript.new()
	btn_no.setup("NO — REMAIN", C.MenuTier.MEDIUM)
	btn_no.item_activated.connect(func(): close_requested.emit())
	options_vbox.add_child(btn_no)

	btn_yes = MenuBtnScript.new()
	btn_yes.setup("YES — QUIT", C.MenuTier.SMALL)
	btn_yes.item_activated.connect(func(): quit_confirmed.emit())
	options_vbox.add_child(btn_yes)


func on_screen_opened() -> void:
	if is_instance_valid(btn_no):
		btn_no.grab_item_focus()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_requested.emit()

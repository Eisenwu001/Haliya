class_name UIScreenManager
extends Control

## UIScreenManager
## Handles navigation between the Main Menu and sub-screens (Settings, Stage Select,
## Lore Codex, How to Play, Quit Confirmation) using stepped pixel-art transitions
## and automatic focus restoration so keyboard focus is never lost.

signal sfx_hover()
signal sfx_confirm()
signal sfx_back()
signal screen_changed(screen_name: String)

const C = preload("res://ui/theme/ui_theme_constants.gd")

var screens: Dictionary = {}
var active_screen_name: String = ""
var return_focus_control: Control = null


func _init() -> void:
	name = "UIScreenManager"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func register_screen(screen_id: String, screen_node: Control) -> void:
	screens[screen_id] = screen_node
	screen_node.visible = false
	add_child(screen_node)
	if screen_node.has_signal("close_requested"):
		screen_node.connect("close_requested", func(): close_active_screen())


func open_screen(screen_id: String, from_focus: Control = null) -> void:
	if not screens.has(screen_id):
		return
	if is_instance_valid(from_focus):
		return_focus_control = from_focus
	else:
		var vp := get_viewport()
		if vp and is_instance_valid(vp.gui_get_focus_owner()):
			return_focus_control = vp.gui_get_focus_owner()

	# Hide any previously open sub-screen
	for k in screens.keys():
		var s: Control = screens[k]
		if is_instance_valid(s):
			s.visible = false

	active_screen_name = screen_id
	var target: Control = screens[screen_id]
	target.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	sfx_confirm.emit()

	# Stepped 3-step pixel fade-in (no smooth easing)
	target.modulate.a = 0.35
	var tw := create_tween()
	tw.tween_callback(func(): target.modulate.a = 0.70).set_delay(0.03)
	tw.tween_callback(func(): target.modulate.a = 1.0).set_delay(0.03)

	if target.has_method("on_screen_opened"):
		target.call("on_screen_opened")
	screen_changed.emit(screen_id)


func close_active_screen() -> void:
	if active_screen_name.is_empty():
		return
	var prev_id := active_screen_name
	active_screen_name = ""
	for k in screens.keys():
		var s: Control = screens[k]
		if is_instance_valid(s):
			s.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	sfx_back.emit()

	if is_instance_valid(return_focus_control) and return_focus_control.is_visible_in_tree():
		return_focus_control.grab_focus()
	screen_changed.emit("")


func is_any_screen_open() -> bool:
	return not active_screen_name.is_empty()

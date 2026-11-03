class_name HaliyaPanelDialog
extends Control

## HaliyaPanelDialog
## Reusable sub-screen container with a dark translucent backdrop, stepped carved-notch
## 9-slice border (from haliya_theme.tres), totem spiral header divider, content body,
## and Esc/Back navigation.

signal close_requested()

const C = preload("res://ui/theme/ui_theme_constants.gd")

@export var dialog_title: String = "SANCTUARY":
	set(v):
		dialog_title = v
		if is_instance_valid(header_label):
			header_label.text = dialog_title

@export var panel_size: Vector2 = Vector2(540, 310):
	set(v):
		panel_size = v
		_update_panel_bounds()

@export var show_back_button: bool = true:
	set(v):
		show_back_button = v
		if is_instance_valid(footer_box):
			footer_box.visible = show_back_button

var backdrop: ColorRect
var panel: PanelContainer
var root_vbox: VBoxContainer
var header_label: Label
var divider_rect: TextureRect
var body_container: VBoxContainer
var footer_box: HBoxContainer
var back_button: Button


func _init() -> void:
	theme = load(C.PATH_THEME)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	backdrop = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = C.COLOR_CHARCOAL_OVERLAY
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	panel = PanelContainer.new()
	panel.name = "NotchedPanel"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	add_child(panel)

	root_vbox = VBoxContainer.new()
	root_vbox.name = "RootVBox"
	root_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	panel.add_child(root_vbox)

	# Header Title + Totem Spiral Divider
	var header_box := VBoxContainer.new()
	header_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header_box.add_theme_constant_override("separation", C.SPACING_XS)
	root_vbox.add_child(header_box)

	header_label = Label.new()
	header_label.name = "HeaderLabel"
	header_label.text = dialog_title
	header_label.theme_type_variation = &"PanelHeaderLabel"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_box.add_child(header_label)

	# Custom pixel art can replace TEX_DIVIDER_ZIGZAG
	divider_rect = TextureRect.new()
	divider_rect.name = "ZigzagDivider"
	divider_rect.texture = load(C.TEX_DIVIDER_ZIGZAG)
	divider_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	divider_rect.custom_minimum_size = Vector2(160, 9)
	header_box.add_child(divider_rect)

	# Body Content Container
	body_container = VBoxContainer.new()
	body_container.name = "BodyContainer"
	body_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_container.add_theme_constant_override("separation", C.SPACING_SM)
	root_vbox.add_child(body_container)

	# Footer Navigation Bar
	footer_box = HBoxContainer.new()
	footer_box.name = "FooterBox"
	footer_box.alignment = BoxContainer.ALIGNMENT_END
	footer_box.add_theme_constant_override("separation", C.SPACING_MD)
	root_vbox.add_child(footer_box)

	var esc_hint := Label.new()
	esc_hint.text = "[W/S or ARROWS] Navigate   [ENTER] Confirm"
	esc_hint.theme_type_variation = &"MutedBodyLabel"
	esc_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_box.add_child(esc_hint)

	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "[ESC] BACK"
	back_button.theme_type_variation = &"ActionButton"
	back_button.custom_minimum_size = Vector2(92, 20)
	back_button.pressed.connect(func(): close_requested.emit())
	footer_box.add_child(back_button)

	_update_panel_bounds()


func _update_panel_bounds() -> void:
	if not is_instance_valid(panel):
		return
	panel.offset_left = -panel_size.x * 0.5
	panel.offset_right = panel_size.x * 0.5
	panel.offset_top = -panel_size.y * 0.5
	panel.offset_bottom = panel_size.y * 0.5
	panel.custom_minimum_size = panel_size

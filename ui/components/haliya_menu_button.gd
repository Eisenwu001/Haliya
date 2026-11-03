class_name HaliyaMenuButton
extends VBoxContainer

## HaliyaMenuButton
## Reusable frameless pixel-art menu item with hierarchy tiers, a 2-frame animated
## crescent-moon selector on the left, optional inline caption underneath (for Continue /
## Begin Journey), and audio hook signals.
## Polish Pass 2:
## - Treats button and caption as ONE unified group container.
## - Both button and caption slide right by C.SLIDE_OFFSET_PX on selection so their left edges match.
## - Crescent selector is anchored to the visual center of the LABEL's cap height (snapped to integer px).
## - Selector gap to label's left edge is a constant defined in UIThemeConstants.
## - 6-8px separation between label and caption.

signal item_selected()
signal item_activated()

const C = preload("res://ui/theme/ui_theme_constants.gd")

@export var label_text: String = "MENU ITEM":
	set(v):
		label_text = v
		if is_instance_valid(button):
			button.text = label_text
		_update_layout_sizes()

@export var caption_text: String = "":
	set(v):
		caption_text = v
		_update_caption()

@export var tier: int = C.MenuTier.SMALL:
	set(v):
		tier = v
		_apply_tier_variation()

var top_spacer: Control
var item_holder: Control
var crescent_rect: TextureRect
var group_container: VBoxContainer
var button: Button
var caption_label: Label

# Custom pixel art can replace these two generated selector frames at any time:
var _tex_crescent_0: Texture2D
var _tex_crescent_1: Texture2D
var _anim_accum: float = 0.0
var _anim_frame: int = 0
var _is_selected: bool = false


func _init() -> void:
	theme = load(C.PATH_THEME)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_theme_constant_override("separation", 1)

	_tex_crescent_0 = load(C.TEX_CRESCENT_0)
	_tex_crescent_1 = load(C.TEX_CRESCENT_1)

	top_spacer = Control.new()
	top_spacer.name = "TopSpacer"
	top_spacer.visible = false
	add_child(top_spacer)

	item_holder = Control.new()
	item_holder.name = "ItemHolder"
	item_holder.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(item_holder)

	crescent_rect = TextureRect.new()
	crescent_rect.name = "CrescentSelector"
	crescent_rect.texture = _tex_crescent_0
	crescent_rect.size = Vector2(14, 14)
	crescent_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	crescent_rect.modulate.a = 0.0
	crescent_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_holder.add_child(crescent_rect)

	# Unified group container: Button and Caption slide together as ONE group
	group_container = VBoxContainer.new()
	group_container.name = "GroupContainer"
	group_container.mouse_filter = Control.MOUSE_FILTER_PASS
	group_container.position = Vector2.ZERO
	group_container.add_theme_constant_override("separation", C.CAPTION_SEPARATION_PX)
	item_holder.add_child(group_container)

	button = Button.new()
	button.name = "ActionButton"
	button.text = label_text
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	group_container.add_child(button)

	caption_label = Label.new()
	caption_label.name = "CaptionLabel"
	caption_label.theme_type_variation = &"CaptionLabel"
	caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption_label.visible = false
	var caption_sb = StyleBoxEmpty.new()
	caption_sb.content_margin_left = 2.0
	caption_label.add_theme_stylebox_override("normal", caption_sb)
	group_container.add_child(caption_label)

	# Wire keyboard focus & mouse hover so hover ALWAYS equals selected state
	button.focus_entered.connect(_on_selected)
	button.focus_exited.connect(_on_unselected)
	button.mouse_entered.connect(func():
		if not button.has_focus():
			button.grab_focus()
		else:
			_on_selected()
	)
	button.pressed.connect(func():
		item_activated.emit()
	)

	_apply_tier_variation()
	_update_caption()


func _ready() -> void:
	_apply_tier_variation()
	_update_caption()


func setup(p_text: String, p_tier: int = C.MenuTier.SMALL, p_caption: String = "") -> void:
	label_text = p_text
	tier = p_tier
	caption_text = p_caption
	_apply_tier_variation()
	_update_caption()


func grab_item_focus() -> void:
	if is_instance_valid(button):
		button.grab_focus()


func is_item_selected() -> bool:
	return _is_selected


func _get_button_height() -> float:
	match tier:
		C.MenuTier.PRIMARY:
			return 29.0
		C.MenuTier.MEDIUM:
			return 16.0
		C.MenuTier.SMALL:
			return 14.0
		C.MenuTier.MUTED:
			return 13.0
		_:
			return 14.0


func _get_cap_visual_center() -> float:
	match tier:
		C.MenuTier.PRIMARY:
			return 16.0
		C.MenuTier.MEDIUM:
			return 9.0
		C.MenuTier.SMALL:
			return 8.0
		C.MenuTier.MUTED:
			return 7.0
		_:
			return 8.0


func _get_label_internal_offset_x() -> float:
	match tier:
		C.MenuTier.PRIMARY:
			return 9.0
		_:
			return 7.0


func _get_selector_gap() -> int:
	match tier:
		C.MenuTier.PRIMARY:
			return C.SELECTOR_GAP_PRIMARY
		C.MenuTier.MEDIUM:
			return C.SELECTOR_GAP_MEDIUM
		C.MenuTier.SMALL:
			return C.SELECTOR_GAP_SMALL
		C.MenuTier.MUTED:
			return C.SELECTOR_GAP_MUTED
		_:
			return C.SELECTOR_GAP_SMALL


func _apply_tier_variation() -> void:
	if not is_instance_valid(button):
		return
	match tier:
		C.MenuTier.PRIMARY:
			button.theme_type_variation = &"MenuButtonPrimary"
			top_spacer.visible = false
		C.MenuTier.MEDIUM:
			button.theme_type_variation = &"MenuButtonMedium"
			top_spacer.visible = false
		C.MenuTier.SMALL:
			button.theme_type_variation = &"MenuButtonSmall"
			top_spacer.visible = false
		C.MenuTier.MUTED:
			button.theme_type_variation = &"MenuButtonMuted"
			top_spacer.custom_minimum_size = Vector2(0, C.SPACING_QUIT_TOP)
			top_spacer.visible = true

	_update_selector_position()
	_update_layout_sizes()


func _update_selector_position() -> void:
	if not is_instance_valid(crescent_rect):
		return
	# Anchor crescent marker directly to the visual center of the LABEL's cap height
	# (independent of container padding and caption). Snap to integer pixels.
	var crescent_y: int = int(round(_get_cap_visual_center() - 6.0))
	var crescent_x: int = int(round(_get_label_internal_offset_x() - 9.0 - _get_selector_gap()))
	crescent_rect.position = Vector2(crescent_x, crescent_y)


func _update_layout_sizes() -> void:
	if not is_instance_valid(group_container) or not is_instance_valid(item_holder):
		return
	var h: float = _get_button_height()
	if is_instance_valid(caption_label) and caption_label.visible:
		h += float(C.CAPTION_SEPARATION_PX) + 12.0
	item_holder.custom_minimum_size = Vector2(220.0, max(_get_button_height(), h))


func _update_caption() -> void:
	if not is_instance_valid(caption_label):
		return
	caption_label.text = caption_text
	caption_label.visible = not caption_text.strip_edges().is_empty()
	_update_layout_sizes()


func _on_selected() -> void:
	var was_selected := _is_selected
	_is_selected = true
	_anim_accum = 0.0
	_anim_frame = 0
	if is_instance_valid(crescent_rect):
		crescent_rect.texture = _tex_crescent_0
		crescent_rect.modulate.a = 1.0
	if is_instance_valid(group_container):
		# Snappy stepped slide right for the entire group (label + caption together)
		group_container.position.x = C.SLIDE_OFFSET_PX
	if not was_selected:
		item_selected.emit()


func _on_unselected() -> void:
	_is_selected = false
	if is_instance_valid(crescent_rect):
		crescent_rect.modulate.a = 0.0
	if is_instance_valid(group_container):
		group_container.position.x = 0.0


func _process(delta: float) -> void:
	if not _is_selected or not is_instance_valid(crescent_rect):
		return
	_anim_accum += delta
	if _anim_accum >= C.CRESCENT_FRAME_SEC:
		_anim_accum = 0.0
		_anim_frame = 1 - _anim_frame
		crescent_rect.texture = _tex_crescent_1 if _anim_frame == 1 else _tex_crescent_0

class_name HaliyaTitleLockup
extends Control

## HaliyaTitleLockup
## Reusable carved pixel-art title lockup component ("HALIYA" + unified zigzag divider
## with center crescent/spiral ornament + "Mask of Sorrows" subtitle).
## All elements share the exact left edge x=0 (or compact centered header layout on sub-screens).

const C = preload("res://ui/theme/ui_theme_constants.gd")

@export var compact_mode: bool = false:
	set(v):
		compact_mode = v
		_apply_layout_mode()

@export var custom_subtitle: String = "Mask of Sorrows":
	set(v):
		custom_subtitle = v
		if is_instance_valid(subtitle_label):
			subtitle_label.text = custom_subtitle

var title_rect: TextureRect
var title_sprite: TextureRect:
	get:
		return title_rect
var divider_rect: TextureRect
var subtitle_label: Label
var _centered_mode: bool = false


func _init() -> void:
	theme = load(C.PATH_THEME)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	title_rect = TextureRect.new()
	title_rect.name = "TitleHaliyaSprite"
	title_rect.texture = load(C.TEX_TITLE_HALIYA)
	title_rect.stretch_mode = TextureRect.STRETCH_KEEP
	title_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_rect)

	divider_rect = TextureRect.new()
	divider_rect.name = "ZigzagDivider"
	divider_rect.texture = load(C.TEX_DIVIDER_ZIGZAG)
	divider_rect.stretch_mode = TextureRect.STRETCH_KEEP
	divider_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(divider_rect)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.theme_type_variation = &"SubtitleLabel"
	subtitle_label.text = custom_subtitle
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(subtitle_label)

	_apply_layout_mode()


func _apply_layout_mode() -> void:
	if not is_instance_valid(title_rect):
		return
	if compact_mode:
		# Compact sub-screen header crest (shows small HALIYA crest + zigzag divider)
		custom_minimum_size = Vector2(162, 32)
		size = Vector2(162, 32)
		title_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		title_rect.position = Vector2(0, 0)
		title_rect.size = Vector2(162, 20)
		divider_rect.position = Vector2(1, 22)
		divider_rect.size = Vector2(160, 9)
		subtitle_label.visible = false
	else:
		# Full title lockup: Title, Divider, and Subtitle all share left edge x=0
		custom_minimum_size = Vector2(162, 62)
		size = Vector2(162, 62)
		title_rect.stretch_mode = TextureRect.STRETCH_KEEP
		title_rect.position = Vector2(0, 0)
		title_rect.size = Vector2(162, 38)
		divider_rect.position = Vector2(0, 38)
		divider_rect.size = Vector2(160, 9)
		subtitle_label.visible = true
		subtitle_label.position = Vector2(0, 48)
		subtitle_label.size = Vector2(162, 14)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if _centered_mode else HORIZONTAL_ALIGNMENT_LEFT


func set_centered_layout(centered: bool) -> void:
	_centered_mode = centered
	_apply_layout_mode()

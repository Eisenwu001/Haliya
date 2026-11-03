class_name ForegroundFoliage
extends Node2D

## ForegroundFoliage
## ============================================================================
## ORGANIC FOREGROUND FRAMING ART (Incoming Art Integration Pass)
## Holds top-left corner fronds, top-right mirrored fronds, optional central
## hanging canopy leaves, and full-width bottom edge undergrowth.
## All assets reference exported Texture2D properties for instant swappability.
## Features stepped 2-frame subtle sway (frozen if reduce_motion is enabled).
## ============================================================================

const GameSettings = preload("res://scripts/game_settings.gd")

@export var tex_corner_left: Texture2D = preload("res://assets/art/corner_fronds_left.png"):
	set(v):
		tex_corner_left = v
		if is_instance_valid(corner_left_spr):
			corner_left_spr.texture = tex_corner_left

@export var tex_corner_right: Texture2D = preload("res://assets/art/corner_fronds_right.png"):
	set(v):
		tex_corner_right = v
		if is_instance_valid(corner_right_spr):
			corner_right_spr.texture = tex_corner_right

@export var tex_hanging_leaves: Texture2D = preload("res://assets/art/hanging_leaves.png"):
	set(v):
		tex_hanging_leaves = v
		if is_instance_valid(hanging_leaves_spr):
			hanging_leaves_spr.texture = tex_hanging_leaves

@export var tex_bottom_foliage: Texture2D = preload("res://assets/art/bottom_foliage.png"):
	set(v):
		tex_bottom_foliage = v
		if is_instance_valid(bottom_foliage_spr):
			bottom_foliage_spr.texture = tex_bottom_foliage

# Node references
var corner_left_spr: Sprite2D
var corner_right_spr: Sprite2D
var hanging_leaves_spr: Sprite2D
var bottom_foliage_spr: Sprite2D

# Base positions (integer pixels)
var _base_left_pos: Vector2 = Vector2(-20.0, -42.0)
var _base_right_pos: Vector2 = Vector2(526.0, -42.0)
var _base_hanging_pos: Vector2 = Vector2(230.0, -12.0)
var _base_bottom_pos: Vector2 = Vector2(0.0, 306.0)

# Animation state
var _sway_timer: float = 0.0
var _sway_frame: int = 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	setup_foliage_nodes()


func setup_foliage_nodes() -> void:
	# 1. Top-left corner fronds (134x88) - frames upper-left without overlapping title (y=48)
	corner_left_spr = Sprite2D.new()
	corner_left_spr.name = "CornerFrondsLeft"
	corner_left_spr.texture = tex_corner_left
	corner_left_spr.centered = false
	corner_left_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	corner_left_spr.position = _base_left_pos
	add_child(corner_left_spr)

	# 2. Top-right mirrored fronds (134x88) - frames upper-right without touching moon (x=483)
	corner_right_spr = Sprite2D.new()
	corner_right_spr.name = "CornerFrondsRight"
	corner_right_spr.texture = tex_corner_right
	corner_right_spr.centered = false
	corner_right_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	corner_right_spr.position = _base_right_pos
	add_child(corner_right_spr)

	# 3. Central hanging leaves (160x76) - hangs from top edge between title and moon
	hanging_leaves_spr = Sprite2D.new()
	hanging_leaves_spr.name = "HangingLeaves"
	hanging_leaves_spr.texture = tex_hanging_leaves
	hanging_leaves_spr.centered = false
	hanging_leaves_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hanging_leaves_spr.position = _base_hanging_pos
	add_child(hanging_leaves_spr)

	# 4. Bottom edge foliage (640x54) - full width undergrowth, flush with bottom screen edge
	bottom_foliage_spr = Sprite2D.new()
	bottom_foliage_spr.name = "BottomFoliage"
	bottom_foliage_spr.texture = tex_bottom_foliage
	bottom_foliage_spr.centered = false
	bottom_foliage_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bottom_foliage_spr.position = _base_bottom_pos
	add_child(bottom_foliage_spr)


func update_bounds(target_w: float, target_h: float) -> void:
	_base_left_pos = Vector2(-20.0, -42.0)
	_base_right_pos = Vector2(target_w - 114.0, -42.0)
	_base_hanging_pos = Vector2(round(target_w * 0.36), -12.0)
	_base_bottom_pos = Vector2(0.0, target_h - 54.0)

	_apply_frame(_sway_frame)
	if is_instance_valid(bottom_foliage_spr):
		bottom_foliage_spr.position = _base_bottom_pos


func _process(delta: float) -> void:
	if not GameSettings.reduce_motion:
		_sway_timer += delta
		if _sway_timer >= 0.90:
			_sway_timer = 0.0
			_sway_frame = 1 - _sway_frame
			_apply_frame(_sway_frame)
	else:
		if _sway_frame != 0:
			_sway_frame = 0
			_apply_frame(0)


func _apply_frame(frame_idx: int) -> void:
	if frame_idx == 0:
		if is_instance_valid(corner_left_spr):
			corner_left_spr.position = _base_left_pos
			corner_left_spr.rotation = 0.0
		if is_instance_valid(corner_right_spr):
			corner_right_spr.position = _base_right_pos
			corner_right_spr.rotation = 0.0
		if is_instance_valid(hanging_leaves_spr):
			hanging_leaves_spr.position = _base_hanging_pos
	else:
		if is_instance_valid(corner_left_spr):
			corner_left_spr.position = _base_left_pos + Vector2(0.0, 1.0)
			corner_left_spr.rotation = deg_to_rad(0.8)
		if is_instance_valid(corner_right_spr):
			corner_right_spr.position = _base_right_pos + Vector2(0.0, 1.0)
			corner_right_spr.rotation = deg_to_rad(-0.8)
		if is_instance_valid(hanging_leaves_spr):
			hanging_leaves_spr.position = _base_hanging_pos + Vector2(0.0, 1.0)

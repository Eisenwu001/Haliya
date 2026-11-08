class_name LevelProgressBar
extends Control

## LevelProgressBar
## Rebuilt HUD Level Progress Tracker.
## Presentation-only component with procedural 2px line (1px slate/bone core, 1px charcoal outline),
## 10% tick notches (1px taller than line), longer milestone notches, milestone pop animations,
## lit/unlit milestone states, stepped 2-frame flame/tip flicker, and milestone proximity opacity fading.
## Respects GameSettings.reduce_motion (no flicker and no pop).

# ── Exported Texture2D Slots (User art replaceable via Inspector) ─────────────
@export_group("Milestone Icons")
@export var progress_mask_lit: Texture2D = preload("res://assets/ui/progress_mask_lit.png")
@export var progress_mask_unlit: Texture2D = preload("res://assets/ui/progress_mask_unlit.png")
@export var progress_shrine_lit: Texture2D = preload("res://assets/ui/progress_shrine_lit.png")
@export var progress_shrine_unlit: Texture2D = preload("res://assets/ui/progress_shrine_unlit.png")
@export var progress_blades_lit: Texture2D = preload("res://assets/ui/progress_blades_lit.png")
@export var progress_blades_unlit: Texture2D = preload("res://assets/ui/progress_blades_unlit.png")

@export_group("Position Marker")
@export var progress_marker_a: Texture2D = preload("res://assets/ui/progress_marker_a.png")
@export var progress_marker_b: Texture2D = preload("res://assets/ui/progress_marker_b.png")

# Optional frame B for shrine flame flicker
var progress_shrine_lit_b: Texture2D = null

# ── Child Nodes ───────────────────────────────────────────────────────────────
var line_canvas: Control = null
var progress_bar_fill_rect: Control = null # Kept for API compatibility & test assertions
var icon_mask: TextureRect = null
var icon_shrine: TextureRect = null
var icon_blades: TextureRect = null
var marker_rect: TextureRect = null

# ── Tracking State ────────────────────────────────────────────────────────────
var current_ratio: float = 0.0
var checkpoint_ratio: float = 0.707

# Milestones reached state
var has_reached_start: bool = true
var has_reached_checkpoint: bool = false
var has_reached_goal: bool = false

# Hold timer for 100% opacity after reaching a milestone (2.0s)
var milestone_hold_timer: float = 0.0

# 3-Frame Pop Animation state: 1.0x -> 1.25x -> 1.0x
var mask_pop_step: int = 0
var mask_pop_timer: float = 0.0

var shrine_pop_step: int = 0
var shrine_pop_timer: float = 0.0

var blades_pop_step: int = 0
var blades_pop_timer: float = 0.0

const POP_STEP_DURATION: float = 0.06

# Stepped 2-frame flicker timer
var flicker_timer: float = 0.0
var flicker_frame_b: bool = false
const FLICKER_INTERVAL: float = 0.16


func _init() -> void:
	setup_nodes()


func _ready() -> void:
	# Load optional lit frame B if available
	if ResourceLoader.exists("res://assets/ui/progress_shrine_lit_b.png"):
		progress_shrine_lit_b = load("res://assets/ui/progress_shrine_lit_b.png")

	update_icons_state()
	update_marker_position()
	modulate.a = 1.0 # Start visible at spawn


func setup_nodes() -> void:
	if is_instance_valid(line_canvas):
		return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.0
	anchor_bottom = 0.0

	var half_w = UIThemeConstants.HUD_PROGRESS_LINE_WIDTH * 0.5
	offset_left = -half_w
	offset_right = half_w
	offset_top = UIThemeConstants.HUD_PROGRESS_ROOT_POS_Y
	offset_bottom = UIThemeConstants.HUD_PROGRESS_ROOT_POS_Y + 16.0

	# 1. Procedural Line Drawing Canvas
	line_canvas = Control.new()
	line_canvas.name = "LineCanvas"
	line_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	line_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_canvas.draw.connect(_on_line_canvas_draw)
	add_child(line_canvas)

	# Invisible tracking rect for API compatibility (test_enhanced_features.gd)
	progress_bar_fill_rect = Control.new()
	progress_bar_fill_rect.name = "TrackFillCompat"
	progress_bar_fill_rect.position = Vector2(0, UIThemeConstants.HUD_PROGRESS_LINE_OFFSET_Y)
	progress_bar_fill_rect.size = Vector2(0, UIThemeConstants.HUD_PROGRESS_LINE_HEIGHT)
	progress_bar_fill_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(progress_bar_fill_rect)

	# 2. Milestone Icons (12x12, centered on milestones, bottom edge touches notches)
	# Icon size: 12x12
	var icon_size = UIThemeConstants.HUD_PROGRESS_ICON_SIZE
	var half_icon = icon_size.x * 0.5

	# Mask at Start (0%)
	icon_mask = TextureRect.new()
	icon_mask.name = "IconMask"
	icon_mask.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_mask.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_mask.size = icon_size
	icon_mask.pivot_offset = icon_size * 0.5
	icon_mask.position = Vector2(-half_icon, 0.0)
	icon_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_mask)

	# Shrine Lantern at Checkpoint
	var cp_x = roundi(checkpoint_ratio * UIThemeConstants.HUD_PROGRESS_LINE_WIDTH)
	icon_shrine = TextureRect.new()
	icon_shrine.name = "IconShrine"
	icon_shrine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_shrine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_shrine.size = icon_size
	icon_shrine.pivot_offset = icon_size * 0.5
	icon_shrine.position = Vector2(cp_x - half_icon, 0.0)
	icon_shrine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_shrine)

	# Crossed Blades at Goal (100%)
	var goal_x = roundi(UIThemeConstants.HUD_PROGRESS_LINE_WIDTH)
	icon_blades = TextureRect.new()
	icon_blades.name = "IconBlades"
	icon_blades.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_blades.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_blades.size = icon_size
	icon_blades.pivot_offset = icon_size * 0.5
	icon_blades.position = Vector2(goal_x - half_icon, 0.0)
	icon_blades.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_blades)

	# 3. Position Marker (5x7px Teal Spirit Wisp)
	var marker_size = UIThemeConstants.HUD_PROGRESS_MARKER_SIZE
	marker_rect = TextureRect.new()
	marker_rect.name = "MarkerRect"
	marker_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marker_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	marker_rect.size = marker_size
	marker_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Center horizontally on x=0, bottom rests right on line (y = line_offset - marker_h + 1)
	marker_rect.position = Vector2(-roundi(marker_size.x * 0.5), UIThemeConstants.HUD_PROGRESS_LINE_OFFSET_Y - marker_size.y + 1.0)
	marker_rect.texture = progress_marker_a
	add_child(marker_rect)


func _process(delta: float) -> void:
	var reduce_motion = GameSettings.reduce_motion

	# 1. Update 2-frame stepped flicker
	flicker_timer += delta
	if flicker_timer >= FLICKER_INTERVAL:
		flicker_timer = 0.0
		flicker_frame_b = not flicker_frame_b
		_update_flicker_textures(reduce_motion)

	# 2. Update Milestone Pop Animations
	_process_pop_animations(delta, reduce_motion)

	# 3. Milestone Proximity Opacity Fading
	_process_proximity_fade(delta)


func _update_flicker_textures(reduce_motion: bool) -> void:
	# Marker tip flicker
	if is_instance_valid(marker_rect):
		if reduce_motion or not flicker_frame_b:
			marker_rect.texture = progress_marker_a
		else:
			marker_rect.texture = progress_marker_b

	# Lit Shrine flame flicker
	if is_instance_valid(icon_shrine) and has_reached_checkpoint:
		if reduce_motion or not flicker_frame_b or progress_shrine_lit_b == null:
			icon_shrine.texture = progress_shrine_lit
		else:
			icon_shrine.texture = progress_shrine_lit_b


func _process_pop_animations(delta: float, reduce_motion: bool) -> void:
	# Checkpoint pop
	if shrine_pop_step > 0 and is_instance_valid(icon_shrine):
		if reduce_motion:
			shrine_pop_step = 0
			icon_shrine.scale = Vector2.ONE
		else:
			shrine_pop_timer += delta
			if shrine_pop_timer >= POP_STEP_DURATION:
				shrine_pop_timer = 0.0
				shrine_pop_step += 1
				if shrine_pop_step == 2:
					icon_shrine.scale = Vector2(UIThemeConstants.HUD_PROGRESS_POP_SCALE, UIThemeConstants.HUD_PROGRESS_POP_SCALE)
				else:
					shrine_pop_step = 0
					icon_shrine.scale = Vector2.ONE

	# Blades pop
	if blades_pop_step > 0 and is_instance_valid(icon_blades):
		if reduce_motion:
			blades_pop_step = 0
			icon_blades.scale = Vector2.ONE
		else:
			blades_pop_timer += delta
			if blades_pop_timer >= POP_STEP_DURATION:
				blades_pop_timer = 0.0
				blades_pop_step += 1
				if blades_pop_step == 2:
					icon_blades.scale = Vector2(UIThemeConstants.HUD_PROGRESS_POP_SCALE, UIThemeConstants.HUD_PROGRESS_POP_SCALE)
				else:
					blades_pop_step = 0
					icon_blades.scale = Vector2.ONE


func _process_proximity_fade(delta: float) -> void:
	if milestone_hold_timer > 0.0:
		milestone_hold_timer = maxf(0.0, milestone_hold_timer - delta)

	var dist_start = absf(current_ratio - 0.0)
	var dist_checkpoint = absf(current_ratio - checkpoint_ratio)
	var dist_goal = absf(current_ratio - 1.0)

	var is_near = (dist_start <= UIThemeConstants.HUD_PROGRESS_PROXIMITY_THRESHOLD or
				   dist_checkpoint <= UIThemeConstants.HUD_PROGRESS_PROXIMITY_THRESHOLD or
				   dist_goal <= UIThemeConstants.HUD_PROGRESS_PROXIMITY_THRESHOLD)

	var target_alpha: float = 1.0 if (is_near or milestone_hold_timer > 0.0) else UIThemeConstants.HUD_PROGRESS_FADED_ALPHA
	modulate.a = move_toward(modulate.a, target_alpha, delta * 4.0)


## Public API called by MainScript
func update_progress(ratio: float, cp_ratio: float = 0.707) -> void:
	var prev_ratio = current_ratio
	current_ratio = clampf(ratio, 0.0, 1.0)
	checkpoint_ratio = clampf(cp_ratio, 0.05, 0.95)

	# Checkpoint milestone reached trigger
	if current_ratio >= checkpoint_ratio:
		if not has_reached_checkpoint:
			has_reached_checkpoint = true
			milestone_hold_timer = UIThemeConstants.HUD_PROGRESS_HOLD_DURATION_SEC
			if not GameSettings.reduce_motion:
				shrine_pop_step = 1
				shrine_pop_timer = 0.0
				if is_instance_valid(icon_shrine):
					icon_shrine.scale = Vector2(UIThemeConstants.HUD_PROGRESS_POP_SCALE, UIThemeConstants.HUD_PROGRESS_POP_SCALE)
	else:
		has_reached_checkpoint = false

	# Goal milestone reached trigger
	if current_ratio >= 1.0:
		if not has_reached_goal:
			has_reached_goal = true
			milestone_hold_timer = UIThemeConstants.HUD_PROGRESS_HOLD_DURATION_SEC
			if not GameSettings.reduce_motion:
				blades_pop_step = 1
				blades_pop_timer = 0.0
				if is_instance_valid(icon_blades):
					icon_blades.scale = Vector2(UIThemeConstants.HUD_PROGRESS_POP_SCALE, UIThemeConstants.HUD_PROGRESS_POP_SCALE)
	else:
		has_reached_goal = false

	update_icons_state()
	update_marker_position()

	# Keep compat rect size updated
	if is_instance_valid(progress_bar_fill_rect):
		progress_bar_fill_rect.size.x = current_ratio * UIThemeConstants.HUD_PROGRESS_LINE_WIDTH

	# Request redraw of procedural line
	if is_instance_valid(line_canvas):
		line_canvas.queue_redraw()


func update_icons_state() -> void:
	# 1. Mask is lit once reached (starts at 0.0, always lit)
	if is_instance_valid(icon_mask):
		icon_mask.texture = progress_mask_lit if has_reached_start else progress_mask_unlit

	# 2. Shrine is lit when reached
	if is_instance_valid(icon_shrine):
		var cp_x = roundi(checkpoint_ratio * UIThemeConstants.HUD_PROGRESS_LINE_WIDTH)
		icon_shrine.position.x = cp_x - roundi(UIThemeConstants.HUD_PROGRESS_ICON_SIZE.x * 0.5)
		if has_reached_checkpoint:
			if not GameSettings.reduce_motion and flicker_frame_b and progress_shrine_lit_b != null:
				icon_shrine.texture = progress_shrine_lit_b
			else:
				icon_shrine.texture = progress_shrine_lit
		else:
			icon_shrine.texture = progress_shrine_unlit

	# 3. Blades are lit when reached
	if is_instance_valid(icon_blades):
		var goal_x = roundi(UIThemeConstants.HUD_PROGRESS_LINE_WIDTH)
		icon_blades.position.x = goal_x - roundi(UIThemeConstants.HUD_PROGRESS_ICON_SIZE.x * 0.5)
		icon_blades.texture = progress_blades_lit if has_reached_goal else progress_blades_unlit


func update_marker_position() -> void:
	if not is_instance_valid(marker_rect):
		return
	var lw = UIThemeConstants.HUD_PROGRESS_LINE_WIDTH
	var marker_x: int = clampi(roundi(current_ratio * lw), 0, roundi(lw))
	var half_marker_w: int = roundi(UIThemeConstants.HUD_PROGRESS_MARKER_SIZE.x * 0.5)
	marker_rect.position.x = marker_x - half_marker_w


## Procedural Line Drawing
func _on_line_canvas_draw() -> void:
	var lw: float = UIThemeConstants.HUD_PROGRESS_LINE_WIDTH
	var ly: float = UIThemeConstants.HUD_PROGRESS_LINE_OFFSET_Y
	var filled_px: int = clampi(roundi(current_ratio * lw), 0, roundi(lw))

	var color_charcoal := UIThemeConstants.COLOR_CHARCOAL_DEEP
	var color_slate := UIThemeConstants.COLOR_SLATE_BLUE
	var color_bone := UIThemeConstants.COLOR_BONE_CREAM

	# 1. Base 2px Line (Snapped to Whole Pixels)
	# Row 0 (core): bone cream for traveled portion, slate for untraveled
	if filled_px > 0:
		line_canvas.draw_rect(Rect2(0.0, ly, float(filled_px), 1.0), color_bone)
	if filled_px < roundi(lw):
		line_canvas.draw_rect(Rect2(float(filled_px), ly, lw - float(filled_px), 1.0), color_slate)

	# Row 1 (outline): 1px charcoal outline along the entire bottom of the line
	line_canvas.draw_rect(Rect2(0.0, ly + 1.0, lw, 1.0), color_charcoal)

	# Left & right end cap outlines
	line_canvas.draw_rect(Rect2(-1.0, ly, 1.0, 2.0), color_charcoal)
	line_canvas.draw_rect(Rect2(lw, ly, 1.0, 2.0), color_charcoal)

	# 2. Tick Notches Every 10%
	# "Tick notches every 10%, 1px taller than the line. Longer notches at the three milestones."
	# Line is 2px tall. 1px taller than line = 3px tall (ly to ly + 2).
	var cp_px: int = roundi(checkpoint_ratio * lw)

	for i in range(11):
		var tick_x: int = roundi(i * 0.10 * lw)
		var is_milestone: bool = (i == 0 or i == 10)
		if not is_milestone and absi(tick_x - cp_px) > 2:
			# Regular 10% notch: 3px tall (ly to ly + 2)
			var is_traveled: bool = (tick_x <= filled_px)
			var core_c: Color = color_bone if is_traveled else color_slate
			line_canvas.draw_rect(Rect2(float(tick_x), ly, 1.0, 1.0), core_c)
			line_canvas.draw_rect(Rect2(float(tick_x), ly + 1.0, 1.0, 2.0), color_charcoal)

	# 3. Longer Notches at the Three Milestones (5px tall: ly - 2 to ly + 2)
	# Connects the 12px milestone icon bottom (at y = 11) to the 2px line (at y = 13..14) and notches below (y = 15)

	# Start Milestone (0%)
	line_canvas.draw_rect(Rect2(0.0, ly - 2.0, 1.0, 5.0), color_charcoal)
	line_canvas.draw_rect(Rect2(0.0, ly, 1.0, 1.0), color_bone)

	# Checkpoint Milestone (cp_px)
	line_canvas.draw_rect(Rect2(float(cp_px), ly - 2.0, 1.0, 5.0), color_charcoal)
	var cp_core: Color = color_bone if filled_px >= cp_px else color_slate
	line_canvas.draw_rect(Rect2(float(cp_px), ly, 1.0, 1.0), cp_core)

	# Goal Milestone (roundi(lw))
	var goal_x = float(roundi(lw))
	line_canvas.draw_rect(Rect2(goal_x, ly - 2.0, 1.0, 5.0), color_charcoal)
	var goal_core: Color = color_bone if filled_px >= roundi(lw) else color_slate
	line_canvas.draw_rect(Rect2(goal_x, ly, 1.0, 1.0), goal_core)

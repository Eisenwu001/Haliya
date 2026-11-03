class_name TotemSurround
extends Node2D

## TotemSurround
## ============================================================================
## UNIFIED SACRED TOTEM & SHRINE HERO PIECE (Totem Swap Pass)
## Wraps the complete sacred Haliya totem, stone altar base, roots, clay lamps,
## and offerings (totem_shrine.png) into a single unified parent node.
## Includes moonlight halo re-centered behind the face, subtle ground patch,
## dithered contact shadow, center flame 2-frame flicker, base mist, and fireflies.
## ============================================================================

const C = preload("res://ui/theme/ui_theme_constants.gd")
const GameSettings = preload("res://scripts/game_settings.gd")

@export var tex_totem: Texture2D = preload("res://assets/art/totem_shrine.png"):
	set(v):
		tex_totem = v
		if is_instance_valid(totem_spr):
			totem_spr.texture = tex_totem

@export var tex_flame_0: Texture2D = preload("res://assets/art/center_flame_flicker_0.png")
@export var tex_flame_1: Texture2D = preload("res://assets/art/center_flame_flicker_1.png")
@export var tex_base_mist: Texture2D = preload("res://assets/ui/menu_mist_band_1.png")

# Node references
var ground_patch_spr: Sprite2D
var ground_shadow: Sprite2D
var teal_halo_spr: Sprite2D
var totem_spr: Sprite2D
var flame_center_spr: Sprite2D
var flame_glow_spr: Sprite2D
var base_mist_spr1: Sprite2D
var fireflies_container: Node2D

# Animation state
var _flame_timer: float = 0.0
var _flame_frame: int = 0
var _mist_x: float = 0.0

# Orbiting fireflies state
var fireflies: Array[Dictionary] = []


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	setup_totem_group()


func setup_totem_group() -> void:
	# 1. Subtle lighter ground patch behind the base so it sits on the ground
	ground_patch_spr = Sprite2D.new()
	ground_patch_spr.name = "GroundPatch"
	ground_patch_spr.texture = _create_ellipse_texture(88, 16, Color(0.24, 0.32, 0.28, 0.22), Color(0.18, 0.24, 0.22, 0.0))
	ground_patch_spr.position = Vector2(0.0, 106.0)
	ground_patch_spr.z_index = -1
	add_child(ground_patch_spr)

	# 2. Moonlight Halo re-centered behind the sacred mask face (local face center y = -74.0)
	teal_halo_spr = Sprite2D.new()
	teal_halo_spr.name = "TealTotemHalo"
	teal_halo_spr.texture = _create_radial_glow(75, Color(0.35, 0.52, 0.48, 0.24), Color(0.18, 0.32, 0.30, 0.0))
	teal_halo_spr.position = Vector2(-2.0, -74.0)
	teal_halo_spr.z_index = -1
	add_child(teal_halo_spr)

	# 3. Soft dithered contact shadow under the base
	ground_shadow = Sprite2D.new()
	ground_shadow.name = "GroundShadow"
	ground_shadow.texture = _create_ellipse_texture(84, 12, Color(0.06, 0.08, 0.07, 0.90), Color(0.06, 0.08, 0.07, 0.0))
	ground_shadow.position = Vector2(0.0, 114.0)
	ground_shadow.z_index = 0
	add_child(ground_shadow)

	# 4. Unified Sacred Totem Sprite (169x226: totem + stone altar + roots + offerings in one image)
	totem_spr = Sprite2D.new()
	totem_spr.name = "TotemSprite"
	totem_spr.texture = tex_totem
	totem_spr.centered = true
	totem_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	totem_spr.position = Vector2.ZERO
	totem_spr.z_index = 1
	add_child(totem_spr)

	# 5. Warm Gold Glow around the center lit candle
	flame_glow_spr = Sprite2D.new()
	flame_glow_spr.name = "FlameGlow"
	flame_glow_spr.texture = _create_ellipse_texture(24, 10, Color(0.92, 0.78, 0.44, 0.25), Color(0.85, 0.70, 0.35, 0.0))
	flame_glow_spr.position = Vector2(2.0, 72.0)
	flame_glow_spr.z_index = 2
	add_child(flame_glow_spr)

	# 6. Center Candle Flame: small 2-frame flicker overlay (1px height variation)
	flame_center_spr = Sprite2D.new()
	flame_center_spr.name = "FlameCenterFlicker"
	flame_center_spr.texture = tex_flame_0
	flame_center_spr.centered = true
	flame_center_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flame_center_spr.position = Vector2(2.0, 71.0)
	flame_center_spr.z_index = 3
	add_child(flame_center_spr)

	# 7. Soft dithered base mist
	if tex_base_mist:
		base_mist_spr1 = Sprite2D.new()
		base_mist_spr1.name = "BaseMist1"
		base_mist_spr1.texture = tex_base_mist
		base_mist_spr1.centered = false
		base_mist_spr1.modulate.a = 0.20
		base_mist_spr1.position = Vector2(-90.0, 96.0)
		base_mist_spr1.scale = Vector2(0.6, 0.6)
		base_mist_spr1.z_index = 2
		add_child(base_mist_spr1)

	# 8. Orbiting Fireflies (8 fireflies loosely orbiting around totem column)
	fireflies_container = Node2D.new()
	fireflies_container.name = "TotemFireflies"
	fireflies_container.z_index = 2
	add_child(fireflies_container)

	_setup_orbiting_fireflies()


func _setup_orbiting_fireflies() -> void:
	fireflies.clear()
	var rng = RandomNumberGenerator.new()
	rng.seed = 20261103

	var tex_px1 = _create_pixel_dot(1)
	var tex_px2 = _create_pixel_dot(2)

	for i in range(8):
		var spr = Sprite2D.new()
		spr.texture = tex_px1 if (i % 2 == 0) else tex_px2
		spr.centered = true
		spr.modulate = Color(0.88, 0.85, 0.70, 0.65)
		fireflies_container.add_child(spr)

		fireflies.append({
			"spr": spr,
			"radius_x": rng.randf_range(34.0, 68.0),
			"radius_y": rng.randf_range(22.0, 48.0),
			"center_y": rng.randf_range(-60.0, 30.0),
			"angle": rng.randf_range(0.0, TAU),
			"speed": rng.randf_range(0.35, 0.75) * (-1.0 if (i % 2 == 0) else 1.0),
			"twinkle_time": rng.randf_range(0.0, 1.0),
			"tex1": tex_px1,
			"tex2": tex_px2
		})


func _process(delta: float) -> void:
	# 1. Flame 2-frame flicker on center candle (frozen if reduce_motion is true)
	if not GameSettings.reduce_motion:
		_flame_timer += delta
		if _flame_timer >= 0.14:
			_flame_timer = 0.0
			_flame_frame = 1 - _flame_frame
			if is_instance_valid(flame_center_spr):
				flame_center_spr.texture = tex_flame_0 if _flame_frame == 0 else tex_flame_1
	else:
		if _flame_frame != 0:
			_flame_frame = 0
			if is_instance_valid(flame_center_spr):
				flame_center_spr.texture = tex_flame_0

	# 2. Base mist slow drift (frozen if reduce_motion is true)
	if is_instance_valid(base_mist_spr1):
		if not GameSettings.reduce_motion:
			_mist_x += 2.0 * delta
			if _mist_x > 60.0:
				_mist_x = -60.0
		base_mist_spr1.position.x = -100.0 + _mist_x

	# 3. Orbiting fireflies (twinkle and orbit around totem)
	for ff in fireflies:
		var spr: Sprite2D = ff["spr"]
		var speed: float = ff["speed"]
		ff["angle"] = fmod(ff["angle"] + speed * delta, TAU)
		var ax: float = cos(ff["angle"]) * ff["radius_x"]
		var ay: float = ff["center_y"] + sin(ff["angle"]) * ff["radius_y"]
		spr.position = Vector2(round(ax), round(ay))

		ff["twinkle_time"] += delta
		if ff["twinkle_time"] >= 0.28:
			ff["twinkle_time"] = 0.0
			spr.texture = ff["tex2"] if spr.texture == ff["tex1"] else ff["tex1"]


static func _create_radial_glow(radius: int, inner_col: Color, outer_col: Color) -> GradientTexture2D:
	var g := GradientTexture2D.new()
	g.width = radius * 2
	g.height = radius * 2
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([inner_col, outer_col])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	g.gradient = grad
	return g


static func _create_ellipse_texture(w: int, h: int, inner_col: Color, outer_col: Color) -> GradientTexture2D:
	var g := GradientTexture2D.new()
	g.width = w * 2
	g.height = h * 2
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([inner_col, outer_col])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	g.gradient = grad
	return g


static func _create_pixel_dot(size: int) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.88, 0.85, 0.70, 1.0))
	return ImageTexture.create_from_image(img)

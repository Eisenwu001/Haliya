class_name HeroProp
extends Node2D

## HeroProp
## ============================================================================
## SWAPPABLE HERO TOTEM PROP WRAPPER (Polish Pass 2 & 3)
## Wraps the sacred Haliya Totem artwork, its dithered lunar halo, ambient
## glow, and carving pulse shader into a self-contained, swappable scene.
##
## HOW TO SWAP THE TOTEM ARTWORK:
## 1. In the Godot Inspector:
##    Select the HeroProp node and assign a new Texture2D to "Prop Texture".
## 2. In GDScript:
##    hero_prop.prop_texture = load("res://path/to/new_artwork.png")
##    Or change the default preload path on the @export var prop_texture below.
## 3. Position and scale can be tuned via the exported "prop_scale_multiplier"
##    and standard Node2D position/scale properties.
## ============================================================================

const C = preload("res://ui/theme/ui_theme_constants.gd")
const GameSettings = preload("res://scripts/game_settings.gd")
const CarvingShader = preload("res://shaders/totem_carvings_pulse.gdshader")

@export var prop_texture: Texture2D = preload("res://assets/bahay_kubo/totem_haliya.png"):
	set(v):
		prop_texture = v
		if is_instance_valid(totem_spr):
			totem_spr.texture = prop_texture

@export var halo_texture: Texture2D = preload("res://assets/ui/totem_halo_dithered.png"):
	set(v):
		halo_texture = v
		if is_instance_valid(halo_spr):
			halo_spr.texture = halo_texture

@export var halo_visible: bool = true:
	set(v):
		halo_visible = v
		if is_instance_valid(halo_spr):
			halo_spr.visible = halo_visible

@export var glow_visible: bool = true:
	set(v):
		glow_visible = v
		if is_instance_valid(altar_glow):
			altar_glow.visible = glow_visible

# Convenience getter/setter so existing code referencing altar_spr.texture works transparently
var texture: Texture2D:
	get:
		return prop_texture
	set(v):
		prop_texture = v

var halo_spr: Sprite2D
var totem_spr: Sprite2D
var altar_glow: Sprite2D
var glow_tween: Tween
var carving_mat: ShaderMaterial


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	setup_nodes()


func setup_nodes() -> void:
	if not is_instance_valid(halo_spr):
		halo_spr = Sprite2D.new()
		halo_spr.name = "TotemHalo"
		halo_spr.texture = halo_texture
		halo_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		# Positioned behind the totem crown and mask, offset slightly up
		halo_spr.position = Vector2(0.0, -120.0)
		halo_spr.scale = Vector2(2.4, 2.4)
		halo_spr.modulate = Color(1.0, 1.0, 1.0, 0.50)
		halo_spr.visible = halo_visible
		halo_spr.z_index = -1
		add_child(halo_spr)

	if not is_instance_valid(totem_spr):
		totem_spr = Sprite2D.new()
		totem_spr.name = "TotemSprite"
		totem_spr.texture = prop_texture
		totem_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		totem_spr.centered = true
		totem_spr.position = Vector2.ZERO
		totem_spr.z_index = 0

		# Apply slow subtle teal pulse shader to totem carvings (Pass 3 & 4)
		carving_mat = ShaderMaterial.new()
		carving_mat.shader = CarvingShader
		carving_mat.set_shader_parameter("reduce_motion", GameSettings.reduce_motion)
		totem_spr.material = carving_mat

		add_child(totem_spr)

	if not is_instance_valid(altar_glow):
		altar_glow = Sprite2D.new()
		altar_glow.name = "AltarGlow"
		altar_glow.texture = _create_glow_texture(80, Color(0.88, 0.85, 0.74, 0.22), Color(0.80, 0.76, 0.64, 0.0))
		altar_glow.position = Vector2(0.0, -337.5)
		altar_glow.visible = glow_visible
		altar_glow.z_index = 1
		totem_spr.add_child(altar_glow)

		glow_tween = create_tween().set_loops()
		glow_tween.tween_property(altar_glow, "modulate:a", 0.22, 2.5).set_trans(Tween.TRANS_SINE)
		glow_tween.tween_property(altar_glow, "modulate:a", 0.10, 2.5).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	if is_instance_valid(carving_mat):
		carving_mat.set_shader_parameter("reduce_motion", GameSettings.reduce_motion)


static func _create_glow_texture(radius: int, inner_color: Color, outer_color: Color) -> GradientTexture2D:
	var glow_tex := GradientTexture2D.new()
	glow_tex.width = radius * 2
	glow_tex.height = radius * 2
	glow_tex.fill = GradientTexture2D.FILL_RADIAL
	glow_tex.fill_from = Vector2(0.5, 0.5)
	glow_tex.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([inner_color, outer_color])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	glow_tex.gradient = grad
	return glow_tex

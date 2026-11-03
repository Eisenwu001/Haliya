class_name CaveCrystalLight
extends Node2D

const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")

enum Kind {
	CRYSTAL_CLUSTER = 0,
	LUMINESCENT_FUNGI = 1,
	CRYSTAL_SPIRE = 2,
	CRYSTAL_CLUSTER_AMETHYST = 3
}

@export var kind: Kind = Kind.CRYSTAL_CLUSTER
@export var light_color: Color = Color(0.35, 0.90, 1.0, 1.0)
@export var base_energy: float = 0.85
@export var light_scale: float = 0.65

var sprite: Sprite2D
var light: PointLight2D
var motes: CPUParticles2D
var anim_timer: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 0

	var props_tex = CaveAssetsScript.get_props_tex()
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = props_tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true

	match kind:
		Kind.CRYSTAL_CLUSTER, Kind.CRYSTAL_SPIRE:
			# Philippine Bamboo Torch (Sulo)
			sprite.region_rect = Rect2(0, 64, 32, 64)
			sprite.position = Vector2(0.0, -29.0)
		Kind.LUMINESCENT_FUNGI:
			# Subterranean River Ferns (Pako)
			sprite.region_rect = Rect2(128, 0, 64, 64)
			sprite.position = Vector2(0.0, -28.0)
		Kind.CRYSTAL_CLUSTER_AMETHYST:
			# Carved Wooden Anito / Moon Totem
			sprite.region_rect = Rect2(64, 0, 64, 96)
			sprite.position = Vector2(0.0, -47.0)

	add_child(sprite)

	# Atmospheric PointLight2D
	light = PointLight2D.new()
	light.name = "PointLight2D"
	light.texture = LIGHT_TEX
	light.texture_scale = min(light_scale, 0.45)
	var is_torch = (kind == Kind.CRYSTAL_CLUSTER or kind == Kind.CRYSTAL_SPIRE)
	light.color = Color(1.0, 0.78, 0.45, 1.0) if is_torch else light_color
	light.energy = min(base_energy, 0.85)
	light.position = sprite.position + (Vector2(0.0, -18.0) if is_torch else Vector2(0.0, 4.0))
	add_child(light)

	# Subtle ambient embers / firefly motes
	motes = CPUParticles2D.new()
	motes.name = "LumaMotes"
	motes.position = light.position
	motes.amount = 4
	motes.lifetime = 1.4
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(6.0, 4.0)
	motes.direction = Vector2(0.0, -1.0)
	motes.spread = 25.0
	motes.gravity = Vector2(0.0, -15.0)
	motes.initial_velocity_min = 6.0
	motes.initial_velocity_max = 18.0
	motes.scale_amount_min = 1.2
	motes.scale_amount_max = 2.4
	motes.color = Color(1.0, 0.82, 0.45, 0.85) if is_torch else Color(light_color.r * 1.1, light_color.g * 1.1, light_color.b * 1.1, 0.65)
	add_child(motes)


func _process(delta: float) -> void:
	anim_timer += delta * 2.0
	if is_instance_valid(light):
		light.energy = base_energy + sin(anim_timer) * 0.08 + sin(anim_timer * 2.4) * 0.04

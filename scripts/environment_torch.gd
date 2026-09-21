class_name EnvironmentTorch
extends Node2D

enum Type {
	TORCH,
	LANTERN
}

@export var torch_type: Type = Type.TORCH
@export var light_energy: float = 1.15
@export var light_scale: float = 0.22

const TORCH_TEX = preload("res://assets/platform_assets/Torch.png")
const LANTERN_TEX = preload("res://assets/bahay_kubo/prop_lantern_small.png")
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")

var sprite: Sprite2D
var light: PointLight2D
var embers_ref: CPUParticles2D
var is_stormy: bool = false
var anim_timer: float = 0.0
var cur_frame: int = 0
# Row 1 of Torch.png contains 6 burning torch frames (indices 6 to 11 in 6x4 grid)
const TORCH_FRAMES = [6, 7, 8, 9, 10, 11]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 1
	
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")
		light = get_node_or_null("PointLight2D")
		return
	
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if torch_type == Type.TORCH:
		sprite.texture = TORCH_TEX
		sprite.hframes = 6
		sprite.vframes = 4
		sprite.frame = TORCH_FRAMES[0]
		sprite.position = Vector2(0, -16)
	else:
		sprite.texture = LANTERN_TEX
		sprite.scale = Vector2(0.45, 0.45)
		sprite.position = Vector2(0, -22)
	
	add_child(sprite)
	
	# PointLight2D
	light = PointLight2D.new()
	light.name = "PointLight2D"
	light.texture = LIGHT_TEX
	light.texture_scale = light_scale
	light.color = Color(1.0, 0.78, 0.48, 1.0) if torch_type == Type.TORCH else Color(1.0, 0.70, 0.38, 1.0)
	light.energy = light_energy
	light.position = Vector2(0, -20 if torch_type == Type.TORCH else -18)
	add_child(light)
	
	# Floating embers
	var embers := CPUParticles2D.new()
	embers.name = "Embers"
	embers.emitting = true
	embers.amount = 10 if is_stormy else 6
	embers.lifetime = 1.0
	embers.direction = Vector2(-0.8, -1.0) if is_stormy else Vector2(0, -1)
	embers.spread = 35.0 if is_stormy else 25.0
	embers.initial_velocity_min = 20.0 if is_stormy else 15.0
	embers.initial_velocity_max = 45.0 if is_stormy else 35.0
	embers.gravity = Vector2(-40.0, -15.0) if is_stormy else Vector2(0, -20.0) # Wind drift in storm
	embers.scale_amount_min = 1.5
	embers.scale_amount_max = 2.5
	embers.color = Color(1.0, 0.65, 0.2, 0.8)
	embers.position = light.position
	add_child(embers)
	embers_ref = embers

func set_storm_mode(stormy: bool) -> void:
	is_stormy = stormy
	if embers_ref:
		embers_ref.amount = 10 if is_stormy else 6
		embers_ref.direction = Vector2(-0.8, -1.0) if is_stormy else Vector2(0, -1)
		embers_ref.gravity = Vector2(-40.0, -15.0) if is_stormy else Vector2(0, -20.0)

func _process(delta: float) -> void:
	# Flame frame cycle
	if torch_type == Type.TORCH:
		anim_timer += delta
		if anim_timer >= 0.10:
			anim_timer -= 0.10
			cur_frame = (cur_frame + 1) % TORCH_FRAMES.size()
			sprite.frame = TORCH_FRAMES[cur_frame]
	
	# Soft organic flame flicker with storm wind sputter
	if light:
		var t = Time.get_ticks_msec() / 1000.0
		if is_stormy:
			var flicker: float = sin(t * 14.0) * 0.16 + sin(t * 28.0) * 0.10 + (randf() - 0.5) * 0.08
			light.energy = clamp(light_energy + flicker, 0.70, 1.75)
		else:
			var flicker: float = sin(t * 12.0) * 0.08 + sin(t * 26.0) * 0.05 + (randf() - 0.5) * 0.03
			light.energy = clamp(light_energy + flicker, 0.85, 1.5)

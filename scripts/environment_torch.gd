class_name EnvironmentTorch
extends Node2D

enum Type {
	TORCH,
	LANTERN
}

@export var torch_type: Type = Type.TORCH
@export var light_energy: float = 0.95
@export var light_scale: float = 0.24
@export var flame_color: Color = Color(1.0, 0.78, 0.48, 1.0)
@export var light_color: Color = Color(1.0, 0.78, 0.48, 1.0)
@export var base_energy: float = 0.85
@export var light_radius: float = 185.0

const TORCH_TEX = preload("res://assets/platform_assets/Torch.png")
const LANTERN_TEX = preload("res://assets/bahay_kubo/prop_lantern_small.png")
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")
const CaveAssetsScript = preload("res://scripts/cave_assets.gd")

var sprite: Sprite2D
var pedestal_sprite: Sprite2D
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
	
	var is_cave_custom: bool = (flame_color != Color(1.0, 0.78, 0.48, 1.0) or light_color != Color(1.0, 0.78, 0.48, 1.0))
	sprite.texture = TORCH_TEX
	sprite.hframes = 6
	sprite.vframes = 4
	sprite.frame = TORCH_FRAMES[0]
	sprite.position = Vector2(0, -32 if is_cave_custom else -16)
	
	# Tint torch flame gently toward custom flame_color if non-default
	if flame_color != Color(1.0, 0.78, 0.48, 1.0):
		sprite.modulate = Color(
			clampf(0.55 + flame_color.r * 0.65, 0.4, 1.35),
			clampf(0.55 + flame_color.g * 0.65, 0.4, 1.35),
			clampf(0.55 + flame_color.b * 0.65, 0.4, 1.35),
			1.0
		)
	add_child(sprite)
	
	if is_cave_custom:
		_ensure_cave_pedestal()
	
	if base_energy > 0.0 and base_energy != 0.85:
		light_energy = base_energy
	
	# PointLight2D
	light = PointLight2D.new()
	light.name = "PointLight2D"
	light.texture = LIGHT_TEX
	light.texture_scale = light_scale
	light.color = light_color if light_color != Color(1.0, 0.78, 0.48, 1.0) else (Color(1.0, 0.78, 0.48, 1.0) if torch_type == Type.TORCH else Color(1.0, 0.70, 0.38, 1.0))
	light.energy = light_energy
	light.position = Vector2(0, -36 if (torch_type == Type.TORCH and is_cave_custom) else (-20 if torch_type == Type.TORCH else -18))
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
	embers.color = Color(flame_color.r, flame_color.g, flame_color.b, 0.82)
	embers.position = light.position
	add_child(embers)
	embers_ref = embers

func _ensure_cave_pedestal() -> void:
	if pedestal_sprite and is_instance_valid(pedestal_sprite):
		return
	var props_tex = CaveAssetsScript.get_props_tex()
	if not props_tex:
		return
	pedestal_sprite = Sprite2D.new()
	pedestal_sprite.name = "TorchPedestal"
	pedestal_sprite.texture = props_tex
	pedestal_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pedestal_sprite.region_enabled = true
	pedestal_sprite.region_rect = Rect2(64, 128, 32, 32)
	pedestal_sprite.position = Vector2(0, -16)
	pedestal_sprite.z_index = -1
	add_child(pedestal_sprite)

func set_storm_mode(stormy: bool) -> void:
	is_stormy = stormy
	if embers_ref:
		embers_ref.amount = 10 if is_stormy else 6
		embers_ref.direction = Vector2(-0.8, -1.0) if is_stormy else Vector2(0, -1)
		embers_ref.gravity = Vector2(-40.0, -15.0) if is_stormy else Vector2(0, -20.0)

func set_cave_mode(cave_mode: bool, is_boss_lair: bool = false) -> void:
	if not cave_mode:
		return
	_ensure_cave_pedestal()
	if sprite and torch_type == Type.TORCH:
		sprite.position = Vector2(0, -32)
	light_energy = clampf(base_energy if base_energy > 0.0 else 0.85, 0.72, 0.96)
	light_scale = 0.58
	var has_custom: bool = (light_color != Color(1.0, 0.78, 0.48, 1.0) or flame_color != Color(1.0, 0.78, 0.48, 1.0))
	if light:
		light.position = Vector2(0, -36)
		light.texture_scale = light_scale
		light.energy = light_energy
		if has_custom:
			light.color = light_color
		elif is_boss_lair:
			light.color = Color(0.55, 0.78, 1.0, 1.0)
			if sprite:
				sprite.modulate = Color(0.75, 1.05, 1.30, 1.0)
		else:
			light.color = Color(0.98, 0.76, 0.45, 1.0)
	if embers_ref:
		embers_ref.position = Vector2(0, -36)
		embers_ref.amount = 7
		if has_custom:
			embers_ref.color = Color(flame_color.r, flame_color.g, flame_color.b, 0.82)
		elif is_boss_lair:
			embers_ref.color = Color(0.45, 0.85, 1.0, 0.80)

func _process(delta: float) -> void:
	# Flame frame cycle
	if torch_type == Type.TORCH and sprite:
		anim_timer += delta
		if anim_timer >= 0.10:
			anim_timer -= 0.10
			cur_frame = (cur_frame + 1) % TORCH_FRAMES.size()
			sprite.frame = TORCH_FRAMES[cur_frame]
	
	# Soft organic flame flicker with storm wind sputter
	if light:
		var t = Time.get_ticks_msec() / 1000.0
		if is_stormy:
			var flicker: float = sin(t * 14.0) * 0.12 + sin(t * 28.0) * 0.08 + (randf() - 0.5) * 0.05
			light.energy = clamp(light_energy + flicker, 0.60, 1.25)
		else:
			var flicker: float = sin(t * 10.0) * 0.05 + sin(t * 23.0) * 0.03 + (randf() - 0.5) * 0.02
			light.energy = clamp(light_energy + flicker, 0.68, 1.12)


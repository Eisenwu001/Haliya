class_name GhostDashDecoy
extends Node2D

const VFX_SCRIPT = preload("res://scripts/vfx.gd")

var damage: int = 1
var lifetime: float = 0.75
var timer: float = 0.0
var hit_enemies: Array[Node] = []
var sprite: Sprite2D


func setup(tex: Texture2D, flip_h: bool, hframes: int = 1, vframes: int = 1, frame: int = 0) -> void:
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.flip_h = flip_h
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame
	sprite.modulate = Color(0.65, 0.85, 1.2, 0.75)
	add_child(sprite)


func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		queue_free()
		return
	
	# Ethereal flicker
	if sprite:
		sprite.modulate.a = (1.0 - (timer / lifetime)) * 0.75
	
	# Check enemies touching the decoy
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e in hit_enemies and not e.get("is_dead"):
			if global_position.distance_to(e.global_position + Vector2(0, -30)) <= 38.0:
				hit_enemies.append(e)
				if e.has_method("take_damage"):
					var dir = 1.0 if e.global_position.x >= global_position.x else -1.0
					e.take_damage(damage, dir)
				if e.has_method("deflect_by_parry"):
					e.deflect_by_parry(1.0)
				VFX_SCRIPT.spawn_blood_slash(get_parent(), e.global_position + Vector2(0, -32), false, Vector2(0.9, 0.9))
				VFX_SCRIPT.spawn_floating_text(get_parent(), e.global_position + Vector2(0, -42), "GHOST SHOCK", Color(0.7, 0.9, 1.0, 1.0), 11)

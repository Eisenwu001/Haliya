class_name CaveCrystalGeode
extends StaticBody2D

const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const PickupItemScript = preload("res://scripts/pickup_item.gd")
const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

enum GeodeState {
	AUTO_RANDOM = 0,
	INTACT = 1,
	CRACKED = 2
}

@export_enum("Auto Random", "Intact (2 Hits)", "Cracked (1 Hit)") var initial_state: int = GeodeState.AUTO_RANDOM
@export_enum("Health Dot (Default)", "Stamina Talisman", "Random Mix") var drop_type: int = 0
@export var is_amethyst: bool = false

var current_state: int = GeodeState.INTACT
var is_broken: bool = false
var wobble_tween: Tween
var sprite: Sprite2D
var col_shape: CollisionShape2D
var glow_light: PointLight2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("breakables")

	collision_layer = 1
	collision_mask = 0

	if initial_state == GeodeState.AUTO_RANDOM:
		var seed_val: int = int(abs(global_position.x * 7.0 + global_position.y * 13.0 + get_index() * 19.0))
		current_state = GeodeState.CRACKED if (seed_val % 2 == 1) else GeodeState.INTACT
	else:
		current_state = initial_state

	col_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(18.0, 20.0)
		col_shape.shape = shape
		col_shape.position = Vector2(0.0, -10.0)
		add_child(col_shape)

	sprite = get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)

	var props_tex = CaveAssetsScript.get_props_tex()
	sprite.texture = props_tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(224, 64, 48, 48)
	sprite.position = Vector2(0.0, -21.0)
	sprite.scale = Vector2(1.0, 1.0)

	# Gentle sacred anito ember glow from inside the pot
	var light_tex = load("res://assets/vfx/radial_light_falloff.png")
	if light_tex:
		glow_light = PointLight2D.new()
		glow_light.name = "GeodeGlow"
		glow_light.texture = light_tex
		glow_light.position = Vector2(0.0, -10.0)
		glow_light.color = Color(1.0, 0.72, 0.38, 0.85)
		glow_light.energy = 0.55
		glow_light.texture_scale = 0.30
		add_child(glow_light)


func smash(impact_dir: Vector2 = Vector2.UP) -> void:
	if is_broken:
		return

	if current_state == GeodeState.INTACT:
		_handle_first_hit(impact_dir)
	else:
		_handle_final_shatter(impact_dir)


func take_damage(_amount: int = 1, knockback_dir: float = 0.0) -> void:
	var dir = Vector2(knockback_dir, -0.6) if knockback_dir != 0.0 else Vector2.UP
	smash(dir)


func _handle_first_hit(impact_dir: Vector2) -> void:
	current_state = GeodeState.CRACKED
	if is_instance_valid(sprite):
		sprite.region_rect = Rect2(96, 0, 48, 48)
	_spawn_particles(impact_dir, 6, 35.0, 75.0, 0.30, 1.2, 2.5)
	
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = ProceduralAudioScript.get_hit_slash(true, 1)
	sfx.pitch_scale = randf_range(1.45, 1.65)
	sfx.volume_db = -4.0
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 2.8, 3.0, 1.0)
		if is_instance_valid(wobble_tween) and wobble_tween.is_valid():
			wobble_tween.kill()
		wobble_tween = create_tween()
		wobble_tween.tween_property(sprite, "scale", Vector2(0.78, 0.52), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wobble_tween.tween_property(sprite, "scale", Vector2(0.58, 0.74), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wobble_tween.tween_property(sprite, "scale", Vector2(0.65, 0.65), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wobble_tween.parallel().tween_property(sprite, "modulate", Color(1.3, 1.2, 1.4, 1.0), 0.20)


func _handle_final_shatter(impact_dir: Vector2) -> void:
	is_broken = true
	if is_instance_valid(col_shape):
		col_shape.set_deferred("disabled", true)

	_spawn_particles(impact_dir, 18, 80.0, 180.0, 0.55, 2.0, 4.5)
	
	var parent_node := get_parent()
	if is_instance_valid(parent_node):
		var sfx := AudioStreamPlayer2D.new()
		sfx.stream = ProceduralAudioScript.get_pot_smash()
		if sfx.stream == null:
			sfx.stream = ProceduralAudioScript.get_hit_slash(true, 2)
		sfx.pitch_scale = randf_range(1.35, 1.55)
		sfx.volume_db = -2.0
		sfx.global_position = global_position
		parent_node.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

	# Drop health or stamina reward
	_spawn_drop()

	if is_instance_valid(glow_light):
		var l_tw = create_tween()
		l_tw.tween_property(glow_light, "energy", 1.8, 0.06)
		l_tw.tween_property(glow_light, "energy", 0.0, 0.24)

	if is_instance_valid(sprite):
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(0.85, 0.35), 0.08).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.22)
		tw.tween_callback(queue_free)
	else:
		queue_free()


func _spawn_drop() -> void:
	var parent_node := get_parent()
	if not is_instance_valid(parent_node):
		return
	
	var should_drop_health := true
	match drop_type:
		1:
			should_drop_health = false
		2:
			should_drop_health = (randf() < 0.70)
		_:
			should_drop_health = true
	
	if should_drop_health:
		var num_dots: int = 1 if randf() < 0.40 else 2
		for i in range(num_dots):
			var dot = PickupItemScript.new()
			dot.pickup_type = PickupItemScript.Type.HEALTH_DOT
			dot.global_position = global_position + Vector2(0.0, -12.0)
			parent_node.add_child(dot)
			var scatter_x = randf_range(-35.0, 35.0) if num_dots == 1 else ((-26.0 if i == 0 else 26.0) + randf_range(-8.0, 8.0))
			dot.launch_scatter(Vector2(scatter_x, 6.0))
	else:
		var talisman = PickupItemScript.new()
		talisman.pickup_type = PickupItemScript.Type.STAMINA_TALISMAN
		talisman.global_position = global_position + Vector2(0.0, -12.0)
		parent_node.add_child(talisman)
		talisman.launch_scatter(Vector2(randf_range(-20.0, 20.0), 6.0))


func _spawn_particles(dir: Vector2, count: int, min_v: float, max_v: float, life: float, min_s: float, max_s: float) -> void:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = count
	p.lifetime = life
	p.direction = dir.normalized()
	p.spread = 75.0
	p.gravity = Vector2(0.0, 320.0)
	p.initial_velocity_min = min_v
	p.initial_velocity_max = max_v
	p.scale_amount_min = min_s
	p.scale_amount_max = max_s
	p.color = Color(0.75, 0.42, 0.28, 0.95) if is_amethyst else Color(0.82, 0.50, 0.32, 0.95)
	p.position = Vector2(0.0, -12.0)
	add_child(p)
	p.emitting = true
	get_tree().create_timer(life + 0.1).timeout.connect(func(): if is_instance_valid(p): p.queue_free())

class_name CaveCrumbleLedge
extends StaticBody2D

const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

enum State {
	INTACT,
	SHUDDERING,
	COLLAPSED
}

@export var shudder_duration: float = 0.60
@export var respawn_delay: float = 2.20

var state: State = State.INTACT
var state_timer: float = 0.0
var sprite: Sprite2D
var col_shape: CollisionShape2D
var dust_particles: CPUParticles2D
var base_sprite_pos: Vector2 = Vector2(56.0, 24.0)


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	col_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		var rect := RectangleShape2D.new()
		rect.size = Vector2(112.0, 16.0)
		col_shape.shape = rect
		col_shape.position = Vector2(56.0, 8.0)
		col_shape.one_way_collision = true
		add_child(col_shape)

	sprite = get_node_or_null("LedgeSprite") as Sprite2D
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "LedgeSprite"
		add_child(sprite)

	sprite.texture = CaveAssetsScript.get_platforms_tex()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_rect = Rect2(112, 64, 112, 48)
	sprite.position = base_sprite_pos
	sprite.z_index = 0

	if not get_node_or_null("DustParticles"):
		dust_particles = CPUParticles2D.new()
		dust_particles.name = "DustParticles"
		dust_particles.position = Vector2(56.0, 18.0)
		dust_particles.emitting = false
		dust_particles.amount = 14
		dust_particles.lifetime = 0.55
		dust_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		dust_particles.emission_rect_extents = Vector2(50.0, 6.0)
		dust_particles.direction = Vector2(0.0, 1.0)
		dust_particles.spread = 35.0
		dust_particles.gravity = Vector2(0.0, 240.0)
		dust_particles.initial_velocity_min = 15.0
		dust_particles.initial_velocity_max = 55.0
		dust_particles.scale_amount_min = 2.0
		dust_particles.scale_amount_max = 3.8
		dust_particles.color = Color(0.45, 0.56, 0.78, 0.85)
		add_child(dust_particles)
	else:
		dust_particles = get_node_or_null("DustParticles") as CPUParticles2D


func _physics_process(delta: float) -> void:
	match state:
		State.INTACT:
			var players = get_tree().get_nodes_in_group("player")
			for p in players:
				if not is_instance_valid(p) or not (p is CharacterBody2D):
					continue
				var player := p as CharacterBody2D
				if player.is_on_floor():
					var dx: float = abs(player.global_position.x - (global_position.x + 48.0))
					var dy: float = abs(player.global_position.y - global_position.y)
					if dx <= 52.0 and dy <= 14.0:
						_start_shudder()
						break
		State.SHUDDERING:
			state_timer -= delta
			if is_instance_valid(sprite):
				sprite.position = base_sprite_pos + Vector2(randf_range(-2.6, 2.6), randf_range(-1.2, 1.5))
			if state_timer <= 0.0:
				_collapse_ledge()
		State.COLLAPSED:
			state_timer -= delta
			if state_timer <= 0.0:
				_reform_ledge()


func _start_shudder() -> void:
	state = State.SHUDDERING
	state_timer = shudder_duration
	if is_instance_valid(dust_particles):
		dust_particles.emitting = true
	if is_instance_valid(sprite):
		sprite.modulate = Color(1.35, 1.15, 1.55, 1.0)


func _collapse_ledge() -> void:
	state = State.COLLAPSED
	state_timer = respawn_delay
	if is_instance_valid(col_shape):
		col_shape.set_deferred("disabled", true)
	if is_instance_valid(dust_particles):
		dust_particles.emitting = false
	if is_instance_valid(sprite):
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(sprite, "modulate:a", 0.0, 0.20)
		tw.tween_callback(func():
			if is_instance_valid(sprite):
				sprite.position = base_sprite_pos
		).set_delay(0.20)


func _reform_ledge() -> void:
	state = State.INTACT
	if is_instance_valid(sprite):
		sprite.position = base_sprite_pos
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var tw := create_tween()
		tw.tween_property(sprite, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func():
			if is_instance_valid(col_shape) and state == State.INTACT:
				col_shape.set_deferred("disabled", false)
		)
	else:
		if is_instance_valid(col_shape):
			col_shape.set_deferred("disabled", false)

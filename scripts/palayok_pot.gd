class_name PalayokPot
extends StaticBody2D

# ── Breakable Pot Frames ────────────────────────────────────────────────────────
const TEX_INTACT = preload("res://assets/props/pot_intact.png")
const TEX_CRACKED = preload("res://assets/props/pot_cracked.png")
const TEX_BURST = preload("res://assets/props/pot_burst.png")
const TEX_RUBBLE = preload("res://assets/props/pot_rubble.png")
const PickupItemScript = preload("res://scripts/pickup_item.gd")

enum PotState {
	AUTO_RANDOM = 0,
	INTACT = 1,
	CRACKED = 2
}

@export_enum("Auto Random", "Intact (2 Hits)", "Cracked (1 Hit)") var initial_state: int = PotState.AUTO_RANDOM
@export_enum("Health Dumpling (Default)", "Stamina Talisman", "Random Mix") var drop_type: int = 0

# ── Proportions & Ground Alignment ─────────────────────────────────────────────
# 1024x1024 native frames scaled down to ~27-28px height matching character scale
const SCALE_FACTOR: float = 0.028

# Offsets so the bottom of each frame sits grounded at y = 0
const OFFSET_INTACT_Y: float = -478.0 * SCALE_FACTOR   # Content bottom at y=990
const OFFSET_CRACKED_Y: float = -478.0 * SCALE_FACTOR  # Content bottom at y=990
const OFFSET_BURST_Y: float = -512.0 * SCALE_FACTOR    # Content bottom at y=1024
const OFFSET_RUBBLE_Y: float = -306.0 * SCALE_FACTOR   # Rubble bottom at y=647 (682h)

# ── State Tracking ─────────────────────────────────────────────────────────────
var current_state: int = PotState.INTACT
var is_broken: bool = false
var wobble_tween: Tween
var sprite: Sprite2D
var col_shape: CollisionShape2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("breakables")
	
	collision_layer = 1
	collision_mask = 0
	
	# Determine starting state: if AUTO_RANDOM, use deterministic position-based distribution
	if initial_state == PotState.AUTO_RANDOM:
		var seed_val: int = int(abs(global_position.x * 7.0 + global_position.y * 13.0 + get_index() * 19.0))
		current_state = PotState.CRACKED if (seed_val % 2 == 1) else PotState.INTACT
	else:
		current_state = initial_state
	
	# Setup Collision Shape if not already provided by scene
	if has_node("CollisionShape2D"):
		col_shape = get_node("CollisionShape2D")
	else:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(20.0, 22.0)
		col_shape.shape = shape
		col_shape.position = Vector2(0.0, -11.0)
		add_child(col_shape)
	
	# Setup Sprite2D if not already provided by scene
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")
	else:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
	
	_apply_current_visual_state()

func _apply_current_visual_state() -> void:
	if not is_instance_valid(sprite):
		return
	sprite.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
	if current_state == PotState.INTACT:
		sprite.texture = TEX_INTACT
		sprite.position = Vector2(0.0, OFFSET_INTACT_Y)
	else:
		sprite.texture = TEX_CRACKED
		sprite.position = Vector2(0.0, OFFSET_CRACKED_Y)

## Called when the pot is struck by the player or an attack
func smash(impact_dir: Vector2 = Vector2.UP) -> void:
	if is_broken:
		return
	
	if current_state == PotState.INTACT:
		_handle_first_hit(impact_dir)
	else:
		_handle_final_shatter(impact_dir)

func take_damage(_amount: int = 1, knockback_dir: float = 0.0) -> void:
	var dir = Vector2(knockback_dir, -0.6) if knockback_dir != 0.0 else Vector2.UP
	smash(dir)

## First hit: Transitions from Intact to Cracked with squash/wobble and chip particles
func _handle_first_hit(impact_dir: Vector2) -> void:
	current_state = PotState.CRACKED
	
	# Spawn small clay chip burst
	_spawn_particles(impact_dir, 6, 40.0, 80.0, 0.4, 1.5, 3.0)
	
	# Hit flash white
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
		
		# Squash & stretch impact tween
		var base_scale := Vector2(SCALE_FACTOR, SCALE_FACTOR)
		var squash_scale := Vector2(SCALE_FACTOR * 1.25, SCALE_FACTOR * 0.78)
		var stretch_scale := Vector2(SCALE_FACTOR * 0.85, SCALE_FACTOR * 1.15)
		
		if is_instance_valid(wobble_tween) and wobble_tween.is_valid():
			wobble_tween.kill()
		
		wobble_tween = create_tween()
		wobble_tween.tween_property(sprite, "scale", squash_scale, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wobble_tween.tween_property(sprite, "scale", stretch_scale, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		wobble_tween.tween_property(sprite, "scale", base_scale, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# Switch to cracked frame right after flash
		var timer := get_tree().create_timer(0.06)
		timer.timeout.connect(func():
			if is_instance_valid(sprite) and not is_broken:
				sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
				sprite.texture = TEX_CRACKED
				sprite.position = Vector2(0.0, OFFSET_CRACKED_Y)
		)

## Final hit: Triggers explosion frame, particle shards, screen shake, loot, and resting rubble
func _handle_final_shatter(impact_dir: Vector2) -> void:
	is_broken = true
	
	if is_instance_valid(wobble_tween) and wobble_tween.is_valid():
		wobble_tween.kill()
	
	if is_instance_valid(col_shape):
		col_shape.set_deferred("disabled", true)
	
	# Screen shake
	_trigger_screen_shake(0.25)
	
	# Full terracotta clay shards particle burst
	_spawn_particles(impact_dir, 16, 80.0, 160.0, 0.65, 2.0, 4.5)
	
	# Spawn reward pickup (70% Dumpling, 30% Talisman)
	_spawn_pickup()
	
	# Display Frame 3 (Explosion) briefly
	if is_instance_valid(sprite):
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprite.texture = TEX_BURST
		sprite.position = Vector2(0.0, OFFSET_BURST_Y)
		sprite.scale = Vector2(SCALE_FACTOR * 1.08, SCALE_FACTOR * 1.08)
		
		# Settle into Frame 4 (Rubble) after 0.18s
		var burst_timer := get_tree().create_timer(0.18)
		burst_timer.timeout.connect(func():
			if not is_instance_valid(sprite):
				return
			sprite.texture = TEX_RUBBLE
			sprite.position = Vector2(0.0, OFFSET_RUBBLE_Y)
			sprite.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
			z_index = -1 # Place debris behind standing entities
			
			# Rubble lingers for 4.5 seconds before smoothly fading out
			var linger_timer := get_tree().create_timer(4.5)
			linger_timer.timeout.connect(func():
				if not is_instance_valid(sprite):
					return
				var fade_tween := create_tween()
				fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
				fade_tween.tween_callback(queue_free)
			)
		)

func _spawn_particles(impact_dir: Vector2, count: int, vel_min: float, vel_max: float, lifetime: float, scale_min: float, scale_max: float) -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.lifetime = lifetime
	particles.amount = count
	particles.direction = impact_dir.normalized()
	particles.spread = 70.0
	particles.initial_velocity_min = vel_min
	particles.initial_velocity_max = vel_max
	particles.gravity = Vector2(0.0, 480.0)
	particles.scale_amount_min = scale_min
	particles.scale_amount_max = scale_max
	particles.color = Color(0.74, 0.40, 0.22, 1.0) # Terracotta clay
	particles.position = Vector2(0.0, -10.0)
	add_child(particles)

func _spawn_pickup() -> void:
	var pickup = PickupItemScript.new()
	match drop_type:
		1:
			pickup.pickup_type = PickupItem.Type.STAMINA_TALISMAN
		2:
			pickup.pickup_type = PickupItem.Type.HEALTH_DUMPLING if randf() < 0.70 else PickupItem.Type.STAMINA_TALISMAN
		_:
			pickup.pickup_type = PickupItem.Type.HEALTH_DUMPLING
	pickup.global_position = global_position + Vector2(0.0, -12.0)
	var parent_node := get_parent()
	if is_instance_valid(parent_node):
		parent_node.add_child(pickup)

func _trigger_screen_shake(amount: float) -> void:
	var tree := get_tree()
	if not is_instance_valid(tree) or not is_instance_valid(tree.root):
		return
	var main_node = tree.root.find_child("Main", true, false)
	if is_instance_valid(main_node) and main_node.has_method("add_screen_shake"):
		main_node.add_screen_shake(amount)

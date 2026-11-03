class_name MudPuddleHazard
extends Area2D

## MudPuddleHazard - Flooded Rice Paddy Mud Pool
## Slows down movement and doubles dodge stamina cost when wading through deep mud.
## Uses a reusable CPUParticles2D node and overlap counting so adjacent puddles never
## prematurely clear the player's wading state.

const TEX_DETAILED = preload("res://assets/rice_field/mud_puddle_detailed.png")
const TEX_MEDIUM = preload("res://assets/rice_field/mud_puddle_medium.png")

@export var is_medium: bool = false
@export var puddle_width: float = 144.0

var sprite: Sprite2D
var col_shape: CollisionShape2D
var splash_particles: CPUParticles2D
var splash_timer: float = 0.0

func _ready() -> void:
	add_to_group("mud_puddle_hazards")
	collision_layer = 0
	collision_mask = 2 | 4 # Player (2) and Enemies (4)
	
	sprite = Sprite2D.new()
	sprite.texture = TEX_MEDIUM if is_medium else TEX_DETAILED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Embedded directly into the top of Floor Tiles1.png (y = -2..+14 relative to ground surface)
	sprite.position = Vector2(0.0, 6.0)
	sprite.z_index = 1
	add_child(sprite)
	
	col_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var w = 84.0 if is_medium else 130.0
	rect.size = Vector2(w, 18.0)
	col_shape.shape = rect
	col_shape.position = Vector2(0.0, -2.0)
	add_child(col_shape)
	
	# Reusable mud splash particle emitter (zero per-step node allocation)
	splash_particles = CPUParticles2D.new()
	splash_particles.emitting = false
	splash_particles.one_shot = true
	splash_particles.explosiveness = 0.85
	splash_particles.amount = 7
	splash_particles.lifetime = 0.38
	splash_particles.direction = Vector2(0, -1)
	splash_particles.spread = 58.0
	splash_particles.gravity = Vector2(0, 230)
	splash_particles.initial_velocity_min = 35.0
	splash_particles.initial_velocity_max = 75.0
	splash_particles.color = Color(0.32, 0.24, 0.15, 0.92)
	splash_particles.scale_amount_min = 1.5
	splash_particles.scale_amount_max = 3.0
	splash_particles.z_index = 5
	add_child(splash_particles)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if splash_timer > 0.0:
		splash_timer -= delta
		return
		
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if is_instance_valid(b) and (b.is_in_group("player") or b.name == "Player"):
			if "velocity" in b and abs(b.velocity.x) > 20.0:
				_trigger_mud_splash(b.global_position)
				splash_timer = 0.22
				break

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if body.is_in_group("player") or body.name == "Player":
		if "is_wading_in_mud" in body:
			body.is_wading_in_mud = true
			_trigger_mud_splash(body.global_position)

func _on_body_exited(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if body.is_in_group("player") or body.name == "Player":
		if "is_wading_in_mud" in body:
			# Verify player is not still overlapping another adjacent mud puddle
			var still_in_mud: bool = false
			if is_inside_tree():
				for hazard in get_tree().get_nodes_in_group("mud_puddle_hazards"):
					if hazard != self and is_instance_valid(hazard) and hazard is Area2D:
						if (hazard as Area2D).overlaps_body(body):
							still_in_mud = true
							break
			body.is_wading_in_mud = still_in_mud

func _trigger_mud_splash(pos: Vector2) -> void:
	if is_instance_valid(splash_particles):
		splash_particles.global_position = Vector2(pos.x, global_position.y - 2.0)
		splash_particles.restart()
		splash_particles.emitting = true

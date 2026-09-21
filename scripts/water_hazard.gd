class_name WaterHazard
extends Area2D

var width: float = 64.0
var height: float = 32.0

func _init(w: float = 64.0, h: float = 32.0) -> void:
	width = w
	height = h

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer
	
	if has_node("CollisionShape2D"):
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)
		return
	
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	col.position = Vector2(width * 0.5, height * 0.5)
	add_child(col)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		# Spawn water splash burst
		spawn_splash(body.global_position)
		
		# Reset player back to last safe grounded ledge with 1 damage
		if body.has_method("respawn_at_safe_ledge"):
			body.respawn_at_safe_ledge(1)

func spawn_splash(pos: Vector2) -> void:
	var splash := CPUParticles2D.new()
	splash.emitting = true
	splash.one_shot = true
	splash.explosiveness = 0.9
	splash.lifetime = 0.55
	splash.amount = 22
	splash.direction = Vector2(0, -1)
	splash.spread = 45.0
	splash.initial_velocity_min = 80.0
	splash.initial_velocity_max = 160.0
	splash.gravity = Vector2(0, 420.0)
	splash.scale_amount_min = 2.0
	splash.scale_amount_max = 4.0
	splash.color = Color(0.70, 0.90, 1.0, 0.95) # Cyan-tinted water droplets
	splash.global_position = Vector2(pos.x, global_position.y + 4.0)
	get_parent().add_child(splash)
	get_tree().create_timer(1.0).timeout.connect(splash.queue_free)

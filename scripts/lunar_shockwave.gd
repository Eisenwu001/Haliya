class_name LunarShockwave
extends Area2D

const VFX_SCRIPT = preload("res://scripts/vfx.gd")

var direction: float = 1.0
var speed: float = 480.0
var max_distance: float = 240.0
var damage: int = 2
var start_x: float = 0.0
var hit_enemies: Array[Node] = []
var lifetime: float = 0.60
var timer: float = 0.0


func _ready() -> void:
	start_x = global_position.x
	collision_layer = 0
	collision_mask = 4 # Enemies layer
	
	# Add a collision shape
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	add_child(col)
	
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta
	timer += delta
	
	var traveled = abs(global_position.x - start_x)
	if traveled >= max_distance or timer >= lifetime:
		fade_and_free()
		return
	
	# Also query group enemies within radius for robustness
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e in hit_enemies and not e.get("is_dead"):
			if global_position.distance_to(e.global_position + Vector2(0, -30)) <= 32.0:
				_apply_hit(e)
	
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("enemies"):
		_apply_hit(body)


func _apply_hit(enemy: Node) -> void:
	if enemy in hit_enemies or not is_instance_valid(enemy):
		return
	hit_enemies.append(enemy)
	
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, direction)
	
	VFX_SCRIPT.spawn_blood_slash(get_parent(), enemy.global_position + Vector2(0, -32), direction < 0.0, Vector2(1.2, 1.2))
	VFX_SCRIPT.spawn_floating_text(get_parent(), enemy.global_position + Vector2(0, -48), "%d" % damage, Color(0.6, 0.85, 1.0, 1.0), 14, true)


func fade_and_free() -> void:
	set_physics_process(false)
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.12)
	tw.tween_callback(queue_free)


func _draw() -> void:
	var col_outer = Color(0.85, 0.95, 1.0, 0.95)
	var col_inner = Color(0.40, 0.75, 1.0, 0.80)
	
	# Draw crescent lunar wave arc
	var flip = -1.0 if direction < 0.0 else 1.0
	var points_outer: PackedVector2Array = []
	var points_inner: PackedVector2Array = []
	
	for i in range(-12, 13):
		var ang = float(i) / 12.0 * 1.05
		var r_out = 24.0
		var r_in = 14.0
		var ox = cos(ang) * r_out * flip
		var oy = sin(ang) * r_out * 1.5
		var ix = cos(ang) * r_in * flip * 0.7
		var iy = sin(ang) * r_in * 1.2
		points_outer.append(Vector2(ox, oy))
		points_inner.append(Vector2(ix, iy))
	
	points_inner.reverse()
	var poly = points_outer + points_inner
	if poly.size() >= 3:
		draw_colored_polygon(poly, col_inner)
	
	draw_polyline(points_outer, col_outer, 2.5)
	
	# Leading gleam star
	draw_circle(Vector2(flip * 24.0, 0.0), 3.5, Color(1.0, 1.0, 1.0, 0.95))

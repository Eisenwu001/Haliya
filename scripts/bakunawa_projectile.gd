class_name BakunawaProjectile
extends Area2D

const SPEED: float = 250.0
const LIFETIME: float = 4.0

var direction: Vector2 = Vector2.LEFT
var lifetime_timer: float = LIFETIME
var is_active: bool = true
var is_enraged: bool = false
var wave_phase: float = 0.0

var sprite: Sprite2D
var eclipse_ring: Polygon2D
var particles: CPUParticles2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 | 1 # Player (2) and Ground (1)
	
	setup_visuals()
	body_entered.connect(_on_body_entered)

func setup_visuals() -> void:
	var add_mat = CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	# Outer spinning abyssal crescent ring
	eclipse_ring = Polygon2D.new()
	eclipse_ring.name = "EclipseRing"
	eclipse_ring.material = add_mat
	var pts = PackedVector2Array()
	for i in range(14):
		var a = (float(i) / 14.0) * TAU
		var r = 13.0 if i % 2 == 0 else 8.5
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	eclipse_ring.polygon = pts
	eclipse_ring.color = Color(0.95, 0.28, 0.62, 0.65) if is_enraged else Color(0.28, 0.78, 1.0, 0.65)
	add_child(eclipse_ring)

	# Core lunar flame orb
	sprite = Sprite2D.new()
	sprite.name = "OrbSprite"
	sprite.texture = create_orb_texture()
	sprite.modulate = Color(2.2, 0.9, 1.6, 1.0) if is_enraged else Color(1.4, 1.8, 2.5, 1.0)
	add_child(sprite)
	
	# Trailing celestial flame particles
	particles = CPUParticles2D.new()
	particles.name = "TrailParticles"
	particles.amount = 20
	particles.lifetime = 0.36
	particles.speed_scale = 1.2
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5.0
	particles.gravity = Vector2(0, -60.0)
	particles.direction = -direction
	particles.spread = 30.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(0.95, 0.30, 0.65, 0.85) if is_enraged else Color(0.3, 0.75, 1.0, 0.85)
	add_child(particles)
	
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 9.0
	col.shape = shape
	add_child(col)

func create_orb_texture() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	var center = Vector2(12, 12)
	for x in range(24):
		for y in range(24):
			var d = center.distance_to(Vector2(x, y))
			if d <= 10.0:
				var alpha = clampf(1.0 - (d / 10.0), 0.0, 1.0)
				var c = Color(0.4, 0.8, 1.0, alpha)
				if d <= 4.5:
					c = Color(1.0, 1.0, 1.0, alpha)
				img.set_pixel(x, y, c)
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	wave_phase += delta * 9.5
	if eclipse_ring:
		eclipse_ring.rotation += delta * 7.5
	var wave_offset = Vector2(0, cos(wave_phase) * 35.0 * delta)
	global_position += (direction * SPEED * delta) + wave_offset
	
	lifetime_timer -= delta
	if lifetime_timer <= 0.0:
		dissipate()

func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	
	if body is Player or body.is_in_group("player"):
		is_active = false
		if body.has_method("take_damage_from_enemy"):
			var knock_dir = sign(direction.x)
			body.take_damage_from_enemy(1, knock_dir, self)
		burst_impact()
	elif body is TileMapLayer or body is StaticBody2D:
		is_active = false
		burst_impact()

func burst_impact() -> void:
	is_active = false
	if sprite:
		sprite.visible = false
	if eclipse_ring:
		eclipse_ring.visible = false
	if particles:
		particles.emitting = false
	
	# Spawn burst sparks
	var burst = CPUParticles2D.new()
	burst.emitting = true
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.amount = 18
	burst.lifetime = 0.35
	burst.spread = 180.0
	burst.initial_velocity_min = 60.0
	burst.initial_velocity_max = 145.0
	burst.scale_amount_min = 1.8
	burst.scale_amount_max = 3.8
	burst.color = Color(0.95, 0.32, 0.68, 0.9) if is_enraged else Color(0.4, 0.85, 1.2, 0.9)
	burst.global_position = global_position
	get_parent().add_child(burst)
	
	get_tree().create_timer(0.40).timeout.connect(func():
		if is_instance_valid(burst):
			burst.queue_free()
		queue_free()
	)

func dissipate() -> void:
	is_active = false
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.20)
	tw.tween_callback(queue_free)

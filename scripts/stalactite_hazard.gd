class_name StalactiteHazard
extends Area2D

const FALL_SPEED: float = 380.0
const GRAVITY: float = 880.0

var current_velocity: float = 0.0
var is_falling: bool = false
var has_impacted: bool = false
var warning_timer: float = 0.58
var ground_y: float = 280.0

var sprite: Sprite2D
var warning_line: Line2D
var warning_dust: CPUParticles2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer
	
	setup_visuals()
	body_entered.connect(_on_body_entered)

func setup_visuals() -> void:
	# Telegraphed ceiling-to-ground warning trace line so player can dodge in dark cavern
	warning_line = Line2D.new()
	warning_line.width = 2.0
	warning_line.default_color = Color(0.45, 0.82, 1.0, 0.38)
	warning_line.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, ground_y - global_position.y)
	])
	add_child(warning_line)

	sprite = Sprite2D.new()
	sprite.name = "StalactiteSprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = create_stalactite_texture()
	sprite.centered = true
	sprite.scale = Vector2(0.95, 0.95)
	add_child(sprite)
	
	var col = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.radius = 8.0
	shape.height = 30.0
	col.shape = shape
	add_child(col)
	
	# Ground warning dust
	warning_dust = CPUParticles2D.new()
	warning_dust.emitting = true
	warning_dust.amount = 14
	warning_dust.lifetime = 0.42
	warning_dust.direction = Vector2(0, -1)
	warning_dust.spread = 35.0
	warning_dust.initial_velocity_min = 25.0
	warning_dust.initial_velocity_max = 60.0
	warning_dust.gravity = Vector2(0, 200.0)
	warning_dust.scale_amount_min = 1.5
	warning_dust.scale_amount_max = 3.2
	warning_dust.color = Color(0.48, 0.74, 0.95, 0.72)
	warning_dust.global_position = Vector2(global_position.x, ground_y)
	get_parent().call_deferred("add_child", warning_dust)

func create_stalactite_texture() -> ImageTexture:
	# 22x40 pointed cavern stalactite spike with cyan crystal vein
	var img = Image.create(22, 40, false, Image.FORMAT_RGBA8)
	for y in range(40):
		var w = int(lerp(10.0, 1.2, float(y) / 40.0))
		for x in range(11 - w, 11 + w):
			var shade = 0.28 + 0.12 * ((x + y) % 3)
			var c = Color(shade * 0.62, shade * 0.74, shade * 0.96, 1.0)
			if x == 11:
				c = Color(0.45, 0.78, 1.0, 1.0)
			elif x == 10:
				c = Color(0.32, 0.56, 0.82, 1.0)
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

func _physics_process(delta: float) -> void:
	if has_impacted:
		return
	
	if warning_timer > 0.0:
		warning_timer -= delta
		# Wobble while detaching from ceiling and pulse warning trace
		sprite.position.x = sin(warning_timer * 42.0) * 2.5
		if warning_line:
			warning_line.default_color.a = 0.22 + 0.25 * abs(sin(warning_timer * 24.0))
		if warning_timer <= 0.0:
			is_falling = true
			if warning_line:
				warning_line.visible = false
			if is_instance_valid(warning_dust):
				warning_dust.emitting = false
		return
	
	if is_falling:
		current_velocity += GRAVITY * delta
		global_position.y += current_velocity * delta
		
		if global_position.y >= ground_y:
			shatter_on_ground()

func _on_body_entered(body: Node2D) -> void:
	if not is_falling or has_impacted:
		return
	
	if body is Player or body.is_in_group("player"):
		if body.has_method("take_damage_from_enemy"):
			body.take_damage_from_enemy(2, 0.0, self)
		shatter_on_ground()

func shatter_on_ground() -> void:
	if has_impacted:
		return
	has_impacted = true
	is_falling = false
	visible = false
	
	if is_instance_valid(warning_dust):
		warning_dust.queue_free()
	
	# Spawn stone & crystal debris burst
	var debris = CPUParticles2D.new()
	debris.emitting = true
	debris.one_shot = true
	debris.explosiveness = 0.95
	debris.amount = 16
	debris.lifetime = 0.45
	debris.direction = Vector2(0, -1)
	debris.spread = 75.0
	debris.initial_velocity_min = 65.0
	debris.initial_velocity_max = 140.0
	debris.gravity = Vector2(0, 480.0)
	debris.scale_amount_min = 2.0
	debris.scale_amount_max = 4.2
	debris.color = Color(0.42, 0.65, 0.88, 0.92)
	debris.global_position = Vector2(global_position.x, ground_y)
	get_parent().add_child(debris)
	
	get_tree().create_timer(0.50).timeout.connect(func():
		if is_instance_valid(debris):
			debris.queue_free()
		queue_free()
	)

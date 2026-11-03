class_name RiceFieldCarabao
extends AnimatableBody2D

## RiceFieldCarabao - Interactive & Ambient Water Buffalo (Kalabaw)
## Resting or wallowing peacefully in the rice paddies.
## Serves as a solid, living platform that the player can jump and stand upon.

@export var facing_left: bool = true
@export var is_wallowing_in_mud: bool = true

var sprite: Sprite2D
var puddle_sprite: Sprite2D
var collision_shape: CollisionShape2D
var player_detect_area: Area2D
var mud_particles: CPUParticles2D

var anim_timer: float = 0.0
var current_frame: int = 0
const FRAME_DURATION: float = 0.40
const TOTAL_FRAMES: int = 4 # Frames 0-3 for idle loop; Frame 4 for squish reaction

var is_squished: bool = false
var original_sprite_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# 1. Mud Puddle Base (if wallowing)
	if is_wallowing_in_mud:
		puddle_sprite = Sprite2D.new()
		var p_tex = load("res://assets/rice_field/mud_puddle.png") as Texture2D
		if p_tex:
			puddle_sprite.texture = p_tex
			puddle_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			puddle_sprite.position = Vector2(0.0, 6.0)
			puddle_sprite.z_index = 1 # Sits embedded in the ground tileset under the carabao
			add_child(puddle_sprite)

	# 2. Sprite Setup (5 frames: 0-3 idle breathing/ear/chew, 4 squish reaction)
	sprite = Sprite2D.new()
	var tex = load("res://assets/rice_field/carabao_spritesheet.png") as Texture2D
	if tex:
		sprite.texture = tex
		sprite.hframes = 5
		sprite.vframes = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.flip_h = not facing_left
	sprite.position = Vector2(0.0, -22.0)
	sprite.z_index = 2
	original_sprite_pos = sprite.position
	add_child(sprite)

	# 3. Solid Platform Collision on back (precisely aligned to top of spine at y = -50.0)
	collision_shape = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(58.0, 8.0)
	collision_shape.shape = box
	collision_shape.position = Vector2(0.0, -48.0)
	collision_shape.one_way_collision = true
	collision_shape.one_way_collision_margin = 4.0
	add_child(collision_shape)

	# 4. Detection Area for player stepping on back (sits just above collision platform)
	player_detect_area = Area2D.new()
	player_detect_area.collision_layer = 0
	player_detect_area.collision_mask = 2 # Player layer
	var detect_shape = CollisionShape2D.new()
	var detect_box = RectangleShape2D.new()
	detect_box.size = Vector2(54.0, 10.0)
	detect_shape.shape = detect_box
	detect_shape.position = Vector2(0.0, -54.0)
	player_detect_area.add_child(detect_shape)
	player_detect_area.body_entered.connect(_on_player_stepped_on)
	add_child(player_detect_area)

	# 5. Mud / Wallowing Ambient Particles if in mud
	if is_wallowing_in_mud:
		mud_particles = CPUParticles2D.new()
		mud_particles.emitting = true
		mud_particles.amount = 8
		mud_particles.lifetime = 1.8
		mud_particles.direction = Vector2(0.0, -1.0)
		mud_particles.spread = 70.0
		mud_particles.gravity = Vector2(0.0, 18.0)
		mud_particles.initial_velocity_min = 4.0
		mud_particles.initial_velocity_max = 14.0
		mud_particles.scale_amount_min = 1.2
		mud_particles.scale_amount_max = 2.4
		mud_particles.color = Color(0.38, 0.28, 0.18, 0.65)
		mud_particles.position = Vector2(0.0, -4.0)
		add_child(mud_particles)

func _process(delta: float) -> void:
	if is_squished:
		return
	anim_timer += delta
	if anim_timer >= FRAME_DURATION:
		anim_timer -= FRAME_DURATION
		current_frame = (current_frame + 1) % TOTAL_FRAMES
		if sprite:
			sprite.frame = current_frame

func _on_player_stepped_on(body: Node2D) -> void:
	if is_squished:
		return
	is_squished = true
	
	# Switch to squish reaction frame
	if sprite:
		sprite.frame = 4
	
	# Mud splash on step impact
	if is_wallowing_in_mud and is_inside_tree():
		var splash = CPUParticles2D.new()
		splash.emitting = true
		splash.one_shot = true
		splash.explosiveness = 0.9
		splash.amount = 12
		splash.lifetime = 0.5
		splash.direction = Vector2(0.0, -1.0)
		splash.spread = 80.0
		splash.gravity = Vector2(0.0, 240.0)
		splash.initial_velocity_min = 25.0
		splash.initial_velocity_max = 55.0
		splash.scale_amount_min = 1.5
		splash.scale_amount_max = 2.8
		splash.color = Color(0.34, 0.24, 0.14, 0.8)
		splash.position = Vector2(0.0, -2.0)
		add_child(splash)
		get_tree().create_timer(0.6).timeout.connect(splash.queue_free)
	
	# Gentle living squash & bounce back
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", original_sprite_pos.y + 2.5, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", original_sprite_pos.y, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		is_squished = false
		if sprite:
			sprite.frame = current_frame
	)

	# Gentle snort / landing thud
	if is_inside_tree():
		var asp = AudioStreamPlayer2D.new()
		asp.stream = ProceduralAudio.get_landing_thud()
		asp.volume_db = -12.0
		asp.pitch_scale = 0.52 # Deep low water buffalo rumble
		add_child(asp)
		asp.finished.connect(asp.queue_free)
		asp.play()

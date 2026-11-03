class_name AmbientEgret
extends Node2D

## AmbientEgret (Tagak) - White Philippine Egret
## Foraging peacefully in the rice fields, startling into flight as the player approaches.

enum State {
	IDLE_PECK,
	STARTLED,
	FLYING
}

const EGRET_TEX = preload("res://assets/rice_field/egret_spritesheet.png")
const SCARE_DISTANCE: float = 120.0

@export var facing_left: bool = true

var state: State = State.IDLE_PECK
var sprite: Sprite2D
var player: CharacterBody2D = null

var velocity: Vector2 = Vector2.ZERO
var flap_timer: float = 0.0
var peck_timer: float = 0.0
var flight_time: float = 0.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = EGRET_TEX
	sprite.hframes = 5
	sprite.vframes = 1
	sprite.frame = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.flip_h = not facing_left
	sprite.position = Vector2(0.0, -16.0)
	add_child(sprite)
	peck_timer = randf_range(0.8, 2.5)

func _process(delta: float) -> void:
	find_player()

	match state:
		State.IDLE_PECK:
			handle_pecking(delta)
		State.STARTLED:
			handle_startled(delta)
		State.FLYING:
			handle_flying(delta)

func find_player() -> void:
	if is_instance_valid(player):
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func handle_pecking(delta: float) -> void:
	if is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist <= SCARE_DISTANCE:
			take_off()
			return
		elif dist <= SCARE_DISTANCE * 1.4:
			# Alert stance before flight
			if sprite.frame != 2:
				sprite.frame = 2

	peck_timer -= delta
	if peck_timer <= 0.0:
		if sprite.frame == 1:
			# Finished pecking, back to standing idle
			sprite.frame = 0
			peck_timer = randf_range(1.5, 3.5)
		else:
			# Dip down to peck rice grains
			sprite.frame = 1
			peck_timer = randf_range(0.35, 0.75)

func take_off() -> void:
	if state != State.IDLE_PECK:
		return
	state = State.STARTLED
	if is_instance_valid(sprite):
		sprite.frame = 2 # Crouch & flare wings
	
	# Determine flight direction (fly away from player)
	var dir_away = -1.0
	if is_instance_valid(player):
		dir_away = -1.0 if player.global_position.x < global_position.x else 1.0
	facing_left = (dir_away < 0.0)
	if is_instance_valid(sprite):
		sprite.flip_h = not facing_left
	
	velocity = Vector2(dir_away * randf_range(85.0, 125.0), -115.0)
	
	# Wing flutter / chirp sound
	if is_inside_tree():
		var asp = AudioStreamPlayer2D.new()
		asp.stream = ProceduralAudio.get_random_bird_chirp()
		asp.volume_db = -10.0
		asp.pitch_scale = 1.3
		add_child(asp)
		asp.finished.connect(asp.queue_free)
		asp.play()

	var tween = create_tween()
	tween.tween_interval(0.14)
	tween.tween_callback(func():
		state = State.FLYING
		if is_instance_valid(sprite):
			sprite.frame = 3
	)

func handle_startled(delta: float) -> void:
	position += velocity * 0.35 * delta

func handle_flying(delta: float) -> void:
	flight_time += delta
	flap_timer += delta
	if flap_timer >= 0.11:
		flap_timer -= 0.11
		sprite.frame = 4 if sprite.frame == 3 else 3

	# Aerodynamic lift-off curving into graceful horizon flight
	velocity.y = move_toward(velocity.y, -30.0, 110.0 * delta)
	
	# Aerodynamic wing lift bobbing
	var wing_lift = sin(flight_time * 18.0) * 0.8
	position += Vector2(velocity.x * delta, (velocity.y + wing_lift) * delta)

	# Smoothly recede into background depth and fade out
	if flight_time > 1.8:
		var fade_progress = (flight_time - 1.8) / 1.6
		modulate.a = max(0.0, 1.0 - fade_progress)
		scale = lerp(Vector2.ONE, Vector2(0.7, 0.7), clampf(fade_progress, 0.0, 1.0))
		if modulate.a <= 0.01 or position.y < -80.0:
			queue_free()

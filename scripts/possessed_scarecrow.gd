class_name PossessedScarecrow
extends CharacterBody2D

signal aswang_died(enemy: Node)

enum State {
	DORMANT,
	AWAKENING,
	CHASE,
	ATTACK,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const SCARECROW_TEX = preload("res://assets/rice_field/scarecrow_spritesheet.png")
const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")

const GRAVITY: float = 980.0
const HOP_SPEED: float = 75.0
const JUMP_VELOCITY: float = -220.0
const TRIGGER_RANGE: float = 120.0
const ATTACK_RANGE: float = 45.0
const MAX_HEALTH: int = 4
const STUN_DURATION: float = 1.6

var current_state: State = State.DORMANT
var health: int = MAX_HEALTH
var is_facing_left: bool = false
var is_dead: bool = false
var is_stunned_vulnerable: bool = false

var hop_timer: float = 0.0
var attack_cooldown: float = 0.0
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var has_hit_player_this_attack: bool = false
var target_player: CharacterBody2D = null

var current_frame_idx: int = 0
var frame_timer: float = 0.0

var sprite: Sprite2D
var collision_shape: CollisionShape2D
var health_pips: Node2D
var stun_stars_sprite: Sprite2D
var eye_light: PointLight2D

const FRAME_MAP = {
	State.DORMANT: [0, 1, 2, 3],
	State.AWAKENING: [6, 7, 8, 9, 10, 11],
	State.CHASE: [8, 9, 10, 11],
	State.ATTACK: [12, 13, 14, 15, 16, 17],
	State.PARRIED_STAGGER: [18, 19],
	State.HURT: [18, 19],
	State.DEATH: [20, 21, 22, 23]
}

const FRAME_DURATIONS = {
	State.DORMANT: 0.35,
	State.AWAKENING: 0.09,
	State.CHASE: 0.12,
	State.ATTACK: 0.08,
	State.PARRIED_STAGGER: 0.18,
	State.HURT: 0.12,
	State.DEATH: 0.12
}

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy")
	collision_layer = 4
	collision_mask = 1

	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = SCARECROW_TEX
	sprite.hframes = 6
	sprite.vframes = 4
	sprite.frame = 0
	sprite.scale = Vector2(0.52, 0.52)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(0.0, -16.0)
	add_child(sprite)

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var cap := CapsuleShape2D.new()
	cap.radius = 9.0
	cap.height = 32.0
	collision_shape.shape = cap
	collision_shape.position = Vector2(0.0, -16.0)
	add_child(collision_shape)

	if EnemyHealthPipsClass:
		health_pips = EnemyHealthPipsClass.new()
		health_pips.position = Vector2(0.0, -42.0)
		add_child(health_pips)
		health_pips.update_health(MAX_HEALTH, MAX_HEALTH, false)
		health_pips.modulate.a = 0.0 # Hidden while dormant

	stun_stars_sprite = Sprite2D.new()
	var stars_tex = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	if stars_tex:
		stun_stars_sprite.texture = stars_tex
		stun_stars_sprite.hframes = 3
		stun_stars_sprite.vframes = 2
		stun_stars_sprite.scale = Vector2(0.08, 0.08)
	stun_stars_sprite.position = Vector2(0.0, -42.0)
	stun_stars_sprite.visible = false
	add_child(stun_stars_sprite)

	set_state(State.DORMANT)

func _physics_process(delta: float) -> void:
	if current_state != State.DORMANT and not is_on_floor() and not is_dead:
		velocity.y += GRAVITY * delta

	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		move_and_slide()
		advance_animation(delta)
		return

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and is_instance_valid(sprite):
			sprite.modulate = Color.WHITE

	update_target_player()

	match current_state:
		State.DORMANT:
			handle_dormant()
		State.AWAKENING:
			handle_awakening(delta)
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack(delta)
		State.PARRIED_STAGGER:
			handle_stagger(delta)
		State.HURT:
			handle_hurt(delta)

	if current_state != State.DORMANT:
		move_and_slide()
	advance_animation(delta)

func update_target_player() -> void:
	if is_dead:
		target_player = null
		return
	if is_instance_valid(target_player):
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func handle_dormant() -> void:
	velocity = Vector2.ZERO
	if is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= TRIGGER_RANGE:
			awaken()

func awaken() -> void:
	if current_state != State.DORMANT:
		return
	if is_instance_valid(health_pips):
		health_pips.visible = true
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -46.0), "SKRREEE!", Color(1.0, 0.25, 0.2), 14, true)
	if is_inside_tree():
		var asp = AudioStreamPlayer2D.new()
		asp.stream = ProceduralAudio.get_pot_smash()
		asp.volume_db = -8.0
		asp.pitch_scale = 1.5 # High snapping wood
		add_child(asp)
		asp.finished.connect(asp.queue_free)
		asp.play()
	set_state(State.AWAKENING)

func handle_awakening(delta: float) -> void:
	velocity = Vector2.ZERO

func handle_chase(delta: float) -> void:
	if not is_instance_valid(target_player):
		set_state(State.CHASE)
		return
	var dist_x = target_player.global_position.x - global_position.x
	var abs_dist_x = abs(dist_x)
	var dir = sign(dist_x)

	update_facing(dist_x < 0.0)

	if abs_dist_x <= ATTACK_RANGE and attack_cooldown <= 0.0:
		set_state(State.ATTACK)
		return

	# Erratic hop movement
	hop_timer -= delta
	if hop_timer <= 0.0 and is_on_floor():
		hop_timer = randf_range(0.5, 0.9)
		velocity.x = dir * HOP_SPEED
		velocity.y = JUMP_VELOCITY * randf_range(0.85, 1.1)

func handle_attack(delta: float) -> void:
	var dir = -1.0 if is_facing_left else 1.0
	if current_frame_idx == 2:
		velocity.x = dir * 110.0
		if not has_hit_player_this_attack:
			check_hitbox()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)

func handle_stagger(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
	stun_timer -= delta
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.frame = int(Time.get_ticks_msec() / 100.0) % 6
	if stun_timer <= 0.0:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		set_state(State.CHASE)

func handle_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)

func update_facing(face_left: bool) -> void:
	is_facing_left = face_left
	if is_instance_valid(sprite):
		sprite.flip_h = is_facing_left

func check_hitbox() -> void:
	if not is_instance_valid(target_player) or is_dead:
		return
	var dist = global_position.distance_to(target_player.global_position)
	var x_diff = target_player.global_position.x - global_position.x
	var in_front = (x_diff < 0.0 and is_facing_left) or (x_diff >= 0.0 and not is_facing_left)
	if dist <= ATTACK_RANGE * 1.4 and in_front:
		has_hit_player_this_attack = true
		var enemy_dir = -1.0 if is_facing_left else 1.0
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(1, enemy_dir, self)

func deflect_by_parry(deflect_dir: float) -> void:
	if is_dead:
		return
	is_stunned_vulnerable = true
	stun_timer = STUN_DURATION
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = true
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, true)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -48.0), "PARRIED!", Color(1.0, 0.85, 0.2), 14, true)
	velocity.x = deflect_dir * 180.0
	velocity.y = -80.0
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 1.8, 0.4, 1.0)
	hurt_flash_timer = 0.25
	set_state(State.PARRIED_STAGGER)

func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if is_dead:
		return

	if current_state == State.DORMANT:
		awaken()

	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		health = 0
		if is_instance_valid(health_pips):
			health_pips.update_health(0, MAX_HEALTH, false)
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -48.0), "CRIT 99!", Color(1.0, 0.9, 0.2), 16, true)
		trigger_death()
		return

	health -= amount
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, false)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -40.0), str(amount), Color(1.0, 0.85, 0.3), 14, false)

	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	hurt_flash_timer = 0.18

	velocity.x = knockback_dir * 140.0
	velocity.y = -100.0

	if health <= 0:
		trigger_death()
	else:
		set_state(State.HURT)

func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	set_state(State.DEATH)
	if is_instance_valid(health_pips):
		health_pips.visible = false
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = false
	collision_layer = 0
	collision_mask = 1
	
	# Spawn cursed straw & splinter burst
	if is_inside_tree() and get_parent():
		var p := CPUParticles2D.new()
		p.emitting = true
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = 16
		p.lifetime = 0.75
		p.direction = Vector2(0.0, -1.0)
		p.spread = 75.0
		p.gravity = Vector2(0.0, 320.0)
		p.initial_velocity_min = 45.0
		p.initial_velocity_max = 95.0
		p.scale_amount_min = 1.5
		p.scale_amount_max = 3.5
		p.color = Color(0.85, 0.72, 0.40, 0.95) # Golden straw & wood
		p.position = global_position + Vector2(0.0, -16.0)
		get_parent().add_child(p)
		get_tree().create_timer(1.0).timeout.connect(p.queue_free)
	
	aswang_died.emit(self)

func set_state(new_state: State) -> void:
	current_state = new_state
	current_frame_idx = 0
	frame_timer = 0.0
	has_hit_player_this_attack = false
	if new_state == State.ATTACK:
		attack_cooldown = 1.4
	apply_current_frame()

func advance_animation(delta: float) -> void:
	var frames: Array = FRAME_MAP.get(current_state, [0])
	if frames.is_empty():
		return
	var dur: float = FRAME_DURATIONS.get(current_state, 0.1)
	frame_timer += delta
	if frame_timer >= dur:
		frame_timer -= dur
		if current_state == State.AWAKENING:
			if current_frame_idx < frames.size() - 1:
				current_frame_idx += 1
			else:
				set_state(State.CHASE)
		elif current_state == State.ATTACK:
			if current_frame_idx < frames.size() - 1:
				current_frame_idx += 1
			else:
				set_state(State.CHASE)
		elif current_state == State.HURT:
			if current_frame_idx < frames.size() - 1:
				current_frame_idx += 1
			else:
				set_state(State.CHASE)
		elif current_state == State.DEATH:
			if current_frame_idx < frames.size() - 1:
				current_frame_idx += 1
				if current_frame_idx == frames.size() - 1:
					# Fade out smoothly on final dissolve frame
					var tw = create_tween()
					tw.tween_property(sprite, "modulate:a", 0.0, 0.40)
					tw.tween_callback(queue_free)
			apply_current_frame()
			return
		elif current_state == State.PARRIED_STAGGER:
			current_frame_idx = (current_frame_idx + 1) % frames.size()
		else:
			current_frame_idx = (current_frame_idx + 1) % frames.size()
		apply_current_frame()

func apply_current_frame() -> void:
	if not is_instance_valid(sprite):
		return
	var frames: Array = FRAME_MAP.get(current_state, [0])
	var idx = clamp(current_frame_idx, 0, frames.size() - 1)
	sprite.frame = frames[idx]

class_name CorruptedFarmer
extends CharacterBody2D

signal aswang_died(enemy: Node)
signal farmer_died(enemy: Node)

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	LUNGE,
	SICKLE_TOSS,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const FARMER_TEX = preload("res://assets/rice_field/corrupted_farmer_spritesheet.png")
const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")

const GRAVITY: float = 980.0
const PATROL_SPEED: float = 34.0
const CHASE_SPEED: float = 72.0
const LUNGE_SPEED: float = 165.0
const AGGRO_RANGE: float = 245.0
const ATTACK_RANGE: float = 56.0
const LUNGE_MIN_RANGE: float = 85.0
const LUNGE_MAX_RANGE: float = 185.0
const TOSS_MIN_RANGE: float = 135.0
const TOSS_MAX_RANGE: float = 235.0
const MAX_HEALTH: int = 6
const STUN_DURATION: float = 1.75

var current_state: State = State.IDLE
var health: int = MAX_HEALTH
var max_health: int = MAX_HEALTH
var is_elite: bool = false
var speed_multiplier: float = 1.0

var is_facing_left: bool = false
var is_dead: bool = false
var is_stunned_vulnerable: bool = false
var is_telegraphing: bool = false

var spawn_x: float = 0.0
var patrol_direction: float = 1.0
var patrol_distance: float = 130.0
var patrol_timer: float = 0.0
var idle_wait_timer: float = 0.0
var attack_cooldown: float = 0.0
var lunge_cooldown: float = 0.0
var toss_cooldown: float = 1.8
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var has_hit_player_this_attack: bool = false
var has_spawned_projectile: bool = false
var target_player: CharacterBody2D = null

var current_frame_idx: int = 0
var frame_timer: float = 0.0
var anim_phase: float = 0.0
var base_sprite_pos: Vector2 = Vector2(0.0, -35.0)

var sprite: Sprite2D
var collision_shape: CollisionShape2D
var ledge_ray: RayCast2D
var health_pips: Node2D
var stun_stars_sprite: Sprite2D

const FRAME_MAP = {
	State.IDLE: [0, 1, 2, 3, 4, 5],
	State.PATROL: [6, 7, 8, 9, 10, 11],
	State.CHASE: [6, 7, 8, 9, 10, 11],
	State.ATTACK: [12, 13, 14, 15, 16, 17],
	State.LUNGE: [6, 12, 13, 14, 15, 16],
	State.SICKLE_TOSS: [12, 13, 14, 15, 16, 17],
	State.PARRIED_STAGGER: [18, 19],
	State.HURT: [18, 19],
	State.DEATH: [20, 21, 22, 23]
}

const FRAME_DURATIONS = {
	State.IDLE: 0.16,
	State.PATROL: 0.105,
	State.CHASE: 0.082,
	State.ATTACK: 0.075,
	State.LUNGE: 0.068,
	State.SICKLE_TOSS: 0.085,
	State.PARRIED_STAGGER: 0.18,
	State.HURT: 0.11,
	State.DEATH: 0.14
}

func apply_difficulty_scaling(hp_mult: float, spd_mult: float, elite: bool = false) -> void:
	is_elite = elite
	speed_multiplier = spd_mult
	if is_elite:
		max_health = int(round(MAX_HEALTH * hp_mult * 1.5))
		speed_multiplier *= 1.20
		if is_instance_valid(sprite):
			sprite.modulate = Color(1.35, 0.45, 0.85, 1.0)
	else:
		max_health = int(round(MAX_HEALTH * hp_mult))
	health = max_health
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health, is_stunned_vulnerable)

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy")
	add_to_group("corrupted_farmer")
	collision_layer = 4 # Enemy layer
	collision_mask = 1  # Collide with world terrain

	spawn_x = global_position.x
	anim_phase = randf_range(0.0, TAU)

	# 1. Main Animated Sprite
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = FARMER_TEX
	sprite.hframes = 6
	sprite.vframes = 4
	sprite.frame = 0
	sprite.scale = Vector2(1.0, 1.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = base_sprite_pos
	add_child(sprite)

	# 2. Physics Body Collision
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var cap := CapsuleShape2D.new()
	cap.radius = 13.0
	cap.height = 52.0
	collision_shape.shape = cap
	collision_shape.position = Vector2(0.0, -26.0)
	add_child(collision_shape)

	# 3. Ledge / Cliff Edge RayCast2D (Prevents blindly walking off elevated terraces)
	ledge_ray = RayCast2D.new()
	ledge_ray.name = "LedgeRay"
	ledge_ray.position = Vector2(18.0, -8.0)
	ledge_ray.target_position = Vector2(0.0, 24.0)
	ledge_ray.collision_mask = 1
	ledge_ray.enabled = true
	add_child(ledge_ray)

	# 4. Health Bar
	if EnemyHealthPipsClass:
		health_pips = EnemyHealthPipsClass.new()
		health_pips.position = Vector2(0.0, -66.0)
		add_child(health_pips)
		health_pips.update_health(MAX_HEALTH, MAX_HEALTH, false)
		health_pips.modulate.a = 0.0

	# 5. Stun Stars
	stun_stars_sprite = Sprite2D.new()
	var stars_tex = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	if stars_tex:
		stun_stars_sprite.texture = stars_tex
		stun_stars_sprite.hframes = 3
		stun_stars_sprite.vframes = 2
		stun_stars_sprite.scale = Vector2(0.12, 0.12)
	stun_stars_sprite.position = Vector2(0.0, -70.0)
	stun_stars_sprite.visible = false
	add_child(stun_stars_sprite)

	set_state(State.IDLE)

func _physics_process(delta: float) -> void:
	anim_phase += delta * 5.5
	if not is_on_floor() and not is_dead:
		velocity.y += GRAVITY * delta

	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		move_and_slide()
		advance_animation(delta)
		return

	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if lunge_cooldown > 0.0:
		lunge_cooldown -= delta
	if toss_cooldown > 0.0:
		toss_cooldown -= delta

	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and is_instance_valid(sprite):
			sprite.modulate = Color(1.35, 0.45, 0.85, 1.0) if is_elite else Color.WHITE

	update_target_player()

	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.PATROL:
			handle_patrol(delta)
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack(delta)
		State.LUNGE:
			handle_lunge(delta)
		State.SICKLE_TOSS:
			handle_sickle_toss(delta)
		State.PARRIED_STAGGER:
			handle_stagger(delta)
		State.HURT:
			handle_hurt(delta)

	move_and_slide()
	advance_animation(delta)
	_apply_smooth_procedural_flow(delta)

func _apply_smooth_procedural_flow(delta: float) -> void:
	if not is_instance_valid(sprite) or is_dead:
		return
	var target_scale := Vector2.ONE
	var target_rot: float = 0.0
	var target_offset_y: float = 0.0
	var f_dir: float = -1.0 if is_facing_left else 1.0

	match current_state:
		State.IDLE:
			var breath = sin(anim_phase * 0.65)
			target_scale = Vector2(1.0 - breath * 0.018, 1.0 + breath * 0.022)
			target_offset_y = -breath * 0.8
		State.PATROL, State.CHASE:
			var speed_ratio = clamp(abs(velocity.x) / CHASE_SPEED, 0.2, 1.3)
			var stride = abs(sin(anim_phase * 1.45))
			target_scale = Vector2(1.0 + stride * 0.025, 1.0 - stride * 0.02)
			target_rot = f_dir * 0.045 * speed_ratio
			target_offset_y = -stride * 1.6
		State.ATTACK, State.LUNGE:
			if current_frame_idx <= 1:
				# Windup coil back
				target_scale = Vector2(0.94, 1.06)
				target_rot = -f_dir * 0.08
			elif current_frame_idx in [2, 3]:
				# Slash extension stretch
				target_scale = Vector2(1.10, 0.93)
				target_rot = f_dir * 0.10
		State.SICKLE_TOSS:
			if current_frame_idx <= 1:
				target_rot = -f_dir * 0.09
			else:
				target_rot = f_dir * 0.07
		State.HURT, State.PARRIED_STAGGER:
			target_scale = Vector2(0.95, 1.04)
			target_rot = -f_dir * 0.06

	sprite.scale = sprite.scale.lerp(target_scale, min(1.0, delta * 14.0))
	sprite.rotation = lerp(sprite.rotation, target_rot, min(1.0, delta * 14.0))
	sprite.position = sprite.position.lerp(base_sprite_pos + Vector2(0.0, target_offset_y), min(1.0, delta * 14.0))

func is_ledge_ahead(move_dir: float) -> bool:
	if not is_on_floor() or not is_instance_valid(ledge_ray):
		return false
	ledge_ray.position.x = 18.0 * sign(move_dir)
	ledge_ray.force_raycast_update()
	return not ledge_ray.is_colliding()

func update_target_player() -> void:
	if is_dead:
		target_player = null
		return
	if is_instance_valid(target_player):
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func handle_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 220.0 * delta)
	if is_player_in_range(AGGRO_RANGE):
		set_state(State.CHASE)
		return
	idle_wait_timer -= delta
	if idle_wait_timer <= 0.0:
		patrol_direction = -patrol_direction
		set_state(State.PATROL)

func handle_patrol(delta: float) -> void:
	if is_player_in_range(AGGRO_RANGE):
		set_state(State.CHASE)
		return
	var offset = global_position.x - spawn_x
	if abs(offset) >= patrol_distance or is_on_wall() or is_ledge_ahead(patrol_direction):
		patrol_direction = -patrol_direction
		idle_wait_timer = randf_range(0.9, 2.0)
		set_state(State.IDLE)
		return
	velocity.x = patrol_direction * (PATROL_SPEED * speed_multiplier)
	update_facing(velocity.x < 0.0)

func handle_chase(delta: float) -> void:
	if not is_instance_valid(target_player):
		set_state(State.IDLE)
		return
	var dist_x = target_player.global_position.x - global_position.x
	var abs_dist_x = abs(dist_x)

	if abs_dist_x > AGGRO_RANGE * 1.5:
		set_state(State.PATROL)
		return

	update_facing(dist_x < 0.0)
	var dir = sign(dist_x) if abs_dist_x > 2.0 else (-1.0 if is_facing_left else 1.0)

	# In melee attack range
	if abs_dist_x <= ATTACK_RANGE and attack_cooldown <= 0.0:
		set_state(State.ATTACK)
		return

	# Check if a cliff edge blocks direct ground pursuit
	var cliff_blocked = is_ledge_ahead(dir)
	if cliff_blocked:
		velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
		if toss_cooldown <= 0.0 and abs_dist_x <= TOSS_MAX_RANGE * 1.15:
			set_state(State.SICKLE_TOSS)
		return

	# Mid-range options: Lunge or Sickle Husk Toss
	if abs_dist_x >= TOSS_MIN_RANGE and abs_dist_x <= TOSS_MAX_RANGE and toss_cooldown <= 0.0 and randf() < 0.25:
		set_state(State.SICKLE_TOSS)
		return

	if abs_dist_x >= LUNGE_MIN_RANGE and abs_dist_x <= LUNGE_MAX_RANGE and lunge_cooldown <= 0.0 and randf() < 0.35:
		set_state(State.LUNGE)
		return

	velocity.x = move_toward(velocity.x, dir * (CHASE_SPEED * speed_multiplier), 320.0 * delta)

func handle_attack(delta: float) -> void:
	is_telegraphing = (current_frame_idx <= 1)
	if current_frame_idx == 2:
		var dir = -1.0 if is_facing_left else 1.0
		if not is_ledge_ahead(dir):
			velocity.x = dir * 92.0
		if not has_hit_player_this_attack:
			check_hitbox()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 320.0 * delta)

func handle_lunge(delta: float) -> void:
	is_telegraphing = (current_frame_idx <= 1)
	var dir = -1.0 if is_facing_left else 1.0
	if current_frame_idx <= 2 and not is_ledge_ahead(dir):
		velocity.x = dir * (LUNGE_SPEED * speed_multiplier)
		if current_frame_idx == 2 and not has_hit_player_this_attack:
			check_hitbox()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 360.0 * delta)

func handle_sickle_toss(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
	is_telegraphing = (current_frame_idx <= 1)
	if current_frame_idx == 2 and not has_spawned_projectile:
		has_spawned_projectile = true
		_spawn_corrupted_sickle_wave()

func _spawn_corrupted_sickle_wave() -> void:
	if not is_inside_tree() or not is_instance_valid(get_parent()):
		return
	var dir: float = -1.0 if is_facing_left else 1.0
	var proj := Area2D.new()
	proj.name = "CorruptedSickleWave_%d" % (Time.get_ticks_usec() % 100000)
	proj.collision_layer = 0
	proj.collision_mask = 2 # Player layer
	proj.global_position = global_position + Vector2(dir * 20.0, -28.0)
	proj.z_index = 10

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	col.shape = circle
	proj.add_child(col)

	# Crescent sickle energy visual
	var crescent := Polygon2D.new()
	crescent.polygon = PackedVector2Array([
		Vector2(-4.0 * dir, -10.0),
		Vector2(8.0 * dir, -6.0),
		Vector2(11.0 * dir, 0.0),
		Vector2(8.0 * dir, 6.0),
		Vector2(-4.0 * dir, 10.0),
		Vector2(2.0 * dir, 0.0)
	])
	crescent.color = Color(0.85, 0.32, 0.95, 0.92)
	proj.add_child(crescent)

	get_parent().add_child(proj)

	var hit_done := [false]
	proj.body_entered.connect(func(body: Node2D):
		if hit_done[0] or not is_instance_valid(body):
			return
		if body.is_in_group("player") or body.name == "Player":
			hit_done[0] = true
			if body.has_method("take_damage_from_enemy"):
				body.take_damage_from_enemy(1, dir, self)
			proj.queue_free()
	)

	var p_tw = proj.create_tween()
	p_tw.set_parallel(true)
	p_tw.tween_property(proj, "global_position:x", proj.global_position.x + dir * 210.0, 0.85)
	p_tw.tween_property(crescent, "rotation", dir * TAU * 2.5, 0.85)
	p_tw.chain().tween_callback(proj.queue_free)

func handle_stagger(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
	stun_timer -= delta
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.frame = int(Time.get_ticks_msec() / 100.0) % 6
	if stun_timer <= 0.0:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		set_state(State.IDLE)

func handle_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 220.0 * delta)

func is_player_in_range(r: float) -> bool:
	if not is_instance_valid(target_player):
		return false
	return global_position.distance_to(target_player.global_position) <= r

func update_facing(face_left: bool) -> void:
	is_facing_left = face_left
	if is_instance_valid(sprite):
		sprite.flip_h = is_facing_left
	if is_instance_valid(ledge_ray):
		ledge_ray.position.x = -18.0 if is_facing_left else 18.0

func check_hitbox() -> void:
	if not is_instance_valid(target_player) or is_dead:
		return
	var x_diff = target_player.global_position.x - global_position.x
	var y_diff = abs(target_player.global_position.y - global_position.y)
	var in_front = (x_diff < 0.0 and is_facing_left) or (x_diff >= 0.0 and not is_facing_left)
	if abs(x_diff) <= ATTACK_RANGE * 1.30 and y_diff <= 44.0 and in_front:
		has_hit_player_this_attack = true
		var enemy_dir = -1.0 if is_facing_left else 1.0
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(2, enemy_dir, self)

func deflect_by_parry(deflect_dir: float) -> void:
	if is_dead:
		return
	is_telegraphing = false
	is_stunned_vulnerable = true
	stun_timer = STUN_DURATION
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = true
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health, true)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -48.0), "PARRIED!", Color(1.0, 0.85, 0.2), 14, true)
	VFX.spawn_stagger_execution_prompt(get_parent(), global_position + Vector2(0, -68.0))
	velocity.x = deflect_dir * 200.0
	velocity.y = -90.0
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 1.8, 0.4, 1.0)
	hurt_flash_timer = 0.25
	set_state(State.PARRIED_STAGGER)

func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if is_dead:
		return
	is_telegraphing = false

	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		health = 0
		if is_instance_valid(health_pips):
			health_pips.update_health(0, max_health, false)
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -48.0), "CRIT 99!", Color(1.0, 0.9, 0.2), 16, true)
		trigger_death()
		return

	health -= amount
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health, false)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -60.0), str(amount), Color(1.0, 0.35, 0.25), 14, false)
	VFX.spawn_blood_splatter(get_parent(), global_position + Vector2(0, -32.0), Vector2(knockback_dir, -0.4), 1.2, false)

	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	hurt_flash_timer = 0.18

	velocity.x = knockback_dir * 160.0
	velocity.y = -110.0

	if health <= 0:
		trigger_death()
	else:
		set_state(State.HURT)

func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	is_telegraphing = false
	if is_elite:
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -60.0), "ELITE SLAIN", Color(1.0, 0.85, 0.35), 14, true)
	set_state(State.DEATH)
	if is_instance_valid(health_pips):
		health_pips.visible = false
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = false
	collision_layer = 0
	collision_mask = 1 # Keep ground collision so it doesn't fall through

	if is_inside_tree():
		var burst = CPUParticles2D.new()
		burst.emitting = true
		burst.one_shot = true
		burst.explosiveness = 0.85
		burst.amount = 16
		burst.lifetime = 0.7
		burst.direction = Vector2(0.0, -1.0)
		burst.spread = 65.0
		burst.gravity = Vector2(0.0, -25.0)
		burst.initial_velocity_min = 20.0
		burst.initial_velocity_max = 50.0
		burst.scale_amount_min = 1.6
		burst.scale_amount_max = 3.2
		burst.color = Color(0.68, 0.22, 0.85, 0.85)
		burst.position = Vector2(0.0, -10.0)
		add_child(burst)
		get_tree().create_timer(0.8).timeout.connect(burst.queue_free)

		var asp = AudioStreamPlayer2D.new()
		asp.stream = ProceduralAudio.get_hit_slash()
		asp.volume_db = -8.0
		asp.pitch_scale = 0.65
		add_child(asp)
		asp.finished.connect(asp.queue_free)
		asp.play()

	farmer_died.emit(self)
	aswang_died.emit(self)

func set_state(new_state: State) -> void:
	current_state = new_state
	current_frame_idx = 0
	frame_timer = 0.0
	has_hit_player_this_attack = false
	has_spawned_projectile = false
	is_telegraphing = false

	if new_state == State.ATTACK:
		attack_cooldown = 1.45
		is_telegraphing = true
		if is_instance_valid(sprite):
			sprite.modulate = Color(2.0, 0.55, 0.55, 1.0)
			hurt_flash_timer = 0.15
	elif new_state == State.LUNGE:
		lunge_cooldown = 3.2
		attack_cooldown = 1.8
		is_telegraphing = true
		if is_instance_valid(sprite):
			sprite.modulate = Color(2.0, 1.6, 0.35, 1.0)
			hurt_flash_timer = 0.15
	elif new_state == State.SICKLE_TOSS:
		toss_cooldown = 3.6
		attack_cooldown = 1.5
		is_telegraphing = true
		if is_instance_valid(sprite):
			sprite.modulate = Color(1.75, 0.65, 2.0, 1.0)
			hurt_flash_timer = 0.18

	apply_current_frame()

func advance_animation(delta: float) -> void:
	var frames: Array = FRAME_MAP.get(current_state, [0])
	if frames.is_empty():
		return
	var dur: float = FRAME_DURATIONS.get(current_state, 0.1)
	frame_timer += delta
	if frame_timer >= dur:
		frame_timer -= dur
		if current_state in [State.ATTACK, State.LUNGE, State.SICKLE_TOSS]:
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

class_name Aswang
extends CharacterBody2D

signal aswang_died(aswang: Aswang)

enum State {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	LEAP_ATTACK,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const MAIN_SHEET_TEX = preload("res://assets/aswang/aswang_spritesheet.png")
const PARRIED_STAGGER_TEX = preload("res://assets/aswang/aswang_parried_stagger.png")
const LEAP_ATTACK_TEX = preload("res://assets/aswang/aswang_leap_attack.png")
const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")

const GRAVITY: float = 980.0
const PATROL_SPEED: float = 24.0
const CHASE_SPEED: float = 62.0
const ACCELERATION: float = 160.0
const DECELERATION: float = 250.0
const AGGRO_RANGE: float = 260.0
const ATTACK_RANGE: float = 42.0
const LEAP_TRIGGER_MIN_RANGE: float = 70.0
const LEAP_TRIGGER_MAX_RANGE: float = 230.0
const MAX_HEALTH: int = 3

# State & Combat variables
var current_state: State = State.IDLE
var health: int = MAX_HEALTH
var is_facing_left: bool = false
var is_dead: bool = false

# AI & Patrol variables
var spawn_x: float = 0.0
var patrol_direction: float = 1.0
var patrol_distance: float = 120.0
var patrol_timer: float = 0.0
var idle_wait_timer: float = 0.0
var attack_cooldown: float = 0.0
var has_hit_player_this_attack: bool = false
var target_player: CharacterBody2D = null

# Animation & Visual variables
var current_frame_idx: int = 0
var frame_timer: float = 0.0
var hurt_flash_timer: float = 0.0

# Attack Telegraphing & Stun Vulnerability
const TELEGRAPH_DURATION: float = 0.25
const STUN_DURATION: float = 1.2
var is_telegraphing: bool = false
var telegraph_timer: float = 0.0
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0

# Master Spritesheet & Animation Frame Maps
const FRAME_MAP = {
	State.IDLE: [0, 1, 2, 3],
	State.WALK: [8, 9, 10, 11, 12, 13, 14, 15],
	State.RUN: [16, 17, 18, 19, 20, 21, 22, 23],
	State.ATTACK: [24, 25, 26, 27, 28, 29, 30, 31],
	State.LEAP_ATTACK: [0, 1, 2, 3, 4, 5, 6, 7],
	State.PARRIED_STAGGER: [0, 1, 2, 3, 4, 5],
	State.HURT: [32, 33, 34, 35],
	State.DEATH: [40, 41, 42, 43, 44, 45, 46, 47]
}

const FRAME_DURATIONS = {
	State.IDLE: 0.14,      # ~7 FPS smooth breathing
	State.WALK: 0.12,      # 8.3 FPS smooth patrol creep
	State.RUN: 0.09,       # 11.1 FPS (0.72s full 8-frame sprint cycle)
	State.ATTACK: 0.085,   # 11.8 FPS snappy 8-frame claw strike
	State.LEAP_ATTACK: 0.09, # Snappy 8-frame leaping dive strike
	State.PARRIED_STAGGER: 0.10, # Reeling stagger into dazed slump
	State.HURT: 0.08,      # 12.5 FPS responsive hit flinch
	State.DEATH: 0.10      # 10 FPS shadow dissolution
}

# Node references
var sprite: Sprite2D
var stun_stars_sprite: Sprite2D
var anim_player: AnimationPlayer
var collision_shape: CollisionShape2D
var health_pips: Node2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	add_to_group("aswang")
	
	spawn_x = global_position.x
	setup_nodes()
	setup_animation_player()
	set_state(State.IDLE)
	
	# Random initial patrol direction
	if randf() > 0.5:
		patrol_direction = -1.0
		is_facing_left = true
	else:
		patrol_direction = 1.0
		is_facing_left = false


func setup_nodes() -> void:
	# Layer 3 (Enemies = 4), Mask 1 (TileMap / Ground = 1)
	collision_layer = 4
	collision_mask = 1
	
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")
		collision_shape = get_node_or_null("CollisionShape2D")
		stun_stars_sprite = get_node_or_null("StunStars")
		if not has_node("EnemyHealthPips"):
			health_pips = EnemyHealthPipsClass.new()
			health_pips.name = "EnemyHealthPips"
			health_pips.position = Vector2(0, -68.0)
			add_child(health_pips)
		else:
			health_pips = get_node("EnemyHealthPips")
		return
	
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sheet_tex = load("res://assets/aswang/aswang_spritesheet.png") as Texture2D
	if sheet_tex:
		sprite.texture = sheet_tex
	sprite.hframes = 8
	sprite.vframes = 6
	sprite.frame = 0
	sprite.centered = true
	sprite.scale = Vector2(0.5, 0.5)
	# Align bottom ground contact (Y=242 in 256x256 cell) precisely to origin (0, 0)
	sprite.position = Vector2(0, -58.0)
	add_child(sprite)
	
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape := CapsuleShape2D.new()
	shape.radius = 9.0
	shape.height = 32.0
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -16.0)
	add_child(collision_shape)
	
	stun_stars_sprite = Sprite2D.new()
	stun_stars_sprite.name = "StunStars"
	var stars_tex = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	if stars_tex:
		stun_stars_sprite.texture = stars_tex
	stun_stars_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stun_stars_sprite.hframes = 3
	stun_stars_sprite.vframes = 2
	stun_stars_sprite.frame = 0
	stun_stars_sprite.centered = true
	stun_stars_sprite.scale = Vector2(0.08, 0.08)
	stun_stars_sprite.position = Vector2(0, -62.0)
	stun_stars_sprite.visible = false
	stun_stars_sprite.z_index = 10
	add_child(stun_stars_sprite)
	
	health_pips = EnemyHealthPipsClass.new()
	health_pips.position = Vector2(0, -68.0)
	add_child(health_pips)


func setup_animation_player() -> void:
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)
	
	var lib := AnimationLibrary.new()
	
	# 1. IDLE (4 frames)
	var a_idle := Animation.new()
	a_idle.length = 0.56
	a_idle.loop_mode = Animation.LOOP_LINEAR
	var t_idle = a_idle.add_track(Animation.TYPE_VALUE)
	a_idle.track_set_path(t_idle, "Sprite2D:frame")
	a_idle.value_track_set_update_mode(t_idle, Animation.UPDATE_DISCRETE)
	for i in range(4):
		a_idle.track_insert_key(t_idle, i * 0.14, i)
	lib.add_animation("idle", a_idle)
	
	# 2. WALK (8 frames)
	var a_walk := Animation.new()
	a_walk.length = 0.96
	a_walk.loop_mode = Animation.LOOP_LINEAR
	var t_walk = a_walk.add_track(Animation.TYPE_VALUE)
	a_walk.track_set_path(t_walk, "Sprite2D:frame")
	a_walk.value_track_set_update_mode(t_walk, Animation.UPDATE_DISCRETE)
	for i in range(8):
		a_walk.track_insert_key(t_walk, i * 0.12, 8 + i)
	lib.add_animation("walk", a_walk)
	
	# 3. RUN / CHASE (8 frames - Forward-reaching chase sprint)
	var a_run := Animation.new()
	a_run.length = 0.72
	a_run.loop_mode = Animation.LOOP_LINEAR
	var t_run = a_run.add_track(Animation.TYPE_VALUE)
	a_run.track_set_path(t_run, "Sprite2D:frame")
	a_run.value_track_set_update_mode(t_run, Animation.UPDATE_DISCRETE)
	for i in range(8):
		a_run.track_insert_key(t_run, i * 0.09, 16 + i)
	lib.add_animation("run", a_run)
	
	# 4. ATTACK (8 frames - Complete claw slash sequence)
	var a_attack := Animation.new()
	a_attack.length = 0.68
	a_attack.loop_mode = Animation.LOOP_NONE
	var t_attack = a_attack.add_track(Animation.TYPE_VALUE)
	a_attack.track_set_path(t_attack, "Sprite2D:frame")
	a_attack.value_track_set_update_mode(t_attack, Animation.UPDATE_DISCRETE)
	for i in range(8):
		a_attack.track_insert_key(t_attack, i * 0.085, 24 + i)
	lib.add_animation("attack", a_attack)
	
	# 5. HURT (4 frames)
	var a_hurt := Animation.new()
	a_hurt.length = 0.32
	a_hurt.loop_mode = Animation.LOOP_NONE
	var t_hurt = a_hurt.add_track(Animation.TYPE_VALUE)
	a_hurt.track_set_path(t_hurt, "Sprite2D:frame")
	a_hurt.value_track_set_update_mode(t_hurt, Animation.UPDATE_DISCRETE)
	for i in range(4):
		a_hurt.track_insert_key(t_hurt, i * 0.08, 32 + i)
	lib.add_animation("hurt", a_hurt)
	
	# 6. DEATH (8 frames)
	var a_death := Animation.new()
	a_death.length = 0.80
	a_death.loop_mode = Animation.LOOP_NONE
	var t_death = a_death.add_track(Animation.TYPE_VALUE)
	a_death.track_set_path(t_death, "Sprite2D:frame")
	a_death.value_track_set_update_mode(t_death, Animation.UPDATE_DISCRETE)
	for i in range(8):
		a_death.track_insert_key(t_death, i * 0.10, 40 + i)
	lib.add_animation("death", a_death)
	
	anim_player.add_animation_library("", lib)


func _physics_process(delta: float) -> void:
	if is_dead:
		handle_death_process(delta)
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Red hurt flash timer
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0:
			sprite.modulate = Color(1, 1, 1, 1)
	
	# Attack cooldown timer
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	
	# Cache player target
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D
	
	# AI logic
	update_ai(delta)
	
	move_and_slide()
	
	# Facing direction
	sprite.flip_h = is_facing_left
	
	# Advance animation frame
	update_animation(delta)


func update_ai(delta: float) -> void:
	# Vulnerable Stunned State from Perfect Parry
	if is_stunned_vulnerable:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.8 * delta)
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = true
			stun_stars_sprite.frame = int(Time.get_ticks_msec() / 100.0) % 6
		# Golden dazed wobble
		var glow = 0.5 + 0.5 * sin(stun_timer * 22.0)
		sprite.modulate = Color(1.4 + glow * 0.4, 1.3 + glow * 0.3, 0.3, 1.0)
		if stun_timer <= 0.0:
			is_stunned_vulnerable = false
			if is_instance_valid(stun_stars_sprite):
				stun_stars_sprite.visible = false
			if is_instance_valid(health_pips):
				health_pips.set_vulnerable(false)
			sprite.modulate = Color(1, 1, 1, 1)
			attack_cooldown = 0.50
			set_state(State.IDLE)
		return
	
	# Locked states
	if current_state in [State.HURT, State.PARRIED_STAGGER]:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.6 * delta)
		return
	
	# Leap Attack Phase (Pounce Arc)
	if current_state == State.LEAP_ATTACK:
		var leap_dir: float = -1.0 if is_facing_left else 1.0
		# Frames 0-1: Coiled crouch on ground (0.45s total crouch with menacing crimson eye pulse)
		if current_frame_idx <= 1:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			var crouch_pulse = 0.5 + 0.5 * sin(frame_timer * 28.0)
			sprite.modulate = Color(1.0 + crouch_pulse * 0.5, 0.4, 0.4, 1.0)
		# Frame 2: Launch jump impulse (leaves ground into high arc)
		elif current_frame_idx == 2:
			sprite.modulate = Color(1, 1, 1, 1)
			if is_on_floor() and velocity.y >= 0.0:
				velocity.y = -340.0
			velocity.x = leap_dir * 240.0
		# Frames 3-4: Airborne apex and steep dive descent (0.45s air hangtime)
		elif current_frame_idx in [3, 4]:
			sprite.modulate = Color(1, 1, 1, 1)
			velocity.x = leap_dir * 240.0
		# Frames 5-6: Ground slam impact & hitbox check
		elif current_frame_idx in [5, 6]:
			sprite.modulate = Color(1, 1, 1, 1)
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.6 * delta)
			check_leap_attack_hit()
		# Frame 7: Recovery rise
		else:
			sprite.modulate = Color(1, 1, 1, 1)
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		return
	
	# Attack Telegraph Phase (0.25s eye/claw warning tell)
	if is_telegraphing:
		telegraph_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		# Pulsing crimson warning glow
		var pulse = 0.5 + 0.5 * sin(telegraph_timer * 30.0)
		sprite.modulate = Color(1.0 + pulse * 0.6, 0.3, 0.3, 1.0)
		
		if telegraph_timer <= 0.0:
			is_telegraphing = false
			sprite.modulate = Color(1, 1, 1, 1)
			has_hit_player_this_attack = false
			set_state(State.ATTACK)
		return
	
	if current_state == State.ATTACK:
		# Forward lunge momentum during windup (frames 0-2) then ease on recovery
		if current_frame_idx <= 2:
			var lunge_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = move_toward(velocity.x, lunge_dir * 30.0, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		
		# Check active damage frames
		check_attack_hit()
		return
	
	# Perception checks
	var player_in_sight: bool = false
	var dist_to_player: float = 9999.0
	var dx_to_player: float = 0.0
	var dy_to_player: float = 0.0
	
	if is_instance_valid(target_player):
		dx_to_player = target_player.global_position.x - global_position.x
		dy_to_player = target_player.global_position.y - global_position.y
		dist_to_player = abs(dx_to_player)
		
		# Aggro when player is nearby on similar vertical level
		if dist_to_player <= AGGRO_RANGE and abs(dy_to_player) < 80.0:
			player_in_sight = true
	
	# 1. Melee Claw Attack Trigger
	if player_in_sight and dist_to_player <= ATTACK_RANGE and abs(dy_to_player) < 35.0:
		is_facing_left = (dx_to_player < 0.0)
		if attack_cooldown <= 0.0 and not is_telegraphing:
			trigger_attack()
			return
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			if current_state != State.IDLE:
				set_state(State.IDLE)
			return
	
	# 2. Mid-Range Leap Attack Trigger (Airborne Pounce Strike)
	if player_in_sight and dist_to_player >= LEAP_TRIGGER_MIN_RANGE and dist_to_player <= LEAP_TRIGGER_MAX_RANGE and abs(dy_to_player) < 40.0:
		is_facing_left = (dx_to_player < 0.0)
		if attack_cooldown <= 0.0 and is_on_floor() and randf() < 0.65:
			trigger_leap_attack()
			return
	
	# 3. Chase / Aggro: Forward-reaching chase sprint towards player
	if player_in_sight:
		is_facing_left = (dx_to_player < 0.0)
		var chase_dir: float = -1.0 if is_facing_left else 1.0
		var target_vx: float = chase_dir * CHASE_SPEED
		velocity.x = move_toward(velocity.x, target_vx, ACCELERATION * delta)
		if current_state != State.RUN:
			set_state(State.RUN)
		return
	
	# 4. Patrol / Roam mode (No player in sight)
	if idle_wait_timer > 0.0:
		idle_wait_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		if current_state != State.IDLE:
			set_state(State.IDLE)
		return
	
	# Move in patrol direction
	var patrol_target_vx: float = patrol_direction * PATROL_SPEED
	velocity.x = move_toward(velocity.x, patrol_target_vx, ACCELERATION * delta)
	is_facing_left = (patrol_direction < 0.0)
	if current_state != State.WALK:
		set_state(State.WALK)
	
	# Turn around at patrol bounds or walls
	var offset_from_spawn = global_position.x - spawn_x
	if abs(offset_from_spawn) > patrol_distance or is_on_wall():
		patrol_direction = -patrol_direction
		is_facing_left = (patrol_direction < 0.0)
		idle_wait_timer = randf_range(1.4, 2.4)
		if current_state != State.IDLE:
			set_state(State.IDLE)


func trigger_attack() -> void:
	is_telegraphing = true
	telegraph_timer = TELEGRAPH_DURATION
	has_hit_player_this_attack = false
	velocity.x = 0.0
	set_state(State.IDLE)


func trigger_leap_attack() -> void:
	has_hit_player_this_attack = false
	is_facing_left = (target_player.global_position.x < global_position.x) if is_instance_valid(target_player) else is_facing_left
	velocity.x = 0.0
	set_state(State.LEAP_ATTACK)


func check_attack_hit() -> void:
	# Active claw strike occurs on frames 2, 3, 4 (raw_attack03, 04, 05)
	if current_frame_idx in [2, 3, 4] and not has_hit_player_this_attack:
		if is_instance_valid(target_player):
			var dx = target_player.global_position.x - global_position.x
			var dy = target_player.global_position.y - global_position.y
			var dist = abs(dx)
			
			var in_front = (is_facing_left and dx < 5.0) or (not is_facing_left and dx > -5.0)
			if in_front and dist <= ATTACK_RANGE + 12.0 and abs(dy) < 35.0:
				has_hit_player_this_attack = true
				apply_attack_to_player()


func check_leap_attack_hit() -> void:
	if not has_hit_player_this_attack and is_instance_valid(target_player):
		var dx = target_player.global_position.x - global_position.x
		var dy = target_player.global_position.y - global_position.y
		var dist = abs(dx)
		
		var in_front = (is_facing_left and dx < 8.0) or (not is_facing_left and dx > -8.0)
		if in_front and dist <= 56.0 and abs(dy) < 40.0:
			has_hit_player_this_attack = true
			apply_attack_to_player()


func apply_attack_to_player() -> void:
	if not is_instance_valid(target_player):
		return
	
	var enemy_dir: float = -1.0 if is_facing_left else 1.0
	if target_player.has_method("take_damage_from_enemy"):
		target_player.take_damage_from_enemy(1, enemy_dir, self)
	elif target_player.has_signal("player_died"):
		target_player.player_died.emit()


func deflect_by_parry(deflect_dir: float) -> void:
	if is_dead:
		return
	
	is_telegraphing = false
	is_stunned_vulnerable = true
	stun_timer = STUN_DURATION
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = true
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, true)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -56.0), "STAGGERED!", Color(1.0, 0.85, 0.2), 14, true)
	
	# Forceful backward deflection recoil
	velocity.x = deflect_dir * 230.0
	velocity.y = -100.0
	
	# Deflection clash flash
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 1.8, 0.4, 1.0)
	hurt_flash_timer = 0.25
	set_state(State.PARRIED_STAGGER)


func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if is_dead:
		return
	
	is_telegraphing = false
	
	# If hit while Vulnerable / Stunned from a Perfect Block -> Instant 1-Hit Lethal Riposte!
	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		health = 0
		if is_instance_valid(health_pips):
			health_pips.update_health(0, MAX_HEALTH, false)
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -52.0), "CRIT 99!", Color(1.0, 0.9, 0.2), 16, true)
		if is_instance_valid(sprite):
			sprite.modulate = Color(2.5, 2.0, 0.5, 1.0)
		trigger_death()
		return
	
	health -= amount
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, false)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -45.0), str(amount), Color(1.0, 0.35, 0.25), 14, false)

	# Visceral Aswang Blood Splatter
	VFX.spawn_blood_splatter(get_parent(), global_position + Vector2(0, -42.0), Vector2(knockback_dir, -0.4), 1.6 if health <= 0 else 1.1, false)
	
	# 1. White impact flash (0.05s) then crimson hurt flash
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	hurt_flash_timer = 0.20
	if is_inside_tree():
		get_tree().create_timer(0.05).timeout.connect(func():
			if not is_dead and is_instance_valid(sprite) and hurt_flash_timer > 0.0:
				sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)
		)
	
	# Recoil impulse
	var impulse = 180.0 if amount < 2 else 240.0
	velocity.x = knockback_dir * impulse
	velocity.y = -130.0
	
	if health <= 0:
		trigger_death()
	else:
		set_state(State.HURT)


func trigger_death() -> void:
	is_dead = true
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = false
	if is_instance_valid(health_pips):
		health_pips.visible = false
	velocity = Vector2.ZERO
	set_state(State.DEATH)
	aswang_died.emit(self)


func handle_death_process(delta: float) -> void:
	velocity = Vector2.ZERO
	update_animation(delta)


func set_state(new_state: State) -> void:
	if current_state == new_state and new_state not in [State.HURT, State.ATTACK, State.LEAP_ATTACK, State.PARRIED_STAGGER, State.DEATH]:
		return
	
	current_state = new_state
	current_frame_idx = 0
	frame_timer = 0.0
	
	# Swap texture according to animation asset
	if is_instance_valid(sprite):
		match current_state:
			State.PARRIED_STAGGER:
				sprite.texture = PARRIED_STAGGER_TEX
				sprite.hframes = 6
				sprite.vframes = 1
			State.LEAP_ATTACK:
				sprite.texture = LEAP_ATTACK_TEX
				sprite.hframes = 8
				sprite.vframes = 1
			_:
				if sprite.texture != MAIN_SHEET_TEX:
					sprite.texture = MAIN_SHEET_TEX
					sprite.hframes = 8
					sprite.vframes = 6
	
	apply_current_frame()


func update_animation(delta: float) -> void:
	var frames: Array = FRAME_MAP.get(current_state, [0])
	if frames.is_empty():
		return
	
	var cur_duration: float = FRAME_DURATIONS.get(current_state, 0.1)
	if current_state == State.LEAP_ATTACK:
		match current_frame_idx:
			0: cur_duration = 0.22 # Low crouch windup
			1: cur_duration = 0.23 # Deep predator spring coil (total 0.45s crouch!)
			2: cur_duration = 0.15 # Launch takeoff
			3: cur_duration = 0.16 # High apex soaring pounce
			4: cur_duration = 0.14 # Airborne dive (total 0.45s air hangtime!)
			5: cur_duration = 0.10 # Ground slam impact
			6: cur_duration = 0.12 # Follow-through slide
			_: cur_duration = 0.16 # Recovery stand

	frame_timer += delta
	
	if frame_timer >= cur_duration:
		frame_timer -= cur_duration
		
		match current_state:
			State.ATTACK:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					attack_cooldown = 0.50
					set_state(State.IDLE)
					return
			
			State.LEAP_ATTACK:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					attack_cooldown = 0.70
					set_state(State.IDLE)
					return
			
			State.PARRIED_STAGGER:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					# Loop dazed frames 4 and 5 while in vulnerable stun
					current_frame_idx = 4 if current_frame_idx == 5 else 5
			
			State.HURT:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					set_state(State.IDLE)
					return
			
			State.DEATH:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
					if current_frame_idx >= 3:
						var fade = 1.0 - float(current_frame_idx - 2) / 5.0
						sprite.modulate.a = clamp(fade, 0.0, 1.0)
				else:
					queue_free()
					return
			
			_:
				# Looping states (IDLE, WALK, RUN)
				current_frame_idx = (current_frame_idx + 1) % frames.size()
		
		apply_current_frame()


func apply_current_frame() -> void:
	if not is_instance_valid(sprite):
		return
	
	var frames: Array = FRAME_MAP.get(current_state, [0])
	var idx = clamp(current_frame_idx, 0, frames.size() - 1)
	sprite.frame = frames[idx]

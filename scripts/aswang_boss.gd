class_name AswangBoss
extends CharacterBody2D

signal boss_hp_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(new_phase: int)
signal boss_died(boss: AswangBoss)
signal boss_summon_requested(pos: Vector2)
signal boss_lightning_requested(pos: Vector2)

enum State {
	INTRO,
	IDLE,
	CHASE,
	ATTACK_COMBO,
	LEAP_SLAM,
	SHADOW_DASH,
	ENRAGE_ROAR,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const MAIN_SHEET_TEX = preload("res://assets/aswang/aswang_spritesheet.png")
const PARRIED_STAGGER_TEX = preload("res://assets/aswang/aswang_parried_stagger.png")
const LEAP_ATTACK_TEX = preload("res://assets/aswang/aswang_leap_attack.png")

const GRAVITY: float = 980.0
const MAX_HEALTH: int = 20

# AI Tuning
const SPEED_PHASE_1: float = 90.0
const SPEED_PHASE_2: float = 145.0
const LEAP_COOLDOWN: float = 5.0

var current_state: State = State.INTRO
var health: int = MAX_HEALTH
var current_phase: int = 1
var is_facing_left: bool = true
var is_dead: bool = false
var has_enraged: bool = false

# Timers & Combat
var state_timer: float = 0.0
var attack_cooldown: float = 1.0
var leap_cooldown_timer: float = 3.0
var shadow_dash_cooldown: float = 4.0
var lightning_strike_cooldown: float = 3.5
var combo_step: int = 0
var has_hit_player_this_step: bool = false
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var ghost_trail_timer: float = 0.0

# Animation
var current_frame_idx: int = 0
var frame_timer: float = 0.0
var leap_target_x: float = 0.0

# Node references
var sprite: Sprite2D
var stun_stars_sprite: Sprite2D
var collision_shape: CollisionShape2D
var roar_audio_player: AudioStreamPlayer2D
var target_player: CharacterBody2D = null

const FRAME_MAP = {
	State.INTRO: [0, 1, 2, 3],
	State.IDLE: [0, 1, 2, 3],
	State.CHASE: [16, 17, 18, 19, 20, 21, 22, 23],
	State.ATTACK_COMBO: [24, 25, 26, 27, 28, 29, 30, 31],
	State.LEAP_SLAM: [0, 1, 2, 3, 4, 5, 6, 7],
	State.SHADOW_DASH: [16, 18, 20, 22],
	State.ENRAGE_ROAR: [0, 1, 2, 3, 0, 1, 2, 3],
	State.PARRIED_STAGGER: [0, 1, 2, 3, 4, 5],
	State.HURT: [32, 33, 34, 35],
	State.DEATH: [40, 41, 42, 43, 44, 45, 46, 47]
}

const FRAME_DURATIONS = {
	State.INTRO: 0.16,
	State.IDLE: 0.15,
	State.CHASE: 0.075,
	State.ATTACK_COMBO: 0.07,
	State.LEAP_SLAM: 0.085,
	State.SHADOW_DASH: 0.05,
	State.ENRAGE_ROAR: 0.14,
	State.PARRIED_STAGGER: 0.12,
	State.HURT: 0.08,
	State.DEATH: 0.15
}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	add_to_group("boss")
	
	setup_nodes()
	set_state(State.INTRO)
	state_timer = 2.0


func setup_nodes() -> void:
	collision_layer = 4
	collision_mask = 1

	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = MAIN_SHEET_TEX
	sprite.hframes = 8
	sprite.vframes = 6
	sprite.frame = 0
	sprite.centered = true
	# 1.6x Scale for imposing boss presence
	sprite.scale = Vector2(0.80, 0.80)
	sprite.position = Vector2(0, -92.0)
	sprite.modulate = Color(0.9, 0.55, 0.65, 1.0) # Corrupted matriarch aura
	add_child(sprite)

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape := CapsuleShape2D.new()
	shape.radius = 16.0
	shape.height = 54.0
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -27.0)
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
	stun_stars_sprite.scale = Vector2(0.12, 0.12)
	stun_stars_sprite.position = Vector2(0, -100.0)
	stun_stars_sprite.visible = false
	stun_stars_sprite.z_index = 10
	add_child(stun_stars_sprite)

	roar_audio_player = AudioStreamPlayer2D.new()
	roar_audio_player.name = "RoarAudio"
	roar_audio_player.bus = "Master"
	roar_audio_player.stream = ProceduralAudio.get_boss_roar()
	add_child(roar_audio_player)


func _physics_process(delta: float) -> void:
	if is_dead:
		handle_death_process(delta)
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	# Find player
	if not is_instance_valid(target_player):
		target_player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	# Hurt flash countdown
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and is_instance_valid(sprite) and not is_stunned_vulnerable:
			var base_tint = Color(1.2, 0.35, 0.35, 1.0) if current_phase == 2 else Color(0.9, 0.55, 0.65, 1.0)
			sprite.modulate = base_tint

	# Cooldowns
	if attack_cooldown > 0.0: attack_cooldown -= delta
	if leap_cooldown_timer > 0.0: leap_cooldown_timer -= delta
	if shadow_dash_cooldown > 0.0: shadow_dash_cooldown -= delta
	if current_phase == 2:
		lightning_strike_cooldown -= delta
		if lightning_strike_cooldown <= 0.0:
			lightning_strike_cooldown = randf_range(2.8, 4.5)
			if is_instance_valid(target_player):
				boss_lightning_requested.emit(target_player.global_position + Vector2(randf_range(-40, 40), 0))

	# Trail afterimages during high-mobility states
	if current_state in [State.LEAP_SLAM, State.SHADOW_DASH] or (current_phase == 2 and current_state == State.CHASE):
		ghost_trail_timer -= delta
		if ghost_trail_timer <= 0.0:
			ghost_trail_timer = 0.08
			var trail_col = Color(0.9, 0.15, 0.15, 0.6) if current_phase == 2 else Color(0.4, 0.2, 0.6, 0.5)
			VFX.spawn_ghost_trail(get_parent(), sprite.texture, sprite.global_position, sprite.scale, sprite.flip_h, trail_col)

	update_ai(delta)
	update_animation(delta)
	move_and_slide()


func update_ai(delta: float) -> void:
	if is_stunned_vulnerable:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = true
			stun_stars_sprite.frame = int(Time.get_ticks_msec() / 100.0) % 6
		var glow = 0.5 + 0.5 * sin(stun_timer * 20.0)
		sprite.modulate = Color(1.5 + glow * 0.5, 1.4 + glow * 0.4, 0.3, 1.0)
		if stun_timer <= 0.0:
			is_stunned_vulnerable = false
			if is_instance_valid(stun_stars_sprite):
				stun_stars_sprite.visible = false
			sprite.modulate = Color(1.2, 0.35, 0.35, 1.0) if current_phase == 2 else Color(0.9, 0.55, 0.65, 1.0)
			attack_cooldown = 0.8
			set_state(State.IDLE)
		return

	match current_state:
		State.INTRO:
			velocity.x = 0.0
			state_timer -= delta
			if state_timer <= 1.2 and not roar_audio_player.playing:
				roar_audio_player.play()
				VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -90), "THE MATRIARCH AWAKENS", Color(1.0, 0.2, 0.2), 16, true)
			if state_timer <= 0.0:
				set_state(State.IDLE)

		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
			state_timer -= delta
			if is_instance_valid(target_player):
				is_facing_left = (target_player.global_position.x < global_position.x)
				sprite.flip_h = not is_facing_left
				var dist = abs(target_player.global_position.x - global_position.x)
				
				# Phase 2 Shadow Dash decision
				if current_phase == 2 and shadow_dash_cooldown <= 0.0 and dist > 90.0:
					start_shadow_dash()
					return
				
				# Leap slam decision
				if leap_cooldown_timer <= 0.0 and dist > 120.0:
					start_leap_slam()
					return
				
				if dist <= 56.0 and attack_cooldown <= 0.0:
					start_attack_combo()
					return
				
				if state_timer <= 0.0:
					set_state(State.CHASE)

		State.CHASE:
			if not is_instance_valid(target_player):
				set_state(State.IDLE)
				return
			
			var dx = target_player.global_position.x - global_position.x
			var dist = abs(dx)
			is_facing_left = (dx < 0.0)
			sprite.flip_h = not is_facing_left
			
			var cur_speed = SPEED_PHASE_2 if current_phase == 2 else SPEED_PHASE_1
			velocity.x = move_toward(velocity.x, (-1.0 if is_facing_left else 1.0) * cur_speed, 450.0 * delta)
			
			# Check attack ranges
			if dist <= 54.0 and attack_cooldown <= 0.0:
				start_attack_combo()
			elif leap_cooldown_timer <= 0.0 and dist > 140.0:
				start_leap_slam()
			elif current_phase == 2 and shadow_dash_cooldown <= 0.0 and dist > 180.0:
				start_shadow_dash()

		State.ATTACK_COMBO:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			# Active hitboxes during mid-strike frames
			if current_frame_idx in [3, 4] and not has_hit_player_this_step:
				check_claw_hit_player()

		State.LEAP_SLAM:
			match current_frame_idx:
				0, 1:
					# Windup crouch
					velocity.x = 0.0
				2, 3, 4:
					# High airborne leap arc
					var dir_x = signf(leap_target_x - global_position.x)
					velocity.x = dir_x * 240.0
				5:
					# Ground slam impact
					velocity.x = 0.0
					if not has_hit_player_this_step:
						trigger_slam_impact()
				_:
					velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)

		State.SHADOW_DASH:
			state_timer -= delta
			if state_timer <= 0.0:
				# Reappear behind player with an instant claw strike!
				start_attack_combo()

		State.ENRAGE_ROAR:
			velocity.x = 0.0
			state_timer -= delta
			if state_timer <= 0.0:
				set_state(State.CHASE)

		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				set_state(State.CHASE)


func start_attack_combo() -> void:
	combo_step = 0
	has_hit_player_this_step = false
	set_state(State.ATTACK_COMBO)
	# Telegraph flash
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 0.3, 0.3, 1.0)
		get_tree().create_timer(0.12).timeout.connect(func():
			if not is_dead and is_instance_valid(sprite) and not is_stunned_vulnerable:
				var base_tint = Color(1.2, 0.35, 0.35, 1.0) if current_phase == 2 else Color(0.9, 0.55, 0.65, 1.0)
				sprite.modulate = base_tint
		)


func check_claw_hit_player() -> void:
	if not is_instance_valid(target_player) or has_hit_player_this_step:
		return
	
	var dx = target_player.global_position.x - global_position.x
	var dy = target_player.global_position.y - global_position.y
	var dist = abs(dx)
	var in_front = (is_facing_left and dx < 12.0) or (not is_facing_left and dx > -12.0)
	
	if in_front and dist <= 62.0 and abs(dy) < 50.0:
		has_hit_player_this_step = true
		var enemy_dir: float = -1.0 if is_facing_left else 1.0
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(1, enemy_dir, self)


func start_leap_slam() -> void:
	leap_cooldown_timer = LEAP_COOLDOWN
	has_hit_player_this_step = false
	if is_instance_valid(target_player):
		leap_target_x = target_player.global_position.x
	else:
		leap_target_x = global_position.x + (150.0 if not is_facing_left else -150.0)
	set_state(State.LEAP_SLAM)
	velocity.y = -380.0 # High vault


func trigger_slam_impact() -> void:
	has_hit_player_this_step = true
	VFX.spawn_guard_impact(get_parent(), global_position + Vector2(0, -6.0))
	if is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= 90.0:
			var dir_x = signf(target_player.global_position.x - global_position.x)
			if dir_x == 0: dir_x = 1.0
			if target_player.has_method("take_damage_from_enemy"):
				target_player.take_damage_from_enemy(1, dir_x, self)


func start_shadow_dash() -> void:
	shadow_dash_cooldown = 4.5
	if not is_instance_valid(target_player):
		return
	
	set_state(State.SHADOW_DASH)
	state_timer = 0.28
	# Dash directly behind the player
	var target_x = target_player.global_position.x + (70.0 if target_player.global_position.x > global_position.x else -70.0)
	velocity.x = signf(target_x - global_position.x) * 380.0
	is_facing_left = (target_player.global_position.x < global_position.x)
	sprite.flip_h = not is_facing_left


func trigger_enrage() -> void:
	has_enraged = true
	current_phase = 2
	boss_phase_changed.emit(2)
	
	if is_instance_valid(roar_audio_player):
		roar_audio_player.play()
	
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -96.0), "TEMPEST FRENZY!", Color(1.0, 0.15, 0.15), 18, true)
	sprite.modulate = Color(2.5, 0.2, 0.2, 1.0)
	
	# Request minion summons
	boss_summon_requested.emit(global_position + Vector2(-120, -10))
	boss_summon_requested.emit(global_position + Vector2(120, -10))
	
	state_timer = 1.2
	set_state(State.ENRAGE_ROAR)


func deflect_by_parry(deflect_dir: float) -> void:
	if is_dead:
		return
	
	is_stunned_vulnerable = true
	stun_timer = 1.3
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = true
	
	velocity.x = deflect_dir * 180.0
	velocity.y = -80.0
	
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.0, 1.8, 0.4, 1.0)
	hurt_flash_timer = 0.25
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -80.0), "STAGGERED!", Color(1.0, 0.88, 0.2), 16, true)
	set_state(State.PARRIED_STAGGER)


func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if is_dead:
		return
	
	var actual_damage = amount
	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if is_instance_valid(stun_stars_sprite):
			stun_stars_sprite.visible = false
		actual_damage = amount * 4 # Massive critical riposte chunk damage
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -84.0), "CRIT %d!" % actual_damage, Color(1.0, 0.9, 0.2), 18, true)
	else:
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -70.0), str(amount), Color(1.0, 0.35, 0.25), 15, false)

	health = maxi(0, health - actual_damage)
	boss_hp_changed.emit(health, MAX_HEALTH)

	# Visceral blood burst
	VFX.spawn_blood_splatter(get_parent(), global_position + Vector2(0, -60.0), Vector2(knockback_dir, -0.4), 2.0 if health <= 0 else 1.3, false)

	# White impact flash
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	hurt_flash_timer = 0.18
	if is_inside_tree():
		get_tree().create_timer(0.05).timeout.connect(func():
			if not is_dead and is_instance_valid(sprite) and hurt_flash_timer > 0.0:
				sprite.modulate = Color(1.0, 0.2, 0.2, 1.0)
		)

	# Recoil impulse
	velocity.x = knockback_dir * 110.0
	velocity.y = -60.0

	if health <= 0:
		trigger_death()
	elif health <= 10 and not has_enraged:
		trigger_enrage()
	elif current_state not in [State.ATTACK_COMBO, State.LEAP_SLAM, State.SHADOW_DASH]:
		state_timer = 0.20
		set_state(State.HURT)


func trigger_death() -> void:
	is_dead = true
	if is_instance_valid(stun_stars_sprite):
		stun_stars_sprite.visible = false
	velocity = Vector2.ZERO
	set_state(State.DEATH)
	boss_died.emit(self)


func handle_death_process(delta: float) -> void:
	velocity = Vector2.ZERO
	update_animation(delta)


func set_state(new_state: State) -> void:
	if current_state == new_state and new_state not in [State.HURT, State.ATTACK_COMBO, State.PARRIED_STAGGER, State.DEATH]:
		return
	
	current_state = new_state
	current_frame_idx = 0
	frame_timer = 0.0

	if is_instance_valid(sprite):
		match current_state:
			State.PARRIED_STAGGER:
				sprite.texture = PARRIED_STAGGER_TEX
				sprite.hframes = 6
				sprite.vframes = 1
			State.LEAP_SLAM:
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
	if current_state == State.LEAP_SLAM:
		match current_frame_idx:
			0: cur_duration = 0.22
			1: cur_duration = 0.20
			2: cur_duration = 0.14
			3: cur_duration = 0.15
			4: cur_duration = 0.14
			5: cur_duration = 0.12
			6: cur_duration = 0.14
			_: cur_duration = 0.18

	frame_timer += delta
	if frame_timer >= cur_duration:
		frame_timer -= cur_duration
		current_frame_idx += 1
		
		if current_frame_idx >= frames.size():
			match current_state:
				State.ATTACK_COMBO:
					var max_combos = 3 if current_phase == 2 else 2
					combo_step += 1
					if combo_step < max_combos:
						current_frame_idx = 0
						has_hit_player_this_step = false
					else:
						attack_cooldown = 0.9 if current_phase == 2 else 1.3
						set_state(State.IDLE)
						return
				State.LEAP_SLAM, State.SHADOW_DASH, State.HURT:
					set_state(State.IDLE)
					return
				State.DEATH:
					current_frame_idx = frames.size() - 1
					return
				_:
					current_frame_idx = 0
		
		apply_current_frame()


func apply_current_frame() -> void:
	var frames: Array = FRAME_MAP.get(current_state, [0])
	if frames.is_empty():
		return
	
	var frame_val: int = frames[clampi(current_frame_idx, 0, frames.size() - 1)]
	if is_instance_valid(sprite):
		sprite.frame = frame_val
		sprite.flip_h = not is_facing_left

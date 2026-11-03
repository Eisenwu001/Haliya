class_name MayonVanguardMiniboss
extends CharacterBody2D

signal skeleton_died(enemy: MayonVanguardMiniboss)
signal miniboss_died(enemy: MayonVanguardMiniboss)
signal boss_hp_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(new_phase: int)

enum State {
	IDLE_GUARD,
	MARCH,
	CHASE,
	TELEGRAPH_LUNGE,
	LUNGE_THRUST,
	TELEGRAPH_SHIELD_BASH,
	SHIELD_BASH_IMPACT,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")
const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

static func load_texture(res_path: String) -> Texture2D:
	if ResourceLoader.exists(res_path):
		var res = load(res_path)
		if res is Texture2D:
			return res
	var global_p = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

const GRAVITY: float = 980.0
const MARCH_SPEED: float = 40.0
const CHASE_SPEED: float = 78.0
const LUNGE_SPEED: float = 195.0
const SHIELD_BASH_SPEED: float = 155.0
const ACCELERATION: float = 230.0
const DECELERATION: float = 380.0
const AGGRO_RANGE: float = 330.0
const ATTACK_TRIGGER_RANGE: float = 80.0
const BASH_TRIGGER_RANGE: float = 58.0
const MAX_HEALTH: int = 80

var current_state: State = State.IDLE_GUARD
var health: int = MAX_HEALTH
var is_facing_left: bool = true
var is_dead: bool = false
var is_enraged: bool = false

# AI & Combat
var spawn_x: float = 0.0
var patrol_direction: float = -1.0
var patrol_distance: float = 180.0
var state_timer: float = 0.0
var attack_cooldown: float = 0.8
var has_hit_player_this_attack: bool = false
var has_spawned_sparks_this_attack: bool = false
var has_triggered_flame_wave: bool = false
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var march_anim_timer: float = 0.0
var target_player: CharacterBody2D = null

# Audio players
var sfx_player: AudioStreamPlayer2D

# Visual & Nodes
var sprite: Sprite2D
var stun_stars: Sprite2D
var col_shape: CollisionShape2D
var health_pips: Node2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	add_to_group("skeleton")
	add_to_group("miniboss")
	
	spawn_x = global_position.x
	setup_nodes()
	set_state(State.IDLE_GUARD)
	state_timer = 1.0

func setup_nodes() -> void:
	collision_layer = 4 # Layer 3: Enemies
	collision_mask = 1  # Layer 1: Solid ground
	
	# Master Spritesheet: 2048x1024, 8 cols x 4 rows (256x256 per frame)
	# Row 0: Idle Guard (0), March (1..7)
	# Row 1: Flame Sword (8: windup, 9: flame sweep, 10: flame thrust)
	# Row 2: Shield Bash (16: brace, 17: impact spark burst, 18: recover)
	# Row 3: Reactions & Complete Death Animation
	#        24: Stagger, 25: Hurt, 26: Death 1, 27: Death 2, 28: Death 3, 29: Death 4
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = load_texture("res://assets/miniboss/mayon_vanguard/mayon_vanguard_spritesheet.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hframes = 8
	sprite.vframes = 4
	sprite.frame = 0
	sprite.centered = true
	sprite.scale = Vector2(0.62, 0.62)
	# Aligned baseline: foot contact Y=240 in 256 frame mapped to (0, -69.0)
	sprite.position = Vector2(0, -69.0)
	add_child(sprite)
	
	# Capsule Collision Shape
	col_shape = CollisionShape2D.new()
	col_shape.name = "CollisionShape2D"
	var shape := CapsuleShape2D.new()
	shape.radius = 16.0
	shape.height = 56.0
	col_shape.shape = shape
	col_shape.position = Vector2(0, -28.0)
	add_child(col_shape)
	
	# Stun Stars
	stun_stars = Sprite2D.new()
	stun_stars.name = "StunStars"
	var stars_tex = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	if stars_tex:
		stun_stars.texture = stars_tex
		stun_stars.hframes = 3
		stun_stars.vframes = 2
	stun_stars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stun_stars.scale = Vector2(0.12, 0.12)
	stun_stars.position = Vector2(0, -78.0)
	stun_stars.visible = false
	stun_stars.z_index = 25
	add_child(stun_stars)
	
	# Overhead health pips disabled - boss health is displayed in the bottom cinematic Boss HUD
	health_pips = null
	
	# SFX Audio Player
	sfx_player = AudioStreamPlayer2D.new()
	sfx_player.name = "MinibossSFX"
	sfx_player.max_distance = 600.0
	sfx_player.bus = "Master"
	add_child(sfx_player)

func set_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	has_hit_player_this_attack = false
	has_spawned_sparks_this_attack = false
	has_triggered_flame_wave = false
	
	if not sprite:
		return
		
	match current_state:
		State.IDLE_GUARD:
			sprite.frame = 0
		State.MARCH, State.CHASE:
			sprite.frame = 1 + (int(march_anim_timer) % 7)
		State.TELEGRAPH_LUNGE:
			sprite.frame = 8
		State.LUNGE_THRUST:
			sprite.frame = 9
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * (LUNGE_SPEED * (1.18 if is_enraged else 1.0))
		State.TELEGRAPH_SHIELD_BASH:
			sprite.frame = 16
		State.SHIELD_BASH_IMPACT:
			sprite.frame = 17
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * (SHIELD_BASH_SPEED * (1.18 if is_enraged else 1.0))
		State.PARRIED_STAGGER:
			sprite.frame = 24
		State.HURT:
			sprite.frame = 25
		State.DEATH:
			sprite.frame = 26

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Pit fall safety
	if global_position.y > 360.0:
		health = 0
		trigger_death()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Cooldowns and hurt flash
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and current_state != State.PARRIED_STAGGER and current_state != State.TELEGRAPH_LUNGE and current_state != State.TELEGRAPH_SHIELD_BASH:
			sprite.modulate = Color(1.2, 0.8, 0.8, 1.0) if is_enraged else Color(1, 1, 1, 1)

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# Target player detection
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D

	var facing_dir: float = -1.0 if is_facing_left else 1.0

	# ── Parried Stagger / Vulnerable State ─────────────────────────────────────
	if current_state == State.PARRIED_STAGGER:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.7 * delta)
		if is_instance_valid(stun_stars):
			stun_stars.visible = true
			stun_stars.frame = int(Time.get_ticks_msec() / 90.0) % 6
		# Golden dazed shimmer
		var pulse = 0.5 + 0.5 * sin(stun_timer * 20.0)
		sprite.modulate = Color(1.6 + pulse * 0.4, 1.4 + pulse * 0.3, 0.4, 1.0)
		sprite.frame = 24
		if stun_timer <= 0.0:
			is_stunned_vulnerable = false
			if is_instance_valid(stun_stars):
				stun_stars.visible = false
			if is_instance_valid(health_pips):
				health_pips.set_vulnerable(false)
			sprite.modulate = Color(1.2, 0.8, 0.8, 1.0) if is_enraged else Color(1, 1, 1, 1)
			attack_cooldown = 0.6 if is_enraged else 0.9
			set_state(State.IDLE_GUARD)
		move_and_slide()
		return

	# ── Hurt State (Only entered when not in hyper-armor attacks) ──────────────
	if current_state == State.HURT:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 25
		if state_timer >= 0.20:
			set_state(State.CHASE)
		move_and_slide()
		return

	# ── Attack 1: Flame Sword Telegraph Phase ──────────────────────────────────
	if current_state == State.TELEGRAPH_LUNGE:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 8
		# Blazing volcanic orange pulse
		var pulse = 0.5 + 0.5 * sin(state_timer * 32.0)
		sprite.modulate = Color(2.2 + pulse * 0.5, 1.1 + pulse * 0.4, 0.2, 1.0)
		var windup_dur: float = 0.32 if is_enraged else 0.44
		if state_timer >= windup_dur:
			sprite.modulate = Color(1, 1, 1, 1)
			set_state(State.LUNGE_THRUST)
		move_and_slide()
		return

	# ── Attack 1: Flame Sword Slash & Thrust Execution ─────────────────────────
	if current_state == State.LUNGE_THRUST:
		state_timer += delta
		# 0.00 - 0.14s: Low sweeping flame slash (Frame 9)
		if state_timer < 0.14:
			sprite.frame = 9
			velocity.x = facing_dir * (LUNGE_SPEED * (1.18 if is_enraged else 1.0))
		# 0.14 - 0.35s: Fiery thrust strike (Frame 10)
		elif state_timer < 0.35:
			sprite.frame = 10
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.8 * delta)
			if not has_spawned_sparks_this_attack:
				has_spawned_sparks_this_attack = true
				_trigger_screen_shake(0.55)
				_trigger_hit_stop(0.055)
				play_sound(ProceduralAudioScript.get_swing_whoosh(true), 1.2)
				spawn_volcanic_sparks(Color(1.0, 0.55, 0.15, 0.95), 12)
				spawn_molten_flame_wave(facing_dir)
			if not has_hit_player_this_attack:
				check_attack_hitbox(82.0, 44.0, 2, "flame_thrust")
		# 0.35 - 0.55s: Recovery
		else:
			sprite.frame = 10
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		var total_thrust_dur = 0.45 if is_enraged else 0.55
		if state_timer >= total_thrust_dur:
			attack_cooldown = 0.6 if is_enraged else 1.0
			set_state(State.IDLE_GUARD)
		move_and_slide()
		return

	# ── Attack 2: Shield Bash Telegraph Phase ──────────────────────────────────
	if current_state == State.TELEGRAPH_SHIELD_BASH:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 16
		# Golden shield gleam tell
		var pulse = 0.5 + 0.5 * sin(state_timer * 32.0)
		sprite.modulate = Color(2.0 + pulse * 0.4, 1.8 + pulse * 0.3, 0.4, 1.0)
		var bash_windup = 0.20 if is_enraged else 0.28
		if state_timer >= bash_windup:
			sprite.modulate = Color(1, 1, 1, 1)
			set_state(State.SHIELD_BASH_IMPACT)
		move_and_slide()
		return

	# ── Attack 2: Shield Bash Impact Execution ─────────────────────────────────
	if current_state == State.SHIELD_BASH_IMPACT:
		state_timer += delta
		if state_timer < 0.16:
			sprite.frame = 17
			velocity.x = facing_dir * (SHIELD_BASH_SPEED * (1.18 if is_enraged else 1.0))
			if not has_spawned_sparks_this_attack:
				has_spawned_sparks_this_attack = true
				_trigger_screen_shake(0.60)
				_trigger_hit_stop(0.06)
				play_sound(ProceduralAudioScript.get_landing_thud(), 1.3)
				spawn_volcanic_sparks(Color(1.0, 0.85, 0.3, 0.95), 14)
				spawn_ground_dust(Color(0.5, 0.3, 0.15, 0.8), 8)
			if not has_hit_player_this_attack:
				check_attack_hitbox(68.0, 44.0, 1, "shield_bash")
		elif state_timer < 0.38:
			sprite.frame = 18
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		else:
			sprite.frame = 18
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		var bash_total = 0.40 if is_enraged else 0.48
		if state_timer >= bash_total:
			attack_cooldown = 0.5 if is_enraged else 0.8
			set_state(State.IDLE_GUARD)
		move_and_slide()
		return

	# ── Perception & Target Distance ──────────────────────────────────────────
	var dist_to_player: float = 9999.0
	var dx_to_player: float = 0.0
	var player_in_range: bool = false
	if is_instance_valid(target_player) and not target_player.get("is_dead"):
		dx_to_player = target_player.global_position.x - global_position.x
		dist_to_player = abs(dx_to_player)
		var dy = abs(target_player.global_position.y - global_position.y)
		if dist_to_player < AGGRO_RANGE and dy < 95.0:
			player_in_range = true

	# ── Normal States: IDLE_GUARD, MARCH, CHASE ───────────────────────────────
	var cur_speed = CHASE_SPEED * (1.25 if is_enraged else 1.0)
	match current_state:
		State.IDLE_GUARD:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			sprite.frame = 0
			state_timer += delta
			if player_in_range:
				set_state(State.CHASE)
			elif state_timer >= 1.0:
				patrol_direction = -patrol_direction
				is_facing_left = (patrol_direction < 0.0)
				set_state(State.MARCH)

		State.MARCH:
			if player_in_range:
				set_state(State.CHASE)
			else:
				velocity.x = patrol_direction * MARCH_SPEED
				is_facing_left = (patrol_direction < 0.0)
				march_anim_timer += delta * 7.5
				sprite.frame = 1 + (int(march_anim_timer) % 7)
				
				# Turn at boundary limits
				if (patrol_direction > 0.0 and global_position.x > spawn_x + patrol_distance) or \
				   (patrol_direction < 0.0 and global_position.x < spawn_x - patrol_distance):
					set_state(State.IDLE_GUARD)

		State.CHASE:
			if not player_in_range:
				set_state(State.MARCH)
			else:
				var chase_dir: float = -1.0 if dx_to_player < 0.0 else 1.0
				is_facing_left = (chase_dir < 0.0)
				march_anim_timer += delta * (11.0 if is_enraged else 9.0)
				sprite.frame = 1 + (int(march_anim_timer) % 7)
				
				# Check attack triggers
				if attack_cooldown <= 0.0:
					if dist_to_player <= BASH_TRIGGER_RANGE and randf() < 0.50:
						set_state(State.TELEGRAPH_SHIELD_BASH)
					elif dist_to_player <= ATTACK_TRIGGER_RANGE:
						set_state(State.TELEGRAPH_LUNGE)
					else:
						velocity.x = move_toward(velocity.x, chase_dir * cur_speed, ACCELERATION * delta)
				else:
					velocity.x = move_toward(velocity.x, chase_dir * cur_speed, ACCELERATION * delta)

	# Update sprite flip
	sprite.flip_h = is_facing_left
	move_and_slide()

func check_attack_hitbox(range_x: float, range_y: float, damage: int, attack_type: String) -> void:
	if not is_instance_valid(target_player):
		return
	var facing_dir: float = -1.0 if is_facing_left else 1.0
	var dx = target_player.global_position.x - global_position.x
	var dy = abs(target_player.global_position.y - global_position.y)
	var in_front = (is_facing_left and dx < 0.0) or (not is_facing_left and dx > 0.0)
	
	if in_front and abs(dx) <= range_x and dy <= range_y:
		has_hit_player_this_attack = true
		if attack_type == "shield_bash":
			# Shield bash penalizes block stamina if player is guarding
			if target_player.get("is_blocking") == true:
				if target_player.has_method("consume_stamina"):
					target_player.consume_stamina(35.0)
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(damage, facing_dir, self)

func deflect_by_parry(knock_dir: float) -> void:
	# Successful parry shatters vanguard posture, breaking through hyper armor!
	is_stunned_vulnerable = true
	stun_timer = 1.5
	velocity.x = knock_dir * 140.0
	velocity.y = -80.0
	set_state(State.PARRIED_STAGGER)
	_trigger_screen_shake(0.70)
	_trigger_hit_stop(0.08)
	play_sound(ProceduralAudioScript.get_pot_smash(), 1.4)
	if is_instance_valid(stun_stars):
		stun_stars.visible = true
	if is_instance_valid(health_pips):
		health_pips.set_vulnerable(true)

func take_damage(amount: int, knock_dir: float = 0.0) -> void:
	if is_dead:
		return
	
	var actual_damage = amount
	if is_stunned_vulnerable:
		actual_damage *= 2 # Massive bonus riposte damage against stunned miniboss!
		_trigger_screen_shake(0.60)
		_trigger_hit_stop(0.06)
	else:
		# Frontal Kalasag Shield defense when in IDLE_GUARD or MARCH
		var hit_from_front = (is_facing_left and knock_dir > 0.0) or (not is_facing_left and knock_dir < 0.0)
		if hit_from_front and (current_state == State.IDLE_GUARD or current_state == State.MARCH):
			actual_damage = max(1, int(ceil(float(actual_damage) * 0.5)))
			spawn_volcanic_sparks(Color(1.0, 0.85, 0.3, 0.9), 8)
			play_sound(ProceduralAudioScript.get_kick_hit(), 1.4)
		
	health = max(0, health - actual_damage)
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, is_stunned_vulnerable)
	boss_hp_changed.emit(health, MAX_HEALTH)
		
	hurt_flash_timer = 0.22
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
	
	# Check Enrage at <= 50% HP
	if not is_enraged and health <= int(MAX_HEALTH * 0.5):
		is_enraged = true
		boss_phase_changed.emit(2)
		play_sound(ProceduralAudioScript.get_boss_roar(), 1.0)
		_trigger_screen_shake(0.55)
		spawn_volcanic_sparks(Color(1.0, 0.2, 0.1, 0.95), 14)
	
	if health <= 0:
		trigger_death()
	else:
		# HYPER ARMOR: If boss is in attack states, he DOES NOT get interrupted!
		var has_hyper_armor: bool = current_state in [
			State.TELEGRAPH_LUNGE, State.LUNGE_THRUST,
			State.TELEGRAPH_SHIELD_BASH, State.SHIELD_BASH_IMPACT
		]
		if not has_hyper_armor and not is_stunned_vulnerable:
			velocity.x = knock_dir * 60.0
			set_state(State.HURT)

func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	
	# Firmly pin to floor so he NEVER falls down the map
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	if is_instance_valid(stun_stars):
		stun_stars.visible = false
	if is_instance_valid(health_pips):
		health_pips.queue_free()
		
	_trigger_screen_shake(0.85)
	_trigger_hit_stop(0.10)
	play_sound(ProceduralAudioScript.get_boss_roar(), 0.9)
	spawn_volcanic_sparks(Color(1.0, 0.4, 0.1, 0.95), 20)

	skeleton_died.emit(self)
	miniboss_died.emit(self)

	# ── Multi-Stage Dramatic Dying Animation Sequence ───────────────────────
	# Frame 26: Fatal stagger & roar as blade drops / wounded posture
	# Frame 27: Sword planted into ground on one knee
	# Frame 28: Collapsing to knees as stone petrifies
	# Frame 29: Crumbles into cold basalt armor pile with rising fiery embers and smoke
	sprite.frame = 26
	
	var death_tw = create_tween()
	# Step 1: Fatal roar stagger
	death_tw.tween_interval(0.38)
	# Step 2: Sword planted into ground
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 27
			play_sound(ProceduralAudioScript.get_landing_thud(), 1.1)
			_trigger_screen_shake(0.40)
			spawn_ground_dust(Color(0.4, 0.25, 0.15, 0.8), 8)
	)
	death_tw.tween_interval(0.45)
	# Step 3: Collapsing to knees
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 28
			_trigger_screen_shake(0.30)
	)
	death_tw.tween_interval(0.55)
	# Step 4: Basalt armor crumble & rising embers
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 29
			spawn_rising_embers(16)
	)
	death_tw.tween_interval(0.90)
	# Step 5: Gentle fade into the ash
	death_tw.tween_property(sprite, "modulate:a", 0.0, 0.70)
	death_tw.tween_callback(Callable(self, "_on_death_complete"))

func _on_death_complete() -> void:
	queue_free()

func spawn_molten_flame_wave(dir: float) -> void:
	# Spawns advancing fiery eruption crests along the floor (3 in Phase 1, 4 + rear backdraft in Enraged Phase 2)
	var pillar_count: int = 4 if is_enraged else 3
	for i in range(pillar_count):
		var delay = (i + 1) * 0.068
		var offset_x = dir * (40.0 + i * 38.0)
		_schedule_flame_pillar(delay, offset_x, dir, i)

	if is_enraged:
		# Enraged backdraft pillar behind the Vanguard to punish blind back-camping
		_schedule_flame_pillar(0.12, -dir * 44.0, -dir, 1)

func _schedule_flame_pillar(delay: float, offset_x: float, dir: float, idx: int) -> void:
	if delay <= 0.0:
		_spawn_flame_pillar_now(offset_x, dir, idx)
		return
	get_tree().create_timer(delay).timeout.connect(func():
		_spawn_flame_pillar_now(offset_x, dir, idx)
	)

func _spawn_flame_pillar_now(offset_x: float, dir: float, idx: int) -> void:
	if not is_inside_tree() or not is_instance_valid(get_parent()):
		return
	if true:
		var h_flame = 30.0 + idx * 5.5
		var hazard_area := Area2D.new()
		hazard_area.name = "MoltenFlamePillar_%d_%d" % [idx, int(abs(offset_x))]
		hazard_area.collision_layer = 0
		hazard_area.collision_mask = 2 # Player layer
		hazard_area.global_position = global_position + Vector2(offset_x, 12.0)
		hazard_area.z_index = 12

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(22.0, h_flame)
		col.shape = rect
		col.position = Vector2(0.0, -h_flame * 0.45)
		hazard_area.add_child(col)

		var flame = Polygon2D.new()
		flame.polygon = PackedVector2Array([
			Vector2(-10.0, 14.0),
			Vector2(-6.5, -h_flame * 0.55),
			Vector2(-2.0, -h_flame * 0.30),
			Vector2(dir * 3.5, -h_flame),
			Vector2(5.5, -h_flame * 0.42),
			Vector2(10.0, 14.0)
		])
		flame.color = Color(1.0, clamp(0.32 + idx * 0.11, 0.0, 1.0), 0.08, 0.95)
		hazard_area.add_child(flame)

		var core = Polygon2D.new()
		core.polygon = PackedVector2Array([
			Vector2(-4.5, 12.0),
			Vector2(dir * 2.0, -h_flame * 0.74),
			Vector2(4.5, 12.0)
		])
		core.color = Color(1.0, 0.90, 0.35, 0.94)
		flame.add_child(core)

		get_parent().add_child(hazard_area)

		var hit_done := [false]
		var apply_pillar_hit = func(body: Node2D):
			if hit_done[0] or not is_instance_valid(body):
				return
			if body.is_in_group("player") or body.name == "Player":
				hit_done[0] = true
				if body.has_method("take_damage_from_enemy"):
					body.take_damage_from_enemy(1, dir, self)

		hazard_area.body_entered.connect(apply_pillar_hit)

		# Also check initial grounded overlap
		if is_instance_valid(target_player) and target_player.is_on_floor():
			var pdx = abs(target_player.global_position.x - hazard_area.global_position.x)
			if pdx < 22.0:
				apply_pillar_hit.call(target_player)

		# Flame surge tween with active hitbox disabled once fading starts
		var ftw = hazard_area.create_tween()
		ftw.tween_property(hazard_area, "position:y", hazard_area.position.y - 16.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		ftw.tween_interval(0.18)
		ftw.tween_callback(func():
			col.set_deferred("disabled", true)
		)
		ftw.tween_property(hazard_area, "modulate:a", 0.0, 0.24)
		ftw.tween_callback(Callable(hazard_area, "queue_free"))

func spawn_rising_embers(count: int = 16) -> void:
	for i in range(count):
		var ember = Polygon2D.new()
		var r = randf_range(2.5, 4.8)
		ember.polygon = PackedVector2Array([
			Vector2(0, -r * 1.4),
			Vector2(r, 0),
			Vector2(0, r * 1.4),
			Vector2(-r, 0)
		])
		ember.color = Color(1.0, randf_range(0.35, 0.78), 0.12, 0.95)
		ember.global_position = global_position + Vector2(randf_range(-25.0, 25.0), randf_range(-10.0, -35.0))
		ember.z_index = 18
		get_parent().add_child(ember)
		
		var tw = ember.create_tween()
		var float_up = Vector2(randf_range(-18.0, 18.0), randf_range(-50.0, -90.0))
		tw.tween_property(ember, "global_position", ember.global_position + float_up, randf_range(1.1, 1.7)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(ember, "modulate:a", 0.0, randf_range(1.1, 1.7))
		tw.tween_callback(Callable(ember, "queue_free"))

func spawn_ground_dust(color: Color = Color(0.4, 0.3, 0.2, 0.8), count: int = 8) -> void:
	for i in range(count):
		var dust = Polygon2D.new()
		var s = randf_range(2.5, 4.8)
		dust.polygon = PackedVector2Array([
			Vector2(-s, 0),
			Vector2(0, -s),
			Vector2(s, s * 0.4),
			Vector2(-s * 0.4, s)
		])
		dust.color = color
		var f_offset = (randf() * 50.0 - 25.0)
		dust.global_position = global_position + Vector2(f_offset, -4.0)
		dust.z_index = 10
		get_parent().add_child(dust)
		
		var tw = dust.create_tween()
		var target_pos = dust.global_position + Vector2(f_offset * 1.5, randf_range(-18.0, -32.0))
		tw.tween_property(dust, "global_position", target_pos, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(dust, "rotation", randf_range(-2.5, 2.5), 0.45)
		tw.parallel().tween_property(dust, "modulate:a", 0.0, 0.45)
		tw.tween_callback(Callable(dust, "queue_free"))

func spawn_volcanic_sparks(color: Color = Color(1.0, 0.6, 0.1, 0.9), count: int = 10) -> void:
	for i in range(count):
		var spark = Polygon2D.new()
		var s = randf_range(2.0, 4.2)
		spark.polygon = PackedVector2Array([
			Vector2(0, -s * 1.3),
			Vector2(s * 0.8, 0),
			Vector2(0, s * 1.3),
			Vector2(-s * 0.8, 0)
		])
		spark.color = color
		var f_offset = (randf() * 40.0 - 20.0)
		spark.global_position = global_position + Vector2(f_offset, -20.0)
		spark.z_index = 10
		get_parent().add_child(spark)
		
		var tw = spark.create_tween()
		var target_pos = spark.global_position + Vector2(f_offset * 2.0, randf_range(-25.0, -45.0))
		tw.tween_property(spark, "global_position", target_pos, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(spark, "rotation", randf_range(-3.0, 3.0), 0.40)
		tw.parallel().tween_property(spark, "modulate:a", 0.0, 0.40)
		tw.tween_callback(Callable(spark, "queue_free"))


func play_sound(stream: AudioStream, vol_pitch: float = 1.0) -> void:
	if not stream or not is_instance_valid(sfx_player):
		return
	sfx_player.stream = stream
	sfx_player.pitch_scale = randf_range(vol_pitch * 0.92, vol_pitch * 1.08)
	sfx_player.play()

func _trigger_screen_shake(amount: float) -> void:
	if not is_inside_tree() or not get_tree():
		return
	var main_node = get_tree().current_scene
	if not is_instance_valid(main_node) or not main_node.has_method("add_screen_shake"):
		var mains = get_tree().get_nodes_in_group("main")
		if mains.size() > 0:
			main_node = mains[0]
	if is_instance_valid(main_node) and main_node.has_method("add_screen_shake"):
		main_node.add_screen_shake(amount)

func _trigger_hit_stop(duration: float = 0.045) -> void:
	if not is_inside_tree() or not get_tree():
		return
	var main_node = get_tree().current_scene
	if not is_instance_valid(main_node) or not main_node.has_method("apply_hit_stop"):
		var mains = get_tree().get_nodes_in_group("main")
		if mains.size() > 0:
			main_node = mains[0]
	if is_instance_valid(main_node) and main_node.has_method("apply_hit_stop"):
		main_node.apply_hit_stop(duration)

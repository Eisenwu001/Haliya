class_name ForestBruteMiniboss
extends CharacterBody2D

signal aswang_died(enemy: ForestBruteMiniboss)
signal miniboss_died(enemy: ForestBruteMiniboss)
signal boss_hp_changed(cur_hp: int, max_hp: int)
signal boss_phase_changed(new_phase: int)

enum State {
	IDLE,
	PATROL,
	CHASE,
	# Phase 1: Barehanded Attacks (without weapon)
	TELEGRAPH_CLAW,
	CLAW_SWIPE_COMBO,
	TELEGRAPH_EARTH_SLAM,
	EARTH_SLAM_IMPACT,
	# Phase Transition: Weapon Pickup & Health Regen
	WEAPON_PICKUP_REGEN,
	# Phase 2: Armed Attacks (with spiked wooden club)
	TELEGRAPH_CLUB_STRIKE,
	CLUB_STRIKE_COMBO,
	TELEGRAPH_WHIRLWIND,
	WHIRLWIND_SPIN_SLAM,
	# Reactions
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
const PATROL_SPEED: float = 40.0
const CHASE_SPEED_P1: float = 90.0
const CHASE_SPEED_P2: float = 135.0
const SLAM_LUNGE_SPEED: float = 145.0
const SWIPE_LUNGE_SPEED: float = 135.0
const WHIRLWIND_SPEED: float = 120.0
const ACCELERATION: float = 320.0
const DECELERATION: float = 400.0
const AGGRO_RANGE: float = 360.0

const CLAW_TRIGGER_RANGE: float = 68.0
const SLAM_TRIGGER_RANGE: float = 95.0
const CLUB_TRIGGER_RANGE: float = 82.0
const WHIRLWIND_TRIGGER_RANGE: float = 125.0

const MAX_HEALTH: int = 112

var current_state: State = State.IDLE
var health: int = MAX_HEALTH
var is_facing_left: bool = true
var is_dead: bool = false
var is_enraged: bool = false

# Phase tracking
var is_phase_2: bool = false
var has_transitioned_to_phase_2: bool = false
var is_invulnerable: bool = false

# AI & Combat timers
var spawn_x: float = 0.0
var patrol_direction: float = -1.0
var patrol_distance: float = 160.0
var state_timer: float = 0.0
var attack_cooldown: float = 0.8
var has_hit_player_this_attack: bool = false
var has_triggered_slam_shockwave: bool = false
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var walk_anim_timer: float = 0.0
var idle_anim_timer: float = 0.0
var regen_pulse_timer: float = 0.0
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
	add_to_group("aswang")
	add_to_group("miniboss")
	
	spawn_x = global_position.x
	setup_nodes()
	set_state(State.IDLE)
	state_timer = 1.0


func setup_nodes() -> void:
	collision_layer = 4 # Layer 3: Enemies
	collision_mask = 1  # Layer 1: Ground/Terrain
	
	# Master Spritesheet: 3840x2592, 10 cols x 9 rows (384x288 per frame)
	# Row 0 (0..7): Idle (Phase 1, barehanded)
	# Row 1 (10..17): Walk (Phase 1, barehanded 8-frame heavy stride)
	# Row 2 (20..27): Phase 1 Attack 1 (Claw Swipe Combo)
	# Row 3 (30..38): Phase 1 Attack 2 (Dual Fist Earth Slam)
	# Row 4 (40..48): Phase Transition (Weapon Pickup & Enrage)
	# Row 5 (50..56): Phase 2 Attack 3 (Club Strikes)
	# Row 6 (60..66): Phase 2 Attack 4 (Green Whirlwind & Earth-Shatter Slam)
	# Row 7 (70..77): Death Sequence
	# Row 8 (80..87): Phase 2 Armed Walk (Spiked Club on Shoulder, 8-frame heavy stride)
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = load_texture("res://assets/miniboss/forest_brute/forest_brute_spritesheet.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hframes = 10
	sprite.vframes = 9
	sprite.frame = 0
	sprite.centered = true
	sprite.scale = Vector2(0.62, 0.62)
	# Baseline Y=248 in 288 frame mapped so feet contact ground at local y=0
	# Offset = -(248 - 144) * 0.62 = -64.48 -> -64.5
	sprite.position = Vector2(0, -64.5)
	add_child(sprite)
	
	# Capsule Collision Shape
	col_shape = CollisionShape2D.new()
	col_shape.name = "CollisionShape2D"
	var shape := CapsuleShape2D.new()
	shape.radius = 18.0
	shape.height = 76.0
	col_shape.shape = shape
	col_shape.position = Vector2(0, -38.0)
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
	stun_stars.scale = Vector2(0.14, 0.14)
	stun_stars.position = Vector2(0, -104.0)
	stun_stars.visible = false
	stun_stars.z_index = 25
	add_child(stun_stars)
	
	# Health is displayed in the bottom cinematic Boss HUD, so overhead pips are disabled
	health_pips = null
	
	# SFX Audio Player
	sfx_player = AudioStreamPlayer2D.new()
	sfx_player.name = "MinibossSFX"
	sfx_player.max_distance = 650.0
	sfx_player.bus = "Master"
	add_child(sfx_player)


func set_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	has_hit_player_this_attack = false
	has_triggered_slam_shockwave = false
	
	if not sprite:
		return
		
	match current_state:
		State.IDLE:
			if hurt_flash_timer <= 0.0 and not is_invulnerable:
				sprite.modulate = Color(1.25, 0.75, 0.75, 1.0) if is_enraged else Color(1, 1, 1, 1)
			sprite.frame = 48 if is_phase_2 else 0
		State.PATROL, State.CHASE:
			if hurt_flash_timer <= 0.0 and not is_invulnerable:
				sprite.modulate = Color(1.25, 0.75, 0.75, 1.0) if is_enraged else Color(1, 1, 1, 1)
			sprite.frame = 10
		State.TELEGRAPH_CLAW:
			sprite.frame = 20
			VFX.spawn_red_eye_glint(self, Vector2(-6 if is_facing_left else 6, -52))
		State.CLAW_SWIPE_COMBO:
			sprite.frame = 22
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * SWIPE_LUNGE_SPEED
		State.TELEGRAPH_EARTH_SLAM:
			sprite.frame = 30
			VFX.spawn_red_eye_glint(self, Vector2(-6 if is_facing_left else 6, -56))
			spawn_ground_dust(Color(0.8, 0.35, 0.2, 0.85), 8)
		State.EARTH_SLAM_IMPACT:
			sprite.frame = 34
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * SLAM_LUNGE_SPEED
		State.WEAPON_PICKUP_REGEN:
			sprite.frame = 40
			velocity = Vector2.ZERO
		State.TELEGRAPH_CLUB_STRIKE:
			sprite.frame = 50
			VFX.spawn_red_eye_glint(self, Vector2(-6 if is_facing_left else 6, -54))
		State.CLUB_STRIKE_COMBO:
			sprite.frame = 51
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * SWIPE_LUNGE_SPEED * 1.15
		State.TELEGRAPH_WHIRLWIND:
			sprite.frame = 60
			VFX.spawn_red_eye_glint(self, Vector2(-6 if is_facing_left else 6, -54))
			spawn_ground_dust(Color(0.4, 0.8, 0.3, 0.85), 10)
		State.WHIRLWIND_SPIN_SLAM:
			sprite.frame = 61
			var f_dir: float = -1.0 if is_facing_left else 1.0
			velocity.x = f_dir * WHIRLWIND_SPEED
		State.PARRIED_STAGGER:
			sprite.frame = 70
		State.HURT:
			sprite.frame = 71
		State.DEATH:
			sprite.frame = 70


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
		if hurt_flash_timer <= 0.0 and current_state != State.PARRIED_STAGGER and not is_invulnerable:
			sprite.modulate = Color(1.25, 0.75, 0.75, 1.0) if is_enraged else Color(1, 1, 1, 1)

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
		var pulse = 0.5 + 0.5 * sin(stun_timer * 20.0)
		sprite.modulate = Color(1.5 + pulse * 0.4, 1.3 + pulse * 0.3, 0.3, 1.0)
		sprite.frame = 70
		if stun_timer <= 0.0:
			is_stunned_vulnerable = false
			if is_instance_valid(stun_stars):
				stun_stars.visible = false
			if is_instance_valid(health_pips):
				health_pips.set_vulnerable(false)
			sprite.modulate = Color(1.25, 0.75, 0.75, 1.0) if is_enraged else Color(1, 1, 1, 1)
			attack_cooldown = 0.5 if is_enraged else 0.8
			set_state(State.IDLE)
		move_and_slide()
		return

	# ── Hurt State ────────────────────────────────────────────────────────────
	if current_state == State.HURT:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 71
		if state_timer >= 0.20:
			set_state(State.CHASE)
		move_and_slide()
		return

	# ── PHASE TRANSITION: Weapon Pickup & Health Regen ────────────────────────
	if current_state == State.WEAPON_PICKUP_REGEN:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		
		# Animate the 9 pickup frames across 2.3 seconds
		if state_timer < 0.25:
			sprite.frame = 40 # Standing looking down at club
		elif state_timer < 0.50:
			sprite.frame = 41 # Stooping forward
		elif state_timer < 0.75:
			sprite.frame = 42 # Bending down
		elif state_timer < 1.00:
			sprite.frame = 43 # Gripping the wooden club
		elif state_timer < 1.25:
			sprite.frame = 44 # Lifting club off ground
		elif state_timer < 1.50:
			sprite.frame = 45 # Hauling club up
		elif state_timer < 1.75:
			sprite.frame = 46 # Standing upright with club
		elif state_timer < 2.00:
			sprite.frame = 47 # Hefting club in two hands
		else:
			sprite.frame = 48 # Hoisting club onto shoulder & roar!

		# Health Regeneration & Aura Wisps during pickup (between 0.8s and 1.9s)
		if state_timer >= 0.8 and state_timer <= 1.9:
			regen_pulse_timer += delta
			var regen_progress = clamp((state_timer - 0.8) / 1.0, 0.0, 1.0)
			var p2_thresh: float = float(int(ceil(float(MAX_HEALTH) * 0.10)))
			health = int(round(lerp(p2_thresh, float(MAX_HEALTH), regen_progress)))
			if is_instance_valid(health_pips):
				health_pips.update_health(health, MAX_HEALTH)
			boss_hp_changed.emit(health, MAX_HEALTH)
			
			# Emerald life pulse shimmer
			var pulse = 0.5 + 0.5 * sin(state_timer * 22.0)
			sprite.modulate = Color(0.6 + pulse * 0.3, 1.8 + pulse * 0.4, 0.6, 1.0)
			
			if regen_pulse_timer >= 0.14:
				regen_pulse_timer = 0.0
				spawn_green_soul_wisps(3)
				play_sound(ProceduralAudioScript.get_swing_whoosh(false), 1.3)

		# Dramatic battle roar at 2.0s
		if state_timer >= 2.0 and not is_enraged:
			is_enraged = true
			is_phase_2 = true
			boss_phase_changed.emit(2)
			play_sound(ProceduralAudioScript.get_boss_roar(), 0.95)
			_trigger_screen_shake(1.05)
			_trigger_hit_stop(0.12)
			spawn_ground_dust(Color(0.9, 0.25, 0.2, 0.95), 24)
			VFX.spawn_blood_moon_shockwave(get_parent(), global_position + Vector2(0, -32), 220.0, Color(1.0, 0.2, 0.2, 0.95))
			VFX.spawn_red_eye_glint(self, Vector2(-6 if is_facing_left else 6, -56))

		if state_timer >= 2.35:
			is_invulnerable = false
			sprite.modulate = Color(1.3, 0.75, 0.75, 1.0)
			attack_cooldown = 0.35
			set_state(State.CHASE)
			
		move_and_slide()
		return

	# ── PHASE 1 ATTACK 1: Claw Swipe Combo ─────────────────────────────────────
	if current_state == State.TELEGRAPH_CLAW:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 20 if state_timer < 0.12 else 21
		var pulse = 0.5 + 0.5 * sin(state_timer * 34.0)
		sprite.modulate = Color(0.6, 1.8 + pulse * 0.4, 0.6, 1.0)
		if state_timer >= 0.24:
			sprite.modulate = Color(1, 1, 1, 1)
			set_state(State.CLAW_SWIPE_COMBO)
		move_and_slide()
		return

	if current_state == State.CLAW_SWIPE_COMBO:
		state_timer += delta
		# 0.00 - 0.10s: Frame 22 (crouch lunge)
		if state_timer < 0.10:
			sprite.frame = 22
			velocity.x = facing_dir * SWIPE_LUNGE_SPEED
		# 0.10 - 0.22s: Frame 23..24 (first strike)
		elif state_timer < 0.22:
			sprite.frame = 23 if state_timer < 0.16 else 24
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.6 * delta)
			if not has_hit_player_this_attack:
				play_sound(ProceduralAudioScript.get_swing_whoosh(true), 1.1)
				check_attack_hitbox(68.0, 42.0, 1, "claw1")
		# 0.22 - 0.40s: Frame 25..26 (massive curved claw swipe & ground dust)
		elif state_timer < 0.40:
			sprite.frame = 25 if state_timer < 0.32 else 26
			velocity.x = facing_dir * (SWIPE_LUNGE_SPEED * 0.8)
			if state_timer >= 0.28 and not has_triggered_slam_shockwave:
				has_triggered_slam_shockwave = true
				_trigger_screen_shake(0.40)
				spawn_ground_dust(Color(0.5, 0.4, 0.3, 0.8), 8)
				check_attack_hitbox(76.0, 46.0, 1, "claw2")
		# 0.40 - 0.56s: Frame 27 (recovery)
		else:
			sprite.frame = 27
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		if state_timer >= 0.56:
			attack_cooldown = 0.5 if is_enraged else 0.8
			set_state(State.IDLE)
		move_and_slide()
		return

	# ── PHASE 1 ATTACK 2: Dual Fist Earth Slam ────────────────────────────────
	if current_state == State.TELEGRAPH_EARTH_SLAM:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		if state_timer < 0.12:
			sprite.frame = 30
		elif state_timer < 0.24:
			sprite.frame = 31
		else:
			sprite.frame = 32
		var pulse = 0.5 + 0.5 * sin(state_timer * 30.0)
		sprite.modulate = Color(2.0 + pulse * 0.5, 1.2 + pulse * 0.3, 0.3, 1.0)
		if state_timer >= 0.36:
			sprite.modulate = Color(1, 1, 1, 1)
			set_state(State.EARTH_SLAM_IMPACT)
		move_and_slide()
		return

	if current_state == State.EARTH_SLAM_IMPACT:
		state_timer += delta
		# 0.00 - 0.12s: Frame 33..34 (both fists high & downward lunge)
		if state_timer < 0.12:
			sprite.frame = 33 if state_timer < 0.06 else 34
			velocity.x = facing_dir * SLAM_LUNGE_SPEED
		# 0.12 - 0.32s: Frame 35..36 (earth impact & rock eruption)
		elif state_timer < 0.32:
			sprite.frame = 35 if state_timer < 0.22 else 36
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.9 * delta)
			if not has_triggered_slam_shockwave:
				has_triggered_slam_shockwave = true
				_trigger_screen_shake(0.65)
				_trigger_hit_stop(0.06)
				play_sound(ProceduralAudioScript.get_landing_thud(), 1.4)
				spawn_ground_dust(Color(0.48, 0.36, 0.22, 0.9), 12)
				spawn_earth_fissure_shockwave(facing_dir)
			if not has_hit_player_this_attack:
				check_attack_hitbox(80.0, 50.0, 2, "slam")
		# 0.32 - 0.58s: Frame 37..38 (debris explosion & recovery)
		else:
			sprite.frame = 37 if state_timer < 0.46 else 38
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		if state_timer >= 0.58:
			attack_cooldown = 0.6 if is_enraged else 1.0
			set_state(State.IDLE)
		move_and_slide()
		return

	# ── PHASE 2 ATTACK 3: Club Strikes Combo ──────────────────────────────────
	if current_state == State.TELEGRAPH_CLUB_STRIKE:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 50
		var pulse = 0.5 + 0.5 * sin(state_timer * 34.0)
		sprite.modulate = Color(2.1 + pulse * 0.4, 1.1 + pulse * 0.2, 0.3, 1.0)
		if state_timer >= 0.22:
			sprite.modulate = Color(1.25, 0.75, 0.75, 1.0)
			set_state(State.CLUB_STRIKE_COMBO)
		move_and_slide()
		return

	if current_state == State.CLUB_STRIKE_COMBO:
		state_timer += delta
		# 0.00 - 0.16s: Frame 51 (giant forward horizontal club swing)
		if state_timer < 0.16:
			sprite.frame = 51
			velocity.x = facing_dir * (SWIPE_LUNGE_SPEED * 1.2)
			if not has_hit_player_this_attack:
				play_sound(ProceduralAudioScript.get_swing_whoosh(true), 0.9)
				check_attack_hitbox(85.0, 52.0, 2, "club1")
		# 0.16 - 0.32s: Frame 52..53 (reverse swing with green energy trail)
		elif state_timer < 0.32:
			sprite.frame = 52 if state_timer < 0.24 else 53
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * 0.5 * delta)
			if state_timer >= 0.22 and not has_triggered_slam_shockwave:
				has_triggered_slam_shockwave = true
				play_sound(ProceduralAudioScript.get_swing_whoosh(false), 1.2)
				check_attack_hitbox(80.0, 48.0, 1, "club2")
		# 0.32 - 0.54s: Frame 54..55 (overhead smash into ground & rock sparks)
		elif state_timer < 0.54:
			sprite.frame = 54 if state_timer < 0.40 else 55
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			if state_timer >= 0.40 and not has_hit_player_this_attack:
				_trigger_screen_shake(0.70)
				_trigger_hit_stop(0.06)
				play_sound(ProceduralAudioScript.get_landing_thud(), 1.3)
				spawn_ground_dust(Color(0.5, 0.35, 0.2, 0.9), 14)
				spawn_earth_fissure_shockwave(facing_dir)
				check_attack_hitbox(85.0, 54.0, 2, "club_smash")
		# 0.54 - 0.72s: Frame 56 (recovery)
		else:
			sprite.frame = 56
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		if state_timer >= 0.72:
			attack_cooldown = 0.45
			set_state(State.IDLE)
		move_and_slide()
		return

	# ── PHASE 2 ATTACK 4: Green Whirlwind Spin & Earth-Shatter Slam ────────────
	if current_state == State.TELEGRAPH_WHIRLWIND:
		state_timer += delta
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		sprite.frame = 60 if state_timer < 0.14 else 61
		var pulse = 0.5 + 0.5 * sin(state_timer * 36.0)
		sprite.modulate = Color(0.4, 2.0 + pulse * 0.5, 0.8, 1.0)
		if state_timer >= 0.28:
			sprite.modulate = Color(1.25, 0.75, 0.75, 1.0)
			set_state(State.WHIRLWIND_SPIN_SLAM)
		move_and_slide()
		return

	if current_state == State.WHIRLWIND_SPIN_SLAM:
		state_timer += delta
		# 0.00 - 0.38s: Frame 62..64 (360-degree green whirlwind spin)
		if state_timer < 0.38:
			if state_timer < 0.12:
				sprite.frame = 62
			elif state_timer < 0.24:
				sprite.frame = 63
			else:
				sprite.frame = 64
			velocity.x = facing_dir * WHIRLWIND_SPEED
			if not has_hit_player_this_attack and state_timer > 0.08:
				play_sound(ProceduralAudioScript.get_swing_whoosh(true), 1.25)
				check_attack_hitbox_both_sides(88.0, 50.0, 2, "whirlwind")
		# 0.38 - 0.62s: Frame 65 (colossal overhead earth-shatter slam)
		elif state_timer < 0.62:
			sprite.frame = 65
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			if not has_triggered_slam_shockwave:
				has_triggered_slam_shockwave = true
				_trigger_screen_shake(0.80)
				_trigger_hit_stop(0.08)
				play_sound(ProceduralAudioScript.get_landing_thud(), 1.5)
				spawn_ground_dust(Color(0.45, 0.32, 0.2, 0.95), 18)
				spawn_earth_fissure_shockwave(facing_dir)
				spawn_earth_fissure_shockwave(-facing_dir)
				check_attack_hitbox(90.0, 55.0, 2, "earth_shatter")
		# 0.62 - 0.82s: Frame 66 (resetting club onto shoulder & recovery)
		else:
			sprite.frame = 66
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

		if state_timer >= 0.82:
			attack_cooldown = 0.5
			set_state(State.IDLE)
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

	# ── Normal States: IDLE, PATROL, CHASE ────────────────────────────────────
	var cur_speed = CHASE_SPEED_P2 if is_phase_2 else CHASE_SPEED_P1
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
			if is_phase_2:
				idle_anim_timer += delta * 4.0
				sprite.frame = 80 + (int(idle_anim_timer) % 3) # Heavy armed breathing stance
			else:
				idle_anim_timer += delta * 6.0
				sprite.frame = int(idle_anim_timer) % 8
			state_timer += delta
			if player_in_range:
				set_state(State.CHASE)
			elif state_timer >= 0.9:
				patrol_direction = -patrol_direction
				is_facing_left = (patrol_direction < 0.0)
				set_state(State.PATROL)

		State.PATROL:
			if player_in_range:
				set_state(State.CHASE)
			else:
				velocity.x = patrol_direction * PATROL_SPEED
				is_facing_left = (patrol_direction < 0.0)
				walk_anim_timer += delta * 8.0
				if is_phase_2:
					sprite.frame = 80 + (int(walk_anim_timer) % 8) # Phase 2 Armed Walk with Spiked Club
				else:
					sprite.frame = 10 + (int(walk_anim_timer) % 8) # Phase 1 Unarmed Walk
				
				if (patrol_direction > 0.0 and global_position.x > spawn_x + patrol_distance) or \
				   (patrol_direction < 0.0 and global_position.x < spawn_x - patrol_distance):
					set_state(State.IDLE)

		State.CHASE:
			if not player_in_range:
				set_state(State.PATROL)
			else:
				var chase_dir: float = -1.0 if dx_to_player < 0.0 else 1.0
				is_facing_left = (chase_dir < 0.0)
				walk_anim_timer += delta * (11.0 if is_phase_2 else 9.5)
				if is_phase_2:
					sprite.frame = 80 + (int(walk_anim_timer) % 8) # Phase 2 Armed Walk with Spiked Club
				else:
					sprite.frame = 10 + (int(walk_anim_timer) % 8) # Phase 1 Unarmed Walk
				
				# Check attack triggers based on Phase
				if attack_cooldown <= 0.0:
					if is_phase_2:
						if dist_to_player <= CLUB_TRIGGER_RANGE and randf() < 0.55:
							set_state(State.TELEGRAPH_CLUB_STRIKE)
						elif dist_to_player <= WHIRLWIND_TRIGGER_RANGE:
							set_state(State.TELEGRAPH_WHIRLWIND)
						else:
							velocity.x = move_toward(velocity.x, chase_dir * cur_speed, ACCELERATION * delta)
					else:
						if dist_to_player <= CLAW_TRIGGER_RANGE and randf() < 0.50:
							set_state(State.TELEGRAPH_CLAW)
						elif dist_to_player <= SLAM_TRIGGER_RANGE:
							set_state(State.TELEGRAPH_EARTH_SLAM)
						else:
							velocity.x = move_toward(velocity.x, chase_dir * cur_speed, ACCELERATION * delta)
				else:
					velocity.x = move_toward(velocity.x, chase_dir * cur_speed, ACCELERATION * delta)

	sprite.flip_h = is_facing_left
	move_and_slide()


func check_attack_hitbox(range_x: float, range_y: float, damage: int, _attack_type: String) -> void:
	if not is_instance_valid(target_player):
		return
	var facing_dir: float = -1.0 if is_facing_left else 1.0
	var dx = target_player.global_position.x - global_position.x
	var dy = abs(target_player.global_position.y - global_position.y)
	var in_front = (is_facing_left and dx < 0.0) or (not is_facing_left and dx > 0.0)
	if in_front and abs(dx) <= range_x and dy <= range_y:
		has_hit_player_this_attack = true
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(damage, facing_dir, self)


func check_attack_hitbox_both_sides(range_x: float, range_y: float, damage: int, _attack_type: String) -> void:
	if not is_instance_valid(target_player):
		return
	var dx = target_player.global_position.x - global_position.x
	var dy = abs(target_player.global_position.y - global_position.y)
	if abs(dx) <= range_x and dy <= range_y:
		has_hit_player_this_attack = true
		var hit_dir: float = -1.0 if dx < 0.0 else 1.0
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(damage, hit_dir, self)


func deflect_by_parry(knock_dir: float) -> void:
	if is_invulnerable or current_state == State.WEAPON_PICKUP_REGEN or is_dead:
		return
	# Successful player parry shatters boss poise, cancelling whatever attack he was doing!
	is_stunned_vulnerable = true
	stun_timer = 1.6
	velocity.x = knock_dir * 140.0
	velocity.y = -80.0
	set_state(State.PARRIED_STAGGER)
	_trigger_screen_shake(0.70)
	_trigger_hit_stop(0.08)
	play_sound(ProceduralAudioScript.get_pot_smash(), 1.3)
	if is_instance_valid(stun_stars):
		stun_stars.visible = true
	if is_instance_valid(health_pips):
		health_pips.set_vulnerable(true)


func take_damage(amount: int, knock_dir: float = 0.0) -> void:
	if is_dead or is_invulnerable:
		return
	
	var actual_damage = amount
	if is_stunned_vulnerable:
		actual_damage *= 2 # Massive bonus riposte damage against stunned miniboss!
		_trigger_screen_shake(0.60)
		_trigger_hit_stop(0.06)
		
	health = max(0, health - actual_damage)
	
	# Phase 1 -> Phase 2 Transition Trigger:
	# Once boss reaches 10% HP (<= 3 HP for 28 max HP), proceed to Phase 2 weapon pickup!
	var p2_threshold: int = int(ceil(float(MAX_HEALTH) * 0.10))
	if not has_transitioned_to_phase_2 and health <= p2_threshold:
		health = p2_threshold
		has_transitioned_to_phase_2 = true
		if is_instance_valid(health_pips):
			health_pips.update_health(health, MAX_HEALTH, false)
		boss_hp_changed.emit(health, MAX_HEALTH)
		start_weapon_pickup_transition()
		return

	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, is_stunned_vulnerable)
	boss_hp_changed.emit(health, MAX_HEALTH)
		
	hurt_flash_timer = 0.22
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
	
	if health <= 0:
		trigger_death()
	else:
		# HYPER ARMOR during active heavy attacks: regular hits cannot interrupt him!
		var has_hyper_armor: bool = current_state in [
			State.TELEGRAPH_CLAW, State.CLAW_SWIPE_COMBO,
			State.TELEGRAPH_EARTH_SLAM, State.EARTH_SLAM_IMPACT,
			State.TELEGRAPH_CLUB_STRIKE, State.CLUB_STRIKE_COMBO,
			State.TELEGRAPH_WHIRLWIND, State.WHIRLWIND_SPIN_SLAM
		]
		if not has_hyper_armor and not is_stunned_vulnerable:
			velocity.x = knock_dir * 50.0
			set_state(State.HURT)


func start_weapon_pickup_transition() -> void:
	is_invulnerable = true
	is_stunned_vulnerable = false
	if is_instance_valid(stun_stars):
		stun_stars.visible = false
	set_state(State.WEAPON_PICKUP_REGEN)
	_trigger_screen_shake(0.50)
	spawn_ground_dust(Color(0.4, 0.9, 0.4, 0.9), 12)


func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	if is_instance_valid(stun_stars):
		stun_stars.visible = false
	if is_instance_valid(health_pips):
		health_pips.queue_free()
		
	_trigger_screen_shake(0.85)
	_trigger_hit_stop(0.10)
	play_sound(ProceduralAudioScript.get_boss_roar(), 0.9)
	spawn_ground_dust(Color(0.3, 0.2, 0.1, 0.95), 18)
	VFX.spawn_boss_death_embers(get_parent(), global_position + Vector2(0, -32), 48)

	aswang_died.emit(self)
	miniboss_died.emit(self)

	# ── Multi-Stage Dramatic Dying Animation Sequence ───────────────────────
	# Row 7: Frames 70 to 77
	sprite.frame = 70
	
	var death_tw = create_tween()
	# Step 1: Trembling fatal stagger
	death_tw.tween_interval(0.35)
	# Step 2: Roaring clutching mortal wound
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 71
			_trigger_screen_shake(0.35)
	)
	death_tw.tween_interval(0.35)
	# Step 3: Slumping forward
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 72
	)
	death_tw.tween_interval(0.30)
	# Step 4: Collapsing onto knees and hands with ground thud
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 73
			play_sound(ProceduralAudioScript.get_landing_thud(), 1.1)
			_trigger_screen_shake(0.40)
			spawn_ground_dust(Color(0.4, 0.3, 0.2, 0.8), 10)
	)
	death_tw.tween_interval(0.35)
	# Step 5: Dropping head down
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 74
	)
	death_tw.tween_interval(0.35)
	# Step 6: Resting on the soil
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 75
	)
	death_tw.tween_interval(0.40)
	# Step 7: Flat on ground
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 76
	)
	death_tw.tween_interval(0.50)
	# Step 8: Petrifying into ancient mossy wood & green soul wisps
	death_tw.tween_callback(func():
		if sprite:
			sprite.frame = 77
			spawn_green_soul_wisps(16)
	)
	death_tw.tween_interval(1.10)
	# Step 9: Gentle fade into the earth
	death_tw.tween_property(sprite, "modulate:a", 0.0, 0.75)
	death_tw.tween_callback(Callable(self, "_on_death_complete"))


func _on_death_complete() -> void:
	queue_free()


func spawn_earth_fissure_shockwave(dir: float) -> void:
	for i in range(3):
		var delay = (i + 1) * 0.07
		var offset_x = dir * (40.0 + i * 36.0)
		get_tree().create_timer(delay).timeout.connect(func():
			if not is_inside_tree():
				return
			var h_spike = 26.0 + i * 5.0
			var spike = Polygon2D.new()
			spike.polygon = PackedVector2Array([
				Vector2(-8.0, 14.0),
				Vector2(-5.0, -h_spike * 0.45),
				Vector2(dir * 3.0, -h_spike),
				Vector2(6.0, -h_spike * 0.35),
				Vector2(8.0, 14.0)
			])
			spike.color = Color(0.42, 0.33, 0.22, 0.96)
			spike.global_position = global_position + Vector2(offset_x, 12.0)
			spike.z_index = 12
			get_parent().add_child(spike)

			var ridge = Polygon2D.new()
			ridge.polygon = PackedVector2Array([
				Vector2(-2.0, 10.0),
				Vector2(dir * 3.0, -h_spike),
				Vector2(3.0, 10.0)
			])
			ridge.color = Color(0.64, 0.52, 0.36, 0.90)
			spike.add_child(ridge)
			
			if is_instance_valid(target_player) and target_player.is_on_floor():
				var pdx = abs(target_player.global_position.x - spike.global_position.x)
				if pdx < 22.0 and target_player.has_method("take_damage_from_enemy"):
					target_player.take_damage_from_enemy(1, dir, self)
			
			var stw = spike.create_tween()
			stw.tween_property(spike, "position:y", spike.position.y - 14.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			stw.tween_interval(0.20)
			stw.tween_property(spike, "modulate:a", 0.0, 0.25)
			stw.tween_callback(Callable(spike, "queue_free"))
		)


func spawn_green_soul_wisps(count: int = 12) -> void:
	for i in range(count):
		var wisp = Polygon2D.new()
		var r = randf_range(3.0, 5.5)
		wisp.polygon = PackedVector2Array([
			Vector2(0, -r * 1.4),
			Vector2(r, 0),
			Vector2(0, r * 1.4),
			Vector2(-r, 0)
		])
		wisp.color = Color(0.32, 0.96, 0.54, 0.92)
		wisp.global_position = global_position + Vector2(randf_range(-30.0, 30.0), randf_range(-10.0, -35.0))
		wisp.z_index = 18
		get_parent().add_child(wisp)
		
		var tw = wisp.create_tween()
		var float_up = Vector2(randf_range(-20.0, 20.0), randf_range(-50.0, -90.0))
		tw.tween_property(wisp, "global_position", wisp.global_position + float_up, randf_range(1.2, 1.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(wisp, "modulate:a", 0.0, randf_range(1.2, 1.8))
		tw.tween_callback(Callable(wisp, "queue_free"))


func spawn_ground_dust(color: Color = Color(0.5, 0.4, 0.3, 0.8), count: int = 8) -> void:
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

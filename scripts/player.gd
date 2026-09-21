class_name Player
extends CharacterBody2D

const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

signal player_died
signal hp_changed(current_hp: int, max_hp: int)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal hit_landed(is_heavy: bool, hit_pos: Vector2)
signal riposte_performed(hit_pos: Vector2)
signal damage_taken(amount: int, is_blocked: bool)

enum State {
	IDLE,
	WALK,
	RUN,
	BREAK,
	JUMP,
	ATTACK,
	CROUCH,
	CROUCH_ATTACK,
	GUARD,
	RUN_KICK,
	LANDING,
	GUARD_BREAK,
	RIPOSTE,
	DODGE
}

const GRAVITY: float = 980.0
const WALK_SPEED: float = 120.0
const RUN_SPEED: float = 240.0
const DASH_SPEED: float = 380.0
const JUMP_VELOCITY: float = -420.0
const HIGH_FALL_THRESHOLD: float = 450.0
const MAX_KICK_DISTANCE: float = 120.0 # Maximum forward travel range for flying run kick
const DODGE_SPEED: float = 340.0
const DODGE_DURATION: float = 0.26
const DODGE_IFRAME_DURATION: float = 0.20
const DODGE_STAMINA_COST: float = 20.0

# Health & Stamina Constants
const MAX_HEALTH: int = 5
const MAX_STAMINA: float = 100.0
const IFRAME_DURATION: float = 1.2
const RUN_KICK_STAMINA_COST: float = 35.0
const GUARD_STAMINA_DRAIN_PER_SEC: float = 18.0
const GUARD_BLOCK_STAMINA_COST: float = 20.0
const STAMINA_REGEN_PER_SEC: float = 35.0
const PARRY_WINDOW: float = 0.20 # Crisp 0.20s perfect parry timing window

# Magnetic Combat & Riposte Constants
const MAGNETIC_ATTACK_RANGE: float = 95.0 # Max soft-lock acquisition distance in px
const MAGNETIC_TARGET_SPACING: float = 34.0 # Optimal strike contact spacing from enemy center
const MAGNETIC_GLIDE_SPEED: float = 340.0 # Fluid ease-out glide speed toward target
const WHIFF_STEP_IMPULSE: float = 110.0 # Subtle dynamic forward step on empty swings
const RIPOSTE_WINDOW_DURATION: float = 0.85 # Critical parry counter window
const RIPOSTE_DASH_SPEED: float = 460.0 # Blazing counter dash velocity
const RIPOSTE_DAMAGE: int = 3 # Devastating critical execution damage
const PARRY_AUTO_FACE_MAX_DIST: float = 75.0 # Close-range forgiveness for parry auto-facing

var current_state: State = State.IDLE
var is_facing_left: bool = false
var max_fall_velocity: float = 0.0

# Combat & Resource variables
var current_hp: int = MAX_HEALTH
var current_stamina: float = MAX_STAMINA
var invulnerable_timer: float = 0.0
var guard_time_held: float = 0.0
var guard_break_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var last_safe_ground_pos: Vector2 = Vector2(192.0, 300.0)

# Shift key double-tap tracking for Dash / Run Kick
var last_shift_press_time: float = -10.0
var shift_key_was_pressed: bool = false

# Run kick range & travel tracking
var kick_start_x: float = 0.0
var kick_direction: float = 1.0

# Animation Frame Containers loaded dynamically from assets/haliya
var idle_frames: Array[Texture2D] = []
var walk_frames: Array[Texture2D] = []
var run_frames: Array[Texture2D] = []
var break_frames: Array[Texture2D] = []
var jump_up_frames: Array[Texture2D] = []
var jump_fall_frames: Array[Texture2D] = []

# Crouch & Defensive Frames
var idle_to_crouch_frames: Array[Texture2D] = []
var idle_crouch_frames: Array[Texture2D] = []
var crouch_to_idle_frames: Array[Texture2D] = []
var crouch_attack1_frames: Array[Texture2D] = []
var crouch_attack2_frames: Array[Texture2D] = []
var guard_stand_frames: Array[Texture2D] = []
var guard_crouch_frames: Array[Texture2D] = []

# Specialty Attacks & Movement Variants
var ground_attack_combos: Array[Array] = []
var jump_attack_frames: Array[Texture2D] = []
var run_kick_frames: Array[Texture2D] = [] # Complete 9-frame continuous sequence: begin01-02 -> 01-02 -> end01-05
var riposte_frames: Array[Texture2D] = [] # Dedicated 6-frame explosive riposte thrust sequence
var landing_frames: Array[Texture2D] = []
var backstep_frames: Array[Texture2D] = []

# Dodge & Evasive Maneuver Tracking
var dodge_timer: float = 0.0
var dodge_direction: float = 0.0
var dodge_trail_timer: float = 0.0

# Magnetic combat & soft-lock tracking
var is_gliding_to_target: bool = false
var attack_glide_target_x: float = 0.0
var attack_whiff_step_speed: float = 0.0
var riposte_timer: float = 0.0
var riposte_target: CharacterBody2D = null

var current_combo_idx: int = 0
var crouch_combo_idx: int = 0
var attack_queued: bool = false
var is_air_attack: bool = false
var is_locked_transition: bool = false
var crouch_sub_state: int = 0 # 0: entering (idle_to_crouch), 1: holding (idle_crouch), 2: exiting (crouch_to_idle)

var current_frame_idx: int = 0
var frame_timer: float = 0.0
var frame_duration: float = 0.1 # 10 FPS default

# Enemy combat tracking
var hit_enemies_this_swing: Array[Node] = []

# Node references
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var footstep_audio_player: AudioStreamPlayer2D
var landing_audio_player: AudioStreamPlayer2D
var swing_audio_player: AudioStreamPlayer2D
var hit_audio_player: AudioStreamPlayer2D
var footstep_dust_particles: CPUParticles2D
var landing_dust_particles: CPUParticles2D
var footstep_cycle_index: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("player")
	ensure_input_actions()
	setup_nodes()
	load_haliya_animations()
	set_state(State.IDLE)

func ensure_input_actions() -> void:
	_register_action_key("move_left", [KEY_A, KEY_LEFT])
	_register_action_key("move_right", [KEY_D, KEY_RIGHT])
	_register_action_key("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_register_action_key("run", [KEY_SHIFT])
	_register_action_key("crouch", [KEY_S, KEY_DOWN])
	_register_action_key("guard", [KEY_K])
	_register_action_mouse("guard", MOUSE_BUTTON_RIGHT)
	_register_action_key("attack", [KEY_J])
	_register_action_mouse("attack", MOUSE_BUTTON_LEFT)
	_register_action_key("dodge", [KEY_ALT, KEY_C])
	_register_action_key("interact", [KEY_E])

func _register_action_key(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for code in keycodes:
		var ev := InputEventKey.new()
		ev.physical_keycode = code
		InputMap.action_add_event(action_name, ev)

func _register_action_mouse(action_name: String, button: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action_name, ev)

func setup_nodes() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(0, -59.0)
	add_child(sprite)
	
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape = CapsuleShape2D.new()
	shape.radius = 10.0
	shape.height = 36.0
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -18)
	add_child(collision_shape)

	# Audio Players for Sfx
	footstep_audio_player = AudioStreamPlayer2D.new()
	footstep_audio_player.name = "FootstepAudioPlayer"
	footstep_audio_player.volume_db = -13.0
	add_child(footstep_audio_player)

	landing_audio_player = AudioStreamPlayer2D.new()
	landing_audio_player.name = "LandingAudioPlayer"
	landing_audio_player.volume_db = -6.0
	add_child(landing_audio_player)

	swing_audio_player = AudioStreamPlayer2D.new()
	swing_audio_player.name = "SwingAudioPlayer"
	swing_audio_player.volume_db = -4.0
	add_child(swing_audio_player)

	hit_audio_player = AudioStreamPlayer2D.new()
	hit_audio_player.name = "HitAudioPlayer"
	hit_audio_player.volume_db = -2.0
	add_child(hit_audio_player)

	# Footstep Dust Kickback Particles (At the feet, Y = 0)
	footstep_dust_particles = CPUParticles2D.new()
	footstep_dust_particles.name = "FootstepDust"
	footstep_dust_particles.emitting = false
	footstep_dust_particles.one_shot = true
	footstep_dust_particles.explosiveness = 0.85
	footstep_dust_particles.amount = 4
	footstep_dust_particles.lifetime = 0.22
	footstep_dust_particles.position = Vector2(0, 0)
	footstep_dust_particles.direction = Vector2(-1, -0.3)
	footstep_dust_particles.spread = 30.0
	footstep_dust_particles.gravity = Vector2(0, 100.0)
	footstep_dust_particles.initial_velocity_min = 25.0
	footstep_dust_particles.initial_velocity_max = 60.0
	footstep_dust_particles.scale_amount_min = 1.5
	footstep_dust_particles.scale_amount_max = 2.5
	footstep_dust_particles.color = Color(0.82, 0.76, 0.62, 0.60)
	add_child(footstep_dust_particles)

	# Landing Dust Radial Burst Particles
	landing_dust_particles = CPUParticles2D.new()
	landing_dust_particles.name = "LandingDust"
	landing_dust_particles.emitting = false
	landing_dust_particles.one_shot = true
	landing_dust_particles.explosiveness = 0.95
	landing_dust_particles.amount = 8
	landing_dust_particles.lifetime = 0.30
	landing_dust_particles.position = Vector2(0, 0)
	landing_dust_particles.direction = Vector2(0, -0.5)
	landing_dust_particles.spread = 80.0
	landing_dust_particles.gravity = Vector2(0, 140.0)
	landing_dust_particles.initial_velocity_min = 40.0
	landing_dust_particles.initial_velocity_max = 85.0
	landing_dust_particles.scale_amount_min = 2.0
	landing_dust_particles.scale_amount_max = 3.5
	landing_dust_particles.color = Color(0.82, 0.76, 0.62, 0.65)
	add_child(landing_dust_particles)

func load_haliya_animations() -> void:
	var asset_folder = "res://assets/haliya"
	var dir = DirAccess.open(asset_folder)
	
	var walk_paths: Array[String] = []
	var run_paths: Array[String] = []
	var break_paths: Array[String] = []
	var jump_up_paths: Array[String] = []
	var jump_fall_paths: Array[String] = []
	var idle_paths: Array[String] = []
	
	var combo1_paths: Array[String] = []
	var combo2_paths: Array[String] = []
	var combo3_paths: Array[String] = []
	var combo4_paths: Array[String] = []
	var knee_paths: Array[String] = []
	var air_attack_paths: Array[String] = []
	var kick_paths: Array[String] = []
	
	var idle_to_crouch_paths: Array[String] = []
	var idle_crouch_paths: Array[String] = []
	var crouch_to_idle_paths: Array[String] = []
	var crouch_atk1_paths: Array[String] = []
	var crouch_atk2_paths: Array[String] = []
	var guard_stand_paths: Array[String] = []
	var guard_crouch_paths: Array[String] = []
	var landing_paths: Array[String] = []
	var backstep_paths: Array[String] = []
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				var full_path = asset_folder + "/" + file_name
				var bname = file_name.get_basename()
				
				if "common_04_back" in file_name:
					backstep_paths.append(full_path)
				elif "run_kick" in file_name:
					kick_paths.append(full_path)
				elif "walk" in file_name:
					walk_paths.append(full_path)
				elif "run" in file_name:
					run_paths.append(full_path)
				elif "break" in file_name:
					break_paths.append(full_path)
				elif "jump_down" in file_name:
					jump_fall_paths.append(full_path)
				elif "jump_attack" in file_name:
					air_attack_paths.append(full_path)
				elif "jump" in file_name:
					if bname in ["common_21_jump01", "common_21_jump02", "common_21_jump03", "common_21_jump04", "common_21_jump05"]:
						jump_up_paths.append(full_path)
				elif "idle_to_crouch" in file_name:
					idle_to_crouch_paths.append(full_path)
				elif "crouch_to_idle" in file_name:
					crouch_to_idle_paths.append(full_path)
				elif "idle_crouch" in file_name:
					idle_crouch_paths.append(full_path)
				elif "crounch_attack01" in file_name:
					crouch_atk1_paths.append(full_path)
				elif "crounch_attack02" in file_name:
					crouch_atk2_paths.append(full_path)
				elif "guard_stand" in file_name:
					guard_stand_paths.append(full_path)
				elif "guard_crouch" in file_name:
					guard_crouch_paths.append(full_path)
				elif "common_22_landing" in file_name:
					landing_paths.append(full_path)
				elif "idle" in file_name and "stand_A" in file_name:
					idle_paths.append(full_path)
				elif "cobination01" in file_name:
					combo1_paths.append(full_path)
				elif "cobination02" in file_name:
					combo2_paths.append(full_path)
				elif "cobination03" in file_name:
					combo3_paths.append(full_path)
				elif "cobination04" in file_name:
					combo4_paths.append(full_path)
				elif "knee" in file_name:
					knee_paths.append(full_path)
			file_name = dir.get_next()
	
	walk_frames = load_and_sort_textures(walk_paths)
	run_frames = load_and_sort_textures(run_paths)
	break_frames = load_and_sort_textures(break_paths)
	jump_up_frames = load_and_sort_textures(jump_up_paths)
	jump_fall_frames = load_and_sort_textures(jump_fall_paths)
	idle_frames = load_and_sort_textures(idle_paths)
	
	idle_to_crouch_frames = load_and_sort_textures(idle_to_crouch_paths)
	idle_crouch_frames = load_and_sort_textures(idle_crouch_paths)
	crouch_to_idle_frames = load_and_sort_textures(crouch_to_idle_paths)
	crouch_attack1_frames = load_and_sort_textures(crouch_atk1_paths)
	crouch_attack2_frames = load_and_sort_textures(crouch_atk2_paths)
	guard_stand_frames = load_and_sort_textures(guard_stand_paths)
	guard_crouch_frames = load_and_sort_textures(guard_crouch_paths)
	landing_frames = load_and_sort_textures(landing_paths)
	run_kick_frames = load_and_sort_textures(kick_paths)
	backstep_frames = load_and_sort_textures(backstep_paths)

	
	ground_attack_combos.clear()
	ground_attack_combos.append(load_and_sort_textures(combo1_paths))
	ground_attack_combos.append(load_and_sort_textures(combo2_paths))
	ground_attack_combos.append(load_and_sort_textures(combo3_paths))
	ground_attack_combos.append(load_and_sort_textures(combo4_paths))
	ground_attack_combos.append(load_and_sort_textures(knee_paths))
	riposte_frames = load_and_sort_textures(knee_paths)
	
	jump_attack_frames = load_and_sort_textures(air_attack_paths)

func load_and_sort_textures(paths: Array[String]) -> Array[Texture2D]:
	paths.sort_custom(sort_paths_custom)
	var textures: Array[Texture2D] = []
	for p in paths:
		var tex = load(p) as Texture2D
		if tex:
			textures.append(tex)
	return textures

static func sort_paths_custom(a: String, b: String) -> bool:
	if "run_kick" in a and "run_kick" in b:
		return get_run_kick_index(a) < get_run_kick_index(b)
	return extract_frame_number(a) < extract_frame_number(b)

static func get_run_kick_index(path: String) -> int:
	var f = path.get_file()
	if "begin01" in f: return 1
	if "begin02" in f: return 2
	if "run_kick_01" in f: return 3
	if "run_kick_02" in f: return 4
	if "end01" in f: return 5
	if "end02" in f: return 6
	if "end03" in f: return 7
	if "end04" in f: return 8
	if "end05" in f: return 9
	return extract_frame_number(path)

static func extract_frame_number(path: String) -> int:
	var file_name = path.get_file().get_basename()
	var regex = RegEx.new()
	regex.compile("\\d+")
	var matches = regex.search_all(file_name)
	if matches.size() > 0:
		return matches[-1].get_string().to_int()
	return 0

func _physics_process(delta: float) -> void:
	# Guard Break Stun Handling
	if current_state == State.GUARD_BREAK:
		guard_break_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 320.0 * delta)
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		if guard_break_timer <= 0.0:
			set_state(State.IDLE)
			sprite.modulate = Color(1, 1, 1, 1)
		move_and_slide()
		update_animation(delta)
		return

	# Track max fall velocity for Heavy Landing Impact Recovery
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > max_fall_velocity:
			max_fall_velocity = velocity.y
	else:
		last_safe_ground_pos = global_position
	
	# Invulnerability frames (i-frames) & Sprite Blink Effect
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
		if invulnerable_timer > 0.0:
			# Fast visual blink while invulnerable
			var blink_phase = int(invulnerable_timer * 20.0) % 2
			sprite.modulate.a = 0.35 if blink_phase == 0 else 0.9
		else:
			invulnerable_timer = 0.0
			sprite.modulate = Color(1, 1, 1, 1)
	elif hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0:
			sprite.modulate = Color(1, 1, 1, 1)
	
	# Riposte Opportunity Timer & Golden Aura Pulse
	if riposte_timer > 0.0:
		riposte_timer -= delta
		if riposte_timer <= 0.0 or not is_instance_valid(riposte_target) or riposte_target.get("is_dead") == true:
			riposte_timer = 0.0
			riposte_target = null
			if current_state != State.RIPOSTE and invulnerable_timer <= 0.0 and hurt_flash_timer <= 0.0 and sprite:
				sprite.modulate = Color(1, 1, 1, 1)
		elif current_state != State.RIPOSTE and sprite:
			# Subtle golden pulse while parry riposte window is open
			var gleam_pulse = 1.0 + 0.35 * sin(riposte_timer * 18.0)
			sprite.modulate = Color(gleam_pulse * 1.4, gleam_pulse * 1.3, 0.45, 1.0)

	# Stamina Management
	if current_state == State.GUARD:
		guard_time_held += delta
		current_stamina = max(0.0, current_stamina - GUARD_STAMINA_DRAIN_PER_SEC * delta)
		if current_stamina <= 0.0:
			# Guard Broken from holding too long!
			trigger_guard_break(1.0 if is_facing_left else -1.0)
	else:
		guard_time_held = 0.0
		if current_state != State.RUN_KICK:
			current_stamina = min(MAX_STAMINA, current_stamina + STAMINA_REGEN_PER_SEC * delta)
	
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	
	# Inputs
	var crouch_held: bool = false
	var guard_held: bool = false
	var attack_just_pressed: bool = false
	var jump_just_pressed: bool = false
	var is_run_key: bool = false
	var move_dir: float = 0.0

	if is_locked_transition:
		move_dir = 1.0
		is_facing_left = false
		if current_state != State.WALK and is_on_floor():
			set_state(State.WALK)
	else:
		crouch_held = Input.is_action_pressed("crouch") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
		guard_held = Input.is_action_pressed("guard") or Input.is_key_pressed(KEY_K) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		attack_just_pressed = Input.is_action_just_pressed("attack")
		jump_just_pressed = Input.is_action_just_pressed("jump")
		is_run_key = Input.is_action_pressed("run") or Input.is_key_pressed(KEY_SHIFT)
		
		# Handle Horizontal Movement Input
		if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			move_dir -= 1.0
		if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			move_dir += 1.0
	
	# Detect Shift key double-tap for DASH / RUN KICK
	var is_shift_just_pressed = Input.is_action_just_pressed("run") or (is_run_key and not shift_key_was_pressed)
	shift_key_was_pressed = is_run_key
	
	if is_shift_just_pressed and is_on_floor() and current_state not in [State.LANDING, State.RUN_KICK, State.GUARD_BREAK, State.RIPOSTE]:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_shift_press_time < 0.35:
			# Double-click Shift -> Trigger RUN_KICK
			start_run_kick(move_dir)
		last_shift_press_time = current_time
	
	var target_speed = RUN_SPEED if is_run_key else WALK_SPEED
	
	# Un-crouch immediately when releasing crouch and pressing movement keys
	if current_state == State.CROUCH and not crouch_held:
		if move_dir != 0.0:
			set_state(State.RUN if is_run_key else State.WALK)
		elif crouch_sub_state != 2:
			crouch_sub_state = 2
			current_frame_idx = 0
	
	# 0. Dodge & Evasive Backstep Input Handling
	var dodge_just_pressed = Input.is_action_just_pressed("dodge") or (Input.is_key_pressed(KEY_ALT) and not shift_key_was_pressed)
	if dodge_just_pressed and is_on_floor() and current_state not in [State.LANDING, State.RUN_KICK, State.GUARD_BREAK, State.DODGE]:
		if current_state == State.ATTACK:
			var cur_frames = get_current_animation_frames()
			if current_frame_idx >= int(cur_frames.size() * 0.35):
				start_dodge(move_dir)
		else:
			start_dodge(move_dir)

	# 1. Guard Mechanic
	if guard_held and is_on_floor() and current_state not in [State.LANDING, State.ATTACK, State.CROUCH_ATTACK, State.RUN_KICK, State.GUARD_BREAK, State.RIPOSTE, State.DODGE]:
		if current_state != State.GUARD:
			set_state(State.GUARD)
	
	# 2. Attack Input Handling (Check riposte counter window first!)
	if attack_just_pressed and current_state not in [State.LANDING, State.RUN_KICK, State.GUARD_BREAK, State.DODGE]:
		if riposte_timer > 0.0 and is_instance_valid(riposte_target):
			trigger_riposte()
		else:
			var is_running_or_shift = is_run_key or current_state == State.RUN or abs(velocity.x) > WALK_SPEED + 10.0
			if is_running_or_shift and is_on_floor():
				start_run_kick(move_dir)
			elif crouch_held and is_on_floor():
				trigger_crouch_attack()
			else:
				trigger_attack(move_dir)
	
	# 3. Jump Input Handling
	if jump_just_pressed and is_on_floor() and current_state not in [State.ATTACK, State.CROUCH_ATTACK, State.LANDING, State.GUARD, State.RUN_KICK, State.GUARD_BREAK, State.RIPOSTE, State.DODGE]:
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)
	
	if move_dir != 0.0 and current_state not in [State.GUARD, State.CROUCH, State.LANDING, State.RUN_KICK, State.GUARD_BREAK, State.RIPOSTE, State.DODGE]:
		is_facing_left = (move_dir < 0.0)
	
	# Horizontal Velocity Calculations per State
	match current_state:
		State.DODGE:
			dodge_timer -= delta
			dodge_trail_timer -= delta
			if dodge_trail_timer <= 0.0:
				dodge_trail_timer = 0.06
				if sprite and sprite.texture:
					VFX.spawn_ghost_trail(get_parent(), sprite.texture, global_position + sprite.position, sprite.scale, sprite.flip_h, Color(0.35, 0.65, 1.0, 0.65))
			
			var speed_ratio = clampf(dodge_timer / DODGE_DURATION, 0.25, 1.0)
			velocity.x = dodge_direction * DODGE_SPEED * speed_ratio
			if not is_on_floor():
				velocity.y += GRAVITY * delta
			if dodge_timer <= 0.0:
				if is_on_floor():
					set_state(State.WALK if move_dir != 0.0 else State.IDLE)
				else:
					set_state(State.JUMP)
		State.RUN_KICK:
			var traveled_dist = abs(global_position.x - kick_start_x)
			
			# Frames 0-1 (begin01-02): Windup on ground
			if current_frame_idx <= 1:
				velocity.x = move_toward(velocity.x, 0.0, target_speed * 8.0 * delta)
			# Frames 2-3 (run_kick_01-02): Airborne flying kick impulse (capped by MAX_KICK_DISTANCE)
			elif current_frame_idx in [2, 3]:
				if traveled_dist >= MAX_KICK_DISTANCE:
					# Max range reached -> cap speed and transition to landing frames (end01)
					velocity.x = move_toward(velocity.x, 0.0, target_speed * 12.0 * delta)
					if current_frame_idx == 2:
						current_frame_idx = 3 # advance to frame 4 then to end01
				else:
					velocity.x = kick_direction * DASH_SPEED
			# Frames 4-8 (end01-05): Landing plant & recovery
			else:
				velocity.x = move_toward(velocity.x, 0.0, target_speed * 10.0 * delta)
		State.GUARD, State.CROUCH, State.CROUCH_ATTACK, State.LANDING:
			velocity.x = move_toward(velocity.x, 0.0, target_speed * 10.0 * delta)
		State.ATTACK:
			if not is_air_attack:
				if is_gliding_to_target:
					var dist_to_target = attack_glide_target_x - global_position.x
					if abs(dist_to_target) > 3.0:
						var glide_dir = signf(dist_to_target)
						velocity.x = move_toward(velocity.x, glide_dir * MAGNETIC_GLIDE_SPEED, 2400.0 * delta)
					else:
						velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
						is_gliding_to_target = false
				else:
					attack_whiff_step_speed = move_toward(attack_whiff_step_speed, 0.0, 420.0 * delta)
					velocity.x = attack_whiff_step_speed
		State.RIPOSTE:
			if is_gliding_to_target:
				var dist_to_target = attack_glide_target_x - global_position.x
				if abs(dist_to_target) > 4.0:
					var dash_dir = signf(dist_to_target)
					velocity.x = dash_dir * RIPOSTE_DASH_SPEED
				else:
					velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
					is_gliding_to_target = false
			else:
				velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
		_:
			if move_dir != 0.0:
				velocity.x = move_dir * target_speed
			else:
				velocity.x = move_toward(velocity.x, 0.0, target_speed * 8.0 * delta)
	
	move_and_slide()
	
	# Update sprite flip: flip the other way ONLY during JUMP state
	if current_state == State.JUMP:
		sprite.flip_h = not is_facing_left
	else:
		sprite.flip_h = is_facing_left
	
	# Check hazards / fall death
	if global_position.y > 600.0:
		player_died.emit()
	
	# Update State Machine & Transitions
	update_state_machine(move_dir, is_run_key, crouch_held, guard_held)
	
	# Advance Animation Frames
	update_animation(delta)
	
	# Attack Hit Detection against enemies
	if current_state in [State.ATTACK, State.CROUCH_ATTACK, State.RUN_KICK, State.RIPOSTE]:
		check_attack_hit_enemies()

func start_dodge(move_dir: float) -> void:
	if current_state == State.DODGE:
		return
	if current_stamina < DODGE_STAMINA_COST:
		return
	
	current_stamina -= DODGE_STAMINA_COST
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	
	dodge_timer = DODGE_DURATION
	invulnerable_timer = DODGE_IFRAME_DURATION
	
	if move_dir != 0.0:
		dodge_direction = move_dir
		is_facing_left = (move_dir < 0.0)
	else:
		# Neutral backstep: step opposite of current facing, but preserve facing!
		dodge_direction = 1.0 if is_facing_left else -1.0
		
	set_state(State.DODGE)
	dodge_trail_timer = 0.0
	
	if swing_audio_player:
		swing_audio_player.stream = ProceduralAudioScript.get_dodge_whoosh()
		swing_audio_player.pitch_scale = randf_range(0.96, 1.04)
		swing_audio_player.volume_db = -2.0
		swing_audio_player.play()
		
	if sprite and sprite.texture:
		VFX.spawn_ghost_trail(get_parent(), sprite.texture, global_position + sprite.position, sprite.scale, sprite.flip_h, Color(0.35, 0.65, 1.0, 0.75))

func start_run_kick(move_dir: float) -> void:
	if current_state == State.RUN_KICK:
		return
	if current_stamina < RUN_KICK_STAMINA_COST:
		# Not enough stamina for Flying Kick - perform normal ground attack instead
		trigger_attack(move_dir)
		return
	
	current_stamina -= RUN_KICK_STAMINA_COST
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	kick_start_x = global_position.x
	kick_direction = move_dir if move_dir != 0.0 else (-1.0 if is_facing_left else 1.0)
	is_facing_left = (kick_direction < 0.0)
	set_state(State.RUN_KICK)
	play_kick_launch_sfx()

func find_magnetic_attack_target(move_dir: float) -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var best_target: CharacterBody2D = null
	var best_score: float = -999999.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or not (enemy is CharacterBody2D):
			continue
		if enemy.get("is_dead") == true:
			continue
		
		var dx: float = enemy.global_position.x - global_position.x
		var dy: float = enemy.global_position.y - global_position.y
		var dist: float = abs(dx)
		
		if dist > MAGNETIC_ATTACK_RANGE or abs(dy) > 45.0:
			continue
		
		# Direction evaluation:
		# If user is holding left or right, strongly prefer enemies in that steered direction
		# If no input, prefer current facing direction
		var desired_dir: float = move_dir if move_dir != 0.0 else (-1.0 if is_facing_left else 1.0)
		var in_desired_dir: bool = (dx * desired_dir) > 0.0
		
		if move_dir != 0.0 and not in_desired_dir:
			continue
			
		var score: float = 1000.0 - dist
		if in_desired_dir:
			score += 500.0
			
		if score > best_score:
			best_score = score
			best_target = enemy
			
	return best_target

func start_attack_action(move_dir: float = 0.0) -> void:
	hit_enemies_this_swing.clear()
	set_state(State.ATTACK)
	var is_heavy = is_air_attack or (current_combo_idx == 3)
	play_swing_sfx(is_heavy)
	
	if is_air_attack:
		is_gliding_to_target = false
		attack_whiff_step_speed = 0.0
		return
	
	var target = find_magnetic_attack_target(move_dir)
	if target:
		var to_enemy_dir: float = 1.0 if target.global_position.x >= global_position.x else -1.0
		is_facing_left = (to_enemy_dir < 0.0)
		
		var target_offset: float = -MAGNETIC_TARGET_SPACING if to_enemy_dir > 0.0 else MAGNETIC_TARGET_SPACING
		attack_glide_target_x = target.global_position.x + target_offset
		is_gliding_to_target = true
		attack_whiff_step_speed = 0.0
	else:
		is_gliding_to_target = false
		var facing_sign: float = -1.0 if is_facing_left else 1.0
		attack_whiff_step_speed = facing_sign * WHIFF_STEP_IMPULSE

func trigger_attack(move_dir: float = 0.0) -> void:
	if riposte_timer > 0.0 and is_instance_valid(riposte_target):
		trigger_riposte()
		return

	if current_state == State.ATTACK:
		attack_queued = true
		return
	is_air_attack = (current_state == State.JUMP) or (not is_on_floor() and abs(velocity.y) > 50.0)
	if not is_air_attack:
		current_combo_idx = 0
	start_attack_action(move_dir)

func trigger_riposte() -> void:
	riposte_timer = 0.0
	is_air_attack = false
	var target = riposte_target
	if is_instance_valid(target):
		var to_enemy_dir: float = 1.0 if target.global_position.x >= global_position.x else -1.0
		is_facing_left = (to_enemy_dir < 0.0)
		var target_offset: float = -28.0 if to_enemy_dir > 0.0 else 28.0
		attack_glide_target_x = target.global_position.x + target_offset
		is_gliding_to_target = true
	else:
		is_gliding_to_target = false
		attack_whiff_step_speed = (-1.0 if is_facing_left else 1.0) * RIPOSTE_DASH_SPEED
	
	invulnerable_timer = 0.60
	set_state(State.RIPOSTE)
	play_swing_sfx(true)

func trigger_crouch_attack() -> void:
	if current_state == State.CROUCH_ATTACK:
		attack_queued = true
		return
	crouch_combo_idx = 0
	set_state(State.CROUCH_ATTACK)
	play_swing_sfx(false)

func detect_current_surface() -> String:
	if not is_inside_tree():
		return "dirt"
	var space_state = get_world_2d().direct_space_state
	if not space_state:
		return "dirt"
	var query = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -6),
		global_position + Vector2(0, 14),
		1
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result and result.collider is TileMapLayer:
		var tm := result.collider as TileMapLayer
		var cell = tm.local_to_map(tm.to_local(result.position + Vector2(0, 2)))
		var source_id = tm.get_cell_source_id(cell)
		if source_id == 1:
			return "wood"
	return "dirt"

func play_swing_sfx(is_heavy: bool = false) -> void:
	if not is_inside_tree() or not swing_audio_player:
		return
	var stream = ProceduralAudioScript.get_swing_whoosh(is_heavy, current_combo_idx)
	if stream:
		swing_audio_player.stream = stream
		swing_audio_player.pitch_scale = randf_range(0.95, 1.05)
		swing_audio_player.volume_db = -2.0 if is_heavy else -4.0
		swing_audio_player.play()

func play_hit_sfx(is_critical: bool = false) -> void:
	if not is_inside_tree() or not hit_audio_player:
		return
	var stream = ProceduralAudioScript.get_hit_slash(is_critical, current_combo_idx)
	if stream:
		hit_audio_player.stream = stream
		hit_audio_player.pitch_scale = randf_range(0.96, 1.04)
		hit_audio_player.volume_db = 0.0 if is_critical else -2.0
		hit_audio_player.play()

func play_pot_smash_sfx() -> void:
	if not is_inside_tree() or not hit_audio_player:
		return
	var stream = ProceduralAudioScript.get_pot_smash()
	if stream:
		hit_audio_player.stream = stream
		hit_audio_player.pitch_scale = randf_range(0.95, 1.05)
		hit_audio_player.volume_db = -3.0
		hit_audio_player.play()

func play_kick_launch_sfx() -> void:
	if not is_inside_tree() or not swing_audio_player:
		return
	var stream = ProceduralAudioScript.get_kick_launch()
	if stream:
		swing_audio_player.stream = stream
		swing_audio_player.pitch_scale = randf_range(0.96, 1.04)
		swing_audio_player.volume_db = -2.0
		swing_audio_player.play()

func play_kick_hit_sfx() -> void:
	if not is_inside_tree() or not hit_audio_player:
		return
	var stream = ProceduralAudioScript.get_kick_hit()
	if stream:
		hit_audio_player.stream = stream
		hit_audio_player.pitch_scale = randf_range(0.96, 1.04)
		hit_audio_player.volume_db = 0.0
		hit_audio_player.play()

func play_footstep(is_running: bool = false) -> void:
	if not is_on_floor() or not is_inside_tree():
		return
	
	footstep_cycle_index += 1
	var surface = detect_current_surface()
	var stream: AudioStream = null
	if surface == "wood":
		stream = ProceduralAudioScript.get_wood_footstep(footstep_cycle_index)
	else:
		stream = ProceduralAudioScript.get_grass_footstep(is_running, footstep_cycle_index)
	
	if footstep_audio_player and stream and is_inside_tree():
		footstep_audio_player.stream = stream
		# Subtle micro-pitch variation (0.96 to 1.04) keeps organic timbre natural
		footstep_audio_player.pitch_scale = randf_range(0.96, 1.04)
		footstep_audio_player.volume_db = -9.0 if is_running else -13.0
		footstep_audio_player.play()
	
	if footstep_dust_particles and is_inside_tree():
		var move_dir = -1.0 if is_facing_left else 1.0
		footstep_dust_particles.direction = Vector2(-move_dir, -0.35)
		footstep_dust_particles.amount = 4 if is_running else 2
		footstep_dust_particles.initial_velocity_min = 35.0 if is_running else 15.0
		footstep_dust_particles.initial_velocity_max = 70.0 if is_running else 30.0
		footstep_dust_particles.restart()
		footstep_dust_particles.emitting = true

func trigger_landing_feedback() -> void:
	if not is_inside_tree():
		return
	if landing_audio_player:
		landing_audio_player.stream = ProceduralAudioScript.get_landing_thud()
		landing_audio_player.pitch_scale = randf_range(0.96, 1.04)
		landing_audio_player.volume_db = -6.0
		landing_audio_player.play()
	
	if landing_dust_particles:
		landing_dust_particles.restart()
		landing_dust_particles.emitting = true

func update_state_machine(move_dir: float, is_run_key: bool, crouch_held: bool, guard_held: bool) -> void:
	# Locked animation states (wait until animation completes)
	if current_state in [State.ATTACK, State.CROUCH_ATTACK, State.RUN_KICK, State.LANDING, State.RIPOSTE, State.DODGE]:
		return
	
	# Handle Landing from Airborne
	if is_on_floor():
		if current_state == State.JUMP:
			trigger_landing_feedback()
			# Check Heavy Landing Impact Recovery (fall from high place)
			if max_fall_velocity >= HIGH_FALL_THRESHOLD:
				max_fall_velocity = 0.0
				set_state(State.LANDING)
				return
			max_fall_velocity = 0.0
			
			# Normal Landing
			if abs(velocity.x) > WALK_SPEED + 10.0:
				set_state(State.BREAK if move_dir == 0.0 else State.RUN)
			elif abs(velocity.x) > 10.0 or move_dir != 0.0:
				set_state(State.WALK)
			else:
				set_state(State.IDLE)
			return
		
		# Ground State Transitions
		if guard_held:
			if current_state != State.GUARD:
				set_state(State.GUARD)
			return
		elif current_state == State.GUARD:
			set_state(State.IDLE)
			return
		
		if crouch_held:
			if current_state != State.CROUCH or crouch_sub_state == 2:
				crouch_sub_state = 0
				set_state(State.CROUCH)
			return
		elif current_state == State.CROUCH:
			if move_dir != 0.0:
				set_state(State.RUN if is_run_key else State.WALK)
				return
			elif crouch_sub_state != 2:
				crouch_sub_state = 2
				current_frame_idx = 0
				return
		
		match current_state:
			State.IDLE:
				if move_dir != 0.0:
					set_state(State.RUN if is_run_key else State.WALK)
			State.WALK:
				if move_dir == 0.0 and abs(velocity.x) < 10.0:
					set_state(State.IDLE)
				elif is_run_key:
					set_state(State.RUN)
			State.RUN:
				if move_dir == 0.0:
					set_state(State.BREAK)
				elif not is_run_key:
					set_state(State.WALK)
			State.BREAK:
				if move_dir != 0.0:
					set_state(State.RUN if is_run_key else State.WALK)

func set_state(new_state: State) -> void:
	if current_state == new_state and new_state not in [State.BREAK, State.ATTACK, State.CROUCH_ATTACK, State.RUN_KICK, State.RIPOSTE, State.DODGE]:
		return
	current_state = new_state
	current_frame_idx = 0
	frame_timer = 0.0
	hit_enemies_this_swing.clear()
	apply_current_frame()

func update_animation(delta: float) -> void:
	var frames: Array[Texture2D] = get_current_animation_frames()
	if frames.is_empty():
		return
	
	frame_timer += delta
	var current_duration = frame_duration
	
	if current_state == State.RUN:
		current_duration = 0.07
	elif current_state == State.RUN_KICK:
		# Smooth, clearly readable frame timing (0.12s per frame for 9 frames)
		current_duration = 0.12
	elif current_state == State.DODGE:
		current_duration = 0.12
	elif current_state in [State.ATTACK, State.CROUCH_ATTACK, State.RIPOSTE]:
		current_duration = 0.07
	elif current_state in [State.BREAK, State.LANDING]:
		current_duration = 0.09
	
	if frame_timer >= current_duration:
		frame_timer -= current_duration
		
		match current_state:
			State.CROUCH:
				if crouch_sub_state == 0:
					if current_frame_idx < frames.size() - 1:
						current_frame_idx += 1
					else:
						crouch_sub_state = 1
						current_frame_idx = 0
				elif crouch_sub_state == 2:
					if current_frame_idx < frames.size() - 1:
						current_frame_idx += 1
					else:
						set_state(State.IDLE)
						return
			
			State.CROUCH_ATTACK:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					if attack_queued and crouch_combo_idx == 0:
						attack_queued = false
						crouch_combo_idx = 1
						current_frame_idx = 0
						hit_enemies_this_swing.clear()
						apply_current_frame()
						play_swing_sfx(false)
						return
					else:
						attack_queued = false
						var crouch_held = Input.is_action_pressed("crouch") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
						if crouch_held:
							crouch_sub_state = 1
							set_state(State.CROUCH)
						else:
							set_state(State.IDLE)
						return
			
			State.ATTACK:
				var is_recovery = current_frame_idx >= int(frames.size() * 0.65)
				var guard_pressed = Input.is_action_pressed("guard") or Input.is_key_pressed(KEY_K) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
				
				# Early guard cancel during recovery frames for snappy defense
				if is_recovery and guard_pressed and not is_air_attack:
					attack_queued = false
					set_state(State.GUARD)
					return
				
				# Early combo chaining during recovery frames
				if is_recovery and attack_queued and not is_air_attack:
					attack_queued = false
					current_combo_idx = (current_combo_idx + 1) % ground_attack_combos.size()
					current_frame_idx = 0
					var steer_dir = Input.get_axis("move_left", "move_right")
					start_attack_action(steer_dir)
					apply_current_frame()
					return

				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					if attack_queued and not is_air_attack:
						attack_queued = false
						current_combo_idx = (current_combo_idx + 1) % ground_attack_combos.size()
						current_frame_idx = 0
						var steer_dir = Input.get_axis("move_left", "move_right")
						start_attack_action(steer_dir)
						apply_current_frame()
						return
					else:
						attack_queued = false
						if not is_on_floor():
							set_state(State.JUMP)
						elif abs(velocity.x) > WALK_SPEED:
							set_state(State.RUN)
						elif abs(velocity.x) > 10.0:
							set_state(State.WALK)
						else:
							set_state(State.IDLE)
						return
			
			State.RIPOSTE:
				attack_queued = false
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					if sprite:
						sprite.modulate = Color(1, 1, 1, 1)
					set_state(State.IDLE)
					return

			State.RUN_KICK:
				attack_queued = false # Never queue ground combo attacks during run kick
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					set_state(State.RUN if abs(velocity.x) > WALK_SPEED else State.IDLE)
					return
			
			State.LANDING:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					var move_dir = Input.get_axis("move_left", "move_right")
					if abs(velocity.x) > WALK_SPEED or move_dir != 0.0:
						set_state(State.WALK)
					else:
						set_state(State.IDLE)
					return
			
			State.BREAK:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1
				else:
					set_state(State.WALK if abs(velocity.x) > 10.0 else State.IDLE)
					return
			
			State.JUMP:
				if current_frame_idx < frames.size() - 1:
					current_frame_idx += 1

			State.WALK:
				current_frame_idx = (current_frame_idx + 1) % frames.size()
				if current_frame_idx in [2, 8]:
					play_footstep(false)

			State.RUN:
				current_frame_idx = (current_frame_idx + 1) % frames.size()
				if current_frame_idx in [1, 4]:
					play_footstep(true)

			_:
				current_frame_idx = (current_frame_idx + 1) % frames.size()
		
		apply_current_frame()

func apply_current_frame() -> void:
	var frames = get_current_animation_frames()
	if not frames.is_empty():
		var idx = clamp(current_frame_idx, 0, frames.size() - 1)
		sprite.texture = frames[idx]

func get_current_animation_frames() -> Array[Texture2D]:
	match current_state:
		State.WALK:
			return walk_frames
		State.RUN:
			return run_frames
		State.BREAK:
			return break_frames
		State.JUMP:
			if velocity.y > 0.0 and not jump_fall_frames.is_empty():
				return jump_fall_frames
			return jump_up_frames
		State.ATTACK:
			if is_air_attack:
				return jump_attack_frames if not jump_attack_frames.is_empty() else ground_attack_combos[0]
			else:
				var combo_idx = clamp(current_combo_idx, 0, ground_attack_combos.size() - 1)
				return ground_attack_combos[combo_idx]
		State.RIPOSTE:
			return riposte_frames if not riposte_frames.is_empty() else ground_attack_combos[0]
		State.CROUCH:
			if crouch_sub_state == 0:
				return idle_to_crouch_frames if not idle_to_crouch_frames.is_empty() else idle_crouch_frames
			elif crouch_sub_state == 2:
				return crouch_to_idle_frames if not crouch_to_idle_frames.is_empty() else idle_crouch_frames
			else:
				return idle_crouch_frames
		State.CROUCH_ATTACK:
			return crouch_attack2_frames if crouch_combo_idx == 1 else crouch_attack1_frames
		State.GUARD:
			var crouch_held = Input.is_action_pressed("crouch") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
			if crouch_held:
				return guard_crouch_frames if not guard_crouch_frames.is_empty() else guard_stand_frames
			return guard_stand_frames
		State.RUN_KICK:
			return run_kick_frames
		State.DODGE:
			return backstep_frames if not backstep_frames.is_empty() else break_frames
		State.LANDING:
			return landing_frames
		State.IDLE:
			return idle_frames if not idle_frames.is_empty() else walk_frames
		_:
			return walk_frames

func check_attack_hit_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy in hit_enemies_this_swing:
			continue
		
		# Check if enemy is alive
		if enemy.get("is_dead") == true:
			continue
		
		var dx = enemy.global_position.x - global_position.x
		var dy = enemy.global_position.y - global_position.y
		var dist_x = abs(dx)
		
		# Hit box range based on attack type
		var max_reach = 54.0
		if current_state == State.RUN_KICK:
			max_reach = 68.0
		elif current_state == State.RIPOSTE:
			max_reach = 85.0
		
		var in_front = (is_facing_left and dx < 10.0 and dist_x <= max_reach) or (not is_facing_left and dx > -10.0 and dist_x <= max_reach)
		
		if in_front and abs(dy) < 45.0:
			hit_enemies_this_swing.append(enemy)
			var knock_dir: float = -1.0 if is_facing_left else 1.0
			var is_riposte = (current_state == State.RIPOSTE)
			var is_heavy = (current_state == State.RUN_KICK) or is_riposte
			var damage_amount = RIPOSTE_DAMAGE if is_riposte else (2 if is_heavy else 1)
			
			hit_landed.emit(is_heavy, enemy.global_position)
			if is_riposte:
				riposte_performed.emit(enemy.global_position)

			var is_counter_kill = is_riposte or (enemy.get("is_stunned_vulnerable") == true)
			var hit_center = enemy.global_position + Vector2(0, -42.0)
			if is_counter_kill:
				VFX.spawn_riposte_slash(get_parent(), hit_center, is_facing_left)
				VFX.spawn_blood_splatter(get_parent(), hit_center, Vector2(knock_dir, -0.6), 2.2, false)
			else:
				VFX.spawn_blood_slash(get_parent(), hit_center, is_facing_left, Vector2(1.3, 1.3) if is_heavy else Vector2(1.0, 1.0))
				VFX.spawn_blood_splatter(get_parent(), hit_center, Vector2(knock_dir, -0.4), 1.4 if is_heavy else 1.0, false)
			
			if current_state == State.RUN_KICK:
				play_kick_hit_sfx()
			else:
				play_hit_sfx(is_counter_kill or is_heavy)
			
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage_amount, knock_dir)
	
	# Check breakable objects (clay pots, etc.)
	var breakables = get_tree().get_nodes_in_group("breakables")
	for item in breakables:
		if not is_instance_valid(item) or item in hit_enemies_this_swing:
			continue
		if item.get("is_broken") == true:
			continue
		var dx = item.global_position.x - global_position.x
		var dy = item.global_position.y - global_position.y
		var dist_x = abs(dx)
		var max_reach = 58.0
		var in_front = (is_facing_left and dx < 12.0 and dist_x <= max_reach) or (not is_facing_left and dx > -12.0 and dist_x <= max_reach)
		if in_front and abs(dy) < 45.0:
			hit_enemies_this_swing.append(item)
			var knock_dir: float = -1.0 if is_facing_left else 1.0
			play_pot_smash_sfx()
			if item.has_method("smash"):
				item.smash(Vector2(knock_dir, -0.6))

func heal(amount: int = 1) -> void:
	current_hp = min(MAX_HEALTH, current_hp + amount)
	hp_changed.emit(current_hp, MAX_HEALTH)
	if sprite:
		sprite.modulate = Color(0.5, 1.8, 0.6, 1.0)
		get_tree().create_timer(0.25).timeout.connect(func(): if sprite: sprite.modulate = Color(1, 1, 1, 1))

func restore_stamina(amount: float = 60.0) -> void:
	current_stamina = min(MAX_STAMINA, current_stamina + amount)
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	if sprite:
		sprite.modulate = Color(1.8, 1.6, 0.4, 1.0)
		get_tree().create_timer(0.25).timeout.connect(func(): if sprite: sprite.modulate = Color(1, 1, 1, 1))

func respawn_at_safe_ledge(damage: int = 1) -> void:
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, MAX_HEALTH)
	damage_taken.emit(damage, false)
	if current_hp <= 0:
		player_died.emit()
	else:
		invulnerable_timer = 1.0
		velocity = Vector2.ZERO
		global_position = last_safe_ground_pos
		hurt_flash_timer = 0.35
		if sprite:
			sprite.modulate = Color(1.8, 0.3, 0.3, 1.0)

func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if invulnerable_timer > 0.0 or current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HEALTH)
	damage_taken.emit(amount, false)

	if sprite:
		sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)
	hurt_flash_timer = 0.25

	velocity.x = knockback_dir * 180.0
	velocity.y = -140.0
	invulnerable_timer = IFRAME_DURATION

	if current_hp <= 0:
		player_died.emit()

func take_damage_from_enemy(amount: int, enemy_dir: float, attacker_node: Node = null) -> void:
	if invulnerable_timer > 0.0 or current_hp <= 0:
		if current_state == State.DODGE:
			VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -38), "EVADED", Color(0.45, 0.85, 1.0, 0.95), 13)
		return
	
	# If guarding and facing enemy attack direction:
	var is_facing_enemy = (is_facing_left and enemy_dir > 0) or (not is_facing_left and enemy_dir < 0)
	
	# Magnetic auto-face on parry forgiveness:
	# If guarding and close-range attack comes from behind, auto-snap facing to reward the parry!
	if current_state == State.GUARD and not is_facing_enemy:
		var dist_to_attacker = global_position.distance_to(attacker_node.global_position) if is_instance_valid(attacker_node) else 999.0
		if dist_to_attacker <= PARRY_AUTO_FACE_MAX_DIST:
			is_facing_left = not is_facing_left
			is_facing_enemy = true
			if sprite:
				sprite.flip_h = is_facing_left

	if current_state == State.GUARD and is_facing_enemy:
		# 1. PERFECT BLOCK / PARRY (first 0.20s of guard)
		if guard_time_held <= PARRY_WINDOW:
			# Perfect Parry: 0 damage, 0 stamina cost, +20 bonus stamina surge
			current_stamina = min(MAX_STAMINA, current_stamina + 20.0)
			stamina_changed.emit(current_stamina, MAX_STAMINA)
			
			# Open critical Riposte window!
			riposte_timer = RIPOSTE_WINDOW_DURATION
			riposte_target = attacker_node as CharacterBody2D if attacker_node is CharacterBody2D else null
			
			# Golden shield clash flash
			sprite.modulate = Color(2.0, 1.8, 0.5, 1.0)
			get_tree().create_timer(0.25).timeout.connect(func(): if sprite and current_state != State.RIPOSTE: sprite.modulate = Color(1, 1, 1, 1))
			
			# Light pushback
			velocity.x = enemy_dir * 30.0
			
			# Spawn Golden Parry Clash & Spark Burst VFX at clash contact point
			var enemy_pos = attacker_node.global_position if is_instance_valid(attacker_node) else global_position
			var clash_pos = (global_position + enemy_pos) * 0.5 + Vector2(0, -18.0)
			VFX.spawn_parry_clash(get_parent(), clash_pos)
			
			# Deflect the attacking monster into Vulnerable Stun!
			if is_instance_valid(attacker_node) and attacker_node.has_method("deflect_by_parry"):
				attacker_node.deflect_by_parry(-enemy_dir)
			
			damage_taken.emit(0, true)
			return
		else:
			# 2. IMPERFECT BLOCK (Holding guard early / long guard)
			# Player feels the hit: 1 chip damage, 35 stamina loss (block meter drain)
			current_hp = max(0, current_hp - 1)
			hp_changed.emit(current_hp, MAX_HEALTH)
			
			current_stamina = max(0.0, current_stamina - 35.0)
			stamina_changed.emit(current_stamina, MAX_STAMINA)
			
			# Spawn Guard Impact Barrier VFX in front of player's shield
			var guard_pos = global_position + Vector2(-16.0 if is_facing_left else 16.0, -18.0)
			VFX.spawn_guard_impact(get_parent(), guard_pos)

			# Light chip blood spray
			VFX.spawn_blood_splatter(get_parent(), global_position + Vector2(0, -42.0), Vector2(-enemy_dir, -0.3), 0.6, true)
			
			if current_stamina <= 0.0:
				# Block meter depleted -> GUARD BREAK!
				trigger_guard_break(enemy_dir)
			else:
				# Standard guard stumble pushback
				velocity.x = enemy_dir * 130.0
				velocity.y = -60.0
				sprite.modulate = Color(1.0, 0.5, 0.3, 1.0)
				hurt_flash_timer = 0.20
				invulnerable_timer = 0.60
			
			damage_taken.emit(1, true)
			
			if current_hp <= 0:
				player_died.emit()
			return
	
	# 3. UNGUARDED HIT: Full damage, heavy knockback, full i-frames
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HEALTH)
	damage_taken.emit(amount, false)

	# Visceral Player Blood Burst & Slash VFX
	var blood_pos = global_position + Vector2(0, -42.0)
	VFX.spawn_blood_slash(get_parent(), blood_pos, enemy_dir > 0, Vector2(1.1, 1.1))
	VFX.spawn_blood_splatter(get_parent(), blood_pos, Vector2(-enemy_dir, -0.5), 1.5, true)
	
	# Crimson damage flash
	sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)
	hurt_flash_timer = 0.22
	
	# Knockback impulse
	velocity.x = enemy_dir * 180.0
	velocity.y = -140.0
	
	# Full invulnerability window
	invulnerable_timer = IFRAME_DURATION
	
	if current_hp <= 0:
		player_died.emit()

func trigger_guard_break(enemy_dir: float) -> void:
	set_state(State.GUARD_BREAK)
	guard_break_timer = 0.60
	velocity.x = enemy_dir * 160.0
	velocity.y = -80.0
	if is_instance_valid(sprite):
		sprite.modulate = Color(1.0, 0.35, 0.35, 1.0)
	invulnerable_timer = 0.60
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -56.0), "GUARD BROKEN!", Color(0.4, 0.6, 1.0), 15, true)

func reset_combat_state() -> void:
	is_locked_transition = false
	current_hp = MAX_HEALTH
	current_stamina = MAX_STAMINA
	invulnerable_timer = 0.0
	guard_time_held = 0.0
	guard_break_timer = 0.0
	hurt_flash_timer = 0.0
	riposte_timer = 0.0
	riposte_target = null
	is_gliding_to_target = false
	attack_glide_target_x = 0.0
	attack_whiff_step_speed = 0.0
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	hp_changed.emit(current_hp, MAX_HEALTH)
	stamina_changed.emit(current_stamina, MAX_STAMINA)

func start_walk_off() -> void:
	is_locked_transition = true
	is_facing_left = false
	invulnerable_timer = 2.0
	if is_on_floor():
		set_state(State.WALK)

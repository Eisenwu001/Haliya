class_name BakunawaBoss
extends CharacterBody2D

signal boss_hp_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(new_phase: int)
signal boss_died(boss: BakunawaBoss)
signal stalactite_drop_requested(x_pos: float)
signal wisp_summon_requested(pos: Vector2)

enum State {
	INTRO,
	IDLE,
	CHASE,
	COIL_LUNGE,
	TIDAL_BREATH,
	TAIL_SLAM_QUAKE,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const TEX_IDLE_FALLBACK = preload("res://assets/bakunawa/bakunawa_idle.png")
const TEX_BREATH_FALLBACK = preload("res://assets/bakunawa/bakunawa_breath.png")
const ProjectileScript = preload("res://scripts/bakunawa_projectile.gd")
const StalactiteScript = preload("res://scripts/stalactite_hazard.gd")

const MAX_HEALTH: int = 112
const BASE_HOVER_Y: float = 175.0
const LUNGE_SPEED: float = 360.0
const CHASE_SPEED: float = 92.0
const BASE_SPRITE_SCALE: Vector2 = Vector2(0.27, 0.27)

var tex_idle: Texture2D = TEX_IDLE_FALLBACK
var tex_roar: Texture2D = TEX_BREATH_FALLBACK

var current_state: State = State.INTRO
var health: int = MAX_HEALTH
var current_phase: int = 1
var is_facing_left: bool = true
var is_dead: bool = false
var has_enraged: bool = false

# Timers & Combat Variables
var state_timer: float = 0.0
var attack_cooldown: float = 1.2
var lunge_cooldown_timer: float = 3.2
var breath_cooldown_timer: float = 5.2
var quake_cooldown_timer: float = 7.5
var wisp_summon_timer: float = 11.0
var sin_wave_timer: float = 0.0
var afterimage_timer: float = 0.0

var is_telegraphing: bool = false
var telegraph_timer: float = 0.0
var lunge_direction: float = -1.0
var has_hit_player_this_lunge: bool = false
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var breath_shots_fired: int = 0
var breath_interval_timer: float = 0.0
var double_lunge_pending: bool = false
var has_slammed_ground: bool = false
var intro_roar_done: bool = false

# Visual nodes
var sprite: Sprite2D
var stun_stars: Sprite2D
var aura_particles: CPUParticles2D
var boss_light: PointLight2D
var maw_vortex: Node2D
var maw_ring_outer: Polygon2D
var maw_ring_inner: Polygon2D
var maw_particles: CPUParticles2D
var serpent_root: Node2D
var serpent_segments: Array[Node2D] = []
var collision_shape: CollisionShape2D
var target_player: CharacterBody2D = null

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	add_to_group("boss")
	
	_load_clean_textures()
	setup_nodes()
	# Start submerged in the abyssal depths so State.INTRO erupts dramatically upward
	if global_position.y < 320.0:
		global_position.y = 385.0
	set_state(State.INTRO)
	state_timer = 2.5
	_spawn_abyssal_splash(Vector2(global_position.x, 285.0), 1.3)

func _load_clean_textures() -> void:
	var clean_path = ProjectSettings.globalize_path("res://assets/bakunawa/bakunawa_clean.png")
	if FileAccess.file_exists(clean_path):
		var img_clean = Image.load_from_file(clean_path)
		if img_clean and not img_clean.is_empty():
			tex_idle = ImageTexture.create_from_image(img_clean)
	elif ResourceLoader.exists("res://assets/bakunawa/bakunawa_clean.png"):
		tex_idle = load("res://assets/bakunawa/bakunawa_clean.png") as Texture2D

	var roar_path = ProjectSettings.globalize_path("res://assets/bakunawa/bakunawa_roar.png")
	if FileAccess.file_exists(roar_path):
		var img_roar = Image.load_from_file(roar_path)
		if img_roar and not img_roar.is_empty():
			tex_roar = ImageTexture.create_from_image(img_roar)
	elif ResourceLoader.exists("res://assets/bakunawa/bakunawa_roar.png"):
		tex_roar = load("res://assets/bakunawa/bakunawa_roar.png") as Texture2D

func setup_nodes() -> void:
	collision_layer = 4 # Enemies layer
	collision_mask = 1  # Solid ground

	# Articulated undulating sea-serpent tail/body segments behind main torso
	serpent_root = Node2D.new()
	serpent_root.name = "SerpentCoils"
	serpent_root.z_index = -1
	add_child(serpent_root)
	_build_serpent_segments()

	# Boss sprite (uses TEXTURE_FILTER_LINEAR to eliminate downscale pixel shimmer on 1011x930 art)
	sprite = Sprite2D.new()
	sprite.name = "BossSprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.texture = tex_idle
	sprite.scale = BASE_SPRITE_SCALE
	sprite.centered = true
	sprite.position = Vector2(0, -60.0)
	add_child(sprite)

	# Maw Vortex (charges at Bakunawa's open jaws during Tidal Breath & Roars)
	maw_vortex = Node2D.new()
	maw_vortex.name = "MawVortex"
	maw_vortex.position = Vector2(-62.0, -56.0)
	maw_vortex.visible = false
	add_child(maw_vortex)

	var vortex_mat = CanvasItemMaterial.new()
	vortex_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	maw_ring_outer = Polygon2D.new()
	maw_ring_outer.material = vortex_mat
	var outer_pts = PackedVector2Array()
	for i in range(16):
		var a = (float(i) / 16.0) * TAU
		var r = 22.0 if i % 2 == 0 else 13.0
		outer_pts.append(Vector2(cos(a) * r, sin(a) * r))
	maw_ring_outer.polygon = outer_pts
	maw_ring_outer.color = Color(0.20, 0.72, 1.0, 0.65)
	maw_vortex.add_child(maw_ring_outer)

	maw_ring_inner = Polygon2D.new()
	maw_ring_inner.material = vortex_mat
	var inner_pts = PackedVector2Array()
	for i in range(12):
		var a = (float(i) / 12.0) * TAU
		var r = 10.0 if i % 2 == 0 else 6.0
		inner_pts.append(Vector2(cos(a) * r, sin(a) * r))
	maw_ring_inner.polygon = inner_pts
	maw_ring_inner.color = Color(0.85, 0.96, 1.0, 0.9)
	maw_vortex.add_child(maw_ring_inner)

	maw_particles = CPUParticles2D.new()
	maw_particles.emitting = false
	maw_particles.amount = 20
	maw_particles.lifetime = 0.45
	maw_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	maw_particles.emission_sphere_radius = 18.0
	maw_particles.spread = 180.0
	maw_particles.gravity = Vector2.ZERO
	maw_particles.initial_velocity_min = 15.0
	maw_particles.initial_velocity_max = 45.0
	maw_particles.scale_amount_min = 2.0
	maw_particles.scale_amount_max = 4.5
	maw_particles.color = Color(0.45, 0.88, 1.0, 0.85)
	maw_vortex.add_child(maw_particles)

	# Bioluminescent Abyssal PointLight2D
	boss_light = PointLight2D.new()
	boss_light.name = "BossAbyssalLight"
	boss_light.color = Color(0.32, 0.74, 1.0, 1.0)
	boss_light.energy = 1.35
	boss_light.texture_scale = 2.4
	boss_light.position = Vector2(0, -60.0)
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = grad
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(0.5, 0.0)
	boss_light.texture = grad_tex
	add_child(boss_light)

	# Collision Capsule
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape = CapsuleShape2D.new()
	shape.radius = 34.0
	shape.height = 116.0
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -52.0)
	add_child(collision_shape)

	# Stun Stars
	stun_stars = Sprite2D.new()
	stun_stars.texture = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	stun_stars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stun_stars.hframes = 3
	stun_stars.vframes = 2
	stun_stars.scale = Vector2(0.12, 0.12)
	stun_stars.position = Vector2(0, -118.0)
	stun_stars.visible = false
	add_child(stun_stars)

	# Lunar Abyssal Aura Particles
	aura_particles = CPUParticles2D.new()
	aura_particles.name = "AuraParticles"
	aura_particles.amount = 34
	aura_particles.lifetime = 1.25
	aura_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	aura_particles.emission_rect_extents = Vector2(68, 56)
	aura_particles.direction = Vector2(0, -1)
	aura_particles.spread = 45.0
	aura_particles.gravity = Vector2(0, -42.0)
	aura_particles.initial_velocity_min = 22.0
	aura_particles.initial_velocity_max = 55.0
	aura_particles.scale_amount_min = 2.0
	aura_particles.scale_amount_max = 4.5
	aura_particles.color = Color(0.32, 0.72, 1.0, 0.58)
	aura_particles.position = Vector2(0, -50.0)
	add_child(aura_particles)

func _build_serpent_segments() -> void:
	serpent_segments.clear()
	var seg_radii = [28.0, 25.0, 22.0, 18.0, 14.0, 10.0]
	for i in range(seg_radii.size()):
		var r: float = seg_radii[i]
		var seg = Node2D.new()
		seg.name = "SerpentSeg_%d" % i

		# Dark armored abyssal scale body
		var body_poly = Polygon2D.new()
		var pts = PackedVector2Array()
		for k in range(12):
			var a = (float(k) / 12.0) * TAU
			pts.append(Vector2(cos(a) * r * 1.18, sin(a) * r * 0.92))
		body_poly.polygon = pts
		body_poly.color = Color(0.06, 0.11, 0.20, 0.92 - i * 0.06)
		seg.add_child(body_poly)

		# Spined cyan dorsal fin
		var fin_poly = Polygon2D.new()
		fin_poly.polygon = PackedVector2Array([
			Vector2(-r * 0.65, -r * 0.65),
			Vector2(r * 0.15, -r * 1.55),
			Vector2(r * 0.75, -r * 0.55)
		])
		fin_poly.color = Color(0.14, 0.48, 0.82, 0.85 - i * 0.06)
		seg.add_child(fin_poly)

		# Glowing bioluminescent scale chevron
		var ridge_poly = Polygon2D.new()
		ridge_poly.name = "ScaleRidge"
		ridge_poly.polygon = PackedVector2Array([
			Vector2(-r * 0.45, -r * 0.15),
			Vector2(0.0, -r * 0.52),
			Vector2(r * 0.45, -r * 0.15),
			Vector2(0.0, r * 0.22)
		])
		ridge_poly.color = Color(0.32, 0.78, 1.0, 0.75 - i * 0.05)
		seg.add_child(ridge_poly)

		serpent_root.add_child(seg)
		serpent_segments.append(seg)

func _update_serpent_segments(delta: float) -> void:
	var face_sign = 1.0 if is_facing_left else -1.0
	var speed_factor = 1.45 if current_state == State.COIL_LUNGE else (1.25 if current_phase == 2 else 1.0)
	for i in range(serpent_segments.size()):
		var seg = serpent_segments[i]
		if not is_instance_valid(seg):
			continue
		var t = sin_wave_timer * 4.2 * speed_factor - float(i) * 0.68
		var base_x = face_sign * (38.0 + float(i) * 20.0)
		var base_y = -20.0 + float(i) * 4.0
		var wave_y = sin(t) * (10.0 + float(i) * 3.5)
		var wave_x = cos(t * 0.5) * 6.0
		var target_pos = Vector2(base_x + wave_x, base_y + wave_y)
		seg.position = seg.position.lerp(target_pos, clampf(delta * 12.0, 0.0, 1.0))
		seg.rotation = sin(t - 0.4) * 0.24 * face_sign
		seg.scale.x = 1.0 if is_facing_left else -1.0

func _physics_process(delta: float) -> void:
	if is_dead:
		handle_death_process(delta)
		return

	# Out of bounds / void safety check (skip during INTRO emergence from the abyss)
	if current_state != State.INTRO and global_position.y > 410.0:
		global_position.y = BASE_HOVER_Y

	sin_wave_timer += delta
	_update_serpent_segments(delta)

	# Animate maw vortex if visible
	if maw_vortex and maw_vortex.visible:
		var maw_x = -62.0 if is_facing_left else 62.0
		maw_vortex.position = Vector2(maw_x, -56.0 + sin(sin_wave_timer * 8.0) * 3.0)
		if maw_ring_outer:
			maw_ring_outer.rotation += delta * 5.5
			var s = 0.9 + 0.25 * sin(sin_wave_timer * 18.0)
			maw_ring_outer.scale = Vector2(s, s)
		if maw_ring_inner:
			maw_ring_inner.rotation -= delta * 8.0

	# Cache player
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as CharacterBody2D

	# Hurt flash decay
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and sprite:
			update_phase_modulate()

	# Cooldowns
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if lunge_cooldown_timer > 0.0:
		lunge_cooldown_timer -= delta
	if breath_cooldown_timer > 0.0:
		breath_cooldown_timer -= delta
	if quake_cooldown_timer > 0.0:
		quake_cooldown_timer -= delta

	# Phase 2 periodic wisp summons
	if current_phase == 2 and current_state in [State.IDLE, State.CHASE]:
		wisp_summon_timer -= delta
		if wisp_summon_timer <= 0.0:
			wisp_summon_timer = 14.0
			_summon_eclipse_wisps(1)

	# State machine update
	update_state_logic(delta)
	move_and_slide()

	# Face player direction during tracking states
	if current_state in [State.IDLE, State.CHASE, State.INTRO, State.TIDAL_BREATH]:
		if is_instance_valid(target_player):
			var to_player = target_player.global_position.x - global_position.x
			if abs(to_player) > 15.0:
				is_facing_left = (to_player < 0)
	
	if sprite:
		# Native asset faces left; flip if facing right
		sprite.flip_h = not is_facing_left

func update_state_logic(delta: float) -> void:
	var face_sign = 1.0 if is_facing_left else -1.0
	match current_state:
		State.INTRO:
			# Erupt upward from the subterranean abyss with water plumes and roar
			state_timer -= delta
			var hover_target_y = BASE_HOVER_Y + sin(sin_wave_timer * 2.5) * 14.0
			global_position.y = move_toward(global_position.y, hover_target_y, 115.0 * delta)
			if sprite:
				sprite.rotation = lerp(sprite.rotation, sin(sin_wave_timer * 3.5) * 0.08, delta * 6.0)
				var b_scale = 1.0 + sin(sin_wave_timer * 4.0) * 0.03
				sprite.scale = BASE_SPRITE_SCALE * Vector2(b_scale, 2.0 - b_scale)
			if state_timer <= 0.95 and not intro_roar_done:
				intro_roar_done = true
				if sprite:
					sprite.texture = tex_roar
				_set_maw_vortex_active(true)
				_spawn_abyssal_splash(global_position + Vector2(0, 20.0), 1.0)
			if state_timer <= 0.0:
				_set_maw_vortex_active(false)
				set_state(State.IDLE)

		State.IDLE:
			# Serpentine figure-8 undulating hover & organic breathing
			var hover_y = BASE_HOVER_Y + sin(sin_wave_timer * 2.8) * 20.0
			global_position.y = move_toward(global_position.y, hover_y, 65.0 * delta)
			velocity.x = move_toward(velocity.x, cos(sin_wave_timer * 1.4) * 18.0, 150.0 * delta)
			if sprite:
				sprite.rotation = lerp(sprite.rotation, cos(sin_wave_timer * 2.8) * 0.055 * face_sign, delta * 8.0)
				var breath = sin(sin_wave_timer * 3.6) * 0.025
				sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE * Vector2(1.0 + breath, 1.0 - breath), delta * 8.0)
				sprite.position = sprite.position.lerp(Vector2(0, -60.0), delta * 8.0)

			state_timer -= delta
			if state_timer <= 0.0:
				pick_next_action()

		State.CHASE:
			# Glide toward player horizontal zone while undulating
			var hover_y = BASE_HOVER_Y + sin(sin_wave_timer * 3.2) * 22.0
			global_position.y = move_toward(global_position.y, hover_y, 80.0 * delta)

			if is_instance_valid(target_player):
				var dx = target_player.global_position.x - global_position.x
				var target_dist = 225.0
				var desired_x = target_player.global_position.x + (target_dist if dx < 0 else -target_dist)
				desired_x = clampf(desired_x, 3840.0, 5000.0)
				var dir_x = sign(desired_x - global_position.x)
				var speed = CHASE_SPEED * (1.35 if current_phase == 2 else 1.0)
				velocity.x = move_toward(velocity.x, dir_x * speed, 210.0 * delta)
			
			if sprite:
				var lean = clampf(-velocity.x / 450.0, -0.12, 0.12)
				sprite.rotation = lerp(sprite.rotation, lean + sin(sin_wave_timer * 3.2) * 0.04, delta * 8.0)
				sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE, delta * 8.0)

			state_timer -= delta
			if state_timer <= 0.0:
				pick_next_action()

		State.COIL_LUNGE:
			if is_telegraphing:
				# Coiled windup: rear back, pitch head up, compress spring-like coils!
				telegraph_timer -= delta
				velocity.x = move_toward(velocity.x, -lunge_direction * 85.0, 320.0 * delta)
				global_position.y = move_toward(global_position.y, BASE_HOVER_Y - 22.0, 90.0 * delta)
				var pulse = 0.5 + 0.5 * sin(telegraph_timer * 34.0)
				if sprite:
					sprite.modulate = Color(1.25 + pulse * 0.75, 0.45, 0.75, 1.0)
					sprite.rotation = lerp(sprite.rotation, -lunge_direction * 0.22, delta * 12.0)
					sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE * Vector2(0.88, 1.12), delta * 10.0)
				if telegraph_timer <= 0.0:
					is_telegraphing = false
					var spd = LUNGE_SPEED * (1.28 if current_phase == 2 else 1.0)
					velocity.x = lunge_direction * spd
					velocity.y = 135.0 # Dive low along the cavern ground
					if sprite:
						sprite.texture = tex_roar
						sprite.rotation = lunge_direction * 0.16
						sprite.scale = BASE_SPRITE_SCALE * Vector2(1.16, 0.88)
					update_phase_modulate()
			else:
				# Sweeping predatory lunge along ground plane with ghost trail
				state_timer -= delta
				afterimage_timer -= delta
				if afterimage_timer <= 0.0 and sprite:
					afterimage_timer = 0.055
					var trail_col = Color(0.25, 0.75, 1.0, 0.48) if current_phase == 1 else Color(0.95, 0.25, 0.65, 0.52)
					VFX.spawn_ghost_trail(get_parent(), sprite.texture, sprite.global_position, sprite.scale, sprite.flip_h, trail_col)
				if not has_hit_player_this_lunge:
					check_lunge_hit()
				if state_timer <= 0.0:
					if double_lunge_pending and current_phase == 2:
						# Phase 2: Reverse lunge immediately!
						double_lunge_pending = false
						lunge_direction *= -1.0
						is_facing_left = (lunge_direction < 0)
						is_telegraphing = true
						telegraph_timer = 0.26
						has_hit_player_this_lunge = false
						state_timer = 0.78
					else:
						set_state(State.IDLE)

		State.TIDAL_BREATH:
			# Hover in place, charge abyssal maw vortex, and spit cascading eclipse-water orbs
			velocity = Vector2.ZERO
			var hover_y = BASE_HOVER_Y - 10.0 + sin(sin_wave_timer * 4.0) * 10.0
			global_position.y = move_toward(global_position.y, hover_y, 70.0 * delta)
			if sprite:
				sprite.position = sprite.position.lerp(Vector2(0, -60.0), delta * 10.0)
				sprite.rotation = lerp(sprite.rotation, -0.06 * face_sign, delta * 8.0)
				sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE * Vector2(1.04, 0.97), delta * 8.0)

			breath_interval_timer -= delta
			var total_shots = 5 if current_phase == 2 else 3
			if breath_interval_timer <= 0.0 and breath_shots_fired < total_shots:
				breath_interval_timer = 0.26 if current_phase == 2 else 0.30
				breath_shots_fired += 1
				fire_breath_projectile()
			
			state_timer -= delta
			if state_timer <= 0.0:
				_set_maw_vortex_active(false)
				set_state(State.IDLE)

		State.TAIL_SLAM_QUAKE:
			velocity.x = move_toward(velocity.x, 0.0, 220.0 * delta)
			state_timer -= delta
			if state_timer > 0.72:
				# Phase 1: Rear high toward cavern roof before slamming!
				global_position.y = move_toward(global_position.y, BASE_HOVER_Y - 58.0, 180.0 * delta)
				if sprite:
					sprite.rotation = lerp(sprite.rotation, 0.24 * face_sign, delta * 10.0)
					sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE * Vector2(0.92, 1.12), delta * 10.0)
			elif not has_slammed_ground:
				# Phase 2: Crash violently down onto cavern floor!
				global_position.y = move_toward(global_position.y, BASE_HOVER_Y + 68.0, 520.0 * delta)
				if sprite:
					sprite.rotation = lerp(sprite.rotation, -0.18 * face_sign, delta * 16.0)
					sprite.scale = BASE_SPRITE_SCALE * Vector2(1.18, 0.84)
				if global_position.y >= BASE_HOVER_Y + 60.0:
					has_slammed_ground = true
					_execute_quake_impact()
			else:
				# Recover back to hover height
				global_position.y = move_toward(global_position.y, BASE_HOVER_Y, 130.0 * delta)
				if sprite:
					sprite.rotation = lerp(sprite.rotation, 0.0, delta * 8.0)
					sprite.scale = sprite.scale.lerp(BASE_SPRITE_SCALE, delta * 8.0)

			if state_timer <= 0.0:
				set_state(State.IDLE)

		State.PARRIED_STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 250.0 * delta)
			stun_timer -= delta
			if stun_stars:
				stun_stars.visible = true
				stun_stars.rotation += delta * 6.0
				stun_stars.frame = int(Time.get_ticks_msec() / 100.0) % 6
			var glow = 0.5 + 0.5 * sin(stun_timer * 22.0)
			if sprite:
				sprite.modulate = Color(1.5 + glow * 0.5, 1.4 + glow * 0.4, 0.4, 1.0)
				sprite.rotation = lerp(sprite.rotation, 0.18 * face_sign, delta * 8.0)
			if stun_timer <= 0.0:
				is_stunned_vulnerable = false
				if stun_stars:
					stun_stars.visible = false
				update_phase_modulate()
				attack_cooldown = 1.0
				set_state(State.IDLE)

		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				set_state(State.IDLE)

func pick_next_action() -> void:
	if attack_cooldown > 0.0:
		set_state(State.CHASE)
		return

	var r = randf()
	if breath_cooldown_timer <= 0.0 and r < 0.40:
		start_tidal_breath()
	elif quake_cooldown_timer <= 0.0 and r < 0.72:
		start_tail_slam_quake()
	elif lunge_cooldown_timer <= 0.0:
		start_coil_lunge()
	else:
		set_state(State.CHASE)
		state_timer = randf_range(1.1, 2.0)

func start_coil_lunge() -> void:
	lunge_cooldown_timer = randf_range(3.4, 4.8) if current_phase == 1 else randf_range(2.3, 3.5)
	if is_instance_valid(target_player):
		lunge_direction = -1.0 if target_player.global_position.x < global_position.x else 1.0
	else:
		lunge_direction = -1.0 if is_facing_left else 1.0
	
	is_facing_left = (lunge_direction < 0)
	is_telegraphing = true
	telegraph_timer = 0.45
	has_hit_player_this_lunge = false
	double_lunge_pending = (current_phase == 2)
	state_timer = 0.85
	set_state(State.COIL_LUNGE)

func start_tidal_breath() -> void:
	breath_cooldown_timer = randf_range(5.2, 7.0) if current_phase == 1 else randf_range(3.8, 5.2)
	breath_shots_fired = 0
	breath_interval_timer = 0.24
	state_timer = 1.85 if current_phase == 2 else 1.35
	_set_maw_vortex_active(true)
	set_state(State.TIDAL_BREATH)

func _set_maw_vortex_active(active: bool) -> void:
	if maw_vortex:
		maw_vortex.visible = active
	if maw_particles:
		maw_particles.emitting = active

func fire_breath_projectile() -> void:
	if not is_inside_tree():
		return
	var proj = ProjectileScript.new()
	var spawn_offset = Vector2(-68.0 if is_facing_left else 68.0, -56.0)
	proj.global_position = global_position + spawn_offset
	if "is_enraged" in proj:
		proj.is_enraged = (current_phase == 2)
	
	var dir = Vector2.LEFT if is_facing_left else Vector2.RIGHT
	if is_instance_valid(target_player):
		var target_vec = (target_player.global_position + Vector2(0, -20.0) - proj.global_position).normalized()
		dir = target_vec
	
	# Slight vertical spread
	dir.y += randf_range(-0.14, 0.14)
	proj.direction = dir.normalized()
	get_parent().add_child(proj)

	# Visual recoil kickback on head/sprite when spitting an orb
	if sprite:
		var kick_x = 10.0 if is_facing_left else -10.0
		sprite.position = Vector2(kick_x, -63.0)
		sprite.scale = BASE_SPRITE_SCALE * Vector2(1.10, 0.92)

func start_tail_slam_quake() -> void:
	quake_cooldown_timer = randf_range(6.8, 9.0) if current_phase == 1 else randf_range(4.8, 6.5)
	state_timer = 1.35
	has_slammed_ground = false
	set_state(State.TAIL_SLAM_QUAKE)

func _execute_quake_impact() -> void:
	if not is_inside_tree():
		return
	_spawn_quake_shockwave(Vector2(global_position.x, 280.0))

	# Trigger falling stalactites across arena
	var center_x = global_position.x
	if is_instance_valid(target_player):
		center_x = target_player.global_position.x
	
	var drops_count = 6 if current_phase == 2 else 4
	for i in range(drops_count):
		var spread = -240.0 + (480.0 * float(i) / float(max(1, drops_count - 1))) + randf_range(-28.0, 28.0)
		var drop_x = clampf(center_x + spread, 3820.0, 5020.0)
		stalactite_drop_requested.emit(drop_x)
		spawn_stalactite(drop_x)

func _spawn_quake_shockwave(impact_pos: Vector2) -> void:
	if not is_inside_tree() or not get_parent():
		return
	var wave_root = Node2D.new()
	wave_root.global_position = impact_pos
	get_parent().add_child(wave_root)

	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	for dir_sign in [-1.0, 1.0]:
		var crest = Polygon2D.new()
		crest.material = mat
		crest.polygon = PackedVector2Array([
			Vector2(0, 0),
			Vector2(dir_sign * 18.0, -28.0),
			Vector2(dir_sign * 34.0, -12.0),
			Vector2(dir_sign * 42.0, 0)
		])
		crest.color = Color(0.32, 0.78, 1.0, 0.85) if current_phase == 1 else Color(0.95, 0.28, 0.62, 0.90)
		wave_root.add_child(crest)
		var tw = wave_root.create_tween().set_parallel(true)
		tw.tween_property(crest, "position:x", dir_sign * 260.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(crest, "scale", Vector2(1.8, 0.35), 0.55)
		tw.tween_property(crest, "modulate:a", 0.0, 0.55)

	var timer = get_tree().create_timer(0.6)
	timer.timeout.connect(func():
		if is_instance_valid(wave_root):
			wave_root.queue_free()
	)

func _spawn_abyssal_splash(splash_pos: Vector2, intensity: float = 1.0) -> void:
	if not is_inside_tree() or not get_parent():
		return
	var splash = CPUParticles2D.new()
	splash.global_position = splash_pos
	splash.emitting = true
	splash.one_shot = true
	splash.explosiveness = 0.92
	splash.amount = int(28 * intensity)
	splash.lifetime = 0.75
	splash.direction = Vector2(0, -1)
	splash.spread = 62.0
	splash.initial_velocity_min = 95.0 * intensity
	splash.initial_velocity_max = 210.0 * intensity
	splash.gravity = Vector2(0, 380.0)
	splash.scale_amount_min = 2.5
	splash.scale_amount_max = 5.5
	splash.color = Color(0.38, 0.82, 1.0, 0.85)
	get_parent().add_child(splash)
	get_tree().create_timer(0.85).timeout.connect(func():
		if is_instance_valid(splash):
			splash.queue_free()
	)

func spawn_stalactite(x_pos: float) -> void:
	if not is_inside_tree():
		return
	var stalactite = StalactiteScript.new()
	stalactite.global_position = Vector2(x_pos, 36.0)
	stalactite.ground_y = 280.0
	get_parent().add_child(stalactite)

func check_lunge_hit() -> void:
	if not is_instance_valid(target_player):
		return
	var dist = global_position.distance_to(target_player.global_position)
	if dist < 85.0:
		has_hit_player_this_lunge = true
		if target_player.has_method("take_damage_from_enemy"):
			target_player.take_damage_from_enemy(2, lunge_direction, self)

func deflect_by_parry(knock_dir: float) -> void:
	# Triggered by Player executing a Perfect Parry!
	is_stunned_vulnerable = true
	stun_timer = 1.45
	is_telegraphing = false
	_set_maw_vortex_active(false)
	if stun_stars:
		stun_stars.visible = true
	
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -90.0), "STAGGERED!", Color(1.0, 0.9, 0.2), 16, true)
	velocity.x = knock_dir * 180.0
	velocity.y = -60.0
	set_state(State.PARRIED_STAGGER)

func take_damage(amount: int, _knockback_dir: float = 0.0) -> void:
	if is_dead:
		return

	# Riposte bonus damage while stunned from parry
	var final_damage = amount
	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if stun_stars:
			stun_stars.visible = false
		final_damage = amount * 3
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -80.0), "CRIT %d!" % final_damage, Color(1.0, 0.95, 0.2), 18, true)

	health -= final_damage
	boss_hp_changed.emit(max(0, health), MAX_HEALTH)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -65.0), str(final_damage), Color(1.0, 0.3, 0.3), 15, false)

	hurt_flash_timer = 0.20
	if sprite:
		sprite.modulate = Color(2.4, 2.4, 2.6, 1.0)

	# Phase 2 Transition check at 50% health (<= 22 HP)
	if current_phase == 1 and health <= (MAX_HEALTH / 2):
		trigger_phase_2()

	if health <= 0:
		trigger_death()
	else:
		if current_state not in [State.PARRIED_STAGGER, State.COIL_LUNGE, State.TAIL_SLAM_QUAKE]:
			set_state(State.HURT)
			state_timer = 0.18

func trigger_phase_2() -> void:
	current_phase = 2
	boss_phase_changed.emit(2)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -110.0), "ECLIPSE OF THE SEVEN MOONS!", Color(1.0, 0.22, 0.48), 16, true)
	if aura_particles:
		aura_particles.amount = 48
		aura_particles.color = Color(0.92, 0.25, 0.58, 0.78)
	if boss_light:
		boss_light.color = Color(0.95, 0.28, 0.62, 1.0)
		boss_light.energy = 1.65
	for seg in serpent_segments:
		if is_instance_valid(seg):
			var ridge = seg.get_node_or_null("ScaleRidge") as Polygon2D
			if ridge:
				ridge.color = Color(0.98, 0.32, 0.68, 0.82)
	update_phase_modulate()
	_summon_eclipse_wisps(2)

func _summon_eclipse_wisps(count: int) -> void:
	for i in range(count):
		var offset_x = -190.0 if i % 2 == 0 else 190.0
		var wisp_pos = Vector2(clampf(global_position.x + offset_x, 3860.0, 4980.0), BASE_HOVER_Y - 35.0)
		wisp_summon_requested.emit(wisp_pos)

func update_phase_modulate() -> void:
	if not sprite:
		return
	if current_phase == 2:
		sprite.modulate = Color(1.18, 0.72, 0.92, 1.0)
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func set_state(new_state: State) -> void:
	current_state = new_state
	
	if sprite:
		if new_state in [State.TIDAL_BREATH, State.TAIL_SLAM_QUAKE]:
			sprite.texture = tex_roar
		else:
			sprite.texture = tex_idle

	match new_state:
		State.IDLE:
			_set_maw_vortex_active(false)
			state_timer = randf_range(0.95, 1.65) if current_phase == 1 else randf_range(0.55, 1.05)
		State.CHASE:
			_set_maw_vortex_active(false)
			state_timer = randf_range(1.4, 2.3)

func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	_set_maw_vortex_active(false)
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if stun_stars:
		stun_stars.visible = false
	
	boss_died.emit(self)
	_spawn_abyssal_splash(global_position, 1.5)
	
	# Death animation: Lunar starlight dissolution & sinking back into the abyss
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color(2.5, 2.8, 3.5, 1.0), 0.8)
	if serpent_root:
		tw.parallel().tween_property(serpent_root, "modulate:a", 0.0, 1.4)
	tw.parallel().tween_property(aura_particles, "modulate:a", 2.0, 0.8)
	tw.tween_property(sprite, "modulate:a", 0.0, 1.6)
	tw.parallel().tween_property(sprite, "position:y", sprite.position.y + 95.0, 1.6)
	if boss_light:
		tw.parallel().tween_property(boss_light, "energy", 0.0, 1.6)
	tw.tween_callback(func():
		queue_free()
	)

func handle_death_process(_delta: float) -> void:
	velocity = Vector2.ZERO

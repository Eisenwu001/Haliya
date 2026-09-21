class_name LightningHazard
extends Node2D

signal strike_occurred(position: Vector2, damage: int)

const TELEGRAPH_DURATION: float = 1.2
const STRIKE_DURATION: float = 0.26
const BLAST_RADIUS: float = 54.0
const DAMAGE: int = 25

const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")

var target_position: Vector2 = Vector2.ZERO
var telegraph_timer: float = 0.0
var strike_timer: float = 0.0
var cleanup_timer: float = 0.0
var is_striking: bool = false
var has_hit: bool = false

# Visual references: Telegraph
var telegraph_circle: Line2D
var telegraph_beam: Line2D
var telegraph_sparks: CPUParticles2D

# Strike visual references: Single sky bolt + BIG ground scatter of rays + impact debris & dust
var bolt_line: Line2D
var bolt_core: Line2D
var ground_scatter_lines: Array[Line2D] = []
var ground_scatter_cores: Array[Line2D] = []
var burst_ray_lines: Array[Line2D] = []
var shockwave_ring: Line2D
var impact_flash_sprite: Sprite2D
var debris_particles: CPUParticles2D
var dust_particles: CPUParticles2D
var strike_sparks: CPUParticles2D
var smoke_particles: CPUParticles2D
var crater_embers: CPUParticles2D
var canopy_leaves: CPUParticles2D
var scorch_line: Line2D
var strike_light: PointLight2D
var audio_player: AudioStreamPlayer2D

var unshaded_mat: CanvasItemMaterial
var additive_mat: CanvasItemMaterial

func _ready() -> void:
	global_position = target_position
	setup_telegraph_visuals()
	setup_strike_visuals()
	setup_audio()
	telegraph_timer = TELEGRAPH_DURATION

func setup_telegraph_visuals() -> void:
	# Ground pulsing warning ring
	telegraph_circle = Line2D.new()
	telegraph_circle.width = 2.5
	telegraph_circle.default_color = Color(0.4, 0.8, 1.0, 0.6)
	var pts: PackedVector2Array = []
	var segments: int = 28
	for i in range(segments + 1):
		var ang: float = float(i) / float(segments) * TAU
		pts.append(Vector2(cos(ang) * BLAST_RADIUS, sin(ang) * (BLAST_RADIUS * 0.35)))
	telegraph_circle.points = pts
	add_child(telegraph_circle)

	# Faint vertical guide beam from the sky
	telegraph_beam = Line2D.new()
	telegraph_beam.width = 1.5
	telegraph_beam.default_color = Color(0.5, 0.85, 1.0, 0.25)
	telegraph_beam.points = PackedVector2Array([Vector2(0, -480), Vector2(0, 0)])
	add_child(telegraph_beam)

	# Ground crackle sparks
	telegraph_sparks = CPUParticles2D.new()
	telegraph_sparks.amount = 18
	telegraph_sparks.lifetime = 0.4
	telegraph_sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	telegraph_sparks.emission_sphere_radius = 32.0
	telegraph_sparks.direction = Vector2(0, -1)
	telegraph_sparks.spread = 70.0
	telegraph_sparks.gravity = Vector2(0, -30)
	telegraph_sparks.initial_velocity_min = 25.0
	telegraph_sparks.initial_velocity_max = 55.0
	telegraph_sparks.scale_amount_min = 1.0
	telegraph_sparks.scale_amount_max = 2.8
	telegraph_sparks.color = Color(0.6, 0.9, 1.0, 0.8)
	add_child(telegraph_sparks)

func setup_strike_visuals() -> void:
	# Materials for brilliant luminescence against dark storm ambient lighting
	unshaded_mat = CanvasItemMaterial.new()
	unshaded_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

	additive_mat = CanvasItemMaterial.new()
	additive_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	additive_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	# Ground scorch ring
	scorch_line = Line2D.new()
	scorch_line.width = 3.2
	scorch_line.default_color = Color(0.12, 0.14, 0.20, 0.0)
	var scorch_pts: PackedVector2Array = []
	for i in range(21):
		var ang: float = float(i) / 20.0 * TAU
		scorch_pts.append(Vector2(cos(ang) * (BLAST_RADIUS * 0.65), sin(ang) * (BLAST_RADIUS * 0.26)))
	scorch_line.points = scorch_pts
	add_child(scorch_line)

	# Dynamic PointLight2D impact flash (broad, intense luminescence)
	strike_light = PointLight2D.new()
	strike_light.name = "StrikePointLight"
	strike_light.texture = LIGHT_TEX
	strike_light.texture_scale = 1.45
	strike_light.color = Color(0.72, 0.92, 1.0, 1.0)
	strike_light.energy = 0.0
	strike_light.position = Vector2(0, -14)
	add_child(strike_light)

	# Incandescent ground core flash (blazing white-hot point of contact)
	impact_flash_sprite = Sprite2D.new()
	impact_flash_sprite.name = "ImpactFlashSprite"
	impact_flash_sprite.texture = LIGHT_TEX
	impact_flash_sprite.material = additive_mat
	impact_flash_sprite.modulate = Color(0.9, 0.96, 1.0, 1.0)
	impact_flash_sprite.scale = Vector2(0.85, 0.45)
	impact_flash_sprite.position = Vector2(0, -6)
	impact_flash_sprite.visible = false
	add_child(impact_flash_sprite)

	# Single-strand main bolt (Sky to ground): Electric cyan outer glow
	bolt_line = Line2D.new()
	bolt_line.width = 8.0
	bolt_line.default_color = Color(0.25, 0.82, 1.0, 0.95)
	bolt_line.material = additive_mat
	bolt_line.visible = false
	add_child(bolt_line)

	# Single-strand main bolt: Pure white inner core
	bolt_core = Line2D.new()
	bolt_core.width = 3.4
	bolt_core.default_color = Color(1.0, 1.0, 1.0, 1.0)
	bolt_core.material = unshaded_mat
	bolt_core.visible = false
	add_child(bolt_core)

	# 1. Big Scatter of 16 Jagged Electrical Discharge Rays
	ground_scatter_lines.clear()
	ground_scatter_cores.clear()
	for i in range(16):
		var s_line := Line2D.new()
		s_line.width = 4.2
		s_line.default_color = Color(0.28, 0.82, 1.0, 0.95)
		s_line.material = additive_mat
		s_line.visible = false
		add_child(s_line)
		ground_scatter_lines.append(s_line)

		var s_core := Line2D.new()
		s_core.width = 1.8
		s_core.default_color = Color(1.0, 1.0, 1.0, 1.0)
		s_core.material = unshaded_mat
		s_core.visible = false
		add_child(s_core)
		ground_scatter_cores.append(s_core)

	# 2. Big Scatter of 14 Radiant Needle Burst Rays (Star-burst energy spikes)
	burst_ray_lines.clear()
	var ray_grad := Gradient.new()
	ray_grad.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	ray_grad.set_color(1, Color(0.22, 0.80, 1.0, 0.0))

	for i in range(14):
		var b_ray := Line2D.new()
		b_ray.width = 3.5
		b_ray.gradient = ray_grad
		b_ray.material = additive_mat
		b_ray.visible = false
		add_child(b_ray)
		burst_ray_lines.append(b_ray)

	# 3. Expanding Electrical Shockwave Ring
	shockwave_ring = Line2D.new()
	shockwave_ring.width = 3.0
	shockwave_ring.default_color = Color(0.40, 0.88, 1.0, 0.0)
	shockwave_ring.material = additive_mat
	shockwave_ring.visible = false
	add_child(shockwave_ring)

	# 4. Ground Debris: Earthen dirt & rock chunks blasting upward with heavy gravity
	debris_particles = CPUParticles2D.new()
	debris_particles.name = "DebrisParticles"
	debris_particles.emitting = false
	debris_particles.one_shot = true
	debris_particles.amount = 32
	debris_particles.lifetime = 0.88
	debris_particles.explosiveness = 0.96
	debris_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	debris_particles.emission_rect_extents = Vector2(18, 4)
	debris_particles.direction = Vector2(0, -1)
	debris_particles.spread = 70.0
	debris_particles.gravity = Vector2(0, 520.0)
	debris_particles.initial_velocity_min = 140.0
	debris_particles.initial_velocity_max = 270.0
	debris_particles.scale_amount_min = 2.5
	debris_particles.scale_amount_max = 5.2
	debris_particles.color = Color(0.32, 0.24, 0.18, 1.0)
	add_child(debris_particles)

	# 5. Ground Dust: Soft billowing earthen dust puff at surface impact
	dust_particles = CPUParticles2D.new()
	dust_particles.name = "DustParticles"
	dust_particles.emitting = false
	dust_particles.one_shot = true
	dust_particles.amount = 20
	dust_particles.lifetime = 0.78
	dust_particles.explosiveness = 0.92
	dust_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust_particles.emission_rect_extents = Vector2(16, 4)
	dust_particles.direction = Vector2(0, -1)
	dust_particles.spread = 85.0
	dust_particles.gravity = Vector2(0, 50.0)
	dust_particles.initial_velocity_min = 35.0
	dust_particles.initial_velocity_max = 85.0
	dust_particles.scale_amount_min = 4.0
	dust_particles.scale_amount_max = 8.5
	dust_particles.color = Color(0.42, 0.36, 0.30, 0.40)
	add_child(dust_particles)

	# 6. Impact electrical explosion sparks (blasting out with the rays)
	strike_sparks = CPUParticles2D.new()
	strike_sparks.name = "StrikeSparks"
	strike_sparks.material = additive_mat
	strike_sparks.emitting = false
	strike_sparks.one_shot = true
	strike_sparks.amount = 55
	strike_sparks.lifetime = 0.58
	strike_sparks.explosiveness = 0.96
	strike_sparks.direction = Vector2(0, -1)
	strike_sparks.spread = 95.0
	strike_sparks.gravity = Vector2(0, 420.0)
	strike_sparks.initial_velocity_min = 120.0
	strike_sparks.initial_velocity_max = 290.0
	strike_sparks.scale_amount_min = 1.5
	strike_sparks.scale_amount_max = 4.0
	strike_sparks.color = Color(0.8, 0.95, 1.0, 1.0)
	add_child(strike_sparks)

	# 7. Residual electrical steam / smoke
	smoke_particles = CPUParticles2D.new()
	smoke_particles.name = "SmokeParticles"
	smoke_particles.emitting = false
	smoke_particles.one_shot = true
	smoke_particles.amount = 18
	smoke_particles.lifetime = 1.2
	smoke_particles.direction = Vector2(-0.3, -1.0)
	smoke_particles.spread = 45.0
	smoke_particles.gravity = Vector2(-20.0, -18.0)
	smoke_particles.initial_velocity_min = 20.0
	smoke_particles.initial_velocity_max = 55.0
	smoke_particles.scale_amount_min = 2.5
	smoke_particles.scale_amount_max = 5.5
	smoke_particles.color = Color(0.65, 0.75, 0.88, 0.45)
	add_child(smoke_particles)

	# 8. Searing Crater Embers: crackling incandescent sparks cooling over 1.35s
	crater_embers = CPUParticles2D.new()
	crater_embers.name = "CraterEmbers"
	crater_embers.texture = load("res://assets/vfx/crater_ember.png")
	crater_embers.material = additive_mat
	crater_embers.emitting = false
	crater_embers.one_shot = true
	crater_embers.amount = 14
	crater_embers.lifetime = 1.35
	crater_embers.explosiveness = 0.85
	crater_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	crater_embers.emission_rect_extents = Vector2(22, 5)
	crater_embers.direction = Vector2(0, -1)
	crater_embers.spread = 75.0
	crater_embers.gravity = Vector2(0, 160.0)
	crater_embers.initial_velocity_min = 20.0
	crater_embers.initial_velocity_max = 65.0
	crater_embers.scale_amount_min = 0.75
	crater_embers.scale_amount_max = 1.4
	add_child(crater_embers)

	# 9. Falling Singed Canopy Leaves: shook loose from tree branches by concussive shockwave
	canopy_leaves = CPUParticles2D.new()
	canopy_leaves.name = "CanopyLeaves"
	canopy_leaves.texture = load("res://assets/vfx/singed_leaf.png")
	canopy_leaves.emitting = false
	canopy_leaves.one_shot = true
	canopy_leaves.amount = 12
	canopy_leaves.lifetime = 2.4
	canopy_leaves.explosiveness = 0.65
	canopy_leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	canopy_leaves.emission_rect_extents = Vector2(40, 15)
	canopy_leaves.direction = Vector2(-0.85, 0.45)
	canopy_leaves.spread = 50.0
	canopy_leaves.gravity = Vector2(-35.0, 52.0)
	canopy_leaves.initial_velocity_min = 30.0
	canopy_leaves.initial_velocity_max = 75.0
	canopy_leaves.angular_velocity_min = -180.0
	canopy_leaves.angular_velocity_max = 180.0
	canopy_leaves.position = Vector2(0, -160)
	add_child(canopy_leaves)

func setup_audio() -> void:
	audio_player = AudioStreamPlayer2D.new()
	audio_player.max_distance = 1400.0
	audio_player.bus = "Master"
	var crit_sound = load("res://assets/audio/sfx/hit_critical.wav")
	if crit_sound:
		audio_player.stream = crit_sound
		audio_player.pitch_scale = randf_range(0.36, 0.44)
		audio_player.volume_db = 5.0
	add_child(audio_player)

func _process(delta: float) -> void:
	if not is_striking:
		telegraph_timer -= delta
		# Pulse telegraph circle and beam
		var pulse: float = 0.5 + 0.5 * sin((TELEGRAPH_DURATION - telegraph_timer) * 20.0)
		var t_ratio: float = 1.0 - clamp(telegraph_timer / TELEGRAPH_DURATION, 0.0, 1.0)
		if telegraph_circle:
			telegraph_circle.default_color.a = lerp(0.4, 1.0, t_ratio * pulse)
			telegraph_circle.width = lerp(2.0, 4.0, t_ratio)
		if telegraph_beam:
			telegraph_beam.default_color.a = lerp(0.15, 0.7, t_ratio * pulse)

		if telegraph_timer <= 0.0:
			trigger_strike()
	else:
		cleanup_timer -= delta
		if strike_timer > 0.0:
			strike_timer -= delta
			# High-voltage strobe flicker
			var t_prog: float = 1.0 - clamp(strike_timer / STRIKE_DURATION, 0.0, 1.0)
			var strobe: float = 1.0
			if t_prog < 0.28:
				strobe = randf_range(0.90, 1.0) # Initial blast
			elif t_prog < 0.50:
				strobe = randf_range(0.65, 0.85) # High-energy restrike
			elif t_prog < 0.78:
				strobe = randf_range(0.85, 1.0) # Peak discharge
			else:
				strobe = clamp((1.0 - t_prog) / 0.22, 0.0, 1.0) # Fast decay

			if bolt_line:
				bolt_line.default_color.a = strobe
			if bolt_core:
				bolt_core.default_color.a = strobe

			# Ground scatter rays fade during strike flash
			var scatter_alpha: float = clamp(strike_timer / 0.22, 0.0, 1.0) * strobe
			for g_line in ground_scatter_lines:
				if is_instance_valid(g_line):
					g_line.default_color.a = scatter_alpha * 0.95
			for g_core in ground_scatter_cores:
				if is_instance_valid(g_core):
					g_core.default_color.a = scatter_alpha

			# Radiant burst needle rays have a fast explosive pop
			var burst_alpha: float = clamp(strike_timer / 0.18, 0.0, 1.0) * strobe
			for b_ray in burst_ray_lines:
				if is_instance_valid(b_ray):
					b_ray.modulate.a = burst_alpha

			# Expanding electrical shockwave ring
			if shockwave_ring:
				var wave_radius: float = lerp(12.0, 85.0, t_prog)
				var wave_pts: PackedVector2Array = []
				for i in range(25):
					var a: float = float(i) / 24.0 * TAU
					wave_pts.append(Vector2(cos(a) * wave_radius, sin(a) * (wave_radius * 0.35)))
				shockwave_ring.points = wave_pts
				shockwave_ring.default_color.a = clamp((1.0 - t_prog) * 1.2, 0.0, 0.90)

			# Impact ground flash sprite
			if impact_flash_sprite:
				var flash_scale: float = lerp(0.95, 0.45, t_prog)
				impact_flash_sprite.scale = Vector2(flash_scale * 1.2, flash_scale * 0.6)
				impact_flash_sprite.modulate.a = scatter_alpha

			if strike_light:
				strike_light.energy = 6.0 * strobe
			if scorch_line:
				scorch_line.default_color.a = clamp(t_prog * 1.8, 0.0, 0.75)
		else:
			# Strike flash finished: hide lines and light, leave debris/dust particles to complete settle
			if bolt_line and bolt_line.visible:
				bolt_line.visible = false
			if bolt_core and bolt_core.visible:
				bolt_core.visible = false
			for g_line in ground_scatter_lines:
				if is_instance_valid(g_line):
					g_line.visible = false
			for g_core in ground_scatter_cores:
				if is_instance_valid(g_core):
					g_core.visible = false
			for b_ray in burst_ray_lines:
				if is_instance_valid(b_ray):
					b_ray.visible = false
			if shockwave_ring:
				shockwave_ring.visible = false
			if impact_flash_sprite:
				impact_flash_sprite.visible = false
			if strike_light:
				strike_light.energy = 0.0

			if cleanup_timer <= 0.0:
				queue_free()

func trigger_strike() -> void:
	is_striking = true
	strike_timer = STRIKE_DURATION
	cleanup_timer = 1.65

	# Hide telegraph visuals
	if telegraph_circle:
		telegraph_circle.visible = false
	if telegraph_beam:
		telegraph_beam.visible = false
	if telegraph_sparks:
		telegraph_sparks.emitting = false

	# 1. Generate 1 single jagged main trunk bolt from sky down to ground impact (NO sky branches)
	var start_y: float = -480.0
	var current_y: float = start_y
	var current_x: float = randf_range(-30.0, 30.0)
	var bolt_points: PackedVector2Array = [Vector2(current_x, current_y)]

	var segments: int = 15
	var step_y: float = (0.0 - start_y) / float(segments)

	for i in range(1, segments):
		current_y += step_y
		# Jitter towards 0 as it approaches ground impact
		var horizontal_jitter: float = lerp(22.0, 8.0, float(i) / float(segments))
		current_x += randf_range(-horizontal_jitter, horizontal_jitter)
		bolt_points.append(Vector2(current_x, current_y))

	bolt_points.append(Vector2(0, 0)) # Exact ground impact point

	bolt_line.points = bolt_points
	bolt_line.visible = true
	bolt_core.points = bolt_points
	bolt_core.visible = true

	# 2. Generate BIG Scatter of Rays upon hitting ground (0, 0)
	# 16 multi-segmented jagged electrical discharge rays:
	# - Rays 0, 1: horizontal left ground skimmers
	# - Rays 2, 3: horizontal right ground skimmers
	# - Rays 4 to 15: broad upward & diagonal starburst fan across upper hemisphere
	for s_idx in range(ground_scatter_lines.size()):
		var base_angle: float = 0.0
		var ray_reach: float = 0.0
		var num_segs: int = randi_range(4, 6)

		if s_idx < 2:
			# Skim along ground to the left
			base_angle = deg_to_rad(randf_range(-178.0, -165.0))
			ray_reach = randf_range(70.0, 110.0)
		elif s_idx < 4:
			# Skim along ground to the right
			base_angle = deg_to_rad(randf_range(-15.0, -2.0))
			ray_reach = randf_range(70.0, 110.0)
		else:
			# Upward & diagonal radial fan (-165° to -15°)
			var fan_t: float = float(s_idx - 4) / 11.0 # 0.0 to 1.0
			var deg: float = lerp(-165.0, -15.0, fan_t) + randf_range(-9.0, 9.0)
			base_angle = deg_to_rad(deg)
			ray_reach = randf_range(75.0, 135.0)

		var cur_pt := Vector2.ZERO
		var scatter_pts: PackedVector2Array = [cur_pt]
		var step_dist: float = ray_reach / float(num_segs)
		var ray_dir := Vector2(cos(base_angle), sin(base_angle))
		var perp_dir := Vector2(-ray_dir.y, ray_dir.x)

		for seg in range(1, num_segs + 1):
			var forward_pos: Vector2 = ray_dir * (float(seg) * step_dist)
			# Jagged perpendicular jitter
			var jitter_amount: float = randf_range(-8.5, 8.5) * (1.0 - float(seg) / float(num_segs) * 0.25)
			if s_idx < 4:
				jitter_amount = clamp(jitter_amount, -4.5, 4.5)
			var pt: Vector2 = forward_pos + perp_dir * jitter_amount
			scatter_pts.append(pt)

		ground_scatter_lines[s_idx].points = scatter_pts
		ground_scatter_lines[s_idx].visible = true
		ground_scatter_cores[s_idx].points = scatter_pts
		ground_scatter_cores[s_idx].visible = true

	# Generate 14 radiant straight needle burst rays (starburst spikes)
	for b_idx in range(burst_ray_lines.size()):
		var b_fan_t: float = float(b_idx) / float(burst_ray_lines.size() - 1)
		var b_deg: float = lerp(-175.0, -5.0, b_fan_t) + randf_range(-6.0, 6.0)
		var b_angle: float = deg_to_rad(b_deg)
		var b_length: float = randf_range(60.0, 130.0)
		var end_pt := Vector2(cos(b_angle), sin(b_angle)) * b_length

		burst_ray_lines[b_idx].points = PackedVector2Array([Vector2.ZERO, end_pt])
		burst_ray_lines[b_idx].visible = true

	# Activate expanding electrical shockwave ring & impact flash
	shockwave_ring.visible = true
	impact_flash_sprite.visible = true

	# 3. Fire impact debris, dust, sparks, residual smoke, searing embers & dynamic light
	debris_particles.emitting = true
	dust_particles.emitting = true
	strike_sparks.emitting = true
	smoke_particles.emitting = true
	if crater_embers:
		crater_embers.emitting = true

	# Check for nearby trees to trigger singed leaf flutter
	if is_inside_tree() and canopy_leaves:
		var foliage_hit: bool = false
		for n in get_tree().root.find_children("", "Sprite2D", true, false):
			if n.name.begins_with("Tree") or n.name.begins_with("Narra") or "narra" in n.name.to_lower():
				var dist: float = abs(n.global_position.x - global_position.x)
				if dist < 260.0:
					canopy_leaves.position.x = clamp(n.global_position.x - global_position.x, -90.0, 90.0)
					canopy_leaves.emitting = true
					foliage_hit = true
					break
		if not foliage_hit:
			# Fallback ambient leaf dislodge
			canopy_leaves.position.x = randf_range(-30.0, 30.0)
			canopy_leaves.emitting = true

	if strike_light:
		strike_light.energy = 6.0

	if is_inside_tree() and audio_player and audio_player.is_inside_tree() and audio_player.stream:
		audio_player.play()

	strike_occurred.emit(global_position, DAMAGE)
	apply_blast_damage()

func apply_blast_damage() -> void:
	if has_hit:
		return
	has_hit = true

	# Find targets within blast radius
	if not is_inside_tree():
		return
	var tree: SceneTree = get_tree()
	if not tree:
		return

	# Damage player if in radius
	var player: Node = tree.get_first_node_in_group("player")
	if not player:
		# Fallback search by type
		for n in get_tree().root.find_children("", "CharacterBody2D", true, false):
			if n.get_script() and "player.gd" in n.get_script().resource_path:
				player = n
				break

	if is_instance_valid(player) and player is Node2D:
		var p_node := player as Node2D
		var p_dist: float = global_position.distance_to(p_node.global_position)
		if p_dist <= BLAST_RADIUS:
			var kdir: float = 1.0 if p_node.global_position.x >= global_position.x else -1.0
			if player.has_method("take_damage"):
				player.take_damage(DAMAGE, kdir)
			elif player.has_method("take_damage_from_enemy"):
				player.take_damage_from_enemy(DAMAGE, kdir, null)

	# Damage any enemies in radius
	for enemy in tree.get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.is_inside_tree() and enemy is Node2D:
			var e_node := enemy as Node2D
			var e_dist: float = global_position.distance_to(e_node.global_position)
			if e_dist <= BLAST_RADIUS:
				var kdir: float = 1.0 if e_node.global_position.x >= global_position.x else -1.0
				if enemy.has_method("take_damage"):
					enemy.take_damage(DAMAGE, kdir)

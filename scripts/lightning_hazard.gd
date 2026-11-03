class_name LightningHazard
extends Node2D

signal strike_occurred(position: Vector2, damage: int)

const TELEGRAPH_DURATION: float = 1.2
const STRIKE_DURATION: float = 0.28
const BLAST_RADIUS: float = 54.0
const DIRECT_HIT_RADIUS: float = 18.0
const DAMAGE: int = 25

const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")
const STRIKE_ANIM_TEX = preload("res://assets/vfx/vfx_lightning_strike.png")
const SCORCH_TEX = preload("res://assets/vfx/vfx_lightning_scorch.png")
const WARNING_TEX = preload("res://assets/vfx/vfx_lightning_warning.png")

var target_position: Vector2 = Vector2.ZERO
var telegraph_timer: float = 0.0
var strike_timer: float = 0.0
var cleanup_timer: float = 0.0
var is_striking: bool = false
var has_hit: bool = false

# Visual references: Telegraph
var telegraph_warning_sprite: Sprite2D
var telegraph_circle: Line2D
var telegraph_beam: Line2D
var telegraph_sparks: CPUParticles2D
var telegraph_arcs: Array[Line2D] = []
var telegraph_light: PointLight2D = null
var arc_jitter_timer: float = 0.0

# Strike visual references: Impactful lightning sprite + Ground crater decal & lingering crackle
var strike_sprite: Sprite2D
var ground_scorch_sprite: Sprite2D
var ground_crackle_sprite: Sprite2D

# Compatibility Line2Ds (kept so existing property references and tests never break)
var bolt_line: Line2D
var bolt_core: Line2D
var ground_scatter_lines: Array[Line2D] = []
var ground_scatter_cores: Array[Line2D] = []
var burst_ray_lines: Array[Line2D] = []
var scorch_line: Line2D

# Particles and lighting
var impact_flash_sprite: Sprite2D
var debris_particles: CPUParticles2D
var dust_particles: CPUParticles2D
var strike_sparks: CPUParticles2D
var smoke_particles: CPUParticles2D
var crater_embers: CPUParticles2D
var canopy_leaves: CPUParticles2D
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
	var add_mat := CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	add_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

	# 2D Side-Scroller Platform Ledge Electric Hazard Telegraph
	telegraph_warning_sprite = Sprite2D.new()
	telegraph_warning_sprite.name = "TelegraphWarningSprite"
	telegraph_warning_sprite.texture = WARNING_TEX
	telegraph_warning_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	telegraph_warning_sprite.material = add_mat
	telegraph_warning_sprite.centered = false
	telegraph_warning_sprite.offset = Vector2(-256, -380) # Floor baseline at (0, 0), vertical column reaches sky
	telegraph_warning_sprite.scale = Vector2(0.28, 0.40)
	telegraph_warning_sprite.position = Vector2(0, 0)
	telegraph_warning_sprite.z_index = 2
	add_child(telegraph_warning_sprite)

	# Subtle ground boundary guide ring (Hidden for seamless natural visuals)
	telegraph_circle = Line2D.new()
	telegraph_circle.width = 1.5
	telegraph_circle.default_color = Color(0.3, 0.75, 1.0, 0.0)
	telegraph_circle.material = add_mat
	telegraph_circle.visible = false
	var pts: PackedVector2Array = []
	var segments: int = 28
	for i in range(segments + 1):
		var ang: float = float(i) / float(segments) * TAU
		pts.append(Vector2(cos(ang) * BLAST_RADIUS, sin(ang) * (BLAST_RADIUS * 0.30)))
	telegraph_circle.points = pts
	add_child(telegraph_circle)

	# Atmospheric vertical beacon column & ground danger illumination (Pure warning, NO lightning)
	telegraph_beam = Line2D.new()
	telegraph_beam.visible = false
	add_child(telegraph_beam)

	# Disabled electric arcs and static sparks during telegraph
	telegraph_sparks = CPUParticles2D.new()
	telegraph_sparks.emitting = false
	telegraph_sparks.visible = false
	add_child(telegraph_sparks)

	# Ambient warning glow PointLight2D (Ionized azure to electric cyan)
	telegraph_light = PointLight2D.new()
	telegraph_light.texture = LIGHT_TEX
	telegraph_light.texture_scale = 1.1
	telegraph_light.color = Color(0.35, 0.85, 1.0, 0.95)
	telegraph_light.energy = 0.8
	telegraph_light.position = Vector2(0, -8)
	add_child(telegraph_light)

func _generate_telegraph_arcs(intensity: float) -> void:
	for i in range(telegraph_arcs.size()):
		var arc: Line2D = telegraph_arcs[i]
		var pts: PackedVector2Array = []
		var count: int = 7
		var start_x = -BLAST_RADIUS * 0.85 if (i % 2 == 0) else BLAST_RADIUS * 0.85
		var end_x = BLAST_RADIUS * 0.85 if (i % 2 == 0) else -BLAST_RADIUS * 0.85
		for p in range(count):
			var frac: float = float(p) / float(count - 1)
			var px = lerp(start_x, end_x, frac)
			var jitter_y = randf_range(-3.5, 1.5) * (1.0 + intensity * 1.5)
			pts.append(Vector2(px, jitter_y))
		arc.points = pts

func setup_strike_visuals() -> void:
	unshaded_mat = CanvasItemMaterial.new()
	unshaded_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

	additive_mat = CanvasItemMaterial.new()
	additive_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	additive_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	# 1. Main High-Impact Lightning Strike Animated Sprite
	strike_sprite = Sprite2D.new()
	strike_sprite.name = "StrikeSprite"
	strike_sprite.texture = STRIKE_ANIM_TEX
	strike_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	strike_sprite.hframes = 6
	strike_sprite.vframes = 1
	strike_sprite.frame = 1
	strike_sprite.centered = false
	strike_sprite.offset = Vector2(-128, -536) # Places the ground impact contact point exactly at (0, 0)
	strike_sprite.material = additive_mat
	strike_sprite.z_index = 28
	strike_sprite.visible = false
	add_child(strike_sprite)

	# 2. 2D Platformer Flat Ground Scorch Decal (Recessed crater embedded along floor tile surface)
	ground_scorch_sprite = Sprite2D.new()
	ground_scorch_sprite.name = "GroundScorchDecal"
	ground_scorch_sprite.texture = SCORCH_TEX
	ground_scorch_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_scorch_sprite.hframes = 5
	ground_scorch_sprite.vframes = 1
	ground_scorch_sprite.frame = 3 # Flat surface scorch with cyan fissures
	ground_scorch_sprite.centered = false
	ground_scorch_sprite.offset = Vector2(-128, -20) # Ground baseline flush at rim (0, 0), cracks bleed down into tile face
	ground_scorch_sprite.scale = Vector2(0.50, 0.50)
	ground_scorch_sprite.z_index = 1 # Embedded directly onto ground tile surface behind characters
	ground_scorch_sprite.visible = false
	add_child(ground_scorch_sprite)

	# 3. Additive Residual Ground Crackle Arcs (Horizontal surface skimmers & impact burst)
	ground_crackle_sprite = Sprite2D.new()
	ground_crackle_sprite.name = "GroundCrackleArcs"
	ground_crackle_sprite.texture = SCORCH_TEX
	ground_crackle_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_crackle_sprite.hframes = 5
	ground_crackle_sprite.vframes = 1
	ground_crackle_sprite.frame = 0 # Frame 0: High-energy Ground Impact Burst
	ground_crackle_sprite.centered = false
	ground_crackle_sprite.offset = Vector2(-128, -20)
	ground_crackle_sprite.scale = Vector2(0.50, 0.50)
	ground_crackle_sprite.material = additive_mat
	ground_crackle_sprite.z_index = 29 # Aligned with strike lightning layer
	ground_crackle_sprite.visible = false
	add_child(ground_crackle_sprite)

	# Compatibility Scorch Line (Kept for unit tests and fallback)
	scorch_line = Line2D.new()
	scorch_line.width = 3.2
	scorch_line.default_color = Color(0.12, 0.14, 0.20, 0.0)
	var scorch_pts: PackedVector2Array = []
	for i in range(21):
		var ang: float = float(i) / 20.0 * TAU
		scorch_pts.append(Vector2(cos(ang) * (BLAST_RADIUS * 0.65), sin(ang) * (BLAST_RADIUS * 0.26)))
	scorch_line.points = scorch_pts
	add_child(scorch_line)

	# Compatibility dummy lines
	bolt_line = Line2D.new()
	bolt_line.visible = false
	add_child(bolt_line)

	bolt_core = Line2D.new()
	bolt_core.visible = false
	add_child(bolt_core)

	# Dynamic PointLight2D impact flash
	strike_light = PointLight2D.new()
	strike_light.name = "StrikePointLight"
	strike_light.texture = LIGHT_TEX
	strike_light.texture_scale = 1.85
	strike_light.color = Color(0.72, 0.92, 1.0, 1.0)
	strike_light.energy = 0.0
	strike_light.position = Vector2(0, -14)
	add_child(strike_light)

	# Incandescent ground core flash sprite
	impact_flash_sprite = Sprite2D.new()
	impact_flash_sprite.name = "ImpactFlashSprite"
	impact_flash_sprite.texture = LIGHT_TEX
	impact_flash_sprite.material = additive_mat
	impact_flash_sprite.modulate = Color(0.9, 0.96, 1.0, 1.0)
	impact_flash_sprite.scale = Vector2(1.1, 0.55)
	impact_flash_sprite.position = Vector2(0, -6)
	impact_flash_sprite.visible = false
	add_child(impact_flash_sprite)

	# Ground Debris: Earthen dirt & rock chunks blasting upward
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

	# Ground Dust: Soft billowing earthen dust puff at surface impact
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

	# Impact electrical explosion sparks
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

	# Residual electrical steam / smoldering smoke rising from crater
	smoke_particles = CPUParticles2D.new()
	smoke_particles.name = "SmokeParticles"
	smoke_particles.emitting = false
	smoke_particles.one_shot = false # Continuous gentle wisps while crater cools
	smoke_particles.amount = 16
	smoke_particles.lifetime = 1.4
	smoke_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	smoke_particles.emission_rect_extents = Vector2(24, 4)
	smoke_particles.direction = Vector2(-0.25, -1.0)
	smoke_particles.spread = 40.0
	smoke_particles.gravity = Vector2(-15.0, -22.0)
	smoke_particles.initial_velocity_min = 15.0
	smoke_particles.initial_velocity_max = 35.0
	smoke_particles.scale_amount_min = 3.0
	smoke_particles.scale_amount_max = 6.0
	smoke_particles.color = Color(0.65, 0.75, 0.88, 0.35)
	add_child(smoke_particles)

	# Searing Crater Embers: crackling incandescent sparks cooling on the ground
	crater_embers = CPUParticles2D.new()
	crater_embers.name = "CraterEmbers"
	crater_embers.texture = load("res://assets/vfx/crater_ember.png")
	crater_embers.material = additive_mat
	crater_embers.emitting = false
	crater_embers.one_shot = true
	crater_embers.amount = 14
	crater_embers.lifetime = 1.6
	crater_embers.explosiveness = 0.80
	crater_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	crater_embers.emission_rect_extents = Vector2(22, 5)
	crater_embers.direction = Vector2(0, -1)
	crater_embers.spread = 75.0
	crater_embers.gravity = Vector2(0, 140.0)
	crater_embers.initial_velocity_min = 20.0
	crater_embers.initial_velocity_max = 65.0
	crater_embers.scale_amount_min = 0.75
	crater_embers.scale_amount_max = 1.4
	add_child(crater_embers)

	# Singed Canopy Leaves
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
	audio_player.name = "StrikeAudioPlayer2D"
	audio_player.max_distance = 1400.0
	audio_player.bus = "Master"
	var strike_sound = load("res://assets/audio/sfx/lightning_strike.mp3")
	if strike_sound:
		audio_player.stream = strike_sound
		audio_player.pitch_scale = randf_range(0.96, 1.04)
		audio_player.volume_db = 3.5
	else:
		var crit_sound = load("res://assets/audio/sfx/hit_critical.wav")
		if crit_sound:
			audio_player.stream = crit_sound
			audio_player.pitch_scale = randf_range(0.36, 0.44)
			audio_player.volume_db = 5.0
	add_child(audio_player)

func _process(delta: float) -> void:
	if not is_striking:
		telegraph_timer -= delta
		var t_ratio: float = 1.0 - clamp(telegraph_timer / TELEGRAPH_DURATION, 0.0, 1.0)
		var pulse: float = 0.5 + 0.5 * sin((TELEGRAPH_DURATION - telegraph_timer) * (15.0 + t_ratio * 25.0))
		
		if telegraph_light:
			# Shift from ethereal azure to intense electric cyan
			var light_col = Color(lerp(0.20, 0.65, t_ratio), lerp(0.65, 0.95, t_ratio), 1.0, 1.0)
			telegraph_light.color = light_col
			telegraph_light.energy = lerp(0.6, 2.5, t_ratio * pulse)
			telegraph_light.texture_scale = lerp(0.9, 1.4, t_ratio)

		if telegraph_warning_sprite:
			var base_s = Vector2(0.28, 0.40)
			telegraph_warning_sprite.scale = base_s * (1.0 + 0.06 * pulse)
			var w_alpha = lerp(0.40, 1.0, t_ratio * pulse)
			var warn_col = Color(lerp(0.45, 0.85, t_ratio), lerp(0.80, 1.0, t_ratio), 1.0, w_alpha)
			telegraph_warning_sprite.modulate = warn_col

		if telegraph_timer <= 0.0:
			trigger_strike()
	else:
		cleanup_timer -= delta
		if strike_timer > 0.0:
			strike_timer -= delta
			var t_prog: float = 1.0 - clamp(strike_timer / STRIKE_DURATION, 0.0, 1.0)

			var anim_frame: int = 1
			if t_prog < 0.20:
				anim_frame = 1
			elif t_prog < 0.45:
				anim_frame = 2
			elif t_prog < 0.70:
				anim_frame = 3
			elif t_prog < 0.88:
				anim_frame = 4
			else:
				anim_frame = 5

			if strike_sprite:
				strike_sprite.frame = anim_frame
				var strobe: float = 1.0
				if t_prog < 0.28:
					strobe = randf_range(0.92, 1.0)
				elif t_prog < 0.50:
					strobe = randf_range(0.70, 0.90)
				elif t_prog < 0.78:
					strobe = randf_range(0.85, 1.0)
				else:
					strobe = clamp((1.0 - t_prog) / 0.22, 0.0, 1.0)
				strike_sprite.modulate.a = strobe

			if ground_crackle_sprite:
				ground_crackle_sprite.frame = 0 if t_prog < 0.35 else 1
				ground_crackle_sprite.position = Vector2(randf_range(-1.0, 1.0), 0.0)
				ground_crackle_sprite.modulate.a = randf_range(0.85, 1.0)

			if strike_light:
				strike_light.energy = 6.5 * (1.0 - t_prog * 0.5)

			if impact_flash_sprite:
				var flash_scale: float = lerp(1.2, 0.5, t_prog)
				impact_flash_sprite.scale = Vector2(flash_scale * 1.2, flash_scale * 0.6)
				impact_flash_sprite.modulate.a = clamp((1.0 - t_prog) * 1.5, 0.0, 1.0)
		else:
			# Strike flash finished: Hide main sky bolt and flash light
			if strike_sprite and strike_sprite.visible:
				strike_sprite.visible = false
			if impact_flash_sprite and impact_flash_sprite.visible:
				impact_flash_sprite.visible = false
			if strike_light:
				strike_light.energy = 0.0

			var time_since_strike_end: float = (3.2 - STRIKE_DURATION) - cleanup_timer
			
			if time_since_strike_end < 0.40:
				if ground_crackle_sprite:
					ground_crackle_sprite.visible = true
					ground_crackle_sprite.frame = 1
					ground_crackle_sprite.position = Vector2(randf_range(-0.8, 0.8), 0.0)
					ground_crackle_sprite.modulate.a = randf_range(0.65, 0.95)
			elif time_since_strike_end < 0.85:
				if ground_crackle_sprite:
					ground_crackle_sprite.visible = true
					ground_crackle_sprite.frame = 2
					ground_crackle_sprite.position = Vector2(randf_range(-0.4, 0.4), 0.0)
					ground_crackle_sprite.modulate.a = randf_range(0.35, 0.65)
			else:
				if ground_crackle_sprite and ground_crackle_sprite.visible:
					ground_crackle_sprite.visible = false

			if ground_scorch_sprite:
				if time_since_strike_end < 0.45:
					ground_scorch_sprite.frame = 2 # Cooling magma fissures & embers (Stage 1)
				elif time_since_strike_end < 1.10:
					ground_scorch_sprite.frame = 3 # Warm scorched charcoal crater (Stage 2)
				else:
					ground_scorch_sprite.frame = 4 # Permanent cooled carbon crater (Stage 3, zero air pixels)
					ground_scorch_sprite.modulate = Color(1.0, 1.0, 1.0, 0.95)

				if smoke_particles and cleanup_timer < 1.0:
					smoke_particles.emitting = false

			if cleanup_timer <= 0.0:
				# ── PERMANENT GROUND STAIN PRESERVATION ──
				# Detach the scorch decal and embed permanently into the parent level node
				if is_instance_valid(ground_scorch_sprite):
					var parent_node := get_parent()
					if is_instance_valid(parent_node):
						ground_scorch_sprite.frame = 4
						ground_scorch_sprite.modulate = Color(0.85, 0.88, 0.92, 0.95)
						ground_scorch_sprite.z_index = 1
						var g_pos = ground_scorch_sprite.global_position
						remove_child(ground_scorch_sprite)
						ground_scorch_sprite.global_position = g_pos
						parent_node.add_child(ground_scorch_sprite)
				queue_free()

func trigger_strike() -> void:
	is_striking = true
	strike_timer = STRIKE_DURATION
	cleanup_timer = 3.2

	# Hide telegraph visuals
	if telegraph_warning_sprite:
		telegraph_warning_sprite.visible = false
	if telegraph_circle:
		telegraph_circle.visible = false
	if telegraph_beam:
		telegraph_beam.visible = false
	if telegraph_sparks:
		telegraph_sparks.emitting = false
	if telegraph_light:
		telegraph_light.enabled = false
	for arc in telegraph_arcs:
		arc.visible = false

	# Show Strike Sprite & Ground Scorch Decal
	if strike_sprite:
		strike_sprite.frame = 1
		strike_sprite.modulate.a = 1.0
		strike_sprite.visible = true

	if ground_scorch_sprite:
		ground_scorch_sprite.frame = 2 # Molten magma fissures & searing embers embedded in floor
		ground_scorch_sprite.modulate.a = 1.0
		ground_scorch_sprite.visible = true

	if ground_crackle_sprite:
		ground_crackle_sprite.frame = 0
		ground_crackle_sprite.modulate.a = 1.0
		ground_crackle_sprite.visible = true

	# Impact flash & dynamic light
	if impact_flash_sprite:
		impact_flash_sprite.visible = true
	if strike_light:
		strike_light.energy = 6.5

	# Fire impact debris, dust, sparks, lingering smoke & embers
	debris_particles.emitting = true
	dust_particles.emitting = true
	strike_sparks.emitting = true
	smoke_particles.emitting = true
	if crater_embers:
		crater_embers.emitting = true

	# Canopy leaf flutter
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
			canopy_leaves.position.x = randf_range(-30.0, 30.0)
			canopy_leaves.emitting = true

	if is_inside_tree() and audio_player and audio_player.is_inside_tree() and audio_player.stream:
		if audio_player.stream.resource_path.ends_with("lightning_strike.mp3"):
			audio_player.pitch_scale = randf_range(0.95, 1.05)
		else:
			audio_player.pitch_scale = randf_range(0.36, 0.44)
		audio_player.play()

	strike_occurred.emit(global_position, DAMAGE)
	apply_blast_damage()

func apply_blast_damage() -> void:
	if has_hit:
		return
	has_hit = true

	if not is_inside_tree():
		return
	var tree: SceneTree = get_tree()
	if not tree:
		return

	# Damage player based on proximity to center
	var player: Node = tree.get_first_node_in_group("player")
	if not player:
		for n in get_tree().root.find_children("", "CharacterBody2D", true, false):
			if n.get_script() and "player.gd" in n.get_script().resource_path:
				player = n
				break

	if is_instance_valid(player) and player is Node2D:
		var p_node := player as Node2D
		var p_dx: float = abs(p_node.global_position.x - global_position.x)
		var p_dy: float = abs(p_node.global_position.y - global_position.y)
		if p_dx <= BLAST_RADIUS and p_dy <= 55.0:
			var kdir: float = 1.0 if p_node.global_position.x >= global_position.x else -1.0
			if p_dx <= DIRECT_HIT_RADIUS:
				# ── CENTER DIRECT HIT: Instant 1-hit lethal obliteration! ──
				VFX.spawn_floating_text(get_parent(), p_node.global_position + Vector2(0, -52), "DIRECT HIT!", Color(1.0, 0.2, 0.2), 16, true)
				var max_hp = player.get("MAX_HEALTH")
				var lethal_amount = max_hp if max_hp != null else 5
				if player.has_method("take_damage"):
					player.take_damage(lethal_amount, kdir)
				elif player.has_method("take_damage_from_enemy"):
					player.take_damage_from_enemy(lethal_amount, kdir, null)
			else:
				# ── GLANCING SHOCKWAVE: 1 Damage + Stun / Guard Break! ──
				VFX.spawn_floating_text(get_parent(), p_node.global_position + Vector2(0, -42), "SHOCKED!", Color(0.4, 0.85, 1.0), 14, true)
				if player.has_method("take_damage"):
					player.take_damage(1, kdir)
				elif player.has_method("take_damage_from_enemy"):
					player.take_damage_from_enemy(1, kdir, null)
				if player.has_method("trigger_guard_break"):
					player.trigger_guard_break(kdir)

	# Damage any enemies in radius
	for enemy in tree.get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.is_inside_tree() and enemy is Node2D:
			var e_node := enemy as Node2D
			var e_dx: float = abs(e_node.global_position.x - global_position.x)
			var e_dy: float = abs(e_node.global_position.y - global_position.y)
			if e_dx <= BLAST_RADIUS and e_dy <= 55.0:
				var kdir: float = 1.0 if e_node.global_position.x >= global_position.x else -1.0
				if e_dx <= DIRECT_HIT_RADIUS:
					# Direct hit on enemy: instant lethal kill (999 dmg)
					VFX.spawn_floating_text(get_parent(), e_node.global_position + Vector2(0, -50), "OBLITERATED!", Color(1.0, 0.2, 0.2), 16, true)
					if enemy.has_method("take_damage"):
						enemy.take_damage(999, kdir)
				else:
					# Glancing hit: 1 damage + stun / stagger
					VFX.spawn_floating_text(get_parent(), e_node.global_position + Vector2(0, -44), "STUNNED!", Color(0.4, 0.85, 1.0), 13, false)
					if enemy.has_method("take_damage"):
						enemy.take_damage(1, kdir)
					if enemy.has_method("trigger_parried_stagger"):
						enemy.trigger_parried_stagger(kdir)

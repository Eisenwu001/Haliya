class_name CavePogoCrystal
extends Node2D

const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

@export var bounce_velocity: float = -465.0
@export var stamina_restore: float = 24.0

var sprite: Sprite2D
var crystal_light: PointLight2D
var burst_particles: CPUParticles2D
var ambient_motes: CPUParticles2D
var sfx_player: AudioStreamPlayer2D

var bob_time: float = 0.0
var cooldown_timer: float = 0.0
var base_sprite_pos: Vector2 = Vector2(0.0, 0.0)
var sway_amplitude: float = 0.0
var sway_timer: float = 0.0


func _ready() -> void:
	add_to_group("pogo_crystals")
	bob_time = randf() * TAU
	z_index = 1

	sprite = get_node_or_null("CrystalSprite") as Sprite2D
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "CrystalSprite"
		add_child(sprite)

	var props_tex = CaveAssetsScript.get_props_tex()
	sprite.texture = props_tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_rect = Rect2(160, 64, 64, 64)
	sprite.position = base_sprite_pos

	var light_tex = load("res://assets/vfx/radial_light_falloff.png")
	if light_tex and not get_node_or_null("CrystalLight"):
		crystal_light = PointLight2D.new()
		crystal_light.name = "CrystalLight"
		crystal_light.texture = light_tex
		crystal_light.position = Vector2(0.0, 0.0)
		crystal_light.color = Color(0.65, 0.90, 1.0, 0.95)
		crystal_light.energy = 0.95
		crystal_light.texture_scale = 0.55
		add_child(crystal_light)
	else:
		crystal_light = get_node_or_null("CrystalLight") as PointLight2D

	if not get_node_or_null("AmbientMotes"):
		ambient_motes = CPUParticles2D.new()
		ambient_motes.name = "AmbientMotes"
		ambient_motes.position = Vector2(0.0, 4.0)
		ambient_motes.amount = 6
		ambient_motes.lifetime = 1.4
		ambient_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		ambient_motes.emission_rect_extents = Vector2(12.0, 12.0)
		ambient_motes.direction = Vector2(0.0, 1.0)
		ambient_motes.spread = 35.0
		ambient_motes.gravity = Vector2(0.0, 12.0)
		ambient_motes.initial_velocity_min = 4.0
		ambient_motes.initial_velocity_max = 12.0
		ambient_motes.scale_amount_min = 1.2
		ambient_motes.scale_amount_max = 2.2
		ambient_motes.color = Color(0.45, 0.88, 1.0, 0.75)
		add_child(ambient_motes)

	if not get_node_or_null("BurstParticles"):
		burst_particles = CPUParticles2D.new()
		burst_particles.name = "BurstParticles"
		burst_particles.position = Vector2(0.0, 0.0)
		burst_particles.emitting = false
		burst_particles.one_shot = true
		burst_particles.explosiveness = 0.95
		burst_particles.amount = 14
		burst_particles.lifetime = 0.38
		burst_particles.direction = Vector2(0.0, -1.0)
		burst_particles.spread = 180.0
		burst_particles.gravity = Vector2(0.0, 220.0)
		burst_particles.initial_velocity_min = 60.0
		burst_particles.initial_velocity_max = 140.0
		burst_particles.scale_amount_min = 1.8
		burst_particles.scale_amount_max = 3.2
		burst_particles.color = Color(0.55, 0.98, 1.0, 0.95)
		add_child(burst_particles)
	else:
		burst_particles = get_node_or_null("BurstParticles") as CPUParticles2D

	if not get_node_or_null("SfxPlayer"):
		sfx_player = AudioStreamPlayer2D.new()
		sfx_player.name = "SfxPlayer"
		sfx_player.volume_db = -3.0
		add_child(sfx_player)
	else:
		sfx_player = get_node_or_null("SfxPlayer") as AudioStreamPlayer2D

	queue_redraw()


func _draw() -> void:
	# Draw fibrous Balete aerial roots suspending the pogo bell from the cavern ceiling (y = 0)
	var ceiling_local_y: float = -global_position.y
	if ceiling_local_y >= -12.0:
		return

	var root_base_col := Color(0.12, 0.10, 0.16, 0.96)
	var root_bark_col := Color(0.22, 0.19, 0.26, 0.92)
	var root_moss_col := Color(0.28, 0.36, 0.34, 0.85)

	# Ceiling root spread / canopy anchor
	draw_circle(Vector2(0, ceiling_local_y), 7.0, root_base_col)
	draw_line(Vector2(-8, ceiling_local_y), Vector2(8, ceiling_local_y), root_bark_col, 3.0)

	var steps: int = int(clamp(abs(ceiling_local_y) / 14.0, 6.0, 36.0))
	var prev_1 := Vector2(-2.5, -28.0)
	var prev_2 := Vector2(2.5, -28.0)

	var sway_offset: float = sin(sway_timer * 3.5) * (sway_amplitude * 0.15)

	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		var curr_y: float = lerpf(-28.0, ceiling_local_y, t)
		var organic_wave: float = sin(t * 9.0 + float(get_instance_id() % 7)) * 2.8 * (1.0 - t * 0.5)
		var curr_sway: float = sway_offset * (1.0 - t)
		var curr_1 := Vector2(-2.2 + organic_wave + curr_sway, curr_y)
		var curr_2 := Vector2(2.2 + organic_wave * 0.8 + curr_sway, curr_y)

		draw_line(prev_1, curr_1, root_base_col, 4.0)
		draw_line(prev_2, curr_2, root_bark_col, 2.4)
		if i % 3 == 0:
			draw_line(curr_1, curr_1 + Vector2(-3.0, -4.0), root_moss_col, 1.4)
		prev_1 = curr_1
		prev_2 = curr_2

	# Knot collar around stalactite rock apex
	draw_circle(Vector2(0, -28.0), 4.5, root_base_col)
	draw_circle(Vector2(0, -28.0), 3.0, root_bark_col)


func _physics_process(delta: float) -> void:
	bob_time += delta * 2.2
	sway_timer += delta

	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)

	if sway_amplitude > 0.05:
		sway_amplitude = lerp(sway_amplitude, 0.0, delta * 3.2)
		queue_redraw()

	var current_sway: float = sin(sway_timer * 4.5) * sway_amplitude + sin(bob_time * 0.8) * 1.5
	if is_instance_valid(sprite):
		sprite.rotation_degrees = current_sway
		sprite.position = base_sprite_pos + Vector2(sin(deg_to_rad(current_sway)) * 8.0, 0.0)

	if is_instance_valid(crystal_light):
		crystal_light.energy = 0.95 + sin(bob_time * 1.8) * 0.15
		crystal_light.position = sprite.position + Vector2(0.0, 4.0)

	if cooldown_timer > 0.0:
		return

	# Automatic Hollow Knight crystal bounce when player drops onto crystal crown or slashes nearby
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if not is_instance_valid(p) or not (p is CharacterBody2D):
			continue
		var player := p as CharacterBody2D
		var dx: float = abs(player.global_position.x - global_position.x)
		var dy: float = player.global_position.y - global_position.y
		# Landing/dropping into the resonant crystal crown from above
		if dx <= 28.0 and dy >= -38.0 and dy <= 12.0 and player.velocity.y >= -15.0 and not player.is_on_floor():
			trigger_pogo_bounce(player)
			break


func trigger_pogo_bounce(player: CharacterBody2D) -> bool:
	if cooldown_timer > 0.0 or not is_instance_valid(player):
		return false
	cooldown_timer = 0.22

	player.velocity.y = bounce_velocity
	if "max_fall_velocity" in player:
		player.max_fall_velocity = 0.0
	if "current_stamina" in player and "MAX_STAMINA" in player:
		player.current_stamina = min(player.MAX_STAMINA, player.current_stamina + stamina_restore)
		if "is_exhausted" in player and player.current_stamina >= 20.0:
			player.is_exhausted = false
		if player.has_signal("stamina_changed"):
			player.emit_signal("stamina_changed", player.current_stamina, player.MAX_STAMINA)

	# Visual squash & stretch + crystal flash
	if is_instance_valid(sprite):
		sprite.modulate = Color(2.2, 2.5, 2.8, 1.0)
		sprite.scale = Vector2(1.32, 0.72)
		var tw := create_tween()
		tw.tween_property(sprite, "scale", Vector2(0.88, 1.18), 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var c_tw := create_tween()
		c_tw.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.26)

	if is_instance_valid(crystal_light):
		crystal_light.energy = 1.85
		var l_tw := create_tween()
		l_tw.tween_property(crystal_light, "energy", 0.95, 0.28)

	if is_instance_valid(burst_particles):
		burst_particles.restart()
		burst_particles.emitting = true

	if is_instance_valid(sfx_player):
		sfx_player.stream = ProceduralAudioScript.get_hit_slash(true, 2)
		sfx_player.pitch_scale = randf_range(1.32, 1.44)
		sfx_player.play()

	return true

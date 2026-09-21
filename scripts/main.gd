extends Node2D

const AssetsScript = preload("res://scripts/assets.gd")
const PlayerScript = preload("res://scripts/player.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const LevelBuilderScript = preload("res://scripts/level_builder.gd")
const LightningHazardScript = preload("res://scripts/lightning_hazard.gd")
const AswangBossScript = preload("res://scripts/aswang_boss.gd")

static var start_level_idx: int = 0

# ── Level Progression Configuration (11 Total Levels) ─────────────────────────
const LEVELS_DATA = [
	{
		"theme": "Forest",
		"scene_title": "Whispering Canopy",
		"level_title": "Level 1-1",
		"full_title": "Forest Scene — Level 1-1: Whispering Canopy",
		"scene_path": "res://scenes/forest/level_1_1.tscn"
	},
	{
		"theme": "Forest",
		"scene_title": "Ancient Balete Grove",
		"level_title": "Level 1-2",
		"full_title": "Forest Scene — Level 1-2: Ancient Balete Grove",
		"scene_path": "res://scenes/forest/level_1_2.tscn"
	},
	{
		"theme": "Forest",
		"scene_title": "Corrupted Sentry Ridge",
		"level_title": "Level 1-3",
		"full_title": "Forest Scene — Level 1-3: Corrupted Sentry Ridge",
		"scene_path": "res://scenes/forest/level_1_3.tscn"
	},
	{
		"theme": "Rice Field",
		"scene_title": "Emerald Terraces",
		"level_title": "Level 2-1",
		"full_title": "Rice Field Scene — Level 2-1: Emerald Terraces",
		"scene_path": "res://scenes/rice_field/level_2_1.tscn"
	},
	{
		"theme": "Rice Field",
		"scene_title": "Stilt Farmstead",
		"level_title": "Level 2-2",
		"full_title": "Rice Field Scene — Level 2-2: Stilt Farmstead",
		"scene_path": "res://scenes/rice_field/level_2_2.tscn"
	},
	{
		"theme": "Rice Field",
		"scene_title": "The Mayon Crossing",
		"level_title": "Level 2-3",
		"full_title": "Rice Field Scene — Level 2-3: The Mayon Crossing",
		"scene_path": "res://scenes/rice_field/level_2_3.tscn"
	},
	{
		"theme": "Rainy Forest",
		"scene_title": "Drenched Foothills",
		"level_title": "Level 3-1",
		"full_title": "Rainy Forest — Level 3-1: Drenched Foothills",
		"scene_path": "res://scenes/rainy_forest/level_3_1.tscn"
	},
	{
		"theme": "Rainy Forest",
		"scene_title": "Canopy Torrent",
		"level_title": "Level 3-2",
		"full_title": "Rainy Forest — Level 3-2: Canopy Torrent",
		"scene_path": "res://scenes/rainy_forest/level_3_2.tscn"
	},
	{
		"theme": "Rainy Forest",
		"scene_title": "The Flooded Ravine",
		"level_title": "Level 3-3",
		"full_title": "Rainy Forest — Level 3-3: The Flooded Ravine",
		"scene_path": "res://scenes/rainy_forest/level_3_3.tscn"
	},
	{
		"theme": "Rainy Forest",
		"scene_title": "Moss-Veiled Ruins",
		"level_title": "Level 3-4",
		"full_title": "Rainy Forest — Level 3-4: Moss-Veiled Ruins",
		"scene_path": "res://scenes/rainy_forest/level_3_4.tscn"
	},
	{
		"theme": "Rainy Forest",
		"scene_title": "Eye of the Tempest",
		"level_title": "Level 3-5",
		"full_title": "Rainy Forest — Level 3-5: Eye of the Tempest",
		"scene_path": "res://scenes/rainy_forest/level_3_5.tscn"
	}
]

const LEVEL_WIDTH: float = 5120.0
const SPAWN_POS: Vector2 = Vector2(192.0, 260.0)
const MAP_TRANSITION_EDGE_X: float = 5050.0

var level_container: Node2D
var current_level_instance: Node2D
var enemies_container: Node2D
var player: CharacterBody2D
var camera: Camera2D

# Map Edge Progression & Safety Boundaries
var map_boundaries_root: Node2D
var exit_barrier_body: StaticBody2D
var active_enemies: Array[Node] = []
var exit_prompt_label: Label
var exit_prompt_timer: float = 0.0

# ── Parallax Background Layer References ──────────────────────────────────────
var parallax_bg: ParallaxBackground
var sky_parallax_layer: ParallaxLayer
var sky_sprite: Sprite2D
var forest_parallax_layers: Array[ParallaxLayer] = []
var rice_field_parallax_layers: Array[ParallaxLayer] = []

# ── Atmosphere, Storm & Lighting ─────────────────────────────────────────────
var canvas_modulate: CanvasModulate
var ambient_particles: CPUParticles2D
var rain_particles: CPUParticles2D         # Midground rain layer
var rain_particles_fg: CPUParticles2D      # Foreground heavy rain streaks
var rain_particles_bg: CPUParticles2D      # Background mist rain
var rain_splashes: CPUParticles2D          # Ground splash droplets
var storm_fog: CPUParticles2D              # Low rolling forest floor mist
var storm_vignette: TextureRect            # Cinematic soft edge storm vignette
var lightning_container: Node2D
var lightning_timer: float = 0.0
var lightning_flash_timer: float = 0.0
var lightning_flash_intensity: float = 1.0
var sheet_lightning_timer: float = 0.0
var thunder_rumble_timer: float = 0.0
var thunder_audio_player: AudioStreamPlayer
var current_storm_intensity: float = 0.0
var base_modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var current_wind_x: float = -0.35

const LensRainOverlayScript = preload("res://scripts/lens_rain_overlay.gd")
var lens_rain_overlay: Control
var puddles_container: Node2D
var puddles_list: Array[Sprite2D] = []

# Forest 1-1 to 1-3 Dynamic Ambient Bird Layers
var forest_bird_timer: float = 0.0
var forest_bird_players: Array[AudioStreamPlayer2D] = []
var forest_bird_response_timer: float = 0.0
var forest_bird_response_pos: Vector2 = Vector2.ZERO

const PUDDLE_TEX_S = preload("res://assets/vfx/puddle_small.png")
const PUDDLE_TEX_M = preload("res://assets/vfx/puddle_medium.png")
const PUDDLE_TEX_L = preload("res://assets/vfx/puddle_large.png")
const PUDDLE_SHADER = preload("res://shaders/rain_puddle.gdshader")

const RAIN_STREAK_BG = preload("res://assets/vfx/rain_streak_bg.png")
const RAIN_STREAK_MID = preload("res://assets/vfx/rain_streak_mid.png")
const RAIN_STREAK_FG = preload("res://assets/vfx/rain_streak_fg.png")

# ── Game State Management ──────────────────────────────────────────────────────
var current_level_idx: int = 0
var is_game_won: bool = false
var is_player_dead: bool = false
var is_transitioning: bool = false

# ── Score & Stats System ───────────────────────────────────────────────────────
var total_distance_traversed: float = 0.0
var last_player_x: float = 0.0
var run_start_time: float = 0.0
var run_end_time: float = 0.0
var death_count: int = 0
var aswang_kills: int = 0
var skeleton_kills: int = 0

# ── UI References (Souls-like Minimalist HUD) ──────────────────────────────────
var ui_layer: CanvasLayer
var hud_container: Control
var is_ui_visible: bool = true
var fade_overlay: ColorRect
var damage_flash_overlay: ColorRect

## Health & Stamina Status Bars (Custom Fantasy Bars)
const TEX_HUD_HP_FRAME = preload("res://assets/ui/hud_hp_bar_frame.png")
const TEX_HUD_HP_FILL = preload("res://assets/ui/hud_hp_bar_fill.png")
const TEX_HUD_HP_BG = preload("res://assets/ui/hud_hp_bar_bg.png")
const TEX_HUD_STA_FRAME = preload("res://assets/ui/hud_sta_bar_frame.png")
const TEX_HUD_STA_FILL = preload("res://assets/ui/hud_sta_bar_fill.png")
const TEX_HUD_STA_BG = preload("res://assets/ui/hud_sta_bar_bg.png")

var hp_bar_root: Control
var hp_fill_clip: Control
var hp_ghost_clip: Control
var hp_fill_tween: Tween
var hp_pulse_tween: Tween
var hp_ghost_tween: Tween
const HP_FILL_MAX_WIDTH: float = 830.0

var stamina_bar_root: Control
var stamina_fill_clip: Control
var stamina_ghost_clip: Control
var stamina_fill_tween: Tween
var stamina_ghost_tween: Tween
var stamina_fill_tex: TextureRect
const STA_FILL_MAX_WIDTH: float = 828.0

## Centered Atmospheric Stage Discovery (Middle of Screen, No Stars or Dashes)
var area_discovery_container: Control
var stage_name_label: Label
var stage_level_label: Label
var area_title_label: Label
var area_title_timer: float = 0.0
const AREA_TITLE_DURATION: float = 3.0

## Top-Right Minimalist Kill Counter
var score_label: Label

## Respawn & Checkpoint Message Banner
var respawn_label: Label
var respawn_msg_timer: float = 0.0
const RESPAWN_MSG_DURATION: float = 2.0

## Win / Game Victory State overlay
var win_overlay: Control
var win_label: Label
var pause_overlay: Control
# ── Audio & BGM Manager ───────────────────────────────────────────────────────
var bgm_audio_player: AudioStreamPlayer
var current_bgm_track: String = ""

# ── Boss & Climax Encounter (Level 3-5) ───────────────────────────────────────
var is_boss_active: bool = false
var boss_instance: CharacterBody2D = null
var boss_arena_barriers: Array[StaticBody2D] = []
var boss_hud_root: Control
var boss_hp_fill: ColorRect
var boss_hp_ghost: ColorRect
var boss_title_label: Label
var boss_hp_tween: Tween

# ── Screen Shake & Game Feel (Trauma System) ──────────────────────────────────
var trauma: float = 0.0
const TRAUMA_DECAY: float = 2.4
const MAX_SHAKE_OFFSET: float = 12.0
const MAX_SHAKE_ANGLE: float = 0.035
var hit_stop_timer: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	RenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
	current_level_idx = clamp(start_level_idx, 0, LEVELS_DATA.size() - 1)
	start_level_idx = 0
	setup_bgm()
	setup_parallax_bg()
	setup_atmosphere()
	setup_level_container()
	load_current_level()
	setup_enemies_container()
	setup_player()
	setup_camera()
	setup_ui()
	spawn_level_enemies()

	run_start_time = Time.get_ticks_msec() / 1000.0
	respawn_player_at_checkpoint()


# ── Parallax Background System ────────────────────────────────────────────────
func setup_parallax_bg() -> void:
	parallax_bg = ParallaxBackground.new()
	parallax_bg.name = "ParallaxBackground"
	add_child(parallax_bg)

	# 1. Shared Sky Layer (Always active, Layer 5)
	sky_parallax_layer = ParallaxLayer.new()
	sky_parallax_layer.name = "SkyParallaxLayer"
	sky_parallax_layer.motion_scale = Vector2(0.02, 0.0)
	sky_parallax_layer.motion_mirroring = Vector2(1024, 0)
	
	var sky_spr := Sprite2D.new()
	sky_spr.name = "SkySprite"
	var sky_tex = load(AssetsScript.PATH_BG_LAYER_5)
	sky_spr.texture = sky_tex
	sky_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sky_spr.centered = false
	sky_spr.scale = Vector2(1.01, 1.05)
	sky_parallax_layer.add_child(sky_spr)
	parallax_bg.add_child(sky_parallax_layer)
	sky_sprite = sky_spr

	# 2. Forest Parallax Layers (Layers 4, 3, 2, 1)
	forest_parallax_layers.clear()
	var forest_data = [
		{"path": AssetsScript.PATH_BG_LAYER_4, "scale": Vector2(0.12, 0.0), "mirror_w": 2128.0, "spr_scale": Vector2(0.5005, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_3, "scale": Vector2(0.28, 0.0), "mirror_w": 2128.0, "spr_scale": Vector2(0.5005, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_2, "scale": Vector2(0.50, 0.0), "mirror_w": 2128.0, "spr_scale": Vector2(0.5005, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_1, "scale": Vector2(0.75, 0.0), "mirror_w": 2128.0, "spr_scale": Vector2(0.5005, 0.5)}
	]

	for i in range(forest_data.size()):
		var f_info = forest_data[i]
		var layer := ParallaxLayer.new()
		layer.name = "ForestLayer_%d" % (4 - i)
		layer.motion_scale = f_info["scale"]
		layer.motion_mirroring = Vector2(f_info["mirror_w"], 0)

		var spr := Sprite2D.new()
		var tex = load(f_info["path"])
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = false
		spr.scale = f_info["spr_scale"]
		layer.add_child(spr)

		parallax_bg.add_child(layer)
		forest_parallax_layers.append(layer)

	# 3. Rice Field Parallax Layers (Tiered Depth: Layer 4 Mount Mayon -> Layer 1 Foreground)
	# Scales dynamically to match 360px viewport height with seamless horizontal mirroring
	rice_field_parallax_layers.clear()
	var rice_data = [
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_4, "scale": Vector2(0.05, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_3, "scale": Vector2(0.16, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_2, "scale": Vector2(0.42, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_1, "scale": Vector2(0.75, 0.0)}
	]

	for i in range(rice_data.size()):
		var r_info = rice_data[i]
		var layer := ParallaxLayer.new()
		layer.name = "RiceFieldLayer_%d" % (4 - i)
		layer.motion_scale = r_info["scale"]

		var spr := Sprite2D.new()
		var tex = load(r_info["path"])
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = false

		# Dynamically scale to fit 360px viewport height maintaining aspect ratio
		var tex_h: float = float(tex.get_height()) if tex else 720.0
		var tex_w: float = float(tex.get_width()) if tex else 2160.0
		var scale_factor: float = 360.0 / tex_h
		spr.scale = Vector2(scale_factor, scale_factor)
		layer.motion_mirroring = Vector2(tex_w * scale_factor, 0.0)
		layer.add_child(spr)

		parallax_bg.add_child(layer)
		rice_field_parallax_layers.append(layer)

	# Set initial background theme based on active level
	set_background_theme(LEVELS_DATA[current_level_idx]["theme"])


func setup_atmosphere() -> void:
	canvas_modulate = CanvasModulate.new()
	canvas_modulate.name = "AtmosphericModulate"
	add_child(canvas_modulate)
	
	ambient_particles = CPUParticles2D.new()
	ambient_particles.name = "AmbientParticles"
	ambient_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ambient_particles.emission_rect_extents = Vector2(340, 200)
	ambient_particles.lifetime = 4.0
	ambient_particles.amount = 35
	ambient_particles.scale_amount_min = 1.5
	ambient_particles.scale_amount_max = 3.0
	add_child(ambient_particles)

	# 1. Background Rain Mist Layer (z_index = -3, behind foreground tiles)
	rain_particles_bg = CPUParticles2D.new()
	rain_particles_bg.name = "RainParticlesBG"
	rain_particles_bg.z_index = -3
	rain_particles_bg.texture = RAIN_STREAK_BG
	rain_particles_bg.particle_flag_align_y = true
	rain_particles_bg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain_particles_bg.emission_rect_extents = Vector2(460, 20)
	rain_particles_bg.lifetime = 0.85
	rain_particles_bg.amount = 140
	rain_particles_bg.direction = Vector2(-0.35, 1.0).normalized()
	rain_particles_bg.spread = 4.0
	rain_particles_bg.gravity = Vector2(-60.0, 680.0)
	rain_particles_bg.initial_velocity_min = 320.0
	rain_particles_bg.initial_velocity_max = 460.0
	rain_particles_bg.scale_amount_min = 0.8
	rain_particles_bg.scale_amount_max = 1.4
	rain_particles_bg.color = Color(0.55, 0.65, 0.82, 0.35)
	rain_particles_bg.emitting = false
	add_child(rain_particles_bg)

	# 2. Midground Main Rain Layer (z_index = 6, gameplay plane)
	rain_particles = CPUParticles2D.new()
	rain_particles.name = "RainParticles"
	rain_particles.z_index = 6
	rain_particles.texture = RAIN_STREAK_MID
	rain_particles.particle_flag_align_y = true
	rain_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain_particles.emission_rect_extents = Vector2(440, 20)
	rain_particles.lifetime = 0.70
	rain_particles.amount = 260
	rain_particles.direction = Vector2(-0.35, 1.0).normalized()
	rain_particles.spread = 4.0
	rain_particles.gravity = Vector2(-80.0, 780.0)
	rain_particles.initial_velocity_min = 420.0
	rain_particles.initial_velocity_max = 580.0
	rain_particles.scale_amount_min = 1.0
	rain_particles.scale_amount_max = 1.8
	rain_particles.color = Color(0.72, 0.84, 0.96, 0.70)
	rain_particles.emitting = false
	add_child(rain_particles)

	# 3. Foreground Fast Rain Streaks (z_index = 12, in front of camera)
	rain_particles_fg = CPUParticles2D.new()
	rain_particles_fg.name = "RainParticlesFG"
	rain_particles_fg.z_index = 12
	rain_particles_fg.texture = RAIN_STREAK_FG
	rain_particles_fg.particle_flag_align_y = true
	rain_particles_fg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain_particles_fg.emission_rect_extents = Vector2(420, 20)
	rain_particles_fg.lifetime = 0.52
	rain_particles_fg.amount = 75
	rain_particles_fg.direction = Vector2(-0.35, 1.0).normalized()
	rain_particles_fg.spread = 3.0
	rain_particles_fg.gravity = Vector2(-110.0, 920.0)
	rain_particles_fg.initial_velocity_min = 640.0
	rain_particles_fg.initial_velocity_max = 820.0
	rain_particles_fg.scale_amount_min = 1.0
	rain_particles_fg.scale_amount_max = 2.0
	rain_particles_fg.color = Color(0.80, 0.90, 1.0, 0.75)
	rain_particles_fg.emitting = false
	add_child(rain_particles_fg)

	# 4. Ground Rain Splash Droplets (z_index = 4, surface impacts)
	rain_splashes = CPUParticles2D.new()
	rain_splashes.name = "RainSplashes"
	rain_splashes.z_index = 4
	rain_splashes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain_splashes.emission_rect_extents = Vector2(420, 12)
	rain_splashes.lifetime = 0.28
	rain_splashes.amount = 120
	rain_splashes.direction = Vector2(0, -1)
	rain_splashes.spread = 65.0
	rain_splashes.gravity = Vector2(0, 480.0)
	rain_splashes.initial_velocity_min = 40.0
	rain_splashes.initial_velocity_max = 95.0
	rain_splashes.scale_amount_min = 1.0
	rain_splashes.scale_amount_max = 2.2
	rain_splashes.color = Color(0.75, 0.88, 1.0, 0.65)
	rain_splashes.emitting = false
	add_child(rain_splashes)

	# 5. Low-Lying Rolling Forest Mist / Fog (z_index = -1)
	storm_fog = CPUParticles2D.new()
	storm_fog.name = "StormFog"
	storm_fog.z_index = -1
	storm_fog.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	storm_fog.emission_rect_extents = Vector2(460, 35)
	storm_fog.lifetime = 4.5
	storm_fog.amount = 26
	storm_fog.direction = Vector2(-1.0, 0.05)
	storm_fog.spread = 20.0
	storm_fog.gravity = Vector2(-12.0, 0.0)
	storm_fog.initial_velocity_min = 15.0
	storm_fog.initial_velocity_max = 35.0
	storm_fog.scale_amount_min = 6.0
	storm_fog.scale_amount_max = 15.0
	storm_fog.color = Color(0.48, 0.58, 0.72, 0.14)
	storm_fog.emitting = false
	add_child(storm_fog)

	# 6. Thunder SFX Player
	thunder_audio_player = AudioStreamPlayer.new()
	thunder_audio_player.name = "ThunderSFXPlayer"
	thunder_audio_player.bus = "Master"
	var crit_sfx = load("res://assets/audio/sfx/hit_critical.wav")
	if crit_sfx:
		thunder_audio_player.stream = crit_sfx
	add_child(thunder_audio_player)

	# 7. Cinematic Storm Vignette (Screen-space CanvasLayer)
	var storm_layer := CanvasLayer.new()
	storm_layer.name = "StormOverlayLayer"
	storm_layer.layer = 5 # In front of game world (layer 0), behind UI (layer 10)
	add_child(storm_layer)

	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0))
	grad.set_color(1, Color(0.02, 0.05, 0.12, 0.75))
	var grad_tex := GradientTexture2D.new()
	grad_tex.gradient = grad
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(1.0, 1.0)
	grad_tex.width = 640
	grad_tex.height = 360

	storm_vignette = TextureRect.new()
	storm_vignette.name = "StormVignette"
	storm_vignette.texture = grad_tex
	storm_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	storm_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	storm_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	storm_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	storm_vignette.modulate = Color(1, 1, 1, 0.0)
	storm_layer.add_child(storm_vignette)

	lens_rain_overlay = LensRainOverlayScript.new()
	lens_rain_overlay.name = "LensRainOverlay"
	storm_layer.add_child(lens_rain_overlay)

	puddles_container = Node2D.new()
	puddles_container.name = "PuddlesContainer"
	puddles_container.z_index = 1
	add_child(puddles_container)

	lightning_container = Node2D.new()
	lightning_container.name = "LightningContainer"
	add_child(lightning_container)


func setup_bgm() -> void:
	bgm_audio_player = AudioStreamPlayer.new()
	bgm_audio_player.name = "BGMPlayer"
	bgm_audio_player.bus = "Master"
	add_child(bgm_audio_player)
	setup_forest_bird_audio()


func setup_forest_bird_audio() -> void:
	for p in forest_bird_players:
		if is_instance_valid(p):
			p.queue_free()
	forest_bird_players.clear()

	for i in range(2):
		var bp := AudioStreamPlayer2D.new()
		bp.name = "ForestBirdPlayer_%d" % i
		bp.bus = "Master"
		bp.panning_strength = 1.2
		bp.max_distance = 2500.0
		bp.attenuation = 0.5
		bp.volume_db = -12.0
		add_child(bp)
		forest_bird_players.append(bp)

	forest_bird_timer = randf_range(2.0, 4.5)
	forest_bird_response_timer = 0.0


func update_forest_bird_ambience(delta: float) -> void:
	# Active ONLY in Forest 1-1, 1-2, 1-3 (current_level_idx in [0, 1, 2])
	var is_forest_level: bool = (current_level_idx in [0, 1, 2])
	if not is_forest_level or is_player_dead or is_transitioning or get_tree().paused:
		forest_bird_response_timer = 0.0
		return

	# Handle delayed companion response chirp if scheduled
	if forest_bird_response_timer > 0.0:
		forest_bird_response_timer -= delta
		if forest_bird_response_timer <= 0.0:
			play_forest_bird_at(forest_bird_response_pos, true)

	forest_bird_timer -= delta
	if forest_bird_timer <= 0.0:
		forest_bird_timer = randf_range(3.5, 7.5)
		trigger_forest_bird_chirp()


func trigger_forest_bird_chirp() -> void:
	if not camera or not current_level_instance:
		return

	var cam_x = camera.global_position.x
	var candidate_trees: Array[Node2D] = []
	var foliage = current_level_instance.find_child("Foliage", true, false)
	if foliage:
		for child in foliage.get_children():
			if child is Node2D:
				var tx = child.global_position.x
				# Within visible screen or immediate borders
				if tx >= cam_x - 360.0 and tx <= cam_x + 360.0:
					candidate_trees.append(child)

	var target_tree: Node2D = null
	if not candidate_trees.is_empty():
		target_tree = candidate_trees.pick_random()
	elif foliage and foliage.get_child_count() > 0:
		target_tree = foliage.get_children().pick_random() as Node2D

	var bird_pos: Vector2
	if target_tree:
		# Position sound up in the leafy tree canopy
		bird_pos = Vector2(target_tree.global_position.x, target_tree.global_position.y - 120.0)
	else:
		var side = 1.0 if randf() > 0.5 else -1.0
		bird_pos = Vector2(cam_x + side * randf_range(160.0, 320.0), 120.0)

	play_forest_bird_at(bird_pos, false)

	# 35% chance of a companion bird answering from an opposite tree on screen!
	if candidate_trees.size() >= 2 and randf() < 0.35:
		var opp_trees: Array[Node2D] = []
		for t in candidate_trees:
			if (t.global_position.x - cam_x) * (bird_pos.x - cam_x) <= 0.0:
				opp_trees.append(t)
		if not opp_trees.is_empty():
			var opp_tree = opp_trees.pick_random()
			forest_bird_response_pos = Vector2(opp_tree.global_position.x, opp_tree.global_position.y - 120.0)
			forest_bird_response_timer = randf_range(0.45, 0.85)


func play_forest_bird_at(pos: Vector2, is_response: bool = false) -> void:
	if forest_bird_players.is_empty():
		return

	# Pick an available player from pool
	var player_to_use: AudioStreamPlayer2D = forest_bird_players[0]
	if is_response and forest_bird_players.size() > 1:
		player_to_use = forest_bird_players[1]
	elif player_to_use.playing and forest_bird_players.size() > 1:
		player_to_use = forest_bird_players[1]

	var chirp_stream = ProceduralAudio.get_random_bird_chirp()
	if chirp_stream:
		player_to_use.stream = chirp_stream
		player_to_use.global_position = pos
		player_to_use.pitch_scale = randf_range(0.95, 1.06)
		player_to_use.volume_db = randf_range(-14.5, -11.0) if not is_response else randf_range(-15.5, -12.5)
		player_to_use.play()


func play_bgm(new_stream: AudioStream, track_key: String, fade_time: float = 1.2) -> void:
	if not is_instance_valid(bgm_audio_player):
		return
	if current_bgm_track == track_key and bgm_audio_player.playing:
		return
	current_bgm_track = track_key
	if not new_stream:
		return

	if bgm_audio_player.playing:
		var tw = create_tween()
		tw.tween_property(bgm_audio_player, "volume_db", -50.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func():
			if not is_instance_valid(bgm_audio_player):
				return
			bgm_audio_player.stream = new_stream
			bgm_audio_player.volume_db = -45.0
			bgm_audio_player.play()
			var tw2 = create_tween()
			var target_vol = -7.0 if track_key == "boss" else -11.0
			tw2.tween_property(bgm_audio_player, "volume_db", target_vol, fade_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		)
	else:
		bgm_audio_player.stream = new_stream
		bgm_audio_player.volume_db = -45.0
		bgm_audio_player.play()
		var tw = create_tween()
		var target_vol = -7.0 if track_key == "boss" else -11.0
		tw.tween_property(bgm_audio_player, "volume_db", target_vol, fade_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func set_background_theme(theme_name: String) -> void:
	var is_forest: bool = (theme_name == "Forest" or theme_name == "Rainy Forest")
	var is_rainy: bool = (theme_name == "Rainy Forest")

	for layer in forest_parallax_layers:
		layer.visible = is_forest
		if is_rainy:
			layer.modulate = Color(0.52, 0.56, 0.70, 1.0)
		else:
			layer.modulate = Color(1.0, 1.0, 1.0, 1.0)

	for layer in rice_field_parallax_layers:
		layer.visible = not is_forest
		layer.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if sky_sprite:
		if is_rainy:
			sky_sprite.modulate = Color(0.35, 0.40, 0.52, 1.0)
		else:
			sky_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if is_rainy:
		var sub_level: float = float(current_level_idx - 6) # 0 to 4
		base_modulate_color = Color(0.29 - sub_level * 0.018, 0.32 - sub_level * 0.018, 0.43 - sub_level * 0.015, 1.0)
		if canvas_modulate:
			canvas_modulate.color = base_modulate_color

		# Configure 3-layer rain
		if rain_particles:
			rain_particles.emitting = true
			rain_particles.modulate = Color(1.0, 1.0, 1.0, 1.0)
			rain_particles.amount = 220 + int(sub_level * 25.0)
		if rain_particles_fg:
			rain_particles_fg.emitting = true
			rain_particles_fg.modulate = Color(1.0, 1.0, 1.0, 1.0)
			rain_particles_fg.amount = 60 + int(sub_level * 10.0)
		if rain_particles_bg:
			rain_particles_bg.emitting = true
			rain_particles_bg.modulate = Color(1.0, 1.0, 1.0, 1.0)
			rain_particles_bg.amount = 120 + int(sub_level * 15.0)
		if rain_splashes:
			rain_splashes.emitting = true
			rain_splashes.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if storm_fog:
			storm_fog.emitting = true
			storm_fog.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if storm_vignette:
			storm_vignette.modulate.a = 0.55 + sub_level * 0.07

		reset_lightning_timer(4.5 - sub_level * 0.5, 8.5 - sub_level * 0.7)
		sheet_lightning_timer = randf_range(3.5, 6.5)
	elif theme_name == "Forest":
		base_modulate_color = Color(0.74, 0.75, 0.76, 1.0)
		if canvas_modulate:
			canvas_modulate.color = base_modulate_color
		if rain_particles:
			rain_particles.emitting = false
		if rain_particles_fg:
			rain_particles_fg.emitting = false
		if rain_particles_bg:
			rain_particles_bg.emitting = false
		if rain_splashes:
			rain_splashes.emitting = false
		if storm_fog:
			storm_fog.emitting = false
		if storm_vignette:
			storm_vignette.modulate.a = 0.0
	else: # Rice Field
		base_modulate_color = Color(1.0, 1.0, 1.0, 1.0)
		if canvas_modulate:
			canvas_modulate.color = base_modulate_color
		if rain_particles:
			rain_particles.emitting = false
		if rain_particles_fg:
			rain_particles_fg.emitting = false
		if rain_particles_bg:
			rain_particles_bg.emitting = false
		if rain_splashes:
			rain_splashes.emitting = false
		if storm_fog:
			storm_fog.emitting = false
		if storm_vignette:
			storm_vignette.modulate.a = 0.0

	if ambient_particles:
		if is_rainy:
			ambient_particles.amount = 30
			ambient_particles.direction = Vector2(-0.35, 1.0)
			ambient_particles.spread = 20.0
			ambient_particles.gravity = Vector2(-30.0, 100.0)
			ambient_particles.initial_velocity_min = 40.0
			ambient_particles.initial_velocity_max = 80.0
			ambient_particles.scale_amount_min = 1.0
			ambient_particles.scale_amount_max = 2.0
			ambient_particles.color = Color(0.8, 0.9, 1.0, 0.35)
		elif is_forest:
			ambient_particles.amount = 16
			ambient_particles.direction = Vector2(0.6, 0.8)
			ambient_particles.spread = 45.0
			ambient_particles.gravity = Vector2(10.0, 15.0)
			ambient_particles.initial_velocity_min = 10.0
			ambient_particles.initial_velocity_max = 24.0
			ambient_particles.scale_amount_min = 1.0
			ambient_particles.scale_amount_max = 2.2
			ambient_particles.color = Color(0.75, 0.85, 0.45, 0.45) # Soft drifting leaf/pollen motes
		else:
			ambient_particles.amount = 35
			ambient_particles.direction = Vector2(-1, 0.2)
			ambient_particles.spread = 30.0
			ambient_particles.gravity = Vector2(-25.0, 8.0)
			ambient_particles.initial_velocity_min = 25.0
			ambient_particles.initial_velocity_max = 50.0
			ambient_particles.scale_amount_min = 1.5
			ambient_particles.scale_amount_max = 3.0
			ambient_particles.color = Color(1.0, 0.85, 0.35, 0.65) # Golden pollen motes

	# Dynamic BGM cross-fade per theme (unless boss battle is locked in)
	if not is_boss_active:
		match theme_name:
			"Forest":
				play_bgm(ProceduralAudio.get_forest_ambient(), "forest")
			"Rice Field":
				play_bgm(ProceduralAudio.get_rice_field_ambient(), "rice_field")
			"Rainy Forest":
				play_bgm(ProceduralAudio.get_tempest_ambient(), "tempest")


# ── Level Container & Instantiation ───────────────────────────────────────────
func setup_level_container() -> void:
	level_container = Node2D.new()
	level_container.name = "LevelContainer"
	add_child(level_container)


func load_current_level() -> void:
	if not level_container:
		setup_level_container()
	for child in level_container.get_children():
		child.queue_free()
	if lightning_container:
		for child in lightning_container.get_children():
			child.queue_free()
	if puddles_container:
		for child in puddles_container.get_children():
			child.queue_free()
		puddles_list.clear()

	var data = LEVELS_DATA[current_level_idx]
	var scene_path: String = data.get("scene_path", "")

	if ResourceLoader.exists(scene_path):
		var scene_res = load(scene_path)
		if scene_res is PackedScene:
			current_level_instance = scene_res.instantiate()
			level_container.add_child(current_level_instance)

			# Remove any legacy portal node from scene
			var portal_node = current_level_instance.find_child("LevelExitPortal", true, false)
			if portal_node:
				portal_node.queue_free()

			# Configure tilemap layers and ensure collision behavior
			for child in current_level_instance.get_children():
				if child is TileMapLayer:
					var layer := child as TileMapLayer
					if layer.name == "ForegroundDecor":
						layer.collision_enabled = true
					elif layer.name == "WaterBackground":
						layer.collision_enabled = false
					ensure_tileset_physics(layer)

			# If Rainy Forest, configure storm wind on foliage and storm mode on torches
			if data.get("theme", "") == "Rainy Forest":
				configure_storm_environment(current_level_instance)

			# Auto-wire scene enemies
			wire_scene_enemies(current_level_instance)
		else:
			LevelBuilderScript.build_level(level_container, current_level_idx, data["theme"])
	else:
		LevelBuilderScript.build_level(level_container, current_level_idx, data["theme"])

	set_background_theme(data["theme"])
	if data.get("theme", "") == "Rainy Forest":
		spawn_stage3_puddles()
	elif data.get("theme", "") == "Forest":
		forest_bird_timer = randf_range(2.0, 4.0)
		forest_bird_response_timer = 0.0
	else:
		for p in forest_bird_players:
			if is_instance_valid(p):
				p.stop()
		forest_bird_response_timer = 0.0
	setup_map_edge_boundaries()
	trigger_area_discovery()


func configure_storm_environment(root_level: Node2D) -> void:
	if not root_level:
		return
	# 1. Torches storm mode
	var torches_node = root_level.find_child("Torches", true, false)
	if torches_node:
		for torch in torches_node.get_children():
			if torch.has_method("set_storm_mode"):
				torch.set_storm_mode(true)

	# 2. Foliage storm wind shader intensity
	var foliage_node = root_level.find_child("Foliage", true, false)
	if foliage_node:
		for spr in foliage_node.get_children():
			if spr is Sprite2D and spr.material is ShaderMaterial:
				var sm := spr.material as ShaderMaterial
				sm.set_shader_parameter("wind_speed", 3.8)
				sm.set_shader_parameter("wind_strength", 10.5)
				sm.set_shader_parameter("wind_detail", 3.0)


func spawn_stage3_puddles() -> void:
	if not puddles_container:
		return
	for child in puddles_container.get_children():
		child.queue_free()
	puddles_list.clear()

	var puddle_textures = [PUDDLE_TEX_S, PUDDLE_TEX_M, PUDDLE_TEX_L]
	var num_puddles: int = 14
	var step_x: float = (LEVEL_WIDTH - 600.0) / float(num_puddles)

	for i in range(num_puddles):
		var px: float = 280.0 + float(i) * step_x + randf_range(-50.0, 50.0)
		var py: float = get_ground_y_at_x(px)
		if py > 900.0:
			continue

		var puddle_spr := Sprite2D.new()
		puddle_spr.name = "RainPuddle_%d" % i
		var tex_idx: int = randi() % puddle_textures.size()
		puddle_spr.texture = puddle_textures[tex_idx]
		puddle_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		var sm := ShaderMaterial.new()
		sm.shader = PUDDLE_SHADER
		sm.set_shader_parameter("shimmer_speed", randf_range(1.8, 3.2))
		sm.set_shader_parameter("lightning_flash", 0.0)
		puddle_spr.material = sm

		puddle_spr.centered = true
		puddle_spr.position = Vector2(px, py + 2.0)
		puddle_spr.flip_h = (randf() > 0.5)
		puddle_spr.modulate = Color(1.0, 1.0, 1.0, 0.95)

		puddles_container.add_child(puddle_spr)
		puddles_list.append(puddle_spr)


func flash_puddles(duration: float = 0.24) -> void:
	for p in puddles_list:
		if is_instance_valid(p) and p.material is ShaderMaterial:
			var sm := p.material as ShaderMaterial
			var tw := create_tween()
			tw.tween_property(sm, "shader_parameter/lightning_flash", 0.0, duration).from(1.0)


func apply_hit_stop(duration: float = 0.045) -> void:
	hit_stop_timer = duration
	Engine.time_scale = 0.05


func wire_scene_enemies(root_level: Node2D) -> void:
	active_enemies.clear()
	var enemies_node = root_level.find_child("Enemies", true, false)
	var enemies_list = enemies_node.get_children() if enemies_node else root_level.find_children("", "CharacterBody2D", true, false)

	for enemy in enemies_list:
		if enemy is Aswang:
			if not enemy.aswang_died.is_connected(_on_aswang_died):
				enemy.aswang_died.connect(_on_aswang_died)
			active_enemies.append(enemy)
		elif enemy is Skeleton:
			if not enemy.skeleton_died.is_connected(_on_skeleton_died):
				enemy.skeleton_died.connect(_on_skeleton_died)
			active_enemies.append(enemy)
	
	if active_enemies.is_empty():
		unlock_exit_path()


func setup_enemies_container() -> void:
	enemies_container = Node2D.new()
	enemies_container.name = "EnemiesContainer"
	add_child(enemies_container)


func spawn_level_enemies() -> void:
	# If current scene already has enemies baked in, keep them wired
	if current_level_instance:
		var scene_enemies = current_level_instance.find_child("Enemies", true, false)
		if scene_enemies and scene_enemies.get_child_count() > 0:
			wire_scene_enemies(current_level_instance)
			return

	if not enemies_container:
		return
	active_enemies.clear()
	if is_boss_active or current_level_idx == 10:
		is_boss_active = false
		clear_boss_arena_barriers()
		if is_instance_valid(boss_instance):
			boss_instance.queue_free()
			boss_instance = null
		if is_instance_valid(boss_hud_root):
			boss_hud_root.visible = false
			boss_hud_root.modulate.a = 0.0
	var data = LEVELS_DATA[current_level_idx]
	LevelBuilderScript.spawn_enemies(enemies_container, current_level_idx, data["theme"], _on_aswang_died, _on_skeleton_died)
	for child in enemies_container.get_children():
		if child is CharacterBody2D:
			active_enemies.append(child)
	if active_enemies.is_empty():
		unlock_exit_path()


func _on_aswang_died(enemy: Aswang) -> void:
	aswang_kills += 1
	if enemy in active_enemies:
		active_enemies.erase(enemy)
	update_score_hud()
	check_enemies_cleared()


func _on_skeleton_died(enemy: Skeleton) -> void:
	skeleton_kills += 1
	if enemy in active_enemies:
		active_enemies.erase(enemy)
	update_score_hud()
	check_enemies_cleared()


func check_enemies_cleared() -> void:
	var remaining: int = 0
	for e in active_enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			remaining += 1
	if remaining == 0:
		unlock_exit_path()


func ensure_tileset_physics(node: Node) -> void:
	if node is TileMapLayer:
		var tm := node as TileMapLayer
		var ts := tm.tile_set
		if ts:
			if ts.get_physics_layers_count() == 0:
				ts.add_physics_layer()
				ts.set_physics_layer_collision_layer(0, 1)
				ts.set_physics_layer_collision_mask(0, 1)

			var poly_points = PackedVector2Array([
				Vector2(-16, -16),
				Vector2(16, -16),
				Vector2(16, 16),
				Vector2(-16, 16)
			])

			for source_idx in range(ts.get_source_count()):
				var source_id = ts.get_source_id(source_idx)
				var source = ts.get_source(source_id)
				if source is TileSetAtlasSource:
					var atlas_source = source as TileSetAtlasSource
					var tex = atlas_source.texture
					var tex_path: String = tex.resource_path.to_lower() if tex else ""
					
					# Strictly ensure ONLY Floor Tiles and Other Tiles are solid
					var is_solid_source: bool = (
						"floor tiles" in tex_path or 
						"other tiles" in tex_path
					)

					for tile_idx in range(atlas_source.get_tiles_count()):
						var coords = atlas_source.get_tile_id(tile_idx)
						var tile_data = atlas_source.get_tile_data(coords, 0)
						if tile_data:
							if is_solid_source:
								if tile_data.get_collision_polygons_count(0) == 0:
									tile_data.add_collision_polygon(0)
									tile_data.set_collision_polygon_points(0, 0, poly_points)
							else:
								# Ensure non-solid tiles (decor, grass, water, dirt) have NO collision
								while tile_data.get_collision_polygons_count(0) > 0:
									tile_data.remove_collision_polygon(0, 0)


func get_level_end_ground_y() -> float:
	var end_y: float = 288.0
	if current_level_instance:
		var base_ground: TileMapLayer = current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
		if base_ground:
			var min_surface_y: float = 9999.0
			for col in range(150, 160):
				for row in range(0, 30):
					if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
						var td = base_ground.get_cell_tile_data(Vector2i(col, row))
						if td and td.get_collision_polygons_count(0) > 0:
							var wy = row * (base_ground.tile_set.tile_size.y if base_ground.tile_set else 32.0)
							min_surface_y = min(min_surface_y, wy)
			if min_surface_y < 9000.0:
				return min_surface_y
	return end_y


func get_ground_y_at_x(target_x: float) -> float:
	var default_y: float = 288.0
	if current_level_instance:
		var base_ground: TileMapLayer = current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
		if base_ground and base_ground.tile_set:
			var tile_size = base_ground.tile_set.tile_size
			var col: int = int(floor(target_x / float(tile_size.x)))
			var min_surface_y: float = 9999.0
			for row in range(0, 25):
				if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
					var td = base_ground.get_cell_tile_data(Vector2i(col, row))
					if td and td.get_collision_polygons_count(0) > 0:
						min_surface_y = min(min_surface_y, float(row * tile_size.y))
			if min_surface_y < 9000.0:
				return min_surface_y
	return default_y


func setup_map_edge_boundaries() -> void:
	if map_boundaries_root and is_instance_valid(map_boundaries_root):
		map_boundaries_root.queue_free()
	
	map_boundaries_root = Node2D.new()
	map_boundaries_root.name = "MapBoundaries"
	add_child(map_boundaries_root)

	# 1. Left Edge Boundary Wall (Prevents falling off backwards at level start)
	var left_wall := StaticBody2D.new()
	left_wall.name = "LeftBoundaryWall"
	left_wall.collision_layer = 1
	left_wall.collision_mask = 0
	var left_shape := CollisionShape2D.new()
	var left_rect := RectangleShape2D.new()
	left_rect.size = Vector2(32.0, 900.0)
	left_shape.shape = left_rect
	left_wall.position = Vector2(-16.0, 150.0)
	left_wall.add_child(left_shape)
	map_boundaries_root.add_child(left_wall)

	# 2. Right Extended Floor (Continuous solid footing past map edge so no entity can ever fall)
	# Begins at x = 5120.0 (where the tilemap ends) so it never intrudes into the playable level area
	var ground_end_y = get_level_end_ground_y()
	var right_floor := StaticBody2D.new()
	right_floor.name = "RightExtendedFloor"
	right_floor.collision_layer = 1
	right_floor.collision_mask = 0
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(600.0, 64.0)
	floor_shape.shape = floor_rect
	right_floor.position = Vector2(5120.0 + 300.0, ground_end_y + 32.0)
	right_floor.add_child(floor_shape)
	map_boundaries_root.add_child(right_floor)

	# 3. Right Safety Backstop Wall (Prevents walking past the extended floor)
	var backstop := StaticBody2D.new()
	backstop.name = "RightBackstopWall"
	backstop.collision_layer = 1
	backstop.collision_mask = 0
	var backstop_shape := CollisionShape2D.new()
	var backstop_rect := RectangleShape2D.new()
	backstop_rect.size = Vector2(32.0, 900.0)
	backstop_shape.shape = backstop_rect
	backstop.position = Vector2(5600.0, 150.0)
	backstop.add_child(backstop_shape)
	map_boundaries_root.add_child(backstop)

	setup_exit_barrier()


func setup_exit_barrier() -> void:
	if exit_barrier_body and is_instance_valid(exit_barrier_body):
		exit_barrier_body.queue_free()
		exit_barrier_body = null


func unlock_exit_path() -> void:
	if exit_barrier_body and is_instance_valid(exit_barrier_body):
		exit_barrier_body.queue_free()
		exit_barrier_body = null
	show_exit_banner("Area Cleared", Color(1.0, 0.9, 0.3, 1.0))


func show_exit_banner(msg: String, color: Color) -> void:
	if not is_instance_valid(exit_prompt_label):
		return
	exit_prompt_label.text = msg
	exit_prompt_label.add_theme_color_override("font_color", color)
	exit_prompt_label.modulate.a = 1.0
	exit_prompt_label.visible = true
	exit_prompt_timer = 2.5


func setup_player() -> void:
	player = PlayerScript.new()
	player.name = "Player"
	add_child(player)
	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(_on_player_hp_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.hit_landed.connect(_on_player_hit_landed)
	if player.has_signal("riposte_performed"):
		player.riposte_performed.connect(_on_player_riposte_performed)
	player.damage_taken.connect(_on_player_damage_taken)


func setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)


func setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "HUD"
	add_child(ui_layer)

	# Master container for all in-game HUD elements (toggled together)
	hud_container = Control.new()
	hud_container.name = "HUDContainer"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud_container)

	var custom_font = load("res://alagard.ttf")

	# ── 1. Custom Health Bar (Top-Left: 10, 10 | Frame 946x84 scaled 0.20 to ~189px) ────
	hp_bar_root = Control.new()
	hp_bar_root.name = "HealthBarRoot"
	hp_bar_root.position = Vector2(10, 10)
	hp_bar_root.scale = Vector2(0.20, 0.20)
	hud_container.add_child(hp_bar_root)

	var hp_bg = TextureRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.texture = TEX_HUD_HP_BG
	hp_bg.position = Vector2(58, 12)
	hp_bar_root.add_child(hp_bg)

	# Ghost damage bar (amber/yellow trailing bar)
	hp_ghost_clip = Control.new()
	hp_ghost_clip.name = "HPGhostClip"
	hp_ghost_clip.position = Vector2(58, 12)
	hp_ghost_clip.size = Vector2(HP_FILL_MAX_WIDTH, 60)
	hp_ghost_clip.clip_contents = true
	hp_bar_root.add_child(hp_ghost_clip)

	var hp_ghost_tex = TextureRect.new()
	hp_ghost_tex.texture = TEX_HUD_HP_FILL
	hp_ghost_tex.modulate = Color(1.8, 1.4, 0.4, 0.85)
	hp_ghost_clip.add_child(hp_ghost_tex)

	# Primary Health bar (vibrant red patterned weave)
	hp_fill_clip = Control.new()
	hp_fill_clip.name = "HPFillClip"
	hp_fill_clip.position = Vector2(58, 12)
	hp_fill_clip.size = Vector2(HP_FILL_MAX_WIDTH, 60)
	hp_fill_clip.clip_contents = true
	hp_bar_root.add_child(hp_fill_clip)

	var hp_fill_tex = TextureRect.new()
	hp_fill_tex.texture = TEX_HUD_HP_FILL
	hp_fill_clip.add_child(hp_fill_tex)

	# Ornate bronze frame with diamond end-caps
	var hp_frame = TextureRect.new()
	hp_frame.name = "HPFrame"
	hp_frame.texture = TEX_HUD_HP_FRAME
	hp_frame.position = Vector2(0, 0)
	hp_bar_root.add_child(hp_frame)

	# ── 2. Custom Stamina Bar (Top-Left: 10, 31 | Frame 946x87 scaled 0.20 to ~189px) ───
	stamina_bar_root = Control.new()
	stamina_bar_root.name = "StaminaBarRoot"
	stamina_bar_root.position = Vector2(10, 31)
	stamina_bar_root.scale = Vector2(0.20, 0.20)
	hud_container.add_child(stamina_bar_root)

	var sta_bg = TextureRect.new()
	sta_bg.name = "StaminaBackground"
	sta_bg.texture = TEX_HUD_STA_BG
	sta_bg.position = Vector2(59, 13)
	stamina_bar_root.add_child(sta_bg)

	# Stamina ghost bar (trailing gold-green highlight)
	stamina_ghost_clip = Control.new()
	stamina_ghost_clip.name = "StaminaGhostClip"
	stamina_ghost_clip.position = Vector2(59, 13)
	stamina_ghost_clip.size = Vector2(STA_FILL_MAX_WIDTH, 61)
	stamina_ghost_clip.clip_contents = true
	stamina_bar_root.add_child(stamina_ghost_clip)

	var sta_ghost_tex = TextureRect.new()
	sta_ghost_tex.texture = TEX_HUD_STA_FILL
	sta_ghost_tex.modulate = Color(1.8, 1.9, 0.5, 0.85)
	stamina_ghost_clip.add_child(sta_ghost_tex)

	stamina_fill_clip = Control.new()
	stamina_fill_clip.name = "StaminaFillClip"
	stamina_fill_clip.position = Vector2(59, 13)
	stamina_fill_clip.size = Vector2(STA_FILL_MAX_WIDTH, 61)
	stamina_fill_clip.clip_contents = true
	stamina_bar_root.add_child(stamina_fill_clip)

	stamina_fill_tex = TextureRect.new()
	stamina_fill_tex.name = "StaminaFillTex"
	stamina_fill_tex.texture = TEX_HUD_STA_FILL
	stamina_fill_clip.add_child(stamina_fill_tex)

	var sta_frame = TextureRect.new()
	sta_frame.name = "StaminaFrame"
	sta_frame.texture = TEX_HUD_STA_FRAME
	sta_frame.position = Vector2(0, 0)
	stamina_bar_root.add_child(sta_frame)

	# ── 3. Top-Right Minimalist Kill Counter (Sleek, Unobtrusive) ─────────────
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(480, 12)
	score_label.size = Vector2(148, 22)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.text = "KILLS: 0"
	score_label.add_theme_font_override("font", custom_font)
	score_label.add_theme_font_size_override("font_size", 15)
	score_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80, 0.95))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	score_label.add_theme_constant_override("shadow_offset_x", 1)
	score_label.add_theme_constant_override("shadow_offset_y", 1)
	hud_container.add_child(score_label)

	# ── 4. Centered Stage Discovery (Middle of Screen, No Stars or Dashes) ────
	var cur_data = LEVELS_DATA[current_level_idx]
	area_discovery_container = Control.new()
	area_discovery_container.name = "AreaDiscoveryContainer"
	area_discovery_container.position = Vector2(0, 135)
	area_discovery_container.size = Vector2(640, 68)
	area_discovery_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_container.add_child(area_discovery_container)

	stage_name_label = Label.new()
	stage_name_label.name = "StageNameLabel"
	stage_name_label.position = Vector2(0, 0)
	stage_name_label.size = Vector2(640, 36)
	stage_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_name_label.text = cur_data.get("scene_title", "")
	stage_name_label.add_theme_font_override("font", custom_font)
	stage_name_label.add_theme_font_size_override("font_size", 24)
	stage_name_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1.0))
	stage_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	stage_name_label.add_theme_constant_override("shadow_offset_x", 2)
	stage_name_label.add_theme_constant_override("shadow_offset_y", 2)
	area_discovery_container.add_child(stage_name_label)

	stage_level_label = Label.new()
	stage_level_label.name = "StageLevelLabel"
	stage_level_label.position = Vector2(0, 34)
	stage_level_label.size = Vector2(640, 22)
	stage_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_level_label.text = cur_data.get("level_title", "")
	stage_level_label.add_theme_font_override("font", custom_font)
	stage_level_label.add_theme_font_size_override("font_size", 13)
	stage_level_label.add_theme_color_override("font_color", Color(0.82, 0.76, 0.65, 0.90))
	stage_level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	stage_level_label.add_theme_constant_override("shadow_offset_x", 1)
	stage_level_label.add_theme_constant_override("shadow_offset_y", 1)
	area_discovery_container.add_child(stage_level_label)

	trigger_area_discovery()

	# ── 5. Respawn & Checkpoint Message Banner (Clean, Centered) ──────────────
	respawn_label = Label.new()
	respawn_label.name = "RespawnLabel"
	respawn_label.position = Vector2(0, 182)
	respawn_label.size = Vector2(640, 28)
	respawn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	respawn_label.text = ""
	respawn_label.visible = false
	respawn_label.add_theme_font_override("font", custom_font)
	respawn_label.add_theme_font_size_override("font_size", 15)
	respawn_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	respawn_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	respawn_label.add_theme_constant_override("shadow_offset_x", 1)
	respawn_label.add_theme_constant_override("shadow_offset_y", 1)
	hud_container.add_child(respawn_label)

	# ── 5b. Exit Path & Edge Prompt Banner ──────────────────────────────────
	exit_prompt_label = Label.new()
	exit_prompt_label.name = "ExitPromptLabel"
	exit_prompt_label.position = Vector2(0, 185)
	exit_prompt_label.size = Vector2(640, 30)
	exit_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exit_prompt_label.text = ""
	exit_prompt_label.visible = false
	exit_prompt_label.add_theme_font_override("font", custom_font)
	exit_prompt_label.add_theme_font_size_override("font_size", 16)
	exit_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3))
	exit_prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	exit_prompt_label.add_theme_constant_override("shadow_offset_x", 2)
	exit_prompt_label.add_theme_constant_override("shadow_offset_y", 2)
	hud_container.add_child(exit_prompt_label)

	# ── 6. Full-Screen Damage Flash Overlay ──────────────────────────────────
	damage_flash_overlay = ColorRect.new()
	damage_flash_overlay.name = "DamageFlashOverlay"
	damage_flash_overlay.color = Color(0.85, 0.05, 0.10, 0.0)
	damage_flash_overlay.size = Vector2(640, 360)
	damage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(damage_flash_overlay)

	# ── 7. Full-Screen Fade-to-Black Overlay ──────────────────────────────────
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.color = Color(0, 0, 0, 0.0)
	fade_overlay.size = Vector2(640, 360)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(fade_overlay)

	# ── 8. Game Victory Overlay ───────────────────────────────────────────────
	win_overlay = ColorRect.new()
	win_overlay.name = "WinOverlay"
	win_overlay.color = Color(0, 0, 0, 0.78)
	win_overlay.size = Vector2(640, 360)
	win_overlay.visible = false
	ui_layer.add_child(win_overlay)

	win_label = Label.new()
	win_label.name = "WinLabel"
	win_label.text = "ALL LEVELS CONQUERED!\n\nPress R to Play Again"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.size = Vector2(640, 360)
	win_label.add_theme_font_override("font", custom_font)
	win_label.add_theme_font_size_override("font_size", 20)
	win_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	win_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	win_label.add_theme_constant_override("shadow_offset_x", 2)
	win_label.add_theme_constant_override("shadow_offset_y", 2)
	win_overlay.add_child(win_label)

	setup_pause_menu()
	setup_boss_hud()


func setup_boss_hud() -> void:
	boss_hud_root = Control.new()
	boss_hud_root.name = "BossHUDRoot"
	boss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.modulate.a = 0.0
	boss_hud_root.visible = false
	hud_container.add_child(boss_hud_root)

	var custom_font = load("res://alagard.ttf")

	# Title Label
	boss_title_label = Label.new()
	boss_title_label.name = "BossTitle"
	boss_title_label.text = "SINAG-ULAP — THE CORRUPTED MATRIARCH"
	boss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_title_label.add_theme_font_override("font", custom_font)
	boss_title_label.add_theme_font_size_override("font_size", 12)
	boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.72, 1.0))
	boss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	boss_title_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_title_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_title_label.position = Vector2(120, 314)
	boss_title_label.size = Vector2(400, 18)
	boss_hud_root.add_child(boss_title_label)

	# Outer Dark Frame
	var bar_frame = ColorRect.new()
	bar_frame.name = "BossBarFrame"
	bar_frame.position = Vector2(144, 334)
	bar_frame.size = Vector2(352, 12)
	bar_frame.color = Color(0.05, 0.05, 0.07, 0.95)
	boss_hud_root.add_child(bar_frame)

	# Inner Gold Border
	var border_rect = ReferenceRect.new()
	border_rect.position = Vector2(144, 334)
	border_rect.size = Vector2(352, 12)
	border_rect.border_color = Color(0.72, 0.60, 0.35, 0.9)
	border_rect.border_width = 1.0
	border_rect.editor_only = false
	boss_hud_root.add_child(border_rect)

	# Background fill
	var bar_bg = ColorRect.new()
	bar_bg.position = Vector2(145, 335)
	bar_bg.size = Vector2(350, 10)
	bar_bg.color = Color(0.18, 0.05, 0.07, 0.85)
	boss_hud_root.add_child(bar_bg)

	# Ghost lag bar
	boss_hp_ghost = ColorRect.new()
	boss_hp_ghost.name = "BossHPGhost"
	boss_hp_ghost.position = Vector2(145, 335)
	boss_hp_ghost.size = Vector2(350, 10)
	boss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.9)
	boss_hud_root.add_child(boss_hp_ghost)

	# Primary crimson fill
	boss_hp_fill = ColorRect.new()
	boss_hp_fill.name = "BossHPFill"
	boss_hp_fill.position = Vector2(145, 335)
	boss_hp_fill.size = Vector2(350, 10)
	boss_hp_fill.color = Color(0.88, 0.14, 0.18, 1.0)
	boss_hud_root.add_child(boss_hp_fill)


func setup_pause_menu() -> void:
	pause_overlay = Control.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.visible = false
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(pause_overlay)

	var bg_dim = ColorRect.new()
	bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_dim.color = Color(0, 0, 0, 0.72)
	pause_overlay.add_child(bg_dim)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -100.0
	panel.offset_right = 100.0
	panel.offset_top = -105.0
	panel.offset_bottom = 105.0
	panel.size = Vector2(200, 210)
	var panel_sb = StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	panel_sb.border_color = Color(0.72, 0.62, 0.40, 1.0)
	panel_sb.border_width_left = 2
	panel_sb.border_width_right = 2
	panel_sb.border_width_top = 2
	panel_sb.border_width_bottom = 2
	panel_sb.content_margin_left = 16
	panel_sb.content_margin_right = 16
	panel_sb.content_margin_top = 16
	panel_sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", panel_sb)
	pause_overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var custom_font = load("res://alagard.ttf")

	var header = Label.new()
	header.text = "PAUSED"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_override("font", custom_font)
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
	header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	header.add_theme_constant_override("shadow_offset_x", 1)
	header.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(header)

	var sep = Control.new()
	sep.custom_minimum_size = Vector2(0, 2)
	vbox.add_child(sep)

	var btn_resume = Button.new()
	btn_resume.text = "RESUME"
	btn_resume.custom_minimum_size = Vector2(160, 28)
	btn_resume.add_theme_font_override("font", custom_font)
	btn_resume.add_theme_font_size_override("font_size", 15)
	btn_resume.pressed.connect(toggle_pause)
	vbox.add_child(btn_resume)

	var btn_restart = Button.new()
	btn_restart.text = "RESTART LEVEL"
	btn_restart.custom_minimum_size = Vector2(160, 28)
	btn_restart.add_theme_font_override("font", custom_font)
	btn_restart.add_theme_font_size_override("font_size", 15)
	btn_restart.pressed.connect(func():
		toggle_pause()
		load_current_level()
		spawn_level_enemies()
		respawn_player_at_checkpoint()
	)
	vbox.add_child(btn_restart)

	var btn_menu = Button.new()
	btn_menu.text = "MAIN MENU"
	btn_menu.custom_minimum_size = Vector2(160, 28)
	btn_menu.add_theme_font_override("font", custom_font)
	btn_menu.add_theme_font_size_override("font_size", 15)
	btn_menu.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	vbox.add_child(btn_menu)


func toggle_pause() -> void:
	if is_game_won or is_transitioning:
		return
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	if pause_overlay:
		pause_overlay.visible = is_paused


func toggle_ui() -> void:
	set_ui_visible(!is_ui_visible)


func set_ui_visible(p_visible: bool) -> void:
	is_ui_visible = p_visible
	if not is_instance_valid(hud_container):
		return
	
	var tween = create_tween()
	if is_ui_visible:
		hud_container.visible = true
		tween.tween_property(hud_container, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(hud_container, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(func():
			if not is_ui_visible and is_instance_valid(hud_container):
				hud_container.visible = false
		)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()
		elif event.keycode == KEY_H:
			toggle_ui()
		elif event.keycode == KEY_1 or event.keycode == KEY_KP_1:
			jump_to_level(0)  # Jump directly to Forest Scene (Level 1-1)
		elif event.keycode == KEY_2 or event.keycode == KEY_KP_2:
			jump_to_level(3)  # Jump directly to Rice Field Scene (Level 2-1)
		elif event.keycode == KEY_3 or event.keycode == KEY_KP_3:
			jump_to_level(6)  # Jump directly to Stage 3: Rainy Forest (Level 3-1: Drenched Foothills)
		elif event.keycode == KEY_N or event.keycode == KEY_PAGEDOWN:
			jump_to_level((current_level_idx + 1) % LEVELS_DATA.size())
		elif event.keycode == KEY_P or event.keycode == KEY_PAGEUP:
			jump_to_level((current_level_idx - 1 + LEVELS_DATA.size()) % LEVELS_DATA.size())


func jump_to_level(target_idx: int) -> void:
	is_transitioning = false
	if is_boss_active:
		is_boss_active = false
		clear_boss_arena_barriers()
		if is_instance_valid(boss_instance):
			boss_instance.queue_free()
			boss_instance = null
		if is_instance_valid(boss_hud_root):
			boss_hud_root.visible = false
			boss_hud_root.modulate.a = 0.0
	current_level_idx = clamp(target_idx, 0, LEVELS_DATA.size() - 1)
	load_current_level()
	spawn_level_enemies()
	respawn_player_at_checkpoint()
	if player:
		player.set_physics_process(true)
	if fade_overlay:
		fade_overlay.color = Color(0, 0, 0, 0.0)
	is_game_won = false
	if win_overlay:
		win_overlay.visible = false
	trigger_area_discovery()
	update_score_hud()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		restart_game()
		return

	if is_game_won:
		return

	# Micro hit-stop recovery
	if hit_stop_timer > 0.0:
		hit_stop_timer -= delta / max(0.01, Engine.time_scale)
		if hit_stop_timer <= 0.0:
			hit_stop_timer = 0.0
			Engine.time_scale = 1.0

	if ambient_particles and camera:
		ambient_particles.global_position = camera.global_position

	if camera:
		var rain_spawn: Vector2 = camera.global_position + Vector2(60.0, -190.0)
		if rain_particles:
			rain_particles.global_position = rain_spawn
		if rain_particles_fg:
			rain_particles_fg.global_position = rain_spawn
		if rain_particles_bg:
			rain_particles_bg.global_position = rain_spawn
		if rain_splashes:
			rain_splashes.global_position = Vector2(camera.global_position.x, 292.0)
		if storm_fog:
			storm_fog.global_position = Vector2(camera.global_position.x, 265.0)

	update_weather_and_lightning(delta)
	update_forest_bird_ambience(delta)

	if player:
		# Camera position follow
		var target_x: float = clamp(player.global_position.x, 320.0, LEVEL_WIDTH - 320.0)
		camera.global_position = Vector2(target_x, 180.0)

		# Screen shake decay
		if trauma > 0.0:
			trauma = max(0.0, trauma - TRAUMA_DECAY * delta)
			var shake: float = trauma * trauma
			var offset_x = (randf() * 2.0 - 1.0) * MAX_SHAKE_OFFSET * shake
			var offset_y = (randf() * 2.0 - 1.0) * MAX_SHAKE_OFFSET * shake
			var angle = (randf() * 2.0 - 1.0) * MAX_SHAKE_ANGLE * shake
			camera.offset = Vector2(offset_x, offset_y)
			camera.rotation = angle
		else:
			camera.offset = Vector2.ZERO
			camera.rotation = 0.0

		# Distance traversed tracking
		if not is_transitioning:
			total_distance_traversed += abs(player.global_position.x - last_player_x)
			last_player_x = player.global_position.x

			# Puddle splash reaction while running over puddles in storm
			if current_storm_intensity > 0.3 and abs(player.velocity.x) > 35.0:
				for p in puddles_list:
					if is_instance_valid(p) and abs(player.global_position.x - p.global_position.x) < 22.0:
						if rain_splashes:
							rain_splashes.global_position = Vector2(player.global_position.x, player.global_position.y)
						break

		update_score_hud()

		# Map Edge Level Transition Trigger
		if not is_transitioning:
			if current_level_idx == 10:
				if not is_boss_active and player.global_position.x >= 3800.0:
					start_boss_encounter()
			elif player.global_position.x >= MAP_TRANSITION_EDGE_X:
				start_level_transition()

		# Water hazard / pit drop detection (falling off ground)
		if not is_transitioning and not is_player_dead:
			if player.global_position.y > 360.0:
				_on_player_died()

	# Respawn Banner Timer
	if respawn_msg_timer > 0.0:
		respawn_msg_timer -= delta
		var alpha: float = clamp(respawn_msg_timer / 0.5, 0.0, 1.0)
		respawn_label.modulate = Color(1, 1, 1, alpha)
		if respawn_msg_timer <= 0.0:
			respawn_label.visible = false
			is_player_dead = false

	# Atmospheric Stage Discovery Fade
	if area_title_timer > 0.0:
		area_title_timer -= delta
		var alpha: float = 1.0
		if area_title_timer > 2.4:
			alpha = clamp((AREA_TITLE_DURATION - area_title_timer) / 0.6, 0.0, 1.0)
		elif area_title_timer < 0.6:
			alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
		else:
			alpha = 1.0
		if area_discovery_container:
			area_discovery_container.modulate = Color(1, 1, 1, alpha)
			if area_title_timer <= 0.0:
				area_discovery_container.visible = false
		elif area_title_label:
			area_title_label.modulate = Color(1, 1, 1, alpha)
			if area_title_timer <= 0.0:
				area_title_label.visible = false

	# Exit prompt banner decay
	if exit_prompt_timer > 0.0:
		exit_prompt_timer -= delta
		if exit_prompt_timer < 0.6:
			if is_instance_valid(exit_prompt_label):
				exit_prompt_label.modulate.a = clamp(exit_prompt_timer / 0.6, 0.0, 1.0)
		if exit_prompt_timer <= 0.0 and is_instance_valid(exit_prompt_label):
			exit_prompt_label.visible = false


func update_weather_and_lightning(delta: float) -> void:
	if is_game_won:
		return

	var current_data = LEVELS_DATA[current_level_idx]
	var current_theme: String = current_data.get("theme", "")
	var is_lvl_2_3: bool = (current_level_idx == 5)
	var is_rainy_forest: bool = (current_theme == "Rainy Forest")

	# Dynamic Wind Squalls Variation
	var time_sec: float = Time.get_ticks_msec() / 1000.0
	current_wind_x = -0.32 + sin(time_sec * 0.75) * 0.16 + sin(time_sec * 1.85) * 0.08
	var wind_dir: Vector2 = Vector2(current_wind_x, 1.0).normalized()
	if rain_particles:
		rain_particles.direction = wind_dir
	if rain_particles_fg:
		rain_particles_fg.direction = wind_dir
	if rain_particles_bg:
		rain_particles_bg.direction = wind_dir

	# Level 2-3 Dynamic Storm Transition
	if is_lvl_2_3:
		if player:
			# Between x=3700 and 4700, smooth transition into storm
			var progress: float = clamp((player.global_position.x - 3700.0) / 1000.0, 0.0, 1.0)
			current_storm_intensity = progress

			# Sky sprite modulate
			if sky_sprite:
				sky_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.35, 0.40, 0.52, 1.0), progress)

			# World lighting
			base_modulate_color = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.29, 0.32, 0.43, 1.0), progress)

			# Multi-layer rain particles
			if progress > 0.04:
				if rain_particles:
					rain_particles.emitting = true
					rain_particles.modulate = Color(1.0, 1.0, 1.0, progress)
				if rain_particles_bg:
					rain_particles_bg.emitting = true
					rain_particles_bg.modulate = Color(1.0, 1.0, 1.0, progress)
				if rain_particles_fg:
					rain_particles_fg.emitting = (progress > 0.28)
					rain_particles_fg.modulate = Color(1.0, 1.0, 1.0, clamp((progress - 0.28) / 0.72, 0.0, 1.0))
				if rain_splashes:
					rain_splashes.emitting = (progress > 0.20)
					rain_splashes.modulate = Color(1.0, 1.0, 1.0, clamp((progress - 0.20) / 0.80, 0.0, 1.0))
				if storm_fog:
					storm_fog.emitting = (progress > 0.35)
					storm_fog.modulate = Color(1.0, 1.0, 1.0, clamp((progress - 0.35) / 0.65, 0.0, 1.0))
			else:
				if rain_particles: rain_particles.emitting = false
				if rain_particles_fg: rain_particles_fg.emitting = false
				if rain_particles_bg: rain_particles_bg.emitting = false
				if rain_splashes: rain_splashes.emitting = false
				if storm_fog: storm_fog.emitting = false

			# Storm vignette
			if storm_vignette:
				storm_vignette.modulate.a = progress * 0.65

			# Rain ambient motes
			if ambient_particles:
				if progress > 0.3:
					ambient_particles.color = Color(1.0, 0.85, 0.35, 0.65).lerp(Color(0.8, 0.9, 1.0, 0.35), progress)

			# Distant sheet lightning in 2-3 near the end (progress >= 0.55)
			if progress >= 0.55 and not is_transitioning:
				sheet_lightning_timer -= delta
				if sheet_lightning_timer <= 0.0:
					trigger_sheet_lightning(5.5, 9.5)

			# Dangerous ground lightning strikes near the exit (progress >= 0.70)
			if progress >= 0.70 and not is_transitioning:
				lightning_timer -= delta
				if lightning_timer <= 0.0:
					spawn_lightning_strike(8.0, 12.0)
	elif is_rainy_forest:
		current_storm_intensity = 1.0
		var sub_level: float = float(current_level_idx - 6) # 0 to 4
		if rain_particles and not rain_particles.emitting:
			rain_particles.emitting = true
			rain_particles.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if rain_particles_fg and not rain_particles_fg.emitting:
			rain_particles_fg.emitting = true
			rain_particles_fg.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if rain_particles_bg and not rain_particles_bg.emitting:
			rain_particles_bg.emitting = true
			rain_particles_bg.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if rain_splashes and not rain_splashes.emitting:
			rain_splashes.emitting = true
			rain_splashes.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if storm_fog and not storm_fog.emitting:
			storm_fog.emitting = true
			storm_fog.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if storm_vignette:
			storm_vignette.modulate.a = 0.55 + sub_level * 0.07

		if not is_transitioning:
			# Sheet lightning (background sky flashes & rolling rumblers)
			sheet_lightning_timer -= delta
			if sheet_lightning_timer <= 0.0:
				var s_min: float = max(3.0, 6.5 - sub_level * 0.8)
				var s_max: float = max(5.0, 10.0 - sub_level * 1.0)
				trigger_sheet_lightning(s_min, s_max)

			# Ground hazard strikes
			lightning_timer -= delta
			if lightning_timer <= 0.0:
				var min_wait: float = max(3.0, 7.5 - sub_level * 1.0)
				var max_wait: float = max(5.0, 11.5 - sub_level * 1.2)
				spawn_lightning_strike(min_wait, max_wait)
	else:
		current_storm_intensity = 0.0
		if rain_particles and rain_particles.emitting:
			rain_particles.emitting = false
		if rain_particles_fg and rain_particles_fg.emitting:
			rain_particles_fg.emitting = false
		if rain_particles_bg and rain_particles_bg.emitting:
			rain_particles_bg.emitting = false
		if rain_splashes and rain_splashes.emitting:
			rain_splashes.emitting = false
		if storm_fog and storm_fog.emitting:
			storm_fog.emitting = false
		if storm_vignette and storm_vignette.modulate.a != 0.0:
			storm_vignette.modulate.a = 0.0
		if sky_sprite and sky_sprite.modulate != Color(1, 1, 1, 1):
			sky_sprite.modulate = Color(1, 1, 1, 1)

	if lens_rain_overlay:
		lens_rain_overlay.set_storm_active(is_rainy_forest or (is_lvl_2_3 and current_storm_intensity > 0.25), current_storm_intensity)

	# Delayed thunder audio rumble
	if thunder_rumble_timer > 0.0:
		thunder_rumble_timer -= delta
		if thunder_rumble_timer <= 0.0:
			if is_inside_tree() and thunder_audio_player and thunder_audio_player.is_inside_tree() and thunder_audio_player.stream:
				thunder_audio_player.pitch_scale = randf_range(0.26, 0.34)
				thunder_audio_player.volume_db = randf_range(-3.5, 0.5)
				thunder_audio_player.play()
			trauma = min(1.0, trauma + 0.16)

	# Multi-phase lightning flash decay & smooth atmospheric tracking
	if lightning_flash_timer > 0.0:
		lightning_flash_timer -= delta
		var p: float = 1.0 - clamp(lightning_flash_timer / 0.24, 0.0, 1.0)
		var flash_mult: float = 1.0
		if p < 0.22:
			flash_mult = 1.0 # Peak return stroke
		elif p < 0.42:
			flash_mult = 0.32 # Micro dip between strokes
		elif p < 0.68:
			flash_mult = 0.82 # Secondary restrike
		else:
			flash_mult = clamp((1.0 - p) / 0.32, 0.0, 1.0) # Dissipation

		if canvas_modulate:
			var flash_col := Color(1.85, 1.95, 2.3, 1.0)
			canvas_modulate.color = base_modulate_color.lerp(flash_col, flash_mult * lightning_flash_intensity)
	elif canvas_modulate:
		canvas_modulate.color = canvas_modulate.color.lerp(base_modulate_color, clamp(delta * 6.0, 0.0, 1.0))


func reset_lightning_timer(min_sec: float = 7.0, max_sec: float = 11.0) -> void:
	lightning_timer = randf_range(min_sec, max_sec)


func trigger_sheet_lightning(min_wait: float, max_wait: float) -> void:
	sheet_lightning_timer = randf_range(min_wait, max_wait)
	lightning_flash_timer = 0.16
	lightning_flash_intensity = 0.68
	thunder_rumble_timer = randf_range(0.35, 0.65) # Speed of sound delay
	flash_puddles(0.18)
	if sky_sprite:
		var orig_mod: Color = sky_sprite.modulate
		sky_sprite.modulate = Color(1.8, 1.9, 2.3, 1.0)
		var tw := create_tween()
		tw.tween_property(sky_sprite, "modulate", orig_mod, 0.18)


func spawn_lightning_strike(min_wait: float, max_wait: float) -> void:
	reset_lightning_timer(min_wait, max_wait)
	if not player or not lightning_container:
		return

	# Choose strike X in player's vicinity
	var offset_x: float = randf_range(-140.0, 220.0)
	var strike_x: float = clamp(player.global_position.x + offset_x, 200.0, LEVEL_WIDTH - 200.0)
	var strike_y: float = get_ground_y_at_x(strike_x)

	var hazard = LightningHazardScript.new()
	hazard.target_position = Vector2(strike_x, strike_y)
	hazard.strike_occurred.connect(_on_lightning_hazard_struck)
	lightning_container.add_child(hazard)


func _on_lightning_hazard_struck(strike_pos: Vector2, _damage: int) -> void:
	lightning_flash_timer = 0.24
	lightning_flash_intensity = 1.0
	apply_hit_stop(0.045)
	flash_puddles(0.26)

	if player and camera:
		var dist: float = abs(strike_pos.x - player.global_position.x)
		var impact_ratio: float = 1.0 - clamp(dist / 450.0, 0.0, 1.0)
		trauma = min(1.0, trauma + lerp(0.60, 1.0, impact_ratio))
		camera.offset.y -= randf_range(8.0, 14.0) * impact_ratio
	else:
		trauma = min(1.0, trauma + 0.65)

	if sky_sprite:
		var orig_mod: Color = sky_sprite.modulate
		sky_sprite.modulate = Color(2.6, 2.9, 3.4, 1.0)
		var tw := create_tween()
		tw.tween_property(sky_sprite, "modulate", orig_mod, 0.20)


func trigger_area_discovery(stage_name: String = "", sub_title: String = "") -> void:
	var cur_data = LEVELS_DATA[current_level_idx]
	var display_stage: String = cur_data.get("scene_title", "")
	var display_sub: String = cur_data.get("level_title", "")

	if stage_name != "" and sub_title != "":
		display_stage = stage_name
		display_sub = sub_title
	elif stage_name != "":
		if stage_name != cur_data.get("full_title", ""):
			display_stage = stage_name
			display_sub = ""

	if stage_name_label:
		stage_name_label.text = display_stage
	if stage_level_label:
		stage_level_label.text = display_sub
	if area_title_label:
		area_title_label.text = "%s  %s" % [display_stage, display_sub]

	area_title_timer = AREA_TITLE_DURATION
	if area_discovery_container:
		area_discovery_container.visible = true
		area_discovery_container.modulate = Color(1, 1, 1, 0)
	elif area_title_label:
		area_title_label.visible = true
		area_title_label.modulate = Color(1, 1, 1, 0)


# ── Fade-to-Black Level Transition ─────────────────────────────────────────────
func start_level_transition() -> void:
	if is_transitioning or is_game_won:
		return
	is_transitioning = true
	show_exit_banner("Area Cleared — Proceeding", Color(1.0, 0.9, 0.3, 1.0))

	if player:
		if player.has_method("start_walk_off"):
			player.start_walk_off()
		else:
			player.velocity = Vector2.ZERO
			player.set_physics_process(false)

	# Fade out to black over 0.5s
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.50)
	tween.tween_callback(Callable(self, "_on_fade_out_complete"))


func _on_fade_out_complete() -> void:
	# Check if all levels completed
	if current_level_idx >= LEVELS_DATA.size() - 1:
		trigger_win()
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
		return

	# Advance to next level
	current_level_idx += 1
	load_current_level()
	spawn_level_enemies()

	# Reposition player to spawn point and restore full health & stamina
	if player:
		player.global_position = SPAWN_POS
		player.velocity = Vector2.ZERO
		last_player_x = SPAWN_POS.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()
		camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, LEVEL_WIDTH - 320.0), 180.0)

	# Fade in from black over 0.5s
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
	tween.tween_callback(Callable(self, "_on_fade_in_complete"))


func _on_fade_in_complete() -> void:
	is_transitioning = false
	if player:
		player.set_physics_process(true)
	trigger_area_discovery()


# ── Score HUD ──────────────────────────────────────────────────────────────────
func update_score_hud() -> void:
	var total_kills = aswang_kills + skeleton_kills
	if score_label:
		score_label.text = "KILLS: %d" % total_kills


# ── Player Death & Respawn State ───────────────────────────────────────────────
func _on_player_died() -> void:
	death_count += 1
	is_player_dead = true
	respawn_player_at_checkpoint()
	show_respawn_message()


func respawn_player_at_checkpoint() -> void:
	if is_boss_active:
		is_boss_active = false
		clear_boss_arena_barriers()
		if is_instance_valid(boss_instance):
			boss_instance.queue_free()
			boss_instance = null
		if is_instance_valid(boss_hud_root):
			boss_hud_root.visible = false
			boss_hud_root.modulate.a = 0.0
		play_bgm(ProceduralAudio.get_tempest_ambient(), "tempest", 1.0)

	if player:
		player.global_position = SPAWN_POS
		player.velocity = Vector2.ZERO
		last_player_x = player.global_position.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()


func show_respawn_message() -> void:
	respawn_label.text = "Respawned at Checkpoint: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
	respawn_label.modulate = Color(1, 1, 1, 1)
	respawn_label.visible = true
	respawn_msg_timer = RESPAWN_MSG_DURATION


# ── Game Victory State ─────────────────────────────────────────────────────────
func trigger_win() -> void:
	if is_game_won:
		return
	is_game_won = true
	is_transitioning = false
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

	run_end_time = Time.get_ticks_msec() / 1000.0
	var elapsed: float = run_end_time - run_start_time
	var minutes: int = int(elapsed) / 60
	var seconds: int = int(elapsed) % 60
	var dist_m: int = int(total_distance_traversed / 32.0)
	var total_kills = aswang_kills + skeleton_kills

	win_label.text = (
		"✦ ALL LEVELS CONQUERED! ✦\n\n"
		+ "Time:        %02d:%02d\n" % [minutes, seconds]
		+ "Distance:     %d m\n" % dist_m
		+ "Kills:        %d\n" % total_kills
		+ "Deaths:       %d\n" % death_count
		+ "Completed:    %d / %d Levels\n\n" % [LEVELS_DATA.size(), LEVELS_DATA.size()]
		+ "Press R to Play Again"
	)
	win_overlay.visible = true


func restart_game() -> void:
	is_game_won = false
	is_player_dead = false
	is_transitioning = false
	win_overlay.visible = false
	if fade_overlay:
		fade_overlay.color = Color(0, 0, 0, 0.0)

	if lightning_container:
		for child in lightning_container.get_children():
			child.queue_free()
	lightning_flash_timer = 0.0
	current_storm_intensity = 0.0

	current_level_idx = 0
	load_current_level()
	spawn_level_enemies()

	total_distance_traversed = 0.0
	death_count = 0
	aswang_kills = 0
	skeleton_kills = 0
	run_start_time = Time.get_ticks_msec() / 1000.0
	run_end_time = 0.0

	respawn_label.visible = false
	respawn_msg_timer = 0.0

	if is_instance_valid(hp_fill_tween) and hp_fill_tween.is_valid():
		hp_fill_tween.kill()
	if is_instance_valid(stamina_fill_tween) and stamina_fill_tween.is_valid():
		stamina_fill_tween.kill()
	update_score_hud()
	respawn_player_at_checkpoint()
	if player:
		player.set_physics_process(true)
	trigger_area_discovery()


# ── Combat Event Signal Handlers & Juice ──────────────────────────────────────
func _on_player_hp_changed(current: int, max_hp: int) -> void:
	if not is_instance_valid(hp_fill_clip) or not is_instance_valid(hp_ghost_clip):
		return
	
	var ratio: float = clamp(float(current) / float(max_hp), 0.0, 1.0)
	var target_width: float = HP_FILL_MAX_WIDTH * ratio
	var was_damage: bool = target_width < hp_fill_clip.size.x
	
	# 1. Main red weave fill smoothly tweens down on damage over 0.25s (or snaps/grows on heal)
	if is_instance_valid(hp_fill_tween) and hp_fill_tween.is_valid():
		hp_fill_tween.kill()
	
	if was_damage:
		hp_fill_tween = create_tween()
		hp_fill_tween.tween_property(hp_fill_clip, "size:x", target_width, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		hp_fill_clip.size.x = target_width
	
	# 2. Ghost damage bar: delays 0.30s, then smoothly catches up over 0.40s
	if is_instance_valid(hp_ghost_tween) and hp_ghost_tween.is_valid():
		hp_ghost_tween.kill()
	
	if was_damage:
		hp_ghost_tween = create_tween()
		hp_ghost_tween.tween_interval(0.30)
		hp_ghost_tween.tween_property(hp_ghost_clip, "size:x", target_width, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		# Healing: ghost bar immediately matches new health
		hp_ghost_clip.size.x = target_width
	
	# 3. Critical low health heartbeat pulse (at 1 HP)
	if is_instance_valid(hp_pulse_tween) and hp_pulse_tween.is_valid():
		hp_pulse_tween.kill()
	
	if current == 1:
		hp_pulse_tween = create_tween().set_loops()
		hp_pulse_tween.tween_property(hp_bar_root, "modulate", Color(1.6, 0.4, 0.4, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
		hp_pulse_tween.tween_property(hp_bar_root, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
	else:
		if is_instance_valid(hp_bar_root):
			hp_bar_root.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_player_stamina_changed(current: float, max_stamina: float) -> void:
	if not is_instance_valid(stamina_fill_clip) or not is_instance_valid(stamina_ghost_clip):
		return
	
	var ratio: float = clamp(current / max_stamina, 0.0, 1.0)
	var target_width: float = STA_FILL_MAX_WIDTH * ratio
	var was_drain: bool = target_width < stamina_fill_clip.size.x
	
	# 1. Main stamina fill smoothly tweens down on drain over 0.18s
	if is_instance_valid(stamina_fill_tween) and stamina_fill_tween.is_valid():
		stamina_fill_tween.kill()
	
	if was_drain:
		stamina_fill_tween = create_tween()
		stamina_fill_tween.tween_property(stamina_fill_clip, "size:x", target_width, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		stamina_fill_clip.size.x = target_width
	
	# 2. Trailing ghost bar animation
	if is_instance_valid(stamina_ghost_tween) and stamina_ghost_tween.is_valid():
		stamina_ghost_tween.kill()
	
	if was_drain:
		stamina_ghost_tween = create_tween()
		stamina_ghost_tween.tween_interval(0.20)
		stamina_ghost_tween.tween_property(stamina_ghost_clip, "size:x", target_width, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		stamina_ghost_clip.size.x = target_width
	
	if is_instance_valid(stamina_fill_tex):
		if current <= 25.0:
			stamina_fill_tex.modulate = Color(1.5, 0.8, 0.4, 1.0) # Low stamina amber warning
		else:
			stamina_fill_tex.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_player_hit_landed(is_heavy: bool, _hit_pos: Vector2) -> void:
	if is_heavy:
		add_screen_shake(0.40)
		trigger_hit_stop(0.09)
	else:
		add_screen_shake(0.20)
		trigger_hit_stop(0.05)


func _on_player_riposte_performed(_hit_pos: Vector2) -> void:
	add_screen_shake(0.65)
	trigger_hit_stop(0.12)
	if is_instance_valid(player):
		VFX.spawn_floating_text(self, player.global_position + Vector2(0, -62.0), "CRITICAL RIPOSTE!", Color(1.0, 0.25, 0.2), 16, true)


func _on_player_damage_taken(amount: int, is_blocked: bool) -> void:
	if is_blocked and amount == 0:
		add_screen_shake(0.40)
		trigger_hit_stop(0.08)
		trigger_parry_slowmo(0.16)
		if is_instance_valid(player):
			VFX.spawn_floating_text(self, player.global_position + Vector2(0, -56.0), "PERFECT PARRY!", Color(1.0, 0.88, 0.25), 15, true)
		if is_instance_valid(hp_bar_root):
			hp_bar_root.modulate = Color(1.8, 1.6, 0.4, 1.0)
			get_tree().create_timer(0.20).timeout.connect(func():
				if is_instance_valid(hp_bar_root):
					hp_bar_root.modulate = Color(1, 1, 1, 1)
			)
	elif is_blocked:
		add_screen_shake(0.30)
		trigger_hit_stop(0.06)
		if is_instance_valid(player):
			VFX.spawn_floating_text(self, player.global_position + Vector2(0, -50.0), "GUARD", Color(0.7, 0.8, 1.0), 13, false)
		if is_instance_valid(hp_bar_root):
			hp_bar_root.modulate = Color(1.4, 0.7, 0.4, 1.0)
			get_tree().create_timer(0.15).timeout.connect(func():
				if is_instance_valid(hp_bar_root):
					hp_bar_root.modulate = Color(1, 1, 1, 1)
			)
	else:
		add_screen_shake(0.55)
		trigger_hit_stop(0.08)
		if is_instance_valid(player):
			VFX.spawn_floating_text(self, player.global_position + Vector2(0, -45.0), "-%d" % amount, Color(1.0, 0.2, 0.2), 14, false)
		if is_instance_valid(hp_bar_root):
			hp_bar_root.modulate = Color(1.8, 0.4, 0.4, 1.0)
			get_tree().create_timer(0.20).timeout.connect(func():
				if is_instance_valid(hp_bar_root):
					hp_bar_root.modulate = Color(1, 1, 1, 1)
			)
		# Red visceral damage screen pulse
		if is_instance_valid(damage_flash_overlay):
			damage_flash_overlay.color = Color(0.85, 0.05, 0.10, 0.28)
			var tween = create_tween()
			tween.tween_property(damage_flash_overlay, "color:a", 0.0, 0.25)


func add_screen_shake(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)


func trigger_hit_stop(duration: float) -> void:
	Engine.time_scale = 0.05
	get_tree().create_timer(duration, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0
	)


func trigger_parry_slowmo(duration: float = 0.16) -> void:
	Engine.time_scale = 0.28
	get_tree().create_timer(duration, true, false, true).timeout.connect(func():
		if Engine.time_scale < 1.0 and not is_game_won and not is_transitioning:
			Engine.time_scale = 1.0
	)


# ── Boss Encounter Methods (Level 3-5 Climax) ──────────────────────────────────
func start_boss_encounter() -> void:
	if is_boss_active:
		return
	is_boss_active = true

	# Switch BGM to climactic boss battle music
	play_bgm(ProceduralAudio.get_boss_battle_music(), "boss", 0.5)

	# Show boss HUD with smooth fade-in
	if is_instance_valid(boss_hud_root):
		boss_hud_root.visible = true
		var tw = create_tween()
		tw.tween_property(boss_hud_root, "modulate:a", 1.0, 1.2)

	# Lock the arena with physical barrier walls
	create_boss_arena_barriers()

	# Spawn the Matriarch Boss
	boss_instance = AswangBossScript.new()
	boss_instance.name = "CorruptedMatriarchBoss"
	boss_instance.global_position = Vector2(4400.0, 260.0)
	boss_instance.boss_hp_changed.connect(_on_boss_hp_changed)
	boss_instance.boss_phase_changed.connect(_on_boss_phase_changed)
	boss_instance.boss_died.connect(_on_boss_died)
	boss_instance.boss_summon_requested.connect(_on_boss_summon_requested)
	boss_instance.boss_lightning_requested.connect(_on_boss_lightning_requested)
	enemies_container.add_child(boss_instance)

	add_screen_shake(0.65)


func create_boss_arena_barriers() -> void:
	clear_boss_arena_barriers()

	# Lock player between x = 3760 and x = 5080
	var barrier_x_positions = [3760.0, 5080.0]
	for bx in barrier_x_positions:
		var barrier = StaticBody2D.new()
		barrier.name = "BossArenaBarrier_%d" % int(bx)
		barrier.collision_layer = 1
		barrier.collision_mask = 2 # Blocks player (Layer 2)

		var col = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(32.0, 600.0)
		col.shape = rect_shape
		barrier.add_child(col)
		barrier.global_position = Vector2(bx, 150.0)
		add_child(barrier)
		boss_arena_barriers.append(barrier)


func clear_boss_arena_barriers() -> void:
	for b in boss_arena_barriers:
		if is_instance_valid(b):
			b.queue_free()
	boss_arena_barriers.clear()


func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 350.0 * pct

	boss_hp_fill.size.x = target_w

	if is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
		boss_hp_tween.kill()
	boss_hp_tween = create_tween()
	boss_hp_tween.tween_interval(0.25)
	boss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_boss_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		add_screen_shake(0.85)
		trigger_parry_slowmo(0.35)
		if is_instance_valid(boss_title_label):
			boss_title_label.text = "SINAG-ULAP — THE ENRAGED MATRIARCH"
			boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(1.2, 0.2, 0.2, 1.0)
		if is_instance_valid(damage_flash_overlay):
			damage_flash_overlay.color = Color(1.0, 0.15, 0.15, 0.45)
			var tw = create_tween()
			tw.tween_property(damage_flash_overlay, "color:a", 0.0, 0.55)


func _on_boss_summon_requested(pos: Vector2) -> void:
	if not is_instance_valid(enemies_container) or not is_boss_active:
		return
	var minion = AswangScript.new()
	minion.global_position = pos
	minion.health = 1
	minion.modulate = Color(0.65, 0.25, 0.45, 0.85)
	minion.aswang_died.connect(_on_aswang_died)
	enemies_container.add_child(minion)
	VFX.spawn_guard_impact(self, pos + Vector2(0, -30))


func _on_boss_lightning_requested(pos: Vector2) -> void:
	if not is_instance_valid(lightning_container) or not is_boss_active:
		return
	var strike = LightningHazardScript.new()
	strike.global_position = pos
	lightning_container.add_child(strike)


func _on_boss_died(_boss: CharacterBody2D) -> void:
	add_screen_shake(1.0)
	trigger_hit_stop(0.40)
	trigger_parry_slowmo(0.60)

	clear_boss_arena_barriers()

	if is_instance_valid(boss_hud_root):
		var tw_hud = create_tween()
		tw_hud.tween_property(boss_hud_root, "modulate:a", 0.0, 1.2)
		tw_hud.tween_callback(func():
			if is_instance_valid(boss_hud_root):
				boss_hud_root.visible = false
		)

	aswang_kills += 1
	update_score_hud()

	# Grand white flash & thunder
	if is_instance_valid(damage_flash_overlay):
		damage_flash_overlay.color = Color(1.0, 1.0, 1.0, 0.75)
		var tw_flash = create_tween()
		tw_flash.tween_property(damage_flash_overlay, "color:a", 0.0, 1.4)

	# Wait 2.8s for death animation and celebratory stillness before victory screen
	get_tree().create_timer(2.8).timeout.connect(func():
		trigger_win()
	)

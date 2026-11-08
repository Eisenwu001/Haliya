extends Node2D

const AssetsScript = preload("res://scripts/assets.gd")
const PlayerScript = preload("res://scripts/player.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const SantelmoScript = preload("res://scripts/santelmo.gd")
const SettingsMenuScript = preload("res://scripts/settings_menu.gd")
const BestiaryCodexUIScript = preload("res://scripts/bestiary_codex_ui.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")
const MetaProgression = preload("res://scripts/meta_progression.gd")
const GameSettings = preload("res://scripts/game_settings.gd")
const LevelBuilderScript = preload("res://scripts/level_builder.gd")
const LightningHazardScript = preload("res://scripts/lightning_hazard.gd")
const AswangBossScript = preload("res://scripts/aswang_boss.gd")
const BakunawaBossScript = preload("res://scripts/bakunawa_boss.gd")
const ForestBruteMinibossScript = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardMinibossScript = preload("res://scripts/mayon_vanguard_miniboss.gd")
const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const UpgradeSelectUIScript = preload("res://scripts/upgrade_select_ui.gd")
const GameOverUIScript = preload("res://scripts/game_over_ui.gd")
const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const UIConstants = preload("res://ui/theme/ui_theme_constants.gd")
const PauseMenuScreenScene = preload("res://ui/screens/pause_menu_screen.tscn")
const LevelProgressBarScript = preload("res://ui/components/level_progress_bar.gd")
var upgrade_select_ui: CanvasLayer
var game_over_ui: CanvasLayer

static var start_level_idx: int = 0
static var restore_saved_run: bool = false

# ── Level Progression Configuration (13 Total Levels) ─────────────────────────
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
		"theme": "Rice Field",
		"scene_title": "The Caldera Foothills",
		"level_title": "Level 2-4",
		"full_title": "Rice Field Scene — Level 2-4: The Caldera Foothills",
		"scene_path": "res://scenes/rice_field/level_2_4.tscn"
	},
	{
		"theme": "Rice Field",
		"scene_title": "The Burning Kiln Village",
		"level_title": "Level 2-5",
		"full_title": "Rice Field Scene — Level 2-5: The Burning Kiln Village",
		"scene_path": "res://scenes/rice_field/level_2_5.tscn"
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
	},
	{
		"theme": "Cave",
		"scene_title": "Bioluminescent Threshold",
		"level_title": "Level 4-1",
		"full_title": "Lapis Caverns — Level 4-1: Bioluminescent Threshold",
		"scene_path": "res://scenes/cave/level_4_1.tscn"
	},
	{
		"theme": "Cave",
		"scene_title": "Sunken Lunar Ruins",
		"level_title": "Level 4-2",
		"full_title": "Lapis Caverns — Level 4-2: Sunken Lunar Ruins",
		"scene_path": "res://scenes/cave/level_4_2.tscn"
	},
	{
		"theme": "Cave",
		"scene_title": "The Abyssal Gauntlet",
		"level_title": "Level 4-3",
		"full_title": "Lapis Caverns — Level 4-3: The Abyssal Gauntlet",
		"scene_path": "res://scenes/cave/level_4_3.tscn"
	},
	{
		"theme": "Cave",
		"scene_title": "The Chasm of Devoured Moons",
		"level_title": "Level 4-4",
		"full_title": "Lapis Caverns — Level 4-4: The Chasm of Devoured Moons",
		"scene_path": "res://scenes/cave/level_4_4.tscn"
	},
	{
		"theme": "Cave Boss",
		"scene_title": "Bakunawa's Abyss",
		"level_title": "Level 5",
		"full_title": "Abyssal Lair — Level 5: Bakunawa, The Moon Devourer",
		"scene_path": "res://scenes/cave/level_5.tscn"
	}
]

const LEVEL_WIDTH: float = 5120.0
const SPAWN_POS: Vector2 = Vector2(192.0, 260.0)
const MAP_TRANSITION_EDGE_X: float = 5050.0
var current_level_width: float = 5120.0
var current_level_height: float = 360.0
var current_level_transition_x: float = 5050.0

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
var cave_parallax_layers: Array[ParallaxLayer] = []

# ── Atmosphere, Storm & Lighting ─────────────────────────────────────────────
var canvas_modulate: CanvasModulate
var ambient_particles: CPUParticles2D
var rain_particles: CPUParticles2D         # Midground rain layer
var rain_particles_fg: CPUParticles2D      # Foreground heavy rain streaks
var rain_particles_bg: CPUParticles2D      # Background mist rain
var rain_splashes: CPUParticles2D          # Ground splash droplets
var storm_fog: CPUParticles2D              # Low rolling forest floor mist
var storm_vignette: TextureRect            # Cinematic soft edge storm vignette
var cave_vignette: TextureRect             # Hollow Knight deep subterranean vignette
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
const SAVE_FILE_PATH: String = "user://haliya_save.cfg"
const BOSS_CHECKPOINT_X: float = 3620.0

var current_level_idx: int = 0
var is_game_won: bool = false
var is_player_dead: bool = false
var is_transitioning: bool = false
var has_activated_boss_checkpoint: bool = false
var boss_checkpoint_shrine: Node2D = null

static func save_progress(level_idx: int) -> void:
	var cfg := ConfigFile.new()
	var prev_highest: int = 0
	if cfg.load(SAVE_FILE_PATH) == OK:
		prev_highest = int(cfg.get_value("progress", "highest_level_idx", 0))
	cfg.set_value("progress", "last_level_idx", clampi(level_idx, 0, LEVELS_DATA.size() - 1))
	cfg.set_value("progress", "highest_level_idx", maxi(prev_highest, clampi(level_idx, 0, LEVELS_DATA.size() - 1)))
	cfg.save(SAVE_FILE_PATH)

static func load_saved_level_idx() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_FILE_PATH) == OK:
		return clampi(int(cfg.get_value("progress", "last_level_idx", 0)), 0, LEVELS_DATA.size() - 1)
	return 0


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
var low_hp_vignette: ColorRect

## Health & Stamina Status Bars (Unified Theme: 2x Crescents, Shield Wards, Notched Stamina Bar)
var hud_cluster_root: Control
var hud_cluster_bg: TextureRect
var hp_bar_root: Control
var hp_pips_container: HBoxContainer
var shield_wards_container: HBoxContainer
var hp_fill_clip: Control = null
var hp_ghost_clip: Control = null
var hp_shield_clip: Control = null
var hp_shield_tex: TextureRect = null
var hp_frame: TextureRect = null
var hp_fill_tween: Tween
var hp_pulse_tween: Tween
var hp_ghost_tween: Tween
var hp_shield_tween: Tween
const HP_FILL_MAX_WIDTH: float = 830.0

var _cur_hp_cached: int = 5
var _max_hp_cached: int = 5
var _cur_arm_cached: int = 3
var _max_arm_cached: int = 3
var _prev_hp_for_crack: int = 5
var _was_exhausted_cached: bool = false
var stamina_full_timer: float = 0.0
var hp_pulse_timer: float = 0.0
var hp_pulse_frame: int = 0
var stamina_fade_tween: Tween
var stamina_exhaust_tween: Tween
var stamina_fill_tween: Tween

var stamina_bar_root: Control
var stamina_track_rect: ColorRect
var stamina_fill_clip: Control
var stamina_frame_tex: TextureRect
var hp_text_label: Label = null
var stamina_text_label: Label = null

## Centered Atmospheric Stage Discovery (Middle of Screen, No Stars or Dashes)
var area_discovery_container: Control
var stage_name_label: Label
var stage_level_label: Label
var settings_menu: CanvasLayer
var bestiary_codex_ui: CanvasLayer
var comic_story_viewer: CanvasLayer
var is_stage_2_boss_defeated: bool = false
var has_seen_boss_encounter_cutscene: bool = false
var has_seen_boss_defeat_cutscene: bool = false
var area_title_label: Label
var area_title_timer: float = 0.0
const AREA_TITLE_DURATION: float = 3.8

## Top-Right Minimalist Kill Counter
var score_label: Label
var _last_cached_kills: int = -1

## Respawn & Checkpoint Message Banner
var respawn_label: Label
var respawn_msg_timer: float = 0.0
const RESPAWN_MSG_DURATION: float = 2.0

## Win / Game Victory State overlay
var win_overlay: Control
var win_label: Label
var pause_overlay: Control
var auto_save_indicator: Control = null
var auto_save_tween: Tween = null
var act1_grade_layer: CanvasLayer = null
var act1_grade_rect: ColorRect = null
var stage_progress_root: Control = null
var progress_bar_fill: Control = null
var progress_player_pin: Control = null
var progress_shrine_pin: Control = null
var level_progress_bar: Control = null
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
var boss_enraged_badge: Label
var boss_baybayin_label: Label
var boss_hp_num_label: Label
var boss_phase_notch: Control
var boss_hp_tween: Tween
var boss_fire_tween: Tween
var foe_vanquished_banner: Control
var active_encounter_type: String = ""

# ── Run Statistics for Score Calculation ──────────────────────────────────────
var bosses_slain_this_run: int = 0
var parries_this_run: int = 0
var pearls_collected_this_run: int = 0

# ── Miniboss Arena Lockdown (Levels 1-3 and 2-3) ───────────────────────────────
var is_miniboss_arena_locked: bool = false
var miniboss_rear_barrier: StaticBody2D = null

# ── Screen Shake & Game Feel (Trauma System) ──────────────────────────────────
var trauma: float = 0.0
const TRAUMA_DECAY: float = 2.4
const MAX_SHAKE_OFFSET: float = 12.0
const MAX_SHAKE_ANGLE: float = 0.035
var hit_stop_timer: float = 0.0
var slowmo_timer: float = 0.0
var _suppress_initial_autosave: bool = false


func _ready() -> void:
	var loaded_save_data: Dictionary = {}
	if restore_saved_run:
		loaded_save_data = SaveManager.load_game(SaveManager.active_slot)
		if not loaded_save_data.is_empty():
			start_level_idx = int(loaded_save_data.get("level_idx", start_level_idx))
			var prog = loaded_save_data.get("progression", {})
			if prog is Dictionary:
				UpgradeManager.active_upgrades = prog.get("active_upgrades", {}).duplicate(true)
				UpgradeManager.current_tier = int(prog.get("current_tier", 1))
				UpgradeManager.loop_count = int(prog.get("loop_count", 1))
				UpgradeManager.total_kills_this_run = int(prog.get("total_kills", 0))
				UpgradeManager.levels_cleared_this_run = int(prog.get("levels_cleared", 0))
	else:
		UpgradeManager.init_run()
		SaveManager.active_run_play_time = 0.0
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	RenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
	current_level_idx = clamp(start_level_idx, 0, LEVELS_DATA.size() - 1)
	start_level_idx = 0
	setup_bgm()
	setup_parallax_bg()
	setup_atmosphere()
	setup_level_container()
	setup_enemies_container()
	setup_player()
	setup_camera()
	setup_ui()
	setup_auto_save_indicator()
	setup_stage_progress_tracker()
	_suppress_initial_autosave = true
	load_current_level()
	_suppress_initial_autosave = false
	spawn_level_enemies()

	run_start_time = Time.get_ticks_msec() / 1000.0
	if restore_saved_run:
		restore_saved_run = false
		if not loaded_save_data.is_empty():
			SaveManager.apply_loaded_game_to_run(loaded_save_data, self)
	respawn_player_at_checkpoint()
	SaveManager.save_game(SaveManager.active_slot, self)
	show_auto_save_indicator()


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
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_4, "scale": Vector2(0.04, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_3, "scale": Vector2(0.12, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_2, "scale": Vector2(0.24, 0.0)},
		{"path": AssetsScript.PATH_RICE_FIELD_LAYER_1, "scale": Vector2(0.42, 0.0)}
	]

	for i in range(rice_data.size()):
		var r_info = rice_data[i]
		var layer := ParallaxLayer.new()
		layer.name = "RiceFieldLayer_%d" % (4 - i)
		layer.motion_scale = r_info["scale"]

		var spr := Sprite2D.new()
		var tex = load(r_info["path"])
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		spr.centered = false

		# Dynamically scale 3840x1080 HD panorama to fit 360px viewport height (1280x360 = 2 un-zoomed 640px tiles)
		var tex_h: float = float(tex.get_height()) if tex else 1080.0
		var tex_w: float = float(tex.get_width()) if tex else 3840.0
		var scale_factor: float = 360.0 / tex_h
		var mirror_w: float = tex_w * scale_factor
		spr.scale = Vector2(scale_factor + 0.0004, scale_factor)
		layer.motion_mirroring = Vector2(mirror_w, 0.0)
		layer.motion_offset.y = max(0.0, (get_viewport_rect().size.y - 360.0) * 0.5)

		if i == 0:
			var sky_cap := Polygon2D.new()
			sky_cap.name = "SkyTopCap"
			sky_cap.color = Color(238.0 / 255.0, 176.0 / 255.0, 124.0 / 255.0, 1.0)
			sky_cap.polygon = PackedVector2Array([
				Vector2(0.0, -140.0),
				Vector2(mirror_w + 2.0, -140.0),
				Vector2(mirror_w + 2.0, 1.0),
				Vector2(0.0, 1.0)
			])
			layer.add_child(sky_cap)

		layer.add_child(spr)

		parallax_bg.add_child(layer)
		rice_field_parallax_layers.append(layer)

	# 4. Cave Parallax Layers (Layers 1 to 9: Deep glow, stalactites, and volumetric light shafts)
	cave_parallax_layers.clear()
	var cave_data = [
		{"path": AssetsScript.PATH_CAVE_LAYER_1, "scale": Vector2(0.02, 0.0), "is_fx": false, "name": "CaveLayer_1_CavernGlow"},
		{"path": AssetsScript.PATH_CAVE_LAYER_2, "scale": Vector2(0.07, 0.0), "is_fx": false, "name": "CaveLayer_2_DeepSilhouette"},
		{"path": AssetsScript.PATH_CAVE_LAYER_3FX, "scale": Vector2(0.12, 0.0), "is_fx": true, "name": "CaveLayer_3_GodRayFar"},
		{"path": AssetsScript.PATH_CAVE_LAYER_4, "scale": Vector2(0.18, 0.0), "is_fx": false, "name": "CaveLayer_4_FarStalactites"},
		{"path": AssetsScript.PATH_CAVE_LAYER_5, "scale": Vector2(0.28, 0.0), "is_fx": false, "name": "CaveLayer_5_MidPillars"},
		{"path": AssetsScript.PATH_CAVE_LAYER_6FX, "scale": Vector2(0.36, 0.0), "is_fx": true, "name": "CaveLayer_6_GodRayMid"},
		{"path": AssetsScript.PATH_CAVE_LAYER_7, "scale": Vector2(0.46, 0.0), "is_fx": false, "name": "CaveLayer_7_NearStalactites"},
		{"path": AssetsScript.PATH_CAVE_LAYER_8FX, "scale": Vector2(0.56, 0.0), "is_fx": true, "name": "CaveLayer_8_GodRayNear"},
		{"path": AssetsScript.PATH_CAVE_LAYER_9, "scale": Vector2(0.68, 0.0), "is_fx": false, "name": "CaveLayer_9_ForeCavern"}
	]

	var cave_fx_mat := CanvasItemMaterial.new()
	cave_fx_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	for c_info in cave_data:
		var layer := ParallaxLayer.new()
		layer.name = c_info["name"]
		layer.motion_scale = c_info["scale"]

		var tex = load(c_info["path"])
		var tex_h: float = float(tex.get_height()) if tex else 1080.0
		var tex_w: float = float(tex.get_width()) if tex else 1920.0
		var scale_factor: float = 360.0 / tex_h
		var tile_w: float = tex_w * scale_factor # 640.0
		var spr_scale = Vector2((tile_w + 0.5) / tex_w, scale_factor)

		var spr1 := Sprite2D.new()
		spr1.name = "Sprite1"
		spr1.texture = tex
		spr1.centered = false
		spr1.position = Vector2(0.0, 0.0)
		spr1.scale = spr_scale
		if c_info["is_fx"]:
			spr1.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			spr1.material = cave_fx_mat
			spr1.modulate = Color(0.45, 0.72, 0.96, 0.22)
		else:
			spr1.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.add_child(spr1)

		var spr2 := Sprite2D.new()
		spr2.name = "Sprite2"
		spr2.texture = tex
		spr2.centered = false
		spr2.position = Vector2(tile_w, 0.0)
		spr2.scale = spr_scale
		if c_info["is_fx"]:
			spr2.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			spr2.material = cave_fx_mat
			spr2.modulate = Color(0.45, 0.72, 0.96, 0.22)
		else:
			spr2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.add_child(spr2)

		if c_info["is_fx"]:
			var ray_tw := layer.create_tween().set_loops()
			ray_tw.tween_property(layer, "modulate:a", 0.55, 3.2).set_trans(Tween.TRANS_SINE)
			ray_tw.tween_property(layer, "modulate:a", 0.88, 3.2).set_trans(Tween.TRANS_SINE)

		layer.motion_mirroring = Vector2(tile_w * 2.0, 0.0)
		parallax_bg.add_child(layer)
		cave_parallax_layers.append(layer)

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
	var rumble_sfx = load("res://assets/audio/sfx/lightning_rumble.wav")
	if rumble_sfx:
		thunder_audio_player.stream = rumble_sfx
	else:
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

	cave_vignette = TextureRect.new()
	cave_vignette.name = "CaveVignette"
	cave_vignette.texture = CaveAssetsScript.get_vignette_tex()
	cave_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cave_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	cave_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	cave_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cave_vignette.modulate = Color(1, 1, 1, 0.0)
	storm_layer.add_child(cave_vignette)

	lens_rain_overlay = LensRainOverlayScript.new()
	lens_rain_overlay.name = "LensRainOverlay"
	storm_layer.add_child(lens_rain_overlay)

	# 8. Act 1 Forest Color Grade (CanvasLayer 4: In front of world layer 0, behind UI layer 10)
	act1_grade_layer = CanvasLayer.new()
	act1_grade_layer.name = "Act1ColorGradeLayer"
	act1_grade_layer.layer = 4
	act1_grade_layer.visible = false
	add_child(act1_grade_layer)

	act1_grade_rect = ColorRect.new()
	act1_grade_rect.name = "Act1ColorGradeRect"
	act1_grade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	act1_grade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var act1_mat := ShaderMaterial.new()
	act1_mat.shader = preload("res://shaders/act1_color_grade.gdshader")
	act1_grade_rect.material = act1_mat
	act1_grade_layer.add_child(act1_grade_rect)

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
	var cur_lvl_title: String = LEVELS_DATA[current_level_idx].get("level_title", "") if current_level_idx < LEVELS_DATA.size() else ""
	var is_forest: bool = (theme_name == "Forest" or theme_name == "Rainy Forest")
	var is_rainy: bool = (theme_name == "Rainy Forest")
	var is_cave: bool = (theme_name == "Cave" or theme_name == "Cave Boss")

	var is_act1_forest: bool = (theme_name == "Forest")
	if is_instance_valid(act1_grade_layer):
		act1_grade_layer.visible = is_act1_forest

	for layer in forest_parallax_layers:
		layer.visible = is_forest
		if is_rainy:
			layer.modulate = Color(0.52, 0.56, 0.70, 1.0)
		else:
			layer.modulate = Color(1.0, 1.0, 1.0, 1.0)

	for layer in rice_field_parallax_layers:
		layer.visible = (not is_forest and not is_cave)
		if cur_lvl_title == "Level 2-1":
			layer.modulate = Color(1.0, 1.0, 1.0, 1.0)
		elif cur_lvl_title == "Level 2-2":
			layer.modulate = Color(1.0, 0.96, 0.90, 1.0)
		elif cur_lvl_title == "Level 2-3":
			layer.modulate = Color(0.98, 0.88, 0.92, 1.0)
		elif cur_lvl_title == "Level 2-4":
			layer.modulate = Color(1.04, 0.84, 0.78, 1.0)
		elif cur_lvl_title == "Level 2-5":
			layer.modulate = Color(1.08, 0.80, 0.72, 1.0)
		else:
			layer.modulate = Color(1.0, 1.0, 1.0, 1.0)

	for i in range(cave_parallax_layers.size()):
		var layer := cave_parallax_layers[i]
		layer.visible = is_cave
		if is_cave:
			var is_fx_layer: bool = ("GodRay" in layer.name)
			var is_glow_bg: bool = (i == 0)
			var base_tint := Color(0.16, 0.20, 0.32, 1.0)
			if cur_lvl_title == "Level 4-1":
				base_tint = Color(0.14, 0.20, 0.30, 1.0) if is_glow_bg else Color(0.24, 0.30, 0.44, 1.0)
			elif cur_lvl_title == "Level 4-2":
				base_tint = Color(0.15, 0.13, 0.26, 1.0) if is_glow_bg else Color(0.25, 0.21, 0.38, 1.0)
			elif cur_lvl_title in ["Level 4-3", "Level 4-4"]:
				base_tint = Color(0.10, 0.12, 0.20, 1.0) if is_glow_bg else Color(0.18, 0.22, 0.32, 1.0)
			else:
				base_tint = Color(0.14, 0.10, 0.22, 1.0) if is_glow_bg else Color(0.24, 0.18, 0.32, 1.0)
			if is_fx_layer:
				layer.modulate = Color(base_tint.r * 1.35, base_tint.g * 1.35, base_tint.b * 1.35, 0.50)
			else:
				layer.modulate = base_tint

	if sky_parallax_layer:
		sky_parallax_layer.visible = not is_cave and not (theme_name == "Rice Field")

	if sky_sprite:
		if is_cave:
			sky_sprite.modulate = Color(0.015, 0.02, 0.04, 1.0)
		elif is_rainy:
			sky_sprite.modulate = Color(0.35, 0.40, 0.52, 1.0)
		elif cur_lvl_title == "Level 2-2":
			sky_sprite.modulate = Color(1.02, 0.92, 0.84, 1.0)
		elif cur_lvl_title == "Level 2-3":
			sky_sprite.modulate = Color(1.04, 0.80, 0.86, 1.0)
		elif cur_lvl_title == "Level 2-4":
			sky_sprite.modulate = Color(1.06, 0.72, 0.60, 1.0)
		elif cur_lvl_title == "Level 2-5":
			sky_sprite.modulate = Color(1.10, 0.64, 0.50, 1.0)
		else:
			sky_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Toggle Hollow Knight deep subterranean vignette
	if cave_vignette:
		cave_vignette.modulate = Color(1.0, 1.0, 1.0, 0.95) if is_cave else Color(1.0, 1.0, 1.0, 0.0)

	if is_cave:
		if cur_lvl_title == "Level 4-1":
			base_modulate_color = Color(0.24, 0.26, 0.36, 1.0)
		elif cur_lvl_title == "Level 4-2":
			base_modulate_color = Color(0.20, 0.22, 0.32, 1.0)
		elif cur_lvl_title in ["Level 4-3", "Level 4-4"]:
			base_modulate_color = Color(0.16, 0.18, 0.26, 1.0)
		else:
			base_modulate_color = Color(0.12, 0.14, 0.22, 1.0)
		if canvas_modulate:
			canvas_modulate.color = base_modulate_color
		if is_instance_valid(player):
			var p_light = player.get_node_or_null("CaveSpiritLight") as PointLight2D
			if not p_light:
				var light_tex = load("res://assets/vfx/radial_light_falloff.png")
				if light_tex:
					p_light = PointLight2D.new()
					p_light.name = "CaveSpiritLight"
					p_light.texture = light_tex
					p_light.position = Vector2(0.0, -18.0)
					p_light.color = Color(0.68, 0.88, 1.0, 0.95)
					p_light.energy = 1.15
					p_light.texture_scale = 0.65
					player.add_child(p_light)
			else:
				p_light.color = Color(0.68, 0.88, 1.0, 0.95)
				p_light.energy = 1.15
				p_light.texture_scale = 0.65
		if rain_particles:
			rain_particles.emitting = false
		if rain_particles_fg:
			rain_particles_fg.emitting = false
		if rain_particles_bg:
			rain_particles_bg.emitting = false
		if rain_splashes:
			rain_splashes.emitting = false
		if storm_fog:
			storm_fog.emitting = true
			storm_fog.modulate = Color(0.32, 0.62, 0.92, 0.24)
	elif is_rainy:
		if is_instance_valid(player):
			var old_light = player.get_node_or_null("CaveSpiritLight")
			if old_light:
				old_light.queue_free()
		var sub_level: float = clamp(float(current_level_idx - 8), 0.0, 4.0) # 0 to 4
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
		if is_instance_valid(player):
			var old_light = player.get_node_or_null("CaveSpiritLight")
			if old_light:
				old_light.queue_free()
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
		if is_instance_valid(player):
			var old_light = player.get_node_or_null("CaveSpiritLight")
			if old_light:
				old_light.queue_free()
		if cur_lvl_title == "Level 2-1":
			base_modulate_color = Color(1.02, 1.01, 0.98, 1.0)
		elif cur_lvl_title == "Level 2-2":
			base_modulate_color = Color(1.00, 0.96, 0.92, 1.0)
		elif cur_lvl_title == "Level 2-3":
			base_modulate_color = Color(0.96, 0.88, 0.92, 1.0)
		elif cur_lvl_title == "Level 2-4":
			base_modulate_color = Color(0.96, 0.84, 0.78, 1.0)
		elif cur_lvl_title == "Level 2-5":
			base_modulate_color = Color(0.95, 0.80, 0.74, 1.0)
		else:
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
		if is_cave:
			ambient_particles.emitting = true
			ambient_particles.amount = 36
			ambient_particles.direction = Vector2(0.2, -0.9)
			ambient_particles.spread = 42.0
			ambient_particles.gravity = Vector2(0.0, -14.0) # Upward floating spore motes
			ambient_particles.initial_velocity_min = 10.0
			ambient_particles.initial_velocity_max = 26.0
			ambient_particles.scale_amount_min = 1.4
			ambient_particles.scale_amount_max = 2.8
			ambient_particles.color = Color(0.45, 0.82, 1.0, 0.58) # Glowing crystalline dust
		elif is_rainy:
			ambient_particles.emitting = true
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
			ambient_particles.emitting = true
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
			# Rice Field: Dynamic 5-level atmospheric progression (golden pollen -> harvest motes -> dusk fireflies -> caldera sparks -> volcanic ash storm)
			ambient_particles.emitting = true
			if cur_lvl_title == "Level 2-1": # 2-1: Emerald Terraces
				ambient_particles.amount = 18
				ambient_particles.direction = Vector2(0.8, 0.35)
				ambient_particles.spread = 35.0
				ambient_particles.gravity = Vector2(4.0, 6.0)
				ambient_particles.initial_velocity_min = 15.0
				ambient_particles.initial_velocity_max = 30.0
				ambient_particles.scale_amount_min = 1.0
				ambient_particles.scale_amount_max = 2.0
				ambient_particles.color = Color(0.98, 0.88, 0.40, 0.45) # Golden pollen & rice chaff
			elif cur_lvl_title == "Level 2-2": # 2-2: Stilt Farmstead
				ambient_particles.amount = 22
				ambient_particles.direction = Vector2(0.5, -0.25)
				ambient_particles.spread = 42.0
				ambient_particles.gravity = Vector2(0.0, -4.0)
				ambient_particles.initial_velocity_min = 10.0
				ambient_particles.initial_velocity_max = 24.0
				ambient_particles.scale_amount_min = 1.1
				ambient_particles.scale_amount_max = 2.2
				ambient_particles.color = Color(0.98, 0.78, 0.38, 0.55) # Warm afternoon harvest motes
			elif cur_lvl_title == "Level 2-3": # 2-3: The Mayon Crossing
				ambient_particles.amount = 28
				ambient_particles.direction = Vector2(-0.3, -0.5)
				ambient_particles.spread = 45.0
				ambient_particles.gravity = Vector2(-6.0, -8.0)
				ambient_particles.initial_velocity_min = 14.0
				ambient_particles.initial_velocity_max = 32.0
				ambient_particles.scale_amount_min = 1.2
				ambient_particles.scale_amount_max = 2.4
				ambient_particles.color = Color(1.0, 0.64, 0.28, 0.65) # Dusk fireflies & distant cinders
			elif cur_lvl_title == "Level 2-4": # 2-4: The Caldera Foothills
				ambient_particles.amount = 36
				ambient_particles.direction = Vector2(-0.6, 0.5)
				ambient_particles.spread = 36.0
				ambient_particles.gravity = Vector2(-14.0, 22.0)
				ambient_particles.initial_velocity_min = 22.0
				ambient_particles.initial_velocity_max = 48.0
				ambient_particles.scale_amount_min = 1.1
				ambient_particles.scale_amount_max = 2.5
				ambient_particles.color = Color(1.0, 0.52, 0.20, 0.72) # Rising caldera ash & glowing sparks
			else: # 2-5: The Burning Kiln Village
				ambient_particles.amount = 46
				ambient_particles.direction = Vector2(-0.75, 0.65)
				ambient_particles.spread = 32.0
				ambient_particles.gravity = Vector2(-20.0, 34.0)
				ambient_particles.initial_velocity_min = 30.0
				ambient_particles.initial_velocity_max = 66.0
				ambient_particles.scale_amount_min = 1.2
				ambient_particles.scale_amount_max = 2.8
				ambient_particles.color = Color(1.0, 0.42, 0.14, 0.80) # Intense volcanic embers & ash from Mayon

	# Dynamic BGM cross-fade per theme (unless boss battle is locked in)
	if not is_boss_active:
		match theme_name:
			"Forest":
				play_bgm(ProceduralAudio.get_forest_ambient(), "forest")
			"Rice Field":
				play_bgm(ProceduralAudio.get_rice_field_ambient(), "rice_field")
			"Rainy Forest":
				play_bgm(ProceduralAudio.get_tempest_ambient(), "tempest")
			"Cave":
				play_bgm(ProceduralAudio.get_cave_ambient(), "cave")
			"Cave Boss":
				play_bgm(ProceduralAudio.get_cave_ambient(), "cave")

	update_hud_contrast()


# ── Level Container & Instantiation ───────────────────────────────────────────
func setup_level_container() -> void:
	level_container = Node2D.new()
	level_container.name = "LevelContainer"
	add_child(level_container)


func load_current_level() -> void:
	clear_miniboss_arena()
	has_activated_boss_checkpoint = false
	boss_checkpoint_shrine = null
	is_stage_2_boss_defeated = false
	has_seen_boss_encounter_cutscene = false
	has_seen_boss_defeat_cutscene = false
	save_progress(current_level_idx)
	if not _suppress_initial_autosave:
		SaveManager.save_game(SaveManager.active_slot, self)
		show_auto_save_indicator()
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

	current_level_width = LEVEL_WIDTH
	current_level_height = 360.0
	current_level_transition_x = MAP_TRANSITION_EDGE_X
	if is_instance_valid(player):
		player.fall_death_y = 600.0

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
			var is_cave_stage: bool = (data.get("theme", "") == "Cave" or data.get("theme", "") == "Cave Boss")
			for child in current_level_instance.get_children():
				if child is TileMapLayer:
					var layer := child as TileMapLayer
					if layer.name == "ForegroundDecor":
						layer.collision_enabled = not is_cave_stage
					elif layer.name == "WaterBackground":
						layer.collision_enabled = false
					else:
						layer.collision_enabled = true
					ensure_tileset_physics(layer)

			# If Rainy Forest, configure storm wind on foliage and storm mode on torches
			if data.get("theme", "") == "Rainy Forest":
				configure_storm_environment(current_level_instance)
			elif is_cave_stage:
				configure_cave_environment(current_level_instance, data.get("theme", "") == "Cave Boss")

			# Auto-wire scene enemies
			wire_scene_enemies(current_level_instance)

			# Subsurface roots/dirt layer under grass for Act 1 Forest
			if data.get("theme", "") == "Forest":
				apply_forest_dirt_roots(current_level_instance)
		else:
			LevelBuilderScript.build_level(level_container, current_level_idx, data["theme"])
	else:
		LevelBuilderScript.build_level(level_container, current_level_idx, data["theme"])

	if current_level_idx in [2, 7, 12, 16, 17]:
		_spawn_boss_checkpoint_shrine()

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
	update_player_environment_lighting()


func apply_forest_dirt_roots(level_node: Node2D) -> void:
	if not is_instance_valid(level_node):
		return
	var bg = level_node.find_child("BaseGround", true, false) as TileMapLayer
	if not is_instance_valid(bg):
		return

	var roots_tex: Texture2D = preload("res://assets/platform_assets/forest_dirt_roots.png")
	var roots_container := Node2D.new()
	roots_container.name = "SubsurfaceRootsDirt"
	roots_container.z_index = -1
	level_node.add_child(roots_container)

	var used_cells = bg.get_used_cells()
	for cell in used_cells:
		if cell.y >= 10 and cell.y <= 13:
			var spr := Sprite2D.new()
			spr.texture = roots_tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.region_enabled = true
			var col_idx: int = (abs(cell.x) + cell.y) % 4
			var row_idx: int = 0 if cell.y == 10 else (1 if cell.y == 11 else 2)
			spr.region_rect = Rect2(col_idx * 32, row_idx * 32, 32, 32)
			spr.position = Vector2(cell.x * 32 + 16, cell.y * 32 + 16)
			roots_container.add_child(spr)


func update_player_environment_lighting() -> void:
	if not is_instance_valid(player):
		return
	var current_theme: String = LEVELS_DATA[current_level_idx]["theme"] if current_level_idx < LEVELS_DATA.size() else ""
	var is_cave: bool = (current_theme == "Cave" or current_theme == "Cave Boss")
	var p_light = player.get_node_or_null("CaveSpiritLight") as PointLight2D
	if is_cave:
		if not p_light:
			var light_tex = load("res://assets/vfx/radial_light_falloff.png")
			if light_tex:
				p_light = PointLight2D.new()
				p_light.name = "CaveSpiritLight"
				p_light.texture = light_tex
				p_light.position = Vector2(0.0, -18.0)
				p_light.color = Color(0.48, 0.85, 1.0, 0.78)
				p_light.energy = 0.68
				p_light.texture_scale = 0.42
				player.add_child(p_light)
	else:
		if p_light:
			p_light.queue_free()


func _spawn_boss_checkpoint_shrine() -> void:
	if not is_instance_valid(level_container):
		return
	var shrine_root := Node2D.new()
	shrine_root.name = "BossCheckpointShrine"
	var sy = get_ground_y_at_x(BOSS_CHECKPOINT_X)
	shrine_root.position = Vector2(BOSS_CHECKPOINT_X, sy)
	shrine_root.z_index = -1

	var statue_tex = load("res://assets/platform_assets/Angel Statue.png")
	if statue_tex:
		var spr := Sprite2D.new()
		spr.name = "ShrineStatue"
		spr.texture = statue_tex
		spr.scale = Vector2(0.85, 0.85)
		spr.position = Vector2(0.0, -34.0)
		spr.modulate = Color(0.75, 0.82, 0.95, 0.95)
		shrine_root.add_child(spr)

	var light_tex = load("res://assets/vfx/radial_light_falloff.png")
	if light_tex:
		var pl := PointLight2D.new()
		pl.name = "ShrineLight"
		pl.texture = light_tex
		pl.position = Vector2(0.0, -36.0)
		pl.color = Color(0.45, 0.80, 1.0, 1.0)
		pl.energy = 0.65
		pl.texture_scale = 0.32
		shrine_root.add_child(pl)

	var motes := CPUParticles2D.new()
	motes.name = "ShrineMotes"
	motes.position = Vector2(0.0, -24.0)
	motes.amount = 12
	motes.lifetime = 1.6
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(18.0, 12.0)
	motes.direction = Vector2(0.0, -1.0)
	motes.spread = 25.0
	motes.gravity = Vector2(0.0, -18.0)
	motes.initial_velocity_min = 8.0
	motes.initial_velocity_max = 22.0
	motes.scale_amount_min = 1.5
	motes.scale_amount_max = 3.0
	motes.color = Color(0.55, 0.88, 1.0, 0.55)
	shrine_root.add_child(motes)

	var prompt_lbl := Label.new()
	prompt_lbl.name = "ShrinePromptLabel"
	prompt_lbl.text = "[W / Up] Meditate & Save"
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.position = Vector2(-100, -78)
	prompt_lbl.size = Vector2(200, 20)
	prompt_lbl.add_theme_font_override("font", load("res://alagard.ttf"))
	prompt_lbl.add_theme_font_size_override("font_size", 11)
	prompt_lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0, 0.95))
	prompt_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	prompt_lbl.add_theme_constant_override("shadow_offset_x", 1)
	prompt_lbl.add_theme_constant_override("shadow_offset_y", 1)
	prompt_lbl.visible = false
	shrine_root.add_child(prompt_lbl)

	level_container.add_child(shrine_root)
	boss_checkpoint_shrine = shrine_root


func _activate_boss_checkpoint_shrine() -> void:
	if has_activated_boss_checkpoint:
		return
	has_activated_boss_checkpoint = true
	if is_instance_valid(boss_checkpoint_shrine):
		var spr := boss_checkpoint_shrine.get_node_or_null("ShrineStatue") as Sprite2D
		var pl := boss_checkpoint_shrine.get_node_or_null("ShrineLight") as PointLight2D
		var motes := boss_checkpoint_shrine.get_node_or_null("ShrineMotes") as CPUParticles2D
		if spr:
			var tw_s = create_tween()
			tw_s.tween_property(spr, "modulate", Color(1.15, 1.22, 1.35, 1.0), 0.45)
		if pl:
			var tw_l = create_tween()
			tw_l.tween_property(pl, "color", Color(0.65, 0.92, 1.0, 1.0), 0.45)
			tw_l.parallel().tween_property(pl, "energy", 1.55, 0.45)
			tw_l.parallel().tween_property(pl, "texture_scale", 0.52, 0.45)
		if motes:
			motes.amount = 24
			motes.color = Color(0.85, 0.96, 1.0, 0.90)
	if is_instance_valid(player):
		player.current_hp = player.get_max_hp()
		player.current_armor = player.get_max_armor()
		player.hp_changed.emit(player.current_hp, player.get_max_hp())
		player.armor_changed.emit(player.current_armor, player.get_max_armor())
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()
	SaveManager.save_game(SaveManager.active_slot, self)
	show_auto_save_indicator()
	show_exit_banner("ANCESTRAL SHRINE KINDLED — CHECKPOINT SAVED", Color(0.65, 0.92, 1.0, 1.0))


func meditate_at_shrine() -> void:
	if not is_instance_valid(player) or is_player_dead:
		return
	has_activated_boss_checkpoint = true
	player.current_hp = player.get_max_hp()
	player.current_armor = player.get_max_armor()
	player.hp_changed.emit(player.current_hp, player.get_max_hp())
	player.armor_changed.emit(player.current_armor, player.get_max_armor())
	if player.has_method("reset_combat_state"):
		player.reset_combat_state()
	VFX.spawn_armor_regen_pulse(self, player.global_position + Vector2(0, -28.0))
	VFX.spawn_floating_text(self, player.global_position + Vector2(0, -55.0), "SPIRIT RESTORED", Color(0.65, 0.95, 1.0, 1.0), 14, true)
	if is_instance_valid(boss_checkpoint_shrine):
		var pl := boss_checkpoint_shrine.get_node_or_null("ShrineLight") as PointLight2D
		if pl:
			var tw_l = create_tween()
			tw_l.tween_property(pl, "energy", 2.2, 0.25)
			tw_l.tween_property(pl, "energy", 1.55, 0.35)
	SaveManager.save_game(SaveManager.active_slot, self)
	show_auto_save_indicator()
	show_exit_banner("ANCESTRAL SHRINE — SPIRIT RESTORED & GAME SAVED", Color(0.65, 0.92, 1.0, 1.0))



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
				sm.set_shader_parameter("wind_speed", 2.4)
				sm.set_shader_parameter("wind_strength", 3.5)
				sm.set_shader_parameter("wind_detail", 2.5)


func configure_cave_environment(root_level: Node2D, is_boss_lair: bool) -> void:
	if not root_level:
		return

	var light_tex = load("res://assets/vfx/radial_light_falloff.png")
	var rock_tex = CaveAssetsScript.get_rock_tiles_tex()
	var plat_tex = CaveAssetsScript.get_platforms_tex()

	# 1. Assign Cave Platform textures across all platform nodes in the scene
	var all_sprites = root_level.find_children("", "Sprite2D", true, false)
	for spr in all_sprites:
		var s := spr as Sprite2D
		var t_path: String = s.texture.resource_path if s.texture else ""
		if "cave_platforms" in t_path or "PlatformVisual" in s.name or "LedgeSprite" in s.name:
			s.texture = plat_tex
		elif t_path == "" or "cave_rock_tiles" in t_path:
			if s.get_parent() and (s.get_parent().name == "GroundSegments" or "Ground" in s.get_parent().name or "Tile" in s.name):
				s.texture = rock_tex

	# 2. Attach bioluminescent Spirit Lantern aura to Haliya in the cave
	if is_instance_valid(player):
		var p_light = player.get_node_or_null("CaveSpiritLight") as PointLight2D
		if not p_light and light_tex:
			p_light = PointLight2D.new()
			p_light.name = "CaveSpiritLight"
			p_light.texture = light_tex
			p_light.position = Vector2(0.0, -18.0)
			p_light.color = Color(0.68, 0.88, 1.0, 0.95)
			p_light.energy = 1.15
			p_light.texture_scale = 0.65
			player.add_child(p_light)
		elif p_light:
			p_light.color = Color(0.68, 0.88, 1.0, 0.95)
			p_light.energy = 1.15
			p_light.texture_scale = 0.65
	# 4. Elevated platforms use self-contained, organically tapered rock underbellies (no artificial column tubes)

	# 5. Animate static water sprites in WaterGaps if any
	var water_gaps = root_level.find_child("WaterGaps", true, false)
	if water_gaps:
		var spr_idx: int = 0
		for child in water_gaps.get_children():
			if child is Sprite2D:
				var w_spr := child as Sprite2D
				w_spr.modulate = Color(0.35, 0.70, 0.95, 0.90)
				var frame_offset: int = (spr_idx * 3) % 20
				var anim_tween = w_spr.create_tween().set_loops()
				for f in range(20):
					anim_tween.tween_callback(func(spr=w_spr, frm=(f + frame_offset) % 20):
						if is_instance_valid(spr):
							spr.frame = frm
					).set_delay(0.06)
				if spr_idx == 0 and light_tex:
					var w_light := PointLight2D.new()
					w_light.texture = light_tex
					w_light.color = Color(0.18, 0.65, 0.95, 0.85)
					w_light.energy = 0.75
					w_light.texture_scale = 0.35
					w_spr.add_child(w_light)
				spr_idx += 1

	# 7. Sculpted Cavern Ceiling Canopy & Water Drips
	var ceiling_root := Node2D.new()
	ceiling_root.name = "CaveCeilingCanopy"
	ceiling_root.z_index = 2
	root_level.add_child(ceiling_root)

	var ceiling_tex = CaveAssetsScript.get_ceiling_tex()
	if ceiling_tex:
		var tex_w: float = float(ceiling_tex.get_width())
		var num_ceiling_tiles: int = int(ceil(current_level_width / tex_w)) + 3
		for i in range(-1, num_ceiling_tiles):
			var c_spr := Sprite2D.new()
			c_spr.texture = ceiling_tex
			c_spr.centered = false
			c_spr.position = Vector2(i * tex_w, 0.0)
			ceiling_root.add_child(c_spr)


	var num_ceiling_spans: int = int(ceil(current_level_width / 96.0))
	for ci in range(num_ceiling_spans):
		var cx: float = ci * 96.0 + 48.0
		if ci % 4 == 1:
			var drip := CPUParticles2D.new()
			drip.emitting = true
			drip.amount = 2
			drip.lifetime = 1.8
			drip.direction = Vector2(0, 1)
			drip.spread = 4.0
			drip.gravity = Vector2(0, 260.0)
			drip.initial_velocity_min = 10.0
			drip.initial_velocity_max = 22.0
			drip.scale_amount_min = 1.2
			drip.scale_amount_max = 2.0
			drip.color = Color(0.38, 0.75, 0.95, 0.65)
			drip.position = Vector2(cx, 80.0)
			ceiling_root.add_child(drip)

	# 8. Subtle Subterranean Spore Motes throughout the Cavern
	var spores := CPUParticles2D.new()
	spores.name = "CavernSporeMotes"
	spores.position = Vector2(current_level_width / 2.0, current_level_height / 2.0)
	spores.amount = 32
	spores.lifetime = 5.0
	spores.preprocess = 2.0
	spores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	spores.emission_rect_extents = Vector2(current_level_width / 2.0, current_level_height / 2.0)
	spores.direction = Vector2(0.3, -0.8)
	spores.spread = 60.0
	spores.gravity = Vector2(0.0, -3.0)
	spores.initial_velocity_min = 4.0
	spores.initial_velocity_max = 12.0
	spores.scale_amount_min = 1.2
	spores.scale_amount_max = 2.4
	spores.color = Color(0.35, 0.80, 0.95, 0.35)
	root_level.add_child(spores)

	# 7. Level 5 Boss Arena: Dedicated Seventh Moon / Eclipse Centerpiece in Upper Cavern Sky
	if is_boss_lair:
		_create_boss_arena_eclipse_moon(root_level, light_tex)


func _create_boss_arena_eclipse_moon(root_level: Node2D, light_tex: Texture2D) -> void:
	var moon_root := Node2D.new()
	moon_root.name = "EclipseMoonCenterpiece"
	moon_root.position = Vector2(4450.0, 86.0)
	moon_root.z_index = -2
	root_level.add_child(moon_root)

	# Outer celestial halo polygon (32-point smooth circle)
	var halo_pts := PackedVector2Array()
	var disc_pts := PackedVector2Array()
	var shadow_pts := PackedVector2Array()
	for i in range(32):
		var ang: float = (float(i) / 32.0) * TAU
		halo_pts.append(Vector2(cos(ang), sin(ang)) * 58.0)
		disc_pts.append(Vector2(cos(ang), sin(ang)) * 42.0)
		shadow_pts.append(Vector2(cos(ang), sin(ang)) * 35.0)

	var halo := Polygon2D.new()
	halo.name = "MoonCorona"
	halo.polygon = halo_pts
	halo.color = Color(0.35, 0.78, 1.0, 0.22)
	moon_root.add_child(halo)

	var disc := Polygon2D.new()
	disc.name = "MoonDisc"
	disc.polygon = disc_pts
	disc.color = Color(0.86, 0.94, 1.0, 0.92)
	moon_root.add_child(disc)

	# Partial abyssal eclipse shadow creeping across the moon
	var shadow := Polygon2D.new()
	shadow.name = "EclipseShadow"
	shadow.polygon = shadow_pts
	shadow.position = Vector2(12.0, -6.0)
	shadow.color = Color(0.05, 0.07, 0.14, 0.88)
	moon_root.add_child(shadow)

	if light_tex:
		var moon_light := PointLight2D.new()
		moon_light.name = "MoonLight"
		moon_light.texture = light_tex
		moon_light.color = Color(0.45, 0.82, 1.0, 1.0)
		moon_light.energy = 1.35
		moon_light.texture_scale = 0.95
		moon_root.add_child(moon_light)

		var ambient_moon := PointLight2D.new()
		ambient_moon.name = "MoonAmbientGlow"
		ambient_moon.texture = light_tex
		ambient_moon.color = Color(0.28, 0.72, 1.0, 0.65)
		ambient_moon.energy = 0.85
		ambient_moon.texture_scale = 1.65
		moon_root.add_child(ambient_moon)

	var pulse_tw := moon_root.create_tween().set_loops()
	pulse_tw.tween_property(halo, "scale", Vector2(1.08, 1.08), 2.4).set_trans(Tween.TRANS_SINE)
	pulse_tw.tween_property(halo, "scale", Vector2(0.96, 0.96), 2.4).set_trans(Tween.TRANS_SINE)


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
	if not is_instance_valid(root_level) or root_level.has_meta("enemies_wired"):
		return
	root_level.set_meta("enemies_wired", true)
	active_enemies.clear()
	var enemies_node = root_level.find_child("Enemies", true, false)
	if not enemies_node:
		enemies_node = root_level

	# Guarantee Miniboss at climax for Level 1-3, Level 2-5, and Level 4-4
	var cur_title_guar = LEVELS_DATA[current_level_idx].get("level_title", "")
	if cur_title_guar == "Level 1-3":
		var has_brute: bool = false
		for child in enemies_node.get_children():
			if child is ForestBruteMiniboss:
				has_brute = true
				break
		if not has_brute:
			# Remove any standard mob at the very end of the ridge (x >= 4300)
			for child in enemies_node.get_children():
				if child is CharacterBody2D and child.position.x >= 4300.0:
					child.queue_free()
			var brute = ForestBruteMinibossScript.new()
			brute.name = "ForestBruteMiniboss"
			brute.position = Vector2(4450.0, 250.0)
			enemies_node.add_child(brute)
	elif cur_title_guar in ["Level 2-3", "Level 2-4"]:
		var has_santelmo: bool = false
		for child in enemies_node.get_children():
			if child.has_signal("santelmo_died"):
				has_santelmo = true
				break
		if not has_santelmo:
			var idx_s: int = 1
			for sx in [1950.0, 3350.0]:
				var st = SantelmoScript.new()
				st.name = "SantelmoWisp%d" % idx_s
				st.position = Vector2(sx, 175.0)
				enemies_node.add_child(st)
				idx_s += 1
	elif cur_title_guar == "Level 2-5":
		var has_vanguard: bool = false
		for child in enemies_node.get_children():
			if child is MayonVanguardMiniboss:
				has_vanguard = true
				break
		if not has_vanguard:
			# Remove any standard mob at the very end of the crossing (x >= 4100)
			for child in enemies_node.get_children():
				if child is CharacterBody2D and child.position.x >= 4100.0:
					child.queue_free()
			var vanguard = MayonVanguardMinibossScript.new()
			vanguard.name = "MayonVanguardMiniboss"
			vanguard.position = Vector2(4450.0, 250.0)
			enemies_node.add_child(vanguard)
	elif cur_title_guar == "Level 4-4":
		var has_cave_miniboss: bool = false
		for child in enemies_node.get_children():
			if child is MayonVanguardMiniboss or child.is_in_group("miniboss"):
				has_cave_miniboss = true
				break
		if not has_cave_miniboss:
			for child in enemies_node.get_children():
				if child is CharacterBody2D and child.position.x >= 4100.0:
					child.queue_free()
			var abyssal_warden = MayonVanguardMinibossScript.new()
			abyssal_warden.name = "AbyssalVanguardMiniboss"
			abyssal_warden.position = Vector2(4450.0, 250.0)
			abyssal_warden.modulate = Color(0.68, 0.85, 1.35, 1.0)
			enemies_node.add_child(abyssal_warden)

	var enemies_list = enemies_node.get_children() if enemies_node else root_level.find_children("", "CharacterBody2D", true, false)

	for enemy in enemies_list:
		if not (enemy is CharacterBody2D):
			continue
		if enemy.has_signal("aswang_died") and not enemy.aswang_died.is_connected(_on_aswang_died):
			enemy.aswang_died.connect(_on_aswang_died)
		elif enemy.has_signal("skeleton_died") and not enemy.skeleton_died.is_connected(_on_skeleton_died):
			enemy.skeleton_died.connect(_on_skeleton_died)
		elif enemy.has_signal("santelmo_died") and not enemy.santelmo_died.is_connected(_on_santelmo_died):
			enemy.santelmo_died.connect(_on_santelmo_died)
		if not (enemy in active_enemies):
			active_enemies.append(enemy)
	
	# Apply Roguelite Difficulty & Escalation Scaling
	var hp_mult = UpgradeManager.get_enemy_hp_multiplier()
	var spd_mult = UpgradeManager.get_enemy_speed_multiplier()
	var elite_rate = UpgradeManager.get_elite_chance()
	
	for enemy in active_enemies:
		if is_instance_valid(enemy) and not enemy.is_in_group("miniboss") and not enemy.is_in_group("boss"):
			var is_elite = (randf() < elite_rate)
			if enemy.has_method("apply_difficulty_scaling"):
				enemy.apply_difficulty_scaling(hp_mult, spd_mult, is_elite)

	# Dynamic Horde Spawning: Sprinkle extra patrol monsters across the 5120px terrain
	var extra_count = UpgradeManager.get_extra_spawn_count()
	if extra_count > 0 and current_level_idx < 16:
		_spawn_escalation_reinforcements(extra_count, hp_mult, spd_mult, elite_rate)

	if active_enemies.is_empty():
		unlock_exit_path()
	else:
		setup_exit_barrier()


func setup_enemies_container() -> void:
	enemies_container = Node2D.new()
	enemies_container.name = "EnemiesContainer"
	add_child(enemies_container)


func spawn_level_enemies() -> void:
	var cur_title_spawn = LEVELS_DATA[current_level_idx].get("level_title", "")
	if is_boss_active or cur_title_spawn == "Level 3-5" or cur_title_spawn == "Level 5":
		is_boss_active = false
		clear_boss_arena_barriers()
		if is_instance_valid(boss_instance):
			boss_instance.queue_free()
			boss_instance = null
		if is_instance_valid(boss_hud_root):
			boss_hud_root.visible = false
			boss_hud_root.modulate.a = 0.0

	# If current scene already has enemies baked in, keep them wired
	if current_level_instance:
		var scene_enemies = current_level_instance.find_child("Enemies", true, false)
		if scene_enemies and scene_enemies.get_child_count() > 0:
			wire_scene_enemies(current_level_instance)
			return

	if not enemies_container:
		return
	active_enemies.clear()
	var data = LEVELS_DATA[current_level_idx]
	LevelBuilderScript.spawn_enemies(enemies_container, current_level_idx, data["theme"], _on_aswang_died, _on_skeleton_died)
	if data["theme"] == "Rice Field" and current_level_idx in [5, 6, 7]:
		for sx in [1850.0, 3200.0]:
			var st = SantelmoScript.new()
			st.global_position = Vector2(sx, 180.0)
			st.santelmo_died.connect(_on_santelmo_died)
			enemies_container.add_child(st)
			active_enemies.append(st)
	elif data["theme"] == "Cave" and current_level_idx in [13, 14, 15]:
		for sx in [2100.0, 3600.0]:
			var st = SantelmoScript.new()
			st.global_position = Vector2(sx, 175.0)
			st.santelmo_died.connect(_on_santelmo_died)
			enemies_container.add_child(st)
			active_enemies.append(st)
	for child in enemies_container.get_children():
		if child is CharacterBody2D:
			active_enemies.append(child)
	if active_enemies.is_empty():
		unlock_exit_path()
	else:
		setup_exit_barrier()


func _on_aswang_died(enemy: Node) -> void:
	aswang_kills += 1
	UpgradeManager.total_kills_this_run += 1
	var is_miniboss = is_instance_valid(enemy) and enemy.is_in_group("miniboss")
	var is_boss = is_instance_valid(enemy) and enemy.is_in_group("boss")
	var pearl_base = 8 if is_miniboss else (25 if is_boss else 1)
	var drop_pearls = pearl_base
	MetaProgression.add_moon_pearls(drop_pearls)
	if is_instance_valid(enemy):
		if enemy.get_script() != null and "CorruptedFarmer" in enemy.get_script().resource_path:
			MetaProgression.unlock_bestiary("corrupted_farmer")
		elif is_boss:
			MetaProgression.unlock_bestiary("manananggal")
		elif is_miniboss:
			MetaProgression.unlock_bestiary("tikbalang")
		else:
			MetaProgression.unlock_bestiary("aswang")
	MetaProgression.save_meta()

	if enemy in active_enemies:
		active_enemies.erase(enemy)
	if is_instance_valid(enemy) and enemy.is_in_group("miniboss"):
		handle_miniboss_defeated(enemy)
	update_score_hud()
	check_enemies_cleared()


func _on_skeleton_died(enemy: Node) -> void:
	skeleton_kills += 1
	UpgradeManager.total_kills_this_run += 1
	var is_miniboss = is_instance_valid(enemy) and enemy.is_in_group("miniboss")
	var is_boss = is_instance_valid(enemy) and enemy.is_in_group("boss")
	var pearl_base = 8 if is_miniboss else (35 if is_boss else 2)
	var drop_pearls = pearl_base
	MetaProgression.add_moon_pearls(drop_pearls)
	if is_instance_valid(enemy):
		if is_boss or "Bakunawa" in enemy.name:
			MetaProgression.unlock_bestiary("bakunawa")
		elif is_miniboss:
			MetaProgression.unlock_bestiary("mayon_vanguard")
		else:
			MetaProgression.unlock_bestiary("sigbin")
	MetaProgression.save_meta()

	if enemy in active_enemies:
		active_enemies.erase(enemy)
	if is_instance_valid(enemy) and enemy.is_in_group("miniboss"):
		handle_miniboss_defeated(enemy)
	update_score_hud()
	check_enemies_cleared()


func _on_santelmo_died(enemy: Node) -> void:
	MetaProgression.unlock_bestiary("santelmo")
	var drop_pearls = 2
	MetaProgression.add_moon_pearls(drop_pearls)
	MetaProgression.save_meta()
	UpgradeManager.total_kills_this_run += 1
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

			var ts_path: String = ts.resource_path.to_lower()
			var is_cave_ts: bool = ("cave_tileset" in ts_path)

			for source_idx in range(ts.get_source_count()):
				var source_id = ts.get_source_id(source_idx)
				var source = ts.get_source(source_id)
				if source is TileSetAtlasSource:
					var atlas_source = source as TileSetAtlasSource
					var tex = atlas_source.texture
					var tex_path: String = ((tex.resource_path + " " + tex.resource_name).to_lower()) if tex else ""
					var is_cave_atlas: bool = (
						"cave_rock" in tex_path or
						"cave_tileset" in tex_path or
						(is_cave_ts and source_id == 0)
					)
					if is_cave_atlas:
						var fresh_tex = CaveAssetsScript.get_tileset_atlas_tex()
						if fresh_tex and atlas_source.texture != fresh_tex:
							atlas_source.texture = fresh_tex
						for cy in range(12):
							for cx in range(9):
								var c_id := Vector2i(cx, cy)
								if not atlas_source.has_tile(c_id):
									atlas_source.create_tile(c_id)
					
					# Strictly ensure ONLY Floor Tiles, Other Tiles, and Cave Rock Tileset are solid
					var is_solid_source: bool = (
						"floor tiles" in tex_path or 
						"other tiles" in tex_path or
						is_cave_atlas or
						(is_cave_ts and source_id == 3)
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
		var ground_node = current_level_instance.find_child("GroundSegments", true, false)
		if ground_node:
			for child in ground_node.get_children():
				if child is StaticBody2D:
					var cs = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
					if cs and cs.shape is RectangleShape2D:
						var r = cs.shape as RectangleShape2D
						var max_x = cs.global_position.x + r.size.x * 0.5
						if max_x >= 5000.0:
							return cs.global_position.y - r.size.y * 0.5
		var base_ground: TileMapLayer = current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
		if base_ground:
			var min_surface_y: float = 9999.0
			for col in range(150, 160):
				for row in range(4, 30):
					if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
						var td = base_ground.get_cell_tile_data(Vector2i(col, row))
						if td and td.get_collision_polygons_count(0) > 0:
							var wy = row * (base_ground.tile_set.tile_size.y if base_ground.tile_set else 32.0)
							min_surface_y = min(min_surface_y, wy)
			if min_surface_y < 9000.0:
				return min_surface_y
	return end_y


func find_valid_ground_strike_position(desired_x: float) -> Vector2:
	if not current_level_instance:
		return Vector2.ZERO
	
	var base_ground: TileMapLayer = current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
	if not base_ground or not base_ground.tile_set:
		return Vector2.ZERO
		
	var tile_size = base_ground.tile_set.tile_size
	var center_col: int = int(floor(desired_x / float(tile_size.x)))
	
	# Search outwards from center_col for a flat, solid 5-tile platform span (2-tile margin on each side)
	var search_offsets: Array[int] = [0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6, 7, -7, 8, -8]
	for offset in search_offsets:
		var col = center_col + offset
		var test_x = (col + 0.5) * float(tile_size.x)
		if test_x < 150.0 or test_x > LEVEL_WIDTH - 150.0:
			continue
		
		# Find the top-most solid ground row at this column (skip rows 0..3 which are cavern ceiling overhangs)
		var surface_row: int = -1
		for r in range(4, 30):
			if _is_solid_ground_tile(base_ground, col, r):
				# Make sure the tile directly above is empty/air (true surface)
				if r == 0 or not _is_solid_ground_tile(base_ground, col, r - 1):
					surface_row = r
					break
		
		if surface_row == -1:
			continue
			
		# Check 2-tile margin on left (col-1, col-2) and right (col+1, col+2)
		var is_continuous_and_solid := true
		for dc in [-2, -1, 1, 2]:
			var check_col = col + dc
			# Require a solid surface tile at surface_row, and air above it
			if not _is_solid_ground_tile(base_ground, check_col, surface_row):
				is_continuous_and_solid = false
				break
			if surface_row > 0 and _is_solid_ground_tile(base_ground, check_col, surface_row - 1):
				# Blocked by a ceiling or wall, not a flat surface
				is_continuous_and_solid = false
				break
		
		# Verify there is no water hazard near this position
		var water_hazards = current_level_instance.find_children("", "Area2D", true, false)
		for h in water_hazards:
			if h.name.begins_with("Water") or "water" in h.name.to_lower():
				var w_dist = abs(h.global_position.x - test_x)
				if w_dist < 64.0:
					is_continuous_and_solid = false
					break
		
		if is_continuous_and_solid:
			# Surface contact point is the top of the tile: row * tile_size.y
			return Vector2(test_x, float(surface_row * tile_size.y))
			
	return Vector2.ZERO

func _is_solid_ground_tile(layer: TileMapLayer, c: int, r: int) -> bool:
	var coord := Vector2i(c, r)
	if layer.get_cell_source_id(coord) == -1:
		return false
	var td = layer.get_cell_tile_data(coord)
	if not td:
		return false
	# Check for collisions
	if td.get_collision_polygons_count(0) <= 0:
		return false
	# Check for invisible tiles (transparent or modulate a <= 0.05)
	if td.modulate.a <= 0.05:
		return false
	return true

func get_ground_y_at_x(target_x: float) -> float:
	if current_level_instance:
		var ground_node = current_level_instance.find_child("GroundSegments", true, false)
		if ground_node:
			for child in ground_node.get_children():
				if child is StaticBody2D:
					var cs = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
					if cs and cs.shape is RectangleShape2D:
						var r = cs.shape as RectangleShape2D
						var min_x = cs.global_position.x - r.size.x * 0.5
						var max_x = cs.global_position.x + r.size.x * 0.5
						if target_x >= min_x and target_x <= max_x:
							return cs.global_position.y - r.size.y * 0.5
	var strike_pos = find_valid_ground_strike_position(target_x)
	if strike_pos != Vector2.ZERO:
		return strike_pos.y
	return 280.0 if (current_level_idx in [13, 14]) else 288.0


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
	left_rect.size = Vector2(32.0, 2400.0)
	left_shape.shape = left_rect
	left_wall.position = Vector2(-16.0, 500.0)
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
	right_floor.position = Vector2(current_level_width + 300.0, ground_end_y + 32.0)
	right_floor.add_child(floor_shape)
	map_boundaries_root.add_child(right_floor)

	# 3. Right Safety Backstop Wall (Prevents walking past the extended floor)
	var backstop := StaticBody2D.new()
	backstop.name = "RightBackstopWall"
	backstop.collision_layer = 1
	backstop.collision_mask = 0
	var backstop_shape := CollisionShape2D.new()
	var backstop_rect := RectangleShape2D.new()
	backstop_rect.size = Vector2(32.0, 2400.0)
	backstop_shape.shape = backstop_rect
	backstop.position = Vector2(current_level_width + 600.0, 500.0)
	backstop.add_child(backstop_shape)
	map_boundaries_root.add_child(backstop)

	setup_exit_barrier()


func setup_exit_barrier() -> void:
	if exit_barrier_body and is_instance_valid(exit_barrier_body):
		exit_barrier_body.queue_free()
		exit_barrier_body = null

	var alive_count: int = 0
	for e in active_enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			alive_count += 1

	if alive_count > 0:
		exit_barrier_body = StaticBody2D.new()
		exit_barrier_body.name = "ExitBarrierBody"
		exit_barrier_body.collision_layer = 1
		exit_barrier_body.collision_mask = 2 # Blocks player (Layer 2)
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(32.0, 2400.0)
		shape.shape = rect
		exit_barrier_body.add_child(shape)
		exit_barrier_body.global_position = Vector2(current_level_transition_x - 40.0, 500.0)
		add_child(exit_barrier_body)


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
	player.armor_changed.connect(_on_player_armor_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.hit_landed.connect(_on_player_hit_landed)
	if player.has_signal("riposte_performed"):
		player.riposte_performed.connect(_on_player_riposte_performed)
	player.damage_taken.connect(_on_player_damage_taken)
	UpgradeManager.sync_player_stats(player)

	var current_theme: String = LEVELS_DATA[current_level_idx]["theme"] if current_level_idx < LEVELS_DATA.size() else ""
	if current_theme == "Cave" or current_theme == "Cave Boss":
		var light_tex = load("res://assets/vfx/radial_light_falloff.png")
		if light_tex:
			var p_light := PointLight2D.new()
			p_light.name = "CaveSpiritLight"
			p_light.texture = light_tex
			p_light.position = Vector2(0.0, -18.0)
			p_light.color = Color(0.58, 0.90, 1.0, 0.92)
			p_light.energy = 0.95
			p_light.texture_scale = 0.46
			player.add_child(p_light)


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
	ui_layer.layer = 10
	add_child(ui_layer)

	# Master container for all in-game HUD elements (toggled together)
	hud_container = Control.new()
	hud_container.name = "HUDContainer"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud_container)

	var custom_font = load("res://alagard.ttf")

	# ── Master Status HUD Cluster (Top-Left: Vector2(14, 12)) ───────────────────
	hud_cluster_root = Control.new()
	hud_cluster_root.name = "HUDStatusCluster"
	hud_cluster_root.position = UIConstants.HUD_STATUS_ROOT_POS
	hud_container.add_child(hud_cluster_root)

	# Dithered background gradient (behind cluster, activated when contrast < 3:1)
	hud_cluster_bg = TextureRect.new()
	hud_cluster_bg.name = "HUDClusterBG"
	hud_cluster_bg.texture = load(UIConstants.TEX_HUD_CLUSTER_BG)
	hud_cluster_bg.position = Vector2(-4, -4)
	hud_cluster_bg.modulate.a = 0.0 # Initialized hidden; updated via update_hud_contrast()
	hud_cluster_root.add_child(hud_cluster_bg)

	# ── 1. Custom Health Bar (HP: row of crescent icons per HUD_SCALE) ──
	hp_bar_root = Control.new()
	hp_bar_root.name = "HealthBarRoot"
	hp_bar_root.position = Vector2(0, 0)
	hud_cluster_root.add_child(hp_bar_root)

	hp_pips_container = HBoxContainer.new()
	hp_pips_container.name = "HPPipsContainer"
	hp_pips_container.add_theme_constant_override("separation", UIConstants.HUD_HP_SPACING)
	hp_bar_root.add_child(hp_pips_container)

	# ── 2. Shield Ward Row (directly under HP, no empty slots, per HUD_SCALE) ──
	shield_wards_container = HBoxContainer.new()
	shield_wards_container.name = "ShieldWardsContainer"
	shield_wards_container.position = Vector2(0, UIConstants.HUD_SHIELD_ROW_OFFSET_Y)
	shield_wards_container.add_theme_constant_override("separation", UIConstants.HUD_SHIELD_SPACING)
	hud_cluster_root.add_child(shield_wards_container)

	# ── 3. Custom Stamina Bar (Plain procedural notched frame per HUD_SCALE) ──
	stamina_bar_root = Control.new()
	stamina_bar_root.name = "StaminaBarRoot"
	stamina_bar_root.position = Vector2(0, UIConstants.HUD_STAMINA_OFFSET_Y)
	stamina_bar_root.custom_minimum_size = Vector2(UIConstants.HUD_STAMINA_WIDTH, UIConstants.HUD_STAMINA_HEIGHT)
	hud_cluster_root.add_child(stamina_bar_root)

	stamina_track_rect = ColorRect.new()
	stamina_track_rect.name = "StaminaTrackRect"
	stamina_track_rect.position = Vector2(UIConstants.HUD_STAMINA_TRACK_X, UIConstants.HUD_STAMINA_TRACK_Y)
	stamina_track_rect.size = Vector2(UIConstants.HUD_STAMINA_TRACK_WIDTH, UIConstants.HUD_STAMINA_TRACK_HEIGHT)
	stamina_track_rect.color = UIConstants.COLOR_SLATE_DARK
	stamina_bar_root.add_child(stamina_track_rect)

	stamina_fill_clip = Control.new()
	stamina_fill_clip.name = "StaminaFillClip"
	stamina_fill_clip.position = Vector2(UIConstants.HUD_STAMINA_TRACK_X, UIConstants.HUD_STAMINA_TRACK_Y)
	stamina_fill_clip.size = Vector2(UIConstants.HUD_STAMINA_TRACK_WIDTH, UIConstants.HUD_STAMINA_TRACK_HEIGHT)
	stamina_fill_clip.clip_contents = true
	stamina_bar_root.add_child(stamina_fill_clip)

	var sta_highlight := ColorRect.new()
	sta_highlight.name = "StaminaHighlight"
	sta_highlight.position = Vector2(0, 0)
	sta_highlight.size = Vector2(UIConstants.HUD_STAMINA_TRACK_WIDTH, 1.0)
	sta_highlight.color = UIConstants.COLOR_TEAL_LIGHT
	stamina_fill_clip.add_child(sta_highlight)

	var sta_body := ColorRect.new()
	sta_body.name = "StaminaBody"
	sta_body.position = Vector2(0, 1.0)
	sta_body.size = Vector2(UIConstants.HUD_STAMINA_TRACK_WIDTH, maxf(1.0, UIConstants.HUD_STAMINA_TRACK_HEIGHT - 1.0))
	sta_body.color = UIConstants.COLOR_MUTED_TEAL
	stamina_fill_clip.add_child(sta_body)

	stamina_frame_tex = TextureRect.new()
	stamina_frame_tex.name = "StaminaFrameTex"
	stamina_frame_tex.position = Vector2(0, 0)
	stamina_frame_tex.texture = load(UIConstants.TEX_HUD_STA_FRAME)
	stamina_frame_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamina_bar_root.add_child(stamina_frame_tex)

	update_hud_contrast()

	# ── 3. Top-Right Minimalist Kill Counter (Small, Bone Cream, Menu Font, 1px Charcoal Outline) ───
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(490, 12)
	score_label.size = Vector2(136, 18)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.text = "KILLS: 0"
	var menu_font = load(UIConstants.PATH_FONT_UI)
	score_label.add_theme_font_override("font", menu_font)
	score_label.add_theme_font_size_override("font_size", 9)
	score_label.add_theme_color_override("font_color", UIConstants.COLOR_BONE_CREAM)
	score_label.add_theme_color_override("font_outline_color", UIConstants.COLOR_CHARCOAL_DEEP)
	score_label.add_theme_constant_override("outline_size", 2)
	hud_container.add_child(score_label)

	# ── 4. Centered Stage Discovery (Middle of Screen, No Stars or Dashes) ────
	var cur_data = LEVELS_DATA[current_level_idx]
	# Modals (Settings & Lore Codex)
	settings_menu = SettingsMenuScript.new()
	settings_menu.name = "SettingsMenu"
	add_child(settings_menu)

	bestiary_codex_ui = BestiaryCodexUIScript.new()
	bestiary_codex_ui.name = "BestiaryCodexUI"
	add_child(bestiary_codex_ui)

	comic_story_viewer = ComicStoryViewerScript.new()
	comic_story_viewer.name = "ComicStoryViewer"
	add_child(comic_story_viewer)

	area_discovery_container = Control.new()
	area_discovery_container.name = "AreaDiscoveryContainer"
	area_discovery_container.position = Vector2(18, 286)
	area_discovery_container.size = Vector2(300, 56)
	area_discovery_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_container.add_child(area_discovery_container)

	var title_card_bg := TextureRect.new()
	title_card_bg.name = "TitleCardBG"
	title_card_bg.texture = preload("res://assets/ui/title_card_gradient.png")
	title_card_bg.position = Vector2(-12, -8)
	title_card_bg.size = Vector2(300, 64)
	title_card_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_card_bg.stretch_mode = TextureRect.STRETCH_SCALE
	title_card_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area_discovery_container.add_child(title_card_bg)

	stage_level_label = Label.new()
	stage_level_label.name = "StageLevelLabel"
	stage_level_label.position = Vector2(0, 2)
	stage_level_label.size = Vector2(280, 14)
	stage_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stage_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_level_label.text = cur_data.get("level_title", "")
	stage_level_label.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
	stage_level_label.add_theme_font_size_override("font_size", 9)
	stage_level_label.add_theme_color_override("font_color", UIThemeConstants.COLOR_MUTED_TEAL)
	stage_level_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	stage_level_label.add_theme_constant_override("shadow_offset_x", 1)
	stage_level_label.add_theme_constant_override("shadow_offset_y", 1)
	area_discovery_container.add_child(stage_level_label)

	stage_name_label = Label.new()
	stage_name_label.name = "StageNameLabel"
	stage_name_label.position = Vector2(0, 18)
	stage_name_label.size = Vector2(280, 24)
	stage_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stage_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_name_label.text = cur_data.get("scene_title", "")
	stage_name_label.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
	stage_name_label.add_theme_font_size_override("font_size", 14)
	stage_name_label.add_theme_color_override("font_color", UIThemeConstants.COLOR_BONE_CREAM)
	stage_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	stage_name_label.add_theme_constant_override("shadow_offset_x", 1)
	stage_name_label.add_theme_constant_override("shadow_offset_y", 1)
	stage_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.90))
	stage_name_label.add_theme_constant_override("outline_size", 2)
	area_discovery_container.add_child(stage_name_label)

	trigger_area_discovery()

	# ── 5. Respawn & Checkpoint Message Banner (Clean, Centered) ──────────────
	respawn_label = Label.new()
	respawn_label.name = "RespawnLabel"
	respawn_label.position = Vector2(0, 182)
	respawn_label.size = Vector2(640, 28)
	respawn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	respawn_label.text = ""
	if is_instance_valid(respawn_label):
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

	# ── 6. Full-Screen Damage Flash Overlay (#8a3b32 Muted Brick Red) ────────
	damage_flash_overlay = ColorRect.new()
	damage_flash_overlay.name = "DamageFlashOverlay"
	damage_flash_overlay.color = Color(0.541, 0.231, 0.196, 0.0)
	damage_flash_overlay.size = Vector2(640, 360)
	damage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(damage_flash_overlay)

	# ── 6b. Pulsating Low-HP Attrition Vignette (#8a3b32 Muted Brick Red) ────
	low_hp_vignette = ColorRect.new()
	low_hp_vignette.name = "LowHpVignette"
	low_hp_vignette.color = Color(0.541, 0.231, 0.196, 0.0)
	low_hp_vignette.size = Vector2(640, 360)
	low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(low_hp_vignette)

	# ── 7. Full-Screen Fade-to-Black Overlay ──────────────────────────────────
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.color = Color(0, 0, 0, 0.0)
	fade_overlay.size = Vector2(640, 360)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(fade_overlay)

	# ── 8. Game Victory & Moon Restoration Epilogue Overlay ───────────────────
	win_overlay = ColorRect.new()
	win_overlay.name = "WinOverlay"
	win_overlay.color = Color(0.02, 0.04, 0.09, 0.88)
	win_overlay.size = Vector2(640, 360)
	if is_instance_valid(win_overlay):
		win_overlay.visible = false
	ui_layer.add_child(win_overlay)

	var epilogue_panel := PanelContainer.new()
	epilogue_panel.name = "EpiloguePanel"
	epilogue_panel.position = Vector2(70, 22)
	epilogue_panel.size = Vector2(500, 316)
	var ep_sb := StyleBoxFlat.new()
	ep_sb.bg_color = Color(0.05, 0.08, 0.15, 0.96)
	ep_sb.border_color = Color(0.58, 0.82, 1.0, 0.92)
	ep_sb.border_width_left = 2
	ep_sb.border_width_right = 2
	ep_sb.border_width_top = 2
	ep_sb.border_width_bottom = 2
	ep_sb.content_margin_left = 20
	ep_sb.content_margin_right = 20
	ep_sb.content_margin_top = 16
	ep_sb.content_margin_bottom = 16
	epilogue_panel.add_theme_stylebox_override("panel", ep_sb)
	win_overlay.add_child(epilogue_panel)

	var ep_vbox := VBoxContainer.new()
	ep_vbox.add_theme_constant_override("separation", 8)
	epilogue_panel.add_child(ep_vbox)

	var ep_title := Label.new()
	ep_title.text = "THE SEVENTH MOON RESTORED"
	ep_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ep_title.add_theme_font_override("font", custom_font)
	ep_title.add_theme_font_size_override("font_size", 22)
	ep_title.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0, 1.0))
	ep_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	ep_title.add_theme_constant_override("shadow_offset_x", 2)
	ep_title.add_theme_constant_override("shadow_offset_y", 2)
	ep_vbox.add_child(ep_title)

	var ep_lore := Label.new()
	ep_lore.text = "Bakunawa retreats into the abyssal trenches, releasing the last devoured moon.\nSilver starlight bathes Ibalong once more, and Haliya's vigil is fulfilled."
	ep_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ep_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ep_lore.add_theme_font_override("font", custom_font)
	ep_lore.add_theme_font_size_override("font_size", 12)
	ep_lore.add_theme_color_override("font_color", Color(0.84, 0.88, 0.96, 0.92))
	ep_vbox.add_child(ep_lore)

	win_label = Label.new()
	win_label.name = "WinLabel"
	win_label.text = ""
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	win_label.add_theme_font_override("font", custom_font)
	win_label.add_theme_font_size_override("font_size", 14)
	win_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.48, 1.0))
	win_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	win_label.add_theme_constant_override("shadow_offset_x", 1)
	win_label.add_theme_constant_override("shadow_offset_y", 1)
	ep_vbox.add_child(win_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 18)
	ep_vbox.add_child(btn_row)

	var btn_loop := Button.new()
	btn_loop.text = "  THE INFINITE ECLIPSE (LOOP 2+)  "
	btn_loop.custom_minimum_size = Vector2(210, 30)
	btn_loop.add_theme_font_override("font", custom_font)
	btn_loop.add_theme_font_size_override("font_size", 13)
	btn_loop.pressed.connect(func():
		UpgradeManager.begin_new_loop()
		restart_game()
	)
	btn_row.add_child(btn_loop)

	var btn_again := Button.new()
	btn_again.text = "  FRESH RUN (R)  "
	btn_again.custom_minimum_size = Vector2(150, 30)
	btn_again.add_theme_font_override("font", custom_font)
	btn_again.add_theme_font_size_override("font_size", 13)
	btn_again.pressed.connect(func(): restart_game())
	btn_row.add_child(btn_again)

	var btn_menu := Button.new()
	btn_menu.text = "  RETURN TO TITLE  "
	btn_menu.custom_minimum_size = Vector2(170, 30)
	btn_menu.add_theme_font_override("font", custom_font)
	btn_menu.add_theme_font_size_override("font_size", 13)
	btn_menu.pressed.connect(func():
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	btn_row.add_child(btn_menu)

	setup_pause_menu()
	setup_boss_hud()
	setup_auto_save_indicator()
	setup_stage_progress_tracker()
	_update_hp_bar_display(false)

	upgrade_select_ui = UpgradeSelectUIScript.new()
	upgrade_select_ui.name = "UpgradeSelectUI"
	add_child(upgrade_select_ui)
	upgrade_select_ui.upgrade_selected.connect(_on_upgrade_selected)

	game_over_ui = GameOverUIScript.new()
	game_over_ui.name = "GameOverUI"
	add_child(game_over_ui)
	game_over_ui.restart_run_requested.connect(_on_restart_run_requested)
	game_over_ui.return_to_title_requested.connect(_on_return_to_title_requested)


func setup_auto_save_indicator() -> void:
	if not is_instance_valid(ui_layer):
		return
	if is_instance_valid(auto_save_indicator):
		return
	auto_save_indicator = Control.new()
	auto_save_indicator.name = "AutoSaveIndicator"
	auto_save_indicator.anchor_left = 1.0
	auto_save_indicator.anchor_right = 1.0
	auto_save_indicator.anchor_top = 0.0
	auto_save_indicator.anchor_bottom = 0.0
	auto_save_indicator.offset_left = -115.0
	auto_save_indicator.offset_right = -15.0
	auto_save_indicator.offset_top = 34.0
	auto_save_indicator.offset_bottom = 56.0
	auto_save_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	auto_save_indicator.visible = false
	auto_save_indicator.modulate = Color(1, 1, 1, 0)
	ui_layer.add_child(auto_save_indicator)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_END
	hbox.add_theme_constant_override("separation", 6)
	auto_save_indicator.add_child(hbox)

	var moon_tex = load("res://assets/ui/crescent_moon.png") as Texture2D
	if moon_tex:
		var moon_icon := TextureRect.new()
		moon_icon.name = "MoonIcon"
		moon_icon.texture = moon_tex
		moon_icon.custom_minimum_size = Vector2(16, 16)
		moon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		moon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		moon_icon.pivot_offset = Vector2(8, 8)
		hbox.add_child(moon_icon)

	var save_lbl := Label.new()
	save_lbl.name = "SaveText"
	save_lbl.text = "SAVED"
	save_lbl.add_theme_font_override("font", load("res://alagard.ttf"))
	save_lbl.add_theme_font_size_override("font_size", 12)
	save_lbl.add_theme_color_override("font_color", Color(0.92, 0.86, 0.68, 1.0))
	save_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	save_lbl.add_theme_constant_override("shadow_offset_x", 1)
	save_lbl.add_theme_constant_override("shadow_offset_y", 1)
	hbox.add_child(save_lbl)


func show_auto_save_indicator() -> void:
	if not is_instance_valid(auto_save_indicator):
		return
	if auto_save_tween and auto_save_tween.is_valid():
		auto_save_tween.kill()

	auto_save_indicator.visible = true
	var moon = auto_save_indicator.find_child("MoonIcon", true, false) as TextureRect

	auto_save_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	auto_save_tween.tween_property(auto_save_indicator, "modulate:a", 1.0, 0.25)
	if moon:
		moon.rotation = 0.0
		auto_save_tween.parallel().tween_property(moon, "rotation", TAU, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	auto_save_tween.tween_interval(1.2)
	auto_save_tween.tween_property(auto_save_indicator, "modulate:a", 0.0, 0.45)
	auto_save_tween.tween_callback(func():
		if is_instance_valid(auto_save_indicator):
			auto_save_indicator.visible = false
	)


func setup_stage_progress_tracker() -> void:
	if not is_instance_valid(hud_container):
		return
	if is_instance_valid(stage_progress_root):
		return

	level_progress_bar = LevelProgressBarScript.new()
	level_progress_bar.name = "LevelProgressBar"
	stage_progress_root = level_progress_bar
	hud_container.add_child(stage_progress_root)

	# Expose references for tests and compatibility
	progress_bar_fill = level_progress_bar.progress_bar_fill_rect
	progress_player_pin = level_progress_bar.marker_rect
	progress_shrine_pin = level_progress_bar.icon_shrine


func update_stage_progress_tracker() -> void:
	if not is_instance_valid(stage_progress_root) or not is_instance_valid(player):
		return
	var terrain_w = maxf(1000.0, current_level_width)
	var ratio = clampf(player.global_position.x / terrain_w, 0.0, 1.0)
	var checkpoint_r = clampf(BOSS_CHECKPOINT_X / terrain_w, 0.0, 1.0)

	if is_instance_valid(level_progress_bar):
		level_progress_bar.update_progress(ratio, checkpoint_r)
	elif is_instance_valid(progress_bar_fill):
		progress_bar_fill.size.x = ratio * UIConstants.HUD_PROGRESS_LINE_WIDTH


func setup_boss_hud() -> void:
	if not is_instance_valid(hud_container):
		hud_container = Control.new()
		hud_container.name = "HUDContainer"
		hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(hud_container)

	boss_hud_root = Control.new()
	boss_hud_root.name = "BossHUDRoot"
	boss_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.modulate.a = 0.0
	boss_hud_root.visible = false
	hud_container.add_child(boss_hud_root)

	var custom_font = load("res://alagard.ttf")

	# Bottom Center Anchor Container - Always centered on any screen size/stretch
	var bottom_box := Control.new()
	bottom_box.name = "BossBottomBox"
	bottom_box.anchor_left = 0.5
	bottom_box.anchor_right = 0.5
	bottom_box.anchor_top = 1.0
	bottom_box.anchor_bottom = 1.0
	bottom_box.offset_left = -210.0
	bottom_box.offset_right = 210.0
	bottom_box.offset_top = -56.0
	bottom_box.offset_bottom = -12.0
	bottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_hud_root.add_child(bottom_box)

	# 1. Main Title Label (Clean Roman Font, no Baybayin)
	boss_title_label = Label.new()
	boss_title_label.name = "BossTitle"
	boss_title_label.text = "CORRUPTED SENTINEL: FOREST BRUTE"
	boss_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_title_label.add_theme_font_override("font", custom_font)
	boss_title_label.add_theme_font_size_override("font_size", 12)
	boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	boss_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	boss_title_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_title_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_title_label.position = Vector2(0, 0)
	boss_title_label.size = Vector2(420, 16)
	bottom_box.add_child(boss_title_label)

	# 1b. Enraged Seal Badge (Pulsing fiery seal for Phase 2)
	boss_enraged_badge = Label.new()
	boss_enraged_badge.name = "BossEnragedBadge"
	boss_enraged_badge.text = "[ ENRAGED ]"
	boss_enraged_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_enraged_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_enraged_badge.add_theme_font_override("font", custom_font)
	boss_enraged_badge.add_theme_font_size_override("font_size", 10)
	boss_enraged_badge.add_theme_color_override("font_color", Color(1.0, 0.28, 0.28, 1.0))
	boss_enraged_badge.add_theme_color_override("font_shadow_color", Color(0.3, 0.0, 0.0, 1.0))
	boss_enraged_badge.add_theme_constant_override("shadow_offset_x", 1)
	boss_enraged_badge.add_theme_constant_override("shadow_offset_y", 1)
	boss_enraged_badge.add_theme_color_override("font_outline_color", Color(1.0, 0.8, 0.2, 0.85))
	boss_enraged_badge.add_theme_constant_override("outline_size", 1)
	boss_enraged_badge.position = Vector2(330, 0)
	boss_enraged_badge.size = Vector2(80, 16)
	boss_enraged_badge.visible = false
	bottom_box.add_child(boss_enraged_badge)

	# 2. Outer Dark Obsidian Frame
	var bar_frame = ColorRect.new()
	bar_frame.name = "BossBarFrame"
	bar_frame.position = Vector2(18, 18)
	bar_frame.size = Vector2(384, 16)
	bar_frame.color = Color(0.04, 0.05, 0.07, 0.96)
	bottom_box.add_child(bar_frame)

	# 3. Gilded Gold Filigree Border
	var border_rect = ReferenceRect.new()
	border_rect.position = Vector2(18, 18)
	border_rect.size = Vector2(384, 16)
	border_rect.border_color = Color(0.72, 0.60, 0.35, 1.0)
	border_rect.border_width = 1.0
	border_rect.editor_only = false
	bottom_box.add_child(border_rect)

	# Decorative Left & Right Diamond Jewels
	for side in [-1.0, 1.0]:
		var dia = Polygon2D.new()
		dia.polygon = PackedVector2Array([Vector2(-3.5, 0), Vector2(0, -3.5), Vector2(3.5, 0), Vector2(0, 3.5)])
		dia.color = Color(0.92, 0.78, 0.42, 1.0)
		dia.position = Vector2(18 if side < 0 else 402, 26)
		bottom_box.add_child(dia)

	# 4. Background Channel
	var bar_bg = ColorRect.new()
	bar_bg.position = Vector2(20, 20)
	bar_bg.size = Vector2(380, 12)
	bar_bg.color = Color(0.12, 0.04, 0.06, 0.88)
	bottom_box.add_child(bar_bg)

	# 5. Amber Ghost Lag Bar
	boss_hp_ghost = ColorRect.new()
	boss_hp_ghost.name = "BossHPGhost"
	boss_hp_ghost.position = Vector2(20, 20)
	boss_hp_ghost.size = Vector2(380, 12)
	boss_hp_ghost.color = Color(1.0, 0.78, 0.28, 0.95)
	bottom_box.add_child(boss_hp_ghost)

	# 6. Primary HP Fill
	boss_hp_fill = ColorRect.new()
	boss_hp_fill.name = "BossHPFill"
	boss_hp_fill.position = Vector2(20, 20)
	boss_hp_fill.size = Vector2(380, 12)
	boss_hp_fill.color = Color(0.20, 0.83, 0.60, 1.0)
	bottom_box.add_child(boss_hp_fill)

	# 7. 10% Phase Threshold Notch (20 + round(380 * 0.10) = 58)
	boss_phase_notch = Control.new()
	boss_phase_notch.name = "BossPhaseNotch"
	boss_phase_notch.position = Vector2(58, 18)
	boss_phase_notch.size = Vector2(2, 16)
	bottom_box.add_child(boss_phase_notch)

	var notch_line = ColorRect.new()
	notch_line.position = Vector2(0, 1)
	notch_line.size = Vector2(1.5, 14)
	notch_line.color = Color(0.85, 0.75, 0.40, 0.95)
	boss_phase_notch.add_child(notch_line)

	var notch_gem = Polygon2D.new()
	notch_gem.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2.5), Vector2(2, 0), Vector2(0, 2.5)])
	notch_gem.color = Color(1.0, 0.88, 0.45, 1.0)
	notch_gem.position = Vector2(1, 0)
	boss_phase_notch.add_child(notch_gem)

	# 8. Numeric HP Percentage Readout (Centered in bar)
	boss_hp_num_label = Label.new()
	boss_hp_num_label.name = "BossHPNumLabel"
	boss_hp_num_label.text = "100%"
	boss_hp_num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_hp_num_label.add_theme_font_override("font", custom_font)
	boss_hp_num_label.add_theme_font_size_override("font_size", 9)
	boss_hp_num_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	boss_hp_num_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	boss_hp_num_label.add_theme_constant_override("shadow_offset_x", 1)
	boss_hp_num_label.add_theme_constant_override("shadow_offset_y", 1)
	boss_hp_num_label.position = Vector2(20, 18)
	boss_hp_num_label.size = Vector2(380, 16)
	bottom_box.add_child(boss_hp_num_label)


func setup_pause_menu() -> void:
	pause_overlay = PauseMenuScreenScene.instantiate()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.visible = false
	ui_layer.add_child(pause_overlay)

	pause_overlay.resume_requested.connect(toggle_pause)
	pause_overlay.restart_requested.connect(func():
		toggle_pause()
		load_current_level()
		spawn_level_enemies()
		respawn_player_at_checkpoint()
	)
	pause_overlay.save_and_quit_requested.connect(func():
		SaveManager.save_game(SaveManager.active_slot, self)
		Engine.time_scale = 1.0
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)


func toggle_pause() -> void:
	if is_game_won or is_transitioning:
		return
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	if is_instance_valid(hud_container):
		hud_container.visible = !is_paused and is_ui_visible
	if is_instance_valid(pause_overlay):
		if is_paused:
			if pause_overlay.has_method("open_menu"):
				pause_overlay.open_menu()
			else:
				pause_overlay.visible = true
		else:
			if pause_overlay.has_method("close_menu"):
				pause_overlay.close_menu()
			else:
				pause_overlay.visible = false


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
			jump_to_level(8)  # Jump directly to Stage 3: Rainy Forest (Level 3-1: Drenched Foothills)
		elif event.keycode == KEY_4 or event.keycode == KEY_KP_4:
			jump_to_level(13) # Jump directly to Stage 4: Cave (Level 4-1: Bioluminescent Threshold)
		elif event.keycode == KEY_5 or event.keycode == KEY_KP_5:
			jump_to_level(17) # Jump directly to Stage 5: Bakunawa's Abyss (Level 5: The Moon Devourer)
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
	if is_instance_valid(win_overlay):
		win_overlay.visible = false
	trigger_area_discovery()
	update_score_hud()


func _process(delta: float) -> void:
	if is_game_won and Input.is_action_just_pressed("restart"):
		restart_game()
		return

	if is_game_won:
		return



	# Micro hit-stop and parry slow-mo recovery (unified unscaled time tracking)
	var real_delta: float = delta / maxf(0.01, Engine.time_scale)
	if hit_stop_timer > 0.0:
		hit_stop_timer -= real_delta
		if hit_stop_timer <= 0.0:
			hit_stop_timer = 0.0
			Engine.time_scale = 0.28 if slowmo_timer > 0.0 else 1.0
	elif slowmo_timer > 0.0:
		slowmo_timer -= real_delta
		if slowmo_timer <= 0.0:
			slowmo_timer = 0.0
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

	var rf_offset_y: float = max(0.0, (get_viewport_rect().size.y - 360.0) * 0.5)
	for r_layer in rice_field_parallax_layers:
		if is_instance_valid(r_layer) and r_layer.motion_offset.y != rf_offset_y:
			r_layer.motion_offset.y = rf_offset_y

	if player:
		# Camera position follow (with smooth framing inside boss & miniboss arenas)
		var cam_min_x: float = 320.0
		var cam_max_x: float = current_level_width - 320.0
		var cam_min_y: float = 180.0
		var cam_max_y: float = max(180.0, current_level_height - 180.0)
		if is_boss_active:
			cam_min_x = 4080.0
			cam_max_x = 4760.0
		elif is_miniboss_arena_locked:
			cam_min_x = 4300.0
			cam_max_x = 4760.0
		var target_x: float = clamp(player.global_position.x, cam_min_x, cam_max_x)
		var target_y: float = clamp(player.global_position.y, cam_min_y, cam_max_y)
		camera.global_position = Vector2(target_x, target_y)

		# Screen shake decay
		if trauma > 0.0:
			trauma = max(0.0, trauma - TRAUMA_DECAY * delta)
			var shake: float = trauma * trauma * GameSettings.screen_shake_intensity
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
		SaveManager.active_run_play_time += delta
		update_stage_progress_tracker()
		_update_hud_status_process(delta)

		# Map Edge Level Transition & Pre-Boss Checkpoint Trigger
		if not is_transitioning:
			if current_level_idx in [2, 7, 12, 16, 17] and not has_activated_boss_checkpoint and not is_player_dead:
				if player.global_position.x >= BOSS_CHECKPOINT_X - 40.0:
					_activate_boss_checkpoint_shrine()

			if is_instance_valid(boss_checkpoint_shrine) and not is_player_dead:
				var shrine_dist = abs(player.global_position.x - boss_checkpoint_shrine.global_position.x)
				var prompt = boss_checkpoint_shrine.get_node_or_null("ShrinePromptLabel") as Label
				if shrine_dist < 60.0:
					if prompt:
						prompt.visible = true
					if Input.is_action_just_pressed("interact") or (Input.is_key_pressed(KEY_W) and Input.is_action_just_pressed("jump")):
						meditate_at_shrine()
				else:
					if prompt:
						prompt.visible = false

			var cur_title_chk = LEVELS_DATA[current_level_idx].get("level_title", "")
			if (cur_title_chk in ["Level 1-3", "Level 2-5", "Level 4-4"]) and not is_miniboss_arena_locked and not is_player_dead:
				if player.global_position.x >= 4050.0:
					trigger_miniboss_arena_lockdown()

			if cur_title_chk == "Level 3-5":
				if not is_boss_active and player.global_position.x >= 3800.0:
					start_boss_encounter()
			elif cur_title_chk == "Level 5":
				if not is_boss_active and player.global_position.x >= 3800.0:
					start_bakunawa_encounter()
			elif player.global_position.x >= current_level_transition_x:
				start_level_transition()

		# Exit barrier proximity feedback
		if exit_barrier_body and is_instance_valid(exit_barrier_body) and not is_transitioning:
			var dist_to_barrier = exit_barrier_body.global_position.x - player.global_position.x
			if dist_to_barrier > 0.0 and dist_to_barrier < 160.0:
				if exit_prompt_timer <= 0.0 or not is_instance_valid(exit_prompt_label) or not exit_prompt_label.visible:
					show_exit_banner("Defeat all enemies to proceed!", Color(1.0, 0.4, 0.4, 1.0))

		# Water hazard / pit drop detection (falling off ground)
		var pit_death_y: float = current_level_height if current_level_height > 360.0 else 360.0
		if not is_transitioning and not is_player_dead:
			if player.global_position.y > pit_death_y:
				_on_player_died()

	# Continuous scan for enemies falling down the map / into pits
	if active_enemies.size() > 0:
		var enemies_to_kill: Array[Node] = []
		var enemy_pit_death_y: float = current_level_height if current_level_height > 360.0 else 360.0
		for e in active_enemies:
			if is_instance_valid(e) and not e.get("is_dead"):
				if e.global_position.y > enemy_pit_death_y:
					enemies_to_kill.append(e)
		for e in enemies_to_kill:
			if e.has_method("take_damage"):
				e.take_damage(999, 0.0)
			elif e.has_method("shatter_death"):
				e.shatter_death(1.0)
			elif e.has_method("trigger_death"):
				e.trigger_death()

	# Respawn Banner Timer
	if respawn_msg_timer > 0.0:
		respawn_msg_timer -= delta
		var alpha: float = clamp(respawn_msg_timer / 0.5, 0.0, 1.0)
		respawn_label.modulate = Color(1, 1, 1, alpha)
		if respawn_msg_timer <= 0.0:
			if is_instance_valid(respawn_label):
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
	var is_lvl_2_3: bool = (current_data.get("level_title", "") == "Level 2-5")
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

	# Level 2-5 Dynamic Storm Transition: Rains only AFTER defeating the boss
	if is_lvl_2_3:
		if is_stage_2_boss_defeated:
			current_storm_intensity = 1.0

			# Sky sprite modulate: dark storm clouds
			if sky_sprite:
				sky_sprite.modulate = Color(0.35, 0.40, 0.52, 1.0)

			# World lighting
			base_modulate_color = Color(0.29, 0.32, 0.43, 1.0)

			# Multi-layer rain particles
			if rain_particles and not rain_particles.emitting:
				rain_particles.emitting = true
				rain_particles.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if rain_particles_bg and not rain_particles_bg.emitting:
				rain_particles_bg.emitting = true
				rain_particles_bg.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if rain_particles_fg and not rain_particles_fg.emitting:
				rain_particles_fg.emitting = true
				rain_particles_fg.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if rain_splashes and not rain_splashes.emitting:
				rain_splashes.emitting = true
				rain_splashes.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if storm_fog and not storm_fog.emitting:
				storm_fog.emitting = true
				storm_fog.modulate = Color(1.0, 1.0, 1.0, 1.0)

			# Storm vignette
			if storm_vignette:
				storm_vignette.modulate.a = 0.65

			# Rain ambient motes
			if ambient_particles:
				ambient_particles.color = Color(0.8, 0.9, 1.0, 0.35)

			# Distant sheet lightning in storm
			if not is_transitioning:
				sheet_lightning_timer -= delta
				if sheet_lightning_timer <= 0.0:
					trigger_sheet_lightning(5.5, 9.5)
		else:
			# Boss not defeated yet: keep Stage 2 dry & fiery (no rain)
			current_storm_intensity = 0.0
			if rain_particles and rain_particles.emitting: rain_particles.emitting = false
			if rain_particles_fg and rain_particles_fg.emitting: rain_particles_fg.emitting = false
			if rain_particles_bg and rain_particles_bg.emitting: rain_particles_bg.emitting = false
			if rain_splashes and rain_splashes.emitting: rain_splashes.emitting = false
			if storm_fog and storm_fog.emitting: storm_fog.emitting = false
			if storm_vignette and storm_vignette.modulate.a != 0.0: storm_vignette.modulate.a = 0.0
	elif is_rainy_forest:
		current_storm_intensity = 1.0
		var sub_level: float = clamp(float(current_level_idx - 8), 0.0, 4.0) # 0 to 4
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
		var is_cave_theme: bool = (current_theme == "Cave" or current_theme == "Cave Boss")
		if rain_particles and rain_particles.emitting:
			rain_particles.emitting = false
		if rain_particles_fg and rain_particles_fg.emitting:
			rain_particles_fg.emitting = false
		if rain_particles_bg and rain_particles_bg.emitting:
			rain_particles_bg.emitting = false
		if rain_splashes and rain_splashes.emitting:
			rain_splashes.emitting = false
		if storm_fog:
			if is_cave_theme:
				if not storm_fog.emitting:
					storm_fog.emitting = true
				storm_fog.modulate = Color(0.38, 0.72, 1.0, 0.36)
			elif storm_fog.emitting:
				storm_fog.emitting = false
		if storm_vignette:
			var target_vig: float = 0.0
			if storm_vignette.modulate.a != target_vig:
				storm_vignette.modulate.a = target_vig
		if sky_sprite and not is_cave_theme and sky_sprite.modulate != Color(1, 1, 1, 1):
			sky_sprite.modulate = Color(1, 1, 1, 1)

	if lens_rain_overlay:
		lens_rain_overlay.set_storm_active(is_rainy_forest or (is_lvl_2_3 and is_stage_2_boss_defeated), current_storm_intensity)

	# Delayed thunder audio rumble
	if thunder_rumble_timer > 0.0:
		thunder_rumble_timer -= delta
		if thunder_rumble_timer <= 0.0:
			if is_inside_tree() and thunder_audio_player and thunder_audio_player.is_inside_tree() and thunder_audio_player.stream:
				if thunder_audio_player.stream.resource_path.ends_with("lightning_rumble.wav"):
					thunder_audio_player.pitch_scale = randf_range(0.92, 1.08)
					thunder_audio_player.volume_db = randf_range(-1.0, 2.0)
				else:
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
	var desired_x: float = clamp(player.global_position.x + offset_x, 150.0, LEVEL_WIDTH - 150.0)
	var strike_pos: Vector2 = find_valid_ground_strike_position(desired_x)
	if strike_pos == Vector2.ZERO:
		return # Discard strikes over pits, edges, or water

	var hazard = LightningHazardScript.new()
	hazard.target_position = strike_pos
	hazard.strike_occurred.connect(_on_lightning_hazard_struck)
	lightning_container.add_child(hazard)


func _on_lightning_hazard_struck(strike_pos: Vector2, _damage: int) -> void:
	lightning_flash_timer = 0.24
	lightning_flash_intensity = 1.0
	apply_hit_stop(0.045)
	flash_puddles(0.26)
	if thunder_rumble_timer <= 0.0:
		thunder_rumble_timer = randf_range(0.18, 0.32)

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
		# Elegant golden glow shimmer
		stage_name_label.modulate = Color(1.4, 1.3, 0.9, 1.0)
		var tw = stage_name_label.create_tween()
		tw.tween_property(stage_name_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
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

	# Show Upgrade Selection Shrine
	var draft = UpgradeManager.draft_upgrades(3)
	if not draft.is_empty() and is_instance_valid(upgrade_select_ui):
		upgrade_select_ui.display_draft(draft, UpgradeManager.current_tier)
	else:
		_proceed_to_next_level()


func _on_upgrade_selected(upgrade_id: String) -> void:
	UpgradeManager.apply_upgrade(upgrade_id, player)
	var cur_lvl_title = LEVELS_DATA[current_level_idx].get("level_title", "")
	UpgradeManager.advance_tier(cur_lvl_title)
	_proceed_to_next_level()


func _proceed_to_next_level() -> void:
	# Advance to next level
	current_level_idx += 1
	load_current_level()
	spawn_level_enemies()

	# Reposition player to spawn point and restore full health & stamina
	if player:
		UpgradeManager.sync_player_stats(player)
		player.global_position = SPAWN_POS
		player.velocity = Vector2.ZERO
		last_player_x = SPAWN_POS.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state(false) # Retain damage across levels (true attrition!)
		camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, current_level_width - 320.0), 180.0)

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
	if score_label and total_kills != _last_cached_kills:
		_last_cached_kills = total_kills
		score_label.text = "KILLS: %d" % total_kills


# ── Player Death & Respawn State ───────────────────────────────────────────────
func _on_player_died() -> void:
	if is_player_dead:
		return
	is_player_dead = true
	death_count += 1
	Engine.time_scale = 1.0
	hit_stop_timer = 0.0

	if is_instance_valid(bgm_audio_player) and bgm_audio_player.playing:
		var tw_bgm = create_tween()
		tw_bgm.tween_property(bgm_audio_player, "volume_db", -50.0, 0.8)
		tw_bgm.tween_callback(func():
			if is_instance_valid(bgm_audio_player):
				bgm_audio_player.stop()
		)

	if is_instance_valid(boss_hud_root):
		boss_hud_root.visible = false
		boss_hud_root.modulate.a = 0.0

	# Stop player physics and dissolve character smoothly
	if is_instance_valid(player):
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		var tw_player = create_tween()
		tw_player.tween_property(player, "modulate:a", 0.0, 0.40)
		tw_player.tween_callback(func():
			if is_instance_valid(player):
				player.visible = false
		)

	# Stop active world enemies
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			if enemy.has_method("set_physics_process"):
				enemy.set_physics_process(false)
			if enemy.has_node("AnimationPlayer"):
				var ap: AnimationPlayer = enemy.get_node("AnimationPlayer")
				if ap:
					ap.pause()

	var cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
	var elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
	if is_instance_valid(game_over_ui):
		var stats_data = {
			"deepest_stage": cur_title,
			"kills": UpgradeManager.total_kills_this_run,
			"elapsed_sec": elapsed,
			"bosses_defeated": bosses_slain_this_run,
			"parries": parries_this_run,
			"pearls": pearls_collected_this_run,
			"stage_idx": current_level_idx,
			"upgrades": UpgradeManager.active_upgrades
		}
		game_over_ui.display_defeat(stats_data)
	else:
		respawn_player_at_checkpoint()
		show_respawn_message()


func _on_restart_run_requested() -> void:
	has_activated_boss_checkpoint = false
	restart_game()


func _on_return_to_title_requested() -> void:
	Engine.time_scale = 1.0
	if is_inside_tree() and get_tree():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func respawn_player_at_checkpoint() -> void:
	clear_miniboss_arena()
	if is_boss_active:
		is_boss_active = false
		clear_boss_arena_barriers()
		if is_instance_valid(boss_instance):
			boss_instance.queue_free()
			boss_instance = null
		if is_instance_valid(boss_hud_root):
			boss_hud_root.visible = false
			boss_hud_root.modulate.a = 0.0
		var cur_theme = LEVELS_DATA[current_level_idx].get("theme", "")
		if cur_theme == "Cave" or cur_theme == "Cave Boss":
			play_bgm(ProceduralAudio.get_cave_ambient(), "cave", 1.0)
		elif cur_theme == "Rainy Forest":
			play_bgm(ProceduralAudio.get_tempest_ambient(), "tempest", 1.0)
		elif cur_theme == "Rice Field":
			play_bgm(ProceduralAudio.get_rice_field_ambient(), "rice_field", 1.0)
		else:
			play_bgm(ProceduralAudio.get_forest_ambient(), "forest", 1.0)

	if player:
		var target_spawn: Vector2 = Vector2(BOSS_CHECKPOINT_X, 260.0) if has_activated_boss_checkpoint else SPAWN_POS
		player.global_position = target_spawn
		player.velocity = Vector2.ZERO
		player.visible = true
		player.modulate = Color(1, 1, 1, 1)
		player.set_physics_process(true)
		is_player_dead = false
		last_player_x = player.global_position.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()


func show_respawn_message() -> void:
	if not is_instance_valid(respawn_label):
		return
	if has_activated_boss_checkpoint:
		respawn_label.text = "Respawned at Ancestral Shrine: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
	else:
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
	save_progress(0)
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
		"Time Elapsed:          %02d:%02d\n" % [minutes, seconds]
		+ "Distance Traversed:    %d m\n" % dist_m
		+ "Nightmares Vanquished: %d\n" % total_kills
		+ "Falls & Respawns:      %d\n" % death_count
		+ "Realms Liberated:      %d / %d" % [LEVELS_DATA.size(), LEVELS_DATA.size()]
	)
	win_overlay.visible = true



func restart_game() -> void:
	UpgradeManager.reset_run()
	if is_instance_valid(game_over_ui):
		if game_over_ui.has_method("reset"):
			game_over_ui.reset()
		else:
			game_over_ui.visible = false
	if is_instance_valid(upgrade_select_ui):
		upgrade_select_ui.visible = false
	is_game_won = false
	is_player_dead = false
	is_stage_2_boss_defeated = false
	has_seen_boss_encounter_cutscene = false
	has_seen_boss_defeat_cutscene = false
	has_activated_boss_checkpoint = false
	is_transitioning = false
	if is_instance_valid(win_overlay):
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

	if is_instance_valid(respawn_label):
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
func _update_hud_status_process(delta: float) -> void:
	# 1. Stamina 2.0s full hold -> 40% opacity fade
	if is_instance_valid(stamina_bar_root) and is_instance_valid(player):
		var p_sta = player.get("current_stamina")
		var p_max_sta = player.get("max_stamina")
		if p_sta != null and p_max_sta != null and p_sta >= p_max_sta - 0.05:
			if not GameSettings.reduce_motion:
				stamina_full_timer += delta
				if stamina_full_timer >= UIConstants.HUD_STAMINA_FULL_HOLD_SEC:
					if stamina_bar_root.modulate.a > UIConstants.HUD_STAMINA_FADED_ALPHA + 0.01:
						if stamina_fade_tween == null or not stamina_fade_tween.is_valid():
							stamina_fade_tween = create_tween()
							stamina_fade_tween.tween_property(stamina_bar_root, "modulate:a", UIConstants.HUD_STAMINA_FADED_ALPHA, 0.40)
			else:
				stamina_bar_root.modulate.a = 1.0
		else:
			stamina_full_timer = 0.0
			if is_instance_valid(stamina_fade_tween) and stamina_fade_tween.is_valid():
				stamina_fade_tween.kill()
			if stamina_bar_root.modulate.a < 1.0:
				stamina_bar_root.modulate.a = 1.0

	# 2. Critical 1 HP stepped pulse: "At 1 HP the last full crescent pulses between hp_full and a 70%-opacity copy (2-frame, stepped, slow)."
	if _cur_hp_cached == 1 and _cur_arm_cached <= 0 and is_instance_valid(hp_pips_container) and hp_pips_container.get_child_count() > 0:
		var p0 = hp_pips_container.get_child(0) as TextureRect
		if is_instance_valid(p0) and not p0.has_meta("is_holding_damaged"):
			if GameSettings.reduce_motion:
				p0.modulate = Color(1, 1, 1, 1)
			else:
				hp_pulse_timer += delta
				if hp_pulse_timer >= UIConstants.HUD_LOW_HP_PULSE_SEC:
					hp_pulse_timer = 0.0
					hp_pulse_frame = 1 - hp_pulse_frame
					p0.modulate = Color(1, 1, 1, 0.70 if hp_pulse_frame == 1 else 1.0)


func update_hud_contrast(force_bright: Variant = null) -> void:
	if not is_instance_valid(hud_cluster_bg):
		return
	var is_bright: bool
	if force_bright != null:
		is_bright = bool(force_bright)
	else:
		var cur_theme: String = LEVELS_DATA[current_level_idx].get("theme", "") if current_level_idx < LEVELS_DATA.size() else ""
		# Bright scenes: Rice Field daytime (sky background luminance ~0.65 vs bone cream L ~0.77 yields contrast 1.17:1 < 3:1)
		# Dark scenes: Forest, Cave, Abyss (background luminance <= 0.15 vs bone cream yields contrast > 4.5:1)
		is_bright = (cur_theme == "Rice Field")

	# Enable subtle dark dithered gradient ONLY when contrast drops below 3:1
	hud_cluster_bg.modulate.a = 1.0 if is_bright else 0.0


func _update_hp_bar_display(was_damage: bool = false, prev_hp: int = -1) -> void:
	if not is_instance_valid(hp_pips_container):
		return

	var total_base: int = _max_hp_cached
	var cur_hp: int = clampi(_cur_hp_cached, 0, total_base)
	var cur_arm: int = maxi(0, _cur_arm_cached)
	var is_critical: bool = (cur_hp <= 1 and cur_arm <= 0)

	# Ensure container has exactly total_base (5) TextureRect nodes for base HP
	while hp_pips_container.get_child_count() > total_base:
		var c = hp_pips_container.get_child(hp_pips_container.get_child_count() - 1)
		hp_pips_container.remove_child(c)
		c.queue_free()

	while hp_pips_container.get_child_count() < total_base:
		var pip := TextureRect.new()
		pip.custom_minimum_size = UIConstants.HUD_HP_PIP_SIZE
		pip.stretch_mode = TextureRect.STRETCH_KEEP
		hp_pips_container.add_child(pip)

	var tex_full = load(UIConstants.TEX_HUD_HP_FULL)
	var tex_empty = load(UIConstants.TEX_HUD_HP_EMPTY)

	for i in range(total_base):
		var pip: TextureRect = hp_pips_container.get_child(i) as TextureRect
		if i < cur_hp:
			pip.texture = tex_full
			if is_critical and i == 0 and not GameSettings.reduce_motion:
				pip.modulate = Color(1, 1, 1, 0.70 if hp_pulse_frame == 1 else 1.0)
			else:
				pip.modulate = Color(1, 1, 1, 1)
		else:
			# Lost HP slot: check if this was damage and pip was just lost
			if was_damage and prev_hp > 0 and i >= cur_hp and i < prev_hp:
				_play_crescent_crack_anim(pip)
			elif not pip.has_meta("is_holding_damaged"):
				pip.texture = tex_empty
				pip.modulate = Color(1, 1, 1, 1)

	# Update distinct shield wards in shield_wards_container directly under HP
	_update_shield_wards_display(cur_arm, was_damage)

	# Damage punch on health bar root (respect Reduce Motion)
	if was_damage and is_instance_valid(hp_bar_root) and not GameSettings.reduce_motion:
		var punch := create_tween()
		punch.tween_property(hp_bar_root, "position:x", -3.0, 0.04).set_trans(Tween.TRANS_QUAD)
		punch.tween_property(hp_bar_root, "position:x", 0.0, 0.08).set_trans(Tween.TRANS_BOUNCE)

	# Critical low health vignette (#8a3b32)
	if is_critical:
		if is_instance_valid(low_hp_vignette):
			low_hp_vignette.color = Color(0.541, 0.231, 0.196, 0.16)
			if not is_instance_valid(hp_pulse_tween) or not hp_pulse_tween.is_valid():
				hp_pulse_tween = create_tween().set_loops()
				hp_pulse_tween.tween_property(low_hp_vignette, "color:a", 0.32, 0.45).set_trans(Tween.TRANS_SINE)
				hp_pulse_tween.tween_property(low_hp_vignette, "color:a", 0.12, 0.45).set_trans(Tween.TRANS_SINE)
	else:
		if is_instance_valid(hp_pulse_tween) and hp_pulse_tween.is_valid():
			hp_pulse_tween.kill()
		if is_instance_valid(low_hp_vignette):
			var fade_vig = create_tween()
			fade_vig.tween_property(low_hp_vignette, "color:a", 0.0, 0.20)


func _play_crescent_crack_anim(pip: TextureRect) -> void:
	if not is_instance_valid(pip):
		return
	pip.set_meta("is_holding_damaged", true)
	pip.texture = load(UIConstants.TEX_HUD_HP_DAMAGED)
	pip.modulate = Color(1, 1, 1, 1)

	if not is_inside_tree() or get_tree() == null:
		pip.texture = load(UIConstants.TEX_HUD_HP_EMPTY)
		pip.remove_meta("is_holding_damaged")
		return

	get_tree().create_timer(UIConstants.HUD_DAMAGE_CRACK_DURATION_SEC).timeout.connect(func():
		if is_instance_valid(pip):
			pip.texture = load(UIConstants.TEX_HUD_HP_EMPTY)
			pip.modulate = Color(1, 1, 1, 1)
			pip.remove_meta("is_holding_damaged")
	)


func _update_shield_wards_display(cur_arm: int, was_damage: bool) -> void:
	if not is_instance_valid(shield_wards_container):
		return

	var active_wards: Array[TextureRect] = []
	for child in shield_wards_container.get_children():
		var tr = child as TextureRect
		if is_instance_valid(tr) and not tr.has_meta("is_shattering"):
			active_wards.append(tr)

	# If shield decreased, shatter the absorbed ward(s)
	if active_wards.size() > cur_arm:
		var wards_to_remove: int = active_wards.size() - cur_arm
		for k in range(wards_to_remove):
			var idx_to_pop = active_wards.size() - 1 - k
			if idx_to_pop >= 0:
				_play_shield_shatter_anim(active_wards[idx_to_pop])

	# If shield increased (e.g. meditating at shrine), add new wards
	while active_wards.size() < cur_arm:
		var ward := TextureRect.new()
		ward.custom_minimum_size = UIConstants.HUD_SHIELD_WARD_SIZE
		ward.stretch_mode = TextureRect.STRETCH_KEEP
		ward.texture = load(UIConstants.TEX_HUD_SHIELD_INTACT)
		shield_wards_container.add_child(ward)
		active_wards.append(ward)


func _play_shield_shatter_anim(ward: TextureRect) -> void:
	if not is_instance_valid(ward):
		return
	ward.set_meta("is_shattering", true)
	ward.texture = load(UIConstants.TEX_HUD_SHIELD_CRACKED)

	if not is_inside_tree() or get_tree() == null:
		ward.queue_free()
		return

	get_tree().create_timer(UIConstants.HUD_SHIELD_CRACK_SEC).timeout.connect(func():
		if is_instance_valid(ward):
			ward.texture = load(UIConstants.TEX_HUD_SHIELD_BROKEN)
			get_tree().create_timer(UIConstants.HUD_SHIELD_BROKEN_SEC).timeout.connect(func():
				if is_instance_valid(ward):
					ward.queue_free()
			)
	)


func _on_player_hp_changed(current: int, max_hp: int) -> void:
	var was_damage = current < _cur_hp_cached
	var prev_hp = _cur_hp_cached
	_cur_hp_cached = current
	_max_hp_cached = max_hp
	_update_hp_bar_display(was_damage, prev_hp)


func _on_player_armor_changed(current: int, max_armor: int) -> void:
	var was_damage = current < _cur_arm_cached
	_cur_arm_cached = current
	_max_arm_cached = max_armor
	_update_hp_bar_display(was_damage)


func _on_player_stamina_changed(current: float, max_stamina: float) -> void:
	if not is_instance_valid(stamina_fill_clip):
		return

	var max_fill: float = UIConstants.HUD_STAMINA_TRACK_WIDTH
	var ratio: float = clamp(current / max(1.0, max_stamina), 0.0, 1.0)
	var target_width: float = float(int(round(ratio * max_fill)))
	stamina_fill_clip.size.x = target_width

	# 3. Fade to 40% opacity after 2s at full, back to 100% as soon as stamina is used
	if current < max_stamina:
		stamina_full_timer = 0.0
		if is_instance_valid(stamina_fade_tween) and stamina_fade_tween.is_valid():
			stamina_fade_tween.kill()
		if is_instance_valid(stamina_bar_root) and stamina_bar_root.modulate.a < 1.0:
			stamina_bar_root.modulate.a = 1.0

	# 4. Exhaustion: "When exhausted, flash the track #8a3b32 for 3 frames."
	var is_exhausted: bool = (is_instance_valid(player) and player.get("is_exhausted") == true)
	if is_exhausted and not _was_exhausted_cached:
		_was_exhausted_cached = true
		_play_stamina_exhaust_flash()
	elif not is_exhausted and _was_exhausted_cached:
		_was_exhausted_cached = false
		if is_instance_valid(stamina_track_rect):
			stamina_track_rect.color = UIConstants.COLOR_SLATE_DARK


func _play_stamina_exhaust_flash() -> void:
	if not is_instance_valid(stamina_track_rect):
		return
	if is_instance_valid(stamina_exhaust_tween) and stamina_exhaust_tween.is_valid():
		stamina_exhaust_tween.kill()

	stamina_track_rect.color = UIConstants.COLOR_DANGER_RED

	if GameSettings.reduce_motion:
		return

	stamina_exhaust_tween = create_tween()
	stamina_exhaust_tween.tween_interval(0.05)
	stamina_exhaust_tween.tween_callback(func():
		if is_instance_valid(stamina_track_rect):
			stamina_track_rect.color = UIConstants.COLOR_SLATE_DARK
	)


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
		parries_this_run += 1
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
			hp_bar_root.modulate = Color(1.35, 0.60, 0.55, 1.0)
			get_tree().create_timer(0.20).timeout.connect(func():
				if is_instance_valid(hp_bar_root) and (_cur_hp_cached > 1 or _cur_arm_cached > 0):
					hp_bar_root.modulate = Color(1, 1, 1, 1)
			)
		# Red visceral damage screen pulse using #8a3b32 (danger red)
		if is_instance_valid(damage_flash_overlay):
			damage_flash_overlay.color = Color(0.541, 0.231, 0.196, 0.36)
			var tween = create_tween()
			tween.tween_property(damage_flash_overlay, "color:a", 0.0, 0.25)


func add_screen_shake(amount: float) -> void:
	trauma = clamp(trauma + amount * GameSettings.screen_shake_intensity, 0.0, 1.0)


func trigger_hit_stop(duration: float) -> void:
	if not is_inside_tree() or not get_tree():
		return
	hit_stop_timer = maxf(hit_stop_timer, duration)
	Engine.time_scale = 0.05


func trigger_parry_slowmo(duration: float = 0.16) -> void:
	if not is_inside_tree() or not get_tree():
		return
	slowmo_timer = maxf(slowmo_timer, duration)
	if hit_stop_timer <= 0.0:
		Engine.time_scale = 0.28


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


func clear_miniboss_arena() -> void:
	is_miniboss_arena_locked = false
	if is_instance_valid(miniboss_rear_barrier):
		miniboss_rear_barrier.queue_free()
		miniboss_rear_barrier = null


func trigger_miniboss_arena_lockdown() -> void:
	var active_miniboss: CharacterBody2D = null
	for e in active_enemies:
		if is_instance_valid(e) and e.is_in_group("miniboss") and not e.get("is_dead"):
			active_miniboss = e as CharacterBody2D
			break
	if not active_miniboss:
		return

	is_miniboss_arena_locked = true

	if is_instance_valid(miniboss_rear_barrier):
		miniboss_rear_barrier.queue_free()

	miniboss_rear_barrier = StaticBody2D.new()
	miniboss_rear_barrier.name = "MinibossRearBarrier"
	miniboss_rear_barrier.collision_layer = 1
	miniboss_rear_barrier.collision_mask = 2 # Blocks player

	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(32.0, 600.0)
	col.shape = rect_shape
	miniboss_rear_barrier.add_child(col)
	miniboss_rear_barrier.global_position = Vector2(3980.0, 150.0)
	add_child(miniboss_rear_barrier)

	add_screen_shake(0.50)
	apply_hit_stop(0.04)

	var cur_theme = LEVELS_DATA[current_level_idx].get("theme", "")
	var title := "CORRUPTED SENTINEL: FOREST BRUTE"
	var baybayin := "ᜑᜒᜄᜈ᜔ᜆᜒᜅ᜔ ᜄᜓᜊᜆ᜔"
	var bar_color := Color(0.20, 0.83, 0.60, 1.0)
	active_encounter_type = "forest_brute"
	if cur_theme == "Rice Field":
		title = "MAYON FLAME VANGUARD"
		baybayin = "ᜊᜅ᜔ᜄᜓᜏᜇ᜔ᜇᜒᜌ ᜅ᜔ ᜋᜌᜓᜈ᜔"
		bar_color = Color(1.0, 0.45, 0.15, 1.0)
		active_encounter_type = "mayon_vanguard"
	elif cur_theme == "Cave":
		title = "ABYSSAL LUNAR WARDEN: SANCTUM VANGUARD"
		baybayin = "ᜆᜈᜓᜇ᜔ ᜅ᜔ ᜎᜎᜓᜋ᜔"
		bar_color = Color(0.52, 0.85, 1.0, 1.0)
		active_encounter_type = "abyssal_warden"

	# Connect miniboss to boss health bar
	if active_miniboss.has_signal("boss_hp_changed"):
		if not active_miniboss.boss_hp_changed.is_connected(_on_boss_hp_changed):
			active_miniboss.boss_hp_changed.connect(_on_boss_hp_changed)
	if active_miniboss.has_signal("boss_phase_changed"):
		if not active_miniboss.boss_phase_changed.is_connected(_on_boss_phase_changed):
			active_miniboss.boss_phase_changed.connect(_on_boss_phase_changed)

	if boss_fire_tween and boss_fire_tween.is_valid():
		boss_fire_tween.kill()

	if is_instance_valid(boss_enraged_badge):
		boss_enraged_badge.visible = false

	if is_instance_valid(boss_hud_root):
		if is_instance_valid(boss_title_label):
			boss_title_label.text = title
			boss_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = bar_color
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			boss_hp_num_label.text = "100%"
		boss_hud_root.visible = true
		var tw = create_tween()
		tw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)

	show_exit_banner(title, bar_color)

	# Cinematic Boss Encounter Cutscene
	if not has_seen_boss_encounter_cutscene and is_instance_valid(comic_story_viewer):
		has_seen_boss_encounter_cutscene = true
		if active_encounter_type == "forest_brute":
			comic_story_viewer.play_cutscene(
				"HIGANTENG GUBAT",
				"Corrupted Forest Sentinel Awakens",
				["res://assets/cutscenes/stage1_boss_encounter.jpg"],
				"",
				false,
				true
			)
		elif active_encounter_type == "mayon_vanguard":
			comic_story_viewer.play_cutscene(
				"MAYON VANGUARD",
				"Champion of the Burning Kiln",
				["res://assets/cutscenes/stage2_boss_encounter.jpg"],
				"",
				false,
				true
			)


func show_foe_vanquished_ceremony(banner_text: String, pearls_awarded: int, on_complete: Callable) -> void:
	# Award Moon Pearls
	pearls_collected_this_run += pearls_awarded
	MetaProgression.add_moon_pearls(pearls_awarded)
	MetaProgression.save_meta()
	update_score_hud()

	if is_inside_tree():
		# Resonant victory gong audio chord
		var sfx_node := AudioStreamPlayer.new()
		sfx_node.name = "VictoryGongSFX"
		sfx_node.bus = "Master"
		sfx_node.stream = ProceduralAudio.get_victory_gong_chord()
		sfx_node.volume_db = -2.0
		add_child(sfx_node)
		sfx_node.play()
		sfx_node.finished.connect(sfx_node.queue_free)

		# 1. Hit-stop & dramatic slow motion
		trigger_hit_stop(0.40)
		trigger_parry_slowmo(0.65)
		add_screen_shake(1.0)

	# 2. Build or display Foe Vanquished Banner overlay
	if not is_instance_valid(hud_container):
		hud_container = Control.new()
		hud_container.name = "HUDContainer"
		hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(hud_container)

	if not is_instance_valid(foe_vanquished_banner):
		foe_vanquished_banner = Control.new()
		foe_vanquished_banner.name = "FoeVanquishedBanner"
		foe_vanquished_banner.set_anchors_preset(Control.PRESET_FULL_RECT)
		foe_vanquished_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud_container.add_child(foe_vanquished_banner)

		var custom_font = load("res://alagard.ttf")

		# Cinematic black band across center screen
		var band = ColorRect.new()
		band.name = "CenterBand"
		band.color = Color(0.015, 0.012, 0.018, 0.90)
		band.anchor_left = 0.0
		band.anchor_right = 1.0
		band.anchor_top = 0.5
		band.anchor_bottom = 0.5
		band.offset_top = -48.0
		band.offset_bottom = 48.0
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		foe_vanquished_banner.add_child(band)

		# Top & Bottom gold hairlines
		var h_top = ColorRect.new()
		h_top.name = "HairlineTop"
		h_top.color = Color(0.92, 0.80, 0.42, 0.90)
		h_top.anchor_left = 0.0
		h_top.anchor_right = 1.0
		h_top.anchor_top = 0.0
		h_top.anchor_bottom = 0.0
		h_top.offset_bottom = 1.5
		h_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(h_top)

		var h_bot = ColorRect.new()
		h_bot.name = "HairlineBottom"
		h_bot.color = Color(0.92, 0.80, 0.42, 0.90)
		h_bot.anchor_left = 0.0
		h_bot.anchor_right = 1.0
		h_bot.anchor_top = 1.0
		h_bot.anchor_bottom = 1.0
		h_bot.offset_top = -1.5
		h_bot.offset_bottom = 0.0
		h_bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(h_bot)

		var vbox = VBoxContainer.new()
		vbox.name = "TextVBox"
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(vbox)

		var banner_label = Label.new()
		banner_label.name = "BannerText"
		banner_label.text = "FOE VANQUISHED"
		banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		banner_label.add_theme_font_override("font", custom_font)
		banner_label.add_theme_font_size_override("font_size", 28)
		banner_label.add_theme_color_override("font_color", Color(0.98, 0.90, 0.68, 1.0))
		banner_label.add_theme_color_override("font_shadow_color", Color(0.2, 0.08, 0.02, 1.0))
		banner_label.add_theme_constant_override("shadow_offset_x", 2)
		banner_label.add_theme_constant_override("shadow_offset_y", 2)
		banner_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
		banner_label.add_theme_constant_override("outline_size", 2)
		vbox.add_child(banner_label)

		var reward_label = Label.new()
		reward_label.name = "RewardText"
		reward_label.text = "+1,500 MOON PEARLS CLAIMED"
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_label.add_theme_font_override("font", custom_font)
		reward_label.add_theme_font_size_override("font_size", 12)
		reward_label.add_theme_color_override("font_color", Color(0.68, 0.90, 1.0, 0.95))
		reward_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
		reward_label.add_theme_constant_override("shadow_offset_x", 1)
		reward_label.add_theme_constant_override("shadow_offset_y", 1)
		vbox.add_child(reward_label)

	foe_vanquished_banner.visible = true
	foe_vanquished_banner.modulate.a = 1.0

	var b_label = foe_vanquished_banner.get_node_or_null("CenterBand/TextVBox/BannerText") as Label
	if is_instance_valid(b_label):
		b_label.text = banner_text

	var reward_lbl = foe_vanquished_banner.get_node_or_null("CenterBand/TextVBox/RewardText") as Label
	if is_instance_valid(reward_lbl):
		reward_lbl.text = "+%d MOON PEARLS CLAIMED" % pearls_awarded

	if not is_inside_tree():
		if on_complete.is_valid():
			on_complete.call()
		return

	# Fade in and hold for glory
	foe_vanquished_banner.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(foe_vanquished_banner, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(2.2)
	tw.tween_property(foe_vanquished_banner, "modulate:a", 0.0, 0.50).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		if is_instance_valid(foe_vanquished_banner):
			foe_vanquished_banner.visible = false
		if on_complete.is_valid():
			on_complete.call()
	)


func handle_miniboss_defeated(_enemy: Node) -> void:
	bosses_slain_this_run += 1
	is_miniboss_arena_locked = false

	if boss_fire_tween and boss_fire_tween.is_valid():
		boss_fire_tween.kill()

	if is_instance_valid(boss_enraged_badge):
		boss_enraged_badge.visible = false

	if is_instance_valid(boss_hud_root):
		var tw_hud = create_tween()
		tw_hud.tween_property(boss_hud_root, "modulate:a", 0.0, 0.60)
		tw_hud.tween_callback(func():
			if is_instance_valid(boss_hud_root):
				boss_hud_root.visible = false
		)

	if is_instance_valid(miniboss_rear_barrier):
		for i in range(12):
			var rock = Polygon2D.new()
			var s = randf_range(3.5, 7.0)
			rock.polygon = PackedVector2Array([
				Vector2(-s, -s * 0.4),
				Vector2(0, -s),
				Vector2(s, -s * 0.2),
				Vector2(s * 0.6, s),
				Vector2(-s * 0.7, s * 0.8)
			])
			rock.color = Color(0.38, 0.33, 0.28, 0.92)
			rock.global_position = miniboss_rear_barrier.global_position + Vector2(randf_range(-16.0, 16.0), randf_range(50.0, 250.0))
			rock.z_index = 15
			add_child(rock)
			var tw = rock.create_tween()
			tw.tween_property(rock, "global_position:y", rock.global_position.y + randf_range(40.0, 80.0), 0.5)
			tw.parallel().tween_property(rock, "rotation", randf_range(-3.0, 3.0), 0.5)
			tw.parallel().tween_property(rock, "modulate:a", 0.0, 0.5)
			tw.tween_callback(Callable(rock, "queue_free"))
		miniboss_rear_barrier.queue_free()
		miniboss_rear_barrier = null

	# Run 3-Stage Victory Ceremony, then transition to defeat cutscene!
	show_foe_vanquished_ceremony("FOE VANQUISHED", 1500, func():
		# If Mayon Vanguard, trigger storm downpour upon victory
		if active_encounter_type == "mayon_vanguard":
			is_stage_2_boss_defeated = true
			trigger_sheet_lightning(1.0, 3.0)
			thunder_rumble_timer = 0.25

		# Cinematic Boss Defeat Cutscene
		if not has_seen_boss_defeat_cutscene and is_instance_valid(comic_story_viewer):
			has_seen_boss_defeat_cutscene = true
			if active_encounter_type == "forest_brute":
				comic_story_viewer.play_cutscene(
					"SENTINEL VANQUISHED",
					"The Ancient Forest Breathes in Silver Moonlight",
					["res://assets/cutscenes/stage1_boss_defeat.jpg"],
					"",
					false,
					true
				)
			elif active_encounter_type == "mayon_vanguard":
				comic_story_viewer.play_cutscene(
					"VANGUARD EXTINCTION",
					"Torrential Rains Quench the Sacred Kilns",
					["res://assets/cutscenes/stage2_boss_defeat.jpg"],
					"",
					false,
					true
				)
		show_exit_banner("MINIBOSS VANQUISHED — PATHWAY UNLOCKED", Color(1.0, 0.88, 0.35, 1.0))
	)


func _on_boss_hp_changed(cur_hp: int, max_hp: int) -> void:
	if not is_instance_valid(boss_hp_fill) or not is_instance_valid(boss_hp_ghost):
		return
	var pct: float = clampf(float(cur_hp) / float(max_hp), 0.0, 1.0)
	var target_w: float = 380.0 * pct

	boss_hp_fill.size.x = target_w
	if is_instance_valid(boss_hp_num_label):
		var pct_int: int = int(round(pct * 100.0)) if cur_hp > 0 else 0
		boss_hp_num_label.text = "%d%%" % pct_int

	if is_instance_valid(boss_hp_tween) and boss_hp_tween.is_valid():
		boss_hp_tween.kill()
	boss_hp_tween = create_tween()
	boss_hp_tween.tween_interval(0.25)
	boss_hp_tween.tween_property(boss_hp_ghost, "size:x", target_w, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_boss_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		add_screen_shake(1.05)
		trigger_hit_stop(0.40)
		trigger_parry_slowmo(0.55)

		# Spawn radial blood-moon shockwave at boss position
		var b_pos := Vector2(4000, 200)
		for e in active_enemies:
			if is_instance_valid(e) and e.is_in_group("miniboss") and not e.get("is_dead"):
				b_pos = e.global_position + Vector2(0, -32)
				break
		if is_instance_valid(boss_instance):
			b_pos = boss_instance.global_position + Vector2(0, -32)
		VFX.spawn_blood_moon_shockwave(self, b_pos, 220.0, Color(1.0, 0.18, 0.18, 0.95))

		# Activate pulsing [ ENRAGED ] seal badge
		if is_instance_valid(boss_enraged_badge):
			boss_enraged_badge.visible = true
			boss_enraged_badge.modulate.a = 0.0
			boss_enraged_badge.scale = Vector2(1.6, 1.6)
			boss_enraged_badge.pivot_offset = Vector2(40, 8)
			var tw_badge = create_tween().set_parallel(true)
			tw_badge.tween_property(boss_enraged_badge, "modulate:a", 1.0, 0.30)
			tw_badge.tween_property(boss_enraged_badge, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		if is_instance_valid(boss_title_label):
			if active_encounter_type == "forest_brute":
				boss_title_label.text = "HIGANTENG GUBAT — ENRAGED TIMBER COLOSSUS"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			elif active_encounter_type == "mayon_vanguard":
				boss_title_label.text = "MAYON FLAME VANGUARD — INFERNAL FURY"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.15, 1.0))
			elif active_encounter_type == "abyssal_warden":
				boss_title_label.text = "ABYSSAL LUNAR WARDEN — ECLIPSE CHAMPION"
				boss_title_label.add_theme_color_override("font_color", Color(0.65, 0.90, 1.0, 1.0))
			elif active_encounter_type == "bakunawa":
				boss_title_label.text = "BAKUNAWA — ECLIPSE OF SEVEN MOONS"
				boss_title_label.add_theme_color_override("font_color", Color(0.95, 0.3, 0.6, 1.0))
			else:
				boss_title_label.text = "SINAG-ULAP — THE ENRAGED MATRIARCH"
				boss_title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))

		# Living fiery pulse on boss health bar
		if is_instance_valid(boss_hp_fill):
			if boss_fire_tween and boss_fire_tween.is_valid():
				boss_fire_tween.kill()
			boss_hp_fill.color = Color(1.2, 0.22, 0.22, 1.0)
			boss_fire_tween = create_tween().set_loops()
			boss_fire_tween.tween_property(boss_hp_fill, "color", Color(1.15, 0.18, 0.18, 1.0), 0.40).set_trans(Tween.TRANS_SINE)
			boss_fire_tween.tween_property(boss_hp_fill, "color", Color(0.85, 0.28, 0.10, 1.0), 0.40).set_trans(Tween.TRANS_SINE)

		if is_instance_valid(damage_flash_overlay):
			damage_flash_overlay.color = Color(1.0, 0.12, 0.12, 0.55)
			var tw = create_tween()
			tw.tween_property(damage_flash_overlay, "color:a", 0.0, 0.70)


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
	strike.target_position = pos
	strike.global_position = pos
	strike.strike_occurred.connect(_on_lightning_hazard_struck)
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
	UpgradeManager.total_kills_this_run += 1
	update_score_hud()

	# Grand white flash & thunder
	if is_instance_valid(damage_flash_overlay):
		damage_flash_overlay.color = Color(1.0, 1.0, 1.0, 0.75)
		var tw_flash = create_tween()
		tw_flash.tween_property(damage_flash_overlay, "color:a", 0.0, 1.4)

	# If more levels remain (e.g. Caverns Level 4 & 5), unseal the path
	if current_level_idx < LEVELS_DATA.size() - 1:
		unlock_exit_path()
		show_exit_banner("Matriarch Slain — The Caverns Unsealed", Color(1.0, 0.85, 0.3, 1.0))
	else:
		# Wait 2.8s for death animation and celebratory stillness before victory screen
		get_tree().create_timer(2.8).timeout.connect(func():
			trigger_win()
		)


# ── Bakunawa Boss Encounter Methods (Level 5 Climax) ──────────────────────────
func start_bakunawa_encounter() -> void:
	if is_boss_active:
		return
	is_boss_active = true

	# Switch BGM to Bakunawa abyssal battle theme
	play_bgm(ProceduralAudio.get_bakunawa_theme(), "bakunawa_boss", 0.5)

	# Show boss HUD with smooth fade-in
	active_encounter_type = "bakunawa"
	if is_instance_valid(boss_hud_root):
		if is_instance_valid(boss_title_label):
			boss_title_label.text = "BAKUNAWA — THE MOON DEVOURER"
			boss_title_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(0.2, 0.65, 0.95, 1.0)
			boss_hp_fill.size.x = 380.0
		if is_instance_valid(boss_hp_ghost):
			boss_hp_ghost.size.x = 380.0
		if is_instance_valid(boss_hp_num_label):
			boss_hp_num_label.text = "100%"
		boss_hud_root.visible = true
		var tw = create_tween()
		tw.tween_property(boss_hud_root, "modulate:a", 1.0, 0.50)

	# Lock the arena with physical barrier walls
	create_boss_arena_barriers()

	# Spawn the Bakunawa Boss submerged in the abyssal depths so State.INTRO erupts upward
	boss_instance = BakunawaBossScript.new()
	boss_instance.name = "BakunawaBoss"
	boss_instance.global_position = Vector2(4450.0, 385.0)
	boss_instance.boss_hp_changed.connect(_on_boss_hp_changed)
	boss_instance.boss_phase_changed.connect(_on_bakunawa_phase_changed)
	boss_instance.boss_died.connect(_on_bakunawa_died)
	if boss_instance.has_signal("wisp_summon_requested"):
		boss_instance.wisp_summon_requested.connect(_on_bakunawa_wisp_summon_requested)
	if boss_instance.has_signal("stalactite_drop_requested"):
		boss_instance.stalactite_drop_requested.connect(func(_x_pos: float): add_screen_shake(0.28))
	enemies_container.add_child(boss_instance)

	show_exit_banner("BAKUNAWA — DEVOURER OF THE SEVEN MOONS", Color(0.42, 0.86, 1.0, 1.0))
	add_screen_shake(0.85)


func _on_bakunawa_wisp_summon_requested(pos: Vector2) -> void:
	if not is_instance_valid(enemies_container) or not is_boss_active:
		return
	var wisp = AswangScript.new()
	wisp.global_position = pos
	wisp.health = 1
	wisp.modulate = Color(0.45, 0.85, 1.35, 0.90)
	wisp.aswang_died.connect(_on_aswang_died)
	enemies_container.add_child(wisp)
	VFX.spawn_guard_impact(self, pos + Vector2(0, -24))


func _on_bakunawa_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		add_screen_shake(0.95)
		trigger_parry_slowmo(0.40)
		if is_instance_valid(boss_title_label):
			boss_title_label.text = "BAKUNAWA — ECLIPSE OF SEVEN MOONS"
			boss_title_label.add_theme_color_override("font_color", Color(0.95, 0.3, 0.6, 1.0))
		if is_instance_valid(boss_hp_fill):
			boss_hp_fill.color = Color(0.85, 0.25, 0.55, 1.0)
		if is_instance_valid(damage_flash_overlay):
			damage_flash_overlay.color = Color(0.8, 0.2, 0.5, 0.45)
			var tw = create_tween()
			tw.tween_property(damage_flash_overlay, "color:a", 0.0, 0.55)
		# Shift the arena's EclipseMoonCenterpiece into Blood-Eclipse crimson-violet
		if is_instance_valid(current_level_instance):
			var moon_node = current_level_instance.get_node_or_null("EclipseMoonCenterpiece")
			if is_instance_valid(moon_node):
				var halo = moon_node.get_node_or_null("MoonCorona") as Polygon2D
				var moon_light = moon_node.get_node_or_null("MoonLight") as PointLight2D
				var rim = moon_node.get_node_or_null("MoonDisc") as Polygon2D
				if halo:
					create_tween().tween_property(halo, "color", Color(0.92, 0.22, 0.54, 0.38), 0.8)
				if moon_light:
					create_tween().tween_property(moon_light, "color", Color(0.95, 0.28, 0.62, 1.0), 0.8)
				if rim:
					create_tween().tween_property(rim, "color", Color(1.0, 0.72, 0.88, 0.96), 0.8)


func _on_bakunawa_died(_boss: CharacterBody2D) -> void:
	bosses_slain_this_run += 1
	add_screen_shake(1.0)
	trigger_hit_stop(0.45)
	trigger_parry_slowmo(0.70)

	clear_boss_arena_barriers()

	if is_instance_valid(boss_hud_root):
		var tw_hud = create_tween()
		tw_hud.tween_property(boss_hud_root, "modulate:a", 0.0, 1.2)
		tw_hud.tween_callback(func():
			if is_instance_valid(boss_hud_root):
				boss_hud_root.visible = false
		)

	aswang_kills += 1
	UpgradeManager.total_kills_this_run += 1
	update_score_hud()

	# Restore the Full Silver Moon in the cavern sky!
	if is_instance_valid(current_level_instance):
		var moon_node = current_level_instance.get_node_or_null("EclipseMoonCenterpiece")
		if is_instance_valid(moon_node):
			var shadow_disc = moon_node.get_node_or_null("EclipseShadow") as Polygon2D
			var halo = moon_node.get_node_or_null("MoonCorona") as Polygon2D
			var moon_light = moon_node.get_node_or_null("MoonLight") as PointLight2D
			var rim = moon_node.get_node_or_null("MoonDisc") as Polygon2D
			var tw_moon = create_tween().set_parallel(true)
			if shadow_disc:
				tw_moon.tween_property(shadow_disc, "position:x", 68.0, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tw_moon.tween_property(shadow_disc, "modulate:a", 0.0, 2.0)
			if halo:
				tw_moon.tween_property(halo, "color", Color(0.78, 0.92, 1.0, 0.55), 1.8)
				tw_moon.tween_property(halo, "scale", Vector2(1.45, 1.45), 2.2)
			if moon_light:
				tw_moon.tween_property(moon_light, "color", Color(0.85, 0.94, 1.0, 1.0), 1.8)
				tw_moon.tween_property(moon_light, "energy", 2.6, 2.2)
			if rim:
				tw_moon.tween_property(rim, "color", Color(0.96, 0.98, 1.0, 1.0), 1.8)

	show_foe_vanquished_ceremony("NIGHTMARE SLAIN", 5000, func():
		show_exit_banner("THE SEVENTH MOON IS RESTORED — BAKUNAWA VANQUISHED", Color(0.75, 0.94, 1.0, 1.0))
	)

	# Grand celestial silver-azure flash
	if is_instance_valid(damage_flash_overlay):
		damage_flash_overlay.color = Color(0.6, 0.85, 1.0, 0.8)
		var tw_flash = create_tween()
		tw_flash.tween_property(damage_flash_overlay, "color:a", 0.0, 1.6)

	# Wait 3.2s for moon restoration and death dissolution before victory epilogue screen
	get_tree().create_timer(3.2).timeout.connect(func():
		trigger_win()
	)

func _spawn_escalation_reinforcements(count: int, hp_mult: float, spd_mult: float, elite_rate: float) -> void:
	var cur_theme = LEVELS_DATA[current_level_idx].get("theme", "")
	var target_container = current_level_instance.find_child("Enemies", true, false) if current_level_instance else enemies_container
	if not target_container:
		target_container = enemies_container

	var step = 3200.0 / float(count + 1)
	for i in range(count):
		var spawn_x = 1100.0 + (i + 1) * step + randf_range(-80.0, 80.0)
		var spawn_pos = Vector2(spawn_x, 260.0)
		var enemy: CharacterBody2D = null

		if cur_theme == "Rice Field":
			if randf() < 0.45:
				enemy = SantelmoScript.new()
				enemy.global_position = Vector2(spawn_x, 180.0)
			else:
				var FarmerClass = preload("res://scripts/corrupted_farmer.gd")
				enemy = CharacterBody2D.new()
				enemy.set_script(FarmerClass)
				enemy.global_position = spawn_pos
		elif cur_theme == "Cave":
			if randf() < 0.35:
				enemy = SantelmoScript.new()
				enemy.global_position = Vector2(spawn_x, 175.0)
			else:
				enemy = SkeletonScript.new()
				enemy.global_position = spawn_pos
		else:
			enemy = AswangScript.new()
			enemy.global_position = spawn_pos

		enemy.add_to_group("enemies")
		if enemy.has_signal("aswang_died"):
			enemy.connect("aswang_died", Callable(self, "_on_aswang_died"))
		elif enemy.has_signal("skeleton_died"):
			enemy.connect("skeleton_died", Callable(self, "_on_skeleton_died"))
		elif enemy.has_signal("santelmo_died"):
			enemy.connect("santelmo_died", Callable(self, "_on_santelmo_died"))
		elif enemy.has_signal("farmer_died"):
			enemy.connect("farmer_died", Callable(self, "_on_aswang_died"))

		var is_elite = (randf() < elite_rate)
		if enemy.has_method("apply_difficulty_scaling"):
			enemy.apply_difficulty_scaling(hp_mult, spd_mult, is_elite)

		target_container.add_child(enemy)
		active_enemies.append(enemy)

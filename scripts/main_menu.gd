extends Control

## MainMenu
## Main Menu controller for "HALIYA: Mask of Sorrows".
## Preserves the moonlit jungle canopy, crying carved totem with crescent crown,
## and fireflies/stars background scene intact, while rendering the frameless
## pixel-art UI layer and managing sub-screen navigation via UIScreenManager.

const AssetsScript = preload("res://scripts/assets.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")
const SaveManager = preload("res://scripts/save_manager.gd")

static func _get_main_script() -> GDScript:
	return load("res://scripts/main.gd") as GDScript

const C = preload("res://ui/theme/ui_theme_constants.gd")
const GameSettings = preload("res://scripts/game_settings.gd")
const TotemSurroundScene = preload("res://scenes/totem_surround.tscn")
const ForegroundFoliageScene = preload("res://scenes/foreground_foliage.tscn")
const HaliyaTitleLockupScene = preload("res://ui/components/haliya_title_lockup.tscn")
const HaliyaMenuButtonScene = preload("res://ui/components/haliya_menu_button.tscn")
const HaliyaPanelDialogScene = preload("res://ui/components/haliya_panel_dialog.tscn")
const ScreenManagerScript = preload("res://ui/screens/screen_manager.gd")

const SettingsScreenScene = preload("res://ui/screens/settings_screen.tscn")
const StageSelectScreenScene = preload("res://ui/screens/stage_select_screen.tscn")
const LoreCodexScreenScene = preload("res://ui/screens/lore_codex_screen.tscn")
const HowToPlayScreenScene = preload("res://ui/screens/how_to_play_screen.tscn")
const QuitConfirmScreenScene = preload("res://ui/screens/quit_confirm_screen.tscn")

# Parallax background nodes (preserved untouched)
var bg_root: Node2D
var bg_layers: Array[Dictionary] = []
var moon_container: Node2D
var stars_container: Node2D
var stars_data: Array[Dictionary] = []
var _stars_time: float = 0.0
var base_moon_pos: Vector2 = Vector2.ZERO
var base_altar_pos: Vector2 = Vector2.ZERO
var mouse_parallax_offset: Vector2 = Vector2.ZERO
var god_ray_spr: Sprite2D
var sanctuary_container: Node2D

# Atmosphere Layers (Polish Pass 2 & 3)
var mist_container: Node2D
var mist_layers: Array[Dictionary] = []
var totem_surround: Node2D
var lower_fireflies: CPUParticles2D
var drifting_leaves: CPUParticles2D
var foreground_foliage: ForegroundFoliage

# Redesigned UI Layer Components
var left_gradient_rect: TextureRect
var title_container: Control
var title_haliya_rect: TextureRect
var zigzag_divider_rect: TextureRect
var subtitle_label: Label
var menu_vbox: VBoxContainer
var menu_buttons: Array[VBoxContainer] = []
var ver_label: Label
var screen_manager: Control

# Chronicle Slot Modal (uses HaliyaPanelDialog)
var slot_select_modal: Control
var slot_cards_container: VBoxContainer
var fade_rect: ColorRect

# Full Splash -> Loading -> Press Any Key intro sequence enabled by default
static var has_shown_splash: bool = false
var splash_layer: Control
var group2_page: Control
var logs_page: Control
var current_splash_stage: int = 0
var splash_skip_presses: int = 0
var dissolve_rect: TextureRect
var _dissolve_textures: Array[Texture2D] = []

const TITLE_CENTER_POS: Vector2 = Vector2(239.0, 120.0)

var step3_container: Control
var step3_title_box: Control
var step3_press_start_label: Label
var loading_container: Control
var loading_fill_bar: Control
var moon_phases_hbox: HBoxContainer
var moon_phase_icons: Array[TextureRect] = []
var _moon_tex_lit: Array[Texture2D] = []
var _moon_tex_unlit: Array[Texture2D] = []
var loading_pct_label: Label
var loading_status_label: Label
var is_loading_assets: bool = false
var loading_tween: Tween = null
var _loading_elapsed: float = 0.0
var _loading_target_paths: Array[String] = [
	"res://assets/bahay_kubo/totem_haliya.png",
	"res://assets/bicol_bg/Bicol_Forest_Layer1.png",
	"res://scenes/tutorial_stage.tscn",
	"res://scenes/main.tscn",
]
var _loading_transitioned: bool = false
var comic_story_viewer: CanvasLayer

var is_in_splash: bool = false
var is_in_press_start: bool = false
var splash_tween: Tween = null
var press_start_tween: Tween = null

var is_transitioning: bool = false
var bgm_player: AudioStreamPlayer
var sfx_ui_player: AudioStreamPlayer

# Retained for backward-compatibility with automated test suites
var settings_menu: CanvasLayer
var bestiary_codex_ui: CanvasLayer


func _ready() -> void:
	theme = load(C.PATH_THEME)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	RenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
	C.ensure_ui_input_actions()
	GameSettings.load_settings()

	setup_sfx()
	setup_background()
	setup_ambient_particles()
	setup_ui()
	setup_screen_manager()
	setup_step3_ui()
	setup_loading_ui()
	setup_comic_story_viewer()
	setup_slot_select_modal()
	setup_settings_and_codex_modals()
	setup_splash_layer()
	setup_fade_overlay()
	setup_bgm()

	if not has_shown_splash:
		var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else null
		if is_instance_valid(motes):
			motes.emitting = false
			motes.visible = false
		if is_instance_valid(totem_surround):
			totem_surround.visible = false
		if is_instance_valid(sanctuary_container):
			sanctuary_container.visible = false
		if is_instance_valid(mist_container):
			mist_container.visible = false
		if is_instance_valid(foreground_foliage):
			foreground_foliage.visible = false
		if is_instance_valid(lower_fireflies):
			lower_fireflies.emitting = false
			lower_fireflies.visible = false
		if is_instance_valid(drifting_leaves):
			drifting_leaves.emitting = false
			drifting_leaves.visible = false
		left_gradient_rect.visible = false
		menu_vbox.visible = false
		ver_label.visible = false

		if GameSettings.skip_intro:
			splash_layer.visible = false
			fade_rect.color = Color(0, 0, 0, 0.0)
			_start_loading_sequence()
		else:
			is_in_splash = true
			is_in_press_start = false
			splash_layer.visible = true
			step3_container.visible = false
			title_container.visible = false
			fade_rect.color = Color(0, 0, 0, 0.0)
			_start_splash_sequence()
	else:
		is_in_splash = false
		is_in_press_start = false
		splash_layer.visible = false
		step3_container.visible = false
		left_gradient_rect.visible = true
		left_gradient_rect.modulate.a = 1.0
		title_container.visible = true
		title_container.position = Vector2(C.MENU_LEFT_EDGE_X, C.MENU_BLOCK_TOP_Y)
		title_container.modulate.a = 1.0
		menu_vbox.visible = true
		menu_vbox.modulate.a = 1.0
		ver_label.visible = true
		ver_label.modulate.a = 1.0
		if is_instance_valid(totem_surround):
			totem_surround.visible = true
			totem_surround.modulate.a = 1.0
		if is_instance_valid(mist_container):
			mist_container.visible = true
			mist_container.modulate.a = 1.0
		if is_instance_valid(foreground_foliage):
			foreground_foliage.visible = true
			foreground_foliage.modulate.a = 1.0
		if is_instance_valid(lower_fireflies):
			lower_fireflies.emitting = true
			lower_fireflies.visible = true
		if is_instance_valid(drifting_leaves):
			drifting_leaves.emitting = true
			drifting_leaves.visible = true
		if is_instance_valid(sanctuary_container):
			sanctuary_container.visible = true
			sanctuary_container.modulate.a = 1.0
		var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else null
		if is_instance_valid(motes):
			motes.emitting = true
			motes.visible = true
		fade_rect.color = Color(0, 0, 0, 0.0)
		_play_staggered_menu_entrance()


func setup_sfx() -> void:
	sfx_ui_player = AudioStreamPlayer.new()
	sfx_ui_player.name = "MenuSFXPlayer"
	sfx_ui_player.bus = "Master"
	add_child(sfx_ui_player)
	ProceduralAudio.prewarm_ui_sounds()


func _play_ui_hover() -> void:
	if not is_inside_tree() or is_transitioning:
		return
	if is_instance_valid(comic_story_viewer) and comic_story_viewer.is_active:
		return
	if is_instance_valid(sfx_ui_player):
		sfx_ui_player.stream = ProceduralAudio.get_ui_hover()
		sfx_ui_player.volume_db = -6.0
		sfx_ui_player.play()


func _play_ui_select() -> void:
	if not is_inside_tree() or is_transitioning:
		return
	if is_instance_valid(comic_story_viewer) and comic_story_viewer.is_active:
		return
	if is_instance_valid(sfx_ui_player):
		sfx_ui_player.stream = ProceduralAudio.get_ui_select()
		sfx_ui_player.volume_db = -4.0
		sfx_ui_player.play()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_background_bounds()


func _update_background_bounds() -> void:
	if not is_inside_tree() or not is_instance_valid(bg_root):
		return
	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = max(640.0, vp_size.x)
	var target_h: float = max(360.0, vp_size.y)

	var sky_spr = bg_root.get_node_or_null("SkySprite")
	if is_instance_valid(sky_spr) and sky_spr.texture:
		var sky_scale = max(target_w / sky_spr.texture.get_width(), target_h / sky_spr.texture.get_height()) * 1.05
		sky_spr.scale = Vector2(sky_scale, sky_scale)

	# Keep moon anchored to upper right sky
	base_moon_pos = Vector2(target_w * 0.755, 46.0)
	if is_instance_valid(moon_container):
		moon_container.position = base_moon_pos
	if is_instance_valid(god_ray_spr):
		god_ray_spr.position = Vector2(target_w * 0.72, target_h * 0.48)

	base_altar_pos = Vector2(round(target_w * 0.755), 231.0)
	if is_instance_valid(totem_surround):
		totem_surround.position = base_altar_pos

	var motes_node = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else get_node_or_null("AltarMotes")
	if is_instance_valid(motes_node):
		motes_node.position = Vector2(target_w * 0.755, target_h - 130.0 * (target_h / 360.0))

	for star_data in stars_data:
		var spr: Sprite2D = star_data.get("spr")
		if is_instance_valid(spr):
			spr.position = Vector2(star_data["nx"] * target_w, star_data["ny"] * target_h)

	var s: float = max(0.5, (target_h + 4.0) / 720.0)
	for layer_data in bg_layers:
		var spr1: Sprite2D = layer_data["spr1"]
		var spr2: Sprite2D = layer_data["spr2"]
		if is_instance_valid(spr1) and is_instance_valid(spr2):
			var w = spr1.texture.get_width() * s
			spr1.scale = Vector2(s, s)
			spr2.scale = Vector2(s, s)
			spr1.position.y = target_h - 720.0 * s
			spr2.position.y = target_h - 720.0 * s
			layer_data["width"] = w

	for layer_data in mist_layers:
		var spr1: Sprite2D = layer_data["spr1"]
		var spr2: Sprite2D = layer_data["spr2"]
		if is_instance_valid(spr1) and is_instance_valid(spr2):
			spr1.position.y = target_h - layer_data["y_off"]
			spr2.position.y = target_h - layer_data["y_off"]


	if is_instance_valid(lower_fireflies):
		lower_fireflies.position = Vector2(target_w * 0.32, target_h * 0.76)

	if is_instance_valid(drifting_leaves):
		drifting_leaves.position = Vector2(target_w * 0.60, 20.0)

	if is_instance_valid(foreground_foliage):
		foreground_foliage.update_bounds(target_w, target_h)


func _process(delta: float) -> void:
	if is_instance_valid(bg_root) and bg_root.visible:
		for layer_data in bg_layers:
			var spr1: Sprite2D = layer_data["spr1"]
			var spr2: Sprite2D = layer_data["spr2"]
			var speed: float = layer_data["speed"]
			var width: float = layer_data["width"]

			spr1.position.x -= speed * delta
			spr2.position.x -= speed * delta

			if spr1.position.x <= -width:
				spr1.position.x = spr2.position.x + width
			if spr2.position.x <= -width:
				spr2.position.x = spr1.position.x + width

		# Ground mist parallax drift (frozen if reduce_motion is enabled)
		var mist_speed_mult: float = 0.0 if GameSettings.reduce_motion else 1.0
		for layer_data in mist_layers:
			var spr1: Sprite2D = layer_data["spr1"]
			var spr2: Sprite2D = layer_data["spr2"]
			var speed: float = layer_data["speed"] * mist_speed_mult
			var width: float = layer_data["width"]

			if speed > 0.0:
				spr1.position.x -= speed * delta
				spr2.position.x -= speed * delta

				if spr1.position.x <= -width:
					spr1.position.x = spr2.position.x + width
				if spr2.position.x <= -width:
					spr2.position.x = spr1.position.x + width


		_stars_time += delta
		for star_data in stars_data:
			var spr: Sprite2D = star_data.get("spr")
			if is_instance_valid(spr):
				var cycle: float = star_data.get("cycle", 2.5)
				var phase: float = star_data.get("phase", 0.0)
				var wave: float = (sin((_stars_time + phase) * TAU / cycle) + 1.0) * 0.5
				spr.modulate.a = lerpf(star_data.get("min_a", 0.4), star_data.get("max_a", 1.0), wave)
				if star_data.get("type", 0) == 3:
					var s: float = lerpf(0.85, 1.20, wave)
					spr.scale = Vector2(s, s)

	if is_instance_valid(sanctuary_container) and is_instance_valid(totem_surround):
		sanctuary_container.visible = totem_surround.visible
		sanctuary_container.modulate.a = totem_surround.modulate.a

	if is_loading_assets and not _loading_transitioned:
		_update_threaded_loading(delta)


func setup_background() -> void:
	# 0. Solid dark night sky underlay that covers the full viewport
	var base_underlay = ColorRect.new()
	base_underlay.name = "BaseUnderlay"
	base_underlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	base_underlay.color = Color(0.015, 0.02, 0.03, 1.0)
	base_underlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base_underlay)

	bg_root = Node2D.new()
	bg_root.name = "BackgroundRoot"
	add_child(bg_root)

	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = max(640.0, vp_size.x)
	var target_h: float = max(360.0, vp_size.y)

	# 1. Sky Layer (Rich twilight slate-indigo)
	var sky_tex = load(AssetsScript.PATH_BG_LAYER_5)
	if sky_tex:
		var sky_spr = Sprite2D.new()
		sky_spr.name = "SkySprite"
		sky_spr.texture = sky_tex
		sky_spr.centered = false
		var sky_scale = max(target_w / sky_tex.get_width(), target_h / sky_tex.get_height()) * 1.05
		sky_spr.scale = Vector2(sky_scale, sky_scale)
		sky_spr.modulate = Color(0.52, 0.56, 0.68, 1.0)
		bg_root.add_child(sky_spr)

	# 1.5. Celestial Starfield (Twinkling dark fantasy pixel stars)
	setup_stars(target_w, target_h)

	# 2. Celestial Moon & Soft Radial Lunar Aura (Aligned with Right-Center Haliya Totem Column)
	base_moon_pos = Vector2(target_w * 0.755, 46.0)
	moon_container = Node2D.new()
	moon_container.name = "MoonContainer"
	moon_container.position = base_moon_pos
	bg_root.add_child(moon_container)

	var moon_aura = Sprite2D.new()
	moon_aura.name = "MoonAura"
	moon_aura.texture = create_radial_glow_texture(90, Color(0.85, 0.81, 0.66, 0.22), Color(0.85, 0.81, 0.66, 0.0))
	moon_container.add_child(moon_aura)

	var moon_core = Sprite2D.new()
	moon_core.name = "MoonCore"
	moon_core.texture = create_radial_glow_texture(32, Color(0.90, 0.86, 0.72, 0.30), Color(0.85, 0.81, 0.66, 0.0))
	moon_container.add_child(moon_core)

	var moon_spr = Sprite2D.new()
	moon_spr.name = "MoonSprite"
	var moon_tex = load(AssetsScript.PATH_CRESCENT_MOON)
	if moon_tex:
		moon_spr.texture = moon_tex
	moon_spr.modulate = Color("#d8cfa8")
	moon_container.add_child(moon_spr)

	var tw_moon = create_tween().set_loops()
	tw_moon.tween_property(moon_aura, "modulate:a", 0.75, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_moon.tween_property(moon_aura, "modulate:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 2.5. Subtle Moonlit Mist Ray slanting down onto the Haliya Totem clearing
	var god_ray_tex = load(AssetsScript.PATH_MENU_GOD_RAY)
	if god_ray_tex:
		god_ray_spr = Sprite2D.new()
		god_ray_spr.name = "GodRaySprite"
		god_ray_spr.texture = god_ray_tex
		god_ray_spr.position = Vector2(target_w * 0.72, target_h * 0.48)
		god_ray_spr.scale = Vector2(1.5, 1.2)
		god_ray_spr.rotation = deg_to_rad(-16.0)
		god_ray_spr.modulate = Color(0.76, 0.78, 0.72, 0.08)
		bg_root.add_child(god_ray_spr)

		var tw_ray = create_tween().set_loops()
		tw_ray.tween_property(god_ray_spr, "modulate:a", 0.12, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_ray.tween_property(god_ray_spr, "modulate:a", 0.06, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 3. Layered Forest Silhouettes (Slow, majestic atmospheric drift)
	var s: float = max(0.5, (target_h + 4.0) / 720.0)
	var forest_configs = [
		{"path": AssetsScript.PATH_BG_LAYER_4, "speed": 1.0, "scale": Vector2(s, s), "mod": Color(0.40, 0.45, 0.56, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_3, "speed": 2.2, "scale": Vector2(s, s), "mod": Color(0.46, 0.50, 0.62, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_2, "speed": 4.0, "scale": Vector2(s, s), "mod": Color(0.52, 0.56, 0.68, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_1, "speed": 6.5, "scale": Vector2(s, s), "mod": Color(0.58, 0.62, 0.74, 1.0)}
	]

	for cfg in forest_configs:
		var tex = load(cfg["path"])
		if not tex:
			continue
		var w = tex.get_width() * cfg["scale"].x

		var spr1 = Sprite2D.new()
		spr1.texture = tex
		spr1.centered = false
		spr1.scale = cfg["scale"]
		spr1.modulate = cfg["mod"]
		spr1.position = Vector2(0, target_h - 720.0 * s)
		bg_root.add_child(spr1)

		var spr2 = Sprite2D.new()
		spr2.texture = tex
		spr2.centered = false
		spr2.scale = cfg["scale"]
		spr2.modulate = cfg["mod"]
		spr2.position = Vector2(w, target_h - 720.0 * s)
		bg_root.add_child(spr2)

		bg_layers.append({
			"spr1": spr1,
			"spr2": spr2,
			"speed": cfg["speed"],
			"width": w
		})

	# 3.5. Ground Mist (2 slow-drifting, dithered low-opacity fog bands near bottom third)
	setup_ground_mist(target_w, target_h)

	# 4. Sacred Haliya Totem (Single unified TotemSurround hero group)
	setup_totem(target_w, target_h)

	# 4.5. Lower-Left and Center Fireflies + Drifting Leaves
	setup_lower_fireflies_and_leaves(target_w, target_h)

	# 5. Foreground Silhouettes (Organic Part 3 foliage: corner leaves + bottom foliage strip)
	setup_foreground_silhouettes(target_w, target_h)

	# 6. Atmospheric Dark Vignette Overlay (inside bg_root, z_index 5, strictly behind UI)
	var vignette = ColorRect.new()
	vignette.name = "VignetteOverlay"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.02, 0.03, 0.05, 0.16)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.z_index = 5
	bg_root.add_child(vignette)


func setup_ground_mist(target_w: float, target_h: float) -> void:
	mist_container = Node2D.new()
	mist_container.name = "MistContainer"
	bg_root.add_child(mist_container)
	mist_layers.clear()

	var mist_tex_0 = load(C.TEX_MIST_BAND_0) as Texture2D
	var mist_tex_1 = load(C.TEX_MIST_BAND_1) as Texture2D

	var mist_configs = [
		{"tex": mist_tex_0, "speed": 2.5, "y_off": 64.0, "alpha": 0.85},
		{"tex": mist_tex_1, "speed": 4.5, "y_off": 40.0, "alpha": 0.95}
	]

	for cfg in mist_configs:
		var tex = cfg["tex"]
		if not tex:
			continue
		var w = float(tex.get_width())
		var spr1 = Sprite2D.new()
		spr1.texture = tex
		spr1.centered = false
		spr1.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr1.modulate.a = cfg["alpha"]
		spr1.position = Vector2(0.0, target_h - cfg["y_off"])
		mist_container.add_child(spr1)

		var spr2 = Sprite2D.new()
		spr2.texture = tex
		spr2.centered = false
		spr2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr2.modulate.a = cfg["alpha"]
		spr2.position = Vector2(w, target_h - cfg["y_off"])
		mist_container.add_child(spr2)

		mist_layers.append({
			"spr1": spr1,
			"spr2": spr2,
			"speed": cfg["speed"],
			"width": w,
			"y_off": cfg["y_off"]
		})


func setup_totem(target_w: float, _target_h: float) -> void:
	totem_surround = TotemSurroundScene.instantiate()
	totem_surround.name = "TotemGroup"
	base_altar_pos = Vector2(round(target_w * 0.755), 231.0)
	totem_surround.position = base_altar_pos
	totem_surround.z_index = 2
	bg_root.add_child(totem_surround)


func setup_lower_fireflies_and_leaves(target_w: float, target_h: float) -> void:
	lower_fireflies = CPUParticles2D.new()
	lower_fireflies.name = "LowerCenterFireflies"
	lower_fireflies.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lower_fireflies.position = Vector2(target_w * 0.32, target_h * 0.76)
	lower_fireflies.amount = 18
	lower_fireflies.lifetime = 5.0
	lower_fireflies.preprocess = 3.0
	lower_fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	lower_fireflies.emission_rect_extents = Vector2(target_w * 0.28, target_h * 0.22)
	lower_fireflies.direction = Vector2(-0.1, -0.4)
	lower_fireflies.spread = 40.0
	lower_fireflies.gravity = Vector2(-1, -3)
	lower_fireflies.initial_velocity_min = 3.0
	lower_fireflies.initial_velocity_max = 8.0
	lower_fireflies.scale_amount_min = 1.0
	lower_fireflies.scale_amount_max = 2.0
	lower_fireflies.color = Color(0.85, 0.81, 0.66, 0.35)
	bg_root.add_child(lower_fireflies)

	drifting_leaves = CPUParticles2D.new()
	drifting_leaves.name = "DriftingLeaves"
	drifting_leaves.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	drifting_leaves.position = Vector2(target_w * 0.60, 20.0)
	drifting_leaves.amount = 4
	drifting_leaves.lifetime = 10.0
	drifting_leaves.preprocess = 5.0
	drifting_leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	drifting_leaves.emission_rect_extents = Vector2(target_w * 0.35, 15.0)
	drifting_leaves.direction = Vector2(-0.6, 1.0)
	drifting_leaves.spread = 20.0
	drifting_leaves.gravity = Vector2(-4, 6)
	drifting_leaves.initial_velocity_min = 6.0
	drifting_leaves.initial_velocity_max = 14.0
	drifting_leaves.scale_amount_min = 1.0
	drifting_leaves.scale_amount_max = 2.0
	drifting_leaves.color = Color(0.18, 0.26, 0.24, 0.55)
	bg_root.add_child(drifting_leaves)


func setup_foreground_silhouettes(target_w: float, target_h: float) -> void:
	foreground_foliage = ForegroundFoliageScene.instantiate()
	foreground_foliage.name = "ForegroundFoliage"
	foreground_foliage.z_index = 4
	bg_root.add_child(foreground_foliage)
	foreground_foliage.update_bounds(target_w, target_h)


static func create_radial_glow_texture(radius: int, inner_color: Color, outer_color: Color) -> GradientTexture2D:
	var glow_tex := GradientTexture2D.new()
	glow_tex.width = radius * 2
	glow_tex.height = radius * 2
	glow_tex.fill = GradientTexture2D.FILL_RADIAL
	glow_tex.fill_from = Vector2(0.5, 0.5)
	glow_tex.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([inner_color, outer_color])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	glow_tex.gradient = grad
	return glow_tex


static func create_pixel_star_texture(size_type: int) -> ImageTexture:
	match size_type:
		0:
			var img = Image.create(1, 1, false, Image.FORMAT_RGBA8)
			img.set_pixel(0, 0, Color(1, 1, 1, 1.0))
			return ImageTexture.create_from_image(img)
		1:
			var img = Image.create(2, 2, false, Image.FORMAT_RGBA8)
			img.fill(Color(1, 1, 1, 0.90))
			return ImageTexture.create_from_image(img)
		2:
			var img = Image.create(3, 3, false, Image.FORMAT_RGBA8)
			img.fill(Color(0, 0, 0, 0))
			img.set_pixel(1, 1, Color(1, 1, 1, 1.0))
			img.set_pixel(1, 0, Color(1, 1, 1, 0.85))
			img.set_pixel(1, 2, Color(1, 1, 1, 0.85))
			img.set_pixel(0, 1, Color(1, 1, 1, 0.85))
			img.set_pixel(2, 1, Color(1, 1, 1, 0.85))
			return ImageTexture.create_from_image(img)
		3:
			var img = Image.create(5, 5, false, Image.FORMAT_RGBA8)
			img.fill(Color(0, 0, 0, 0))
			img.set_pixel(2, 2, Color(1, 1, 1, 1.0))
			img.set_pixel(2, 1, Color(1, 1, 1, 0.95))
			img.set_pixel(2, 3, Color(1, 1, 1, 0.95))
			img.set_pixel(1, 2, Color(1, 1, 1, 0.95))
			img.set_pixel(3, 2, Color(1, 1, 1, 0.95))
			img.set_pixel(2, 0, Color(1, 1, 1, 0.55))
			img.set_pixel(2, 4, Color(1, 1, 1, 0.55))
			img.set_pixel(0, 2, Color(1, 1, 1, 0.55))
			img.set_pixel(4, 2, Color(1, 1, 1, 0.55))
			img.set_pixel(1, 1, Color(1, 1, 1, 0.35))
			img.set_pixel(3, 1, Color(1, 1, 1, 0.35))
			img.set_pixel(1, 3, Color(1, 1, 1, 0.35))
			img.set_pixel(3, 3, Color(1, 1, 1, 0.35))
			return ImageTexture.create_from_image(img)
		_:
			var img = Image.create(1, 1, false, Image.FORMAT_RGBA8)
			img.set_pixel(0, 0, Color(1, 1, 1, 1.0))
			return ImageTexture.create_from_image(img)


func setup_stars(target_w: float, target_h: float) -> void:
	stars_container = Node2D.new()
	stars_container.name = "StarsContainer"
	bg_root.add_child(stars_container)
	var sky_spr = bg_root.get_node_or_null("SkySprite")
	if sky_spr:
		bg_root.move_child(stars_container, sky_spr.get_index() + 1)

	var tex_0: ImageTexture = create_pixel_star_texture(0)
	var tex_1: ImageTexture = create_pixel_star_texture(1)
	var tex_2: ImageTexture = create_pixel_star_texture(2)
	var tex_3: ImageTexture = create_pixel_star_texture(3)

	stars_data.clear()

	var star_palette = [
		Color(1.0, 1.0, 1.0),
		Color(1.0, 0.96, 0.82),
		Color(0.85, 0.93, 1.0),
		Color(0.98, 0.96, 0.90)
	]

	var rng = RandomNumberGenerator.new()
	rng.seed = 20261004

	var placed = 0
	var attempts = 0
	var target_stars = 38

	while placed < target_stars and attempts < 600:
		attempts += 1
		var nx: float = rng.randf_range(0.015, 0.985)
		var ny: float = rng.randf_range(0.02, 0.44)

		var ref_x: float = nx * 640.0
		var ref_y: float = ny * 360.0

		if ref_x >= 40.0 and ref_x <= 316.0 and ref_y >= 12.0 and ref_y <= 340.0:
			continue

		var moon_ref_pos := Vector2(640.0 * 0.755, 56.0)
		if Vector2(ref_x, ref_y).distance_to(moon_ref_pos) < 26.0:
			continue

		var roll = rng.randf()
		var type = 0
		var tex: ImageTexture = tex_0
		if roll < 0.12:
			type = 3
			tex = tex_3
		elif roll < 0.38:
			type = 2
			tex = tex_2
		elif roll < 0.62:
			type = 1
			tex = tex_1
		else:
			type = 0
			tex = tex_0

		var col: Color = star_palette[rng.randi() % star_palette.size()]
		var base_alpha: float = rng.randf_range(0.85, 1.0) if type >= 2 else rng.randf_range(0.70, 0.95)

		var spr = Sprite2D.new()
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = true
		spr.position = Vector2(nx * target_w, ny * target_h)
		spr.modulate = Color(col.r, col.g, col.b, base_alpha)
		stars_container.add_child(spr)

		var cycle_dur: float = rng.randf_range(1.8, 4.0)
		var min_a: float = base_alpha * rng.randf_range(0.35, 0.58)
		var phase: float = rng.randf_range(0.0, cycle_dur)

		stars_data.append({
			"spr": spr,
			"nx": nx,
			"ny": ny,
			"type": type,
			"cycle": cycle_dur,
			"phase": phase,
			"min_a": min_a,
			"max_a": 1.0
		})
		placed += 1


func setup_ambient_particles() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = max(640.0, vp_size.x)
	var target_h: float = max(360.0, vp_size.y)

	# Keep ambient firefly motes inside bg_root and restricted to the right jungle clearing
	# so stray particle dots never drift over the left-third menu text (e.g. after "QUIT").
	var particles = CPUParticles2D.new()
	particles.name = "AmbientMotes"
	particles.position = Vector2(target_w * 0.68, target_h * 0.5)
	particles.amount = 18
	particles.lifetime = 6.0
	particles.preprocess = 4.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(target_w * 0.28, target_h * 0.45)
	particles.direction = Vector2(-0.2, -0.5)
	particles.spread = 35.0
	particles.gravity = Vector2(-1, -4)
	particles.initial_velocity_min = 4.0
	particles.initial_velocity_max = 11.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.0
	particles.color = Color(0.78, 0.75, 0.64, 0.30)
	bg_root.add_child(particles)

	var altar_motes = CPUParticles2D.new()
	altar_motes.name = "AltarMotes"
	altar_motes.position = Vector2(target_w * 0.755, target_h - 130.0)
	altar_motes.amount = 12
	altar_motes.lifetime = 4.5
	altar_motes.preprocess = 2.0
	altar_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	altar_motes.emission_rect_extents = Vector2(28.0, 95.0)
	altar_motes.direction = Vector2(0, -1.0)
	altar_motes.spread = 25.0
	altar_motes.gravity = Vector2(-2, -6)
	altar_motes.initial_velocity_min = 6.0
	altar_motes.initial_velocity_max = 14.0
	altar_motes.scale_amount_min = 1.0
	altar_motes.scale_amount_max = 2.0
	altar_motes.color = Color(0.84, 0.81, 0.70, 0.40)
	bg_root.add_child(altar_motes)


# ============================================================================
# REDESIGNED PIXEL-ART UI LAYER (Frameless Left-Third Menu + Shared Theme)
# ============================================================================
func setup_ui() -> void:
	# Dedicated UI container with high z_index so all UI sits strictly on top of
	# every background, mist, firefly, and foliage layer.
	var ui_layer = Control.new()
	ui_layer.name = "UILayer"
	ui_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.z_index = 25
	add_child(ui_layer)

	# 1. Soft Bayer-dithered dark gradient on the left third (~60% charcoal to transparent)
	left_gradient_rect = TextureRect.new()
	left_gradient_rect.name = "LeftDitherGradient"
	left_gradient_rect.texture = load(C.TEX_LEFT_GRADIENT)
	left_gradient_rect.position = Vector2.ZERO
	left_gradient_rect.size = Vector2(260, 360)
	left_gradient_rect.stretch_mode = TextureRect.STRETCH_SCALE
	left_gradient_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(left_gradient_rect)

	# 2. Reusable Title Lockup component ("HALIYA" carved pixel sprite + zigzag divider + "Mask of Sorrows")
	# Positioned at (x=26, y=48) so the Title + Menu block is vertically balanced against the right-side totem.
	title_container = HaliyaTitleLockupScene.instantiate()
	title_container.name = "TitleContainer"
	title_container.position = Vector2(C.MENU_LEFT_EDGE_X, C.MENU_BLOCK_TOP_Y)
	title_container.z_index = 1
	title_container.set_centered_layout(false)
	ui_layer.add_child(title_container)

	title_haliya_rect = title_container.title_sprite
	zigzag_divider_rect = title_container.divider_rect
	subtitle_label = title_container.subtitle_label

	# 3. Frameless Hierarchical Menu Items in left third
	# Placed at x=26 (C.MENU_LEFT_EDGE_X) so Title, Subtitle, Caption, VersionLabel, and all
	# unselected menu items share the exact same left edge (x=26). Only the selected item slides right (+6px).
	menu_vbox = VBoxContainer.new()
	menu_vbox.name = "MenuVBox"
	menu_vbox.position = Vector2(C.MENU_LEFT_EDGE_X, C.MENU_BLOCK_TOP_Y + C.MENU_ITEMS_OFFSET_Y)
	menu_vbox.size = Vector2(228, 214)
	menu_vbox.z_index = 1
	menu_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	ui_layer.add_child(menu_vbox)

	# 4. Version text bottom-left, tiny, readable contrast (> 6.0:1), aligned to shared left edge x=26
	ver_label = Label.new()
	ver_label.name = "VersionLabel"
	ver_label.theme_type_variation = &"VersionLabel"
	ver_label.text = "v1.0.0 · Dark Fantasy Edition"
	ver_label.position = Vector2(C.MENU_LEFT_EDGE_X, 342)
	ver_label.size = Vector2(220, 14)
	ver_label.z_index = 2
	ver_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ver_label)

	_rebuild_menu_buttons()


func _has_any_saved_progress() -> bool:
	for slot_idx in range(1, SaveManager.DEFAULT_SLOT_COUNT + 1):
		if SaveManager.has_save(slot_idx):
			return true
	return false


func _get_continue_caption() -> String:
	var active_slot: int = SaveManager.active_slot if SaveManager.active_slot > 0 else 1
	var meta: Dictionary = SaveManager.get_slot_metadata(active_slot)
	if not meta.get("exists", false):
		for s in range(1, SaveManager.DEFAULT_SLOT_COUNT + 1):
			var test_meta: Dictionary = SaveManager.get_slot_metadata(s)
			if test_meta.get("exists", false):
				meta = test_meta
				active_slot = s
				break
	if meta.get("exists", false):
		var st_title: String = _format_clean_stage_title(str(meta.get("stage_title", "Whispering Canopy")))
		return "Act 1 · %s" % st_title
	return "Act 1 · Whispering Canopy"


func _rebuild_menu_buttons() -> void:
	if not is_instance_valid(menu_vbox):
		return
	for child in menu_vbox.get_children():
		child.queue_free()
	menu_buttons.clear()

	var has_saved_game: bool = _has_any_saved_progress()

	# Show "Continue" at the top of the menu when a save file exists; hide it when none exists.
	if has_saved_game:
		var continue_caption: String = _get_continue_caption()
		var _btn_continue := _add_haliya_menu_item("Continue", C.MenuTier.PRIMARY, continue_caption, _on_continue_pressed)
		var _btn_begin := _add_haliya_menu_item("Begin Journey", C.MenuTier.MEDIUM, "", _on_begin_journey_pressed)
	else:
		var _btn_begin := _add_haliya_menu_item("Begin Journey", C.MenuTier.PRIMARY, "Act 1 · Whispering Canopy", _on_begin_journey_pressed)

	var _btn_stages := _add_haliya_menu_item("Stage Select", C.MenuTier.MEDIUM, "", _on_stage_select_pressed)
	var _btn_codex := _add_haliya_menu_item("Lore Codex", C.MenuTier.SMALL, "", _on_codex_pressed)
	var _btn_settings := _add_haliya_menu_item("Settings", C.MenuTier.SMALL, "", _on_settings_pressed)
	var _btn_howto := _add_haliya_menu_item("How to Play", C.MenuTier.SMALL, "", _on_controls_pressed)
	var _btn_quit := _add_haliya_menu_item("Quit", C.MenuTier.MUTED, "", _on_quit_pressed)

	# Wire explicit keyboard focus neighbors (Up/Down/W/S wrap cleanly around the list)
	var count := menu_buttons.size()
	for i in range(count):
		var curr_btn: Button = menu_buttons[i].button
		var prev_btn: Button = menu_buttons[(i - 1 + count) % count].button
		var next_btn: Button = menu_buttons[(i + 1) % count].button
		curr_btn.focus_neighbor_top = curr_btn.get_path_to(prev_btn)
		curr_btn.focus_neighbor_bottom = curr_btn.get_path_to(next_btn)

	if not menu_buttons.is_empty() and menu_vbox.visible:
		menu_buttons[0].call_deferred("grab_item_focus")


func _add_haliya_menu_item(text: String, tier: int, caption: String, callback: Callable) -> VBoxContainer:
	var item: VBoxContainer = HaliyaMenuButtonScene.instantiate()
	item.setup(text, tier, caption)
	item.item_selected.connect(_play_ui_hover)
	item.item_activated.connect(func():
		_play_ui_select()
		callback.call()
	)
	menu_vbox.add_child(item)
	menu_buttons.append(item)
	return item


func _play_staggered_menu_entrance() -> void:
	for i in range(menu_buttons.size()):
		var item: VBoxContainer = menu_buttons[i]
		item.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_interval(float(i) * C.STAGGER_DELAY_SEC)
		# Stepped 2-step pixel fade-in per item, staggered 80ms apart
		tw.tween_callback(func(): item.modulate.a = 0.5)
		tw.tween_interval(0.04)
		tw.tween_callback(func(): item.modulate.a = 1.0)


func setup_screen_manager() -> void:
	screen_manager = ScreenManagerScript.new()
	screen_manager.name = "UIScreenManager"
	screen_manager.z_index = 40
	add_child(screen_manager)

	# Register all 5 redesigned sub-screens
	var settings_scr = SettingsScreenScene.instantiate()
	screen_manager.register_screen("settings", settings_scr)

	var stage_scr = StageSelectScreenScene.instantiate()
	stage_scr.stage_launched.connect(func(level_idx: int):
		_get_main_script().restore_saved_run = false
		if level_idx < 0:
			if is_transitioning:
				return
			is_transitioning = true
			if is_instance_valid(bgm_player):
				bgm_player.stop()
			get_tree().change_scene_to_file("res://scenes/tutorial_stage.tscn")
		else:
			_start_game_at_level(level_idx)
	)
	screen_manager.register_screen("stage_select", stage_scr)

	var codex_scr = LoreCodexScreenScene.instantiate()
	screen_manager.register_screen("lore_codex", codex_scr)

	var howto_scr = HowToPlayScreenScene.instantiate()
	screen_manager.register_screen("how_to_play", howto_scr)

	var quit_scr = QuitConfirmScreenScene.instantiate()
	quit_scr.quit_confirmed.connect(func():
		get_tree().quit()
	)
	screen_manager.register_screen("quit_confirm", quit_scr)

	# Connect audio hooks & modal visibility hooks
	screen_manager.sfx_hover.connect(_play_ui_hover)
	screen_manager.sfx_confirm.connect(_play_ui_select)
	screen_manager.sfx_back.connect(_play_ui_select)
	screen_manager.screen_changed.connect(func(screen_id: String):
		_set_totem_modal_mode(not screen_id.is_empty())
	)


static func _format_clean_stage_title(raw_title: String) -> String:
	var st_title: String = raw_title.strip_edges()
	if st_title.is_empty():
		return "Whispering Canopy"
	var colon_idx = st_title.rfind(":")
	if colon_idx >= 0 and colon_idx + 1 < st_title.length():
		st_title = st_title.substr(colon_idx + 1).strip_edges()
	var paren_idx = st_title.find("(")
	if paren_idx > 0:
		st_title = st_title.substr(0, paren_idx).strip_edges()
	var dash_idx = st_title.rfind("—")
	if dash_idx >= 0 and dash_idx + 1 < st_title.length():
		st_title = st_title.substr(dash_idx + 1).strip_edges()
	return st_title


# ============================================================================
# CHRONICLE SLOTS MODAL (Opened via "Continue", styled via haliya_theme.tres)
# ============================================================================
func setup_slot_select_modal() -> void:
	slot_select_modal = Control.new()
	slot_select_modal.name = "SlotSelectModal"
	slot_select_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot_select_modal.visible = false
	slot_select_modal.z_index = 45
	add_child(slot_select_modal)

	var dialog: Control = HaliyaPanelDialogScene.instantiate()
	dialog.dialog_title = "SELECT CHRONICLE SLOT"
	dialog.panel_size = Vector2(520, 276)
	dialog.close_requested.connect(func():
		_play_ui_select()
		_close_modals()
	)
	slot_select_modal.add_child(dialog)

	var body: VBoxContainer = dialog.body_container
	slot_cards_container = VBoxContainer.new()
	slot_cards_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slot_cards_container.add_theme_constant_override("separation", C.SPACING_SM)
	body.add_child(slot_cards_container)

	_refresh_slot_cards()


func _refresh_slot_cards() -> void:
	if not is_instance_valid(slot_cards_container):
		return
	for c in slot_cards_container.get_children():
		c.queue_free()

	var slot_titles = ["Bathala's Path", "Mayari's Ward", "Tala's Guidance"]

	for slot_idx in range(1, 4):
		var meta = SaveManager.get_slot_metadata(slot_idx)
		var exists = meta.get("exists", false)

		var card = PanelContainer.new()
		card.theme_type_variation = &"InnerHighlightPanel" if exists else &"InnerDarkPanel"
		slot_cards_container.add_child(card)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", C.SPACING_MD)
		card.add_child(hbox)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", C.SPACING_XS)
		hbox.add_child(info_vbox)

		var title_lbl = Label.new()
		title_lbl.theme_type_variation = &"SectionHeaderLabel"
		title_lbl.clip_text = true
		title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

		if not exists:
			title_lbl.text = "SLOT %d: %s • [EMPTY]" % [slot_idx, slot_titles[slot_idx - 1]]
			info_vbox.add_child(title_lbl)

			var sub_lbl = Label.new()
			sub_lbl.theme_type_variation = &"CaptionLabel"
			sub_lbl.text = "No journey recorded. Begin a new pilgrimage."
			info_vbox.add_child(sub_lbl)

			var btn_new = Button.new()
			btn_new.text = "NEW RUN"
			btn_new.custom_minimum_size = Vector2(78, 20)
			var s_idx = slot_idx
			btn_new.pressed.connect(func():
				_play_ui_select()
				_start_new_slot(s_idx)
			)
			hbox.add_child(btn_new)
		else:
			var clean_st = _format_clean_stage_title(str(meta.get("stage_title", "Whispering Canopy")))
			title_lbl.text = "SLOT %d: %s • %s" % [slot_idx, slot_titles[slot_idx - 1], clean_st]
			info_vbox.add_child(title_lbl)

			var ptime: float = float(meta.get("play_time_seconds", 0.0))
			var p_min = int(ptime / 60.0)
			var p_sec = int(ptime) % 60
			var det_lbl = Label.new()
			det_lbl.theme_type_variation = &"CaptionLabel"
			det_lbl.text = "Time %02d:%02d • HP %d • Armor %d" % [
				p_min, p_sec,
				meta.get("current_hp", 5),
				meta.get("current_armor", 3)
			]
			info_vbox.add_child(det_lbl)

			var s_idx = slot_idx
			var btn_cont = Button.new()
			btn_cont.text = "RESUME"
			btn_cont.custom_minimum_size = Vector2(70, 20)
			btn_cont.pressed.connect(func():
				_play_ui_select()
				_continue_slot(s_idx)
			)
			hbox.add_child(btn_cont)

			var btn_new = Button.new()
			btn_new.text = "NEW"
			btn_new.custom_minimum_size = Vector2(54, 20)
			btn_new.pressed.connect(func():
				_play_ui_select()
				_start_new_slot(s_idx)
			)
			hbox.add_child(btn_new)

			var btn_del = Button.new()
			btn_del.text = "DEL"
			btn_del.custom_minimum_size = Vector2(48, 20)
			btn_del.pressed.connect(func():
				_play_ui_select()
				SaveManager.delete_slot(s_idx)
				_refresh_slot_cards()
				_rebuild_menu_buttons()
			)
			hbox.add_child(btn_del)


func _on_continue_pressed() -> void:
	if is_transitioning:
		return
	_refresh_slot_cards()
	slot_select_modal.visible = true
	_set_totem_modal_mode(true)


func _continue_slot(slot: int) -> void:
	if is_transitioning:
		return
	SaveManager.active_slot = slot
	var meta = SaveManager.get_slot_metadata(slot)
	_get_main_script().restore_saved_run = true
	var lvl_idx = int(meta.get("level_idx", 0))
	_start_game_at_level(lvl_idx)


func _start_new_slot(slot: int) -> void:
	if is_transitioning:
		return
	SaveManager.active_slot = slot
	SaveManager.delete_slot(slot)
	_get_main_script().restore_saved_run = false
	slot_select_modal.visible = false
	if is_instance_valid(comic_story_viewer):
		comic_story_viewer.open_story(true)
	else:
		_start_game_at_level(0)


func setup_bgm() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "MenuBGMPlayer"
	bgm_player.bus = "Master"
	bgm_player.stream = ProceduralAudio.get_kulintang_exploration_bgm()
	bgm_player.volume_db = -80.0
	add_child(bgm_player)
	bgm_player.play()

	if has_shown_splash:
		var tw = create_tween()
		tw.tween_property(bgm_player, "volume_db", -8.0, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		var tw = create_tween()
		tw.tween_property(bgm_player, "volume_db", -26.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func setup_fade_overlay() -> void:
	_dissolve_textures.clear()
	for p in C.TEX_DISSOLVE_STEPS:
		var t = load(p)
		if t is Texture2D:
			_dissolve_textures.append(t)

	dissolve_rect = TextureRect.new()
	dissolve_rect.name = "DissolveOverlay"
	dissolve_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	dissolve_rect.stretch_mode = TextureRect.STRETCH_TILE
	dissolve_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dissolve_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dissolve_rect.z_index = 99
	dissolve_rect.visible = false
	add_child(dissolve_rect)

	fade_rect = ColorRect.new()
	fade_rect.name = "FadeOverlay"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 100
	add_child(fade_rect)


func _play_dissolve_reveal(done_callback: Callable = Callable(), step_sec: float = C.DISSOLVE_STEP_SEC) -> Tween:
	var tw := create_tween()
	var step_count: int = _dissolve_textures.size()
	if step_count == 0 or not is_instance_valid(dissolve_rect):
		fade_rect.color.a = 0.0
		if done_callback.is_valid():
			tw.tween_callback(done_callback)
		return tw

	fade_rect.color.a = 0.0
	dissolve_rect.visible = true
	dissolve_rect.texture = _dissolve_textures[step_count - 1]
	for i in range(step_count - 1, -1, -1):
		var tex: Texture2D = _dissolve_textures[i]
		tw.tween_callback(func(): dissolve_rect.texture = tex)
		tw.tween_interval(step_sec)
	tw.tween_callback(func():
		dissolve_rect.visible = false
		if done_callback.is_valid():
			done_callback.call()
	)
	return tw


func _play_dissolve_transition(midpoint_callback: Callable, done_callback: Callable = Callable(), step_sec: float = C.DISSOLVE_STEP_SEC) -> Tween:
	var tw := create_tween()
	var step_count: int = _dissolve_textures.size()
	if step_count == 0 or not is_instance_valid(dissolve_rect):
		if midpoint_callback.is_valid():
			midpoint_callback.call()
		if done_callback.is_valid():
			done_callback.call()
		return tw

	dissolve_rect.visible = true
	for i in range(step_count):
		var tex: Texture2D = _dissolve_textures[i]
		tw.tween_callback(func(): dissolve_rect.texture = tex)
		tw.tween_interval(step_sec)
	tw.tween_callback(func():
		fade_rect.color.a = 1.0
		if midpoint_callback.is_valid():
			midpoint_callback.call()
	)
	tw.tween_interval(maxf(0.18, step_sec * 2.0))
	tw.tween_callback(func(): fade_rect.color.a = 0.0)
	for i in range(step_count - 1, -1, -1):
		var tex: Texture2D = _dissolve_textures[i]
		tw.tween_callback(func(): dissolve_rect.texture = tex)
		tw.tween_interval(step_sec)
	tw.tween_callback(func():
		dissolve_rect.visible = false
		if done_callback.is_valid():
			done_callback.call()
	)
	return tw


func _close_modals() -> void:
	if is_instance_valid(slot_select_modal) and slot_select_modal.visible:
		slot_select_modal.visible = false
	if is_instance_valid(screen_manager) and screen_manager.is_any_screen_open():
		screen_manager.close_active_screen()
	if is_instance_valid(settings_menu) and settings_menu.visible:
		settings_menu.close_menu()
	if is_instance_valid(bestiary_codex_ui) and bestiary_codex_ui.visible:
		bestiary_codex_ui.close_menu()
	_set_totem_modal_mode(false)
	if not menu_buttons.is_empty():
		menu_buttons[0].call_deferred("grab_item_focus")


func _set_totem_modal_mode(in_modal: bool) -> void:
	var target_alpha: float = 0.25 if in_modal else 1.0
	if is_instance_valid(totem_surround):
		var tw = create_tween()
		tw.tween_property(totem_surround, "modulate:a", target_alpha, 0.16).set_trans(Tween.TRANS_LINEAR)
	var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else get_node_or_null("AltarMotes")
	if is_instance_valid(motes):
		motes.emitting = not in_modal

	# Hide the Main Menu title lockup, menu buttons, left gradient, and version label
	# while any sub-screen or modal is open so the dialog sits cleanly over the jungle scene.
	var show_main_ui: bool = (not in_modal) and (not is_in_splash) and (not is_loading_assets) and (not is_in_press_start)
	if is_instance_valid(title_container) and not is_loading_assets and not is_in_press_start:
		title_container.visible = show_main_ui
	if is_instance_valid(menu_vbox):
		menu_vbox.visible = show_main_ui
	if is_instance_valid(left_gradient_rect):
		left_gradient_rect.visible = show_main_ui
	if is_instance_valid(ver_label):
		ver_label.visible = show_main_ui


func _on_begin_journey_pressed() -> void:
	if is_transitioning:
		return
	_get_main_script().restore_saved_run = false
	if is_instance_valid(bgm_player):
		bgm_player.stop()
	if is_instance_valid(sfx_ui_player):
		sfx_ui_player.stop()
	if is_instance_valid(menu_vbox):
		menu_vbox.visible = false
	if is_instance_valid(left_gradient_rect):
		left_gradient_rect.visible = false
	if is_inside_tree() and get_viewport():
		get_viewport().gui_release_focus()
	if is_instance_valid(comic_story_viewer):
		comic_story_viewer.open_story(true)
	else:
		_start_game_at_level(0)


func _on_story_completed() -> void:
	if is_instance_valid(comic_story_viewer) and comic_story_viewer.is_prologue_mode:
		if is_instance_valid(bgm_player):
			bgm_player.stop()
		if is_instance_valid(sfx_ui_player):
			sfx_ui_player.stop()
		_get_main_script().start_level_idx = 0
		if is_inside_tree() and get_tree():
			get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		if is_instance_valid(menu_vbox):
			menu_vbox.visible = true
			menu_vbox.modulate.a = 1.0
		if is_instance_valid(left_gradient_rect):
			left_gradient_rect.visible = true
			left_gradient_rect.modulate.a = 1.0
		if is_instance_valid(bgm_player) and not bgm_player.playing:
			bgm_player.volume_db = -8.0
			bgm_player.play()
		if not menu_buttons.is_empty():
			menu_buttons[0].call_deferred("grab_item_focus")


func _on_stage_select_pressed() -> void:
	if is_transitioning:
		return
	screen_manager.open_screen("stage_select")


func _on_codex_pressed() -> void:
	if is_transitioning:
		return
	screen_manager.open_screen("lore_codex")


func _on_settings_pressed() -> void:
	if is_transitioning:
		return
	screen_manager.open_screen("settings")


func _on_controls_pressed() -> void:
	if is_transitioning:
		return
	screen_manager.open_screen("how_to_play")


func _on_quit_pressed() -> void:
	if is_transitioning:
		return
	screen_manager.open_screen("quit_confirm")


func _start_game_at_level(lvl_idx: int) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	if is_instance_valid(bgm_player):
		var tw_bgm = create_tween()
		tw_bgm.tween_property(bgm_player, "volume_db", -40.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var tw = create_tween().set_parallel(true)
	tw.tween_property(fade_rect, "color:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(totem_surround):
		tw.tween_property(totem_surround, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(moon_container):
		tw.tween_property(moon_container, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(stars_container):
		tw.tween_property(stars_container, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(title_container):
		tw.tween_property(title_container, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if is_instance_valid(menu_vbox):
		tw.tween_property(menu_vbox, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else get_node_or_null("AltarMotes")
	if is_instance_valid(motes):
		motes.emitting = false

	var tw_seq = create_tween()
	tw_seq.tween_interval(0.45)
	tw_seq.tween_callback(func():
		if is_instance_valid(bgm_player):
			bgm_player.stop()
		if is_instance_valid(sfx_ui_player):
			sfx_ui_player.stop()
		_get_main_script().start_level_idx = lvl_idx
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)


func _unhandled_input(event: InputEvent) -> void:
	if is_in_splash or is_in_press_start or is_transitioning:
		return

	if is_instance_valid(slot_select_modal) and slot_select_modal.visible:
		if event.is_action_pressed("ui_cancel"):
			_play_ui_select()
			_close_modals()
			get_viewport().set_input_as_handled()
		return

	if is_instance_valid(screen_manager) and screen_manager.is_any_screen_open():
		return

	# Ensure keyboard focus is never lost on the Main Menu
	if event is InputEventKey and event.pressed and not event.echo:
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner == null or not menu_vbox.is_ancestor_of(focus_owner):
			if not menu_buttons.is_empty():
				menu_buttons[0].grab_item_focus()
				get_viewport().set_input_as_handled()


func setup_step3_ui() -> void:
	step3_container = Control.new()
	step3_container.name = "Step3TitleContainer"
	step3_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	step3_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(step3_container)

	var title_aura = Sprite2D.new()
	title_aura.name = "TitleAura"
	title_aura.position = Vector2(320.0, 146.0)
	title_aura.texture = create_radial_glow_texture(150, Color(0.98, 0.95, 0.85, 0.14), Color(0.85, 0.82, 0.70, 0.0))
	step3_container.add_child(title_aura)

	# Note: The Title Screen and Main Menu share the single reusable `title_container` (HaliyaTitleLockup)
	# so the title glides continuously from center-screen (TITLE_CENTER_POS) to top-left (26, 48).
	step3_title_box = title_container

	step3_press_start_label = Label.new()
	step3_press_start_label.name = "Step3PressStartLabel"
	step3_press_start_label.theme_type_variation = &"PressStartLabel"
	step3_press_start_label.anchor_left = 0.5
	step3_press_start_label.anchor_right = 0.5
	step3_press_start_label.anchor_top = 1.0
	step3_press_start_label.anchor_bottom = 1.0
	step3_press_start_label.offset_left = -180.0
	step3_press_start_label.offset_right = 180.0
	step3_press_start_label.offset_top = -54.0
	step3_press_start_label.offset_bottom = -24.0
	step3_press_start_label.text = "PRESS ANY KEY TO START"
	step3_press_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step3_press_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	step3_press_start_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	step3_container.add_child(step3_press_start_label)


func setup_splash_layer() -> void:
	splash_layer = Control.new()
	splash_layer.name = "SplashLayer"
	splash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	splash_layer.z_index = 90
	splash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(splash_layer)

	var splash_bg = ColorRect.new()
	splash_bg.name = "SplashBG"
	splash_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	splash_bg.color = Color(0.010, 0.013, 0.018, 1.0)
	splash_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splash_layer.add_child(splash_bg)

	# Card 1: Log's Production studio logo (pixelated bone-cream #d8cfa8, Nearest filter, 1:1 integer scale)
	logs_page = Control.new()
	logs_page.name = "LogsPage"
	logs_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	logs_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logs_page.visible = true
	splash_layer.add_child(logs_page)

	var logo_rect = TextureRect.new()
	logo_rect.name = "LogoRect"
	logo_rect.anchor_left = 0.5
	logo_rect.anchor_right = 0.5
	logo_rect.anchor_top = 0.5
	logo_rect.anchor_bottom = 0.5
	logo_rect.offset_left = -140.0
	logo_rect.offset_right = 140.0
	logo_rect.offset_top = -46.0
	logo_rect.offset_bottom = 46.0
	logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	logo_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo_rect.texture = _load_logs_production_texture()
	logo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logs_page.add_child(logo_rect)

	# Card 2: "GROUP 2 / PRESENTS" card (~1.5x larger text, raised PRESENTS contrast, centered on black)
	group2_page = Control.new()
	group2_page.name = "Group2Page"
	group2_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	group2_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group2_page.visible = false
	splash_layer.add_child(group2_page)

	var g2_box = VBoxContainer.new()
	g2_box.name = "Group2Box"
	g2_box.anchor_left = 0.5
	g2_box.anchor_right = 0.5
	g2_box.anchor_top = 0.5
	g2_box.anchor_bottom = 0.5
	g2_box.offset_left = -220.0
	g2_box.offset_right = 220.0
	g2_box.offset_top = -40.0
	g2_box.offset_bottom = 40.0
	g2_box.alignment = BoxContainer.ALIGNMENT_CENTER
	g2_box.add_theme_constant_override("separation", C.SPACING_MD)
	g2_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group2_page.add_child(g2_box)

	var g2_title = Label.new()
	g2_title.name = "Group2Title"
	g2_title.theme_type_variation = &"SplashTitleLabel"
	g2_title.text = "GROUP 2"
	g2_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	g2_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g2_box.add_child(g2_title)

	var g2_sub = Label.new()
	g2_sub.name = "Group2Sub"
	g2_sub.theme_type_variation = &"SplashSubLabel"
	g2_sub.text = "PRESENTS"
	g2_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	g2_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g2_box.add_child(g2_sub)


func _load_logs_production_texture() -> Texture2D:
	if ResourceLoader.exists(C.TEX_LOGS_PIXEL):
		var res_px = load(C.TEX_LOGS_PIXEL)
		if res_px is Texture2D:
			return res_px
	if ResourceLoader.exists(AssetsScript.PATH_LOGS_PRODUCTION_DARK):
		var res = load(AssetsScript.PATH_LOGS_PRODUCTION_DARK)
		if res is Texture2D:
			return res
	var global_path: String = ProjectSettings.globalize_path(AssetsScript.PATH_LOGS_PRODUCTION_DARK)
	if FileAccess.file_exists(global_path):
		var img = Image.new()
		if img.load(global_path) == OK:
			return ImageTexture.create_from_image(img)
	return null


func _start_splash_sequence() -> void:
	current_splash_stage = 1
	splash_skip_presses = 0
	if is_instance_valid(bg_root):
		bg_root.visible = false
	# Stage 1: Studio logo (Log's Production) first
	logs_page.visible = true
	logs_page.modulate.a = 1.0
	group2_page.visible = false
	group2_page.modulate.a = 1.0

	if is_instance_valid(sfx_ui_player):
		sfx_ui_player.stream = ProceduralAudio.get_splash_chime()
		sfx_ui_player.volume_db = -4.0
		sfx_ui_player.play()

	if splash_tween and splash_tween.is_valid():
		splash_tween.kill()

	_play_dissolve_reveal(func():
		if not is_in_splash or current_splash_stage != 1:
			return
		splash_tween = create_tween()
		splash_tween.tween_interval(C.SPLASH_CARD_DURATION_SEC)
		splash_tween.tween_callback(func(): _advance_splash_stage(false))
	)


func _advance_splash_stage(is_skip: bool = false) -> void:
	if splash_tween and splash_tween.is_valid():
		splash_tween.kill()

	var step_sec: float = 0.035 if is_skip else C.DISSOLVE_STEP_SEC

	if current_splash_stage == 1:
		current_splash_stage = 2
		var mid_cb := func() -> void:
			logs_page.visible = false
			group2_page.visible = true
			group2_page.modulate.a = 1.0
		var done_cb := func() -> void:
			if not is_in_splash or current_splash_stage != 2:
				return
			splash_tween = create_tween()
			splash_tween.tween_interval(C.SPLASH_CARD_DURATION_SEC)
			splash_tween.tween_callback(func(): _advance_splash_stage(false))
		splash_tween = _play_dissolve_transition(mid_cb, done_cb, step_sec)
	elif current_splash_stage == 2:
		current_splash_stage = 3
		is_in_splash = false
		splash_tween = _play_dissolve_transition(_prepare_loading_scene_state, _begin_loading_progress, step_sec)


func _skip_splash() -> void:
	if not is_in_splash:
		return
	splash_skip_presses += 1
	if splash_skip_presses == 1:
		# First press skips the current card (Card 1 -> Card 2, or Card 2 -> Moon Phase Loader)
		_advance_splash_stage(true)
	else:
		# Second press skips the rest of the intro directly into the Title Screen
		is_in_splash = false
		has_shown_splash = true
		if splash_tween and splash_tween.is_valid():
			splash_tween.kill()
		var skip_mid_cb := func() -> void:
			if is_instance_valid(splash_layer):
				splash_layer.visible = false
			_enter_title_screen_state()
		_play_dissolve_transition(skip_mid_cb, Callable(), 0.03)


func setup_comic_story_viewer() -> void:
	comic_story_viewer = ComicStoryViewerScript.new()
	comic_story_viewer.name = "ComicStoryViewer"
	add_child(comic_story_viewer)
	comic_story_viewer.story_completed.connect(_on_story_completed)


func setup_loading_ui() -> void:
	_moon_tex_lit.clear()
	_moon_tex_unlit.clear()
	for i in range(8):
		_moon_tex_lit.append(load(C.get_moon_phase_texture_path(i, true)))
		_moon_tex_unlit.append(load(C.get_moon_phase_texture_path(i, false)))

	loading_container = Control.new()
	loading_container.name = "LoadingContainer"
	loading_container.anchor_left = 0.5
	loading_container.anchor_right = 0.5
	loading_container.anchor_top = 1.0
	loading_container.anchor_bottom = 1.0
	loading_container.offset_left = -180.0
	loading_container.offset_right = 180.0
	loading_container.offset_top = -82.0
	loading_container.offset_bottom = -12.0
	loading_container.visible = false
	loading_container.modulate.a = 1.0
	step3_container.add_child(loading_container)

	# Status copy above the Moon Phase loader (bone cream at ~85% opacity, 10px)
	loading_status_label = Label.new()
	loading_status_label.name = "LoadingStatusLabel"
	loading_status_label.theme_type_variation = &"LoadingStatusLabel"
	loading_status_label.text = "Awakening the seven moons..."
	loading_status_label.position = Vector2(0, 0)
	loading_status_label.size = Vector2(360, 16)
	loading_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_container.add_child(loading_status_label)

	# Row of 8 pixel moons centered horizontally (8 * 18px + 7 * 8px = 200px wide -> x = 80..280)
	moon_phases_hbox = HBoxContainer.new()
	moon_phases_hbox.name = "MoonPhasesHBox"
	moon_phases_hbox.position = Vector2(80, 22)
	moon_phases_hbox.size = Vector2(200, 18)
	moon_phases_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	moon_phases_hbox.add_theme_constant_override("separation", 8)
	loading_container.add_child(moon_phases_hbox)

	moon_phase_icons.clear()
	for i in range(8):
		var m_rect := TextureRect.new()
		m_rect.name = "MoonPhase_%d" % i
		m_rect.custom_minimum_size = Vector2(18, 18)
		m_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		m_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		m_rect.texture = _moon_tex_unlit[i]
		moon_phases_hbox.add_child(m_rect)
		moon_phase_icons.append(m_rect)

	# Small high-contrast percentage text placed outside/below the Moon Phase loader
	loading_pct_label = Label.new()
	loading_pct_label.name = "LoadingPctLabel"
	loading_pct_label.theme_type_variation = &"LoadingPctLabel"
	loading_pct_label.text = "0%"
	loading_pct_label.position = Vector2(0, 46)
	loading_pct_label.size = Vector2(360, 16)
	loading_pct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_pct_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_container.add_child(loading_pct_label)

	# Hidden compatibility node for any legacy scripts checking loading_fill_bar
	loading_fill_bar = Control.new()
	loading_fill_bar.name = "LoadingFillBar"
	loading_fill_bar.visible = false
	loading_container.add_child(loading_fill_bar)


func _set_loading_progress(val: float) -> void:
	var clamped: float = clampf(val, 0.0, 1.0)
	if is_instance_valid(loading_fill_bar):
		loading_fill_bar.size.x = 336.0 * clamped
	if is_instance_valid(loading_pct_label):
		loading_pct_label.text = "%d%%" % int(round(clamped * 100.0))
	if is_instance_valid(loading_status_label):
		if clamped < 0.28:
			loading_status_label.text = "Awakening the seven moons..."
		elif clamped < 0.60:
			loading_status_label.text = "Loading ancient assets..."
		elif clamped < 0.88:
			loading_status_label.text = "Tuning kulintang harmonics..."
		else:
			loading_status_label.text = "Preparing eclipse chronicles..."

	var lit_count: int = int(floor(clamped * 8.0 + 0.001))
	for i in range(moon_phase_icons.size()):
		var icon: TextureRect = moon_phase_icons[i]
		if is_instance_valid(icon):
			icon.texture = _moon_tex_lit[i] if i < lit_count else _moon_tex_unlit[i]


func _prepare_loading_scene_state() -> void:
	is_in_splash = false
	has_shown_splash = true
	is_loading_assets = false
	_loading_transitioned = false
	_loading_elapsed = 0.0
	is_in_press_start = false

	if is_instance_valid(bg_root):
		bg_root.visible = true

	if is_instance_valid(splash_layer):
		splash_layer.visible = false
	if is_instance_valid(step3_container):
		step3_container.visible = true
		step3_container.modulate = Color(1, 1, 1, 1)
	if is_instance_valid(step3_press_start_label):
		step3_press_start_label.visible = false
		step3_press_start_label.modulate.a = 0.0
	if is_instance_valid(loading_container):
		loading_container.visible = true
		loading_container.modulate.a = 1.0
	_set_loading_progress(0.0)

	if is_instance_valid(left_gradient_rect):
		left_gradient_rect.visible = false
	if is_instance_valid(title_container):
		title_container.visible = true
		title_container.modulate.a = 1.0
		title_container.position = TITLE_CENTER_POS
		title_container.set_centered_layout(true)
	if is_instance_valid(menu_vbox):
		menu_vbox.visible = false
	if is_instance_valid(ver_label):
		ver_label.visible = false
	if is_instance_valid(totem_surround):
		totem_surround.visible = false
	if is_instance_valid(mist_container):
		mist_container.visible = false
	if is_instance_valid(foreground_foliage):
		foreground_foliage.visible = false
	if is_instance_valid(lower_fireflies):
		lower_fireflies.emitting = false
		lower_fireflies.visible = false
	if is_instance_valid(drifting_leaves):
		drifting_leaves.emitting = false
		drifting_leaves.visible = false
	var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else get_node_or_null("AltarMotes")
	if is_instance_valid(motes):
		motes.emitting = false
		motes.visible = false


func _begin_loading_progress() -> void:
	if is_instance_valid(fade_rect):
		fade_rect.color.a = 0.0
	if is_instance_valid(dissolve_rect):
		dissolve_rect.visible = false
	for path in _loading_target_paths:
		if ResourceLoader.exists(path):
			ResourceLoader.load_threaded_request(path)
	_loading_elapsed = 0.0
	_loading_transitioned = false
	is_loading_assets = true

	if is_instance_valid(bgm_player):
		var bgm_tw = create_tween()
		bgm_tw.tween_property(bgm_player, "volume_db", -8.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _start_loading_sequence() -> void:
	if splash_tween and splash_tween.is_valid():
		splash_tween.kill()
	_prepare_loading_scene_state()
	_begin_loading_progress()


func _update_threaded_loading(delta: float) -> void:
	_loading_elapsed += delta

	var total_real: float = 0.0
	var count: int = _loading_target_paths.size()
	for path in _loading_target_paths:
		var p_arr: Array = []
		var st := ResourceLoader.load_threaded_get_status(path, p_arr)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			total_real += 1.0
		elif st == ResourceLoader.THREAD_LOAD_IN_PROGRESS and not p_arr.is_empty():
			total_real += float(p_arr[0])
		else:
			total_real += 1.0
	var real_ratio: float = total_real / float(max(1, count))
	var raw_time_ratio: float = clampf(_loading_elapsed / C.LOADING_MIN_HOLD_SEC, 0.0, 1.0)
	var smooth_time_ratio: float = smoothstep(0.0, 1.0, raw_time_ratio)
	var combined_progress: float = minf(real_ratio, smooth_time_ratio)
	if _loading_elapsed >= C.LOADING_MAX_HOLD_SEC:
		combined_progress = 1.0

	_set_loading_progress(combined_progress)

	if combined_progress >= 1.0 and not _loading_transitioned:
		_loading_transitioned = true
		is_loading_assets = false
		if loading_tween and loading_tween.is_valid():
			loading_tween.kill()
		loading_tween = create_tween()
		loading_tween.tween_interval(C.LOADING_COMPLETE_HOLD_SEC)
		loading_tween.tween_callback(_morph_loading_to_press_start)


func _enter_title_screen_state() -> void:
	is_in_splash = false
	is_loading_assets = false
	_loading_transitioned = true
	if is_instance_valid(step3_container):
		step3_container.visible = true
		step3_container.modulate = Color(1, 1, 1, 1)
	if is_instance_valid(loading_container):
		loading_container.visible = false
	if is_instance_valid(title_container):
		title_container.visible = true
		title_container.modulate.a = 1.0
		title_container.position = TITLE_CENTER_POS
		title_container.set_centered_layout(true)
	if is_instance_valid(step3_press_start_label):
		step3_press_start_label.visible = true
		is_in_press_start = true
		_start_press_start_breathing()


func _morph_loading_to_press_start() -> void:
	# Transition out of loading with the same stepped Bayer dithered pixel dissolve
	_play_dissolve_transition(_enter_title_screen_state, Callable(), C.DISSOLVE_STEP_SEC)


func _start_press_start_breathing() -> void:
	if press_start_tween and press_start_tween.is_valid():
		press_start_tween.kill()
	if not is_instance_valid(step3_press_start_label):
		return
	# 4-step pixel pulse instead of a smooth sine fade
	step3_press_start_label.modulate.a = 1.0
	press_start_tween = create_tween().set_loops()
	for a_step in [1.0, 0.78, 0.52, 0.78]:
		var alpha_val: float = a_step
		press_start_tween.tween_callback(func():
			if is_instance_valid(step3_press_start_label):
				step3_press_start_label.modulate.a = alpha_val
		)
		press_start_tween.tween_interval(0.28)


func _on_press_start_triggered() -> void:
	if not is_in_press_start or is_transitioning:
		return
	is_in_press_start = false

	if is_instance_valid(sfx_ui_player):
		sfx_ui_player.stream = ProceduralAudio.get_title_start_chime()
		sfx_ui_player.volume_db = -3.0
		sfx_ui_player.play()

	if press_start_tween and press_start_tween.is_valid():
		press_start_tween.kill()

	if is_instance_valid(step3_container):
		step3_container.visible = false

	# Continuous reveal:
	# 1. Reusable HaliyaTitleLockup glides in discrete pixel steps from center-screen to top-left (26, 48)
	title_container.visible = true
	title_container.set_centered_layout(false)
	var start_pos: Vector2 = title_container.position
	var target_pos: Vector2 = Vector2(C.MENU_LEFT_EDGE_X, C.MENU_BLOCK_TOP_Y)
	var glide_steps: int = 8
	var step_dur: float = 0.032
	var tw_glide := create_tween()
	for s_i in range(1, glide_steps + 1):
		var t_val: float = float(s_i) / float(glide_steps)
		var eased_t: float = 1.0 - pow(1.0 - t_val, 2.0)
		var step_pos := Vector2(
			round(lerp(start_pos.x, target_pos.x, eased_t)),
			round(lerp(start_pos.y, target_pos.y, eased_t))
		)
		tw_glide.tween_callback(func():
			if is_instance_valid(title_container):
				title_container.position = step_pos
		)
		tw_glide.tween_interval(step_dur)

	# 2. Left dither gradient + version label reveal in stepped increments
	left_gradient_rect.visible = true
	left_gradient_rect.modulate.a = 0.5
	ver_label.visible = true
	ver_label.modulate.a = 0.5

	# 3. Totem rises and fades in on the right in discrete pixel steps
	if is_instance_valid(totem_surround):
		totem_surround.visible = true
		totem_surround.modulate.a = 0.0
		var totem_end_pos: Vector2 = base_altar_pos
		var totem_start_pos: Vector2 = base_altar_pos + Vector2(0.0, 14.0)
		totem_surround.position = totem_start_pos
		var tw_totem := create_tween()
		for s_i in range(1, 5):
			var frac: float = float(s_i) / 4.0
			var p_y: float = round(lerp(totem_start_pos.y, totem_end_pos.y, frac))
			tw_totem.tween_callback(func():
				if is_instance_valid(totem_surround):
					totem_surround.modulate.a = frac
					totem_surround.position.y = p_y
			)
			tw_totem.tween_interval(0.06)
	if is_instance_valid(foreground_foliage):
		foreground_foliage.visible = true
		foreground_foliage.modulate.a = 1.0
	if is_instance_valid(lower_fireflies):
		lower_fireflies.emitting = true
		lower_fireflies.visible = true
	if is_instance_valid(drifting_leaves):
		drifting_leaves.emitting = true
		drifting_leaves.visible = true

	var motes = bg_root.get_node_or_null("AltarMotes") if is_instance_valid(bg_root) else get_node_or_null("AltarMotes")
	if is_instance_valid(motes):
		motes.visible = true
		motes.emitting = true

	# 4. Menu items fade in staggered 80ms apart
	menu_vbox.visible = true
	_play_staggered_menu_entrance()
	var tw_settle := create_tween()
	tw_settle.tween_interval(0.16)
	tw_settle.tween_callback(func():
		if is_instance_valid(left_gradient_rect):
			left_gradient_rect.modulate.a = 1.0
		if is_instance_valid(ver_label):
			ver_label.modulate.a = 1.0
	)
	if not menu_buttons.is_empty():
		menu_buttons[0].call_deferred("grab_item_focus")


func _input(event: InputEvent) -> void:
	if is_in_splash:
		if (event is InputEventKey and event.pressed and not event.echo) or \
		   (event is InputEventMouseButton and event.pressed):
			_skip_splash()
			get_viewport().set_input_as_handled()
			return

	if is_in_press_start:
		if (event is InputEventKey and event.pressed and not event.echo) or \
		   (event is InputEventMouseButton and event.pressed):
			_on_press_start_triggered()
			get_viewport().set_input_as_handled()
			return


func setup_settings_and_codex_modals() -> void:
	# Lightweight stubs for compatibility with external references without heavy node trees
	settings_menu = CanvasLayer.new()
	settings_menu.name = "SettingsMenu"
	settings_menu.visible = false
	add_child(settings_menu)

	bestiary_codex_ui = CanvasLayer.new()
	bestiary_codex_ui.name = "BestiaryCodexUI"
	bestiary_codex_ui.visible = false
	add_child(bestiary_codex_ui)

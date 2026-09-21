extends Control

const AssetsScript = preload("res://scripts/assets.gd")
const MainScript = preload("res://scripts/main.gd")
const FONT_ALAGARD = preload("res://alagard.ttf")

# Parallax background nodes
var bg_root: Node2D
var bg_layers: Array[Dictionary] = []

# UI Components
var menu_vbox: VBoxContainer
var title_container: Control
var title_label: Label
var subtitle_label: Label

# Modals
var stage_select_modal: Control
var controls_modal: Control
var fade_rect: ColorRect

var is_transitioning: bool = false
var bgm_player: AudioStreamPlayer


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	RenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
	setup_background()
	setup_ambient_particles()
	setup_ui()
	setup_stage_select_modal()
	setup_controls_modal()
	setup_fade_overlay()
	setup_bgm()

	# Initial fade in from black
	fade_rect.color = Color(0, 0, 0, 1.0)
	var tw = create_tween()
	tw.tween_property(fade_rect, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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

	var s: float = max(0.5, target_h / 720.0)
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

	var ground_fill = bg_root.get_node_or_null("GroundFill")
	if is_instance_valid(ground_fill):
		ground_fill.position = Vector2(0, target_h - 8.0)
		ground_fill.size = Vector2(target_w * 2.5, 400.0)


func _process(delta: float) -> void:
	# Subtle continuous parallax scrolling
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


func setup_background() -> void:
	# 0. Solid dark night sky underlay that covers the full viewport (prevents any seams)
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

	# 1. Sky Layer (Deep indigo twilight)
	var sky_tex = load(AssetsScript.PATH_BG_LAYER_5)
	if sky_tex:
		var sky_spr = Sprite2D.new()
		sky_spr.name = "SkySprite"
		sky_spr.texture = sky_tex
		sky_spr.centered = false
		var sky_scale = max(target_w / sky_tex.get_width(), target_h / sky_tex.get_height()) * 1.05
		sky_spr.scale = Vector2(sky_scale, sky_scale)
		sky_spr.modulate = Color(0.65, 0.70, 0.85, 1.0)
		bg_root.add_child(sky_spr)

	# 2. Layered Forest Silhouettes
	# Bicol_Forest_Layer textures are 4256x720.
	# Scale factor s ensures trees fill from top to target_h, seamlessly grounding at any aspect ratio.
	var s: float = max(0.5, target_h / 720.0)
	var forest_configs = [
		{"path": AssetsScript.PATH_BG_LAYER_4, "speed": 4.0, "scale": Vector2(s, s), "mod": Color(0.40, 0.45, 0.60, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_3, "speed": 8.0, "scale": Vector2(s, s), "mod": Color(0.48, 0.52, 0.66, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_2, "speed": 14.0, "scale": Vector2(s, s), "mod": Color(0.55, 0.60, 0.72, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_1, "speed": 22.0, "scale": Vector2(s, s), "mod": Color(0.62, 0.66, 0.76, 1.0)}
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

	# 3. Seamless Forest Ground Silhouette Extension (safety fill below trees for ultra-tall viewports)
	var ground_fill = ColorRect.new()
	ground_fill.name = "GroundFill"
	ground_fill.color = Color(0.015, 0.022, 0.025, 1.0)
	ground_fill.position = Vector2(0, target_h - 8.0)
	ground_fill.size = Vector2(target_w * 2.5, 400.0)
	ground_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_root.add_child(ground_fill)

	# 4. Atmospheric Dark Vignette Overlay
	var vignette = ColorRect.new()
	vignette.name = "VignetteOverlay"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.02, 0.03, 0.06, 0.42)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)


func setup_ambient_particles() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = max(640.0, vp_size.x)
	var target_h: float = max(360.0, vp_size.y)

	var particles = CPUParticles2D.new()
	particles.name = "AmbientMotes"
	particles.position = Vector2(target_w * 0.5, target_h * 0.5)
	particles.amount = 40
	particles.lifetime = 5.0
	particles.preprocess = 3.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(target_w * 0.5, target_h * 0.5)
	particles.direction = Vector2(-0.8, -0.4)
	particles.spread = 45.0
	particles.gravity = Vector2(-4, -6)
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 24.0
	particles.scale_amount_min = 1.2
	particles.scale_amount_max = 2.4
	particles.color = Color(0.95, 0.88, 0.62, 0.45)
	add_child(particles)


func setup_ui() -> void:
	# ── Title Container (Upper Center) ───────────────────────────────────────
	title_container = Control.new()
	title_container.name = "TitleContainer"
	title_container.anchor_left = 0.5
	title_container.anchor_right = 0.5
	title_container.offset_left = -320.0
	title_container.offset_right = 320.0
	title_container.offset_top = 42.0
	title_container.offset_bottom = 122.0
	title_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_container)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.position = Vector2(0, -8)
	title_label.size = Vector2(640, 62)
	title_label.text = "H A L I Y A"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_override("font", FONT_ALAGARD)
	title_label.add_theme_font_size_override("font_size", 58)
	title_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.84, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	title_container.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.position = Vector2(0, 50)
	subtitle_label.size = Vector2(640, 24)
	subtitle_label.text = "Mask of Sorrows"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_override("font", FONT_ALAGARD)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.65, 0.92))
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 2)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 2)
	title_container.add_child(subtitle_label)

	# Gentle breathing animation on title
	var tw = create_tween().set_loops()
	tw.tween_property(title_label, "modulate", Color(1.08, 1.05, 0.95, 1.0), 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(title_label, "modulate", Color(0.92, 0.90, 0.85, 1.0), 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# ── Main Menu Buttons (Centered List) ────────────────────────────────────
	menu_vbox = VBoxContainer.new()
	menu_vbox.name = "MenuVBox"
	menu_vbox.anchor_left = 0.5
	menu_vbox.anchor_right = 0.5
	menu_vbox.offset_left = -90.0
	menu_vbox.offset_right = 90.0
	menu_vbox.offset_top = 140.0
	menu_vbox.offset_bottom = 300.0
	menu_vbox.add_theme_constant_override("separation", 10)
	add_child(menu_vbox)

	var btn_play = create_menu_button("BEGIN JOURNEY")
	btn_play.pressed.connect(_on_begin_journey_pressed)
	menu_vbox.add_child(btn_play)

	var btn_stages = create_menu_button("STAGE SELECT")
	btn_stages.pressed.connect(_on_stage_select_pressed)
	menu_vbox.add_child(btn_stages)

	var btn_controls = create_menu_button("CONTROLS")
	btn_controls.pressed.connect(_on_controls_pressed)
	menu_vbox.add_child(btn_controls)

	var btn_quit = create_menu_button("QUIT")
	btn_quit.pressed.connect(_on_quit_pressed)
	menu_vbox.add_child(btn_quit)

	# Version footer (anchored to bottom-left)
	var ver_label = Label.new()
	ver_label.name = "VersionLabel"
	ver_label.anchor_top = 1.0
	ver_label.anchor_bottom = 1.0
	ver_label.anchor_left = 0.0
	ver_label.anchor_right = 0.0
	ver_label.offset_left = 12.0
	ver_label.offset_right = 260.0
	ver_label.offset_top = -24.0
	ver_label.offset_bottom = -6.0
	ver_label.text = "v1.0.0 • Dark Fantasy Edition"
	ver_label.add_theme_font_override("font", FONT_ALAGARD)
	ver_label.add_theme_font_size_override("font_size", 11)
	ver_label.add_theme_color_override("font_color", Color(0.55, 0.52, 0.48, 0.7))
	add_child(ver_label)



func create_menu_button(label_text: String) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(180, 28)
	btn.focus_mode = Control.FOCUS_ALL
	btn.add_theme_font_override("font", FONT_ALAGARD)
	btn.add_theme_font_size_override("font_size", 16)

	# Clean flat dark fantasy button styles
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.08, 0.10, 0.14, 0.70)
	normal_sb.border_color = Color(0.42, 0.38, 0.30, 0.75)
	normal_sb.border_width_bottom = 1
	normal_sb.border_width_top = 1
	normal_sb.border_width_left = 1
	normal_sb.border_width_right = 1
	normal_sb.content_margin_left = 10
	normal_sb.content_margin_right = 10

	var hover_sb = StyleBoxFlat.new()
	hover_sb.bg_color = Color(0.16, 0.18, 0.24, 0.90)
	hover_sb.border_color = Color(0.92, 0.80, 0.45, 1.0)
	hover_sb.border_width_bottom = 2
	hover_sb.border_width_top = 1
	hover_sb.border_width_left = 2
	hover_sb.border_width_right = 1
	hover_sb.content_margin_left = 14
	hover_sb.content_margin_right = 10

	var pressed_sb = StyleBoxFlat.new()
	pressed_sb.bg_color = Color(0.24, 0.20, 0.14, 0.95)
	pressed_sb.border_color = Color(1.0, 0.88, 0.50, 1.0)
	pressed_sb.border_width_bottom = 1
	pressed_sb.border_width_top = 2
	pressed_sb.border_width_left = 1
	pressed_sb.border_width_right = 1

	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("focus", hover_sb)

	btn.add_theme_color_override("font_color", Color(0.90, 0.86, 0.78, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.45, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.80, 1.0))
	btn.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	btn.add_theme_constant_override("shadow_offset_x", 1)
	btn.add_theme_constant_override("shadow_offset_y", 1)

	return btn


func setup_stage_select_modal() -> void:
	stage_select_modal = Control.new()
	stage_select_modal.name = "StageSelectModal"
	stage_select_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_select_modal.visible = false
	add_child(stage_select_modal)

	var bg_dim = ColorRect.new()
	bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_dim.color = Color(0, 0, 0, 0.78)
	stage_select_modal.add_child(bg_dim)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -180.0
	panel.offset_right = 180.0
	panel.offset_top = -132.0
	panel.offset_bottom = 132.0
	panel.size = Vector2(360, 264)
	var panel_sb = StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	panel_sb.border_color = Color(0.72, 0.62, 0.40, 1.0)
	panel_sb.border_width_left = 2
	panel_sb.border_width_right = 2
	panel_sb.border_width_top = 2
	panel_sb.border_width_bottom = 2
	panel_sb.content_margin_left = 18
	panel_sb.content_margin_right = 18
	panel_sb.content_margin_top = 16
	panel_sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", panel_sb)
	stage_select_modal.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "SELECT CHAPTER"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_override("font", FONT_ALAGARD)
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
	header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	header.add_theme_constant_override("shadow_offset_x", 1)
	header.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(header)

	var stages = [
		{"name": "Stage I: Whispering Forest", "desc": "Levels 1-1 to 1-3  •  The Balete Canopy", "idx": 0},
		{"name": "Stage II: Emerald Terraces", "desc": "Levels 2-1 to 2-3  •  The Mayon Crossing", "idx": 3},
		{"name": "Stage III: Rainy Forest", "desc": "Levels 3-1 to 3-5  •  Storm & Tempest", "idx": 6}
	]

	for st in stages:
		var btn = create_stage_card_button(st["name"], st["desc"])
		var target_idx = st["idx"]
		btn.pressed.connect(func(): _start_game_at_level(target_idx))
		vbox.add_child(btn)

	var btn_back = create_menu_button("RETURN")
	btn_back.custom_minimum_size = Vector2(160, 24)
	btn_back.pressed.connect(func(): stage_select_modal.visible = false)
	vbox.add_child(btn_back)


func create_stage_card_button(title: String, subtitle: String) -> Button:
	var btn = Button.new()
	btn.text = "%s\n%s" % [title, subtitle]
	btn.custom_minimum_size = Vector2(320, 42)
	btn.add_theme_font_override("font", FONT_ALAGARD)
	btn.add_theme_font_size_override("font_size", 14)

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.14, 0.18, 0.85)
	sb.border_color = Color(0.45, 0.40, 0.32, 0.8)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4

	var sb_hover = StyleBoxFlat.new()
	sb_hover.bg_color = Color(0.20, 0.22, 0.28, 0.95)
	sb_hover.border_color = Color(0.96, 0.85, 0.45, 1.0)
	sb_hover.border_width_left = 2
	sb_hover.border_width_right = 1
	sb_hover.border_width_top = 1
	sb_hover.border_width_bottom = 2
	sb_hover.content_margin_top = 4
	sb_hover.content_margin_bottom = 4

	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("focus", sb_hover)
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.45, 1.0))
	return btn


func setup_controls_modal() -> void:
	controls_modal = Control.new()
	controls_modal.name = "ControlsModal"
	controls_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	controls_modal.visible = false
	add_child(controls_modal)

	var bg_dim = ColorRect.new()
	bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_dim.color = Color(0, 0, 0, 0.78)
	controls_modal.add_child(bg_dim)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -190.0
	panel.offset_right = 190.0
	panel.offset_top = -140.0
	panel.offset_bottom = 140.0
	panel.size = Vector2(380, 280)
	var panel_sb = StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	panel_sb.border_color = Color(0.72, 0.62, 0.40, 1.0)
	panel_sb.border_width_left = 2
	panel_sb.border_width_right = 2
	panel_sb.border_width_top = 2
	panel_sb.border_width_bottom = 2
	panel_sb.content_margin_left = 20
	panel_sb.content_margin_right = 20
	panel_sb.content_margin_top = 14
	panel_sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", panel_sb)
	controls_modal.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "HOW TO PLAY"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_override("font", FONT_ALAGARD)
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
	header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	header.add_theme_constant_override("shadow_offset_x", 1)
	header.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(header)

	var bindings = [
		{"action": "Move Left / Right", "keys": "A / D  or  Arrow Keys"},
		{"action": "Jump", "keys": "Space  or  W"},
		{"action": "Attack", "keys": "J  or  Left Click"},
		{"action": "Parry / Block", "keys": "K  or  Right Click"},
		{"action": "Dodge / Roll", "keys": "Shift / Alt / C"},
		{"action": "Stage Shortcuts", "keys": "1, 2, 3 on keyboard"},
		{"action": "Toggle HUD", "keys": "H"},
		{"action": "Pause Menu", "keys": "ESC"}
	]

	for b in bindings:
		var row = HBoxContainer.new()
		var lbl_act = Label.new()
		lbl_act.text = b["action"]
		lbl_act.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_act.add_theme_font_override("font", FONT_ALAGARD)
		lbl_act.add_theme_font_size_override("font_size", 13)
		lbl_act.add_theme_color_override("font_color", Color(0.85, 0.80, 0.72, 1.0))

		var lbl_keys = Label.new()
		lbl_keys.text = b["keys"]
		lbl_keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_keys.add_theme_font_override("font", FONT_ALAGARD)
		lbl_keys.add_theme_font_size_override("font_size", 13)
		lbl_keys.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))

		row.add_child(lbl_act)
		row.add_child(lbl_keys)
		vbox.add_child(row)

	var sep = Control.new()
	sep.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(sep)

	var btn_back = create_menu_button("RETURN")
	btn_back.custom_minimum_size = Vector2(160, 24)
	btn_back.pressed.connect(func(): controls_modal.visible = false)
	vbox.add_child(btn_back)


func setup_bgm() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "MenuBGMPlayer"
	bgm_player.bus = "Master"
	bgm_player.stream = ProceduralAudio.get_menu_ambient()
	bgm_player.volume_db = -80.0
	add_child(bgm_player)
	bgm_player.play()

	var tw = create_tween()
	tw.tween_property(bgm_player, "volume_db", -8.0, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func setup_fade_overlay() -> void:
	fade_rect = ColorRect.new()
	fade_rect.name = "FadeOverlay"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_rect)



func _on_begin_journey_pressed() -> void:
	_start_game_at_level(0)


func _on_stage_select_pressed() -> void:
	if is_transitioning:
		return
	stage_select_modal.visible = true


func _on_controls_pressed() -> void:
	if is_transitioning:
		return
	controls_modal.visible = true


func _on_quit_pressed() -> void:
	if is_transitioning:
		return
	get_tree().quit()


func _start_game_at_level(lvl_idx: int) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade out BGM audio smoothly
	if is_instance_valid(bgm_player):
		var tw_bgm = create_tween()
		tw_bgm.tween_property(bgm_player, "volume_db", -40.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Fade out to black over 0.45s and change scene
	var tw = create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		MainScript.start_level_idx = lvl_idx
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if stage_select_modal.visible:
				stage_select_modal.visible = false
			elif controls_modal.visible:
				controls_modal.visible = false

class_name TutorialStage
extends Node2D

const AssetsScript = preload("res://scripts/assets.gd")
const PlayerScript = preload("res://scripts/player.gd")
const DialogueManagerScript = preload("res://scripts/dialogue_manager.gd")
const KapreNPCScript = preload("res://scripts/kapre_npc.gd")
const WeaponRackScript = preload("res://scripts/weapon_rack.gd")
const MaskAltarScript = preload("res://scripts/mask_altar.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const TrainingDummyScript = preload("res://scripts/training_dummy.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")
const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")

const FONT_ALAGARD = preload("res://alagard.ttf")

const LEVEL_WIDTH: float = 2600.0
const PLAYER_SPAWN_POS: Vector2 = Vector2(160, 255)
const GATEWAY_POS_X: float = 2480.0

# ── Tutorial Milestones ────────────────────────────────────────────────────────
enum TutorialStep {
	MOVE_AND_SPRINT,
	JUMP_AND_CROUCH,
	SELECT_WEAPON,
	ATTACK_COMBOS,
	SMASH_POTS,
	DODGE_ROLL,
	GUARD_AND_PARRY,
	RIPOSTE_STRIKE,
	TALK_TO_KAPRE,
	CLAIM_MASK,
	ENTER_GATEWAY,
	COMPLETED
}

var current_step: TutorialStep = TutorialStep.MOVE_AND_SPRINT

# Progress Flags
var flag_moved_left: bool = false
var flag_moved_right: bool = false
var flag_sprinted: bool = false
var flag_jumped: bool = false
var flag_crouched: bool = false
var flag_weapon_chosen: bool = false
var flag_attack_count: int = 0
var flag_pot_smashed: bool = false
var flag_item_picked: bool = false
var flag_dodged: bool = false
var flag_guarded: bool = false
var flag_parried: bool = false
var flag_riposted: bool = false
var flag_kapre_spoken: bool = false
var flag_mask_claimed: bool = false

# Scene Node References
var player: CharacterBody2D
var camera: Camera2D
var dialogue_manager: DialogueManager
var kapre_npc: KapreNPC
var weapon_rack: WeaponRack
var mask_altar: MaskAltar
var training_dummy: TrainingDummy
var exit_barrier: CollisionShape2D
var gateway_particles: CPUParticles2D
var gateway_light: PointLight2D

# UI References
var ui_layer: CanvasLayer
var objective_panel: PanelContainer
var objective_title_label: Label
var objective_desc_label: Label
var objective_progress_label: Label
var hud_container: Control
var hp_bar_root: Control
var hp_fill_clip: Control
var hp_ghost_clip: Control
var hp_shield_clip: Control
var hp_text_label: Label
var _cur_hp_cached: int = 5
var _max_hp_cached: int = 5
var _cur_arm_cached: int = 3
var _max_arm_cached: int = 3
var stamina_bar_root: Control
var stamina_fill_clip: Control
var stamina_text_label: Label
var weapon_badge_label: Label
var controls_ribbon: Label
var banner_label: Label
var banner_timer: float = 0.0
var pause_overlay: Control
var fade_rect: ColorRect
var is_transitioning: bool = false

# Constants for HUD
const HP_FILL_MAX_WIDTH: float = 148.0
const STA_FILL_MAX_WIDTH: float = 118.0
const ARM_FILL_MAX_WIDTH: float = 148.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	setup_parallax_background()
	setup_environment_ground()
	setup_elevated_platform()
	setup_props_and_homestead()
	setup_stations()
	setup_player()
	setup_camera()
	setup_ui()
	setup_pause_menu()
	update_objective_display()
	play_ambient_audio()

	# Initial smooth fade in from black
	fade_rect = ColorRect.new()
	fade_rect.name = "FadeOverlay"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(fade_rect)
	var tw = create_tween()
	tw.tween_property(fade_rect, "color:a", 0.0, 0.5)


func play_ambient_audio() -> void:
	var sfx_wind = AudioStreamPlayer.new()
	sfx_wind.name = "AmbientWind"
	var wind_sound = ProceduralAudioScript.get_forest_ambient()
	if wind_sound:
		sfx_wind.stream = wind_sound
		sfx_wind.volume_db = -12.0
		sfx_wind.autoplay = true
		add_child(sfx_wind)


# ── 1. Parallax Environment ───────────────────────────────────────────────────
func setup_parallax_background() -> void:
	var pb := ParallaxBackground.new()
	pb.name = "ParallaxBackground"
	add_child(pb)

	# 1. Sky Layer
	var sky_layer := ParallaxLayer.new()
	sky_layer.motion_scale = Vector2(0.02, 0.0)
	sky_layer.motion_mirroring = Vector2(1024, 0)
	var sky_spr := Sprite2D.new()
	var sky_tex = load(AssetsScript.PATH_BG_LAYER_5)
	if sky_tex:
		sky_spr.texture = sky_tex
		sky_spr.centered = false
		sky_spr.scale = Vector2(1.01, 1.05)
		sky_spr.modulate = Color(0.85, 0.88, 0.95, 1.0)
		sky_layer.add_child(sky_spr)
	pb.add_child(sky_layer)

	# 2. Forest Silhouettes
	var forest_layers = [
		{"path": AssetsScript.PATH_BG_LAYER_4, "scale": Vector2(0.12, 0.0), "mod": Color(0.55, 0.60, 0.72, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_3, "scale": Vector2(0.28, 0.0), "mod": Color(0.65, 0.70, 0.80, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_2, "scale": Vector2(0.50, 0.0), "mod": Color(0.78, 0.82, 0.88, 1.0)},
		{"path": AssetsScript.PATH_BG_LAYER_1, "scale": Vector2(0.75, 0.0), "mod": Color(0.90, 0.92, 0.95, 1.0)}
	]

	for i in range(forest_layers.size()):
		var f_data = forest_layers[i]
		var layer := ParallaxLayer.new()
		layer.motion_scale = f_data["scale"]
		layer.motion_mirroring = Vector2(2128, 0)
		var spr := Sprite2D.new()
		var tex = load(f_data["path"])
		if tex:
			spr.texture = tex
			spr.centered = false
			spr.scale = Vector2(0.5, 0.5)
			spr.modulate = f_data["mod"]
			layer.add_child(spr)
		pb.add_child(layer)


# ── 2. Environment Ground & Platforms ──────────────────────────────────────────
func setup_environment_ground() -> void:
	var ground_body := StaticBody2D.new()
	ground_body.name = "GroundBody"
	ground_body.collision_layer = 1
	ground_body.collision_mask = 0

	# Floor collision at Y=288
	var floor_col := CollisionShape2D.new()
	var floor_shape := WorldBoundaryShape2D.new()
	floor_shape.normal = Vector2.UP
	floor_col.shape = floor_shape
	floor_col.position = Vector2(0, 288)
	ground_body.add_child(floor_col)

	# Left boundary wall at X=20
	var left_col := CollisionShape2D.new()
	var left_shape := WorldBoundaryShape2D.new()
	left_shape.normal = Vector2.RIGHT
	left_col.shape = left_shape
	left_col.position = Vector2(20, 0)
	ground_body.add_child(left_col)

	# Right exit gate boundary at X=GATEWAY_POS_X + 40
	var right_col := CollisionShape2D.new()
	var right_shape := WorldBoundaryShape2D.new()
	right_shape.normal = Vector2.LEFT
	right_col.shape = right_shape
	right_col.position = Vector2(GATEWAY_POS_X + 40, 0)
	ground_body.add_child(right_col)
	exit_barrier = right_col

	add_child(ground_body)

	# Floor Visual Tiles
	var floor_tex = load(AssetsScript.PATH_FLOOR_TILES) as Texture2D
	if floor_tex:
		var ground_visuals := Node2D.new()
		ground_visuals.name = "GroundVisuals"
		ground_visuals.z_index = -1
		for x in range(0, int(LEVEL_WIDTH), 32):
			var spr_top := Sprite2D.new()
			spr_top.texture = floor_tex
			spr_top.region_enabled = true
			spr_top.region_rect = Rect2(0, 0, 32, 32)
			spr_top.position = Vector2(x + 16, 304)
			ground_visuals.add_child(spr_top)

			var spr_sub := Sprite2D.new()
			spr_sub.texture = floor_tex
			spr_sub.region_enabled = true
			spr_sub.region_rect = Rect2(0, 32, 32, 32)
			spr_sub.position = Vector2(x + 16, 336)
			ground_visuals.add_child(spr_sub)
		add_child(ground_visuals)


func setup_elevated_platform() -> void:
	# Elevated wooden platform at X=560..720 (Y=210) for jumping practice
	var plat_body := StaticBody2D.new()
	plat_body.name = "JumpPlatform"
	plat_body.collision_layer = 1
	plat_body.collision_mask = 0

	var plat_col := CollisionShape2D.new()
	var plat_shape := RectangleShape2D.new()
	plat_shape.size = Vector2(170, 16)
	plat_col.shape = plat_shape
	plat_col.position = Vector2(640, 216)
	plat_body.add_child(plat_col)
	add_child(plat_body)

	# Platform visual wooden deck
	var plat_spr := Sprite2D.new()
	plat_spr.name = "PlatVisual"
	plat_spr.texture = load("res://assets/bahay_kubo/tile_deck_platform.png")
	plat_spr.position = Vector2(640, 247)
	plat_spr.z_index = 0
	add_child(plat_spr)

	# Low wooden arch/overhang at X=780..840 (Y=240) to teach crouching
	var crouch_roof := StaticBody2D.new()
	crouch_roof.name = "CrouchBeam"
	crouch_roof.collision_layer = 1
	crouch_roof.collision_mask = 0

	var c_col := CollisionShape2D.new()
	var c_shape := RectangleShape2D.new()
	c_shape.size = Vector2(75, 20)
	c_col.shape = c_shape
	c_col.position = Vector2(810, 248) # Clearance of ~40px above ground: forces crouching!
	crouch_roof.add_child(c_col)
	add_child(crouch_roof)

	var beam_spr := Sprite2D.new()
	beam_spr.texture = load("res://assets/bahay_kubo/prop_crouch_beam.png")
	beam_spr.scale = Vector2(0.60, 0.60)
	beam_spr.position = Vector2(810, 260)
	beam_spr.modulate = Color.WHITE
	add_child(beam_spr)


# ── 3. Props, Homestead, & Stations ───────────────────────────────────────────
func setup_props_and_homestead() -> void:
	var props := Node2D.new()
	props.name = "HomesteadProps"
	add_child(props)

	# 1. Bahay Kubo Stilt House
	var house_tex = load("res://assets/bahay_kubo/bahay_kubo_house.png")
	if house_tex:
		var house := Sprite2D.new()
		house.name = "BahayKuboHouse"
		house.texture = house_tex
		house.scale = Vector2(0.5, 0.5)
		house.position = Vector2(150, 172)
		props.add_child(house)

	# 2. Banana Tree
	var banana_tex = load("res://assets/bahay_kubo/prop_banana_tree.png")
	if banana_tex:
		var b_spr := Sprite2D.new()
		b_spr.texture = banana_tex
		b_spr.scale = Vector2(0.5, 0.5)
		b_spr.position = Vector2(40, 240)
		props.add_child(b_spr)

	# 3. Wooden Yard Fence
	var fence_tex = load("res://assets/bahay_kubo/prop_wooden_fence.png")
	if fence_tex:
		var f_spr := Sprite2D.new()
		f_spr.texture = fence_tex
		f_spr.scale = Vector2(0.5, 0.5)
		f_spr.position = Vector2(280, 268)
		props.add_child(f_spr)

	# 4. Rooster & Sleeping Cat
	var rooster_tex = load("res://assets/bahay_kubo/prop_rooster.png")
	if rooster_tex:
		var r_spr := Sprite2D.new()
		r_spr.texture = rooster_tex
		r_spr.scale = Vector2(0.45, 0.45)
		r_spr.position = Vector2(245, 272)
		props.add_child(r_spr)

	var cat_tex = load("res://assets/bahay_kubo/prop_sleeping_cat.png")
	if cat_tex:
		var c_spr := Sprite2D.new()
		c_spr.texture = cat_tex
		c_spr.scale = Vector2(0.5, 0.5)
		c_spr.position = Vector2(208, 222)
		props.add_child(c_spr)

	# 5. Firewood Pile
	var wood_tex = load("res://assets/bahay_kubo/prop_firewood.png")
	if wood_tex:
		var w_spr := Sprite2D.new()
		w_spr.texture = wood_tex
		w_spr.scale = Vector2(0.5, 0.5)
		w_spr.position = Vector2(110, 273)
		props.add_child(w_spr)

	# 6. Mossy Rocks
	var rock_tex = load("res://assets/bahay_kubo/prop_mossy_rocks.png")
	if rock_tex:
		var rock1 := Sprite2D.new()
		rock1.texture = rock_tex
		rock1.scale = Vector2(0.45, 0.45)
		rock1.position = Vector2(440, 270)
		props.add_child(rock1)

		var rock2 := Sprite2D.new()
		rock2.texture = rock_tex
		rock2.scale = Vector2(0.45, 0.45)
		rock2.position = Vector2(1380, 270)
		rock2.flip_h = true
		props.add_child(rock2)

	# 7. Torches along the way
	for tx in [380, 880, 1420, 1920, 2400]:
		var torch = EnvironmentTorchScript.new()
		torch.position = Vector2(tx, 270)
		add_child(torch)


func setup_stations() -> void:
	# ── Dialogue System ──
	dialogue_manager = DialogueManagerScript.new()
	dialogue_manager.name = "DialogueManager"
	add_child(dialogue_manager)

	# ── Station 3: Weapon Selection Rack (X=930) ──
	weapon_rack = WeaponRackScript.new()
	weapon_rack.name = "WeaponRack"
	weapon_rack.position = Vector2(930, 265)

	var w_col := CollisionShape2D.new()
	var w_shape := CircleShape2D.new()
	w_shape.radius = 40.0
	w_col.shape = w_shape
	weapon_rack.add_child(w_col)

	var rack_tex = load("res://assets/bahay_kubo/weapon_rack.png")
	if rack_tex:
		var w_spr := Sprite2D.new()
		w_spr.texture = rack_tex
		w_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		w_spr.position = Vector2(0, -20)
		weapon_rack.add_child(w_spr)

	weapon_rack.weapon_selected.connect(_on_weapon_selected)
	add_child(weapon_rack)

	# ── Station 4: Breakable Palayok Pots (X=1100, X=1150) ──
	var pot1 = PalayokPotScript.new()
	pot1.position = Vector2(1100, 288)
	pot1.initial_state = PalayokPotScript.PotState.INTACT
	pot1.tree_exiting.connect(func(): _on_pot_broken())
	add_child(pot1)

	var pot2 = PalayokPotScript.new()
	pot2.position = Vector2(1150, 288)
	pot2.initial_state = PalayokPotScript.PotState.INTACT
	pot2.tree_exiting.connect(func(): _on_pot_broken())
	add_child(pot2)

	# ── Station 5: Training Sparring Dummy (X=1680) ──
	training_dummy = TrainingDummyScript.new()
	training_dummy.position = Vector2(1680, 280)
	training_dummy.parried_by_player.connect(_on_dummy_parried)
	training_dummy.riposte_received.connect(_on_dummy_riposted)
	add_child(training_dummy)

	# ── Station 6: Balete Tree & Kapre Elder (X=2050) ──
	var tree_tex = load("res://assets/bahay_kubo/balete_tree.png")
	if tree_tex:
		var balete := Sprite2D.new()
		balete.name = "BaleteTree"
		balete.texture = tree_tex
		balete.position = Vector2(2050, 168)
		add_child(balete)

	kapre_npc = KapreNPCScript.new()
	kapre_npc.name = "KapreNPC"
	kapre_npc.position = Vector2(2050, 265)

	var k_col := CollisionShape2D.new()
	var k_shape := CircleShape2D.new()
	k_shape.radius = 52.0
	k_col.shape = k_shape
	kapre_npc.add_child(k_col)

	var kapre_tex = load("res://assets/bahay_kubo/kapre_sprite.png")
	if kapre_tex:
		var k_spr := Sprite2D.new()
		k_spr.texture = kapre_tex
		k_spr.position = Vector2(0, -35)
		kapre_npc.add_child(k_spr)
	add_child(kapre_npc)

	# Hook into dialogue to detect when Kapre conversation finishes
	if dialogue_manager:
		dialogue_manager.dialogue_finished.connect(_on_dialogue_finished)

	# ── Station 7: Mask Altar (X=2300) ──
	mask_altar = MaskAltarScript.new()
	mask_altar.name = "MaskAltar"
	mask_altar.position = Vector2(2300, 265)

	var a_col := CollisionShape2D.new()
	var a_shape := CircleShape2D.new()
	a_shape.radius = 45.0
	a_col.shape = a_shape
	mask_altar.add_child(a_col)

	var altar_tex = load("res://assets/bahay_kubo/mask_altar.png")
	if altar_tex:
		var a_spr := Sprite2D.new()
		a_spr.texture = altar_tex
		a_spr.position = Vector2(0, -20)
		mask_altar.add_child(a_spr)

	mask_altar.mask_claimed.connect(_on_mask_claimed)
	add_child(mask_altar)

	# ── Station 8: Ancient Torii / Spirit Gateway (X=2460) ──
	setup_spirit_gateway()


func setup_spirit_gateway() -> void:
	var gate_root := Node2D.new()
	gate_root.name = "SpiritGateway"
	gate_root.position = Vector2(GATEWAY_POS_X, 260)
	add_child(gate_root)

	# Gateway Arch Visual (using decorative totems)
	var arch_tex = load("res://assets/bahay_kubo/totem_haliya.png")
	if arch_tex:
		var totem_l := Sprite2D.new()
		totem_l.texture = arch_tex
		totem_l.scale = Vector2(0.40, 0.40)
		totem_l.position = Vector2(-35, -35)
		gate_root.add_child(totem_l)

		var totem_r := Sprite2D.new()
		totem_r.texture = arch_tex
		totem_r.scale = Vector2(0.40, 0.40)
		totem_r.position = Vector2(35, -35)
		totem_r.flip_h = true
		gate_root.add_child(totem_r)

	# Luminous Spirit Particles
	gateway_particles = CPUParticles2D.new()
	gateway_particles.name = "GatewayParticles"
	gateway_particles.emitting = false
	gateway_particles.amount = 28
	gateway_particles.lifetime = 1.6
	gateway_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	gateway_particles.emission_rect_extents = Vector2(30, 60)
	gateway_particles.direction = Vector2(0, -1)
	gateway_particles.spread = 25.0
	gateway_particles.gravity = Vector2(0, -30)
	gateway_particles.initial_velocity_min = 25.0
	gateway_particles.initial_velocity_max = 60.0
	gateway_particles.scale_amount_min = 2.0
	gateway_particles.scale_amount_max = 4.5
	gateway_particles.color = Color(0.35, 0.85, 1.0, 0.75)
	gate_root.add_child(gateway_particles)

	# Gateway PointLight2D
	gateway_light = PointLight2D.new()
	gateway_light.name = "GatewayLight"
	gateway_light.texture = load("res://assets/vfx/radial_light_falloff.png")
	gateway_light.color = Color(0.4, 0.85, 1.0, 1.0)
	gateway_light.energy = 0.0
	gateway_light.texture_scale = 1.2
	gateway_light.position = Vector2(0, -30)
	gate_root.add_child(gateway_light)


# ── 4. Player & Camera ────────────────────────────────────────────────────────
func setup_player() -> void:
	player = PlayerScript.new()
	player.name = "Player"
	player.global_position = PLAYER_SPAWN_POS
	add_child(player)

	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(_on_player_hp_changed)
	player.armor_changed.connect(_on_player_armor_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.hit_landed.connect(_on_player_hit_landed)
	if player.has_signal("riposte_performed"):
		player.riposte_performed.connect(_on_player_riposte_performed)


func setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)


# ── 5. User Interface & Objective Tracking ────────────────────────────────────
func setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "TutorialHUD"
	ui_layer.layer = 10
	add_child(ui_layer)

	hud_container = Control.new()
	hud_container.name = "HUDContainer"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud_container)

	# ── 1. Top-Center Objective Card ──
	objective_panel = PanelContainer.new()
	objective_panel.name = "ObjectivePanel"
	objective_panel.anchor_left = 0.5
	objective_panel.anchor_right = 0.5
	objective_panel.offset_left = -135.0
	objective_panel.offset_right = 135.0
	objective_panel.offset_top = 8.0
	objective_panel.offset_bottom = 62.0

	var obj_sb := StyleBoxFlat.new()
	obj_sb.bg_color = Color(0.06, 0.08, 0.12, 0.90)
	obj_sb.border_color = Color(0.85, 0.72, 0.45, 1.0)
	obj_sb.border_width_left = 2
	obj_sb.border_width_right = 2
	obj_sb.border_width_top = 2
	obj_sb.border_width_bottom = 2
	obj_sb.corner_radius_top_left = 4
	obj_sb.corner_radius_top_right = 4
	obj_sb.corner_radius_bottom_left = 4
	obj_sb.corner_radius_bottom_right = 4
	obj_sb.content_margin_left = 10
	obj_sb.content_margin_right = 10
	obj_sb.content_margin_top = 5
	obj_sb.content_margin_bottom = 5
	objective_panel.add_theme_stylebox_override("panel", obj_sb)
	hud_container.add_child(objective_panel)

	var obj_vbox := VBoxContainer.new()
	obj_vbox.add_theme_constant_override("separation", 2)
	objective_panel.add_child(obj_vbox)

	var title_box := HBoxContainer.new()
	obj_vbox.add_child(title_box)

	objective_title_label = Label.new()
	objective_title_label.name = "ObjectiveTitle"
	objective_title_label.text = "✦ TUTORIAL OBJECTIVE ✦"
	objective_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_title_label.add_theme_font_override("font", FONT_ALAGARD)
	objective_title_label.add_theme_font_size_override("font_size", 11)
	objective_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))
	title_box.add_child(objective_title_label)

	objective_progress_label = Label.new()
	objective_progress_label.name = "ObjectiveProgress"
	objective_progress_label.text = "Step 1 / 10"
	objective_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_progress_label.add_theme_font_override("font", FONT_ALAGARD)
	objective_progress_label.add_theme_font_size_override("font_size", 11)
	objective_progress_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.9))
	title_box.add_child(objective_progress_label)

	objective_desc_label = Label.new()
	objective_desc_label.name = "ObjectiveDesc"
	objective_desc_label.text = "Use [A] and [D] to move. Hold [Shift] to sprint."
	objective_desc_label.add_theme_font_override("font", FONT_ALAGARD)
	objective_desc_label.add_theme_font_size_override("font_size", 11)
	objective_desc_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1.0))
	objective_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_desc_label.custom_minimum_size = Vector2(240, 0)
	obj_vbox.add_child(objective_desc_label)

	# ── 2. Health Bar (Top-Left: 12, 10) ──
	hp_bar_root = Control.new()
	hp_bar_root.name = "HealthBarRoot"
	hp_bar_root.position = Vector2(12, 10)
	hp_bar_root.size = Vector2(150, 14)
	hud_container.add_child(hp_bar_root)

	var hp_bg := ColorRect.new()
	hp_bg.position = Vector2(-1, -1)
	hp_bg.size = Vector2(152, 16)
	hp_bg.color = Color(0.08, 0.07, 0.09, 0.92)
	hp_bar_root.add_child(hp_bg)

	var hp_border := ReferenceRect.new()
	hp_border.position = Vector2(-1, -1)
	hp_border.size = Vector2(152, 16)
	hp_border.border_color = Color(0.65, 0.52, 0.30, 0.9)
	hp_border.border_width = 1.0
	hp_border.editor_only = false
	hp_bar_root.add_child(hp_border)

	hp_ghost_clip = Control.new()
	hp_ghost_clip.position = Vector2(1, 1)
	hp_ghost_clip.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_ghost_clip.clip_contents = true
	hp_bar_root.add_child(hp_ghost_clip)

	var hp_ghost_fill := ColorRect.new()
	hp_ghost_fill.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_ghost_fill.color = Color(0.95, 0.75, 0.25, 0.75)
	hp_ghost_clip.add_child(hp_ghost_fill)

	hp_fill_clip = Control.new()
	hp_fill_clip.position = Vector2(1, 1)
	hp_fill_clip.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_fill_clip.clip_contents = true
	hp_bar_root.add_child(hp_fill_clip)

	var hp_fill_rect := ColorRect.new()
	hp_fill_rect.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_fill_rect.color = Color(0.72, 0.14, 0.18, 1.0)
	hp_fill_clip.add_child(hp_fill_rect)

	# Luminous Crystal Shield Coating (Cyan/silver overlay over health)
	hp_shield_clip = Control.new()
	hp_shield_clip.name = "HPShieldClip"
	hp_shield_clip.position = Vector2(1, 1)
	hp_shield_clip.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_shield_clip.clip_contents = true
	hp_bar_root.add_child(hp_shield_clip)

	var hp_shield_rect := ColorRect.new()
	hp_shield_rect.name = "HPShieldRect"
	hp_shield_rect.size = Vector2(HP_FILL_MAX_WIDTH, 12)
	hp_shield_rect.color = Color(0.35, 0.85, 1.35, 0.85)
	hp_shield_clip.add_child(hp_shield_rect)

	hp_text_label = Label.new()
	hp_text_label.position = Vector2(6, 0)
	hp_text_label.text = "HP  5 / 5  (+3)"
	hp_text_label.add_theme_font_override("font", FONT_ALAGARD)
	hp_text_label.add_theme_font_size_override("font_size", 10)
	hp_text_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 0.95))
	hp_text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hp_text_label.add_theme_constant_override("shadow_offset_x", 1)
	hp_text_label.add_theme_constant_override("shadow_offset_y", 1)
	hp_bar_root.add_child(hp_text_label)

	# ── 3. Stamina Bar (Below Health Bar: 12, 30) ──
	stamina_bar_root = Control.new()
	stamina_bar_root.position = Vector2(12, 30)
	stamina_bar_root.size = Vector2(120, 8)
	hud_container.add_child(stamina_bar_root)

	var sta_bg := ColorRect.new()
	sta_bg.position = Vector2(-1, -1)
	sta_bg.size = Vector2(122, 10)
	sta_bg.color = Color(0.08, 0.07, 0.09, 0.90)
	stamina_bar_root.add_child(sta_bg)

	var sta_border := ReferenceRect.new()
	sta_border.position = Vector2(-1, -1)
	sta_border.size = Vector2(122, 10)
	sta_border.border_color = Color(0.50, 0.45, 0.35, 0.8)
	sta_border.border_width = 1.0
	sta_border.editor_only = false
	stamina_bar_root.add_child(sta_border)

	stamina_fill_clip = Control.new()
	stamina_fill_clip.position = Vector2(1, 1)
	stamina_fill_clip.size = Vector2(STA_FILL_MAX_WIDTH, 8)
	stamina_fill_clip.clip_contents = true
	stamina_bar_root.add_child(stamina_fill_clip)

	var sta_fill_rect := ColorRect.new()
	sta_fill_rect.size = Vector2(STA_FILL_MAX_WIDTH, 8)
	sta_fill_rect.color = Color(0.28, 0.62, 0.36, 1.0)
	stamina_fill_clip.add_child(sta_fill_rect)

	stamina_text_label = Label.new()
	stamina_text_label.position = Vector2(6, -2)
	stamina_text_label.text = "STA  100 / 100"
	stamina_text_label.add_theme_font_override("font", FONT_ALAGARD)
	stamina_text_label.add_theme_font_size_override("font_size", 9)
	stamina_text_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9, 0.95))
	stamina_text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	stamina_text_label.add_theme_constant_override("shadow_offset_x", 1)
	stamina_text_label.add_theme_constant_override("shadow_offset_y", 1)
	stamina_bar_root.add_child(stamina_text_label)

	# ── 4. Equipped Weapon Badge (Top-Right: 490, 10) ──
	weapon_badge_label = Label.new()
	weapon_badge_label.position = Vector2(490, 10)
	weapon_badge_label.size = Vector2(140, 20)
	weapon_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	weapon_badge_label.text = "⚔ Weapon: Unarmed"
	weapon_badge_label.add_theme_font_override("font", FONT_ALAGARD)
	weapon_badge_label.add_theme_font_size_override("font_size", 12)
	weapon_badge_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.76, 0.90))
	weapon_badge_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.90))
	hud_container.add_child(weapon_badge_label)

	# ── 5. Quick Controls Ribbon (Bottom of Screen) ──
	controls_ribbon = Label.new()
	controls_ribbon.name = "ControlsRibbon"
	controls_ribbon.anchor_top = 1.0
	controls_ribbon.anchor_bottom = 1.0
	controls_ribbon.anchor_left = 0.0
	controls_ribbon.anchor_right = 1.0
	controls_ribbon.offset_top = -24.0
	controls_ribbon.offset_bottom = -4.0
	controls_ribbon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_ribbon.text = "[A/D] Move  •  [Shift] Sprint  •  [Space] Jump  •  [J] Attack  •  [K] Guard / Parry  •  [Alt] Dodge  •  [E] Interact  •  [ESC] Menu"
	controls_ribbon.add_theme_font_override("font", FONT_ALAGARD)
	controls_ribbon.add_theme_font_size_override("font_size", 11)
	controls_ribbon.add_theme_color_override("font_color", Color(0.68, 0.65, 0.60, 0.85))
	controls_ribbon.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	hud_container.add_child(controls_ribbon)

	# ── 6. Center Notification Banner ──
	banner_label = Label.new()
	banner_label.name = "BannerLabel"
	banner_label.anchor_left = 0.5
	banner_label.anchor_right = 0.5
	banner_label.offset_left = -250.0
	banner_label.offset_right = 250.0
	banner_label.offset_top = 90.0
	banner_label.offset_bottom = 120.0
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_override("font", FONT_ALAGARD)
	banner_label.add_theme_font_size_override("font_size", 16)
	banner_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35, 1.0))
	banner_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	banner_label.add_theme_constant_override("shadow_offset_x", 1)
	banner_label.add_theme_constant_override("shadow_offset_y", 1)
	banner_label.visible = false
	hud_container.add_child(banner_label)


func show_banner(text: String, color: Color = Color(1.0, 0.88, 0.35, 1.0)) -> void:
	if not banner_label:
		return
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", color)
	banner_label.modulate.a = 1.0
	banner_label.visible = true
	banner_timer = 2.4


func update_objective_display() -> void:
	if not is_instance_valid(objective_title_label) or not is_instance_valid(objective_desc_label):
		return

	match current_step:
		TutorialStep.MOVE_AND_SPRINT:
			objective_title_label.text = "✦ LESSON 1: MOVEMENT & SPRINT ✦"
			objective_progress_label.text = "Step 1 / 10"
			objective_desc_label.text = "Press [A] and [D] to walk. Hold [Shift] while running to sprint."

		TutorialStep.JUMP_AND_CROUCH:
			objective_title_label.text = "✦ LESSON 2: JUMP & CROUCH ✦"
			objective_progress_label.text = "Step 2 / 10"
			objective_desc_label.text = "Press [Space] to leap onto the platform. Hold [S] to crouch under the beam."

		TutorialStep.SELECT_WEAPON:
			objective_title_label.text = "✦ LESSON 3: SELECT YOUR WEAPON ✦"
			objective_progress_label.text = "Step 3 / 10"
			objective_desc_label.text = "Approach the weapon rack and press [E] to equip a blade."

		TutorialStep.ATTACK_COMBOS:
			objective_title_label.text = "✦ LESSON 4: MELEE COMBAT ✦"
			objective_progress_label.text = "Step 4 / 10"
			objective_desc_label.text = "Press [J] or [LMB] to slash. Chain 3 strikes for a swift melee combo (%d/3 attacks)." % flag_attack_count

		TutorialStep.SMASH_POTS:
			objective_title_label.text = "✦ LESSON 5: CLAY POTS & LOOT ✦"
			objective_progress_label.text = "Step 5 / 10"
			objective_desc_label.text = "Attack the clay pots [J] to break them and pick up healing items."

		TutorialStep.DODGE_ROLL:
			objective_title_label.text = "✦ LESSON 6: EVASIVE DODGE ROLL ✦"
			objective_progress_label.text = "Step 6 / 10"
			objective_desc_label.text = "Press [Alt] or [C] to dodge roll with invincibility frames (uses stamina)."

		TutorialStep.GUARD_AND_PARRY:
			objective_title_label.text = "✦ LESSON 7: GUARD & PERFECT PARRY ✦"
			objective_progress_label.text = "Step 7 / 10"
			objective_desc_label.text = "Hold [K] to block. Tap [K] right as an attack lands to PERFECT PARRY!"

		TutorialStep.RIPOSTE_STRIKE:
			objective_title_label.text = "✦ LESSON 8: DEADLY RIPOSTE ✦"
			objective_progress_label.text = "Step 8 / 10"
			objective_desc_label.text = "The dummy is staggered! Press [J] IMMEDIATELY to execute a critical Riposte!"

		TutorialStep.TALK_TO_KAPRE:
			objective_title_label.text = "✦ LESSON 9: ELDER LORE & GUIDANCE ✦"
			objective_progress_label.text = "Step 9 / 10"
			objective_desc_label.text = "Approach the Balete tree and press [E] to speak with the Kapre elder."

		TutorialStep.CLAIM_MASK:
			objective_title_label.text = "✦ LESSON 10: THE MASK OF HALIYA ✦"
			objective_progress_label.text = "Step 10 / 10"
			objective_desc_label.text = "Approach the Moon Altar and press [E] to claim the Mask of Sorrow."

		TutorialStep.ENTER_GATEWAY:
			objective_title_label.text = "✦ TUTORIAL COMPLETE: THE JOURNEY AWAITS ✦"
			objective_progress_label.text = "Complete!"
			objective_desc_label.text = "Step through the glowing spirit gateway ahead to begin Chapter 1!"

		TutorialStep.COMPLETED:
			objective_title_label.text = "✦ READY FOR ADVENTURE ✦"
			objective_progress_label.text = "Complete!"
			objective_desc_label.text = "Transitioning to the Whispering Canopy..."


func advance_step(next_step: TutorialStep, completion_msg: String = "✓ OBJECTIVE COMPLETE! ✓") -> void:
	current_step = next_step
	show_banner(completion_msg, Color(0.4, 1.0, 0.5, 1.0))
	var sfx = ProceduralAudio.get_ui_select()
	if sfx:
		var p = AudioStreamPlayer.new()
		p.stream = sfx
		p.volume_db = -2.0
		add_child(p)
		p.play()
		p.finished.connect(Callable(p, "queue_free"))
	update_objective_display()


# ── 6. Physics & Game Loop ───────────────────────────────────────────────────
func _process(delta: float) -> void:
	if is_instance_valid(player):
		# Camera tracking
		var target_x: float = clamp(player.global_position.x, 320.0, LEVEL_WIDTH - 320.0)
		camera.global_position = Vector2(target_x, 180.0)

		# Check tutorial progress according to player inputs & positions
		check_tutorial_progress()

		# Check gateway exit trigger
		if current_step >= TutorialStep.ENTER_GATEWAY and not is_transitioning:
			if player.global_position.x >= GATEWAY_POS_X:
				trigger_tutorial_complete()

	# Banner timer
	if banner_timer > 0.0:
		banner_timer -= delta
		if banner_timer <= 0.0 and banner_label:
			banner_label.visible = false


func check_tutorial_progress() -> void:
	if not is_instance_valid(player):
		return

	# Step 1: Move & Sprint
	if current_step == TutorialStep.MOVE_AND_SPRINT:
		if Input.is_action_pressed("move_left"):
			flag_moved_left = true
		if Input.is_action_pressed("move_right"):
			flag_moved_right = true
		if Input.is_action_pressed("run") and (flag_moved_left or flag_moved_right):
			flag_sprinted = true

		if (flag_moved_left or flag_moved_right) and flag_sprinted:
			advance_step(TutorialStep.JUMP_AND_CROUCH, "✓ MOVEMENT MASTERED! ✓")

	# Step 2: Jump & Crouch
	elif current_step == TutorialStep.JUMP_AND_CROUCH:
		if player.current_state == PlayerScript.State.JUMP:
			flag_jumped = true
		if player.current_state == PlayerScript.State.CROUCH:
			flag_crouched = true

		# Advancing when jumping over platform or crouching
		if flag_jumped and (flag_crouched or player.global_position.x > 840.0):
			advance_step(TutorialStep.SELECT_WEAPON, "✓ AGILITY MASTERED! ✓")

	# Step 3: Select Weapon
	elif current_step == TutorialStep.SELECT_WEAPON:
		if flag_weapon_chosen:
			advance_step(TutorialStep.ATTACK_COMBOS, "✓ WEAPON EQUIPPED! ✓")

	# Step 4: Attack Combos
	elif current_step == TutorialStep.ATTACK_COMBOS:
		if flag_attack_count >= 3:
			advance_step(TutorialStep.SMASH_POTS, "✓ MELEE COMBOS MASTERED! ✓")

	# Step 5: Smash Pots
	elif current_step == TutorialStep.SMASH_POTS:
		if flag_pot_smashed:
			advance_step(TutorialStep.DODGE_ROLL, "✓ CLAY POT SMASHED! ✓")

	# Step 6: Dodge Roll
	elif current_step == TutorialStep.DODGE_ROLL:
		if player.current_state == PlayerScript.State.DODGE or Input.is_action_just_pressed("dodge"):
			flag_dodged = true
			advance_step(TutorialStep.GUARD_AND_PARRY, "✓ EVASIVE ROLL MASTERED! ✓")

	# Step 7: Guard & Parry
	elif current_step == TutorialStep.GUARD_AND_PARRY:
		if Input.is_action_pressed("guard") or player.current_state == PlayerScript.State.GUARD:
			flag_guarded = true
		if flag_parried:
			advance_step(TutorialStep.RIPOSTE_STRIKE, "★ PERFECT PARRY EXECUTED! ★")

	# Step 8: Riposte Strike
	elif current_step == TutorialStep.RIPOSTE_STRIKE:
		if flag_riposted:
			advance_step(TutorialStep.TALK_TO_KAPRE, "★ CRITICAL RIPOSTE SUCCESSFUL! ★")

	# Step 9: Talk to Kapre
	elif current_step == TutorialStep.TALK_TO_KAPRE:
		if flag_kapre_spoken:
			advance_step(TutorialStep.CLAIM_MASK, "✓ ELDER COUNSEL RECEIVED! ✓")

	# Step 10: Claim Mask
	elif current_step == TutorialStep.CLAIM_MASK:
		if flag_mask_claimed:
			advance_step(TutorialStep.ENTER_GATEWAY, "★ MASK OF HALIYA CLAIMED! ★")


# ── 7. Signal Callbacks ───────────────────────────────────────────────────────
func _on_weapon_selected(w_name: String) -> void:
	flag_weapon_chosen = true
	if weapon_badge_label:
		weapon_badge_label.text = "⚔ Weapon: %s" % w_name
		weapon_badge_label.modulate = Color(1.5, 1.3, 0.4, 1.0)
		get_tree().create_timer(0.6).timeout.connect(func():
			if weapon_badge_label:
				weapon_badge_label.modulate = Color(1, 1, 1, 1)
		)
	if current_step == TutorialStep.SELECT_WEAPON:
		advance_step(TutorialStep.ATTACK_COMBOS, "✓ WEAPON EQUIPPED: %s! ✓" % w_name.to_upper())


func _on_player_hit_landed(_is_heavy: bool, _hit_pos: Vector2) -> void:
	flag_attack_count += 1
	if current_step == TutorialStep.ATTACK_COMBOS:
		update_objective_display()
		if flag_attack_count >= 3:
			advance_step(TutorialStep.SMASH_POTS, "✓ MELEE COMBOS MASTERED! ✓")


func _on_pot_broken() -> void:
	flag_pot_smashed = true
	if current_step == TutorialStep.SMASH_POTS:
		advance_step(TutorialStep.DODGE_ROLL, "✓ POT SMASHED! COLLECT THE ITEM! ✓")


func _on_dummy_parried() -> void:
	flag_parried = true
	if current_step == TutorialStep.GUARD_AND_PARRY:
		advance_step(TutorialStep.RIPOSTE_STRIKE, "★ PERFECT PARRY! PRESS [J] NOW! ★")


func _on_dummy_riposted() -> void:
	flag_riposted = true
	if current_step == TutorialStep.RIPOSTE_STRIKE:
		advance_step(TutorialStep.TALK_TO_KAPRE, "★ CRITICAL RIPOSTE SUCCESSFUL! ★")


func _on_player_riposte_performed(_hit_pos: Vector2) -> void:
	flag_riposted = true
	if current_step == TutorialStep.RIPOSTE_STRIKE:
		advance_step(TutorialStep.TALK_TO_KAPRE, "★ CRITICAL RIPOSTE SUCCESSFUL! ★")


func _on_dialogue_finished() -> void:
	flag_kapre_spoken = true
	if current_step == TutorialStep.TALK_TO_KAPRE:
		advance_step(TutorialStep.CLAIM_MASK, "✓ ELDER COUNSEL RECEIVED! ✓")


func _on_mask_claimed() -> void:
	flag_mask_claimed = true
	if exit_barrier:
		exit_barrier.position = Vector2(LEVEL_WIDTH + 500.0, 0)

	# Ignite Gateway
	if gateway_particles:
		gateway_particles.emitting = true
	if gateway_light:
		var tw = create_tween()
		tw.tween_property(gateway_light, "energy", 2.2, 1.2)

	advance_step(TutorialStep.ENTER_GATEWAY, "✦ SPIRIT GATEWAY UNLOCKED! ✦")


func _on_player_died() -> void:
	if is_instance_valid(player):
		player.global_position = PLAYER_SPAWN_POS
		player.velocity = Vector2.ZERO
		player.current_hp = 5
		player.hp_changed.emit(5, 5)
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()
		show_banner("Revived at Training Grounds", Color(1.0, 0.4, 0.4, 1.0))


func _update_hp_bar_display() -> void:
	if not is_instance_valid(hp_fill_clip) or not is_instance_valid(hp_ghost_clip):
		return

	var hp_ratio: float = clamp(float(_cur_hp_cached) / float(_max_hp_cached), 0.0, 1.0) if _max_hp_cached > 0 else 0.0
	var target_w: float = HP_FILL_MAX_WIDTH * hp_ratio

	var tw = create_tween()
	tw.tween_property(hp_fill_clip, "size:x", target_w, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var tw_ghost = create_tween()
	tw_ghost.tween_interval(0.40)
	tw_ghost.tween_property(hp_ghost_clip, "size:x", target_w, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if is_instance_valid(hp_shield_clip):
		var arm_ratio: float = clamp(float(_cur_arm_cached) / float(_max_arm_cached), 0.0, 1.0) if _max_arm_cached > 0 else 0.0
		var shield_target_w: float = HP_FILL_MAX_WIDTH * arm_ratio
		var tw_shield = create_tween()
		tw_shield.tween_property(hp_shield_clip, "size:x", shield_target_w, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if hp_text_label:
		if _cur_arm_cached > 0:
			hp_text_label.text = "HP  %d / %d  (+%d)" % [_cur_hp_cached, _max_hp_cached, _cur_arm_cached]
			hp_text_label.add_theme_color_override("font_color", Color(0.85, 0.98, 1.2, 0.95))
		else:
			hp_text_label.text = "HP  %d / %d" % [_cur_hp_cached, _max_hp_cached]
			hp_text_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.92, 0.95))

func _on_player_hp_changed(current: int, max_hp: int) -> void:
	_cur_hp_cached = current
	_max_hp_cached = max_hp
	_update_hp_bar_display()

func _on_player_armor_changed(current: int, max_armor: int) -> void:
	_cur_arm_cached = current
	_max_arm_cached = max_armor
	_update_hp_bar_display()


func _on_player_stamina_changed(current: float, max_stamina: float) -> void:
	if not is_instance_valid(stamina_fill_clip):
		return

	var ratio: float = clamp(current / max_stamina, 0.0, 1.0)
	stamina_fill_clip.size.x = STA_FILL_MAX_WIDTH * ratio

	if stamina_text_label:
		if is_instance_valid(player) and player.get("is_exhausted") == true:
			stamina_text_label.text = "STA  0 / %d  (EXHAUSTED)" % int(max_stamina)
			stamina_text_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		else:
			stamina_text_label.text = "STA  %d / %d" % [int(ceil(current)), int(max_stamina)]
			stamina_text_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.90, 0.95))


# ── 8. Tutorial Completion Celebration ─────────────────────────────────────────
func trigger_tutorial_complete() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	current_step = TutorialStep.COMPLETED
	update_objective_display()
	show_banner("✦ TUTORIAL MASTERED! ✦")

	# Play celebration audio chime
	var chime := AudioStreamPlayer.new()
	chime.stream = ProceduralAudioScript.get_ui_select()
	add_child(chime)
	chime.play()

	# Show completion victory dialog
	setup_complete_modal()


func setup_complete_modal() -> void:
	var complete_overlay := Control.new()
	complete_overlay.name = "TutorialCompleteOverlay"
	complete_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	complete_overlay.z_index = 60
	if ui_layer:
		ui_layer.add_child(complete_overlay)
	else:
		add_child(complete_overlay)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.70)
	complete_overlay.add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	sb.border_color = Color(0.9, 0.75, 0.35, 1.0)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	complete_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "✦ TUTORIAL MASTERED ✦"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT_ALAGARD)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.40, 1.0))
	vbox.add_child(title)

	var desc := Label.new()
	desc.text = "You have mastered all ancestral combat & survival techniques:\n\n• Sprinting, Jumping, & Low Crawling\n• 3-Hit Combo & Pot Smashing\n• Dodge Rolling with Invulnerability\n• Guarding & Perfect Parry Timings\n• Stagger Vulnerability & 3x Critical Riposte\n• Lore of the Balete & Moon Altar Claim\n\nTake your time to practice freely or replay the training."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_override("font", FONT_ALAGARD)
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 1.0))
	vbox.add_child(desc)

	var btn_box := HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_box)

	var btn_begin := create_menu_btn("BEGIN CHAPTER 1")
	btn_begin.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
	btn_box.add_child(btn_begin)

	var btn_freeplay := create_menu_btn("FREE PRACTICE")
	btn_freeplay.pressed.connect(func():
		complete_overlay.queue_free()
		is_transitioning = false
	)
	btn_box.add_child(btn_freeplay)

	var btn_restart := create_menu_btn("RESTART")
	btn_restart.custom_minimum_size = Vector2(110, 28)
	btn_restart.pressed.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
	btn_box.add_child(btn_restart)

	var btn_menu := create_menu_btn("MAIN MENU")
	btn_menu.custom_minimum_size = Vector2(110, 28)
	btn_menu.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	btn_box.add_child(btn_menu)


# ── 9. Pause Menu (ESC) ────────────────────────────────────────────────────────
func setup_pause_menu() -> void:
	pause_overlay = Control.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.visible = false
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(pause_overlay)

	var bg_dim := ColorRect.new()
	bg_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_dim.color = Color(0, 0, 0, 0.78)
	pause_overlay.add_child(bg_dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -160.0
	panel.offset_right = 160.0
	panel.offset_top = -110.0
	panel.offset_bottom = 110.0

	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.07, 0.09, 0.13, 0.96)
	panel_sb.border_color = Color(0.85, 0.72, 0.45, 1.0)
	panel_sb.border_width_left = 2
	panel_sb.border_width_right = 2
	panel_sb.border_width_top = 2
	panel_sb.border_width_bottom = 2
	panel_sb.content_margin_left = 18
	panel_sb.content_margin_right = 18
	panel_sb.content_margin_top = 14
	panel_sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", panel_sb)
	pause_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header := Label.new()
	header.text = "TUTORIAL PAUSED"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_override("font", FONT_ALAGARD)
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1.0))
	vbox.add_child(header)

	var btn_resume := create_menu_btn("RESUME")
	btn_resume.pressed.connect(toggle_pause)
	vbox.add_child(btn_resume)

	var btn_restart := create_menu_btn("RESTART TUTORIAL")
	btn_restart.pressed.connect(func():
		toggle_pause()
		get_tree().reload_current_scene()
	)
	vbox.add_child(btn_restart)

	var btn_menu := create_menu_btn("MAIN MENU")
	btn_menu.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	vbox.add_child(btn_menu)


func create_menu_btn(txt: String) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(160, 28)
	btn.add_theme_font_override("font", FONT_ALAGARD)
	btn.add_theme_font_size_override("font_size", 13)
	return btn


func toggle_pause() -> void:
	if not is_instance_valid(pause_overlay):
		return
	var is_p = not get_tree().paused
	get_tree().paused = is_p
	pause_overlay.visible = is_p


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()

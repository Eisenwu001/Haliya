class_name Act1BahayKuboHub
extends Node2D

const AssetsScript = preload("res://scripts/assets.gd")
const PlayerScript = preload("res://scripts/player.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const DialogueManagerScript = preload("res://scripts/dialogue_manager.gd")
const KapreNPCScript = preload("res://scripts/kapre_npc.gd")
const WeaponRackScript = preload("res://scripts/weapon_rack.gd")
const MaskAltarScript = preload("res://scripts/mask_altar.gd")

const LEVEL_WIDTH: float = 1920.0
const PLAYER_SPAWN_POS: Vector2 = Vector2(175, 255)
const GATEWAY_POS: Vector2 = Vector2(1780, 250)

var player: CharacterBody2D
var camera: Camera2D
var dialogue_manager: DialogueManager
var kapre_npc: KapreNPC
var weapon_rack: WeaponRack
var mask_altar: MaskAltar
var guardian_enemy: Aswang
var gateway_active: bool = false
var exit_wall: CollisionShape2D
var is_transitioning: bool = false

# UI references
var ui_layer: CanvasLayer
var area_title_label: Label
var area_title_timer: float = 0.0
var hp_bar_root: Control
var hp_segments: Array[ColorRect] = []
var stamina_bar_root: Control
var stamina_bar_fill: ColorRect
var weapon_badge_label: Label

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	setup_parallax_bg()
	setup_environment_ground()
	setup_homestead_and_props()
	setup_player()
	setup_camera()
	setup_dialogue_system()
	setup_kapre_and_altar()
	setup_ui()
	trigger_area_discovery("ACT 1 — BAHAY KUBO (THE HOMESTEAD)")

func setup_parallax_bg() -> void:
	var pb := ParallaxBackground.new()
	add_child(pb)
	
	var layers_data = [
		{"path": AssetsScript.PATH_BG_LAYER_5, "scale": Vector2(0.02, 0.0), "mirror_w": 1024, "spr_scale": Vector2(1.0, 1.05)},
		{"path": AssetsScript.PATH_BG_LAYER_4, "scale": Vector2(0.12, 0.0), "mirror_w": 2128, "spr_scale": Vector2(0.5, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_3, "scale": Vector2(0.28, 0.0), "mirror_w": 2128, "spr_scale": Vector2(0.5, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_2, "scale": Vector2(0.50, 0.0), "mirror_w": 2128, "spr_scale": Vector2(0.5, 0.5)},
		{"path": AssetsScript.PATH_BG_LAYER_1, "scale": Vector2(0.75, 0.0), "mirror_w": 2128, "spr_scale": Vector2(0.5, 0.5)}
	]
	
	for l_data in layers_data:
		var layer := ParallaxLayer.new()
		layer.motion_scale = l_data["scale"]
		layer.motion_mirroring = Vector2(l_data["mirror_w"], 0)
		
		var spr := Sprite2D.new()
		var tex = load(l_data["path"])
		if tex:
			spr.texture = tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.centered = false
			spr.scale = l_data.get("spr_scale", Vector2(1.0, 1.0))
			layer.add_child(spr)
		pb.add_child(layer)

func setup_environment_ground() -> void:
	# Ground Physics (Y=288 floor boundary)
	var ground_body := StaticBody2D.new()
	ground_body.name = "GroundBody"
	ground_body.collision_layer = 1
	ground_body.collision_mask = 0
	
	var col := CollisionShape2D.new()
	var shape := WorldBoundaryShape2D.new()
	shape.normal = Vector2.UP
	col.shape = shape
	col.position = Vector2(0, 288)
	ground_body.add_child(col)
	
	# Left & Right Level Boundaries
	var left_wall := CollisionShape2D.new()
	var left_shape := WorldBoundaryShape2D.new()
	left_shape.normal = Vector2.RIGHT
	left_wall.shape = left_shape
	left_wall.position = Vector2(16, 0)
	ground_body.add_child(left_wall)
	
	var right_wall := CollisionShape2D.new()
	var right_shape := WorldBoundaryShape2D.new()
	right_shape.normal = Vector2.LEFT
	right_wall.shape = right_shape
	right_wall.position = Vector2(1820, 0)
	ground_body.add_child(right_wall)
	exit_wall = right_wall
	
	add_child(ground_body)
	
	# Ground visuals with Floor Tiles
	var floor_tex = load(AssetsScript.PATH_FLOOR_TILES) as Texture2D
	if floor_tex:
		var ground_container := Node2D.new()
		ground_container.name = "GroundVisuals"
		ground_container.z_index = -1
		for x in range(0, int(LEVEL_WIDTH), 32):
			var spr := Sprite2D.new()
			spr.texture = floor_tex
			spr.region_enabled = true
			spr.region_rect = Rect2(0, 0, 32, 32)
			spr.position = Vector2(x + 16, 304)
			ground_container.add_child(spr)
			
			var spr_sub := Sprite2D.new()
			spr_sub.texture = floor_tex
			spr_sub.region_enabled = true
			spr_sub.region_rect = Rect2(0, 32, 32, 32)
			spr_sub.position = Vector2(x + 16, 336)
			ground_container.add_child(spr_sub)
		add_child(ground_container)

func setup_homestead_and_props() -> void:
	var props_container := Node2D.new()
	props_container.name = "HomesteadProps"
	props_container.z_index = 0
	add_child(props_container)
	
	# 1. Authentic Bahay Kubo House (Stilt home at X=150, Y=172)
	var house_tex = load("res://assets/bahay_kubo/bahay_kubo_house.png") as Texture2D
	if house_tex:
		var house_spr := Sprite2D.new()
		house_spr.name = "BahayKuboHouse"
		house_spr.texture = house_tex
		house_spr.scale = Vector2(0.5, 0.5) # Match 0.5 pixel resolution scale
		house_spr.position = Vector2(150, 172)
		house_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(house_spr)
	
	# 2. Banana Tree (Left of house: X=35, Y=240)
	var banana_tex = load("res://assets/bahay_kubo/prop_banana_tree.png") as Texture2D
	if banana_tex:
		var b_spr := Sprite2D.new()
		b_spr.texture = banana_tex
		b_spr.scale = Vector2(0.5, 0.5)
		b_spr.position = Vector2(35, 240)
		b_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(b_spr)
	
	# 3. Wooden Yard Fence (X=280, Y=265)
	var fence_tex = load("res://assets/bahay_kubo/prop_wooden_fence.png") as Texture2D
	if fence_tex:
		var f_spr := Sprite2D.new()
		f_spr.texture = fence_tex
		f_spr.scale = Vector2(0.5, 0.5)
		f_spr.position = Vector2(280, 268)
		f_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(f_spr)
	
	# 4. Rooster in Yard (X=245, Y=272)
	var rooster_tex = load("res://assets/bahay_kubo/prop_rooster.png") as Texture2D
	if rooster_tex:
		var r_spr := Sprite2D.new()
		r_spr.texture = rooster_tex
		r_spr.scale = Vector2(0.45, 0.45)
		r_spr.position = Vector2(245, 272)
		r_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(r_spr)
	
	# 5. Sleeping Cat (On Bahay Kubo Porch: X=210, Y=222)
	var cat_tex = load("res://assets/bahay_kubo/prop_sleeping_cat.png") as Texture2D
	if cat_tex:
		var c_spr := Sprite2D.new()
		c_spr.texture = cat_tex
		c_spr.scale = Vector2(0.5, 0.5)
		c_spr.position = Vector2(210, 222)
		c_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(c_spr)
	
	# 6. Firewood Pile Under Stilts (X=110, Y=273)
	var wood_tex = load("res://assets/bahay_kubo/prop_firewood.png") as Texture2D
	if wood_tex:
		var w_spr := Sprite2D.new()
		w_spr.texture = wood_tex
		w_spr.scale = Vector2(0.5, 0.5)
		w_spr.position = Vector2(110, 273)
		w_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(w_spr)
	
	# 7. Mossy Rocks along the path (X=420, Y=270 and X=1100, Y=270)
	var rock_tex = load("res://assets/bahay_kubo/prop_mossy_rocks.png") as Texture2D
	if rock_tex:
		var rock1 := Sprite2D.new()
		rock1.texture = rock_tex
		rock1.scale = Vector2(0.45, 0.45)
		rock1.position = Vector2(420, 270)
		rock1.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(rock1)
		
		var rock2 := Sprite2D.new()
		rock2.texture = rock_tex
		rock2.scale = Vector2(0.45, 0.45)
		rock2.position = Vector2(1100, 270)
		rock2.flip_h = true
		rock2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(rock2)
	
	# 8. Balete Tree for Kapre (X=640, Y=168)
	var tree_tex = load("res://assets/bahay_kubo/balete_tree.png") as Texture2D
	if tree_tex:
		var tree_spr := Sprite2D.new()
		tree_spr.name = "BaleteTree"
		tree_spr.texture = tree_tex
		tree_spr.position = Vector2(640, 168)
		tree_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		props_container.add_child(tree_spr)

func setup_player() -> void:
	player = PlayerScript.new()
	player.name = "Player"
	player.global_position = PLAYER_SPAWN_POS
	add_child(player)
	
	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(_on_player_hp_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)

func setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)

func setup_dialogue_system() -> void:
	dialogue_manager = DialogueManagerScript.new()
	dialogue_manager.name = "DialogueManager"
	add_child(dialogue_manager)

func setup_kapre_and_altar() -> void:
	# 1. Kapre NPC (at Balete Tree: X=640, Y=265)
	kapre_npc = KapreNPCScript.new()
	kapre_npc.name = "KapreNPC"
	kapre_npc.position = Vector2(640, 265)
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 48.0
	col.shape = shape
	kapre_npc.add_child(col)
	
	var kapre_tex = load("res://assets/bahay_kubo/kapre_sprite.png") as Texture2D
	if kapre_tex:
		var spr := Sprite2D.new()
		spr.texture = kapre_tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = Vector2(0, -35)
		kapre_npc.add_child(spr)
	add_child(kapre_npc)
	
	# 2. Weapon Decision Rack (X=900, Y=265)
	weapon_rack = WeaponRackScript.new()
	weapon_rack.name = "WeaponRack"
	weapon_rack.position = Vector2(900, 265)
	
	var w_col := CollisionShape2D.new()
	var w_shape := CircleShape2D.new()
	w_shape.radius = 36.0
	w_col.shape = w_shape
	weapon_rack.add_child(w_col)
	
	var rack_tex = load("res://assets/bahay_kubo/weapon_rack.png") as Texture2D
	if rack_tex:
		var w_spr := Sprite2D.new()
		w_spr.texture = rack_tex
		w_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		w_spr.position = Vector2(0, -20)
		weapon_rack.add_child(w_spr)
	
	weapon_rack.weapon_selected.connect(_on_weapon_selected)
	add_child(weapon_rack)
	
	# 3. Mask of Sorrow Altar (X=1350, Y=265)
	mask_altar = MaskAltarScript.new()
	mask_altar.name = "MaskAltar"
	mask_altar.position = Vector2(1350, 265)
	
	var a_col := CollisionShape2D.new()
	var a_shape := CircleShape2D.new()
	a_shape.radius = 40.0
	a_col.shape = a_shape
	mask_altar.add_child(a_col)
	
	var altar_tex = load("res://assets/bahay_kubo/mask_altar.png") as Texture2D
	if altar_tex:
		var a_spr := Sprite2D.new()
		a_spr.texture = altar_tex
		a_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		a_spr.position = Vector2(0, -20)
		mask_altar.add_child(a_spr)
	
	mask_altar.mask_claimed.connect(_on_mask_claimed)
	add_child(mask_altar)
	
	# 4. Tutorial Corrupted Guardian (X=1200, Y=260)
	guardian_enemy = AswangScript.new()
	guardian_enemy.name = "TutorialGuardian"
	guardian_enemy.global_position = Vector2(1200, 260)
	mask_altar.guardian_enemy = guardian_enemy
	add_child(guardian_enemy)
	
	# 5. Exit to overworld unlocked via right edge after mask claim

func setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "HUD"
	add_child(ui_layer)
	
	var custom_font = load("res://alagard.ttf")
	
	# Health Bar Root (Top-Left: 14, 14)
	hp_bar_root = Control.new()
	hp_bar_root.position = Vector2(14, 14)
	hp_bar_root.size = Vector2(150, 8)
	ui_layer.add_child(hp_bar_root)
	
	var hp_bg = ColorRect.new()
	hp_bg.color = Color(0.08, 0.07, 0.09, 0.92)
	hp_bg.position = Vector2(-1, -1)
	hp_bg.size = Vector2(152, 10)
	hp_bar_root.add_child(hp_bg)
	
	hp_segments.clear()
	for i in range(5):
		var seg = ColorRect.new()
		seg.position = Vector2(1 + i * 30, 1)
		seg.size = Vector2(28, 6)
		seg.color = Color(0.66, 0.12, 0.18, 1.0)
		hp_bar_root.add_child(seg)
		hp_segments.append(seg)
	
	# Stamina Bar Root (Top-Left: 14, 26)
	stamina_bar_root = Control.new()
	stamina_bar_root.position = Vector2(14, 26)
	stamina_bar_root.size = Vector2(120, 5)
	ui_layer.add_child(stamina_bar_root)
	
	var sta_bg = ColorRect.new()
	sta_bg.color = Color(0.08, 0.07, 0.09, 0.90)
	sta_bg.position = Vector2(-1, -1)
	sta_bg.size = Vector2(122, 7)
	stamina_bar_root.add_child(sta_bg)
	
	stamina_bar_fill = ColorRect.new()
	stamina_bar_fill.position = Vector2(0, 0)
	stamina_bar_fill.size = Vector2(120, 5)
	stamina_bar_fill.color = Color(0.32, 0.54, 0.38, 1.0)
	stamina_bar_root.add_child(stamina_bar_fill)
	
	# Equipped Weapon Badge (Top-Right)
	weapon_badge_label = Label.new()
	weapon_badge_label.position = Vector2(420, 12)
	weapon_badge_label.size = Vector2(200, 20)
	weapon_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	weapon_badge_label.text = "⚔ Weapon: Unarmed"
	weapon_badge_label.add_theme_font_override("font", custom_font)
	weapon_badge_label.add_theme_font_size_override("font_size", 12)
	weapon_badge_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.76, 0.90))
	weapon_badge_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.90))
	ui_layer.add_child(weapon_badge_label)
	
	# Area Discovery Label (Center Upper)
	area_title_label = Label.new()
	area_title_label.position = Vector2(120, 55)
	area_title_label.size = Vector2(400, 32)
	area_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	area_title_label.text = "✦ ACT 1 — BAHAY KUBO ✦"
	area_title_label.add_theme_font_override("font", custom_font)
	area_title_label.add_theme_font_size_override("font_size", 16)
	area_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
	area_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	ui_layer.add_child(area_title_label)

func _process(delta: float) -> void:
	if player:
		var target_x: float = clamp(player.global_position.x, 320.0, LEVEL_WIDTH - 320.0)
		camera.global_position = Vector2(target_x, 180.0)
		
		# Check if player reaches edge to transition to overworld after claiming mask
		if gateway_active and not is_transitioning and player.global_position.x >= 1850.0:
			transition_to_overworld()
	
	# Area title fade
	if area_title_timer > 0.0:
		area_title_timer -= delta
		var alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
		if area_title_label:
			area_title_label.modulate.a = alpha

func trigger_area_discovery(text_title: String) -> void:
	if area_title_label:
		area_title_label.text = text_title
		area_title_timer = 3.2
		area_title_label.modulate.a = 1.0

func _on_weapon_selected(w_name: String) -> void:
	if weapon_badge_label:
		weapon_badge_label.text = "⚔ Weapon: %s" % w_name
		weapon_badge_label.modulate = Color(1.5, 1.3, 0.5, 1.0)
		get_tree().create_timer(0.5).timeout.connect(func():
			if weapon_badge_label:
				weapon_badge_label.modulate = Color(1, 1, 1, 1)
		)

func _on_mask_claimed() -> void:
	gateway_active = true
	if exit_wall:
		exit_wall.position = Vector2(LEVEL_WIDTH + 200, 0)
	trigger_area_discovery("✦ PATH TO THE OVERWORLD UNLOCKED ✦")

func transition_to_overworld() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	if player and player.has_method("start_walk_off"):
		player.start_walk_off()
	var fade_rect = ColorRect.new()
	fade_rect.size = Vector2(640, 360)
	fade_rect.color = Color(0, 0, 0, 0)
	ui_layer.add_child(fade_rect)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.50)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)

func _on_player_died() -> void:
	if player:
		player.global_position = PLAYER_SPAWN_POS
		player.velocity = Vector2.ZERO
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()

func _on_player_hp_changed(current: int, _max_hp: int) -> void:
	for i in range(hp_segments.size()):
		hp_segments[i].color = Color(0.66, 0.12, 0.18, 1.0) if i < current else Color(0.12, 0.10, 0.12, 0.90)

func _on_player_stamina_changed(current: float, max_stamina: float) -> void:
	if stamina_bar_fill:
		var ratio = clamp(current / max_stamina, 0.0, 1.0)
		stamina_bar_fill.size.x = 120.0 * ratio

class_name LevelBuilder
extends RefCounted

const AssetsScript = preload("res://scripts/assets.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const WaterHazardScript = preload("res://scripts/water_hazard.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")

const FLOOR_TILES_TEX = preload("res://assets/platform_assets/Floor Tiles1.png")
const OTHER_TILES_TEX = preload("res://assets/platform_assets/Other Tiles1.png")
const WATER_TILES_TEX = preload("res://assets/platform_assets/Animated Sprites/animated_water_tiles.png")
const WIND_SHADER = preload("res://shaders/foliage_wind.gdshader")

# Trees & Props
const NARRA_1_TEX = preload("res://assets/foliage/narra_tree_1.png")
const NARRA_2_TEX = preload("res://assets/foliage/narra_tree_2.png")
const NARRA_3_TEX = preload("res://assets/foliage/narra_tree_3.png")
const NARRA_4_TEX = preload("res://assets/foliage/narra_tree_4.png")
const NARRA_5_TEX = preload("res://assets/foliage/narra_tree_5.png")
const TREE1_TEX = preload("res://assets/platform_assets/Tree1.png")
const TREE2_TEX = preload("res://assets/platform_assets/Tree2.png")
const BIRCH1_TEX = preload("res://assets/platform_assets/Birch1.png")
const BIRCH2_TEX = preload("res://assets/platform_assets/Birch2.png")
const WILLOW_TEX = preload("res://assets/platform_assets/Weeping Willow1.png")
const BALETE_TEX = preload("res://assets/bahay_kubo/balete_tree.png")
const BANANA_TEX = preload("res://assets/bahay_kubo/prop_banana_tree.png")
const FENCE_TEX = preload("res://assets/bahay_kubo/prop_wooden_fence.png")
const FIREWOOD_TEX = preload("res://assets/bahay_kubo/prop_firewood.png")
const ROCKS_TEX = preload("res://assets/bahay_kubo/prop_mossy_rocks.png")
const HOUSE_TEX = preload("res://assets/bahay_kubo/bahay_kubo_house.png")
const WHEAT_TEX = preload("res://assets/platform_assets/Pixel Art Wheat.png")
const GRASS_TEX = preload("res://assets/platform_assets/Tall Grass.png")
const ROOSTER_TEX = preload("res://assets/bahay_kubo/prop_rooster.png")

static func build_level(root: Node2D, level_idx: int, theme: String) -> void:
	var wind_mat := ShaderMaterial.new()
	wind_mat.shader = WIND_SHADER
	wind_mat.set_shader_parameter("wind_speed", 1.8)
	wind_mat.set_shader_parameter("wind_strength", 4.5)
	wind_mat.set_shader_parameter("wind_detail", 2.0)
	
	# Layout definition per level
	var level_config = get_level_layout(level_idx, theme)
	
	# 1. Build Ground Segments with Elevation Changes
	build_ground_segments(root, level_config["ground_segments"], theme)
	
	# 2. Build Water Gaps & Hazards
	build_water_gaps(root, level_config["water_gaps"])
	
	# 3. Build Elevated Platforms (One-Way Colliders)
	build_platforms(root, level_config["platforms"], theme)
	
	# 4. Populate Thematic Foliage & Trees (with wind shader)
	populate_foliage(root, level_config["foliage"], wind_mat)
	
	# 5. Populate Rural / Environmental Props
	populate_props(root, level_config["props"])
	
	# 6. Place Lighting (Torches & Lanterns)
	place_torches(root, level_config["torches"])
	
	# 7. Place Breakable Palayok Pots
	place_breakables(root, level_config["pots"])

static func get_level_layout(level_idx: int, theme: String) -> Dictionary:
	var is_forest = (theme == "Forest" or theme == "Rainy Forest")
	var sub_lvl = (level_idx % 3) + 1 # 1, 2, or 3
	
	var ground: Array[Dictionary] = []
	var water: Array[Dictionary] = []
	var plats: Array[Dictionary] = []
	var foliage: Array[Dictionary] = []
	var props: Array[Dictionary] = []
	var torches: Array[Dictionary] = []
	var pots: Array[Vector2] = []
	
	if is_forest:
		if sub_lvl == 1: # Level 1-1: Forest Entry - Gentle hills & stepping ledges
			ground = [
				{"start_x": 0.0, "end_x": 1600.0, "y": 300.0},
				{"start_x": 1600.0, "end_x": 2800.0, "y": 268.0}, # Raised ridge
				{"start_x": 2800.0, "end_x": 5120.0, "y": 300.0}
			]
			water = [
				{"x": 2720.0, "w": 80.0, "y": 310.0}
			]
			plats = [
				{"x": 600.0, "y": 236.0, "w": 160.0},
				{"x": 1100.0, "y": 220.0, "w": 192.0},
				{"x": 2000.0, "y": 190.0, "w": 160.0},
				{"x": 3400.0, "y": 220.0, "w": 224.0},
				{"x": 4200.0, "y": 236.0, "w": 160.0}
			]
			foliage = [
				{"type": "narra_1", "x": 250.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_2", "x": 650.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_3", "x": 1150.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_4", "x": 1650.0, "y": 268.0, "scale": 1.0},
				{"type": "narra_5", "x": 2200.0, "y": 268.0, "scale": 1.0},
				{"type": "narra_2", "x": 2900.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_1", "x": 3600.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_3", "x": 4100.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_4", "x": 4650.0, "y": 300.0, "scale": 1.0}
			]
			props = [
				{"type": "rocks", "x": 380.0, "y": 300.0},
				{"type": "firewood", "x": 1050.0, "y": 300.0},
				{"type": "rocks", "x": 1950.0, "y": 268.0},
				{"type": "rocks", "x": 3600.0, "y": 300.0}
			]
			torches = [
				{"type": "torch", "x": 320.0, "y": 300.0},
				{"type": "torch", "x": 1100.0, "y": 220.0},
				{"type": "torch", "x": 2650.0, "y": 268.0},
				{"type": "torch", "x": 3400.0, "y": 220.0},
				{"type": "torch", "x": 4800.0, "y": 300.0}
			]
			pots = [
				Vector2(650.0, 236.0),
				Vector2(1150.0, 220.0),
				Vector2(2050.0, 190.0),
				Vector2(3450.0, 220.0)
			]
		elif sub_lvl == 2: # Level 1-2: Forest Ascent - High scaffolding, multiple water streams
			ground = [
				{"start_x": 0.0, "end_x": 1300.0, "y": 300.0},
				{"start_x": 1400.0, "end_x": 2600.0, "y": 268.0},
				{"start_x": 2720.0, "end_x": 3900.0, "y": 236.0}, # High plateau
				{"start_x": 4020.0, "end_x": 5120.0, "y": 300.0}
			]
			water = [
				{"x": 1300.0, "w": 100.0, "y": 315.0},
				{"x": 2600.0, "w": 120.0, "y": 315.0},
				{"x": 3900.0, "w": 120.0, "y": 315.0}
			]
			plats = [
				{"x": 450.0, "y": 220.0, "w": 160.0},
				{"x": 1310.0, "y": 240.0, "w": 80.0}, # Bridge over water 1
				{"x": 1750.0, "y": 180.0, "w": 192.0},
				{"x": 2610.0, "y": 200.0, "w": 100.0}, # Bridge over water 2
				{"x": 3100.0, "y": 150.0, "w": 224.0},
				{"x": 3910.0, "y": 240.0, "w": 100.0}, # Bridge over water 3
				{"x": 4400.0, "y": 210.0, "w": 192.0}
			]
			foliage = [
				{"type": "narra_4", "x": 250.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_5", "x": 750.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_1", "x": 1700.0, "y": 268.0, "scale": 1.0},
				{"type": "narra_3", "x": 2300.0, "y": 268.0, "scale": 1.0},
				{"type": "narra_2", "x": 3000.0, "y": 236.0, "scale": 1.0},
				{"type": "narra_5", "x": 3600.0, "y": 236.0, "scale": 1.0},
				{"type": "narra_3", "x": 4300.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_1", "x": 4750.0, "y": 300.0, "scale": 1.0}
			]
			props = [
				{"type": "rocks", "x": 600.0, "y": 300.0},
				{"type": "firewood", "x": 1800.0, "y": 268.0},
				{"type": "rocks", "x": 3200.0, "y": 236.0},
				{"type": "rocks", "x": 4350.0, "y": 300.0}
			]
			torches = [
				{"type": "torch", "x": 1280.0, "y": 300.0},
				{"type": "torch", "x": 1750.0, "y": 180.0},
				{"type": "torch", "x": 2580.0, "y": 268.0},
				{"type": "torch", "x": 3100.0, "y": 150.0},
				{"type": "torch", "x": 3880.0, "y": 236.0},
				{"type": "torch", "x": 4850.0, "y": 300.0}
			]
			pots = [
				Vector2(480.0, 220.0),
				Vector2(1800.0, 180.0),
				Vector2(3150.0, 150.0),
				Vector2(4450.0, 210.0)
			]
		else: # Level 1-3: Deep Corrupted Forest - High ruins, dense ambushes
			ground = [
				{"start_x": 0.0, "end_x": 1100.0, "y": 300.0},
				{"start_x": 1250.0, "end_x": 2200.0, "y": 256.0},
				{"start_x": 2360.0, "end_x": 3500.0, "y": 224.0},
				{"start_x": 3650.0, "end_x": 5120.0, "y": 288.0}
			]
			water = [
				{"x": 1100.0, "w": 150.0, "y": 315.0},
				{"x": 2200.0, "w": 160.0, "y": 315.0},
				{"x": 3500.0, "w": 150.0, "y": 315.0}
			]
			plats = [
				{"x": 500.0, "y": 210.0, "w": 192.0},
				{"x": 1120.0, "y": 220.0, "w": 110.0},
				{"x": 1600.0, "y": 160.0, "w": 224.0},
				{"x": 2220.0, "y": 170.0, "w": 120.0},
				{"x": 2700.0, "y": 130.0, "w": 256.0},
				{"x": 3520.0, "y": 210.0, "w": 110.0},
				{"x": 4100.0, "y": 190.0, "w": 224.0}
			]
			foliage = [
				{"type": "narra_5", "x": 300.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_2", "x": 850.0, "y": 300.0, "scale": 1.0},
				{"type": "narra_4", "x": 1400.0, "y": 256.0, "scale": 1.0},
				{"type": "narra_3", "x": 1800.0, "y": 256.0, "scale": 1.0},
				{"type": "narra_1", "x": 2600.0, "y": 224.0, "scale": 1.0},
				{"type": "narra_2", "x": 3100.0, "y": 224.0, "scale": 1.0},
				{"type": "narra_3", "x": 3900.0, "y": 288.0, "scale": 1.0},
				{"type": "narra_5", "x": 4500.0, "y": 288.0, "scale": 1.0}
			]
			props = [
				{"type": "rocks", "x": 420.0, "y": 300.0},
				{"type": "rocks", "x": 1400.0, "y": 256.0},
				{"type": "firewood", "x": 2800.0, "y": 224.0},
				{"type": "rocks", "x": 3900.0, "y": 288.0}
			]
			torches = [
				{"type": "torch", "x": 280.0, "y": 300.0},
				{"type": "torch", "x": 1600.0, "y": 160.0},
				{"type": "torch", "x": 2700.0, "y": 130.0},
				{"type": "torch", "x": 4100.0, "y": 190.0},
				{"type": "torch", "x": 4850.0, "y": 288.0}
			]
			pots = [
				Vector2(550.0, 210.0),
				Vector2(1650.0, 160.0),
				Vector2(2750.0, 130.0),
				Vector2(4150.0, 190.0)
			]
	else: # Rice Field Theme
		if sub_lvl == 1: # Level 2-1: Rice Field - Terraces & Irrigation Ditches
			ground = [
				{"start_x": 0.0, "end_x": 1800.0, "y": 300.0},
				{"start_x": 1920.0, "end_x": 3300.0, "y": 268.0}, # Stepped terrace
				{"start_x": 3440.0, "end_x": 5120.0, "y": 300.0}
			]
			water = [
				{"x": 1800.0, "w": 120.0, "y": 312.0},
				{"x": 3300.0, "w": 140.0, "y": 312.0}
			]
			plats = [
				{"x": 700.0, "y": 236.0, "w": 160.0},
				{"x": 1810.0, "y": 250.0, "w": 100.0}, # Footbridge over ditch 1
				{"x": 2300.0, "y": 200.0, "w": 192.0},
				{"x": 3310.0, "y": 240.0, "w": 120.0}, # Footbridge over ditch 2
				{"x": 4100.0, "y": 236.0, "w": 192.0}
			]
			foliage = [
				{"type": "banana", "x": 280.0, "y": 300.0, "scale": 0.75},
				{"type": "wheat_strip", "x": 400.0, "y": 300.0, "len": 1200.0},
				{"type": "banana", "x": 1650.0, "y": 300.0, "scale": 0.8},
				{"type": "wheat_strip", "x": 2000.0, "y": 268.0, "len": 1200.0},
				{"type": "banana", "x": 3150.0, "y": 268.0, "scale": 0.8},
				{"type": "wheat_strip", "x": 3500.0, "y": 300.0, "len": 1300.0}
			]
			props = [
				{"type": "fence", "x": 500.0, "y": 300.0},
				{"type": "firewood", "x": 1000.0, "y": 300.0},
				{"type": "rooster", "x": 550.0, "y": 290.0},
				{"type": "fence", "x": 2200.0, "y": 268.0},
				{"type": "fence", "x": 3800.0, "y": 300.0}
			]
			torches = [
				{"type": "lantern", "x": 380.0, "y": 300.0},
				{"type": "lantern", "x": 1780.0, "y": 300.0},
				{"type": "lantern", "x": 2300.0, "y": 200.0},
				{"type": "lantern", "x": 3280.0, "y": 268.0},
				{"type": "lantern", "x": 4850.0, "y": 300.0}
			]
			pots = [
				Vector2(750.0, 236.0),
				Vector2(1020.0, 300.0),
				Vector2(2350.0, 200.0),
				Vector2(4150.0, 236.0)
			]
		elif sub_lvl == 2: # Level 2-2: Stilt Farmstead & Village Roofs
			ground = [
				{"start_x": 0.0, "end_x": 1200.0, "y": 300.0},
				{"start_x": 1350.0, "end_x": 2500.0, "y": 268.0},
				{"start_x": 2650.0, "end_x": 3800.0, "y": 300.0},
				{"start_x": 3950.0, "end_x": 5120.0, "y": 268.0}
			]
			water = [
				{"x": 1200.0, "w": 150.0, "y": 315.0},
				{"x": 2500.0, "w": 150.0, "y": 315.0},
				{"x": 3800.0, "w": 150.0, "y": 315.0}
			]
			plats = [
				{"x": 550.0, "y": 210.0, "w": 192.0},
				{"x": 1220.0, "y": 230.0, "w": 110.0},
				{"x": 1750.0, "y": 170.0, "w": 256.0}, # Bahay Kubo porch/roof platform
				{"x": 2520.0, "y": 230.0, "w": 110.0},
				{"x": 3050.0, "y": 190.0, "w": 224.0},
				{"x": 3820.0, "y": 220.0, "w": 110.0},
				{"x": 4400.0, "y": 180.0, "w": 224.0}
			]
			foliage = [
				{"type": "banana", "x": 200.0, "y": 300.0, "scale": 0.8},
				{"type": "wheat_strip", "x": 300.0, "y": 300.0, "len": 800.0},
				{"type": "wheat_strip", "x": 1400.0, "y": 268.0, "len": 1000.0},
				{"type": "banana", "x": 2400.0, "y": 268.0, "scale": 0.8},
				{"type": "wheat_strip", "x": 2700.0, "y": 300.0, "len": 1000.0},
				{"type": "banana", "x": 4100.0, "y": 268.0, "scale": 0.8}
			]
			props = [
				{"type": "house", "x": 1800.0, "y": 268.0}, # Actual Bahay Kubo home!
				{"type": "fence", "x": 700.0, "y": 300.0},
				{"type": "firewood", "x": 1650.0, "y": 268.0},
				{"type": "rooster", "x": 1950.0, "y": 268.0},
				{"type": "fence", "x": 3300.0, "y": 300.0}
			]
			torches = [
				{"type": "lantern", "x": 450.0, "y": 300.0},
				{"type": "lantern", "x": 1180.0, "y": 300.0},
				{"type": "lantern", "x": 1750.0, "y": 170.0},
				{"type": "lantern", "x": 2480.0, "y": 268.0},
				{"type": "lantern", "x": 3050.0, "y": 190.0},
				{"type": "lantern", "x": 4850.0, "y": 268.0}
			]
			pots = [
				Vector2(580.0, 210.0),
				Vector2(1780.0, 170.0),
				Vector2(3100.0, 190.0),
				Vector2(4450.0, 180.0)
			]
		else: # Level 2-3: The Mayon Crossing - Perilous river crossings & gauntlet
			ground = [
				{"start_x": 0.0, "end_x": 1000.0, "y": 300.0},
				{"start_x": 1180.0, "end_x": 2100.0, "y": 268.0},
				{"start_x": 2300.0, "end_x": 3300.0, "y": 236.0},
				{"start_x": 3500.0, "end_x": 5120.0, "y": 288.0}
			]
			water = [
				{"x": 1000.0, "w": 180.0, "y": 315.0},
				{"x": 2100.0, "w": 200.0, "y": 315.0},
				{"x": 3300.0, "w": 200.0, "y": 315.0}
			]
			plats = [
				{"x": 450.0, "y": 210.0, "w": 192.0},
				{"x": 1030.0, "y": 240.0, "w": 120.0}, # Stepping log 1
				{"x": 1500.0, "y": 170.0, "w": 224.0},
				{"x": 2130.0, "y": 200.0, "w": 140.0}, # Stepping log 2
				{"x": 2600.0, "y": 140.0, "w": 256.0},
				{"x": 3330.0, "y": 220.0, "w": 140.0}, # Stepping log 3
				{"x": 4000.0, "y": 180.0, "w": 256.0}
			]
			foliage = [
				{"type": "banana", "x": 220.0, "y": 300.0, "scale": 0.85},
				{"type": "wheat_strip", "x": 350.0, "y": 300.0, "len": 600.0},
				{"type": "wheat_strip", "x": 1250.0, "y": 268.0, "len": 800.0},
				{"type": "banana", "x": 2000.0, "y": 268.0, "scale": 0.85},
				{"type": "wheat_strip", "x": 2350.0, "y": 236.0, "len": 900.0},
				{"type": "banana", "x": 3200.0, "y": 236.0, "scale": 0.85},
				{"type": "wheat_strip", "x": 3600.0, "y": 288.0, "len": 1200.0}
			]
			props = [
				{"type": "fence", "x": 550.0, "y": 300.0},
				{"type": "firewood", "x": 1400.0, "y": 268.0},
				{"type": "fence", "x": 2500.0, "y": 236.0},
				{"type": "rocks", "x": 3700.0, "y": 288.0}
			]
			torches = [
				{"type": "lantern", "x": 350.0, "y": 300.0},
				{"type": "lantern", "x": 980.0, "y": 300.0},
				{"type": "lantern", "x": 1500.0, "y": 170.0},
				{"type": "lantern", "x": 2080.0, "y": 268.0},
				{"type": "lantern", "x": 2600.0, "y": 140.0},
				{"type": "lantern", "x": 3280.0, "y": 236.0},
				{"type": "lantern", "x": 4000.0, "y": 180.0},
				{"type": "lantern", "x": 4850.0, "y": 288.0}
			]
			pots = [
				Vector2(480.0, 210.0),
				Vector2(1550.0, 170.0),
				Vector2(2650.0, 140.0),
				Vector2(4050.0, 180.0)
			]
	
	return {
		"ground_segments": ground,
		"water_gaps": water,
		"platforms": plats,
		"foliage": foliage,
		"props": props,
		"torches": torches,
		"pots": pots
	}

# ── Ground Builder ─────────────────────────────────────────────────────────────
static func build_ground_segments(root: Node2D, segments: Array[Dictionary], theme: String) -> void:
	var ground_container := Node2D.new()
	ground_container.name = "GroundSegments"
	root.add_child(ground_container)
	
	var is_forest = (theme == "Forest")
	# Row 0 = grass/earth, Row 6 = wood/deck
	var top_row = 0 if is_forest else 0
	
	for seg in segments:
		var start_x: float = seg["start_x"]
		var end_x: float = seg["end_x"]
		var ground_y: float = seg["y"]
		var width: float = end_x - start_x
		
		# Solid static body
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		# Deep collision box extending below screen
		shape.size = Vector2(width, 160.0)
		col.shape = shape
		col.position = Vector2(start_x + width * 0.5, ground_y + 80.0)
		body.add_child(col)
		ground_container.add_child(body)
		
		# Visual tile sprites
		var num_tiles: int = int(ceil(width / 32.0))
		for i in range(num_tiles):
			var tile_x: float = start_x + i * 32.0 + 16.0
			if tile_x > end_x:
				break
			
			# Surface tile
			var spr_top := Sprite2D.new()
			spr_top.texture = FLOOR_TILES_TEX
			spr_top.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr_top.region_enabled = true
			spr_top.region_rect = Rect2(0, top_row * 32, 32, 32)
			spr_top.position = Vector2(tile_x, ground_y + 16.0)
			spr_top.z_index = -1
			ground_container.add_child(spr_top)
			
			# Subsurface dirt tiles (fill down to bottom of screen)
			for sub_y in range(1, 4):
				var spr_sub := Sprite2D.new()
				spr_sub.texture = FLOOR_TILES_TEX
				spr_sub.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				spr_sub.region_enabled = true
				spr_sub.region_rect = Rect2(0, (top_row + 1) * 32, 32, 32)
				spr_sub.position = Vector2(tile_x, ground_y + 16.0 + sub_y * 32.0)
				spr_sub.z_index = -1
				ground_container.add_child(spr_sub)

# ── Water Hazards ─────────────────────────────────────────────────────────────
static func build_water_gaps(root: Node2D, gaps: Array[Dictionary]) -> void:
	var water_container := Node2D.new()
	water_container.name = "WaterGaps"
	root.add_child(water_container)
	
	for gap in gaps:
		var gx: float = gap["x"]
		var gw: float = gap["w"]
		var gy: float = gap["y"]
		
		# Water hazard trigger
		var hazard = WaterHazardScript.new(gw, 64.0)
		hazard.position = Vector2(gx, gy)
		water_container.add_child(hazard)
		
		# Visual animated water tiles
		var tiles_count = int(ceil(gw / 32.0))
		for i in range(tiles_count):
			var w_spr := Sprite2D.new()
			w_spr.texture = WATER_TILES_TEX
			w_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			w_spr.hframes = 20
			w_spr.vframes = 11
			w_spr.frame = 0
			w_spr.position = Vector2(gx + i * 32.0 + 16.0, gy + 16.0)
			w_spr.z_index = -1
			water_container.add_child(w_spr)
			
			# Animate ripple cycle
			var frame_offset = randi() % 20
			var anim_tween = w_spr.create_tween().set_loops()
			for f in range(20):
				anim_tween.tween_callback(func(spr=w_spr, frm=(f + frame_offset) % 20): if is_instance_valid(spr): spr.frame = frm).set_delay(0.12)

# ── Elevated Platforms (One-Way Collision) ────────────────────────────────────
static func build_platforms(root: Node2D, plats: Array[Dictionary], _theme: String) -> void:
	var plat_container := Node2D.new()
	plat_container.name = "ElevatedPlatforms"
	root.add_child(plat_container)
	
	for p in plats:
		var px: float = p["x"]
		var py: float = p["y"]
		var pw: float = p["w"]
		
		# One-way static body (can jump through from underneath!)
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(pw, 14.0)
		col.shape = shape
		col.position = Vector2(px + pw * 0.5, py + 7.0)
		col.one_way_collision = true
		body.add_child(col)
		plat_container.add_child(body)
		
		# Visual plank tiles
		var num_tiles: int = int(ceil(pw / 32.0))
		for i in range(num_tiles):
			var tx: float = px + i * 32.0 + 16.0
			var spr := Sprite2D.new()
			spr.texture = FLOOR_TILES_TEX
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.region_enabled = true
			# Row 6 is wood planks
			spr.region_rect = Rect2(0, 6 * 32, 32, 16)
			spr.position = Vector2(tx, py + 8.0)
			plat_container.add_child(spr)
		
		# Wooden support posts underneath
		var left_post := Sprite2D.new()
		left_post.texture = OTHER_TILES_TEX
		left_post.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		left_post.region_enabled = true
		left_post.region_rect = Rect2(6 * 32, 0, 16, 48)
		left_post.position = Vector2(px + 16.0, py + 32.0)
		left_post.z_index = -2
		plat_container.add_child(left_post)
		
		var right_post := Sprite2D.new()
		right_post.texture = OTHER_TILES_TEX
		right_post.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		right_post.region_enabled = true
		right_post.region_rect = Rect2(6 * 32, 0, 16, 48)
		right_post.position = Vector2(px + pw - 16.0, py + 32.0)
		right_post.z_index = -2
		plat_container.add_child(right_post)

# ── Foliage & Wind Shader ──────────────────────────────────────────────────────
static func populate_foliage(root: Node2D, foliage_list: Array[Dictionary], wind_mat: Material) -> void:
	var foliage_container := Node2D.new()
	foliage_container.name = "FoliageAndTrees"
	root.add_child(foliage_container)
	
	for item in foliage_list:
		var type: String = item["type"]
		
		if type == "wheat_strip":
			var wx: float = item["x"]
			var wy: float = item["y"]
			var wlen: float = item["len"]
			var count: int = int(wlen / 64.0)
			for i in range(count):
				var stalk := Sprite2D.new()
				stalk.texture = WHEAT_TEX
				stalk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				stalk.material = wind_mat
				stalk.position = Vector2(wx + i * 64.0, wy - 16.0)
				stalk.z_index = 2 if (i % 2 == 0) else -1 # Interweave foreground and background
				foliage_container.add_child(stalk)
			continue
		
		var spr := Sprite2D.new()
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.material = wind_mat
		spr.z_index = -2 # Background foliage behind combat
		
		var pos_x: float = item["x"]
		var pos_y: float = item["y"]
		var s: float = item.get("scale", 1.0)
		spr.scale = Vector2(s, s)
		
		match type:
			"narra_1":
				spr.texture = NARRA_1_TEX
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				spr.offset = Vector2(0, -512)
				spr.scale = Vector2(0.30 * s, 0.30 * s)
				spr.position = Vector2(pos_x, pos_y)
			"narra_2":
				spr.texture = NARRA_2_TEX
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				spr.offset = Vector2(0, -400)
				spr.scale = Vector2(0.36 * s, 0.36 * s)
				spr.position = Vector2(pos_x, pos_y)
			"narra_3":
				spr.texture = NARRA_3_TEX
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				spr.offset = Vector2(0, -424)
				spr.scale = Vector2(0.35 * s, 0.35 * s)
				spr.position = Vector2(pos_x, pos_y)
			"narra_4":
				spr.texture = NARRA_4_TEX
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				spr.offset = Vector2(0, -387.5)
				spr.scale = Vector2(0.37 * s, 0.37 * s)
				spr.position = Vector2(pos_x, pos_y)
			"narra_5":
				spr.texture = NARRA_5_TEX
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				spr.offset = Vector2(0, -439)
				spr.scale = Vector2(0.34 * s, 0.34 * s)
				spr.position = Vector2(pos_x, pos_y)
			"balete":
				spr.texture = BALETE_TEX
				spr.position = Vector2(pos_x, pos_y - 120.0 * s)
			"birch":
				spr.texture = BIRCH1_TEX
				spr.position = Vector2(pos_x, pos_y - 80.0 * s)
			"tree1":
				spr.texture = TREE1_TEX
				spr.position = Vector2(pos_x, pos_y - 95.0 * s)
			"tree2":
				spr.texture = TREE2_TEX
				spr.position = Vector2(pos_x, pos_y - 95.0 * s)
			"willow":
				spr.texture = WILLOW_TEX
				spr.position = Vector2(pos_x, pos_y - 100.0 * s)
			"banana":
				spr.texture = BANANA_TEX
				spr.scale = Vector2(0.5 * s, 0.5 * s)
				spr.position = Vector2(pos_x, pos_y - 48.0 * s)
		
		foliage_container.add_child(spr)

# ── Environmental Props ────────────────────────────────────────────────────────
static func populate_props(root: Node2D, props_list: Array[Dictionary]) -> void:
	var props_container := Node2D.new()
	props_container.name = "LevelProps"
	root.add_child(props_container)
	
	for item in props_list:
		var type: String = item["type"]
		var px: float = item["x"]
		var py: float = item["y"]
		
		var spr := Sprite2D.new()
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		match type:
			"house":
				spr.texture = HOUSE_TEX
				spr.scale = Vector2(0.5, 0.5)
				spr.position = Vector2(px, py - 95.0)
				spr.z_index = -2
			"fence":
				spr.texture = FENCE_TEX
				spr.scale = Vector2(0.5, 0.5)
				spr.position = Vector2(px, py - 20.0)
				spr.z_index = -1
			"firewood":
				spr.texture = FIREWOOD_TEX
				spr.scale = Vector2(0.5, 0.5)
				spr.position = Vector2(px, py - 14.0)
				spr.z_index = -1
			"rocks":
				spr.texture = ROCKS_TEX
				spr.scale = Vector2(0.45, 0.45)
				spr.position = Vector2(px, py - 14.0)
				spr.z_index = -1
			"rooster":
				spr.texture = ROOSTER_TEX
				spr.scale = Vector2(0.45, 0.45)
				spr.position = Vector2(px, py - 10.0)
				spr.z_index = 0
		
		props_container.add_child(spr)

# ── Torches & Lanterns ─────────────────────────────────────────────────────────
static func place_torches(root: Node2D, torch_list: Array[Dictionary]) -> void:
	var torch_container := Node2D.new()
	torch_container.name = "LevelTorches"
	root.add_child(torch_container)
	
	for item in torch_list:
		var t_type = EnvironmentTorch.Type.TORCH if item["type"] == "torch" else EnvironmentTorch.Type.LANTERN
		var torch = EnvironmentTorchScript.new()
		torch.torch_type = t_type
		torch.position = Vector2(item["x"], item["y"])
		torch_container.add_child(torch)

# ── Breakable Clay Pots ───────────────────────────────────────────────────────
static func place_breakables(root: Node2D, pot_positions: Array[Vector2]) -> void:
	var pots_container := Node2D.new()
	pots_container.name = "BreakablePots"
	root.add_child(pots_container)
	
	for pos in pot_positions:
		var pot = PalayokPotScript.new()
		pot.position = pos
		pots_container.add_child(pot)

# ── Enemy Spawning (Pure Aswang Mythical Encounters) ───────────────────────────
static func spawn_enemies(container: Node2D, level_idx: int, theme: String, on_aswang_died: Callable, _on_skeleton_died: Callable = Callable()) -> void:
	for child in container.get_children():
		child.queue_free()
	
	var sub_lvl = (level_idx % 3) + 1
	var aswang_count = 3 + sub_lvl * 2 # 5, 7, 9
	if theme == "Rice Field":
		aswang_count += 2 # 7, 9, 11
	
	var x_min: float = 600.0
	var x_max: float = 4600.0
	if level_idx == 10:
		# Level 3-5: 4 sentinels along ascent, clearing x >= 3600 for Boss Arena
		aswang_count = 4
		x_max = 3400.0
	
	for j in range(aswang_count):
		var seg = (x_max - x_min) / float(aswang_count)
		var rx = randf_range(x_min + j * seg + 20.0, x_min + (j + 1) * seg - 20.0)
		var ry = 210.0 if (j % 2 == 1) else 260.0
		
		var aswang = AswangScript.new()
		aswang.global_position = Vector2(rx, ry)
		aswang.aswang_died.connect(on_aswang_died)
		container.add_child(aswang)

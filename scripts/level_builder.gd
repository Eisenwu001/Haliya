class_name LevelBuilder
extends RefCounted

const AssetsScript = preload("res://scripts/assets.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const ForestBruteMinibossScript = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardMinibossScript = preload("res://scripts/mayon_vanguard_miniboss.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const WaterHazardScript = preload("res://scripts/water_hazard.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")
const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const CavePogoCrystalScript = preload("res://scripts/cave_pogo_crystal.gd")
const CaveCrumbleLedgeScript = preload("res://scripts/cave_crumble_ledge.gd")
const CaveSpikeHazardScript = preload("res://scripts/cave_spike_hazard.gd")

const FLOOR_TILES_TEX = preload("res://assets/platform_assets/Floor Tiles1.png")
const FOREST_DIRT_ROOTS_TEX = preload("res://assets/platform_assets/forest_dirt_roots.png")
const OTHER_TILES_TEX = preload("res://assets/platform_assets/Other Tiles1.png")
const FLOOR_TILES_2_TEX = preload("res://assets/platform_assets/Floor Tiles2.png")
const OTHER_TILES_2_TEX = preload("res://assets/platform_assets/Other Tiles2.png")
const ORES_TEX = preload("res://assets/platform_assets/Ores.png")
const BG_DIRT_2_TEX = preload("res://assets/platform_assets/BG Dirt2.png")
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
	wind_mat.set_shader_parameter("wind_speed", 1.4)
	wind_mat.set_shader_parameter("wind_strength", 1.6)
	wind_mat.set_shader_parameter("wind_detail", 2.0)
	
	# Layout definition per level
	var level_config = get_level_layout(level_idx, theme)
	
	# 1. Build Ground Segments with Elevation Changes
	build_ground_segments(root, level_config["ground_segments"], theme)
	
	# 2. Build Water Gaps & Subterranean Crystal Spike Hazards
	build_water_gaps(root, level_config["water_gaps"])
	build_cave_spikes(root, level_config.get("spike_hazards", []))
	
	# 3. Build Elevated Platforms & Crumbling Stone Ledges
	build_platforms(root, level_config["platforms"], theme)
	
	# 4. Build Hollow Knight Resonant Pogo Crystal Blooms
	build_pogo_crystals(root, level_config.get("pogo_crystals", []))
	
	# 5. Populate Thematic Foliage & Trees (with wind shader)
	populate_foliage(root, level_config["foliage"], wind_mat)
	
	# 6. Populate Rural / Subterranean Environmental Props
	populate_props(root, level_config["props"])
	
	# 7. Place Lighting (Torches & Lanterns)
	place_torches(root, level_config["torches"])
	
	# 8. Place Breakable Palayok Pots
	place_breakables(root, level_config["pots"])

static func get_level_layout(level_idx: int, theme: String) -> Dictionary:
	var is_forest = (theme == "Forest" or theme == "Rainy Forest")
	var sub_lvl = (level_idx % 3) + 1 # 1, 2, or 3
	
	var ground: Array[Dictionary] = []
	var water: Array[Dictionary] = []
	var spikes: Array[Dictionary] = []
	var plats: Array[Dictionary] = []
	var pogo_crystals: Array[Vector2] = []
	var foliage: Array[Dictionary] = []
	var props: Array[Dictionary] = []
	var torches: Array[Dictionary] = []
	var pots: Array[Vector2] = []
	
	if theme == "Cave":
		# Level 4: The Lapis Depths — Multi-tiered Hollow Knight Subterranean Platforming Gauntlet
		ground = [
			{"start_x": 0.0, "end_x": 864.0, "y": 292.0},
			{"start_x": 1120.0, "end_x": 1920.0, "y": 256.0},
			{"start_x": 2368.0, "end_x": 3232.0, "y": 228.0},
			{"start_x": 3744.0, "end_x": 4320.0, "y": 264.0},
			{"start_x": 4480.0, "end_x": 5120.0, "y": 280.0}
		]
		spikes = [
			{"x": 864.0, "w": 256.0, "y": 318.0, "respawn": Vector2(810.0, 260.0)},
			{"x": 1920.0, "w": 448.0, "y": 318.0, "respawn": Vector2(1870.0, 224.0)},
			{"x": 3232.0, "w": 512.0, "y": 318.0, "respawn": Vector2(3180.0, 196.0)},
			{"x": 4320.0, "w": 160.0, "y": 318.0, "respawn": Vector2(4270.0, 232.0)}
		]
		plats = [
			# Zone 1: Threshold ascent & upper overlook
			{"x": 460.0, "y": 228.0, "w": 96.0, "style": "island_md"},
			{"x": 640.0, "y": 172.0, "w": 128.0, "style": "island_lg"},
			{"x": 880.0, "y": 176.0, "w": 96.0, "style": "crumble"},
			# Zone 3: Twin-Tiered Ruins skyway
			{"x": 1240.0, "y": 192.0, "w": 128.0, "style": "bridge"},
			{"x": 1450.0, "y": 138.0, "w": 128.0, "style": "island_lg"},
			{"x": 1660.0, "y": 188.0, "w": 96.0, "style": "island_md"},
			# Zone 4: Crumbling Viaduct Gorge
			{"x": 1970.0, "y": 248.0, "w": 96.0, "style": "crumble"},
			{"x": 2190.0, "y": 212.0, "w": 96.0, "style": "crumble"},
			# Zone 5: High Hanging Citadel
			{"x": 2460.0, "y": 168.0, "w": 96.0, "style": "island_md"},
			{"x": 2640.0, "y": 148.0, "w": 128.0, "style": "bridge"},
			{"x": 2850.0, "y": 124.0, "w": 128.0, "style": "island_lg"},
			{"x": 3060.0, "y": 168.0, "w": 96.0, "style": "island_md"},
			# Zone 6: Abyssal Pogo Ascent mid-chasm island & crumbling ledge
			{"x": 3400.0, "y": 196.0, "w": 128.0, "style": "island_lg"},
			{"x": 3575.0, "y": 216.0, "w": 96.0, "style": "crumble"},
			# Zone 7: Deep Sanctum Approach
			{"x": 3920.0, "y": 196.0, "w": 128.0, "style": "island_lg"},
			{"x": 4140.0, "y": 152.0, "w": 96.0, "style": "island_md"},
			{"x": 4336.0, "y": 224.0, "w": 128.0, "style": "bridge"},
			{"x": 4660.0, "y": 208.0, "w": 128.0, "style": "island_lg"}
		]
		pogo_crystals = [
			Vector2(945.0, 268.0),
			Vector2(1045.0, 244.0),
			Vector2(2125.0, 236.0),
			Vector2(2315.0, 204.0),
			Vector2(3325.0, 224.0),
			Vector2(3695.0, 236.0),
			Vector2(4400.0, 260.0)
		]
		props = [
			{"type": "streetlamp", "x": 240.0, "y": 292.0},
			{"type": "lore_stele", "x": 380.0, "y": 292.0},
			{"type": "ore_blue", "x": 540.0, "y": 292.0},
			{"type": "ore_purple", "x": 790.0, "y": 292.0},
			{"type": "streetlamp", "x": 1170.0, "y": 256.0},
			{"type": "ore_gold", "x": 1380.0, "y": 256.0},
			{"type": "lore_stele", "x": 1514.0, "y": 138.0},
			{"type": "ore_blue", "x": 1760.0, "y": 256.0},
			{"type": "streetlamp", "x": 1860.0, "y": 256.0},
			{"type": "streetlamp", "x": 2410.0, "y": 228.0},
			{"type": "lore_stele", "x": 2700.0, "y": 228.0},
			{"type": "ore_gold", "x": 2914.0, "y": 124.0},
			{"type": "ore_purple", "x": 2980.0, "y": 228.0},
			{"type": "streetlamp", "x": 3180.0, "y": 228.0},
			{"type": "ore_blue", "x": 3464.0, "y": 196.0},
			{"type": "streetlamp", "x": 3790.0, "y": 264.0},
			{"type": "ore_purple", "x": 4080.0, "y": 264.0},
			{"type": "streetlamp", "x": 4270.0, "y": 264.0},
			{"type": "streetlamp", "x": 4540.0, "y": 280.0},
			{"type": "ore_blue", "x": 4780.0, "y": 280.0},
			{"type": "lore_stele", "x": 4890.0, "y": 280.0},
			{"type": "streetlamp", "x": 4980.0, "y": 280.0},
			{"type": "ceiling_stalactite", "x": 580.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 1280.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 2080.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 2820.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 3520.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 4380.0, "y": 0.0}
		]
		torches = [
			{"type": "torch", "x": 310.0, "y": 292.0},
			{"type": "torch", "x": 760.0, "y": 292.0},
			{"type": "torch", "x": 1320.0, "y": 256.0},
			{"type": "torch", "x": 1680.0, "y": 256.0},
			{"type": "torch", "x": 2560.0, "y": 228.0},
			{"type": "torch", "x": 3040.0, "y": 228.0},
			{"type": "torch", "x": 3960.0, "y": 264.0},
			{"type": "torch", "x": 4720.0, "y": 280.0}
		]
		pots = [
			Vector2(704.0, 172.0),
			Vector2(1485.0, 138.0),
			Vector2(2885.0, 124.0),
			Vector2(4188.0, 152.0),
			Vector2(4724.0, 208.0)
		]
	elif theme == "Cave Boss":
		# Level 5: Bakunawa's Abyss — Hollow Knight Suspension Ascent + Multi-Tiered Boss Sanctuary Arena
		ground = [
			{"start_x": 0.0, "end_x": 928.0, "y": 284.0},
			{"start_x": 1184.0, "end_x": 2080.0, "y": 252.0},
			{"start_x": 2432.0, "end_x": 3328.0, "y": 244.0},
			{"start_x": 3520.0, "end_x": 5120.0, "y": 280.0}
		]
		spikes = [
			{"x": 928.0, "w": 256.0, "y": 318.0, "respawn": Vector2(875.0, 252.0)},
			{"x": 2080.0, "w": 352.0, "y": 318.0, "respawn": Vector2(2025.0, 220.0)},
			{"x": 3328.0, "w": 192.0, "y": 318.0, "respawn": Vector2(3275.0, 212.0)}
		]
		plats = [
			# Section 1: Abyssal Processional & Suspension Gauntlet (x = 0..3520)
			{"x": 560.0, "y": 216.0, "w": 96.0, "style": "island_md"},
			{"x": 1055.0, "y": 228.0, "w": 96.0, "style": "crumble"},
			{"x": 1360.0, "y": 184.0, "w": 128.0, "style": "bridge"},
			{"x": 1580.0, "y": 138.0, "w": 128.0, "style": "island_lg"},
			{"x": 1800.0, "y": 184.0, "w": 96.0, "style": "island_md"},
			{"x": 2125.0, "y": 232.0, "w": 96.0, "style": "crumble"},
			{"x": 2310.0, "y": 196.0, "w": 96.0, "style": "island_md"},
			{"x": 2660.0, "y": 176.0, "w": 128.0, "style": "island_lg"},
			{"x": 2880.0, "y": 152.0, "w": 128.0, "style": "bridge"},
			{"x": 3080.0, "y": 180.0, "w": 128.0, "style": "island_lg"},
			{"x": 3360.0, "y": 204.0, "w": 128.0, "style": "bridge"},
			# Section 2: Bakunawa Multi-Tiered Sanctuary Boss Arena (x = 3760..5080)
			{"x": 3900.0, "y": 212.0, "w": 160.0, "style": "sanctuary"},
			{"x": 4145.0, "y": 156.0, "w": 96.0, "style": "island_md"},
			{"x": 4340.0, "y": 188.0, "w": 160.0, "style": "sanctuary"},
			{"x": 4595.0, "y": 156.0, "w": 96.0, "style": "island_md"},
			{"x": 4760.0, "y": 212.0, "w": 160.0, "style": "sanctuary"}
		]
		pogo_crystals = [
			Vector2(995.0, 256.0),
			Vector2(2265.0, 224.0),
			Vector2(3424.0, 248.0),
			# Boss Arena flank Pogo Crystals for aerial combat vs Bakunawa!
			Vector2(3825.0, 236.0),
			Vector2(4985.0, 236.0)
		]
		props = [
			{"type": "streetlamp", "x": 240.0, "y": 284.0},
			{"type": "lore_stele", "x": 410.0, "y": 284.0},
			{"type": "ore_blue", "x": 720.0, "y": 284.0},
			{"type": "streetlamp", "x": 860.0, "y": 284.0},
			{"type": "streetlamp", "x": 1240.0, "y": 252.0},
			{"type": "ore_purple", "x": 1520.0, "y": 252.0},
			{"type": "ore_gold", "x": 1644.0, "y": 138.0},
			{"type": "streetlamp", "x": 2010.0, "y": 252.0},
			{"type": "streetlamp", "x": 2490.0, "y": 244.0},
			{"type": "lore_stele", "x": 2820.0, "y": 244.0},
			{"type": "ore_blue", "x": 3144.0, "y": 180.0},
			{"type": "streetlamp", "x": 3260.0, "y": 244.0},
			# Checkpoint Shrine Promenade (x = 3520..3740)
			{"type": "streetlamp", "x": 3555.0, "y": 280.0},
			{"type": "streetlamp", "x": 3685.0, "y": 280.0},
			# Bakunawa Sanctuary Arena Props
			{"type": "lore_stele", "x": 3790.0, "y": 280.0},
			{"type": "ore_blue", "x": 3980.0, "y": 212.0},
			{"type": "streetlamp", "x": 4120.0, "y": 280.0},
			{"type": "ore_gold", "x": 4420.0, "y": 188.0},
			{"type": "streetlamp", "x": 4720.0, "y": 280.0},
			{"type": "ore_purple", "x": 4840.0, "y": 212.0},
			{"type": "lore_stele", "x": 5035.0, "y": 280.0},
			{"type": "ceiling_stalactite", "x": 640.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 1540.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 2740.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 3950.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 4420.0, "y": 0.0},
			{"type": "ceiling_stalactite", "x": 4880.0, "y": 0.0}
		]
		torches = [
			{"type": "torch", "x": 520.0, "y": 284.0},
			{"type": "torch", "x": 1440.0, "y": 252.0},
			{"type": "torch", "x": 1880.0, "y": 252.0},
			{"type": "torch", "x": 2680.0, "y": 244.0},
			{"type": "torch", "x": 3140.0, "y": 244.0},
			{"type": "torch", "x": 3860.0, "y": 280.0},
			{"type": "torch", "x": 4260.0, "y": 280.0},
			{"type": "torch", "x": 4580.0, "y": 280.0},
			{"type": "torch", "x": 4940.0, "y": 280.0}
		]
		pots = [
			Vector2(608.0, 216.0),
			Vector2(1620.0, 138.0),
			Vector2(2944.0, 152.0),
			Vector2(3580.0, 280.0)
		]
	elif is_forest:
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
		"spike_hazards": spikes,
		"platforms": plats,
		"pogo_crystals": pogo_crystals,
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
	
	var is_cave = (theme == "Cave" or theme == "Cave Boss")
	var is_forest = (theme == "Forest")
	var g_tex = CaveAssetsScript.get_rock_tiles_tex() if is_cave else FLOOR_TILES_TEX
	var top_row = 0 if is_forest else 0
	var cave_tint := Color(1.0, 1.0, 1.0, 1.0) if theme == "Cave" else Color(0.92, 0.94, 1.05, 1.0)
	
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
			spr_top.texture = g_tex
			spr_top.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr_top.region_enabled = true
			if is_cave:
				if i == 0:
					spr_top.region_rect = Rect2(0, 0, 32, 32)
				elif i == num_tiles - 1:
					spr_top.region_rect = Rect2(64, 0, 32, 32)
				elif i % 3 == 1:
					spr_top.region_rect = Rect2(128 + ((i / 3) % 4) * 32, 0, 32, 32)
				else:
					spr_top.region_rect = Rect2(32, 0, 32, 32)
				spr_top.modulate = cave_tint
			else:
				spr_top.region_rect = Rect2(0, top_row * 32, 32, 32)
			spr_top.position = Vector2(tile_x, ground_y + 16.0)
			spr_top.z_index = -1
			ground_container.add_child(spr_top)
			
			# Subsurface dirt/rock tiles (fill down to bottom of screen)
			for sub_y in range(1, 5):
				var spr_sub := Sprite2D.new()
				spr_sub.texture = g_tex
				spr_sub.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				spr_sub.region_enabled = true
				if is_cave:
					if sub_y == 4:
						if i == 0:
							spr_sub.region_rect = Rect2(0, 64, 32, 32)
						elif i == num_tiles - 1:
							spr_sub.region_rect = Rect2(64, 64, 32, 32)
						else:
							spr_sub.region_rect = Rect2(32, 64, 32, 32)
					else:
						if i == 0:
							spr_sub.region_rect = Rect2(0, 32, 32, 32)
						elif i == num_tiles - 1:
							spr_sub.region_rect = Rect2(64, 32, 32, 32)
						elif (i + sub_y) % 2 == 0:
							spr_sub.region_rect = Rect2(128 + ((i + sub_y) % 4) * 32, 32, 32, 32)
						else:
							spr_sub.region_rect = Rect2(32, 32, 32, 32)
					spr_sub.modulate = cave_tint.darkened(float(sub_y) * 0.08)
				else:
					spr_sub.texture = FOREST_DIRT_ROOTS_TEX
					var col_idx: int = (i + sub_y) % 4
					var row_idx: int = 0 if sub_y == 1 else (1 if sub_y == 2 else 2)
					spr_sub.region_rect = Rect2(col_idx * 32, row_idx * 32, 32, 32)
				spr_sub.position = Vector2(tile_x, ground_y + 16.0 + sub_y * 32.0)
				spr_sub.z_index = -1
				ground_container.add_child(spr_sub)
		
		# Carved Ancient Ruin Pillars supporting cliff edges in Cave
		if is_cave:
			if start_x > 32.0:
				var left_pillar := Sprite2D.new()
				left_pillar.texture = g_tex
				left_pillar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				left_pillar.region_enabled = true
				left_pillar.region_rect = Rect2(96, 0, 32, 96)
				left_pillar.position = Vector2(start_x + 16.0, ground_y + 64.0)
				left_pillar.z_index = -1
				ground_container.add_child(left_pillar)
			if end_x < 5080.0:
				var right_pillar := Sprite2D.new()
				right_pillar.texture = g_tex
				right_pillar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				right_pillar.region_enabled = true
				right_pillar.region_rect = Rect2(96, 0, 32, 96)
				right_pillar.position = Vector2(end_x - 16.0, ground_y + 64.0)
				right_pillar.z_index = -1
				ground_container.add_child(right_pillar)

# ── Subterranean Crystal Spike Hazards ─────────────────────────────────────────
static func build_cave_spikes(root: Node2D, spike_list: Array) -> void:
	if spike_list.is_empty():
		return
	var spikes_container := Node2D.new()
	spikes_container.name = "SpikeHazards"
	root.add_child(spikes_container)
	for sp in spike_list:
		var sx: float = sp["x"]
		var sw: float = sp["w"]
		var sy: float = sp.get("y", 318.0)
		var respawn_pos: Vector2 = sp.get("respawn", Vector2(max(120.0, sx - 48.0), 250.0))
		var hazard := CaveSpikeHazardScript.new(sw, respawn_pos)
		hazard.position = Vector2(sx, sy)
		spikes_container.add_child(hazard)

# ── Hollow Knight Resonant Pogo Crystal Blooms ─────────────────────────────────
static func build_pogo_crystals(root: Node2D, crystal_positions: Array) -> void:
	if crystal_positions.is_empty():
		return
	var crystal_container := Node2D.new()
	crystal_container.name = "PogoCrystals"
	root.add_child(crystal_container)
	for c_pos in crystal_positions:
		var crystal := CavePogoCrystalScript.new()
		crystal.position = c_pos
		crystal_container.add_child(crystal)

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
			
			# Animate ripple cycle (2x faster lively flow)
			var frame_offset = randi() % 20
			var anim_tween = w_spr.create_tween().set_loops()
			for f in range(20):
				anim_tween.tween_callback(func(spr=w_spr, frm=(f + frame_offset) % 20): if is_instance_valid(spr): spr.frame = frm).set_delay(0.06)

# ── Elevated Platforms (One-Way Collision & Hollow Knight Cave Islands) ───────
static func build_platforms(root: Node2D, plats: Array[Dictionary], _theme: String) -> void:
	var plat_container := Node2D.new()
	plat_container.name = "ElevatedPlatforms"
	root.add_child(plat_container)
	
	var is_cave = (_theme == "Cave" or _theme == "Cave Boss")
	var cave_plat_tex = CaveAssetsScript.get_platforms_tex() if is_cave else null
	var cave_props_tex = CaveAssetsScript.get_props_tex() if is_cave else null
	var cave_rock_tex = CaveAssetsScript.get_rock_tiles_tex() if is_cave else null
	
	for p in plats:
		var px: float = p["x"]
		var py: float = p["y"]
		var pw: float = p["w"]
		var style: String = p.get("style", "island_lg" if pw >= 120.0 else "island_md")
		
		# Interactive Crumbling Stone Ledge in Cave
		if is_cave and style == "crumble":
			var crumble := CaveCrumbleLedgeScript.new()
			crumble.position = Vector2(px, py)
			plat_container.add_child(crumble)
			continue
		
		# One-way static body (can jump through from underneath!)
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(pw, 12.0)
		col.shape = shape
		col.position = Vector2(px + pw * 0.5, py + 6.0)
		col.one_way_collision = true
		body.add_child(col)
		plat_container.add_child(body)
		
		if is_cave and cave_plat_tex:
			var spr := Sprite2D.new()
			spr.texture = cave_plat_tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.region_enabled = true
			if style == "sanctuary" or pw >= 150.0:
				spr.region_rect = Rect2(0, 104, 160, 56)
				spr.position = Vector2(px + pw * 0.5, py + 28.0)
				_add_hanging_chain(plat_container, cave_props_tex, px + 22.0, py)
				_add_hanging_chain(plat_container, cave_props_tex, px + pw - 22.0, py)
			elif style == "bridge":
				spr.region_rect = Rect2(0, 64, 128, 40)
				spr.position = Vector2(px + pw * 0.5, py + 20.0)
				if cave_rock_tex:
					for post_x in [px + 14.0, px + pw - 14.0]:
						var pillar := Sprite2D.new()
						pillar.texture = cave_rock_tex
						pillar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
						pillar.region_enabled = true
						pillar.region_rect = Rect2(96, 0, 32, 96)
						pillar.scale = Vector2(0.68, 0.85)
						pillar.position = Vector2(post_x, py + 48.0)
						pillar.z_index = -2
						plat_container.add_child(pillar)
			elif style == "island_md" or pw <= 104.0:
				spr.region_rect = Rect2(128, 0, 96, 48)
				spr.position = Vector2(px + pw * 0.5, py + 24.0)
				_add_hanging_chain(plat_container, cave_props_tex, px + pw * 0.5, py)
			else:
				spr.region_rect = Rect2(0, 0, 128, 56)
				spr.position = Vector2(px + pw * 0.5, py + 28.0)
				_add_hanging_chain(plat_container, cave_props_tex, px + 18.0, py)
				_add_hanging_chain(plat_container, cave_props_tex, px + pw - 18.0, py)
			plat_container.add_child(spr)
			continue
		
		# Outdoor wood plank platforms
		var num_tiles: int = int(ceil(pw / 32.0))
		for i in range(num_tiles):
			var tx: float = px + i * 32.0 + 16.0
			var spr := Sprite2D.new()
			spr.texture = FLOOR_TILES_TEX
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.region_enabled = true
			spr.region_rect = Rect2(0, 6 * 32, 32, 16) # Wood plank
			spr.position = Vector2(tx, py + 8.0)
			plat_container.add_child(spr)
		
		# Support posts underneath
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

static func _add_hanging_chain(container: Node2D, props_tex: Texture2D, cx: float, top_y: float) -> void:
	if not props_tex or top_y <= 16.0:
		return
	var cur_y: float = top_y - 64.0
	while cur_y > -64.0:
		var ch := Sprite2D.new()
		ch.texture = props_tex
		ch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ch.region_enabled = true
		ch.region_rect = Rect2(64, 0, 32, 128)
		ch.position = Vector2(cx, cur_y)
		ch.modulate = Color(0.75, 0.84, 0.96, 0.90)
		ch.z_index = -2
		container.add_child(ch)
		cur_y -= 128.0

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
	
	var cave_props_tex := CaveAssetsScript.get_props_tex()
	
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
			"streetlamp":
				spr.texture = cave_props_tex
				spr.region_enabled = true
				spr.region_rect = Rect2(0, 0, 64, 96)
				spr.position = Vector2(px, py - 46.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(0.42, 0.94, 1.0, 1.0), 1.45, 0.42, Vector2(12.0, -12.0))
			"lore_stele":
				spr.texture = cave_props_tex
				spr.region_enabled = true
				spr.region_rect = Rect2(96, 48, 64, 112)
				spr.position = Vector2(px, py - 54.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(0.28, 0.82, 1.0, 1.0), 0.88, 0.36, Vector2(0.0, -18.0))
			"ceiling_stalactite":
				spr.texture = cave_props_tex
				spr.region_enabled = true
				spr.region_rect = Rect2(160, 32, 96, 128)
				spr.position = Vector2(px, py + 58.0)
				spr.z_index = 1
			"ore_blue":
				spr.texture = ORES_TEX
				spr.region_enabled = true
				spr.region_rect = Rect2(0, 0, 64, 64)
				spr.scale = Vector2(0.68, 0.68)
				spr.position = Vector2(px, py - 20.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(0.25, 0.72, 1.0, 1.0))
				var tw = spr.create_tween().set_loops()
				tw.tween_property(spr, "modulate", Color(1.4, 1.65, 2.25, 1.0), 1.8)
				tw.tween_property(spr, "modulate", Color(0.85, 1.05, 1.35, 0.92), 1.8)
			"ore_purple":
				spr.texture = ORES_TEX
				spr.region_enabled = true
				spr.region_rect = Rect2(64, 0, 64, 64)
				spr.scale = Vector2(0.68, 0.68)
				spr.position = Vector2(px, py - 20.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(0.78, 0.35, 1.0, 1.0))
				var tw = spr.create_tween().set_loops()
				tw.tween_property(spr, "modulate", Color(1.85, 1.25, 2.1, 1.0), 1.6)
				tw.tween_property(spr, "modulate", Color(1.0, 0.8, 1.25, 0.92), 1.6)
			"ore_gold":
				spr.texture = ORES_TEX
				spr.region_enabled = true
				spr.region_rect = Rect2(0, 64, 64, 64)
				spr.scale = Vector2(0.68, 0.68)
				spr.position = Vector2(px, py - 20.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(1.0, 0.82, 0.28, 1.0))
				var tw = spr.create_tween().set_loops()
				tw.tween_property(spr, "modulate", Color(2.0, 1.8, 0.85, 1.0), 2.0)
				tw.tween_property(spr, "modulate", Color(1.2, 1.0, 0.55, 0.92), 2.0)
			"ore_green":
				spr.texture = ORES_TEX
				spr.region_enabled = true
				spr.region_rect = Rect2(64, 64, 64, 64)
				spr.scale = Vector2(0.68, 0.68)
				spr.position = Vector2(px, py - 20.0)
				spr.z_index = -1
				_attach_ore_light(spr, Color(0.25, 0.95, 0.65, 1.0))
				var tw = spr.create_tween().set_loops()
				tw.tween_property(spr, "modulate", Color(1.25, 2.0, 1.45, 1.0), 1.7)
				tw.tween_property(spr, "modulate", Color(0.8, 1.2, 0.95, 0.92), 1.7)
			"stalactite":
				spr.texture = BG_DIRT_2_TEX
				spr.region_enabled = true
				spr.region_rect = Rect2(0, 0, 32, 128)
				spr.flip_v = true
				spr.scale = Vector2(0.85, 0.65)
				spr.modulate = Color(0.55, 0.65, 0.86, 0.96)
				spr.position = Vector2(px, py + 22.0)
				spr.z_index = -1
		
		props_container.add_child(spr)

static func _attach_ore_light(spr: Sprite2D, light_col: Color, energy: float = 0.72, scale_val: float = 0.22, pos: Vector2 = Vector2.ZERO) -> void:
	var light := PointLight2D.new()
	light.texture = load("res://assets/vfx/radial_light_falloff.png")
	light.color = light_col
	light.energy = energy
	light.texture_scale = scale_val
	light.position = pos
	spr.add_child(light)

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

# ── Enemy Spawning ─────────────────────────────────────────────────────────────
static func spawn_enemies(container: Node2D, level_idx: int, theme: String, on_aswang_died: Callable, on_skeleton_died: Callable = Callable()) -> void:
	for child in container.get_children():
		child.queue_free()
	
	if theme == "Cave":
		# Level 4: The Lapis Depths - Handcrafted placements on solid ruin terraces & elevated islands
		var cave_spawns = [
			{"type": "skeleton", "pos": Vector2(680.0, 272.0)},
			{"type": "aswang", "pos": Vector2(1350.0, 236.0)},
			{"type": "skeleton", "pos": Vector2(1740.0, 236.0)},
			{"type": "skeleton", "pos": Vector2(2560.0, 208.0)},
			{"type": "aswang", "pos": Vector2(2890.0, 208.0)},
			{"type": "skeleton", "pos": Vector2(3130.0, 208.0)},
			{"type": "aswang", "pos": Vector2(3980.0, 244.0)},
			{"type": "skeleton", "pos": Vector2(4220.0, 244.0)},
			{"type": "aswang", "pos": Vector2(4740.0, 260.0)}
		]
		for sp in cave_spawns:
			if sp["type"] == "skeleton":
				var skel = SkeletonScript.new()
				skel.global_position = sp["pos"]
				if on_skeleton_died.is_valid():
					skel.skeleton_died.connect(on_skeleton_died)
				container.add_child(skel)
			else:
				var aswang = AswangScript.new()
				aswang.global_position = sp["pos"]
				aswang.aswang_died.connect(on_aswang_died)
				container.add_child(aswang)
		return
	elif theme == "Cave Boss":
		# Level 5: Bakunawa's Abyss - 3 guardian sentinels on solid obsidian terraces before the shrine
		var guard_positions = [
			Vector2(740.0, 264.0),
			Vector2(1640.0, 232.0),
			Vector2(2840.0, 224.0)
		]
		for g_pos in guard_positions:
			var skel = SkeletonScript.new()
			skel.global_position = g_pos
			if on_skeleton_died.is_valid():
				skel.skeleton_died.connect(on_skeleton_died)
			container.add_child(skel)
		return
	
	# Level 1-3: Corrupted Sentry Ridge Climax (Forest Brute Miniboss)
	if level_idx == 2:
		var sentinels = 8
		var x_s_min: float = 650.0
		var x_s_max: float = 3400.0
		var seg = (x_s_max - x_s_min) / float(sentinels)
		for j in range(sentinels):
			var rx = randf_range(x_s_min + j * seg + 20.0, x_s_min + (j + 1) * seg - 20.0)
			var ry = 210.0 if (j % 2 == 1) else 260.0
			var aswang = AswangScript.new()
			aswang.global_position = Vector2(rx, ry)
			aswang.aswang_died.connect(on_aswang_died)
			container.add_child(aswang)
		
		# Climax Miniboss: Forest Brute at ridge edge
		var brute = ForestBruteMinibossScript.new()
		brute.global_position = Vector2(4450.0, 250.0)
		brute.aswang_died.connect(on_aswang_died)
		container.add_child(brute)
		return

	# Level 2-3: The Mayon Crossing Climax (Mayon Vanguard Miniboss)
	if level_idx == 5:
		var sentinels = 8
		var x_s_min: float = 650.0
		var x_s_max: float = 3400.0
		var seg = (x_s_max - x_s_min) / float(sentinels)
		for j in range(sentinels):
			var rx = randf_range(x_s_min + j * seg + 20.0, x_s_min + (j + 1) * seg - 20.0)
			var ry = 210.0 if (j % 2 == 1) else 260.0
			if j % 2 == 0 and on_skeleton_died.is_valid():
				var skel = SkeletonScript.new()
				skel.global_position = Vector2(rx, ry)
				skel.skeleton_died.connect(on_skeleton_died)
				container.add_child(skel)
			else:
				var aswang = AswangScript.new()
				aswang.global_position = Vector2(rx, ry)
				aswang.aswang_died.connect(on_aswang_died)
				container.add_child(aswang)
		
		# Climax Miniboss: Mayon Vanguard at volcanic storm crossing
		var vanguard = MayonVanguardMinibossScript.new()
		vanguard.global_position = Vector2(4450.0, 250.0)
		if on_skeleton_died.is_valid():
			vanguard.skeleton_died.connect(on_skeleton_died)
		container.add_child(vanguard)
		return

	var sub_lvl = (level_idx % 3) + 1
	var aswang_count = 6 + sub_lvl * 4 # 10, 14, 18
	if theme == "Rice Field":
		aswang_count += 4 # 14, 18, 22
	
	var x_min: float = 600.0
	var x_max: float = 4600.0
	if level_idx == 10:
		# Level 3-5: 8 sentinels along ascent, clearing x >= 3600 for Boss Arena
		aswang_count = 8
		x_max = 3400.0
	
	for j in range(aswang_count):
		var seg = (x_max - x_min) / float(aswang_count)
		var rx = randf_range(x_min + j * seg + 20.0, x_min + (j + 1) * seg - 20.0)
		var ry = 210.0 if (j % 2 == 1) else 260.0
		
		var aswang = AswangScript.new()
		aswang.global_position = Vector2(rx, ry)
		aswang.aswang_died.connect(on_aswang_died)
		container.add_child(aswang)


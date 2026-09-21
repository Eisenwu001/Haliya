@tool
extends SceneTree

const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")
const WIND_SHADER = preload("res://shaders/foliage_wind.gdshader")

# Trees
const NARRA_1_TEX = preload("res://assets/foliage/narra_tree_1.png")
const NARRA_2_TEX = preload("res://assets/foliage/narra_tree_2.png")
const NARRA_3_TEX = preload("res://assets/foliage/narra_tree_3.png")
const NARRA_4_TEX = preload("res://assets/foliage/narra_tree_4.png")
const NARRA_5_TEX = preload("res://assets/foliage/narra_tree_5.png")

const TILESET_PATH = "res://scenes/tileset.tres"

func set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://scenes/rainy_forest")
	var tileset: TileSet = load(TILESET_PATH)
	if not tileset:
		printerr("Failed to load tileset!")
		quit(1)
		return

	# Wind shader material configured for stormy conditions (higher speed and sway)
	var storm_wind_mat = ShaderMaterial.new()
	storm_wind_mat.shader = WIND_SHADER
	storm_wind_mat.set_shader_parameter("wind_speed", 2.6)
	storm_wind_mat.set_shader_parameter("wind_strength", 6.2)
	storm_wind_mat.set_shader_parameter("wind_detail", 2.5)

	# 5 Level Configurations
	var levels_config = [
		{
			"id": "3_1",
			"name": "Level_3_1",
			"title": "Drenched Foothills",
			# Elevation profile: col ranges -> ground_row (8=256, 9=288, 7=224, 10=320)
			"ground": [
				{"start_col": 0, "end_col": 26, "row": 9},    # 0 - 832
				{"start_col": 27, "end_col": 55, "row": 7},   # 864 - 1760 (rolling hill)
				{"start_col": 56, "end_col": 61, "row": 9},   # 1792 - 1952
				# water gap at 62-66 (1984 - 2112)
				{"start_col": 67, "end_col": 105, "row": 8},  # 2144 - 3360 (raised ridge)
				{"start_col": 106, "end_col": 125, "row": 9}, # 3392 - 4000
				{"start_col": 126, "end_col": 159, "row": 9}  # 4032 - 5088 (approach to exit)
			],
			"water_gaps": [
				{"start_col": 62, "end_col": 66, "row": 10}
			],
			"platforms": [
				{"start_col": 59, "end_col": 69, "row": 7},   # bridge over stream 1
				{"start_col": 82, "end_col": 90, "row": 5},   # ridge lookout platform
				{"start_col": 112, "end_col": 120, "row": 7}  # hill descent platform
			],
			"trees": [
				{"tex": NARRA_1_TEX, "x": 280, "y": 300, "scale": 0.32},
				{"tex": NARRA_2_TEX, "x": 750, "y": 300, "scale": 0.36},
				{"tex": NARRA_4_TEX, "x": 1300, "y": 236, "scale": 0.35},
				{"tex": NARRA_5_TEX, "x": 1650, "y": 236, "scale": 0.34},
				{"tex": NARRA_3_TEX, "x": 2400, "y": 268, "scale": 0.35},
				{"tex": NARRA_2_TEX, "x": 3100, "y": 268, "scale": 0.38},
				{"tex": NARRA_1_TEX, "x": 3750, "y": 300, "scale": 0.30},
				{"tex": NARRA_5_TEX, "x": 4500, "y": 300, "scale": 0.34}
			],
			"torches": [
				Vector2(320, 288), Vector2(1200, 224), Vector2(2100, 240),
				Vector2(3300, 256), Vector2(4800, 288)
			],
			"pots": [
				Vector2(600, 276), Vector2(1950, 212), Vector2(2750, 148), Vector2(4000, 276)
			],
			"enemies": [
				{"type": "aswang", "pos": Vector2(950, 212)},
				{"type": "skeleton", "pos": Vector2(1500, 212)},
				{"type": "aswang", "pos": Vector2(2450, 244)},
				{"type": "skeleton", "pos": Vector2(3200, 244)},
				{"type": "aswang", "pos": Vector2(4200, 276)}
			]
		},
		{
			"id": "3_2",
			"name": "Level_3_2",
			"title": "Canopy Torrent",
			"ground": [
				{"start_col": 0, "end_col": 38, "row": 9},     # 0 - 1216
				# water gap at 39-46 (1248 - 1472)
				{"start_col": 47, "end_col": 92, "row": 9},   # 1504 - 2944
				# water gap at 93-100 (2976 - 3200)
				{"start_col": 101, "end_col": 135, "row": 8}, # 3232 - 4320
				{"start_col": 136, "end_col": 159, "row": 9}  # 4352 - 5088
			],
			"water_gaps": [
				{"start_col": 39, "end_col": 46, "row": 10},
				{"start_col": 93, "end_col": 100, "row": 10}
			],
			"platforms": [
				{"start_col": 20, "end_col": 28, "row": 6},   # approach canopy
				{"start_col": 36, "end_col": 49, "row": 7},   # river bridge 1
				{"start_col": 55, "end_col": 66, "row": 5},   # high central canopy
				{"start_col": 75, "end_col": 86, "row": 6},   # middle canopy
				{"start_col": 90, "end_col": 103, "row": 7},  # river bridge 2
				{"start_col": 118, "end_col": 128, "row": 5}  # overlook canopy
			],
			"trees": [
				{"tex": NARRA_4_TEX, "x": 250, "y": 300, "scale": 0.38},
				{"tex": NARRA_5_TEX, "x": 750, "y": 300, "scale": 0.35},
				{"tex": NARRA_2_TEX, "x": 1350, "y": 300, "scale": 0.40},
				{"tex": NARRA_3_TEX, "x": 1900, "y": 300, "scale": 0.36},
				{"tex": NARRA_1_TEX, "x": 2500, "y": 300, "scale": 0.34},
				{"tex": NARRA_5_TEX, "x": 3050, "y": 300, "scale": 0.38},
				{"tex": NARRA_4_TEX, "x": 3600, "y": 268, "scale": 0.36},
				{"tex": NARRA_2_TEX, "x": 4200, "y": 268, "scale": 0.37},
				{"tex": NARRA_1_TEX, "x": 4750, "y": 300, "scale": 0.32}
			],
			"torches": [
				Vector2(280, 288), Vector2(1360, 212), Vector2(1950, 148),
				Vector2(3080, 212), Vector2(4000, 244), Vector2(4850, 288)
			],
			"pots": [
				Vector2(700, 180), Vector2(1850, 148), Vector2(2500, 276), Vector2(3950, 148)
			],
			"enemies": [
				{"type": "skeleton", "pos": Vector2(700, 276)},
				{"type": "aswang", "pos": Vector2(1380, 212)},
				{"type": "skeleton", "pos": Vector2(2000, 148)},
				{"type": "aswang", "pos": Vector2(2650, 276)},
				{"type": "aswang", "pos": Vector2(3100, 212)},
				{"type": "skeleton", "pos": Vector2(4300, 244)}
			]
		},
		{
			"id": "3_3",
			"name": "Level_3_3",
			"title": "The Flooded Ravine",
			"ground": [
				{"start_col": 0, "end_col": 28, "row": 9},     # 0 - 896
				# Ravine 1 at 29-37 (928 - 1184)
				{"start_col": 38, "end_col": 68, "row": 7},   # 1216 - 2176 (high cliff)
				# Ravine 2 at 69-77 (2208 - 2464)
				{"start_col": 78, "end_col": 108, "row": 8},  # 2496 - 3456 (middle plateau)
				# Ravine 3 at 109-117 (3488 - 3744)
				{"start_col": 118, "end_col": 159, "row": 9}  # 3776 - 5088 (final approach)
			],
			"water_gaps": [
				{"start_col": 29, "end_col": 37, "row": 10},
				{"start_col": 69, "end_col": 77, "row": 10},
				{"start_col": 109, "end_col": 117, "row": 10}
			],
			"platforms": [
				{"start_col": 30, "end_col": 36, "row": 8},   # stepping log 1
				{"start_col": 48, "end_col": 58, "row": 5},   # cliff watchtower
				{"start_col": 70, "end_col": 76, "row": 7},   # stepping log 2
				{"start_col": 90, "end_col": 98, "row": 6},   # mid plateau ledge
				{"start_col": 110, "end_col": 116, "row": 8}, # stepping log 3
				{"start_col": 130, "end_col": 140, "row": 7}  # valley watchplatform
			],
			"trees": [
				{"tex": NARRA_5_TEX, "x": 300, "y": 300, "scale": 0.35},
				{"tex": NARRA_2_TEX, "x": 800, "y": 300, "scale": 0.36},
				{"tex": NARRA_4_TEX, "x": 1500, "y": 236, "scale": 0.37},
				{"tex": NARRA_3_TEX, "x": 2000, "y": 236, "scale": 0.35},
				{"tex": NARRA_1_TEX, "x": 2700, "y": 268, "scale": 0.34},
				{"tex": NARRA_2_TEX, "x": 3200, "y": 268, "scale": 0.36},
				{"tex": NARRA_3_TEX, "x": 3900, "y": 300, "scale": 0.35},
				{"tex": NARRA_5_TEX, "x": 4500, "y": 300, "scale": 0.35}
			],
			"torches": [
				Vector2(260, 288), Vector2(1050, 244), Vector2(1700, 148),
				Vector2(2330, 212), Vector2(3000, 244), Vector2(3620, 244), Vector2(4800, 288)
			],
			"pots": [
				Vector2(650, 276), Vector2(1700, 148), Vector2(2850, 244), Vector2(3600, 244), Vector2(4300, 276)
			],
			"enemies": [
				{"type": "aswang", "pos": Vector2(800, 276)},
				{"type": "skeleton", "pos": Vector2(1500, 212)},
				{"type": "aswang", "pos": Vector2(1900, 212)},
				{"type": "skeleton", "pos": Vector2(2800, 244)},
				{"type": "aswang", "pos": Vector2(3300, 244)},
				{"type": "skeleton", "pos": Vector2(4100, 276)},
				{"type": "aswang", "pos": Vector2(4600, 276)}
			]
		},
		{
			"id": "3_4",
			"name": "Level_3_4",
			"title": "Moss-Veiled Ruins",
			"ground": [
				{"start_col": 0, "end_col": 40, "row": 9},     # 0 - 1280
				{"start_col": 41, "end_col": 64, "row": 10},  # sunken courtyard 1
				# canal at 65-72 (2080 - 2304)
				{"start_col": 73, "end_col": 110, "row": 9},  # 2336 - 3520
				{"start_col": 111, "end_col": 130, "row": 10},# sunken courtyard 2
				{"start_col": 131, "end_col": 159, "row": 9}  # 4192 - 5088
			],
			"water_gaps": [
				{"start_col": 65, "end_col": 72, "row": 10}
			],
			"platforms": [
				# Tier 1 ruins (mid level)
				{"start_col": 24, "end_col": 34, "row": 7},
				{"start_col": 46, "end_col": 60, "row": 8},   # over courtyard 1
				{"start_col": 63, "end_col": 74, "row": 7},   # canal ruin bridge
				{"start_col": 85, "end_col": 98, "row": 7},
				{"start_col": 115, "end_col": 128, "row": 8}, # over courtyard 2
				{"start_col": 138, "end_col": 148, "row": 7},
				# Tier 2 ruins (high battlements)
				{"start_col": 28, "end_col": 36, "row": 5},
				{"start_col": 65, "end_col": 72, "row": 5},   # high bridge over canal
				{"start_col": 90, "end_col": 96, "row": 4},
				{"start_col": 120, "end_col": 126, "row": 5}
			],
			"trees": [
				{"tex": NARRA_1_TEX, "x": 350, "y": 300, "scale": 0.34},
				{"tex": NARRA_3_TEX, "x": 950, "y": 300, "scale": 0.36},
				{"tex": NARRA_5_TEX, "x": 1600, "y": 320, "scale": 0.35},
				{"tex": NARRA_2_TEX, "x": 2500, "y": 300, "scale": 0.37},
				{"tex": NARRA_4_TEX, "x": 3100, "y": 300, "scale": 0.36},
				{"tex": NARRA_1_TEX, "x": 3800, "y": 320, "scale": 0.32},
				{"tex": NARRA_5_TEX, "x": 4400, "y": 300, "scale": 0.35},
				{"tex": NARRA_2_TEX, "x": 4850, "y": 300, "scale": 0.38}
			],
			"torches": [
				Vector2(300, 288), Vector2(1000, 148), Vector2(1750, 244),
				Vector2(2200, 148), Vector2(2900, 212), Vector2(3700, 116),
				Vector2(4400, 212), Vector2(4900, 288)
			],
			"pots": [
				Vector2(900, 212), Vector2(1750, 244), Vector2(2200, 148),
				Vector2(3050, 212), Vector2(3900, 148), Vector2(4500, 276)
			],
			"enemies": [
				{"type": "skeleton", "pos": Vector2(750, 276)},
				{"type": "aswang", "pos": Vector2(1050, 148)},
				{"type": "skeleton", "pos": Vector2(1600, 308)},
				{"type": "aswang", "pos": Vector2(2250, 148)},
				{"type": "skeleton", "pos": Vector2(2700, 276)},
				{"type": "aswang", "pos": Vector2(3450, 116)},
				{"type": "skeleton", "pos": Vector2(3900, 308)},
				{"type": "aswang", "pos": Vector2(4450, 276)}
			]
		},
		{
			"id": "3_5",
			"name": "Level_3_5",
			"title": "Eye of the Tempest",
			"ground": [
				{"start_col": 0, "end_col": 26, "row": 9},     # 0 - 832 (base)
				{"start_col": 27, "end_col": 50, "row": 7},   # 864 - 1600 (Crag 1)
				# Tempest Chasm 1 at 51-59 (1632 - 1888)
				{"start_col": 60, "end_col": 85, "row": 6},   # 1920 - 2720 (Crag 2 summit!)
				# Tempest Chasm 2 at 86-94 (2752 - 3008)
				{"start_col": 95, "end_col": 124, "row": 8},  # 3040 - 3968 (descent ridge)
				{"start_col": 125, "end_col": 159, "row": 9}  # 4000 - 5088 (Storm Sanctum)
			],
			"water_gaps": [
				{"start_col": 51, "end_col": 59, "row": 10},
				{"start_col": 86, "end_col": 94, "row": 10}
			],
			"platforms": [
				{"start_col": 18, "end_col": 26, "row": 8},   # climb to crag 1
				{"start_col": 34, "end_col": 44, "row": 5},   # peak of crag 1
				{"start_col": 52, "end_col": 58, "row": 7},   # chasm 1 suspended ledge
				{"start_col": 66, "end_col": 78, "row": 4},   # supreme summit battlement!
				{"start_col": 87, "end_col": 93, "row": 7},   # chasm 2 suspended ledge
				{"start_col": 104, "end_col": 114, "row": 6}, # descent cliffside ledge
				{"start_col": 132, "end_col": 146, "row": 7}  # sanctum grand gate platform
			],
			"trees": [
				{"tex": NARRA_4_TEX, "x": 240, "y": 300, "scale": 0.40},
				{"tex": NARRA_2_TEX, "x": 750, "y": 300, "scale": 0.38},
				{"tex": NARRA_5_TEX, "x": 1350, "y": 236, "scale": 0.36},
				{"tex": NARRA_3_TEX, "x": 2100, "y": 204, "scale": 0.38},
				{"tex": NARRA_1_TEX, "x": 2600, "y": 204, "scale": 0.35},
				{"tex": NARRA_4_TEX, "x": 3300, "y": 268, "scale": 0.37},
				{"tex": NARRA_2_TEX, "x": 3800, "y": 268, "scale": 0.38},
				{"tex": NARRA_5_TEX, "x": 4350, "y": 300, "scale": 0.37},
				{"tex": NARRA_1_TEX, "x": 4800, "y": 300, "scale": 0.35}
			],
			"torches": [
				Vector2(260, 288), Vector2(1000, 212), Vector2(1730, 212),
				Vector2(2300, 180), Vector2(2850, 212), Vector2(3500, 244),
				Vector2(4200, 288), Vector2(4850, 288)
			],
			"pots": [
				Vector2(600, 276), Vector2(1250, 148), Vector2(2250, 116),
				Vector2(3200, 244), Vector2(4150, 276), Vector2(4600, 212)
			],
			"enemies": [
				{"type": "skeleton", "pos": Vector2(650, 276)},
				{"type": "aswang", "pos": Vector2(1200, 212)},
				{"type": "aswang", "pos": Vector2(1750, 212)},
				{"type": "skeleton", "pos": Vector2(2250, 180)},
				{"type": "skeleton", "pos": Vector2(2550, 180)},
				{"type": "aswang", "pos": Vector2(3250, 244)},
				{"type": "skeleton", "pos": Vector2(3800, 244)},
				{"type": "aswang", "pos": Vector2(4300, 276)},
				{"type": "skeleton", "pos": Vector2(4650, 276)}
			]
		}
	]

	for cfg in levels_config:
		print("Building level: ", cfg["name"], " - ", cfg["title"])
		var root_node = Node2D.new()
		root_node.name = cfg["name"]

		# 1. WaterBackground (TileMapLayer)
		var water_bg = TileMapLayer.new()
		water_bg.name = "WaterBackground"
		water_bg.tile_set = tileset
		water_bg.z_index = -1
		water_bg.collision_enabled = false
		root_node.add_child(water_bg)

		for w_gap in cfg["water_gaps"]:
			var start_col: int = w_gap["start_col"]
			var end_col: int = w_gap["end_col"]
			var row: int = w_gap["row"]
			for col in range(start_col, end_col + 1):
				# Water surface
				water_bg.set_cell(Vector2i(col, row), 3, Vector2i(0, 0))
				# Deep water down to row 16
				for drow in range(row + 1, 17):
					water_bg.set_cell(Vector2i(col, drow), 3, Vector2i(0, 1))

		# 2. BaseGround (TileMapLayer)
		var base_ground = TileMapLayer.new()
		base_ground.name = "BaseGround"
		base_ground.tile_set = tileset
		base_ground.collision_enabled = true
		root_node.add_child(base_ground)

		# Build ground segments
		for seg in cfg["ground"]:
			var start_col: int = seg["start_col"]
			var end_col: int = seg["end_col"]
			var ground_row: int = seg["row"]
			for col in range(start_col, end_col + 1):
				# Check if col is in water gap
				var in_water = false
				for wg in cfg["water_gaps"]:
					if col >= wg["start_col"] and col <= wg["end_col"]:
						in_water = true
						break
				if in_water:
					continue

				# Surface tile
				base_ground.set_cell(Vector2i(col, ground_row), 0, Vector2i(1, 0))
				# Subsurface dirt down to row 16
				for drow in range(ground_row + 1, 17):
					base_ground.set_cell(Vector2i(col, drow), 0, Vector2i(1, 1))

		# Build platforms into BaseGround
		for plat in cfg["platforms"]:
			var start_col: int = plat["start_col"]
			var end_col: int = plat["end_col"]
			var plat_row: int = plat["row"]
			for col in range(start_col, end_col + 1):
				if col == start_col:
					base_ground.set_cell(Vector2i(col, plat_row), 0, Vector2i(0, 6))
				elif col == end_col:
					base_ground.set_cell(Vector2i(col, plat_row), 0, Vector2i(2, 6))
				else:
					base_ground.set_cell(Vector2i(col, plat_row), 0, Vector2i(1, 6))

		# 3. ForegroundDecor (TileMapLayer)
		var fg_decor = TileMapLayer.new()
		fg_decor.name = "ForegroundDecor"
		fg_decor.tile_set = tileset
		fg_decor.z_index = 1
		fg_decor.collision_enabled = true
		root_node.add_child(fg_decor)

		# 4. Foliage (Node2D)
		var foliage_node = Node2D.new()
		foliage_node.name = "Foliage"
		root_node.add_child(foliage_node)

		var t_idx = 1
		for t_data in cfg["trees"]:
			var tree = Sprite2D.new()
			tree.name = "NarraTree_%02d" % t_idx
			tree.texture = t_data["tex"]
			tree.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tree.material = storm_wind_mat
			tree.z_index = -2
			var s: float = t_data["scale"]
			tree.scale = Vector2(s, s)
			var h: float = float(tree.texture.get_height())
			tree.offset = Vector2(0, -h * 0.5)
			tree.position = Vector2(t_data["x"], t_data["y"])
			foliage_node.add_child(tree)
			t_idx += 1

		# 5. Torches (Node2D)
		var torches_node = Node2D.new()
		torches_node.name = "Torches"
		root_node.add_child(torches_node)

		var torch_idx = 1
		for t_pos in cfg["torches"]:
			var torch = EnvironmentTorchScript.new()
			torch.name = "Torch_%02d" % torch_idx
			torch.position = t_pos
			torches_node.add_child(torch)
			torch_idx += 1

		# 6. Breakables (Node2D)
		var breakables_node = Node2D.new()
		breakables_node.name = "Breakables"
		root_node.add_child(breakables_node)

		var pot_idx = 1
		for p_pos in cfg["pots"]:
			var pot = PalayokPotScript.new()
			pot.name = "PalayokPot_%02d" % pot_idx
			pot.position = p_pos
			breakables_node.add_child(pot)
			pot_idx += 1

		# 7. Enemies (Node2D)
		var enemies_node = Node2D.new()
		enemies_node.name = "Enemies"
		root_node.add_child(enemies_node)

		var e_idx = 1
		for e_data in cfg["enemies"]:
			var enemy: Node2D
			if e_data["type"] == "aswang":
				enemy = AswangScript.new()
				enemy.name = "Aswang_%02d" % e_idx
			else:
				enemy = SkeletonScript.new()
				enemy.name = "Skeleton_%02d" % e_idx
			enemy.position = e_data["pos"]
			enemies_node.add_child(enemy)
			e_idx += 1

		# Pack and save scene
		set_owner_recursive(root_node, root_node)
		var packed := PackedScene.new()
		var pack_err := packed.pack(root_node)
		if pack_err != OK:
			printerr("Failed to pack ", cfg["name"], ": ", pack_err)
			continue

		var file_path = "res://scenes/rainy_forest/level_%s.tscn" % cfg["id"]
		var save_err := ResourceSaver.save(packed, file_path)
		if save_err != OK:
			printerr("Failed to save ", file_path, ": ", save_err)
		else:
			print("Successfully saved: ", file_path)

	print("All 5 World 3 levels successfully generated!")
	quit(0)

@tool
extends SceneTree

const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")

const TILESET_PATH = "res://scenes/tileset.tres"
const PORTAL_TEX = preload("res://assets/platform_assets/Animated Sprites/portal_sheet.png")
const MOSSY_ROCKS_TEX = preload("res://assets/bahay_kubo/prop_mossy_rocks.png")

func set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)

func _init() -> void:
	print("--- Baking Level 4 (The Cave: The Lapis Depths) with TileMapLayer ---")
	
	var tileset: TileSet = load(TILESET_PATH)
	if not tileset:
		printerr("Failed to load tileset!")
		quit(1)
		return

	var root_node := Node2D.new()
	root_node.name = "Level_4"

	# Level Layout Configuration
	# Ground segments across 160 columns (5120 px width)
	# Row 9 = y 288 px (matching entrance and exit standards)
	var ground_segments = [
		{"start_col": 0, "end_col": 36, "row": 9},     # 0 - 1184 (Entrance Plateau)
		{"start_col": 37, "end_col": 38, "row": 10},   # 1184 - 1248 (Step down into Sunken Grotto)
		# Chasm 1 at 39-46 (1248 - 1504)
		{"start_col": 47, "end_col": 49, "row": 10},   # 1504 - 1600 (Grotto Floor)
		{"start_col": 50, "end_col": 62, "row": 9},    # 1600 - 2016 (Lower Vein)
		{"start_col": 63, "end_col": 78, "row": 8},    # 2016 - 2528 (Mineral Ridge Ascent)
		# Chasm 2 at 79-86 (2528 - 2784)
		{"start_col": 87, "end_col": 98, "row": 8},    # 2784 - 3168 (Deep Cavern Landing)
		{"start_col": 99, "end_col": 118, "row": 7},   # 3168 - 3808 (High Crystal Terrace)
		# Chasm 3 at 119-126 (3808 - 4064)
		{"start_col": 127, "end_col": 130, "row": 8},  # 4064 - 4192 (Descent to Exit)
		{"start_col": 131, "end_col": 159, "row": 9}   # 4192 - 5088 (Exit Plateau leading to portal & boss gate)
	]

	var water_gaps = [
		{"start_col": 39, "end_col": 46, "row": 11},   # Chasm 1 water pool
		{"start_col": 79, "end_col": 86, "row": 11},   # Chasm 2 water pool
		{"start_col": 119, "end_col": 126, "row": 11}  # Chasm 3 water pool
	]

	var platforms = [
		# Chasm 1 Bridges & Entrance Scaffolding
		{"start_col": 14, "end_col": 20, "row": 7},    # Entrance exploration ledge
		{"start_col": 38, "end_col": 42, "row": 8},    # Chasm 1 west stepping ledge
		{"start_col": 43, "end_col": 47, "row": 8},    # Chasm 1 east stepping ledge

		# Mineral Ridge Elevated Terraces
		{"start_col": 54, "end_col": 60, "row": 6},    # Lower vein terrace
		{"start_col": 68, "end_col": 74, "row": 5},    # Ridge summit lookout

		# Chasm 2 Suspended Bridge & Aerial Path
		{"start_col": 78, "end_col": 82, "row": 7},    # Chasm 2 west bridge ledge
		{"start_col": 83, "end_col": 87, "row": 7},    # Chasm 2 east bridge ledge
		{"start_col": 80, "end_col": 85, "row": 4},    # Chasm 2 high secret scaffold

		# Crystal Terrace High Overhangs
		{"start_col": 104, "end_col": 112, "row": 5},  # Crystal terrace balcony

		# Chasm 3 Descent Ledges
		{"start_col": 118, "end_col": 122, "row": 7},  # Chasm 3 west stepping stone
		{"start_col": 123, "end_col": 127, "row": 8}   # Chasm 3 east stepping stone
	]

	# 1. WaterBackground (TileMapLayer, z_index = -1, collision_enabled = false)
	var water_bg := TileMapLayer.new()
	water_bg.name = "WaterBackground"
	water_bg.tile_set = tileset
	water_bg.z_index = -1
	water_bg.collision_enabled = false
	root_node.add_child(water_bg)

	# Paint animated subterranean water tiles in water gaps
	for w_gap in water_gaps:
		var start_col: int = w_gap["start_col"]
		var end_col: int = w_gap["end_col"]
		var row: int = w_gap["row"]
		for col in range(start_col, end_col + 1):
			# Water surface (source 3, animated 0,0)
			water_bg.set_cell(Vector2i(col, row), 3, Vector2i(0, 0))
			# Deep water fill down to row 24 (source 3, animated 0,1)
			for drow in range(row + 1, 24):
				water_bg.set_cell(Vector2i(col, drow), 3, Vector2i(0, 1))

	# 2. BaseGround (TileMapLayer, z_index = 0, collision_enabled = true)
	var base_ground := TileMapLayer.new()
	base_ground.name = "BaseGround"
	base_ground.tile_set = tileset
	base_ground.collision_enabled = true
	root_node.add_child(base_ground)

	# Paint Cave Ground (Source 8 = Floor Tiles2.png)
	for seg in ground_segments:
		var start_col: int = seg["start_col"]
		var end_col: int = seg["end_col"]
		var ground_row: int = seg["row"]
		for col in range(start_col, end_col + 1):
			# Check if col is in water gap
			var in_water = false
			for wg in water_gaps:
				if col >= wg["start_col"] and col <= wg["end_col"]:
					in_water = true
					break
			if in_water:
				continue

			# Top surface cave stone tile (Source 8, tile 1,0 or 0,0)
			var surface_col_tile = 1 if (col % 2 == 0) else 0
			base_ground.set_cell(Vector2i(col, ground_row), 8, Vector2i(surface_col_tile, 0))

			# Subsurface deep cave stone fill down to row 24 (Source 8, tile 0,1 / 1,1)
			for drow in range(ground_row + 1, 24):
				var sub_tile = Vector2i(0, 1) if (col + drow) % 3 != 0 else Vector2i(1, 1)
				base_ground.set_cell(Vector2i(col, drow), 8, sub_tile)

	# Paint Platforms into BaseGround (Source 8, Row 6 = Wooden/Stone cave platform tiles)
	for plat in platforms:
		var start_col: int = plat["start_col"]
		var end_col: int = plat["end_col"]
		var plat_row: int = plat["row"]
		for col in range(start_col, end_col + 1):
			if col == start_col:
				# Left platform cap (Source 8, 0:6)
				base_ground.set_cell(Vector2i(col, plat_row), 8, Vector2i(0, 6))
			elif col == end_col:
				# Right platform cap (Source 8, 2:6)
				base_ground.set_cell(Vector2i(col, plat_row), 8, Vector2i(2, 6))
			else:
				# Middle platform (Source 8, 1:6)
				base_ground.set_cell(Vector2i(col, plat_row), 8, Vector2i(1, 6))

	# 3. ForegroundDecor (TileMapLayer, z_index = 1, collision_enabled = false)
	var fg_decor := TileMapLayer.new()
	fg_decor.name = "ForegroundDecor"
	fg_decor.tile_set = tileset
	fg_decor.z_index = 1
	fg_decor.collision_enabled = false
	root_node.add_child(fg_decor)

	# Place Glowing Mineral Ores (Source 11: 0,0 Lapis Blue, 1,0 Purple, 2,0 Gold, 3,0 Green)
	var ore_positions = [
		{"cell": Vector2i(15, 6), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(20, 6), "tile": Vector2i(1, 0)}, # Purple
		{"cell": Vector2i(25, 8), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(45, 7), "tile": Vector2i(2, 0)}, # Gold
		{"cell": Vector2i(52, 8), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(58, 5), "tile": Vector2i(1, 0)}, # Purple
		{"cell": Vector2i(70, 4), "tile": Vector2i(2, 0)}, # Gold
		{"cell": Vector2i(72, 4), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(85, 3), "tile": Vector2i(1, 0)}, # Purple
		{"cell": Vector2i(95, 7), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(106, 4), "tile": Vector2i(1, 0)}, # Purple
		{"cell": Vector2i(108, 6), "tile": Vector2i(2, 0)}, # Gold
		{"cell": Vector2i(110, 4), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(138, 8), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(142, 8), "tile": Vector2i(1, 0)}, # Purple
		{"cell": Vector2i(148, 8), "tile": Vector2i(0, 0)}, # Lapis
		{"cell": Vector2i(152, 8), "tile": Vector2i(2, 0)}, # Gold
		{"cell": Vector2i(155, 8), "tile": Vector2i(3, 0)}  # Emerald
	]
	for ore in ore_positions:
		fg_decor.set_cell(ore["cell"], 11, ore["tile"])

	# Place Stalactites along the ceiling (Source 9 = Other Tiles2.png: 5,0 and 5,1)
	var stalactite_cols = [12, 18, 28, 41, 44, 56, 65, 75, 83, 85, 92, 102, 111, 115, 124, 136, 145, 150]
	for scol in stalactite_cols:
		fg_decor.set_cell(Vector2i(scol, 0), 9, Vector2i(5, 0))
		fg_decor.set_cell(Vector2i(scol, 1), 9, Vector2i(5, 1))

	# 4. Props (Node2D) - Mossy rocks
	var props_node := Node2D.new()
	props_node.name = "Props"
	root_node.add_child(props_node)

	var rock_positions = [
		Vector2(420.0, 282.0),
		Vector2(1750.0, 282.0),
		Vector2(2150.0, 250.0),
		Vector2(3200.0, 218.0),
		Vector2(3700.0, 218.0),
		Vector2(4500.0, 282.0)
	]
	var rock_idx = 1
	for r_pos in rock_positions:
		var rock := Sprite2D.new()
		rock.name = "MossyRocks_%02d" % rock_idx
		rock.texture = MOSSY_ROCKS_TEX
		rock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		rock.scale = Vector2(0.45, 0.45)
		rock.position = r_pos
		rock.z_index = -1
		props_node.add_child(rock)
		rock_idx += 1

	# 5. Torches (Node2D)
	var torches_node := Node2D.new()
	torches_node.name = "Torches"
	root_node.add_child(torches_node)

	var torch_positions = [
		Vector2(280.0, 288.0),
		Vector2(850.0, 288.0),
		Vector2(1200.0, 288.0),
		Vector2(1650.0, 288.0),
		Vector2(2100.0, 256.0),
		Vector2(2500.0, 256.0),
		Vector2(2850.0, 256.0),
		Vector2(3300.0, 224.0),
		Vector2(3750.0, 224.0),
		Vector2(4200.0, 288.0),
		Vector2(4850.0, 288.0)
	]
	var torch_idx = 1
	for t_pos in torch_positions:
		var torch = EnvironmentTorchScript.new()
		torch.name = "Torch_%02d" % torch_idx
		torch.position = t_pos
		torches_node.add_child(torch)
		torch_idx += 1

	# 6. Breakables (Node2D)
	var breakables_node := Node2D.new()
	breakables_node.name = "Breakables"
	root_node.add_child(breakables_node)

	var pot_positions = [
		Vector2(500.0, 276.0),
		Vector2(1800.0, 180.0),
		Vector2(2650.0, 116.0),
		Vector2(3450.0, 148.0),
		Vector2(4300.0, 276.0)
	]
	var pot_idx = 1
	for p_pos in pot_positions:
		var pot = PalayokPotScript.new()
		pot.name = "PalayokPot_%02d" % pot_idx
		pot.position = p_pos
		breakables_node.add_child(pot)
		pot_idx += 1

	# 7. Enemies (Node2D) - 10 balanced encounters (Skeletons and Aswangs)
	var enemies_node := Node2D.new()
	enemies_node.name = "Enemies"
	root_node.add_child(enemies_node)

	var enemy_configs = [
		{"type": "skeleton", "pos": Vector2(700.0, 272.0)},
		{"type": "aswang",   "pos": Vector2(1050.0, 272.0)},
		{"type": "aswang",   "pos": Vector2(1440.0, 240.0)},
		{"type": "skeleton", "pos": Vector2(1850.0, 272.0)},
		{"type": "skeleton", "pos": Vector2(2300.0, 240.0)},
		{"type": "aswang",   "pos": Vector2(2720.0, 208.0)},
		{"type": "aswang",   "pos": Vector2(3350.0, 208.0)},
		{"type": "skeleton", "pos": Vector2(3650.0, 208.0)},
		{"type": "skeleton", "pos": Vector2(4400.0, 272.0)},
		{"type": "aswang",   "pos": Vector2(4650.0, 272.0)}
	]
	var e_idx = 1
	for e_data in enemy_configs:
		var enemy: CharacterBody2D
		if e_data["type"] == "aswang":
			enemy = AswangScript.new()
			enemy.name = "Aswang_%02d" % e_idx
		else:
			enemy = SkeletonScript.new()
			enemy.name = "Skeleton_%02d" % e_idx
		enemy.position = e_data["pos"]
		enemies_node.add_child(enemy)
		e_idx += 1

	# 8. LevelExitPortal (Sprite2D)
	var portal := Sprite2D.new()
	portal.name = "LevelExitPortal"
	portal.texture = PORTAL_TEX
	portal.region_enabled = true
	portal.region_rect = Rect2(0, 0, 64, 64)
	portal.position = Vector2(4900.0, 288.0)
	portal.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root_node.add_child(portal)

	# Save scene
	set_owner_recursive(root_node, root_node)
	var packed := PackedScene.new()
	var pack_err := packed.pack(root_node)
	if pack_err != OK:
		printerr("Failed to pack Level_4 scene: ", pack_err)
		quit(1)
		return

	var file_path = "res://scenes/cave/level_4.tscn"
	var save_err := ResourceSaver.save(packed, file_path)
	if save_err != OK:
		printerr("Failed to save ", file_path, ": ", save_err)
		quit(1)
		return

	print("SUCCESS: Baked new TileMapLayer-based Level 4 to: ", file_path)
	quit(0)

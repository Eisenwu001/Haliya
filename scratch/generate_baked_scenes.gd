extends SceneTree

const LevelBuilderScript = preload("res://scripts/level_builder.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const WaterHazardScript = preload("res://scripts/water_hazard.gd")
const EnvironmentTorchScript = preload("res://scripts/environment_torch.gd")

const FLOOR_TILES_TEX = preload("res://assets/platform_assets/Floor Tiles1.png")
const OTHER_TILES_TEX = preload("res://assets/platform_assets/Other Tiles1.png")
const WATER_TILES_TEX = preload("res://assets/platform_assets/Animated Sprites/animated_water_tiles.png")
const WIND_SHADER = preload("res://shaders/foliage_wind.gdshader")
const PORTAL_TEX = preload("res://assets/platform_assets/Animated Sprites/portal_sheet.png")

# Background-matching Canopy Trees
const CANOPY_LARGE_TEX = preload("res://assets/foliage/tree_canopy_large.png")
const CANOPY_MEDIUM_TEX = preload("res://assets/foliage/tree_canopy_medium.png")
const CANOPY_CLUSTER_TEX = preload("res://assets/foliage/tree_canopy_cluster.png")

# Rural Rice Field Props & Foliage
const BANANA_TEX = preload("res://assets/bahay_kubo/prop_banana_tree.png")
const FENCE_TEX = preload("res://assets/bahay_kubo/prop_wooden_fence.png")
const FIREWOOD_TEX = preload("res://assets/bahay_kubo/prop_firewood.png")
const ROCKS_TEX = preload("res://assets/bahay_kubo/prop_mossy_rocks.png")
const HOUSE_TEX = preload("res://assets/bahay_kubo/bahay_kubo_house.png")
const WHEAT_TEX = preload("res://assets/platform_assets/Pixel Art Wheat.png")
const ROOSTER_TEX = preload("res://assets/bahay_kubo/prop_rooster.png")

const SCENES_CONFIG = [
	{
		"path": "res://scenes/forest/level_1_1.tscn",
		"name": "Level_1_1",
		"level_idx": 0,
		"theme": "Forest",
		"enemies_aswang": [
			Vector2(950, 272),
			Vector2(1100, 202),
			Vector2(2000, 172),
			Vector2(2400, 240),
			Vector2(3800, 272)
		]
	},
	{
		"path": "res://scenes/forest/level_1_2.tscn",
		"name": "Level_1_2",
		"level_idx": 1,
		"theme": "Forest",
		"enemies_aswang": [
			Vector2(450, 192),
			Vector2(800, 272),
			Vector2(1750, 152),
			Vector2(1900, 240),
			Vector2(3100, 122),
			Vector2(3400, 208),
			Vector2(4500, 272)
		]
	},
	{
		"path": "res://scenes/forest/level_1_3.tscn",
		"name": "Level_1_3",
		"level_idx": 2,
		"theme": "Forest",
		"enemies_aswang": [
			Vector2(500, 192),
			Vector2(700, 272),
			Vector2(1500, 230),
			Vector2(1600, 142),
			Vector2(2000, 230),
			Vector2(2700, 112),
			Vector2(3000, 198),
			Vector2(4100, 172),
			Vector2(4400, 260)
		]
	},
	{
		"path": "res://scenes/rice_field/level_2_1.tscn",
		"name": "Level_2_1",
		"level_idx": 3,
		"theme": "Rice Field",
		"enemies_aswang": [
			Vector2(700, 202),
			Vector2(900, 272),
			Vector2(1400, 272),
			Vector2(2300, 172),
			Vector2(2500, 240),
			Vector2(4100, 202),
			Vector2(4200, 272)
		]
	},
	{
		"path": "res://scenes/rice_field/level_2_2.tscn",
		"name": "Level_2_2",
		"level_idx": 4,
		"theme": "Rice Field",
		"enemies_aswang": [
			Vector2(550, 182),
			Vector2(600, 272),
			Vector2(1600, 240),
			Vector2(1750, 142),
			Vector2(2100, 240),
			Vector2(3050, 162),
			Vector2(3200, 272),
			Vector2(4400, 152),
			Vector2(4500, 240)
		]
	},
	{
		"path": "res://scenes/rice_field/level_2_3.tscn",
		"name": "Level_2_3",
		"level_idx": 5,
		"theme": "Rice Field",
		"enemies_aswang": [
			Vector2(450, 182),
			Vector2(600, 272),
			Vector2(1400, 240),
			Vector2(1500, 142),
			Vector2(1800, 240),
			Vector2(2130, 172),
			Vector2(2600, 112),
			Vector2(2800, 208),
			Vector2(3800, 260),
			Vector2(4000, 152),
			Vector2(4400, 260)
		]
	}
]

func set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://scenes/forest")
	DirAccess.make_dir_recursive_absolute("res://scenes/rice_field")
	
	var tileset_res = load("res://scenes/tileset.tres")
	
	for cfg in SCENES_CONFIG:
		print("Re-baking %s with matching canopy trees and pure Aswang encounters..." % cfg["name"])
		var root_node = Node2D.new()
		root_node.name = cfg["name"]
		
		var lvl_data = LevelBuilderScript.get_level_layout(cfg["level_idx"], cfg["theme"])
		var water_gaps: Array = lvl_data["water_gaps"]
		
		# 1. BaseGround (TileMapLayer)
		var base_ground = TileMapLayer.new()
		base_ground.name = "BaseGround"
		base_ground.tile_set = tileset_res
		root_node.add_child(base_ground)
		
		for seg in lvl_data["ground_segments"]:
			var start_col = int(floor(seg["start_x"] / 32.0))
			var end_col = int(ceil(seg["end_x"] / 32.0))
			var top_row = int(round(seg["y"] / 32.0))
			
			for col in range(start_col, end_col):
				var col_center_x = col * 32.0 + 16.0
				var in_water = false
				for wg in water_gaps:
					if col_center_x >= wg["x"] and col_center_x <= wg["x"] + wg["w"]:
						in_water = true
						break
				if in_water:
					continue
				
				# Top grass/earth surface tile with physics
				base_ground.set_cell(Vector2i(col, top_row), 0, Vector2i(2, 0))
				# Subsurface dirt extending deep down to row 24
				for row in range(top_row + 1, 24):
					base_ground.set_cell(Vector2i(col, row), 0, Vector2i(6, 1))
		
		# 2. Water Gaps (Painted directly into BaseGround TileMapLayer: Surface, Depth, and Abyss Fill)
		for gap in water_gaps:
			var gx: float = gap["x"]
			var gw: float = gap["w"]
			var gy: float = gap["y"]
			var water_start_col = int(floor(gx / 32.0))
			var water_end_col = int(ceil((gx + gw) / 32.0))
			var water_row = int(round(gy / 32.0)) # Row 10
			
			for col in range(water_start_col, water_end_col):
				# Top animated water surface: Row 0 of animated water tiles
				base_ground.set_cell(Vector2i(col, water_row), 2, Vector2i(0, 0))
				# Continuous Full Block Water Body: Row 1 of animated water tiles (animated caustics, seamless vertically)
				for body_row in range(water_row + 1, 24):
					base_ground.set_cell(Vector2i(col, body_row), 2, Vector2i(0, 1))
		
		# 3. Platforms (Painted directly into BaseGround TileMapLayer: Wooden Platform Tiles)
		for p in lvl_data["platforms"]:
			var px: float = p["x"]
			var py: float = p["y"]
			var pw: float = p["w"]
			var p_start_col = int(floor(px / 32.0))
			var p_end_col = int(ceil((px + pw) / 32.0))
			var p_row = int(round(py / 32.0))
			var span = p_end_col - p_start_col
			
			for col in range(p_start_col, p_end_col):
				if span <= 1:
					base_ground.set_cell(Vector2i(col, p_row), 0, Vector2i(0, 6))
				elif col == p_start_col:
					base_ground.set_cell(Vector2i(col, p_row), 0, Vector2i(0, 6))
				elif col == p_end_col - 1:
					base_ground.set_cell(Vector2i(col, p_row), 0, Vector2i(2, 6))
				else:
					base_ground.set_cell(Vector2i(col, p_row), 0, Vector2i(1, 6))
		
		# 4. Foliage (Node2D)
		var foliage_container = Node2D.new()
		foliage_container.name = "Foliage"
		root_node.add_child(foliage_container)
		
		var wind_mat = ShaderMaterial.new()
		wind_mat.shader = WIND_SHADER
		wind_mat.set_shader_parameter("wind_speed", 1.8)
		wind_mat.set_shader_parameter("wind_strength", 4.5)
		wind_mat.set_shader_parameter("wind_detail", 2.0)
		
		var f_idx = 1
		for item in lvl_data["foliage"]:
			var type: String = item["type"]
			if type == "wheat_strip":
				var wx: float = item["x"]
				var wy: float = item["y"]
				var wlen: float = item["len"]
				var count: int = int(wlen / 64.0)
				for i in range(count):
					var stalk = Sprite2D.new()
					stalk.name = "Wheat_%02d_%02d" % [f_idx, i]
					stalk.texture = WHEAT_TEX
					stalk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					stalk.material = wind_mat
					stalk.position = Vector2(wx + i * 64.0, wy - 16.0)
					stalk.z_index = 2 if (i % 2 == 0) else -1
					foliage_container.add_child(stalk)
				f_idx += 1
				continue
			
			var spr = Sprite2D.new()
			spr.name = "%s_%02d" % [type.capitalize().replace(" ", ""), f_idx]
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.material = wind_mat
			spr.z_index = -2
			
			var pos_x: float = item["x"]
			var pos_y: float = item["y"]
			var s: float = item.get("scale", 1.0)
			spr.scale = Vector2(s, s)
			
			match type:
				"canopy_large":
					spr.texture = CANOPY_LARGE_TEX
					spr.position = Vector2(pos_x, pos_y - 80.0 * s)
				"canopy_medium":
					spr.texture = CANOPY_MEDIUM_TEX
					spr.position = Vector2(pos_x, pos_y - 64.0 * s)
				"canopy_cluster":
					spr.texture = CANOPY_CLUSTER_TEX
					spr.position = Vector2(pos_x, pos_y - 44.0 * s)
				"banana":
					spr.texture = BANANA_TEX
					spr.scale = Vector2(0.5 * s, 0.5 * s)
					spr.position = Vector2(pos_x, pos_y - 48.0 * s)
			
			foliage_container.add_child(spr)
			f_idx += 1
		
		# 5. Props (Node2D)
		var props_container = Node2D.new()
		props_container.name = "Props"
		root_node.add_child(props_container)
		
		var prop_idx = 1
		for item in lvl_data["props"]:
			var type: String = item["type"]
			var px: float = item["x"]
			var py: float = item["y"]
			
			var spr = Sprite2D.new()
			spr.name = "%s_%02d" % [type.capitalize(), prop_idx]
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
			prop_idx += 1
		
		# 6. Torches (Node2D)
		var torch_container = Node2D.new()
		torch_container.name = "Torches"
		root_node.add_child(torch_container)
		
		var t_idx = 1
		for item in lvl_data["torches"]:
			var t_type = EnvironmentTorch.Type.TORCH if item["type"] == "torch" else EnvironmentTorch.Type.LANTERN
			var torch = EnvironmentTorchScript.new()
			torch.name = "Torch_%02d" % t_idx if item["type"] == "torch" else "Lantern_%02d" % t_idx
			torch.torch_type = t_type
			torch.position = Vector2(item["x"], item["y"])
			torch_container.add_child(torch)
			t_idx += 1
		
		# 7. Breakables (Node2D)
		var pots_container = Node2D.new()
		pots_container.name = "Breakables"
		root_node.add_child(pots_container)
		
		var pot_idx = 1
		for pos in lvl_data["pots"]:
			var pot = PalayokPotScript.new()
			pot.name = "PalayokPot_%02d" % pot_idx
			pot.position = pos
			pots_container.add_child(pot)
			pot_idx += 1
		
		# 8. Enemies (Node2D) - Pure Aswang Encounters (Zero Skeletons)
		var enemies_container = Node2D.new()
		enemies_container.name = "Enemies"
		root_node.add_child(enemies_container)
		
		var a_idx = 1
		for pos in cfg["enemies_aswang"]:
			var aswang = AswangScript.new()
			aswang.name = "Aswang_%02d" % a_idx
			aswang.position = pos
			enemies_container.add_child(aswang)
			a_idx += 1
		
		# 9. LevelExitPortal (Sprite2D)
		var portal = Sprite2D.new()
		portal.name = "LevelExitPortal"
		portal.texture = PORTAL_TEX
		portal.region_enabled = true
		portal.region_rect = Rect2(0, 0, 64, 64)
		portal.position = Vector2(4900.0, 288.0)
		portal.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		root_node.add_child(portal)
		
		# Recursive owner assignment
		set_owner_recursive(root_node, root_node)
		
		var packed = PackedScene.new()
		var pack_err = packed.pack(root_node)
		if pack_err != OK:
			printerr("Error packing %s: %d" % [cfg["name"], pack_err])
			continue
		
		var save_err = ResourceSaver.save(packed, cfg["path"])
		if save_err != OK:
			printerr("Error saving %s to %s: %d" % [cfg["name"], cfg["path"], save_err])
		else:
			print("Successfully baked: %s" % cfg["path"])
	
	print("ALL 6 SCENES RE-BAKED WITH NEW CANOPY TREES & ZERO SKELETONS!")
	quit(0)

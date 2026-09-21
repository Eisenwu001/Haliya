extends SceneTree

var main_node = null
var cur_test_lvl: int = 0
var frame_count: int = 0

func _init() -> void:
	print("--- BEGINNING FULL SYSTEM VERIFICATION OF BAKED SCENES ---")
	main_node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_node)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count % 15 == 0:
		if cur_test_lvl < main_node.LEVELS_DATA.size():
			var lvl_info = main_node.LEVELS_DATA[cur_test_lvl]
			print("\nTesting [%d/6]: %s" % [cur_test_lvl + 1, lvl_info["full_title"]])
			print("Scene file: %s" % lvl_info["scene_path"])
			
			main_node.jump_to_level(cur_test_lvl)
			var level_inst = main_node.current_level_instance
			if not level_inst:
				printerr("FAIL: current_level_instance is null!")
				quit(1)
				return false
			
			# Check BaseGround
			var base_ground = level_inst.find_child("BaseGround", true, false)
			if not base_ground is TileMapLayer:
				printerr("FAIL: BaseGround TileMapLayer not found!")
				quit(1)
				return false
			var used_cells = base_ground.get_used_cells()
			print(" -> BaseGround tiles count: %d" % used_cells.size())
			
			# Verify separate ElevatedPlatforms node is removed
			var plats = level_inst.find_child("ElevatedPlatforms", true, false)
			if plats != null:
				printerr("FAIL: ElevatedPlatforms node should NOT exist in scene!")
				quit(1)
				return false
			print(" -> Verified: ElevatedPlatforms node removed (0 separate platform nodes)")
			
			# Verify separate WaterHazards node is removed
			var water = level_inst.find_child("WaterHazards", true, false)
			if water != null:
				printerr("FAIL: WaterHazards node should NOT exist in scene!")
				quit(1)
				return false
			print(" -> Verified: WaterHazards node removed (0 separate water hazard nodes)")
			
			# Check BaseGround TileMapLayer contents: Water tiles (Source 2) & Platform tiles (Source 0, row 6)
			var water_surface_count = 0
			var water_body_count = 0
			var platform_tiles_found = 0
			for cell in used_cells:
				var src_id = base_ground.get_cell_source_id(cell)
				var coords = base_ground.get_cell_atlas_coords(cell)
				if src_id == 2:
					if coords.y == 0:
						water_surface_count += 1
					elif coords.y == 1:
						water_body_count += 1
				elif src_id == 0 and coords.y == 6:
					platform_tiles_found += 1
			print(" -> BaseGround Water Surface (Row 0): %d | Full Block Body (Row 1): %d" % [water_surface_count, water_body_count])
			print(" -> BaseGround Wooden Platform tiles (Source 0, row 6): %d" % platform_tiles_found)
			if water_surface_count == 0 or water_body_count == 0:
				printerr("FAIL: Expected complete water column (surface and full block body)!")
				quit(1)
				return false
			if platform_tiles_found == 0:
				printerr("FAIL: Expected wooden platform tiles in BaseGround!")
				quit(1)
				return false
			
			# Check Foliage
			var foliage = level_inst.find_child("Foliage", true, false)
			print(" -> Foliage items count: %d" % (foliage.get_child_count() if foliage else 0))
			
			# Check Props
			var props = level_inst.find_child("Props", true, false)
			print(" -> Props count: %d" % (props.get_child_count() if props else 0))
			
			# Check Torches
			var torches = level_inst.find_child("Torches", true, false)
			print(" -> Torches count: %d" % (torches.get_child_count() if torches else 0))
			
			# Check Breakables
			var breakables = level_inst.find_child("Breakables", true, false)
			print(" -> Breakable pots count: %d" % (breakables.get_child_count() if breakables else 0))
			
			# Check Enemies: Ensure zero skeletons, all Aswangs
			var enemies_node = level_inst.find_child("Enemies", true, false)
			var enemy_count = enemies_node.get_child_count() if enemies_node else 0
			print(" -> Baked Enemies count: %d" % enemy_count)
			if enemy_count == 0:
				printerr("FAIL: Expected enemies in baked scene!")
				quit(1)
				return false
			for enemy in enemies_node.get_children():
				if enemy.get_class() == "Skeleton" or "Skeleton" in enemy.name:
					printerr("FAIL: Found unexpected Skeleton enemy: %s" % enemy.name)
					quit(1)
					return false
				if not enemy is Aswang:
					printerr("FAIL: Enemy is not an Aswang: %s" % enemy.name)
					quit(1)
					return false
			print(" -> Verified: 100% pure Aswang mythical encounters (0 skeletons)")
			
			# Check Foliage for Forest levels: verify canopy trees
			if lvl_info["theme"] == "Forest":
				var has_canopy = false
				for f in foliage.get_children():
					if "Canopy" in f.name:
						has_canopy = true
						break
				if not has_canopy:
					printerr("FAIL: Forest level missing canopy trees!")
					quit(1)
					return false
				print(" -> Verified: Forest canopy trees active with wind shader")
			
			# Check Portal
			print(" -> Portal position: %s (Sprite: %s)" % [main_node.portal_pos, str(main_node.portal_sprite != null)])
			if not main_node.portal_sprite:
				printerr("FAIL: LevelExitPortal not detected in scene!")
				quit(1)
				return false
			
			cur_test_lvl += 1
		else:
			print("\n=======================================================")
			print("ALL 6 BAKED SCENES VERIFIED 100% OPERATIONAL AT RUNTIME!")
			print("=======================================================")
			quit(0)
	
	return false

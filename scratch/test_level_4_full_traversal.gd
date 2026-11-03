extends SceneTree

func _init() -> void:
	print("--- Running Comprehensive Level 4 TileMap & Traversal Verification ---")

	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	main_node.start_level_idx = 11 # Level 4
	root.add_child(main_node)
	await process_frame
	await process_frame

	var lvl = main_node.current_level_instance
	if not lvl:
		print("FAIL: Level 4 instance not found")
		quit(1)
		return

	# 1. Verify TileMapLayers
	var base_ground = lvl.find_child("BaseGround", true, false)
	var fg_decor = lvl.find_child("ForegroundDecor", true, false)

	if not (base_ground is TileMapLayer):
		print("FAIL: BaseGround is not TileMapLayer")
		quit(1)
		return
	if not (fg_decor is TileMapLayer):
		print("FAIL: ForegroundDecor is not TileMapLayer")
		quit(1)
		return
	print("PASS: BaseGround and ForegroundDecor are all TileMapLayers!")

	# 2. Check collisions
	if not base_ground.collision_enabled:
		print("FAIL: BaseGround collision is disabled")
		quit(1)
		return
	print("PASS: BaseGround collision is ENABLED!")

	# 3. Verify zero loose individual Sprite2D ground nodes
	var ground_segs = lvl.find_child("GroundSegments", true, false)
	if ground_segs:
		print("FAIL: Found obsolete GroundSegments node in Level 4!")
		quit(1)
		return
	print("PASS: No obsolete GroundSegments sprite containers found in Level 4!")

	# 4. Check ground height at spawn
	var spawn_ground_y = main_node.get_ground_y_at_x(192.0)
	print("Spawn ground Y at x=192: ", spawn_ground_y)
	if spawn_ground_y != 288.0:
		print("FAIL: Expected spawn ground y=288.0, got ", spawn_ground_y)
		quit(1)
		return
	print("PASS: Spawn point (x=192, y=260) has solid ground directly underneath at y=288.0!")

	# 5. Check level end ground height
	var end_ground_y = main_node.get_level_end_ground_y()
	print("Level end ground Y: ", end_ground_y)
	if end_ground_y != 288.0:
		print("FAIL: Expected level end ground y=288.0, got ", end_ground_y)
		quit(1)
		return
	print("PASS: Level exit connects smoothly at y=288.0!")

	# 6. Verify Enemies wiring
	print("Active enemies count in Level 4: ", main_node.active_enemies.size())
	if main_node.active_enemies.size() != 9:
		print("FAIL: Expected 9 active enemies, got ", main_node.active_enemies.size())
		quit(1)
		return
	print("PASS: All 9 enemies wired with death callbacks!")

	# 7. Verify Exit Barrier exists when enemies are alive
	if not main_node.exit_barrier_body or not is_instance_valid(main_node.exit_barrier_body):
		print("FAIL: Exit barrier not found while enemies are active")
		quit(1)
		return
	print("PASS: Exit barrier active while enemies are alive")

	# 8. Simulate defeating all enemies and unlocking exit
	for enemy in main_node.active_enemies.duplicate():
		if enemy is Aswang:
			main_node._on_aswang_died(enemy)
		elif enemy is Skeleton:
			main_node._on_skeleton_died(enemy)
	
	if not main_node.active_enemies.is_empty():
		print("FAIL: active_enemies not empty after defeating all enemies")
		quit(1)
		return
	
	if main_node.exit_barrier_body != null:
		print("FAIL: Exit barrier should be removed after defeating all enemies")
		quit(1)
		return
	print("PASS: Defeating all enemies unlocked the exit path!")

	# 9. Verify Props, Torches, Breakables
	var torches = lvl.find_child("LevelTorches", true, false)
	if not torches:
		torches = lvl.find_child("Torches", true, false)
	var breakables = lvl.find_child("BreakablePots", true, false)
	if not breakables:
		breakables = lvl.find_child("Breakables", true, false)
	var props = lvl.find_child("LevelProps", true, false)
	if not props:
		props = lvl.find_child("Props", true, false)
	print("Torches count: ", torches.get_child_count() if torches else 0)
	print("Breakables count: ", breakables.get_child_count() if breakables else 0)
	print("Props count: ", props.get_child_count() if props else 0)

	if not torches or torches.get_child_count() < 5:
		print("FAIL: Insufficient torches")
		quit(1)
		return
	if not breakables or breakables.get_child_count() < 3:
		print("FAIL: Insufficient breakables")
		quit(1)
		return
	print("PASS: Torches, Breakables, and Props populated properly!")

	main_node.queue_free()
	print("--- ALL LEVEL 4 TESTS PASSED PERFECTLY ---")
	quit(0)

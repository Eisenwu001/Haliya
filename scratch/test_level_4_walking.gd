extends SceneTree

func _init() -> void:
	print("--- Running Level 4 Walking & Traversal Simulation ---")

	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	main_node.start_level_idx = 11 # Level 4
	root.add_child(main_node)
	await process_frame
	await process_frame

	var player = main_node.player
	if not player:
		print("FAIL: Player not found")
		quit(1)
		return

	# Unlock exit barrier for unobstructed walk test
	for enemy in main_node.active_enemies.duplicate():
		if enemy is Aswang:
			main_node._on_aswang_died(enemy)
		elif enemy is Skeleton:
			main_node._on_skeleton_died(enemy)

	# Step forward across the level by testing each key ground/platform section
	var sample_xs = [
		192.0, 400.0, 700.0, 1000.0, 1180.0, # Entrance
		1300.0, 1450.0,                      # Chasm 1 platform bridges (row 8 = 256)
		1650.0, 1900.0, 2200.0, 2400.0,      # Mineral Ridge
		2600.0, 2750.0,                      # Chasm 2 platform bridges (row 7 = 224)
		2900.0, 3200.0, 3500.0, 3750.0,      # Crystal Terrace (row 7/8 = 224/256)
		3850.0, 4000.0,                      # Chasm 3 platform bridges (row 7/8 = 224/256)
		4250.0, 4500.0, 4800.0, 4900.0, 5050.0 # Exit Plateau (row 9 = 288)
	]

	for target_x in sample_xs:
		var gy = main_node.get_ground_y_at_x(target_x)
		if gy > 350.0:
			print("FAIL: Void gap with no floor or platform detected at x=%.1f (gy=%.1f)" % [target_x, gy])
			quit(1)
			return
		player.global_position = Vector2(target_x, gy)
		player.velocity = Vector2(0, 50.0)
		for f in range(10):
			await physics_frame
		
		print("  Sample x=%.1f (expected surface y=%.1f): player pos = (%.1f, %.1f), is_on_floor = %s" % [
			target_x, gy, player.global_position.x, player.global_position.y, str(player.is_on_floor())
		])
		if not player.is_on_floor():
			print("FAIL: Player not grounded at x=%.1f (y=%.1f)" % [target_x, player.global_position.y])
			quit(1)
			return

	print("PASS: Player is grounded across all critical sampling coordinates from 192 to 5050!")

	# Check transition at edge 5050
	player.global_position = Vector2(5055.0, 280.0)
	await process_frame
	await process_frame
	
	main_node.queue_free()
	print("--- LEVEL 4 WALKING SIMULATION PASSED ---")
	quit(0)

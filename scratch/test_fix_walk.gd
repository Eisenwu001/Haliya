@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	# Apply proposed fixes dynamically to main
	for level_idx in [0, 1, 2, 3]:
		print("\n==========================================")
		print("Testing Level idx: ", level_idx, " (", main.LEVELS_DATA[level_idx]["level_title"], ")")
		main.current_level_idx = level_idx
		main.load_current_level()
		main.spawn_level_enemies()
		await process_frame
		
		# Compute corrected ground y
		var base_ground = main.current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
		var min_surface_y = 9999.0
		for col in range(150, 160):
			for row in range(0, 30):
				if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
					var td = base_ground.get_cell_tile_data(Vector2i(col, row))
					if td and td.get_collision_polygons_count(0) > 0:
						var wy = row * 32.0
						min_surface_y = min(min_surface_y, wy)
		print("  Calculated surface Y: ", min_surface_y)
		
		# Reposition RightExtendedFloor & remove ExitBarrier
		if main.exit_barrier_body and is_instance_valid(main.exit_barrier_body):
			main.exit_barrier_body.queue_free()
			main.exit_barrier_body = null
			
		var right_floor = main.map_boundaries_root.get_node_or_null("RightExtendedFloor")
		if right_floor:
			right_floor.position = Vector2(5120.0 + 250.0, min_surface_y + 32.0)
			
		# Test walk from 4800 to 5100
		var player = main.player
		player.global_position = Vector2(4800.0, min_surface_y - 20.0)
		var blocked = false
		for step in range(150): # 2.5s
			player.velocity.x = 200.0
			player.velocity.y += 980.0 * 0.01666
			player.move_and_slide()
			for i in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(i)
				var normal = col.get_normal()
				if normal.x < -0.5:
					print("  BLOCKED at x=", player.global_position.x, " by ", col.get_collider().name)
					blocked = true
					break
			if blocked or player.global_position.x >= 5050.0:
				break
				
		if not blocked:
			print("  SUCCESS: Reached transition point x=", player.global_position.x, " smoothly!")
	
	main.free()
	quit()

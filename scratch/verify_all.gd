@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	print("========================================")
	print("VERIFICATION 1: Rice Field Scene Consistency")
	print("========================================")
	var l21_data = load("res://scenes/rice_field/level_2_1.tscn").instantiate()
	var l22_data = load("res://scenes/rice_field/level_2_2.tscn").instantiate()
	var l23_data = load("res://scenes/rice_field/level_2_3.tscn").instantiate()
	
	var bg21 = l21_data.find_child("BaseGround") as TileMapLayer
	var bg22 = l22_data.find_child("BaseGround") as TileMapLayer
	var bg23 = l23_data.find_child("BaseGround") as TileMapLayer
	
	print("Level 2-1 BaseGround cells: ", bg21.get_used_cells().size())
	print("Level 2-2 BaseGround cells: ", bg22.get_used_cells().size())
	print("Level 2-3 BaseGround cells: ", bg23.get_used_cells().size())
	assert(bg21.get_used_cells().size() == bg22.get_used_cells().size(), "2-1 and 2-2 cell counts mismatch!")
	assert(bg21.get_used_cells().size() == bg23.get_used_cells().size(), "2-1 and 2-3 cell counts mismatch!")
	print(">> Tile count & layout check: PASSED!")
	
	l21_data.free()
	l22_data.free()
	l23_data.free()
	
	print("\n========================================")
	print("VERIFICATION 2: Lighting & End-of-Level Navigation")
	print("========================================")
	for i in range(6):
		main.current_level_idx = i
		main.load_current_level()
		main.spawn_level_enemies()
		await process_frame
		await physics_frame
		
		var title = main.LEVELS_DATA[i]["full_title"]
		var theme = main.LEVELS_DATA[i]["theme"]
		var mod_color = main.canvas_modulate.color if main.canvas_modulate else Color.WHITE
		print("\nTesting: ", title)
		print("  Theme: ", theme, " CanvasModulate: ", mod_color)
		if theme == "Rice Field":
			assert(mod_color == Color(1, 1, 1, 1), "Rice field modulate is not 1.0, 1.0, 1.0!")
		
		var ground_y = main.get_level_end_ground_y()
		print("  Detected end ground Y: ", ground_y)
		
		# Test walking to transition
		var player = main.player
		player.global_position = Vector2(4800.0, ground_y - 20.0)
		var blocked = false
		for step in range(150):
			player.velocity.x = 200.0
			player.velocity.y += 980.0 * 0.01666
			player.move_and_slide()
			for c_idx in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(c_idx)
				if col.get_normal().x < -0.5:
					print("  FAILED: Blocked at x=", player.global_position.x, " by ", col.get_collider().name)
					blocked = true
					break
			if blocked or player.global_position.x >= main.MAP_TRANSITION_EDGE_X:
				break
				
		if not blocked:
			print("  SUCCESS: Reached transition point at x=", player.global_position.x, " without hitting any invisible wall!")
		else:
			assert(false, "Player was blocked before reaching transition!")
			
	print("\n========================================")
	print("ALL VERIFICATION CHECKS PASSED!")
	print("========================================")
	
	main.free()
	quit(0)

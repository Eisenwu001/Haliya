@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	# Test each level from 0 to 5
	for level_idx in range(6):
		main.current_level_idx = level_idx
		main.load_current_level()
		main.spawn_level_enemies()
		await process_frame
		
		var title = main.LEVELS_DATA[level_idx]["level_title"]
		print("==========================================")
		print("Testing: ", title)
		
		# Apply the fix to map boundaries
		if main.map_boundaries_root:
			main.map_boundaries_root.queue_free()
		
		main.map_boundaries_root = Node2D.new()
		main.map_boundaries_root.name = "MapBoundaries"
		main.add_child(main.map_boundaries_root)
		
		# Left boundary
		var left_wall := StaticBody2D.new()
		left_wall.collision_layer = 1
		left_wall.collision_mask = 0
		var left_shape := CollisionShape2D.new()
		var left_rect := RectangleShape2D.new()
		left_rect.size = Vector2(32.0, 900.0)
		left_shape.shape = left_rect
		left_wall.position = Vector2(-16.0, 150.0)
		left_wall.add_child(left_shape)
		main.map_boundaries_root.add_child(left_wall)
		
		# Right floor: starts at 5120.0
		# find actual ground surface Y
		var base_ground = main.current_level_instance.find_child("BaseGround", true, false) as TileMapLayer
		var ground_y = 288.0
		if base_ground:
			var min_y = 9999.0
			for col in range(150, 160):
				for row in range(0, 30):
					if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
						var td = base_ground.get_cell_tile_data(Vector2i(col, row))
						if td and td.get_collision_polygons_count(0) > 0:
							min_y = min(min_y, row * 32.0)
			if min_y < 9000.0:
				ground_y = min_y
		print("  Surface Y at end: ", ground_y)
		
		var right_floor := StaticBody2D.new()
		right_floor.collision_layer = 1
		right_floor.collision_mask = 0
		var floor_shape := CollisionShape2D.new()
		var floor_rect := RectangleShape2D.new()
		floor_rect.size = Vector2(500.0, 64.0)
		floor_shape.shape = floor_rect
		right_floor.position = Vector2(5120.0 + 250.0, ground_y + 32.0)
		right_floor.add_child(floor_shape)
		main.map_boundaries_root.add_child(right_floor)
		
		# Right wall: at 5500.0
		var backstop := StaticBody2D.new()
		backstop.collision_layer = 1
		backstop.collision_mask = 0
		var backstop_shape := CollisionShape2D.new()
		var backstop_rect := RectangleShape2D.new()
		backstop_rect.size = Vector2(32.0, 900.0)
		backstop_shape.shape = backstop_rect
		backstop.position = Vector2(5500.0, 150.0)
		backstop.add_child(backstop_shape)
		main.map_boundaries_root.add_child(backstop)
		
		await process_frame
		await physics_frame
		
		# Test player walk from 4800 to 5100
		var player = main.player
		player.global_position = Vector2(4800.0, ground_y - 20.0)
		var blocked = false
		for step in range(150):
			player.velocity.x = 200.0
			player.velocity.y += 980.0 * 0.01666
			player.move_and_slide()
			for i in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(i)
				if col.get_normal().x < -0.5:
					print("  BLOCKED at x=", player.global_position.x, " by ", col.get_collider().name)
					blocked = true
					break
			if blocked or player.global_position.x >= 5050.0:
				break
				
		if not blocked:
			print("  SUCCESS: Reached transition point at x=", player.global_position.x)
	
	main.free()
	quit()

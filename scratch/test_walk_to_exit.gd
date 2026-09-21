@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	# Current level is 0 (Level 1-1)
	print("--- Testing Level 1-1 ---")
	test_walk(main)
	
	# Switch to level 3 (Level 2-1)
	print("\n--- Testing Level 2-1 ---")
	main.current_level_idx = 3
	main.load_current_level()
	main.spawn_level_enemies()
	await process_frame
	test_walk(main)
	
	main.free()
	quit()

func test_walk(main):
	var player = main.player
	var ground_y = main.get_level_end_ground_y()
	print("Level: ", main.LEVELS_DATA[main.current_level_idx]["level_title"], " ground_end_y: ", ground_y)
	
	# Place player at x=4800 on the ground
	# In player.gd, let's see player's standing y
	player.global_position = Vector2(4800.0, ground_y - 20.0)
	player.velocity = Vector2(200.0, 0.0)
	
	var blocked_at = -1.0
	for step in range(120): # 2 seconds at 60 fps
		# simulate physics step
		player.velocity.x = 200.0
		player.velocity.y += 980.0 * 0.01666
		player.move_and_slide()
		if player.get_slide_collision_count() > 0:
			for i in range(player.get_slide_collision_count()):
				var col = player.get_slide_collision(i)
				var collider = col.get_collider()
				var normal = col.get_normal()
				# If hit a vertical wall (normal.x < -0.5)
				if normal.x < -0.5:
					print("  BLOCKED! at x=", player.global_position.x, " y=", player.global_position.y, " by collider: ", collider.name if collider else "unknown", " normal: ", normal)
					blocked_at = player.global_position.x
					break
		if blocked_at > 0:
			break
			
	if blocked_at < 0:
		print("  Walked cleanly to x=", player.global_position.x)

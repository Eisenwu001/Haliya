@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	var right_floor = main.map_boundaries_root.get_node_or_null("RightExtendedFloor")
	print("Initial right_floor pos: ", right_floor.position)
	print("Initial right_floor global_pos: ", right_floor.global_position)
	
	# Let's inspect its shape and shape position
	for child in right_floor.get_children():
		print("  child: ", child.name, " shape: ", child.get("shape"), " shape pos: ", child.position)
		if child is CollisionShape2D:
			print("  shape rect size: ", child.shape.size)
			
	# What if we queue_free RightExtendedFloor completely?
	right_floor.queue_free()
	if main.exit_barrier_body and is_instance_valid(main.exit_barrier_body):
		main.exit_barrier_body.queue_free()
	await process_frame
	await physics_frame
	
	# Test walk with NO RightExtendedFloor at all
	var player = main.player
	player.global_position = Vector2(4800.0, 268.0)
	var blocked = false
	for step in range(150):
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
		print("  SUCCESS: Walked to x=", player.global_position.x, " without any block!")
		
	main.free()
	quit()

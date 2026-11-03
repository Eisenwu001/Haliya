extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	for lvl_idx in [11, 12, 13, 14]:
		MainScript.start_level_idx = lvl_idx
		main.jump_to_level(lvl_idx)
		for f in range(10):
			await process_frame
			
		var p = main.player
		print("\n==========================================")
		print("SIMULATING PLAYER IN LEVEL ", lvl_idx, " (", main.LEVELS_DATA[lvl_idx]["level_title"], ")")
		print("==========================================")
		
		# Let's test player at various points across the level
		# Sample x = 200, 300, 400, 500, 1600, 1800, 2000, 3500, 3700, 4000, 4800, 5000
		var test_xs = [192.0, 250.0, 350.0, 450.0, 1600.0, 1800.0, 2000.0, 3500.0, 3800.0, 4800.0, 5000.0]
		for tx in test_xs:
			p.global_position = Vector2(tx, 200.0)
			p.velocity = Vector2.ZERO
			for f in range(25):
				p._physics_process(1.0 / 60.0)
			
			var standing_y = p.global_position.y
			var on_floor = p.is_on_floor()
			# Determine what floor was hit
			var space = p.get_world_2d().direct_space_state
			var q = PhysicsRayQueryParameters2D.create(p.global_position + Vector2(0, -5), p.global_position + Vector2(0, 25))
			q.exclude = [p.get_rid()]
			var res = space.intersect_ray(q)
			var floor_name = res.collider.name if res else "NONE"
			print("  X=", tx, " -> Player settled Y=", standing_y, " on_floor=", on_floor, " collider=", floor_name)

	main.free()
	quit(0)

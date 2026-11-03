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
		print("TESTING GROUND STEPPING IN LEVEL ", lvl_idx, " (", main.LEVELS_DATA[lvl_idx]["level_title"], ")")
		print("==========================================")
		
		# Test on BaseGround at x = 100, 200, 300, 500, 1600, 1800, 2000, 3600, 3800, 4800, 5000
		var test_xs = [100.0, 200.0, 300.0, 500.0, 1600.0, 1800.0, 2000.0, 3600.0, 3800.0, 4800.0, 5000.0]
		for tx in test_xs:
			p.global_position = Vector2(tx, 270.0)
			p.velocity = Vector2.ZERO
			for f in range(40):
				p._physics_process(1.0 / 60.0)
			
			var standing_y = p.global_position.y
			var on_floor = p.is_on_floor()
			var space = p.get_world_2d().direct_space_state
			var q = PhysicsRayQueryParameters2D.create(Vector2(tx, 200.0), Vector2(tx, 350.0))
			q.exclude = [p.get_rid()]
			var res = space.intersect_ray(q)
			var col_name = res.collider.name if res else "NONE"
			var hit_y = res.position.y if res else -1.0
			print("  X=", tx, " -> Player Y=", standing_y, " on_floor=", on_floor, " Hit Y=", hit_y, " col=", col_name)

	main.free()
	quit(0)

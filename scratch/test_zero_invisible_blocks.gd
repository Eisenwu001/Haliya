extends SceneTree

func _init() -> void:
	print("=======================================================")
	print("HIGH-DENSITY PHYSICS RAYCAST SWEEP: 0 INVISIBLE BLOCKS")
	print("=======================================================")

	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var cave_indices = [
		{"idx": 11, "name": "Level 4-1"},
		{"idx": 12, "name": "Level 4-2"},
		{"idx": 13, "name": "Level 4-3"},
		{"idx": 14, "name": "Level 5"}
	]

	for lvl in cave_indices:
		print("\n--- Sweeping %s (Index %d) ---" % [lvl.name, lvl.idx])
		main.jump_to_level(lvl.idx)
		await physics_frame
		await physics_frame

		var p = main.player
		var space = p.get_world_2d().direct_space_state
		var invisible_hits = []
		var ground_hits = 0
		var platform_hits = 0

		# Cast rays across playable level width (Y=80 to Y=320)
		for x in range(64, 4980, 16):
			var query = PhysicsRayQueryParameters2D.create(Vector2(x, 80), Vector2(x, 320))
			query.exclude = [p.get_rid()]
			var res = space.intersect_ray(query)
			if res:
				var col = res.collider
				var col_name = col.name if col else "null"
				var col_parent = col.get_parent().name if (col and col.get_parent()) else ""

				if col_name == "BaseGround":
					ground_hits += 1
				elif "CavePlatform" in col_name or "CrumbleLedge" in col_name or col_parent == "ElevatedPlatforms":
					platform_hits += 1
				elif "Enemy" in col_parent or "Enemies" in col_parent or col is CharacterBody2D:
					pass # Enemy collider
				elif col_name == "ExitBarrierBody" or col_parent == "MapBoundaries" or col_name == "LeftBoundary" or col_name == "RightBoundary":
					pass # Boundary or dynamic transition barrier
				else:
					invisible_hits.append({
						"x": x,
						"hit_y": res.position.y,
						"col": col_name,
						"parent": col_parent
					})

		print("  Raycast stats: ground_hits=%d, platform_hits=%d, invisible_blocks=%d" % [ground_hits, platform_hits, invisible_hits.size()])
		for inv in invisible_hits:
			print("  [ERROR] Invisible block detected at X=%0.1f, Y=%0.1f! Name=%s, Parent=%s" % [inv.x, inv.hit_y, inv.col, inv.parent])

		assert(invisible_hits.size() == 0, "Found %d invisible blocks in %s!" % [invisible_hits.size(), lvl.name])
		print("  [PASS] ZERO invisible blocks in %s!" % lvl.name)

	print("\n=======================================================")
	print("ALL CAVE LEVELS VERIFIED: STRICTLY 0 INVISIBLE BLOCKS!")
	print("=======================================================")
	main.free()
	quit(0)

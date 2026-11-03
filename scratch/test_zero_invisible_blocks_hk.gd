extends SceneTree

func _init() -> void:
	print("=======================================================")
	print("RAYCAST SWEEP: ZERO INVISIBLE BLOCKS (HK LEVEL 4-1)")
	print("=======================================================")

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	main.jump_to_level(11) # Level 4-1
	await physics_frame
	await physics_frame

	var p = main.player
	var space = p.get_world_2d().direct_space_state
	var invisible_hits = []
	var ground_hits = 0
	var platform_hits = 0

	# 1. Sweep Upper Chamber 1: X=64..1000, Y=80..320
	for x in range(64, 1000, 16):
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
				pass
			else:
				invisible_hits.append({"x": x, "y": res.position.y, "col": col_name, "parent": col_parent})

	# 2. Sweep Shaft Chamber 2: X=1050..1600, Y=300..900
	for x in range(1050, 1600, 16):
		var query = PhysicsRayQueryParameters2D.create(Vector2(x, 300), Vector2(x, 900))
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
				pass
			else:
				invisible_hits.append({"x": x, "y": res.position.y, "col": col_name, "parent": col_parent})

	# 3. Sweep Deep Grotto Chamber 3: X=1664..3200, Y=640..900
	for x in range(1664, 3200, 16):
		var query = PhysicsRayQueryParameters2D.create(Vector2(x, 640), Vector2(x, 900))
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
				pass
			else:
				invisible_hits.append({"x": x, "y": res.position.y, "col": col_name, "parent": col_parent})

	# 4. Sweep Ascending Cathedral Chamber 4: X=3200..4864, Y=200..900
	for x in range(3200, 4864, 16):
		var query = PhysicsRayQueryParameters2D.create(Vector2(x, 200), Vector2(x, 900))
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
				pass
			else:
				invisible_hits.append({"x": x, "y": res.position.y, "col": col_name, "parent": col_parent})

	# 5. Sweep Upper Sanctuary Chamber 5: X=4896..6250, Y=80..320
	for x in range(4896, 6250, 16):
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
				pass
			elif col_name == "ExitBarrierBody" or col_parent == "MapBoundaries":
				pass
			else:
				invisible_hits.append({"x": x, "y": res.position.y, "col": col_name, "parent": col_parent})

	print("Raycast results: ground_hits=%d, platform_hits=%d, invisible_blocks=%d" % [ground_hits, platform_hits, invisible_hits.size()])
	for inv in invisible_hits:
		print("  [ERROR] Invisible block detected at X=%0.1f, Y=%0.1f! Name=%s, Parent=%s" % [inv.x, inv.y, inv.col, inv.parent])

	assert(invisible_hits.size() == 0, "Found %d invisible blocks!" % invisible_hits.size())
	print("[PASS] STRICTLY 0 INVISIBLE BLOCKS IN HOLLOW KNIGHT LEVEL 4-1!")

	main.free()
	quit(0)

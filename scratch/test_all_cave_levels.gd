extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	
	var cave_levels = [
		{"idx": 11, "name": "Level 4-1"},
		{"idx": 12, "name": "Level 4-2"},
		{"idx": 13, "name": "Level 4-3"},
		{"idx": 14, "name": "Level 5"}
	]
	
	print("=======================================================")
	print("STARTING CAVE LEVELS PHYSICS & TILESET AUDIT")
	print("=======================================================")
	
	for lvl in cave_levels:
		print("\n--- AUDITING %s (Index %d) ---" % [lvl.name, lvl.idx])
		main.jump_to_level(lvl.idx)
		await physics_frame
		
		var p = main.player
		
		# Let player settle using physics frames
		for f in range(40):
			await physics_frame
			
		var on_floor = p.is_on_floor()
		var pos = p.global_position
		print("Spawn check: settled at pos (%0.2f, %0.2f) | on_floor = %s" % [pos.x, pos.y, on_floor])
		assert(on_floor, "Player should be on floor at spawn!")
		assert(abs(pos.y - 288.0) < 0.5, "Player should be exactly on the tile ground surface (Y=288)!")
		
		# Test walking from X=192 to X=600 along ground
		var start_x = pos.x
		var blocked = false
		for step in range(60):
			p.velocity.x = 200.0
			await physics_frame
			if p.is_on_wall():
				print("WARNING: Player hit wall at X=%0.2f, Y=%0.2f!" % [p.global_position.x, p.global_position.y])
				blocked = true
				break
				
		print("Walk check: moved from X=%0.2f to X=%0.2f | Y=%0.2f | wall_blocked=%s" % [start_x, p.global_position.x, p.global_position.y, blocked])
		assert(not blocked, "Player walk path in spawn area must be unblocked!")
		assert(p.global_position.x > start_x + 50.0, "Player must move forward!")
		assert(abs(p.global_position.y - 288.0) < 0.5, "Player should remain flush on the ground while walking!")
		
		# Check all platforms in the level
		var inst = main.current_level_instance
		var elev = inst.find_child("ElevatedPlatforms", true, false)
		if elev:
			var plat_count = elev.get_child_count()
			var valid_plats = 0
			var crumble_count = 0
			for child in elev.get_children():
				if child is StaticBody2D:
					var cs = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
					var spr = child.get_node_or_null("PlatformVisual") as Sprite2D
					if not spr:
						spr = child.get_node_or_null("LedgeSprite") as Sprite2D
					if cs and cs.shape and spr and spr.texture:
						valid_plats += 1
					if "Crumble" in child.name or "crumble" in child.name.to_lower():
						crumble_count += 1
						# Check that CrumbleLedge sprite has valid visible texture region
						if spr and spr.region_enabled:
							var r = spr.region_rect
							assert(r.size.x > 0 and r.size.y > 0, "CrumbleLedge must have non-empty sprite region!")
			print("Platforms check: total=%d, valid (shape+sprite)=%d, crumble_ledges=%d" % [plat_count, valid_plats, crumble_count])
			assert(plat_count == valid_plats, "All elevated platforms must have both collision shape and visual sprite!")
			
		# Check all hazards
		var hazards = inst.find_child("Hazards", true, false)
		if hazards:
			var haz_count = hazards.get_child_count()
			print("Hazards check: total=%d" % haz_count)
			for h in hazards.get_children():
				if h.name.begins_with("SpikeHazard"):
					var spr = h.get_node_or_null("SpikeSprite") as Sprite2D
					assert(spr and spr.texture, "SpikeHazard must have valid texture!")
					
		# Check props (Strictly 0 decor props as requested)
		var props = inst.find_child("LevelProps", true, false)
		var prop_count = props.get_child_count() if props else 0
		print("Props check: total=%d (decor stripped)" % prop_count)
		assert(prop_count == 0, "Cave level must have 0 decorative props!")
			
	print("\n=======================================================")
	print("ALL CAVE LEVELS PASSED THE PHYSICS & TILESET AUDIT!")
	print("=======================================================")
	main.free()
	quit(0)

extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	for lvl_idx in [11, 12, 13, 14]:
		main.jump_to_level(lvl_idx)
		await create_timer(0.2).timeout
		
		var p = main.player
		print("\n--- LEVEL IDX ", lvl_idx, " (", main.LEVELS_DATA[lvl_idx]["level_title"], ") ---")
		print("Spawn pos: ", p.global_position, " is_on_floor: ", p.is_on_floor())
		
		# Let player settle on floor
		for i in range(30):
			await process_frame
		
		print("Settled pos: ", p.global_position, " is_on_floor: ", p.is_on_floor())
		
		# Check if player is floating or what is under player feet
		var space_state = p.get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(p.global_position, p.global_position + Vector2(0, 50))
		query.exclude = [p.get_rid()]
		var result = space_state.intersect_ray(query)
		if result:
			print("Raycast down from player: hit at ", result.position, " collider: ", result.collider, " (name: ", result.collider.name, ")")
		else:
			print("Raycast down from player: NO COLLIDER!")

		# Check elevated platforms and crumble ledges in current scene
		var inst = main.current_level_instance
		if inst:
			var elev = inst.find_child("ElevatedPlatforms", true, false)
			if elev:
				print("ElevatedPlatforms children: ", elev.get_child_count())
				for child in elev.get_children():
					if child is StaticBody2D:
						var cs = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
						var spr = child.get_node_or_null("PlatformVisual") as Sprite2D
						if not spr:
							spr = child.get_node_or_null("LedgeSprite") as Sprite2D
						var spr_rect = spr.region_rect if (spr and spr.region_enabled) else Rect2()
						var shape_sz = cs.shape.size if (cs and cs.shape is RectangleShape2D) else Vector2.ZERO
						# Check if child is at some position
						# print first 3
						if child.get_index() < 4:
							print("  Plat: ", child.name, " pos: ", child.global_position, " shape_sz: ", shape_sz, " spr_rect: ", spr_rect)
			
			var props = inst.find_child("LevelProps", true, false)
			if props:
				print("LevelProps children: ", props.get_child_count())
				for child in props.get_children():
					if child.get_index() < 4:
						print("  Prop: ", child.name, " pos: ", child.global_position, " tex: ", (child.texture.resource_path if (child is Sprite2D and child.texture) else "none"), " region: ", (child.region_rect if (child is Sprite2D) else Rect2()))

	main.free()
	print("\nAUDIT FINISHED")
	quit(0)

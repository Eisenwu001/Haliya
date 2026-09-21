@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	# Let a frame pass
	await process_frame
	
	print("main.current_level_instance: ", main.current_level_instance)
	print("get_level_end_ground_y(): ", main.get_level_end_ground_y())
	
	var boundaries = main.get_node_or_null("MapBoundaries")
	if boundaries:
		for child in boundaries.get_children():
			print("Boundary: ", child.name, " pos: ", child.position)
			if child is StaticBody2D:
				print("  layer: ", child.collision_layer, " mask: ", child.collision_mask)
				for cs in child.get_children():
					if cs is CollisionShape2D:
						print("  shape size: ", cs.shape.get("size"))
	
	main.free()
	quit()

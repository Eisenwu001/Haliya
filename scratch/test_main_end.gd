@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	print("Main initialized. Current level idx: ", main.current_level_idx)
	print("get_level_end_ground_y() returned: ", main.get_level_end_ground_y())
	
	var boundaries = main.get_node_or_null("MapBoundaries")
	if boundaries:
		for child in boundaries.get_children():
			print("Boundary child: ", child.name, " class: ", child.get_class(), " pos: ", child.position)
			if child is StaticBody2D:
				print("  collision_layer: ", child.collision_layer, " mask: ", child.collision_mask)
				for s in child.get_children():
					if s is CollisionShape2D:
						print("  shape: ", s.shape, " size: ", s.shape.get("size") if s.shape else "none")
	
	print("active_enemies count: ", main.active_enemies.size())
	for e in main.active_enemies:
		print("  enemy: ", e.name, " pos: ", e.global_position)
		
	# Check tiles near x=5000-5120
	if main.current_level_instance:
		for child in main.current_level_instance.get_children():
			if child is TileMapLayer:
				print("TileMapLayer: ", child.name)
				for x in range(150, 161):
					for y in range(0, 24):
						var source_id = child.get_cell_source_id(Vector2i(x, y))
						if source_id != -1:
							var td = child.get_cell_tile_data(Vector2i(x, y))
							var polys = td.get_collision_polygons_count(0) if td else 0
							print("  cell (", x, ",", y, ") px=(", x*32, ",", y*32, ") source=", source_id, " coll_polys=", polys)
	
	main.free()
	quit()

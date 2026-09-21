@tool
extends SceneTree

func _init():
	var levels = [
		"res://scenes/forest/level_1_1.tscn",
		"res://scenes/forest/level_1_2.tscn",
		"res://scenes/forest/level_1_3.tscn",
		"res://scenes/rice_field/level_2_1.tscn",
		"res://scenes/rice_field/level_2_2.tscn",
		"res://scenes/rice_field/level_2_3.tscn"
	]
	
	for path in levels:
		print("========================================")
		print("Inspecting end area of: ", path)
		var scene = load(path)
		var instance = scene.instantiate()
		root.add_child(instance)
		
		# Find BaseGround
		var base_ground: TileMapLayer = null
		for child in instance.get_children():
			if child is TileMapLayer and child.name == "BaseGround":
				base_ground = child
				break
		
		if base_ground:
			print("BaseGround tile_set physics layers count: ", base_ground.tile_set.get_physics_layers_count() if base_ground.tile_set else 0)
			# Find right-most column of tiles
			var max_col = -1
			for c in base_ground.get_used_cells():
				if c.x > max_col:
					max_col = c.x
			print("Max col in BaseGround: ", max_col, " (pixel: ", max_col * 32, ")")
			
			# Print columns 155 to 160
			for col in range(155, max_col + 2):
				var rows_in_col = []
				for row in range(0, 30):
					var source = base_ground.get_cell_source_id(Vector2i(col, row))
					if source != -1:
						var atlas_coords = base_ground.get_cell_atlas_coords(Vector2i(col, row))
						var td = base_ground.get_cell_tile_data(Vector2i(col, row))
						var has_coll = td.get_collision_polygons_count(0) > 0 if td else false
						rows_in_col.append(str("r", row, "(y=", row*32, ",coll=", has_coll, ")"))
				if rows_in_col.size() > 0:
					print("  Col ", col, " (x=", col*32, "): ", ", ".join(rows_in_col))
				else:
					print("  Col ", col, " (x=", col*32, "): EMPTY!")
		
		instance.free()
	quit()

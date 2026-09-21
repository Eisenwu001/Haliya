@tool
extends SceneTree

func _init():
	var levels = [
		"res://scenes/forest/level_1_1.tscn",
		"res://scenes/forest/level_1_2.tscn",
		"res://scenes/forest/level_1_3.tscn",
		"res://scenes/rice_field/level_2_1.tscn"
	]
	
	for path in levels:
		print("========================================")
		print("Ground surface for: ", path)
		var scene = load(path)
		var inst = scene.instantiate()
		var base_ground: TileMapLayer = null
		for child in inst.get_children():
			if child is TileMapLayer and child.name == "BaseGround":
				base_ground = child
				break
		if base_ground:
			for col in range(145, 160):
				var top_row = 999
				for row in range(0, 25):
					if base_ground.get_cell_source_id(Vector2i(col, row)) != -1:
						var td = base_ground.get_cell_tile_data(Vector2i(col, row))
						if td and td.get_collision_polygons_count(0) > 0:
							top_row = min(top_row, row)
				print("  Col ", col, " (x=", col*32, "): top_solid_row=", top_row, " (top_y=", top_row*32, ")")
		inst.free()
	quit()

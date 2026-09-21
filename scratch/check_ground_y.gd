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
		var scene = load(path)
		var inst = scene.instantiate()
		
		# Exact code from get_level_end_ground_y
		var end_y: float = 288.0
		for child in inst.get_children():
			if child is TileMapLayer:
				var tm := child as TileMapLayer
				var used = tm.get_used_cells()
				for cell in used:
					if cell.x >= 150:
						var wy = cell.y * (tm.tile_set.tile_size.y if tm.tile_set else 32.0)
						end_y = wy
		print(path, " -> get_level_end_ground_y() = ", end_y)
		inst.free()
	quit()

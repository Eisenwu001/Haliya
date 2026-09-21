extends SceneTree

func _init():
	var s3 = load('res://scenes/scene_03.tscn').instantiate()
	for cell in s3.get_used_cells():
		var src = s3.get_cell_source_id(cell)
		if src == 2 or src == 3:
			print('scene_03 water: cell=', cell, ' src=', src, ' atlas=', s3.get_cell_atlas_coords(cell))
			break
	quit(0)

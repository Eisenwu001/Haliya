extends SceneTree

func _init():
	var s1 = load('res://scenes/scene_01.tscn').instantiate()
	for cell in s1.get_used_cells():
		var src = s1.get_cell_source_id(cell)
		if src == 2 or src == 3:
			print('Water in scene_01 at: ', cell, ' source: ', src)
	print('Finished checking scene_01')
	quit(0)

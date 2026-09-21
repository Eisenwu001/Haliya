extends SceneTree

func _init():
	for i in range(1, 6):
		var path = 'res://scenes/scene_0' + str(i) + '.tscn'
		var s = load(path).instantiate()
		var count = 0
		for cell in s.get_used_cells():
			var src = s.get_cell_source_id(cell)
			if src == 2 or src == 3:
				count += 1
		print(path, ' water tiles: ', count)
	quit(0)

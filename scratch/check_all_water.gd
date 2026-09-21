extends SceneTree

func _init():
	for name in ['forest/level_1_1', 'forest/level_1_2', 'forest/level_1_3', 'rice_field/level_2_1', 'rice_field/level_2_2', 'rice_field/level_2_3']:
		var path = 'res://scenes/' + name + '.tscn'
		var scn = load(path).instantiate()
		var bg = scn.get_node('BaseGround')
		var water_count = 0
		for cell in bg.get_used_cells():
			var src = bg.get_cell_source_id(cell)
			if src == 2 or src == 3:
				water_count += 1
		print(name, ' water tiles in BaseGround: ', water_count)
	quit(0)

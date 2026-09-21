extends SceneTree

func _init():
	var scn = load('res://scenes/scene_01.tscn')
	var inst = scn.instantiate()
	print('Scene_01 used cells: ', inst.get_used_cells().size())
	var cell_counts = {}
	for cell in inst.get_used_cells():
		var src_id = inst.get_cell_source_id(cell)
		var atlas = inst.get_cell_atlas_coords(cell)
		var key = str(src_id) + '_' + str(atlas)
		cell_counts[key] = cell_counts.get(key, 0) + 1
	print('Used tile distribution: ', cell_counts)
	quit(0)

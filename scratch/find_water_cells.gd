extends SceneTree

func _init():
	var scn = load('res://scenes/forest/level_1_1.tscn')
	var inst = scn.instantiate()
	var bg = inst.get_node('BaseGround')
	for cell in bg.get_used_cells():
		var src_id = bg.get_cell_source_id(cell)
		if src_id == 2 or src_id == 3: # water!
			print('BaseGround Water tile at cell: ', cell, ' source: ', src_id, ' atlas: ', bg.get_cell_atlas_coords(cell))
	quit(0)

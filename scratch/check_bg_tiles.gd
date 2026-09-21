extends SceneTree

func _init():
	var scn = load('res://scenes/forest/level_1_1.tscn')
	var inst = scn.instantiate()
	var bg = inst.get_node('BaseGround')
	var ts = bg.tile_set
	print('TileSet sources count: ', ts.get_source_count())
	for i in range(ts.get_source_count()):
		var id = ts.get_source_id(i)
		var src = ts.get_source(id)
		if src is TileSetAtlasSource:
			print('  Source ', id, ': texture=', src.texture.resource_path)
	
	var cell_counts = {}
	for cell in bg.get_used_cells():
		var src_id = bg.get_cell_source_id(cell)
		var atlas = bg.get_cell_atlas_coords(cell)
		var key = str(src_id) + '_' + str(atlas)
		cell_counts[key] = cell_counts.get(key, 0) + 1
	print('Used tile distribution: ', cell_counts)
	quit(0)

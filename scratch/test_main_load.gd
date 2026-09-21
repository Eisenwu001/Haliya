extends SceneTree

func _init():
	var root_node = Node2D.new()
	root.add_child(root_node)
	var main_scn = load('res://scenes/main.tscn')
	var main_inst = main_scn.instantiate()
	root_node.add_child(main_inst)
	
	# Check what level is loaded
	print('current_level_idx: ', main_inst.current_level_idx)
	print('current_level_instance: ', main_inst.current_level_instance.name)
	for child in main_inst.current_level_instance.get_children():
		print('  child: ', child.name, ' (', child.get_class(), ')')
		if child is TileMapLayer:
			print('    cells: ', child.get_used_cells().size())
			# Check first 5 cells
			var cells = child.get_used_cells()
			for i in range(min(5, cells.size())):
				print('      cell ', cells[i], ' source: ', child.get_cell_source_id(cells[i]), ' coords: ', child.get_cell_atlas_coords(cells[i]))
	quit(0)

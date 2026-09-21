extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_03.tscn").instantiate()
	var used = s.get_used_cells()
	var water_cells = []
	var water_atlas = {}
	for c in used:
		if s.get_cell_source_id(c) == 2:
			water_cells.append(c)
			var a = s.get_cell_atlas_coords(c)
			water_atlas[a] = water_atlas.get(a, 0) + 1
	print("scene_03 water cells count: ", water_cells.size())
	print("Atlas coords used for water: ", water_atlas)
	
	# Group by Y rows
	var y_counts = {}
	for c in water_cells:
		y_counts[c.y] = y_counts.get(c.y, 0) + 1
	print("Water rows (Y): ", y_counts)
	
	for a in water_atlas.keys():
		for c in water_cells:
			if s.get_cell_atlas_coords(c) == a:
				print("Sample cell for atlas ", a, " -> cell pos: ", c)
				break
	quit(0)

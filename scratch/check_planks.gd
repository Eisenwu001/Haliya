extends SceneTree

func _init() -> void:
	for i in range(1, 6):
		var p = "res://scenes/scene_%02d.tscn" % i
		var s = load(p).instantiate()
		var used = s.get_used_cells()
		var plank_cells = []
		for c in used:
			var sid = s.get_cell_source_id(c)
			var a = s.get_cell_atlas_coords(c)
			if sid == 0 and a.y == 6:
				plank_cells.append(c)
		print(p, " plank cells (source 0, row 6): count = ", plank_cells.size(), " sample: ", plank_cells.slice(0, 5))
	quit(0)

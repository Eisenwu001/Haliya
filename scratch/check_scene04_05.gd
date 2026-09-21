extends SceneTree

func _init() -> void:
	for i in [4, 5]:
		var p = "res://scenes/scene_%02d.tscn" % i
		var s = load(p).instantiate()
		var used = s.get_used_cells()
		var y_counts = {}
		var atlas_counts = {}
		for c in used:
			if s.get_cell_source_id(c) == 2:
				y_counts[c.y] = y_counts.get(c.y, 0) + 1
				var a = s.get_cell_atlas_coords(c)
				atlas_counts[a] = atlas_counts.get(a, 0) + 1
		print(p, " water rows:", y_counts, " atlas:", atlas_counts)
	quit(0)

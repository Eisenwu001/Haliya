extends SceneTree

func _init() -> void:
	for i in range(1, 6):
		var p = "res://scenes/scene_%02d.tscn" % i
		var s = load(p).instantiate()
		var used = s.get_used_cells()
		var atlas_by_source = {}
		for c in used:
			var sid = s.get_cell_source_id(c)
			if not atlas_by_source.has(sid):
				atlas_by_source[sid] = {}
			var a = s.get_cell_atlas_coords(c)
			atlas_by_source[sid][a] = atlas_by_source[sid].get(a, 0) + 1
		print(p, " atlas by source: ", atlas_by_source)
	quit(0)

extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_01.tscn").instantiate()
	var used = s.get_used_cells()
	var sources_used = {}
	for c in used:
		var sid = s.get_cell_source_id(c)
		var atlas = s.get_cell_atlas_coords(c)
		sources_used[sid] = sources_used.get(sid, 0) + 1
		if sid == 2:
			print("Water cell at ", c, " atlas: ", atlas)
	print("Sources used summary: ", sources_used)
	quit(0)

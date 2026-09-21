extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_03.tscn").instantiate()
	var used = s.get_used_cells()
	var rows_by_source = {}
	for c in used:
		var sid = s.get_cell_source_id(c)
		if not rows_by_source.has(sid):
			rows_by_source[sid] = {}
		rows_by_source[sid][c.y] = rows_by_source[sid].get(c.y, 0) + 1
	print("scene_03 rows by source: ", rows_by_source)
	quit(0)

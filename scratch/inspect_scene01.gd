extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_01.tscn").instantiate()
	var used = s.get_used_cells()
	print("Used cells count: ", used.size())
	var min_y = 99999
	var max_y = -99999
	for c in used:
		min_y = min(min_y, c.y)
		max_y = max(max_y, c.y)
	print("min_y: ", min_y, " max_y: ", max_y)
	for i in min(10, used.size()):
		print("cell: ", used[i], " source: ", s.get_cell_source_id(used[i]), " atlas: ", s.get_cell_atlas_coords(used[i]))
	quit(0)

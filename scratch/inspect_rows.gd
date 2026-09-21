extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_01.tscn").instantiate()
	var used = s.get_used_cells()
	var row_counts = {}
	for c in used:
		row_counts[c.y] = row_counts.get(c.y, 0) + 1
	var sorted_rows = row_counts.keys()
	sorted_rows.sort()
	for r in sorted_rows:
		print("Row ", r, " (Y=", r * 32, " to ", (r + 1) * 32, "): ", row_counts[r], " tiles")
	quit(0)

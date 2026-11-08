extends SceneTree

func _init() -> void:
	var scn = load("res://scenes/forest/level_1_1.tscn").instantiate()
	var bg = scn.get_node("BaseGround") as TileMapLayer
	var cells = bg.get_used_cells()
	print("Cells count: ", cells.size())
	var min_x = 99999
	var max_x = -99999
	var min_y = 99999
	var max_y = -99999
	for c in cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	print("Cell X range: ", min_x, " to ", max_x, " (pixels: ", min_x * 32, " to ", max_x * 32, ")")
	print("Cell Y range: ", min_y, " to ", max_y, " (pixels: ", min_y * 32, " to ", max_y * 32, ")")
	
	# Let's count how many cells at each Y
	var y_counts = {}
	for c in cells:
		y_counts[c.y] = y_counts.get(c.y, 0) + 1
	for y in range(min_y, max_y + 1):
		if y in y_counts:
			print("Y=", y, " (px ", y * 32, "): ", y_counts[y], " tiles")
	
	scn.free()
	quit(0)

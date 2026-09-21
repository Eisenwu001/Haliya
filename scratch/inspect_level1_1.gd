extends SceneTree

func _init():
	var scn = load("res://scenes/forest/level_1_1.tscn")
	var inst = scn.instantiate()
	print("Level_1_1 children:")
	for c in inst.get_children():
		print("  ", c.name, " (", c.get_class(), ")")
		if c is TileMapLayer:
			var cells = c.get_used_cells()
			print("    used cells: ", cells.size())
		for c2 in c.get_children():
			print("    -> ", c2.name, " (", c2.get_class(), ")")
			if c2 is TileMapLayer:
				print("      used cells: ", c2.get_used_cells().size())
	quit(0)

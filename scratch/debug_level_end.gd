@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	print("main.current_level_instance: ", main.current_level_instance)
	if main.current_level_instance:
		print("name: ", main.current_level_instance.name)
		for child in main.current_level_instance.get_children():
			print("  child: ", child.name, " (", child.get_class(), ")")
			if child is TileMapLayer:
				var used = child.get_used_cells()
				print("    used cells: ", used.size())
				var count_150 = 0
				var last_wy = 0.0
				for c in used:
					if c.x >= 150:
						count_150 += 1
						last_wy = c.y * 32.0
				print("    cells >= 150: ", count_150, " last_wy: ", last_wy)
				
	print("get_level_end_ground_y(): ", main.get_level_end_ground_y())
	main.free()
	quit()

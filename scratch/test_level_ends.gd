@tool
extends SceneTree

func _init():
	var levels = [
		"res://scenes/forest/level_1_1.tscn",
		"res://scenes/forest/level_1_2.tscn",
		"res://scenes/forest/level_1_3.tscn",
		"res://scenes/rice_field/level_2_1.tscn",
		"res://scenes/rice_field/level_2_2.tscn",
		"res://scenes/rice_field/level_2_3.tscn"
	]
	
	for path in levels:
		print("========================================")
		print("Checking: ", path)
		if not ResourceLoader.exists(path):
			print("File does not exist!")
			continue
		var scene = load(path)
		var instance = scene.instantiate()
		
		# Check all TileMapLayers
		var layers = []
		for child in instance.get_children():
			if child is TileMapLayer:
				layers.append(child)
			for sub in child.get_children():
				if sub is TileMapLayer:
					layers.append(sub)
		
		for layer in layers:
			var used = layer.get_used_cells()
			if used.size() == 0:
				continue
			var min_x = 999999
			var max_x = -999999
			var min_y = 999999
			var max_y = -999999
			var end_cells = []
			for c in used:
				min_x = min(min_x, c.x)
				max_x = max(max_x, c.x)
				min_y = min(min_y, c.y)
				max_y = max(max_y, c.y)
				if c.x >= 150:
					end_cells.append(c)
			print("  TileMapLayer: ", layer.name, " cells: ", used.size(), " x-range: [", min_x, ", ", max_x, "] (px: ", min_x*32, " to ", (max_x+1)*32, ") y-range: [", min_y, ", ", max_y, "] (px: ", min_y*32, " to ", (max_y+1)*32, ")")
			if end_cells.size() > 0:
				var end_min_y = 999999
				var end_max_y = -999999
				for ec in end_cells:
					end_min_y = min(end_min_y, ec.y)
					end_max_y = max(end_max_y, ec.y)
				print("    Cells with x >= 150: count=", end_cells.size(), " y-range=[", end_min_y, ", ", end_max_y, "] (px: ", end_min_y*32, " to ", end_max_y*32, ")")
		
		# Check StaticBody2D or CollisionShape2D children in scene
		var statics = instance.find_children("", "StaticBody2D", true, false)
		for sb in statics:
			print("  StaticBody2D: ", sb.name, " pos: ", sb.position, " global_pos: ", sb.global_position)
			for shape_node in sb.get_children():
				if shape_node is CollisionShape2D:
					print("    CollisionShape2D: ", shape_node.shape, " pos: ", shape_node.position)
		
		# Check Area2D children
		var areas = instance.find_children("", "Area2D", true, false)
		for a in areas:
			print("  Area2D: ", a.name, " pos: ", a.position, " global_pos: ", a.global_position)
		
		instance.free()
	quit()

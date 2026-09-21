extends SceneTree

func _init():
	for name in ['forest/level_1_1', 'forest/level_1_2', 'forest/level_1_3', 'rice_field/level_2_1', 'rice_field/level_2_2', 'rice_field/level_2_3', 'scene_01', 'scene_02', 'scene_03', 'scene_04', 'scene_05']:
		var path = 'res://scenes/' + name + '.tscn'
		if ResourceLoader.exists(path):
			var scn = load(path)
			var inst = scn.instantiate()
			var layers = []
			if inst is TileMapLayer:
				layers.append(inst.name + ' (' + str(inst.get_used_cells().size()) + ')')
			for c in inst.get_children():
				if c is TileMapLayer:
					layers.append(c.name + ' (' + str(c.get_used_cells().size()) + ')')
				for c2 in c.get_children():
					if c2 is TileMapLayer:
						layers.append('  ' + c2.name + ' (' + str(c2.get_used_cells().size()) + ')')
			print(name, ': ', layers)
	quit(0)

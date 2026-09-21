extends SceneTree

func _init():
	for i in range(1, 6):
		var path = 'res://scenes/scene_0' + str(i) + '.tscn'
		var scn = load(path).instantiate()
		print(path, ' -> class: ', scn.get_class(), ' name: ', scn.name, ' cells: ', scn.get_used_cells().size())
	quit(0)

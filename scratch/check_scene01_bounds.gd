extends SceneTree

func _init():
	var s1 = load('res://scenes/scene_01.tscn').instantiate()
	print('Scene_01 root node name: ', s1.name)
	print('Scene_01 children count: ', s1.get_child_count())
	for c in s1.get_children():
		print('  child: ', c.name, ' (', c.get_class(), ')')
	
	var used = s1.get_used_cells()
	var min_x = 99999; var max_x = -99999
	var min_y = 99999; var max_y = -99999
	for p in used:
		min_x = min(min_x, p.x); max_x = max(max_x, p.x)
		min_y = min(min_y, p.y); max_y = max(max_y, p.y)
	print('Scene_01 bounds: x=[', min_x, ', ', max_x, '], y=[', min_y, ', ', max_y, ']')
	quit(0)

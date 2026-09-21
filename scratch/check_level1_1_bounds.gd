extends SceneTree

func _init():
	var s1 = load('res://scenes/forest/level_1_1.tscn').instantiate()
	var bg = s1.get_node('BaseGround')
	var used = bg.get_used_cells()
	var min_x = 99999; var max_x = -99999
	var min_y = 99999; var max_y = -99999
	for p in used:
		min_x = min(min_x, p.x); max_x = max(max_x, p.x)
		min_y = min(min_y, p.y); max_y = max(max_y, p.y)
	print('level_1_1 BaseGround bounds: x=[', min_x, ', ', max_x, '], y=[', min_y, ', ', max_y, ']')
	quit(0)

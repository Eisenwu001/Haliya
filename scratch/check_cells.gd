@tool
extends SceneTree

func _init() -> void:
	var scn = load("res://scenes/forest/level_1_1.tscn")
	var inst = scn.instantiate()
	var bg = inst.get_node("BaseGround")
	for x in range(0, 25):
		var col_ys = []
		for y in range(0, 25):
			if bg.get_cell_source_id(Vector2i(x, y)) != -1:
				col_ys.append(y)
		if col_ys.size() > 0:
			print("Col ", x, ": ys=", col_ys)
	inst.free()
	quit(0)

@tool
extends SceneTree

func _init() -> void:
	var scn = load('res://scenes/rice_field/level_2_1.tscn')
	var inst = scn.instantiate()
	var bg = inst.get_node('BaseGround') as TileMapLayer
	var ys = []
	for x in range(0, 160):
		for y in range(0, 25):
			var cell = bg.get_cell_source_id(Vector2i(x, y))
			if cell != -1:
				ys.append(y)
				break
	var counts = {}
	for y in ys:
		counts[y] = counts.get(y, 0) + 1
	print('level_2_1 top ground tile Y distribution:', counts)
	inst.free()
	quit(0)

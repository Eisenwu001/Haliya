@tool
extends SceneTree

func _init() -> void:
	var scn = load('res://scenes/forest/level_1_1.tscn')
	var inst = scn.instantiate()
	var bg = inst.get_node('BaseGround') as TileMapLayer
	for x in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
		for y in range(0, 25):
			var cell = bg.get_cell_source_id(Vector2i(x, y))
			if cell != -1:
				print('x=', x, ' y=', y, ' world_y=', y * 32, ' cell=', cell, ' atlas_coords=', bg.get_cell_atlas_coords(Vector2i(x, y)))
				break
	inst.free()
	quit(0)

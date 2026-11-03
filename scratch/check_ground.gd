@tool
extends SceneTree

func _init() -> void:
	for lvl_path in ['res://scenes/forest/level_1_1.tscn', 'res://scenes/rice_field/level_2_1.tscn']:
		var scn = load(lvl_path)
		var inst = scn.instantiate()
		var bg = inst.get_node('BaseGround') as TileMapLayer
		if bg:
			var cells = bg.get_used_cells()
			var min_y = 999999
			var max_y = -999999
			var min_x = 999999
			var max_x = -999999
			for c in cells:
				if c.y < min_y: min_y = c.y
				if c.y > max_y: max_y = c.y
				if c.x < min_x: min_x = c.x
				if c.x > max_x: max_x = c.x
			print(lvl_path, ' cell range X:', min_x, '..', max_x, ' Y:', min_y, '..', max_y)
			print('Tile size:', bg.tile_set.tile_size)
			print('Top-most world Y:', min_y * bg.tile_set.tile_size.y)
		inst.free()
	quit(0)

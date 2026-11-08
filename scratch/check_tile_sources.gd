extends SceneTree

func _init() -> void:
	var scn = load("res://scenes/forest/level_1_1.tscn").instantiate()
	var bg = scn.get_node("BaseGround") as TileMapLayer
	for y in range(8, 14):
		var src_id = bg.get_cell_source_id(Vector2i(20, y))
		var atlas_coords = bg.get_cell_atlas_coords(Vector2i(20, y))
		var alt = bg.get_cell_alternative_tile(Vector2i(20, y))
		print("x=20, y=", y, " (px ", y * 32, "): src=", src_id, " coords=", atlas_coords, " alt=", alt)
	scn.free()
	quit(0)

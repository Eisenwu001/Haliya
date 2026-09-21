extends SceneTree

func _init() -> void:
	var s1 = load("res://scenes/scene_01.tscn").instantiate()
	var ts = s1.tile_set.duplicate(true)
	DirAccess.make_dir_recursive_absolute("res://scenes/forest")
	DirAccess.make_dir_recursive_absolute("res://scenes/rice_field")
	ResourceSaver.save(ts, "res://scenes/tileset.tres")
	print("Saved tileset.tres successfully!")
	
	# Create a test TileMapLayer
	var tm = TileMapLayer.new()
	tm.name = "BaseGround"
	tm.tile_set = load("res://scenes/tileset.tres")
	# Set a cell at (5, 9)
	tm.set_cell(Vector2i(5, 9), 0, Vector2i(2, 0)) # grass top
	tm.set_cell(Vector2i(5, 10), 0, Vector2i(6, 1)) # dirt
	print("Set cell 5,9. Cell source: ", tm.get_cell_source_id(Vector2i(5, 9)))
	quit(0)

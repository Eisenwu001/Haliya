@tool
extends SceneTree

func _init() -> void:
	var ts: TileSet = load("res://scenes/tileset.tres")
	if not ts:
		print("FAIL: Could not load tileset.tres")
		quit(1)
		return
	
	print("Loaded tileset.tres!")
	print("Source count: ", ts.get_source_count())
	for i in range(ts.get_source_count()):
		var id = ts.get_source_id(i)
		var s = ts.get_source(id)
		if s is TileSetAtlasSource:
			var tex = s.texture
			print("  Source %d: %s (tiles: %d)" % [id, tex.resource_path if tex else "null", s.get_tiles_count()])
	
	quit(0)

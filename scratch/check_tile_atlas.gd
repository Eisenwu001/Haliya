@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		var bg: TileMapLayer = inst.find_child("BaseGround", true, false)
		print("=== Tiles used in ", path, " ===")
		var used_sources = {}
		for c in bg.get_used_cells():
			var src = bg.get_cell_source_id(c)
			var atlas = bg.get_cell_atlas_coords(c)
			var alt = bg.get_cell_alternative_tile(c)
			var key = "%d:%s:%d" % [src, str(atlas), alt]
			used_sources[key] = used_sources.get(key, 0) + 1
		print(used_sources)
		inst.free()
	quit()

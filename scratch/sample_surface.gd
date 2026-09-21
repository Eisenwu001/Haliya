@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		var bg: TileMapLayer = inst.find_child("BaseGround", true, false)
		var surface: Array = []
		for col in range(160):
			var found := -1
			for row in range(0, 25):
				if bg.get_cell_source_id(Vector2i(col, row)) != -1:
					found = row
					break
			surface.append(found)
		print(path, " surface: ", surface.slice(0, 40))
		inst.free()
	quit()

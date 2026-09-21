@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		var fd: TileMapLayer = inst.find_child("ForegroundDecor", true, false)
		var cols = []
		for c in fd.get_used_cells():
			if not cols.has(c.x):
				cols.append(c.x)
		cols.sort()
		print(path, " decor cols: ", cols)
		inst.free()
	quit()

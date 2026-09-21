@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		var wb: TileMapLayer = inst.find_child("WaterBackground", true, false)
		var cols = []
		for c in wb.get_used_cells():
			if not cols.has(c.x):
				cols.append(c.x)
		cols.sort()
		print(path, " water cols: ", cols)
		inst.free()
	quit()

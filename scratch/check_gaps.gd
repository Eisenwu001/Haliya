@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		var bg: TileMapLayer = inst.find_child("BaseGround", true, false)
		var gaps := []
		var cur_gap := []
		for col in range(160):
			var has_tile = false
			for row in range(0, 25):
				if bg.get_cell_source_id(Vector2i(col, row)) != -1:
					has_tile = true
					break
			if not has_tile:
				cur_gap.append(col)
			else:
				if not cur_gap.is_empty():
					gaps.append(cur_gap.duplicate())
					cur_gap.clear()
		if not cur_gap.is_empty():
			gaps.append(cur_gap)
		print(path, " gaps: ", gaps)
		inst.free()
	quit()

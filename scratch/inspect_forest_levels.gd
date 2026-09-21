@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		if not scene:
			print("Could not load ", path)
			continue
		var inst = scene.instantiate()
		print("=== ", path, " ===")
		for c in inst.get_children():
			print(" - Child: ", c.name, " (", c.get_class(), ")")
			if c is TileMapLayer:
				print("   Used cells count: ", c.get_used_cells().size(), " rect: ", c.get_used_rect())
			elif c.name == "Enemies":
				print("   Enemies count: ", c.get_child_count())
				for e in c.get_children():
					print("     * ", e.name, " at ", e.position)
		inst.free()
	quit()

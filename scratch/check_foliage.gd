@tool
extends SceneTree

func _init() -> void:
	for path in ["res://scenes/forest/level_1_1.tscn", "res://scenes/forest/level_1_2.tscn", "res://scenes/forest/level_1_3.tscn"]:
		var scene: PackedScene = load(path)
		var inst = scene.instantiate()
		print("--- Foliage in ", path)
		var fol = inst.find_child("Foliage", true, false)
		if fol:
			for c in fol.get_children():
				if c is Sprite2D:
					print("Tree: ", c.name, " pos: ", c.position, " tex: ", c.texture.resource_path.get_file(), " scale: ", c.scale)
		var brk = inst.find_child("Breakables", true, false)
		if brk:
			print("--- Breakables in ", path, " count: ", brk.get_child_count())
			for c in brk.get_children():
				print("Pot: ", c.name, " pos: ", c.position)
		inst.free()
	quit()

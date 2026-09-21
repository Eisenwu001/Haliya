@tool
extends SceneTree

func _init():
	var scene_path = "res://scenes/forest/level_1_1.tscn"
	print("Exists: ", ResourceLoader.exists(scene_path))
	var res = load(scene_path)
	print("Loaded: ", res)
	if res is PackedScene:
		var inst = res.instantiate()
		print("Instantiated: ", inst)
		inst.free()
	quit()

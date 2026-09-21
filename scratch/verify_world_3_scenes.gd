@tool
extends SceneTree

func _init() -> void:
	for i in range(1, 6):
		var p = "res://scenes/rainy_forest/level_3_%d.tscn" % i
		print("Checking: ", p)
		var scn: PackedScene = load(p)
		assert(scn != null, "Scene %s failed to load!" % p)
		var inst = scn.instantiate()
		assert(inst != null, "Scene %s failed to instantiate!" % p)
		var bg = inst.find_child("BaseGround", true, false)
		assert(bg != null, "BaseGround missing!")
		assert(bg.get_used_cells().size() > 0, "BaseGround has no cells!")
		var enemies = inst.find_child("Enemies", true, false)
		assert(enemies != null, "Enemies missing!")
		assert(enemies.get_child_count() > 0, "No enemies in scene!")
		print("  -> Passed! BaseGround cells: ", bg.get_used_cells().size(), " Enemies: ", enemies.get_child_count())
		inst.free()
	print("ALL 5 SCENES VERIFIED SUCCESSFULLY!")
	quit(0)

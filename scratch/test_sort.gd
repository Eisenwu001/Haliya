extends SceneTree

func _init() -> void:
	var paths: Array[String] = [
		"res://assets/haliya/common_00_idle_stand_B01.png",
		"res://assets/haliya/common_00_idle_stand_A01.png",
		"res://assets/haliya/common_00_idle_stand_B02.png",
		"res://assets/haliya/common_00_idle_stand_A02.png",
	]
	paths.sort_custom(Player.sort_paths_custom)
	for p in paths:
		print("Sorted:", p.get_file())
	quit()

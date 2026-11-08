extends SceneTree

func _init() -> void:
	var paths: Array[String] = []
	for i in range(1, 9):
		paths.append("res://assets/haliya/common_00_idle_stand_B%02d.png" % i)
		paths.append("res://assets/haliya/common_00_idle_stand_A%02d.png" % i)
	
	paths.sort_custom(func(a: String, b: String) -> bool:
		if "stand_A" in a and "stand_B" in b:
			return true
		if "stand_B" in a and "stand_A" in b:
			return false
		return Player.extract_frame_number(a) < Player.extract_frame_number(b)
	)
	
	for p in paths:
		print("Sorted: ", p.get_file())
	quit()

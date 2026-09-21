extends SceneTree

func _initialize():
	var file = FileAccess.open("c:/Users/Lin/OneDrive/Pictures/Camera Roll/Documents/project-1-test/scratch/verified.txt", FileAccess.WRITE)
	if file:
		file.store_string("GODOT ENGINE SCRIPT EXECUTED WITH _INITIALIZE\n")
		file.close()
	quit(0)

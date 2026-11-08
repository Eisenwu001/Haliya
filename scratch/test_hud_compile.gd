extends SceneTree

func _init() -> void:
	print("--- Compiling Main Scene and Scripts ---")
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		push_error("Failed to load main.tscn")
		quit(1)
		return
	print("SUCCESS: main.tscn loaded successfully without syntax or parse errors")
	var main = main_scene.instantiate()
	root.add_child(main)
	print("SUCCESS: main instantiated successfully")
	main.free()
	quit(0)

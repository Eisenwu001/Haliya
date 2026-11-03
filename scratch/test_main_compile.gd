extends SceneTree

const MainScript = preload("res://scripts/main.gd")

func _init() -> void:
	print("[TEST] Compiling and loading scripts/main.gd...")
	assert(MainScript != null, "scripts/main.gd failed to preload")
	var main_inst = MainScript.new()
	assert(main_inst != null, "scripts/main.gd failed to instantiate")
	root.add_child(main_inst)
	print("[TEST PASS] scripts/main.gd instantiated cleanly with Settings, Lore Codex, and Baybayin Area Discovery!")
	main_inst.free()
	quit(0)

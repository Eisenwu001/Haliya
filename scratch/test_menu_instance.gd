extends SceneTree

func _init() -> void:
	print("[TEST] Loading and instantiating Main Menu scene...")
	var scene = load("res://scenes/main_menu.tscn")
	assert(scene != null, "Main menu scene failed to load")
	var instance = scene.instantiate()
	root.add_child(instance)
	print("Is node ready? ", instance.is_node_ready())
	if not instance.is_node_ready():
		instance._ready()
	print("Settings menu is: ", instance.settings_menu)
	assert(instance.settings_menu != null, "settings_menu should be instantiated")
	assert(instance.bestiary_codex_ui != null, "bestiary_codex_ui should be instantiated")
	print("[TEST PASS] Main Menu instantiated cleanly with Settings and Lore Codex modals!")
	instance.free()
	quit(0)

extends SceneTree

func _init() -> void:
	print("[TEST] Compiling and instantiating Act 1 Bahay Kubo Hub...")
	var scene = load("res://scenes/act1_bahay_kubo_hub.tscn")
	assert(scene != null, "Act 1 Bahay Kubo Hub scene failed to load")
	var instance = scene.instantiate()
	assert(instance != null, "Failed to instantiate Act 1 Bahay Kubo Hub")
	root.add_child(instance)
	print("[TEST PASS] Act 1 Bahay Kubo Hub loaded cleanly with Altar Codex and Baybayin Banner!")
	instance.free()
	quit(0)

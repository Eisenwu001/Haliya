extends SceneTree

func _init() -> void:
	print("--- Capturing Pause Menu Before ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(20):
		await process_frame

	main.toggle_pause()

	for i in range(10):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://snapshot_pause_menu_before.png")
		print("SUCCESS: Snapshot pause menu before saved: res://snapshot_pause_menu_before.png")
	else:
		push_error("Failed to capture image")

	main.free()
	quit(0)

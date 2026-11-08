extends SceneTree

func _init() -> void:
	print("--- Capturing Snapshots: HUD Dark (Cave 4-1), HUD Bright (Rice Field 2-1), and Pause Menu ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	# 1. Jump to Level 13 (Cave Scene: Bioluminescent Threshold - Deep Dark Background)
	main.jump_to_level(13)
	for i in range(40):
		await process_frame

	var img_dark = root.get_viewport().get_texture().get_image()
	if img_dark:
		img_dark.save_png("res://snapshot_hud_dark.png")
		print("SUCCESS: snapshot_hud_dark.png saved (Cave Level 4-1 dark background)")
	else:
		push_error("Failed to capture dark HUD image")

	# 2. Switch to Level 3 (Rice Field 2-1: Emerald Terraces - Bright Daytime Amber/Sky Background)
	main.jump_to_level(3)
	for i in range(40):
		await process_frame

	var img_bright = root.get_viewport().get_texture().get_image()
	if img_bright:
		img_bright.save_png("res://snapshot_hud_bright.png")
		print("SUCCESS: snapshot_hud_bright.png saved (Rice Field Level 2-1 bright background)")
	else:
		push_error("Failed to capture bright HUD image")

	# 3. Toggle Pause to show the rebuilt Pause Menu
	main.toggle_pause()
	for i in range(25):
		await process_frame

	var img_pause = root.get_viewport().get_texture().get_image()
	if img_pause:
		img_pause.save_png("res://snapshot_pause_menu_after.png")
		print("SUCCESS: snapshot_pause_menu_after.png saved")
	else:
		push_error("Failed to capture pause menu after image")

	main.free()
	quit(0)

extends SceneTree

func _init() -> void:
	print("--- Testing Immediate Main Menu Launch ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)

	for i in range(25):
		await process_frame

	menu.menu_buttons[0].grab_item_focus()
	for i in range(6):
		await process_frame

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"
	var img = root.get_viewport().get_texture().get_image()
	img.save_png(artifact_dir + "restored_menu_raw.png")
	print("Saved restored_menu_raw.png")

	menu.free()
	quit(0)

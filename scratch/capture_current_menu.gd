extends SceneTree

func _init() -> void:
	# Ensure slot 1 has a save file
	var save_path = "user://haliya_save_slot_1.json"
	var mock_save = {
		"version": 1,
		"level_idx": 0,
		"highest_level_idx": 1,
		"stage_title": "Forest Scene — Level 1-1: Whispering Canopy",
		"date_string": "2026-11-02 14:00",
		"play_time_seconds": 125.0,
		"current_hp": 5,
		"current_armor": 3,
		"upgrades_count": 2
	}
	var f = FileAccess.open(save_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(mock_save))
	f.close()

	var MainMenuScript = load("res://scripts/main_menu.gd")
	MainMenuScript.has_shown_splash = true

	var menu = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)

	await process_frame
	await process_frame
	await process_frame
	await process_frame

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

	# 1. State 1: Continue selected (button index 0)
	menu.menu_buttons[0].grab_item_focus()
	await process_frame
	await process_frame
	var img1 = root.get_viewport().get_texture().get_image()
	img1.save_png(artifact_dir + "before_continue_selected.png")
	print("Saved before_continue_selected.png")

	# 2. State 2: Begin Journey selected (button index 1)
	menu.menu_buttons[1].grab_item_focus()
	await process_frame
	await process_frame
	var img2 = root.get_viewport().get_texture().get_image()
	img2.save_png(artifact_dir + "before_begin_selected.png")
	print("Saved before_begin_selected.png")

	# 3. State 3: Quit selected (last button index)
	menu.menu_buttons[menu.menu_buttons.size() - 1].grab_item_focus()
	await process_frame
	await process_frame
	var img3 = root.get_viewport().get_texture().get_image()
	img3.save_png(artifact_dir + "before_quit_selected.png")
	print("Saved before_quit_selected.png")

	menu.free()
	quit(0)

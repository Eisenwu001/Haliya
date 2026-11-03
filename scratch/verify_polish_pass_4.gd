extends SceneTree

func _init() -> void:
	print("--- Starting Polish Pass 4 Verification ---")

	# 1. Ensure save file exists in slot 1 so "Continue" is visible
	var save_path = "user://haliya_save_slot_1.json"
	var mock_save = {
		"version": 1,
		"level_idx": 0,
		"highest_level_idx": 1,
		"stage_title": "Forest Scene — Level 1-1: Whispering Canopy",
		"date_string": "2026-11-03 14:00",
		"play_time_seconds": 150.0,
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

	# Wait for scene initialization and staggered fade-in to complete
	for i in range(30):
		await process_frame

	# State A: Continue selected (focus grabbed)
	menu.menu_buttons[0].grab_item_focus()
	for i in range(10):
		await process_frame

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

	var img_selected = root.get_viewport().get_texture().get_image()
	img_selected.save_png(artifact_dir + "pass4_raw_selected.png")
	print("Saved pass4_raw_selected.png")

	# State B: Unselected state (select Begin Journey instead, so Continue is unselected)
	menu.menu_buttons[1].grab_item_focus()
	for i in range(10):
		await process_frame

	var img_unselected = root.get_viewport().get_texture().get_image()
	img_unselected.save_png(artifact_dir + "pass4_raw_unselected.png")
	print("Saved pass4_raw_unselected.png")

	print("--- Captured Raw Viewports Successfully ---")
	menu.free()
	quit(0)

extends SceneTree

var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

func _init() -> void:
	print("--- Running Full Intro to Menu Test ---")
	
	# Ensure slot 1 has a save file so Continue button appears
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

	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)

	# 1. Capture Stage 1: Studio Card (Log's Production)
	for i in range(15):
		await process_frame
	var img1 = root.get_viewport().get_texture().get_image()
	img1.save_png(artifact_dir + "stage1_logs_production.png")
	print("Saved stage1_logs_production.png (logs_page visible: ", menu.logs_page.visible if is_instance_valid(menu.logs_page) else false, ")")

	# Skip to Stage 2: Group 2 Presents
	menu._skip_splash()
	for i in range(20):
		await process_frame
	var img2 = root.get_viewport().get_texture().get_image()
	img2.save_png(artifact_dir + "stage2_group2_presents.png")
	print("Saved stage2_group2_presents.png (group2_page visible: ", menu.group2_page.visible if is_instance_valid(menu.group2_page) else false, ")")

	# Skip to Stage 3: Moon Phase Loading Screen
	menu._skip_splash()
	for i in range(20):
		await process_frame
	var img3 = root.get_viewport().get_texture().get_image()
	img3.save_png(artifact_dir + "stage3_moon_phase_loading.png")
	print("Saved stage3_moon_phase_loading.png (loading_container visible: ", menu.loading_container.visible if is_instance_valid(menu.loading_container) else false, ")")

	# Wait for loading to finish and enter Step 3: PRESS ANY KEY TO START
	while not menu.is_in_press_start:
		await process_frame
	for i in range(10):
		await process_frame
	var img4 = root.get_viewport().get_texture().get_image()
	img4.save_png(artifact_dir + "stage4_press_any_key.png")
	print("Saved stage4_press_any_key.png (is_in_press_start: ", menu.is_in_press_start, ")")

	# Trigger press start to transition into Main Menu
	menu._on_press_start_triggered()
	for i in range(35):
		await process_frame
	menu.menu_buttons[0].grab_item_focus()
	for i in range(10):
		await process_frame

	var img5 = root.get_viewport().get_texture().get_image()
	img5.save_png(artifact_dir + "stage5_restored_main_menu.png")
	print("Saved stage5_restored_main_menu.png (menu_vbox visible: ", menu.menu_vbox.visible if is_instance_valid(menu.menu_vbox) else false, ")")

	print("--- All Stages Verified Successfully ---")
	menu.free()
	quit(0)

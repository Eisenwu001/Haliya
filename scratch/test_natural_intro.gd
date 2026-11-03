extends SceneTree

var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

func _init() -> void:
	print("--- Running Natural Intro Stages Capture ---")
	
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

	# 1. Stage 1: Log's Production
	# Wait 1.0s (60 frames) so dissolve reveal is 100% finished
	for i in range(60):
		await process_frame
	var img1 = root.get_viewport().get_texture().get_image()
	img1.save_png(artifact_dir + "stage1_logs_production.png")
	print("Saved stage1_logs_production.png")

	# Skip Card 1 to go to Card 2
	menu._skip_splash()
	# Wait 1.0s (60 frames) so dissolve transition to Card 2 is 100% finished
	for i in range(60):
		await process_frame
	var img2 = root.get_viewport().get_texture().get_image()
	img2.save_png(artifact_dir + "stage2_group2_presents.png")
	print("Saved stage2_group2_presents.png")

	# Skip Card 2 to go to Moon Phase Loading Screen
	menu._skip_splash()
	# Wait 0.8s for transition to finish and loading to be in progress
	for i in range(50):
		await process_frame
	var img3 = root.get_viewport().get_texture().get_image()
	img3.save_png(artifact_dir + "stage3_moon_phase_loading.png")
	print("Saved stage3_moon_phase_loading.png")

	# Wait until loading finishes and press start is fully revealed
	while not menu.is_in_press_start or (menu.fade_rect.color.a > 0.0 or menu.dissolve_rect.visible):
		await process_frame
	# Wait an extra 30 frames for press start label breathing
	for i in range(30):
		await process_frame
	var img4 = root.get_viewport().get_texture().get_image()
	img4.save_png(artifact_dir + "stage4_press_any_key.png")
	print("Saved stage4_press_any_key.png")

	# Trigger press start
	menu._on_press_start_triggered()
	# Wait 50 frames for title to glide, totem to rise, and buttons to settle
	for i in range(50):
		await process_frame
	menu.menu_buttons[0].grab_item_focus()
	for i in range(10):
		await process_frame
	var img5 = root.get_viewport().get_texture().get_image()
	img5.save_png(artifact_dir + "stage5_restored_main_menu.png")
	print("Saved stage5_restored_main_menu.png")

	print("--- All Stages Captured Successfully ---")
	menu.free()
	quit(0)

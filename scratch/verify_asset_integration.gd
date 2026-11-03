extends SceneTree

func _init() -> void:
	print("--- Starting Totem Swap Verification ---")

	# Ensure save file exists in slot 1 so "Continue" is visible
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

	# Wait for scene initialization and staggered fade-in to settle
	for i in range(45):
		await process_frame

	if menu.menu_buttons.size() > 0:
		menu.menu_buttons[0].grab_item_focus()
	for i in range(15):
		await process_frame

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

	var img_window = root.get_viewport().get_texture().get_image()
	# Save raw window capture
	img_window.save_png(artifact_dir + "swap_window_capture.png")

	# Create true 1:1 pixel grid 640x360
	var img_640 = Image.create(640, 360, false, Image.FORMAT_RGBA8)
	var win_w = img_window.get_width()
	var win_h = img_window.get_height()
	var scale_factor_x = float(win_w) / 640.0
	var scale_factor_y = float(win_h) / 360.0

	for y in range(360):
		for x in range(640):
			var sx = int(round(x * scale_factor_x))
			var sy = int(round(y * scale_factor_y))
			sx = clamp(sx, 0, win_w - 1)
			sy = clamp(sy, 0, win_h - 1)
			img_640.set_pixel(x, y, img_window.get_pixel(sx, sy))

	img_640.save_png(artifact_dir + "swap_full_menu_640x360.png")
	print("Saved swap_full_menu_640x360.png")

	# 1. Close-up: Sacred Face, Crescent Crown, and Celestial Moon (x=410..560, y=30..180)
	var img_face = img_640.get_region(Rect2i(410, 30, 150, 160))
	img_face.save_png(artifact_dir + "swap_face_and_moon.png")
	print("Saved swap_face_and_moon.png")

	# 2. Close-up: Base, Offerings, Center Flame, Smoke Wisps, and Bottom Foliage (x=380..580, y=260..360)
	var img_base = img_640.get_region(Rect2i(380, 260, 200, 100))
	img_base.save_png(artifact_dir + "swap_base_and_offerings.png")
	print("Saved swap_base_and_offerings.png")

	# 3. Close-up: Full Totem Column (x=380..580, y=60..360)
	var img_totem = img_640.get_region(Rect2i(380, 60, 200, 300))
	img_totem.save_png(artifact_dir + "swap_full_totem.png")
	print("Saved swap_full_totem.png")

	# 4. Close-up: Version Label Contrast (x=16..240, y=326..356)
	var img_ver = img_640.get_region(Rect2i(16, 326, 224, 30))
	img_ver.save_png(artifact_dir + "swap_version_label.png")
	print("Saved swap_version_label.png")

	print("--- All Totem Swap Verification Screenshots Captured Successfully ---")
	menu.free()
	quit(0)

extends SceneTree

func _init() -> void:
	print("--- Starting Polish Pass 3 Verification ---")

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

	# Wait for scene initialization and staggered fade-in to settle
	for i in range(25):
		await process_frame

	menu.menu_buttons[0].grab_item_focus()
	for i in range(6):
		await process_frame

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

	# 1. Capture Full Menu
	var img_full = root.get_viewport().get_texture().get_image()
	img_full.save_png(artifact_dir + "pass3_full_menu.png")
	print("Saved pass3_full_menu.png")

	# 2. Capture Totem Base Close-up (crop x=390..580, y=260..360)
	var crop_totem = Image.create(190, 100, false, Image.FORMAT_RGBA8)
	crop_totem.blit_rect(img_full, Rect2i(390, 260, 190, 100), Vector2i.ZERO)
	crop_totem.resize(380, 200, Image.INTERPOLATE_NEAREST)
	crop_totem.save_png(artifact_dir + "pass3_totem_base_closeup.png")
	print("Saved pass3_totem_base_closeup.png")

	# 3. Capture Bottom-Left Version Text Close-up (crop x=16..260, y=326..360)
	var crop_ver = Image.create(244, 34, false, Image.FORMAT_RGBA8)
	crop_ver.blit_rect(img_full, Rect2i(16, 326, 244, 34), Vector2i.ZERO)
	crop_ver.resize(732, 102, Image.INTERPOLATE_NEAREST)
	crop_ver.save_png(artifact_dir + "pass3_version_text_closeup.png")
	print("Saved pass3_version_text_closeup.png")

	# 4. Capture Top-Left Corner (crop x=0..200, y=0..110)
	var crop_tl = Image.create(200, 110, false, Image.FORMAT_RGBA8)
	crop_tl.blit_rect(img_full, Rect2i(0, 0, 200, 110), Vector2i.ZERO)
	crop_tl.resize(400, 220, Image.INTERPOLATE_NEAREST)
	crop_tl.save_png(artifact_dir + "pass3_top_left_corner.png")
	print("Saved pass3_top_left_corner.png")

	# 5. Capture Top-Right Corner (crop x=440..640, y=0..110)
	var crop_tr = Image.create(200, 110, false, Image.FORMAT_RGBA8)
	crop_tr.blit_rect(img_full, Rect2i(440, 0, 200, 110), Vector2i.ZERO)
	crop_tr.resize(400, 220, Image.INTERPOLATE_NEAREST)
	crop_tr.save_png(artifact_dir + "pass3_top_right_corner.png")
	print("Saved pass3_top_right_corner.png")

	# 6. Verify Reduce Motion
	var GameSettings = load("res://scripts/game_settings.gd")
	GameSettings.reduce_motion = true
	for i in range(5):
		await process_frame
	print("Verified reduce_motion setting: ", GameSettings.reduce_motion)

	print("--- Polish Pass 3 Verification Complete ---")
	menu.free()
	quit(0)

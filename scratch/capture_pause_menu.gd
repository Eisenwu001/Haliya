extends SceneTree

func _init() -> void:
	print("--- Running Unified Pause Menu Verification and Captures ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(25):
		await process_frame

	# Ensure UI layer sits on top
	if is_instance_valid(main.ui_layer):
		main.ui_layer.layer = 10

	var pause_menu = main.pause_overlay as HaliyaPauseMenuScreen
	assert(is_instance_valid(pause_menu), "Pause menu must be instantiated")

	# ── TEST 1: Bright Background (Rice Field 2-1, index 3) ──
	print("Switching to Bright Background (Rice Field 2-1)...")
	main.jump_to_level(3)
	for i in range(35):
		await process_frame

	# Pause the game
	print("Pausing game on Bright Background...")
	main.toggle_pause()
	for i in range(15):
		await process_frame

	# Verify pause state & HUD visibility
	assert(paused == true, "SceneTree must be paused")
	assert(pause_menu.visible == true, "Pause menu must be visible")
	assert(main.hud_container.visible == false, "HUD must be hidden while paused!")

	# Verify Pause Menu Structure
	assert(is_instance_valid(pause_menu.backdrop_rect), "Backdrop rect must exist")
	assert(pause_menu.backdrop_rect.material != null, "Backdrop rect must have shader material")
	assert(is_instance_valid(pause_menu.left_gradient_rect), "Left gradient rect must exist")
	assert(pause_menu.left_gradient_rect.texture.resource_path.ends_with("menu_left_gradient.png"), "Must use menu_left_gradient.png")
	assert(pause_menu.title_label.text == "PAUSED", "Title must be PAUSED")
	assert(pause_menu.title_label.theme_type_variation == &"PanelHeaderLabel", "Title must use PanelHeaderLabel")
	assert(pause_menu.resume_hint.text == "[ESC] RESUME", "Bottom-left hint must be [ESC] RESUME")

	# Verify Buttons
	assert(pause_menu.menu_buttons.size() == 5, "Must have exactly 5 menu buttons")
	assert(pause_menu.menu_buttons[0].label_text == "Resume", "Button 0 must be Resume")
	assert(pause_menu.menu_buttons[0].tier == UIThemeConstants.MenuTier.PRIMARY, "Resume must be PRIMARY tier")
	assert(pause_menu.menu_buttons[1].label_text == "Settings", "Button 1 must be Settings")
	assert(pause_menu.menu_buttons[1].tier == UIThemeConstants.MenuTier.SMALL, "Settings must be SMALL tier")
	assert(pause_menu.menu_buttons[2].label_text == "Lore Codex", "Button 2 must be Lore Codex")
	assert(pause_menu.menu_buttons[2].tier == UIThemeConstants.MenuTier.SMALL, "Lore Codex must be SMALL tier")
	assert(pause_menu.menu_buttons[3].label_text == "Restart Level", "Button 3 must be Restart Level")
	assert(pause_menu.menu_buttons[3].tier == UIThemeConstants.MenuTier.MEDIUM, "Restart Level must be MEDIUM tier")
	assert(pause_menu.menu_buttons[4].label_text == "SAVE AND QUIT", "Button 4 must be SAVE AND QUIT")
	assert(pause_menu.menu_buttons[4].tier == UIThemeConstants.MenuTier.MUTED, "SAVE AND QUIT must be MUTED tier")

	# Verify Resume is focused by default and crescent is visible
	assert(pause_menu.menu_buttons[0].is_item_selected() == true, "Resume button must be selected by default")
	assert(pause_menu.menu_buttons[0].crescent_rect.modulate.a == 1.0, "Crescent selector must be visible on selected item")

	# Capture Bright Scene Pause Menu
	for i in range(10):
		await process_frame
	_save_capture("pause_bright.png")
	print("SUCCESS: Bright scene pause menu captured!")

	# ── TEST 2: Confirmation Modal (Restart Level & SAVE AND QUIT) ──
	print("Testing Confirmation Modal...")
	pause_menu._on_restart_pressed()
	for i in range(10):
		await process_frame
	assert(pause_menu.confirm_modal.visible == true, "Confirm modal must be visible on Restart Level press")
	assert(pause_menu.confirm_title_label.text == "RESTART LEVEL?", "Confirm title must be RESTART LEVEL?")
	assert(pause_menu.btn_confirm_no.button.has_focus() == true or pause_menu.btn_confirm_no.is_item_selected() == true, "NO must be focused by default")
	_save_capture("pause_confirm_restart.png")

	# Close confirm modal
	pause_menu._close_confirm()
	for i in range(5):
		await process_frame
	assert(pause_menu.confirm_modal.visible == false, "Confirm modal must close")

	# Test Save & Quit Confirm Modal
	pause_menu._on_save_quit_pressed()
	for i in range(10):
		await process_frame
	assert(pause_menu.confirm_modal.visible == true, "Confirm modal must be visible on SAVE AND QUIT press")
	assert(pause_menu.confirm_title_label.text == "SAVE AND QUIT?", "Confirm title must be SAVE AND QUIT?")
	_save_capture("pause_confirm_save_quit.png")
	pause_menu._close_confirm()
	for i in range(5):
		await process_frame
	assert(pause_menu.confirm_modal.visible == false, "Confirm modal must close")

	# ── TEST 3: Unpause and verify HUD restoration ──
	print("Unpausing to test HUD restoration...")
	main.toggle_pause()
	for i in range(15):
		await process_frame
	assert(paused == false, "SceneTree must be unpaused")
	assert(pause_menu.visible == false, "Pause menu must be hidden")
	assert(main.hud_container.visible == true, "HUD must be restored when unpaused!")

	# ── TEST 4: Dark Background (Cave 4-1, index 13) ──
	print("Switching to Dark Background (Cave 4-1)...")
	main.jump_to_level(13)
	for i in range(35):
		await process_frame

	# Pause on Dark Background
	print("Pausing game on Dark Background...")
	main.toggle_pause()
	for i in range(15):
		await process_frame

	assert(paused == true, "SceneTree must be paused")
	assert(pause_menu.visible == true, "Pause menu must be visible")
	assert(main.hud_container.visible == false, "HUD must be hidden while paused!")

	# Capture Dark Scene Pause Menu
	for i in range(10):
		await process_frame
	_save_capture("pause_dark.png")
	print("SUCCESS: Dark scene pause menu captured!")

	print("--- ALL PAUSE MENU TESTS & CAPTURES PASSED ---")
	main.free()
	quit(0)


func _save_capture(filename: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var path = "res://" + filename
		img.save_png(path)
		print("Saved screenshot: %s" % filename)
	else:
		push_error("Failed to capture image for %s" % filename)

extends SceneTree

func _init() -> void:
	call_deferred("_run_captures")

func _wait_seconds(sec: float) -> void:
	var elapsed := 0.0
	while elapsed < sec:
		await process_frame
		elapsed += get_root().get_process_delta_time()

func _save_snap(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_root().get_texture().get_image()
	if img != null:
		var path := "res://scratch/" + filename
		img.save_png(path)
		print("[CAPTURED] ", path, " (", img.get_width(), "x", img.get_height(), ")")
	else:
		printerr("[ERROR] Viewport image was null for ", filename)

func _run_captures() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var menu_scene: PackedScene = load("res://scenes/main_menu.tscn")
	var menu: Control = menu_scene.instantiate()
	get_root().add_child(menu)

	# Wait for staggered 80ms fade-in (7 items * 80ms = 560ms) + fade overlay (320ms)
	await _wait_seconds(0.85)
	if menu.menu_buttons.size() > 0:
		menu.menu_buttons[0].grab_item_focus()
	await _wait_seconds(0.15)
	await _save_snap("ui_after_main_menu.png")

	# Also capture with "Stage Select" (index 2) focused to verify selection movement
	if menu.menu_buttons.size() > 2:
		menu.menu_buttons[2].grab_item_focus()
	await _wait_seconds(0.35)
	await _save_snap("ui_after_main_menu_hover.png")

	# 1. Settings Screen (Audio, Video, Controls)
	menu.screen_manager.open_screen("settings")
	await _wait_seconds(0.25)
	await _save_snap("ui_after_settings_audio.png")

	var settings_scr = menu.screen_manager.screens.get("settings")
	if is_instance_valid(settings_scr):
		settings_scr.switch_tab(1)
		await _wait_seconds(0.12)
		await _save_snap("ui_after_settings_video.png")

		settings_scr.switch_tab(2)
		await _wait_seconds(0.12)
		await _save_snap("ui_after_settings_controls.png")

	# 2. Stage Select Screen
	menu.screen_manager.open_screen("stage_select")
	await _wait_seconds(0.25)
	await _save_snap("ui_after_stage_select.png")

	# 3. Lore Codex Screen (Unlocked entry & Locked "???" entry)
	menu.screen_manager.open_screen("lore_codex")
	await _wait_seconds(0.25)
	await _save_snap("ui_after_lore_codex.png")

	var codex_scr = menu.screen_manager.screens.get("lore_codex")
	if is_instance_valid(codex_scr):
		codex_scr._select_entry(2)
		await _wait_seconds(0.12)
		await _save_snap("ui_after_lore_codex_locked.png")

	# 4. How to Play Screen
	menu.screen_manager.open_screen("how_to_play")
	await _wait_seconds(0.25)
	await _save_snap("ui_after_how_to_play.png")

	# 5. Quit Confirmation Screen
	menu.screen_manager.open_screen("quit_confirm")
	await _wait_seconds(0.25)
	await _save_snap("ui_after_quit_confirm.png")

	print("[DONE] All UI screenshots captured.")
	quit(0)

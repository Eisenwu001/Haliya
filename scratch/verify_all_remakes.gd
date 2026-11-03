extends SceneTree

func _init() -> void:
	_run_all()

func _run_all() -> void:
	# Ensure mock save exists in slot 1
	var save_path = SaveManager.get_save_path(1)
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

	# 1. Capture Main Menu with new loading screen & new buttons
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu_scene)
	await process_frame
	await process_frame

	# Hold loading bar at 55%
	menu_scene._start_loading_sequence()
	if menu_scene.loading_tween and menu_scene.loading_tween.is_valid():
		menu_scene.loading_tween.kill()

	menu_scene.loading_fill_bar.size.x = 336.0 * 0.55
	menu_scene.loading_pct_label.text = "55%"
	menu_scene.loading_status_label.text = "TUNING KULINTANG HARMONICS..."
	menu_scene.loading_container.modulate.a = 1.0

	await process_frame
	await process_frame

	var img_loading = root.get_viewport().get_texture().get_image()
	img_loading.save_png("scratch/snap_remade_loading_55.png")
	print("Saved scratch/snap_remade_loading_55.png")

	# Show Step 4 Menu with new ironwood button frames & fullness suite
	menu_scene.fade_rect.color.a = 0.0
	menu_scene.is_loading_assets = false
	menu_scene.is_in_splash = false
	menu_scene.is_in_press_start = false
	menu_scene.step3_container.visible = false
	menu_scene.loading_container.visible = false
	menu_scene.title_container.visible = true
	menu_scene.title_container.modulate.a = 1.0
	menu_scene.menu_vbox.visible = true
	menu_scene.menu_vbox.modulate.a = 1.0
	if is_instance_valid(menu_scene.menu_col_plaque):
		menu_scene.menu_col_plaque.visible = true
		menu_scene.menu_col_plaque.modulate.a = 1.0
	if is_instance_valid(menu_scene.preview_panel_root):
		menu_scene.preview_panel_root.visible = true
		menu_scene.preview_panel_root.modulate.a = 1.0
	menu_scene.ver_label.visible = true
	menu_scene.ver_label.modulate.a = 1.0
	menu_scene.altar_spr.visible = true
	menu_scene.altar_spr.modulate.a = 1.0

	await process_frame
	await process_frame

	var img_menu = root.get_viewport().get_texture().get_image()
	img_menu.save_png("scratch/snap_remade_menu_idle.png")
	print("Saved scratch/snap_remade_menu_idle.png")

	# Hover first button ("CONTINUE")
	var btn_cont = menu_scene.menu_vbox.get_child(0) as Button
	btn_cont.grab_focus()
	btn_cont.emit_signal("mouse_entered")
	await process_frame
	await process_frame

	var img_hover = root.get_viewport().get_texture().get_image()
	img_hover.save_png("scratch/snap_remade_menu_hover.png")
	print("Saved scratch/snap_remade_menu_hover.png")

	# Open Chronicle Slots modal ("CONTINUE" popup)
	menu_scene._on_slots_pressed()
	menu_scene.slot_select_modal.modulate.a = 1.0
	await process_frame
	await process_frame

	var img_slots = root.get_viewport().get_texture().get_image()
	img_slots.save_png("scratch/snap_menu_slots_modal.png")
	print("Saved scratch/snap_menu_slots_modal.png")

	menu_scene.queue_free()
	await process_frame
	await process_frame

	# 2. Capture In-Game Stage Progress Tracker in Main Gameplay Scene
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame
	await process_frame

	# Position player at 35% of level width to show dynamic progress
	if is_instance_valid(main_scene.player):
		main_scene.player.global_position.x = main_scene.current_level_width * 0.35
		main_scene.update_stage_progress_tracker()

	await process_frame
	await process_frame

	var img_gameplay = root.get_viewport().get_texture().get_image()
	img_gameplay.save_png("scratch/snap_remade_gameplay_tracker.png")
	print("Saved scratch/snap_remade_gameplay_tracker.png")

	quit()

extends SceneTree

func _init() -> void:
	# Ensure slot 1 has save data so CONTINUE button appears
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

	_run_verification()

func _run_verification() -> void:
	var scene = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(scene)

	# Wait for _ready() to complete
	await process_frame
	await process_frame

	# 1. Test Loading Bar at 45%
	scene._start_loading_sequence()
	if scene.loading_tween and scene.loading_tween.is_valid():
		scene.loading_tween.kill()

	scene.loading_fill_bar.size.x = 336.0 * 0.45
	scene.loading_pct_label.text = "45%"
	scene.loading_status_label.text = "LOADING ANCIENT ASSETS..."
	scene.loading_container.modulate.a = 1.0

	await process_frame
	await process_frame

	var img_loading = root.get_viewport().get_texture().get_image()
	img_loading.save_png("scratch/snap_loading_45.png")
	print("Saved scratch/snap_loading_45.png")

	# 2. Test Step 4 Menu (hide Step 3 center title!)
	scene.fade_rect.color.a = 0.0
	scene.is_loading_assets = false
	scene.is_in_splash = false
	scene.is_in_press_start = false
	scene.step3_container.visible = false
	scene.loading_container.visible = false
	scene.title_container.visible = true
	scene.title_container.modulate.a = 1.0
	scene.menu_vbox.visible = true
	scene.menu_vbox.modulate.a = 1.0
	scene.ver_label.visible = true
	scene.ver_label.modulate.a = 1.0
	scene.altar_spr.visible = true
	scene.altar_spr.modulate.a = 1.0

	await process_frame
	await process_frame

	var img_menu = root.get_viewport().get_texture().get_image()
	img_menu.save_png("scratch/snap_menu_step4.png")
	print("Saved scratch/snap_menu_step4.png")

	# Check menu buttons
	var buttons = []
	for c in scene.menu_vbox.get_children():
		if c is Button:
			buttons.append(c.text.strip_edges())
	print("Menu Buttons: ", buttons)

	var quit_btn = scene.menu_vbox.get_child(scene.menu_vbox.get_child_count() - 1)
	print("Quit button global rect: ", quit_btn.get_global_rect())
	print("Version label global rect: ", scene.ver_label.get_global_rect())

	var gap = scene.ver_label.get_global_rect().position.y - (quit_btn.get_global_rect().position.y + quit_btn.get_global_rect().size.y)
	print("Vertical gap between QUIT and VersionLabel: ", gap, "px")

	# 3. Simulate Hover on CONTINUE
	var continue_btn = scene.menu_vbox.get_child(0)
	continue_btn.emit_signal("mouse_entered")
	await process_frame
	await process_frame

	var img_hover = root.get_viewport().get_texture().get_image()
	img_hover.save_png("scratch/snap_menu_hover.png")
	print("Saved scratch/snap_menu_hover.png")

	# 4. Simulate Click on CONTINUE -> opens slot_select_modal
	continue_btn.emit_signal("pressed")
	await process_frame
	await process_frame

	var img_modal = root.get_viewport().get_texture().get_image()
	img_modal.save_png("scratch/snap_menu_slots_modal.png")
	print("Saved scratch/snap_menu_slots_modal.png")
	print("Slot modal visible: ", scene.slot_select_modal.visible)

	quit()

extends SceneTree

func _init() -> void:
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)

	# 1. Capture Stage 1: Group 2 Splash
	await create_timer(1.0).timeout
	var img_g2 = root.get_texture().get_image()
	img_g2.save_png("res://snapshot_stage1_group2.png")
	print("[TEST] Saved snapshot_stage1_group2.png")

	# 2. Advance to Stage 2: Log's Production
	menu._advance_splash_stage(true)
	await create_timer(0.8).timeout
	var img_logs = root.get_texture().get_image()
	img_logs.save_png("res://snapshot_stage2_logs.png")
	print("[TEST] Saved snapshot_stage2_logs.png")

	# 3. Advance to Stage 3: Title Screen with centered Press Any Key
	menu._advance_splash_stage(true)
	await create_timer(1.0).timeout
	var img_title = root.get_texture().get_image()
	img_title.save_png("res://snapshot_stage3_title.png")
	print("[TEST] Saved snapshot_stage3_title.png")

	# 4. Trigger Press Any Key -> Main Menu buttons revealed
	menu._on_press_start_triggered()
	await create_timer(0.6).timeout
	var img_menu = root.get_texture().get_image()
	img_menu.save_png("res://snapshot_stage4_menu.png")
	print("[TEST] Saved snapshot_stage4_menu.png")

	menu.free()
	print("[TEST] All 4 snapshots captured successfully!")
	quit(0)

extends SceneTree

func _init() -> void:
	print("--- Running Level Progress Bar Verification & Captures ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(25):
		await process_frame

	if is_instance_valid(main.ui_layer):
		main.ui_layer.layer = 10

	if is_instance_valid(main.player):
		main.player.set_physics_process(false)

	# ── 1. TREE CANOPY (Level 0, Forest 1-1: Whispering Canopy) ──
	print("Switching to Tree Canopy background (Level 0)...")
	main.jump_to_level(0)
	for i in range(35):
		await process_frame

	# Ensure contrast background updates
	main.update_hud_contrast()
	main.is_transitioning = true

	var ratios = [0.0, 0.25, 0.50, 0.75, 1.0]
	var pct_names = ["0", "25", "50", "75", "100"]

	for idx in range(ratios.size()):
		var r = ratios[idx]
		var name_str = pct_names[idx]
		print("Capturing Canopy at %s%% (ratio=%.2f)..." % [name_str, r])
		var terrain_w = maxf(1000.0, main.current_level_width)
		if is_instance_valid(main.player):
			main.player.global_position.x = r * terrain_w
		if is_instance_valid(main.level_progress_bar) and (r == 0.25 or r == 0.50):
			main.level_progress_bar.milestone_hold_timer = 0.0
		main.update_stage_progress_tracker()
		for f in range(30):
			await process_frame
		_save_capture("progress_canopy_%s.png" % name_str)

	# ── 2. OPEN SKY (Level 3, Rice Field 2-1: Daytime Open Sky) ──
	print("Switching to Open Sky background (Level 3)...")
	main.is_transitioning = false
	main.jump_to_level(3)
	for i in range(35):
		await process_frame

	main.update_hud_contrast()
	main.is_transitioning = true

	for idx in range(ratios.size()):
		var r = ratios[idx]
		var name_str = pct_names[idx]
		print("Capturing Open Sky at %s%% (ratio=%.2f)..." % [name_str, r])
		var terrain_w = maxf(1000.0, main.current_level_width)
		if is_instance_valid(main.player):
			main.player.global_position.x = r * terrain_w
		if is_instance_valid(main.level_progress_bar) and (r == 0.25 or r == 0.50):
			main.level_progress_bar.milestone_hold_timer = 0.0
		main.update_stage_progress_tracker()
		for f in range(30):
			await process_frame
		_save_capture("progress_sky_%s.png" % name_str)

	print("--- ALL LEVEL PROGRESS BAR SCREENSHOTS CAPTURED SUCCESSFULLY ---")
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

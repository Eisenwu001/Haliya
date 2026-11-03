extends SceneTree

func _init():
	print("Starting multi-level cave screenshot capture...")
	var main_scn = load('res://scenes/main.tscn')
	if not main_scn:
		printerr("Failed to load main.tscn")
		quit(1)
		return
	
	var levels = [
		{"idx": 11, "name": "cave_4_1", "cam_x": 750.0},
		{"idx": 12, "name": "cave_4_2", "cam_x": 600.0},
		{"idx": 13, "name": "cave_4_3", "cam_x": 600.0},
		{"idx": 14, "name": "cave_5_boss", "cam_x": 500.0}
	]
	
	for lvl in levels:
		var main_inst = main_scn.instantiate()
		main_inst.start_level_idx = lvl["idx"]
		root.add_child(main_inst)

		for i in range(25):
			await process_frame

		if main_inst.player:
			main_inst.player.global_position = Vector2(lvl["cam_x"], 220.0)
		if main_inst.camera:
			main_inst.camera.global_position = Vector2(lvl["cam_x"], 200.0)

		for i in range(20):
			await process_frame

		var img = root.get_texture().get_image()
		if img:
			var out_p = "scratch/" + lvl["name"] + "_verified.png"
			img.save_png(out_p)
			print("Saved: ", out_p)
			
		main_inst.queue_free()
		for i in range(5):
			await process_frame

	print("ALL CAVE SCREENSHOTS COMPLETED!")
	quit(0)

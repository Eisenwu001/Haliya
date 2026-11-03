extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/"
	
	var levels_to_capture = [
		{"idx": 11, "name": "snapshot_level_4_1_spawn", "cam_x": 240.0, "cam_y": 240.0},
		{"idx": 11, "name": "snapshot_level_4_1_platforming", "cam_x": 850.0, "cam_y": 220.0},
		{"idx": 12, "name": "snapshot_level_4_2_sunken_ruins", "cam_x": 450.0, "cam_y": 230.0},
		{"idx": 13, "name": "snapshot_level_4_3_abyssal_gauntlet", "cam_x": 650.0, "cam_y": 220.0},
		{"idx": 14, "name": "snapshot_level_5_bakunawa_abyss", "cam_x": 4200.0, "cam_y": 220.0}
	]
	
	for lvl in levels_to_capture:
		MainScript.start_level_idx = lvl["idx"]
		var inst = main_scene.instantiate()
		root.add_child(inst)
		
		# Wait for scene initialization
		for f in range(25):
			await process_frame
		
		var cam = inst.find_child("Camera2D", true, false)
		var p = inst.find_child("Player", true, false)
		if cam:
			cam.global_position = Vector2(lvl["cam_x"], lvl["cam_y"])
		if p:
			p.global_position = Vector2(lvl["cam_x"], 240.0)
			
		for f in range(20):
			await process_frame
		
		var img = root.get_texture().get_image()
		if img:
			var out_artifact = artifact_dir + lvl["name"] + ".png"
			var out_scratch = "scratch/" + lvl["name"] + ".png"
			img.save_png(out_artifact)
			img.save_png(out_scratch)
			print("Captured & saved: ", lvl["name"], " (", img.get_width(), "x", img.get_height(), ")")
		
		inst.free()
		for f in range(5):
			await process_frame

	print("ALL CAVE SNAPSHOTS COMPLETED SUCCESSFULLY!")
	quit(0)

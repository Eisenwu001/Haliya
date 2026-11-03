extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/"

	var chambers_to_capture = [
		{"name": "snapshot_hk_chamber_1_entry", "cam_x": 420.0, "cam_y": 180.0, "p_x": 420.0, "p_y": 288.0},
		{"name": "snapshot_hk_chamber_2_shaft", "cam_x": 1200.0, "cam_y": 580.0, "p_x": 1200.0, "p_y": 580.0},
		{"name": "snapshot_hk_chamber_3_grotto", "cam_x": 2460.0, "cam_y": 720.0, "p_x": 2460.0, "p_y": 864.0},
		{"name": "snapshot_hk_chamber_4_cathedral", "cam_x": 3880.0, "cam_y": 480.0, "p_x": 3880.0, "p_y": 480.0},
		{"name": "snapshot_hk_chamber_5_sanctuary", "cam_x": 5400.0, "cam_y": 180.0, "p_x": 5400.0, "p_y": 288.0},
	]

	MainScript.start_level_idx = 11 # Level 4-1
	var inst = main_scene.instantiate()
	root.add_child(inst)

	# Wait for scene initialization
	for f in range(30):
		await process_frame

	var cam = inst.find_child("Camera2D", true, false)
	var p = inst.find_child("Player", true, false)

	for ch in chambers_to_capture:
		if p:
			p.global_position = Vector2(ch["p_x"], ch["p_y"])
			p.velocity = Vector2.ZERO
		if cam:
			cam.global_position = Vector2(ch["cam_x"], ch["cam_y"])

		for f in range(25):
			await process_frame

		var img = root.get_texture().get_image()
		if img:
			var out_artifact = artifact_dir + ch["name"] + ".png"
			var out_scratch = "scratch/" + ch["name"] + ".png"
			img.save_png(out_artifact)
			img.save_png(out_scratch)
			print("Captured & saved: ", ch["name"], " (", img.get_width(), "x", img.get_height(), ")")

	inst.free()
	print("ALL HOLLOW KNIGHT CAVERN SNAPSHOTS COMPLETED SUCCESSFULLY!")
	quit(0)

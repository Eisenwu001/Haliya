@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var scn = load("res://scenes/main.tscn")
	
	MainScript.start_level_idx = 3 # Level 2-1
	var inst = scn.instantiate()
	root.add_child(inst)
	
	for i in range(20):
		await process_frame
		
	var cam: Camera2D = inst.camera
	var player: CharacterBody2D = inst.player
	
	var cam_positions = [
		{"x": 200.0, "file": "pan_2_1_start.png"},
		{"x": 1500.0, "file": "pan_2_1_mid.png"},
		{"x": 3000.0, "file": "pan_2_1_end.png"}
	]
	
	for cp in cam_positions:
		if player:
			player.global_position.x = cp["x"]
		if cam:
			cam.global_position.x = cp["x"]
			
		for i in range(15):
			await process_frame
			
		var img = root.get_texture().get_image()
		if img:
			var path = "C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/" + cp["file"]
			img.save_png(path)
			print("Saved: ", path)
			
	inst.free()
	quit(0)

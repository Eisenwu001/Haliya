@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var scn = load("res://scenes/main.tscn")
	
	var stages = [
		{"idx": 3, "file": "new_level_2_1.png"},
		{"idx": 4, "file": "new_level_2_2.png"},
		{"idx": 5, "file": "new_level_2_3.png"}
	]
	
	for st in stages:
		MainScript.start_level_idx = st["idx"]
		var inst = scn.instantiate()
		root.add_child(inst)
		
		for i in range(25):
			await process_frame
			
		var img = root.get_texture().get_image()
		if img:
			var path = "C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/" + st["file"]
			img.save_png(path)
			print("Saved: ", path)
			
		inst.free()
		
	quit(0)

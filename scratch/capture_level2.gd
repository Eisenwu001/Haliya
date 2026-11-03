@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var scn = load("res://scenes/main.tscn")
	MainScript.start_level_idx = 3 # Level 2-1 Rice Field
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(30):
		await process_frame
	var img = root.get_texture().get_image()
	if img:
		img.save_png("C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/level_2_1_ricefield_current.png")
		print("Saved level_2_1_ricefield_current.png")
	inst.free()
	quit(0)

@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	MainScript.start_level_idx = 3
	var scn = load("res://scenes/main.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)

	for i in range(25):
		await process_frame

	var img = root.get_texture().get_image()
	if img:
		img.save_png("C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/current_level_2_1.png")
		print("Saved current_level_2_1.png")

	inst.free()
	quit(0)

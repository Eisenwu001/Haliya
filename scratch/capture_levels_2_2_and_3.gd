@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	
	# Level 2-2 (index 4)
	MainScript.start_level_idx = 4
	var scn = load("res://scenes/main.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)

	for i in range(25):
		await process_frame

	var img = root.get_texture().get_image()
	if img:
		img.save_png("scratch/level_2_2.png")
		print("Saved level_2_2.png")

	inst.free()

	# Level 2-3 (index 5)
	MainScript.start_level_idx = 5
	inst = scn.instantiate()
	root.add_child(inst)

	for i in range(25):
		await process_frame

	img = root.get_texture().get_image()
	if img:
		img.save_png("scratch/level_2_3.png")
		print("Saved level_2_3.png")

	inst.free()
	quit(0)

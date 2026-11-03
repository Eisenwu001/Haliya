@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var scn = load("res://scenes/main.tscn")
	MainScript.start_level_idx = 0 # Level 2-1 Rice Field
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(30):
		await process_frame
	var p = inst.get_node("Player")
	var cam = inst.get_node("Camera2D")
	print("Player pos:", p.global_position)
	print("Camera pos:", cam.global_position)
	inst.free()
	quit(0)

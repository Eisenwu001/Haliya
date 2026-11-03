@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var scn = load("res://scenes/main.tscn")
	MainScript.start_level_idx = 3 # Level 2-1
	var inst = scn.instantiate()
	root.add_child(inst)
	for i in range(10):
		await process_frame
	var p = inst.player
	var cam = inst.camera
	print("PLAYER GLOBAL POS: ", p.global_position if p else "null")
	print("CAMERA GLOBAL POS: ", cam.global_position if cam else "null")
	var bg_layer1 = inst.get_node_or_null("ParallaxBackground/RiceFieldLayer_1")
	if bg_layer1:
		print("BG LAYER 1 POS: ", bg_layer1.position, " MOTION_SCALE: ", bg_layer1.motion_scale, " MIRROR: ", bg_layer1.motion_mirroring)
		for c in bg_layer1.get_children():
			print("  CHILD: ", c.name, " pos: ", c.position, " scale: ", c.scale)
	inst.free()
	quit(0)

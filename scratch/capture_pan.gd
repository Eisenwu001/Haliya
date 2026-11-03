@tool
extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	MainScript.start_level_idx = 3
	var scn = load("res://scenes/main.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)

	for i in range(20):
		await process_frame

	var camera = inst.get_node_or_null("Camera2D")
	var player = inst.get_node_or_null("Player")
	
	# Snapshot 1: Start
	var img1 = root.get_texture().get_image()
	if img1:
		img1.save_png("scratch/pan_2_1_start.png")
		print("Saved pan_2_1_start.png")

	# Move player & camera to x = 700
	if player:
		player.global_position.x = 700.0
	if camera:
		camera.global_position.x = 700.0
	for i in range(15):
		await process_frame

	var img2 = root.get_texture().get_image()
	if img2:
		img2.save_png("scratch/pan_2_1_mid.png")
		print("Saved pan_2_1_mid.png")

	# Move player & camera to x = 1400
	if player:
		player.global_position.x = 1400.0
	if camera:
		camera.global_position.x = 1400.0
	for i in range(15):
		await process_frame

	var img3 = root.get_texture().get_image()
	if img3:
		img3.save_png("scratch/pan_2_1_end.png")
		print("Saved pan_2_1_end.png")

	inst.free()
	quit(0)

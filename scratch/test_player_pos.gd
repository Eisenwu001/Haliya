extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	for i in range(20):
		await process_frame
	main.jump_to_level(0)
	for i in range(30):
		await process_frame
	if main.player:
		print("Player global_position:", main.player.global_position)
		print("Player canvas pos:", main.player.get_global_transform_with_canvas().origin)
		print("Camera global_pos:", main.camera.global_position if main.camera else "no cam")
	quit()

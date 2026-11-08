extends SceneTree

func _init() -> void:
	print("--- Running Haliya Cloth In-Game Verification ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(30):
		await process_frame

	if is_instance_valid(main.player):
		main.player.set_physics_process(false)

	# Level 0 (Forest 1-1)
	main.jump_to_level(0)
	for i in range(40):
		await process_frame

	main.is_transitioning = true

	# 1. Idle capture
	if is_instance_valid(main.player):
		main.player.current_state = Player.State.IDLE
		main.player.sprite.texture = main.player.idle_frames[0]
	for f in range(25):
		await process_frame
	_save_capture("haliya_cloth_ingame_idle.png")

	# 2. Walk capture
	if is_instance_valid(main.player):
		main.player.current_state = Player.State.WALK
		main.player.sprite.texture = main.player.walk_frames[2]
	for f in range(25):
		await process_frame
	_save_capture("haliya_cloth_ingame_walk.png")

	# 3. Crouch capture
	if is_instance_valid(main.player):
		main.player.current_state = Player.State.CROUCH
		main.player.crouch_sub_state = 2
		main.player.sprite.texture = main.player.crouch_to_idle_frames[0]
	for f in range(25):
		await process_frame
	_save_capture("haliya_cloth_ingame_crouch.png")

	print("--- ALL HALIYA CLOTH SCREENSHOTS CAPTURED ---")
	main.free()
	quit(0)

func _save_capture(filename: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var path = "res://" + filename
		img.save_png(path)
		print("Saved screenshot: %s" % filename)
	else:
		push_error("Failed to capture image for %s" % filename)

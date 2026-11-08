extends SceneTree

func _init() -> void:
	print("Starting Haliya cloth verification capture...")
	var MainScript = load("res://scripts/main.gd")
	var main = MainScript.new()
	root.add_child(main)
	
	await process_frame
	await process_frame
	
	main.jump_to_level(0)
	await process_frame
	await process_frame
	
	main.is_transitioning = true
	
	# 1. Capture Idle
	main.player.velocity = Vector2.ZERO
	main.player.current_state = Player.State.IDLE
	main.player.sprite.texture = main.player.idle_frames[0]
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_idle.png")
	
	# 2. Capture Walk
	main.player.current_state = Player.State.WALK
	main.player.sprite.texture = main.player.walk_frames[2]
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_walk.png")
	
	# 3. Capture Crouch Hold (idle_crouch_frames[0])
	main.player.current_state = Player.State.CROUCH
	main.player.crouch_sub_state = 1
	main.player.sprite.texture = main.player.idle_crouch_frames[0]
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_crouch_hold.png")
	
	# 4. Capture Run (run_frames[1])
	main.player.current_state = Player.State.RUN
	main.player.sprite.texture = main.player.run_frames[1]
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_run.png")
	
	print("All in-game verifications captured successfully!")
	quit()

func capture_screen(path: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot to: ", path)

extends SceneTree

func _init() -> void:
	print("Starting in-game organic cloth captures...")
	var MainScript = load("res://scripts/main.gd")
	var main = MainScript.new()
	root.add_child(main)
	
	await process_frame
	await process_frame
	
	main.jump_to_level(0)
	await process_frame
	await process_frame
	
	main.is_transitioning = true
	
	# 1. Capture Remade Organic Run
	main.player.current_state = Player.State.RUN
	main.player.sprite.texture = main.player.run_frames[1]
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_organic_run.png")
	
	# 2. Capture Remade Organic Jump
	main.player.velocity = Vector2(0, -250)
	main.player.current_state = Player.State.JUMP
	main.player.sprite.texture = main.player.jump_up_frames[0]
	main.player.position.y -= 40
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_organic_jump.png")
	
	print("All organic in-game captures complete!")
	quit()

func capture_screen(path: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot to: ", path)

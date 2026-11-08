extends SceneTree

func _init() -> void:
	print("Starting in-game jump verification capture...")
	var MainScript = load("res://scripts/main.gd")
	var main = MainScript.new()
	root.add_child(main)
	
	await process_frame
	await process_frame
	
	main.jump_to_level(0)
	await process_frame
	await process_frame
	
	main.is_transitioning = true
	
	# Jump ascending capture
	main.player.velocity = Vector2(0, -250)
	main.player.current_state = Player.State.JUMP
	main.player.sprite.texture = main.player.jump_up_frames[0]
	main.player.position.y -= 40 # slightly in air
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_jump.png")
	
	print("In-game jump captured successfully!")
	quit()

func capture_screen(path: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot to: ", path)

extends SceneTree

func _init() -> void:
	print("Starting in-game all-actions verification capture...")
	var MainScript = load("res://scripts/main.gd")
	var main = MainScript.new()
	root.add_child(main)
	
	await process_frame
	await process_frame
	
	main.jump_to_level(0)
	await process_frame
	await process_frame
	
	main.is_transitioning = true
	
	# 1. Attack Combo
	main.player.current_state = Player.State.ATTACK
	var atk_tex = load("res://assets/haliya/attack_01_cobination0102.png")
	main.player.sprite.texture = atk_tex
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_attack.png")
	
	# 2. Guard
	main.player.current_state = Player.State.GUARD
	var guard_tex = load("res://assets/haliya/common_31_guard_stand01.png")
	main.player.sprite.texture = guard_tex
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_guard.png")
	
	# 3. Break / Skid
	main.player.current_state = Player.State.BREAK
	var break_tex = load("res://assets/haliya/common_13_break02.png")
	main.player.sprite.texture = break_tex
	await process_frame
	await process_frame
	capture_screen("scratch/haliya_in_game_break.png")
	
	print("All in-game action captures completed successfully!")
	quit()

func capture_screen(path: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot to: ", path)

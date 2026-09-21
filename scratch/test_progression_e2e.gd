@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout
	
	print("--- Starting End-to-End Progression Test ---")
	for lvl in range(6):
		print("At level index: ", main_scene.current_level_idx, " (", main_scene.LEVELS_DATA[main_scene.current_level_idx]["level_title"], ")")
		assert(main_scene.current_level_idx == lvl, "Wrong level index!")
		
		# Move player to near the end
		main_scene.player.global_position = Vector2(5040.0, main_scene.get_level_end_ground_y() - 20.0)
		main_scene.player.velocity = Vector2(200.0, 0.0)
		
		# Step forward so player crosses 5050.0
		var transitioned = false
		for f in range(60):
			main_scene.player.move_and_slide()
			main_scene._process(0.01666)
			if main_scene.is_transitioning:
				transitioned = true
				break
		assert(transitioned, "Level did not trigger transition!")
		print("  Transition triggered successfully at x=", main_scene.player.global_position.x)
		
		# Complete the fade-out and fade-in
		main_scene._on_fade_out_complete()
		if not main_scene.is_game_won:
			main_scene._on_fade_in_complete()
		await create_timer(0.1).timeout
		
	print("Game won state: ", main_scene.is_game_won)
	assert(main_scene.is_game_won, "Game should be won after completing all 6 levels!")
	print("ALL 6 LEVELS PROGRESSION VERIFIED PERFECTLY!")
	main_scene.free()
	quit(0)

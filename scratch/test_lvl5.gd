@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout
	
	main_scene.current_level_idx = 5
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	await create_timer(0.1).timeout
	
	print("Level 2-3 ground_end_y: ", main_scene.get_level_end_ground_y())
	print("Level 2-3 MAP_TRANSITION_EDGE_X: ", main_scene.MAP_TRANSITION_EDGE_X)
	
	main_scene.player.global_position = Vector2(5040.0, main_scene.get_level_end_ground_y() - 20.0)
	main_scene.player.velocity = Vector2(200.0, 0.0)
	
	for f in range(60):
		main_scene.player.move_and_slide()
		main_scene._process(0.01666)
		if main_scene.is_transitioning:
			print("  Level 2-3 triggered transition! Player at x=", main_scene.player.global_position.x)
			break
			
	print("Transition state: ", main_scene.is_transitioning)
	main_scene._on_fade_out_complete()
	print("is_game_won: ", main_scene.is_game_won)
	main_scene.free()
	quit(0)

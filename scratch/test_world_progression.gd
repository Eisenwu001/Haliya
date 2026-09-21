extends Node2D

func _ready() -> void:
	print("=== Starting World Progression & Levels 3-1..3-5 Test ===")
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "main.tscn must exist")

	var main = main_scene.instantiate()
	add_child(main)

	# Verify LEVELS_DATA count
	print("Checking LEVELS_DATA size: ", main.LEVELS_DATA.size())
	assert(main.LEVELS_DATA.size() == 11, "Must have exactly 11 levels (3 Forest, 3 Rice Field, 5 Rainy Forest)")

	# Verify themes of all levels
	for idx in range(main.LEVELS_DATA.size()):
		var data = main.LEVELS_DATA[idx]
		var theme = data["theme"]
		var lvl_title = data["level_title"]
		var scene_path = data["scene_path"]
		print("Level [%d] %s - Theme: %s, Scene: %s" % [idx, lvl_title, theme, scene_path])
		assert(ResourceLoader.exists(scene_path), "Scene must exist: " + scene_path)

		if idx < 3:
			assert(theme == "Forest", "World 1 must be Forest theme")
		elif idx < 6:
			assert(theme == "Rice Field", "World 2 must be Rice Field theme")
		else:
			assert(theme == "Rainy Forest", "World 3 must be Rainy Forest theme")

	# Test Level 2-3 weather transition
	print("\n--- Verifying Level 2-3 Weather Transition ---")
	main.current_level_idx = 5
	main.load_current_level()
	main.set_background_theme("Rice Field")
	main.player.global_position.x = 192.0
	main._process(0.016)

	assert(main.current_storm_intensity == 0.0, "Storm intensity should be 0.0 at start of 2-3")
	assert(not main.rain_particles.emitting, "Rain should NOT emit at start of 2-3")

	main.player.global_position.x = 4200.0
	for _i in range(15):
		main._process(0.016)
	assert(main.current_storm_intensity >= 0.49 and main.current_storm_intensity <= 0.51, "Storm intensity ~0.5 at x=4200")
	assert(main.rain_particles.emitting, "Rain MUST emit at x=4200")

	main.player.global_position.x = 4800.0
	for _i in range(15):
		main._process(0.016)
	assert(main.current_storm_intensity == 1.0, "Storm intensity 1.0 at x=4800")
	assert(main.rain_particles.emitting, "Rain MUST emit at x=4800")

	# Test World 3 levels (3-1 to 3-5) loading and atmosphere
	print("\n--- Verifying World 3 (Levels 3-1 to 3-5) ---")
	for lvl_idx in range(6, 11):
		main.current_level_idx = lvl_idx
		main.load_current_level()
		var lvl_info = main.LEVELS_DATA[lvl_idx]
		main.set_background_theme(lvl_info["theme"])
		main.spawn_level_enemies()

		for _i in range(10):
			main._process(0.016)

		var cur_inst = main.current_level_instance
		assert(cur_inst != null, "Current level instance must be valid for " + lvl_info["level_title"])
		assert(main.rain_particles.emitting, "Rain must be emitting in " + lvl_info["level_title"])
		assert(main.current_storm_intensity == 1.0, "Storm intensity must be 1.0 in " + lvl_info["level_title"])
		assert(main.canvas_modulate.color.r < 0.5, "Atmosphere must be dark stormy in " + lvl_info["level_title"])

		var ground = cur_inst.find_child("BaseGround", true, false)
		var water = cur_inst.find_child("WaterBackground", true, false)
		var decor = cur_inst.find_child("ForegroundDecor", true, false)
		var foliage = cur_inst.find_child("Foliage", true, false)
		var torches = cur_inst.find_child("Torches", true, false)
		var breakables = cur_inst.find_child("Breakables", true, false)
		var enemies_node = cur_inst.find_child("Enemies", true, false)

		assert(ground != null, "BaseGround missing in " + lvl_info["level_title"])
		assert(water != null, "WaterBackground missing in " + lvl_info["level_title"])
		assert(decor != null, "ForegroundDecor missing in " + lvl_info["level_title"])
		assert(foliage != null, "Foliage missing in " + lvl_info["level_title"])
		assert(torches != null, "Torches missing in " + lvl_info["level_title"])
		assert(breakables != null, "Breakables missing in " + lvl_info["level_title"])
		assert(enemies_node != null, "Enemies missing in " + lvl_info["level_title"])

		var enemies_in_scene = enemies_node.get_children().size()
		print("  %s (%s): %d enemies in scene, active_enemies count: %d" % [
			lvl_info["level_title"],
			lvl_info["scene_title"],
			enemies_in_scene,
			main.active_enemies.size()
		])
		assert(enemies_in_scene >= 5, "Level should have at least 5 enemies")
		assert(main.active_enemies.size() >= 5, "Main active_enemies should track at least 5 enemies")

	# Test victory screen trigger at end of 3-5
	print("\n--- Verifying Victory State ---")
	main.current_level_idx = 10 # Level 3-5
	main.trigger_win()
	assert(main.is_game_won, "is_game_won must be true")
	print("Victory state triggered successfully!")

	print("\n=== ALL WORLD PROGRESSION TESTS PASSED! ===")
	get_tree().quit(0)

@tool
extends SceneTree

func _init() -> void:
	print("--- Starting Weather Transition Test ---")
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("Failed to load main.tscn")
		quit(1)
		return

	var main = main_scene.instantiate()
	root.add_child(main)
	main._ready()

	# Jump directly to Level 2-3 (idx = 5)
	main.current_level_idx = 5
	main.load_current_level()
	main.set_background_theme("Rice Field")

	assert(main.player != null, "Player must be initialized")

	# Initial state at start of level (x = 192)
	main.player.global_position.x = 192.0
	main._process(0.016)

	print("Initial State (x=192):")
	print("  Storm Intensity: ", main.current_storm_intensity)
	print("  Rain Emitting: ", main.rain_particles.emitting)
	print("  Canvas Modulate: ", main.canvas_modulate.color)

	assert(main.current_storm_intensity == 0.0, "Storm intensity should be 0.0 at start")
	assert(not main.rain_particles.emitting, "Rain should NOT be emitting at start of 2-3")
	assert(main.canvas_modulate.color == Color(1, 1, 1, 1), "Lighting should be normal at start")

	# Move player to x = 4200 (halfway through transition: (4200-3700)/1000 = 0.5)
	main.player.global_position.x = 4200.0
	for _i in range(25):
		main._process(0.016)

	print("Mid-transition State (x=4200):")
	print("  Storm Intensity: ", main.current_storm_intensity)
	print("  Rain Emitting: ", main.rain_particles.emitting)
	print("  Rain Alpha: ", main.rain_particles.modulate.a)
	print("  Canvas Modulate: ", main.canvas_modulate.color)

	assert(main.current_storm_intensity >= 0.49 and main.current_storm_intensity <= 0.51, "Storm intensity should be ~0.5 at x=4200")
	assert(main.rain_particles.emitting, "Rain SHOULD be emitting at x=4200")
	assert(main.canvas_modulate.color.r < 0.85, "CanvasModulate should be darkening")

	# Move player to x = 4800 (full storm: (4800-3700)/1000 = 1.0 clamped)
	main.player.global_position.x = 4800.0
	for _i in range(25):
		main._process(0.016)

	print("Full Storm State (x=4800):")
	print("  Storm Intensity: ", main.current_storm_intensity)
	print("  Rain Emitting: ", main.rain_particles.emitting)
	print("  Rain Alpha: ", main.rain_particles.modulate.a)
	print("  Canvas Modulate: ", main.canvas_modulate.color)

	assert(main.current_storm_intensity == 1.0, "Storm intensity should be 1.0 at x=4800")
	assert(main.rain_particles.emitting, "Rain should be emitting at x=4800")
	assert(main.rain_particles.modulate.a == 1.0, "Rain modulate alpha should be 1.0")
	assert(main.canvas_modulate.color.r < 0.55, "CanvasModulate should be fully darkened at x=4800")

	# Now test World 3 theme setting (Level 3-1, idx = 6)
	main.current_level_idx = 6
	main.load_current_level()
	main.set_background_theme("Rainy Forest")
	for _i in range(25):
		main._process(0.016)

	print("World 3 (Level 3-1 Rainy Forest) State:")
	print("  Storm Intensity: ", main.current_storm_intensity)
	print("  Rain Emitting: ", main.rain_particles.emitting)
	print("  Canvas Modulate: ", main.canvas_modulate.color)

	assert(main.current_storm_intensity == 1.0, "Storm intensity should be 1.0 in World 3")
	assert(main.rain_particles.emitting, "Rain should be emitting in World 3")
	assert(main.canvas_modulate.color.r < 0.5, "CanvasModulate should be dark stormy")

	main.queue_free()
	print("--- Weather Transition Test PASSED! ---")
	quit(0)

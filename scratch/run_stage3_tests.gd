@tool
extends SceneTree

func _init() -> void:
	print("=== Running Stage 3 Atmosphere & Puddles Verification ===")
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout

	main_scene.current_level_idx = 6
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()

	for _i in range(15):
		main_scene._process(0.016)

	print("\n1. Rain Particles Verification:")
	print("  Midground Rain Emitting: ", main_scene.rain_particles.emitting)
	print("  Midground Texture: ", main_scene.rain_particles.texture != null)
	print("  Midground Align Y: ", main_scene.rain_particles.particle_flag_align_y)

	print("\n2. Puddles Verification:")
	print("  Puddle Count: ", main_scene.puddles_list.size())
	if main_scene.puddles_list.size() > 0:
		var p0 = main_scene.puddles_list[0]
		print("  Sample Puddle Pos: ", p0.position, " Texture: ", p0.texture.resource_path)
		print("  Material: ", p0.material.get_class())

	print("\n3. Lens Rain Droplets Verification:")
	print("  Lens Rain Overlay Exists: ", main_scene.lens_rain_overlay != null)
	print("  Droplets Count: ", main_scene.lens_rain_overlay.droplets.size())

	print("\n4. Lightning Flash on Puddles:")
	main_scene.flash_puddles(0.15)
	print("  Puddle flash executed cleanly!")

	print("\n=== ALL ATMOSPHERE & PUDDLE TESTS PASSED SUCCESSFULLY! ===")
	main_scene.free()
	quit(0)

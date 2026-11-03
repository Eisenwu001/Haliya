@tool
extends SceneTree

func _init() -> void:
	print("--- Running Rice Field Particles & Background Verification ---")
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout

	# Load Level 2-1 (Emerald Terraces, idx = 3)
	main_scene.current_level_idx = 3
	main_scene.load_current_level()
	await create_timer(0.2).timeout

	# 1. Verify ambient particles are disabled in Rice Field
	assert(main_scene.ambient_particles != null, "ambient_particles node should exist")
	assert(main_scene.ambient_particles.emitting == false, "ambient_particles must NOT emit in Rice Field stage")
	print("✔ Ambient particles verified disabled in Rice Field (Level 2-1)")

	# 2. Verify Rice Field Parallax Layers
	assert(main_scene.rice_field_parallax_layers.size() == 4, "Must have 4 Rice Field parallax layers")
	for i in range(main_scene.rice_field_parallax_layers.size()):
		var layer = main_scene.rice_field_parallax_layers[i]
		assert(layer.visible == true, "Rice Field layer %d must be visible" % i)
		var spr = layer.get_child(0) as Sprite2D
		assert(spr != null and spr.texture != null, "Rice Field layer %d must have valid texture" % i)
		print("✔ Rice Field Parallax Layer %d verified: %s (%dx%d)" % [i, layer.name, spr.texture.get_width(), spr.texture.get_height()])

	# 3. Load Level 2-2 and 2-3 to verify particle suppression across entire World 2
	main_scene.current_level_idx = 4
	main_scene.load_current_level()
	await create_timer(0.1).timeout
	assert(main_scene.ambient_particles.emitting == false, "ambient_particles must NOT emit in Level 2-2")
	print("✔ Ambient particles verified disabled in Level 2-2")

	main_scene.current_level_idx = 5
	main_scene.load_current_level()
	await create_timer(0.1).timeout
	assert(main_scene.ambient_particles.emitting == false, "ambient_particles must NOT emit in Level 2-3")
	print("✔ Ambient particles verified disabled in Level 2-3")

	main_scene.free()
	print("--- ALL RICE FIELD VERIFICATIONS PASSED SUCCESSFULLY ---")
	quit(0)

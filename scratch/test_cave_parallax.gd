extends SceneTree

func _init() -> void:
	print("--- Running Cave Parallax Tests ---")

	# 1. Verify Assets constants
	var AssetsScript = load("res://scripts/assets.gd")
	var expected_paths = [
		AssetsScript.PATH_CAVE_LAYER_1,
		AssetsScript.PATH_CAVE_LAYER_2,
		AssetsScript.PATH_CAVE_LAYER_3FX,
		AssetsScript.PATH_CAVE_LAYER_4,
		AssetsScript.PATH_CAVE_LAYER_5,
		AssetsScript.PATH_CAVE_LAYER_6FX,
		AssetsScript.PATH_CAVE_LAYER_7,
		AssetsScript.PATH_CAVE_LAYER_8FX,
		AssetsScript.PATH_CAVE_LAYER_9
	]

	for i in range(expected_paths.size()):
		var path: String = expected_paths[i]
		if not ResourceLoader.exists(path):
			print("FAIL: Path does not exist: ", path)
			quit(1)
			return
		var tex = load(path)
		if not (tex is Texture2D):
			print("FAIL: Resource at %s is not a Texture2D" % path)
			quit(1)
			return
		print("PASS: Cave layer %d loaded successfully: %s (%dx%d)" % [i + 1, path.get_file(), tex.get_width(), tex.get_height()])

	# 2. Verify Main scene instantiation and parallax setup
	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	await process_frame

	print("PASS: Main node instantiated and added to root")

	var cave_layers = main_node.cave_parallax_layers
	if cave_layers.size() != 9:
		print("FAIL: Expected 9 cave parallax layers, got %d" % cave_layers.size())
		quit(1)
		return
	print("PASS: Found exactly 9 cave parallax layers")

	# Verify properties of each cave layer
	var prev_motion_x: float = 0.0
	for i in range(cave_layers.size()):
		var layer = cave_layers[i]
		if not (layer is ParallaxLayer):
			print("FAIL: Layer %d is not a ParallaxLayer" % i)
			quit(1)
			return
		if layer.get_child_count() != 2:
			print("FAIL: Layer %d does not have 2 sprites, got %d" % [i, layer.get_child_count()])
			quit(1)
			return
		if layer.motion_mirroring.x != 1280.0 or layer.motion_mirroring.y != 0.0:
			print("FAIL: Layer %d motion_mirroring expected (1280, 0), got %s" % [i, layer.motion_mirroring])
			quit(1)
			return
		if layer.motion_scale.x <= prev_motion_x:
			print("FAIL: Layer %d motion_scale.x (%f) not strictly increasing from prev (%f)" % [i, layer.motion_scale.x, prev_motion_x])
			quit(1)
			return
		prev_motion_x = layer.motion_scale.x
	print("PASS: Parallax layers have strictly increasing depth motion_scales and 1280px mirroring")

	# 3. Test theme switching
	# Test "Cave" theme
	main_node.set_background_theme("Cave")
	for layer in main_node.cave_parallax_layers:
		if not layer.visible:
			print("FAIL: Cave layer not visible in Cave theme")
			quit(1)
			return
	for layer in main_node.forest_parallax_layers:
		if layer.visible:
			print("FAIL: Forest layer visible in Cave theme")
			quit(1)
			return
	for layer in main_node.rice_field_parallax_layers:
		if layer.visible:
			print("FAIL: Rice field layer visible in Cave theme")
			quit(1)
			return
	if main_node.sky_parallax_layer.visible:
		print("FAIL: Sky parallax layer visible in Cave theme")
		quit(1)
		return
	print("PASS: Cave theme correctly enables cave layers and disables sky/forest/rice layers")

	# Test "Cave Boss" theme
	main_node.set_background_theme("Cave Boss")
	for layer in main_node.cave_parallax_layers:
		if not layer.visible:
			print("FAIL: Cave layer not visible in Cave Boss theme")
			quit(1)
			return
	print("PASS: Cave Boss theme correctly enables cave layers")

	# Test "Forest" theme
	main_node.set_background_theme("Forest")
	for layer in main_node.cave_parallax_layers:
		if layer.visible:
			print("FAIL: Cave layer visible in Forest theme")
			quit(1)
			return
	if not main_node.sky_parallax_layer.visible:
		print("FAIL: Sky layer not visible in Forest theme")
		quit(1)
		return
	print("PASS: Forest theme correctly disables cave layers and restores sky layer")

	main_node.queue_free()
	print("--- ALL CAVE PARALLAX TESTS PASSED ---")
	quit(0)

extends SceneTree

func _init() -> void:
	print("--- Running Level 4 and Level 5 In-Game Simulation Test ---")

	var main_scene = load("res://scenes/main.tscn")
	var main_node = main_scene.instantiate()
	main_node.start_level_idx = 11 # Stage 4: Cave
	root.add_child(main_node)
	await process_frame

	print("Current level theme: ", main_node.LEVELS_DATA[main_node.current_level_idx]["theme"])
	print("Current level title: ", main_node.LEVELS_DATA[main_node.current_level_idx]["full_title"])

	# Verify cave parallax layers are visible and active
	var visible_cave_count = 0
	for l in main_node.cave_parallax_layers:
		if l.visible:
			visible_cave_count += 1
	if visible_cave_count != 9:
		print("FAIL: Expected 9 visible cave parallax layers, got %d" % visible_cave_count)
		quit(1)
		return
	print("PASS: Level 4 has all 9 cave parallax layers visible")

	# Simulate 30 frames of gameplay
	for f in range(30):
		await process_frame

	print("PASS: Level 4 30-frame simulation completed smoothly")

	# Jump to Level 5 (Cave Boss)
	main_node.jump_to_level(12)
	await process_frame
	print("Jumped to: ", main_node.LEVELS_DATA[main_node.current_level_idx]["full_title"])
	visible_cave_count = 0
	for l in main_node.cave_parallax_layers:
		if l.visible:
			visible_cave_count += 1
	if visible_cave_count != 9:
		print("FAIL: Expected 9 visible cave parallax layers in Level 5, got %d" % visible_cave_count)
		quit(1)
		return
	print("PASS: Level 5 has all 9 cave parallax layers visible")

	for f in range(30):
		await process_frame

	print("PASS: Level 5 30-frame simulation completed smoothly")

	main_node.queue_free()
	print("--- ALL LEVEL SIMULATION TESTS PASSED ---")
	quit(0)

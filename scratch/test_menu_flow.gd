@tool
extends SceneTree

func _init() -> void:
	print("--- Testing Main Menu to Stage 3 Flow ---")
	var menu_res = load("res://scenes/main_menu.tscn")
	var menu = menu_res.instantiate()
	root.add_child(menu)
	await create_timer(0.2).timeout

	# Simulate choosing Stage III
	var MainScript = load("res://scripts/main.gd")
	MainScript.start_level_idx = 6 # Stage 3-1

	menu.free()
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	print("Current Level Index in Main:", main_scene.current_level_idx)
	assert(main_scene.current_level_idx == 6, "Expected Level Index to be 6 (Stage 3-1)")

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"
	var img = root.get_texture().get_image()
	if img:
		img.save_png(artifact_dir + "flow_stage_3_transition.png")
		print("Saved flow_stage_3_transition.png")

	main_scene.free()
	print("--- Flow Test PASSED ---")
	quit(0)

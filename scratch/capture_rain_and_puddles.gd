@tool
extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/10e66e4e-536c-44ea-9bb0-942b328f3b1c/"

	# 1. Capture Level 3-1 around player position showing puddles on grass and rain
	main_scene.current_level_idx = 6
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	if main_scene.player:
		main_scene.player.global_position = Vector2(500.0, 280.0)
	if main_scene.camera:
		main_scene.camera.global_position = Vector2(500.0, 180.0)
	
	# Process weather so particles and puddles settle
	for _i in range(30):
		main_scene._process(0.016)
	
	await create_timer(0.5).timeout

	var img = root.get_texture().get_image()
	img.save_png("scratch/stage_3_new_puddle_verified.png")
	img.save_png(artifact_dir + "stage_3_new_puddle_verified.png")
	print("Saved: stage_3_new_puddle_verified.png")

	main_scene.free()
	quit(0)

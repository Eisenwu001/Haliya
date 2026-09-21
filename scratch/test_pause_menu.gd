@tool
extends SceneTree

func _init() -> void:
	print("--- Testing In-Game Pause Menu ---")
	var main_res = load("res://scenes/main.tscn")
	var main_scene = main_res.instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"

	# Trigger pause menu
	main_scene.toggle_pause()
	await create_timer(0.2).timeout

	var img = root.get_texture().get_image()
	if img:
		img.save_png(artifact_dir + "ingame_pause_menu.png")
		print("Saved ingame_pause_menu.png")

	main_scene.toggle_pause()
	main_scene.free()
	print("--- In-Game Pause Menu Verified ---")
	quit(0)

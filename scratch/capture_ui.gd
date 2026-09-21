@tool
extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"

	# 1. Level 2-1: Emerald Terraces
	main_scene.current_level_idx = 3
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	main_scene.trigger_area_discovery()
	await create_timer(0.4).timeout

	var img1 = root.get_texture().get_image()
	img1.save_png(artifact_dir + "ui_emerald_terraces.png")
	print("Saved ui_emerald_terraces.png")

	# 2. Level 3-1: Drenched Foothills
	main_scene.current_level_idx = 6
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	main_scene.trigger_area_discovery()
	await create_timer(0.4).timeout

	var img2 = root.get_texture().get_image()
	img2.save_png(artifact_dir + "ui_drenched_foothills.png")
	print("Saved ui_drenched_foothills.png")

	main_scene.free()
	quit(0)

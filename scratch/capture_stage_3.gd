@tool
extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"

	# 1. Capture Level 3-1 (Drenched Foothills) with 3-layer rain and mist
	main_scene.current_level_idx = 6
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	if main_scene.player:
		main_scene.player.global_position = Vector2(480.0, 280.0)
	if main_scene.camera:
		main_scene.camera.global_position = Vector2(480.0, 180.0)
	await create_timer(0.4).timeout

	var img1 = root.get_texture().get_image()
	img1.save_png("scratch/stage_3_rainy_forest_lvl_3_1.png")
	img1.save_png(artifact_dir + "stage_3_rainy_forest_lvl_3_1.png")
	print("Saved: stage_3_rainy_forest_lvl_3_1.png")

	# 2. Capture Lightning Strike with branches and PointLight2D
	var hazard_script = load("res://scripts/lightning_hazard.gd")
	var hazard = hazard_script.new() as LightningHazard
	hazard.target_position = Vector2(450.0, 288.0)
	main_scene.lightning_container.add_child(hazard)
	hazard.trigger_strike()
	main_scene._on_lightning_hazard_struck(hazard.target_position, 25)
	await create_timer(0.08).timeout

	var img2 = root.get_texture().get_image()
	img2.save_png("scratch/stage_3_rainy_forest_lightning.png")
	img2.save_png(artifact_dir + "stage_3_rainy_forest_lightning.png")
	print("Saved: stage_3_rainy_forest_lightning.png")

	# 3. Capture Level 3-5 (Eye of the Tempest)
	main_scene.current_level_idx = 10
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	if main_scene.player:
		main_scene.player.global_position = Vector2(600.0, 280.0)
	if main_scene.camera:
		main_scene.camera.global_position = Vector2(600.0, 180.0)
	await create_timer(0.4).timeout

	var img3 = root.get_texture().get_image()
	img3.save_png("scratch/stage_3_rainy_forest_lvl_3_5.png")
	img3.save_png(artifact_dir + "stage_3_rainy_forest_lvl_3_5.png")
	print("Saved: stage_3_rainy_forest_lvl_3_5.png")

	main_scene.free()
	quit(0)

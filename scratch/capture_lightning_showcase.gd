@tool
extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/"

	# Load Level 3-1 (Drenched Foothills)
	main_scene.current_level_idx = 6
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	if main_scene.player:
		main_scene.player.global_position = Vector2(360.0, 280.0)
	if main_scene.camera:
		main_scene.camera.global_position = Vector2(460.0, 190.0)
	await create_timer(0.4).timeout

	var hazard_script = load("res://scripts/lightning_hazard.gd")
	var hazard = hazard_script.new() as LightningHazard
	hazard.target_position = Vector2(480.0, 288.0)
	main_scene.lightning_container.add_child(hazard)

	# 1. Trigger Strike (Peak bolt and 2D ground detonation burst)
	hazard.trigger_strike()
	await create_timer(0.10).timeout

	var img1 = root.get_texture().get_image()
	img1.save_png("scratch/new_lightning_strike_impact.png")
	img1.save_png(artifact_dir + "new_lightning_strike_impact.png")
	print("Saved: new_lightning_strike_impact.png")

	# 2. Capture Active Horizontal Surface Crackle on Floor Tiles
	await create_timer(0.35).timeout
	var img2 = root.get_texture().get_image()
	img2.save_png("scratch/new_lightning_ground_crackle.png")
	img2.save_png(artifact_dir + "new_lightning_ground_crackle.png")
	print("Saved: new_lightning_ground_crackle.png")

	# 3. Capture Cooling Charred Decal & Embers
	await create_timer(0.70).timeout
	var img3 = root.get_texture().get_image()
	img3.save_png("scratch/new_lightning_ground_embers.png")
	img3.save_png(artifact_dir + "new_lightning_ground_embers.png")
	print("Saved: new_lightning_ground_embers.png")

	# 4. Capture Fading Dissipation
	await create_timer(1.20).timeout
	var img4 = root.get_texture().get_image()
	img4.save_png("scratch/new_lightning_ground_dissipated.png")
	img4.save_png(artifact_dir + "new_lightning_ground_dissipated.png")
	print("Saved: new_lightning_ground_dissipated.png")

	main_scene.free()
	quit(0)

@tool
extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.3).timeout

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

	# 1. Capture Seamless Warning Hazard Telegraph (Sky Pillar + Ground Plasma Crawlers)
	hazard.telegraph_timer = 0.5
	hazard._process(0.01)
	await create_timer(0.15).timeout
	var img_warn = root.get_texture().get_image()
	img_warn.save_png("scratch/seamless_warning_ingame.png")
	print("Saved: seamless_warning_ingame.png")

	# 2. Trigger Strike Impact
	hazard.trigger_strike()
	await create_timer(0.08).timeout
	var img_strike = root.get_texture().get_image()
	img_strike.save_png("scratch/seamless_strike_ingame.png")
	print("Saved: seamless_strike_ingame.png")

	# 3. Fast-forward to Cooled Permanent Carbon Crater Leftover (Frame 4)
	hazard.strike_timer = 0.0
	hazard.cleanup_timer = 0.0
	hazard._process(0.02)
	await create_timer(0.20).timeout
	var img_crater = root.get_texture().get_image()
	img_crater.save_png("scratch/seamless_crater_ingame.png")
	print("Saved: seamless_crater_ingame.png")

	main_scene.free()
	quit(0)

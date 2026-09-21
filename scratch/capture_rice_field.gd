@tool
extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout
	
	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"
	
	for lvl in [3, 4, 5]:
		main_scene.current_level_idx = lvl
		main_scene.load_current_level()
		main_scene.spawn_level_enemies()
		if main_scene.player:
			main_scene.player.global_position = Vector2(400.0, 300.0)
		if main_scene.camera:
			main_scene.camera.global_position = Vector2(400.0, 180.0)
		await create_timer(0.3).timeout
		
		var img = root.get_texture().get_image()
		var filename = "rice_field_lvl_%d.png" % (lvl - 1)
		img.save_png("scratch/" + filename)
		img.save_png(artifact_dir + filename)
		print("Saved: ", filename)
		
	main_scene.free()
	quit(0)

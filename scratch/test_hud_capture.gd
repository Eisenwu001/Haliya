extends SceneTree

func _init():
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait a couple frames so HUD is laid out and rendered
	await create_timer(0.5).timeout
	
	var img = root.get_texture().get_image()
	img.save_png("res://scratch/hud_screenshot.png")
	print("Captured HUD screenshot successfully!")
	quit()

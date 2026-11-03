extends SceneTree

func _init() -> void:
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	await create_timer(0.1).timeout

	# Advance splash past stage 1 & 2
	menu._skip_splash()
	await create_timer(0.4).timeout
	menu._skip_splash()
	await create_timer(0.8).timeout

	root.get_texture().get_image().save_png("res://scratch/snap_menu_loading_active.png")
	print("Captured snap_menu_loading_active.png!")
	menu.free()
	quit(0)

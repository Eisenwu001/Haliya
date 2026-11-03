extends SceneTree

func _init() -> void:
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	await create_timer(0.3).timeout

	# Trigger Step 3 (loading sequence)
	if menu.has_method("_advance_to_step"):
		menu._advance_to_step(3)
	await create_timer(0.6).timeout

	root.get_texture().get_image().save_png("res://scratch/snap_menu_loading.png")
	print("Captured snap_menu_loading.png!")
	menu.free()
	quit(0)

@tool
extends SceneTree

func _init() -> void:
	var menu_res = load("res://scenes/main_menu.tscn")
	var menu = menu_res.instantiate()
	root.add_child(menu)
	await create_timer(0.3).timeout

	# Let's test single space "H A L I Y A" at font size 52
	menu.title_label.text = "H A L I Y A"
	menu.title_label.add_theme_font_size_override("font_size", 54)
	menu.subtitle_label.text = "—  Mask of Sorrows  —"
	menu.subtitle_label.add_theme_font_size_override("font_size", 15)
	await create_timer(0.2).timeout

	var img = root.get_texture().get_image()
	img.save_png("C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/menu_title_refined.png")
	print("Saved menu_title_refined.png")

	menu.free()
	quit(0)

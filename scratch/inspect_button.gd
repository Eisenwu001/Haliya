extends SceneTree

func _init() -> void:
	var th = load("res://ui/theme/haliya_theme.tres") as Theme
	var btn = Button.new()
	btn.theme = th
	btn.theme_type_variation = &"MenuButtonPrimary"
	btn.text = "CONTINUE"
	root.add_child(btn)

	var font = btn.get_theme_font(&"font", &"MenuButtonPrimary")
	var font_size = btn.get_theme_font_size(&"font_size", &"MenuButtonPrimary")
	var ascent = font.get_ascent(font_size)
	var descent = font.get_descent(font_size)
	var height = font.get_height(font_size)
	print("Ascent: ", ascent, " Descent: ", descent, " Height: ", height)

	# Get string size
	var str_size = font.get_string_size("CONTINUE", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	print("String size: ", str_size)

	# Check button minimum size
	print("Button min size: ", btn.get_combined_minimum_size())

	# Now check HaliyaMenuButton instance
	var item_scene = load("res://ui/components/haliya_menu_button.tscn")
	var item = item_scene.instantiate()
	item.setup("CONTINUE", 0, "Act 1 · Whispering Canopy")
	root.add_child(item)

	await process_frame
	await process_frame

	print("Item size: ", item.size)
	print("Item row_container size: ", item.row_container.size, " pos: ", item.row_container.position)
	print("Item button size: ", item.button.size, " pos: ", item.button.position)
	print("Item crescent size: ", item.crescent_rect.size, " pos: ", item.crescent_rect.position)
	print("Item caption_margin size: ", item.caption_margin.size, " pos: ", item.caption_margin.position)

	item.grab_item_focus()
	await process_frame
	print("After focus:")
	print("Item button pos: ", item.button.position)
	print("Item crescent pos: ", item.crescent_rect.position)

	quit(0)

extends SceneTree

func _init() -> void:
	var th = load("res://ui/theme/haliya_theme.tres") as Theme
	var btn = Button.new()
	btn.theme = th
	btn.theme_type_variation = &"MenuButtonPrimary"
	btn.text = "CONTINUE"
	root.add_child(btn)

	await process_frame
	await process_frame

	var font = btn.get_theme_font(&"font", &"MenuButtonPrimary")
	var font_size = btn.get_theme_font_size(&"font_size", &"MenuButtonPrimary")
	var ascent = font.get_ascent(font_size)
	var descent = font.get_descent(font_size)
	var height = font.get_height(font_size)

	print("Ascent: ", ascent, " Descent: ", descent, " Height: ", height)
	# Check Silkscreen font details
	# Let's inspect glyph 'C' in font
	var glyph_c = font.get_char_size("C".unicode_at(0), font_size)
	print("Char size 'C': ", glyph_c)

	# Check StyleBox
	var sb = btn.get_theme_stylebox(&"normal", &"MenuButtonPrimary")
	print("StyleBox normal: ", sb, " margin_left: ", sb.content_margin_left if sb else 0)

	quit(0)

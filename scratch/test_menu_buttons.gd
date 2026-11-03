extends SceneTree

func _init() -> void:
	var canvas = CanvasLayer.new()
	root.add_child(canvas)

	var bg = ColorRect.new()
	bg.size = Vector2(640, 360)
	bg.color = Color(0.05, 0.07, 0.10, 1.0)
	canvas.add_child(bg)

	var font = load("res://alagard.ttf")

	# Test various prefix characters in Alagard
	var test_chars = ["•", "✦", "►", "▸", ">", "»", "♦"]
	var y = 20
	for ch in test_chars:
		var lbl = Label.new()
		lbl.position = Vector2(400, y)
		lbl.text = "prefix: " + ch + " TEST OPTION"
		lbl.add_theme_font_override("font", font)
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
		canvas.add_child(lbl)
		y += 24

	# Also simulate the new menu VBox
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(52, 124)
	vbox.size = Vector2(210, 180)
	vbox.add_theme_constant_override("separation", 3)
	canvas.add_child(vbox)

	var labels = ["CONTINUE", "BEGIN JOURNEY", "STAGE SELECT", "LORE CODEX", "SETTINGS", "HOW TO PLAY", "QUIT"]
	for i in range(labels.size()):
		var btn = Button.new()
		var txt = labels[i]
		var is_hovered = (i == 0) # simulate first button hovered
		if is_hovered:
			btn.text = "  •  " + txt
		else:
			btn.text = "     " + txt
		btn.custom_minimum_size = Vector2(196, 22)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 12)

		var sb = StyleBoxFlat.new()
		if is_hovered:
			sb.bg_color = Color(0.12, 0.16, 0.24, 0.90)
			sb.border_color = Color(0.96, 0.84, 0.42, 1.0)
			sb.border_width_left = 3
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.content_margin_left = 10
			sb.content_margin_right = 8
			sb.content_margin_top = 2
			sb.content_margin_bottom = 2
			btn.add_theme_color_override("font_color", Color(1.0, 0.94, 0.65, 1.0))
		else:
			sb.bg_color = Color(0.04, 0.06, 0.10, 0.55)
			sb.border_color = Color(0.42, 0.38, 0.30, 0.60)
			sb.border_width_left = 2
			sb.content_margin_left = 10
			sb.content_margin_right = 8
			sb.content_margin_top = 2
			sb.content_margin_bottom = 2
			btn.add_theme_color_override("font_color", Color(0.85, 0.82, 0.76, 0.95))

		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		btn.add_theme_constant_override("shadow_offset_x", 1)
		btn.add_theme_constant_override("shadow_offset_y", 1)
		vbox.add_child(btn)

	# Add Version label at bottom
	var ver = Label.new()
	ver.position = Vector2(52, 338)
	ver.text = "v1.0.0 • Dark Fantasy Edition"
	ver.add_theme_font_override("font", font)
	ver.add_theme_font_size_override("font_size", 11)
	ver.add_theme_color_override("font_color", Color(0.55, 0.50, 0.42, 0.70))
	canvas.add_child(ver)

	await process_frame
	await process_frame

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("scratch/test_menu_preview.png")
	print("SAVED scratch/test_menu_preview.png")
	quit()

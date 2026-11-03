extends SceneTree

func _init() -> void:
	var canvas = CanvasLayer.new()
	root.add_child(canvas)

	var bg = ColorRect.new()
	bg.size = Vector2(640, 360)
	bg.color = Color(0.02, 0.03, 0.05, 1.0)
	canvas.add_child(bg)

	var font = load("res://alagard.ttf")

	# Test 4 different vertical offsets for loading_pct_label
	for idx in range(4):
		var y_base = 50 + idx * 70
		var cont = Control.new()
		cont.position = Vector2(150, y_base)
		canvas.add_child(cont)

		var bar_frame = ColorRect.new()
		bar_frame.size = Vector2(340, 16)
		bar_frame.color = Color(0.04, 0.03, 0.06, 0.95)
		cont.add_child(bar_frame)

		var border = ReferenceRect.new()
		border.size = Vector2(340, 16)
		border.border_color = Color(0.72, 0.60, 0.35, 1.0)
		border.border_width = 1.0
		border.editor_only = false
		cont.add_child(border)

		var channel = ColorRect.new()
		channel.position = Vector2(2, 2)
		channel.size = Vector2(336, 12)
		channel.color = Color(0.08, 0.05, 0.10, 0.85)
		cont.add_child(channel)

		var fill = ColorRect.new()
		fill.position = Vector2(2, 2)
		fill.size = Vector2(160, 12)
		fill.color = Color(0.35, 0.82, 1.0, 1.0)
		cont.add_child(fill)

		var y_offset = -3 + idx # -3, -2, -1, 0
		var lbl = Label.new()
		lbl.text = "50%"
		lbl.position = Vector2(0, y_offset)
		lbl.size = Vector2(340, 16)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", font)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		cont.add_child(lbl)

		var tag = Label.new()
		tag.text = "Offset y = %d" % y_offset
		tag.position = Vector2(0, -18)
		tag.add_theme_font_override("font", font)
		tag.add_theme_font_size_override("font_size", 11)
		cont.add_child(tag)

	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/test_loading_offsets.png")
	print("Saved test_loading_offsets.png!")
	quit(0)

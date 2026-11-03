extends SceneTree

func _init() -> void:
	var canvas = CanvasLayer.new()
	root.add_child(canvas)

	var bg = ColorRect.new()
	bg.size = Vector2(640, 360)
	bg.color = Color(0.04, 0.05, 0.07, 1.0)
	canvas.add_child(bg)

	var font = load("res://alagard.ttf")

	# 1. Test Stage Progress Tracker with newly generated assets
	var progress_root = Control.new()
	progress_root.position = Vector2(206, 30) # center 640 - 228 / 2 = 206
	canvas.add_child(progress_root)

	var track_frame = TextureRect.new()
	track_frame.texture = load("res://assets/ui/progress_track_frame.png")
	track_frame.size = Vector2(228, 14)
	progress_root.add_child(track_frame)

	var track_fill = TextureRect.new()
	track_fill.texture = load("res://assets/ui/progress_track_fill.png")
	track_fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	track_fill.stretch_mode = TextureRect.STRETCH_TILE
	track_fill.position = Vector2(6, 4)
	track_fill.size = Vector2(55, 6) # 25% fill
	progress_root.add_child(track_fill)

	var shrine_pin = TextureRect.new()
	shrine_pin.texture = load("res://assets/ui/progress_pin_shrine.png")
	shrine_pin.position = Vector2(107, -10)
	shrine_pin.size = Vector2(14, 16)
	progress_root.add_child(shrine_pin)

	var goal_pin = TextureRect.new()
	goal_pin.texture = load("res://assets/ui/progress_pin_boss.png")
	goal_pin.position = Vector2(216, -11)
	goal_pin.size = Vector2(18, 18)
	progress_root.add_child(goal_pin)

	var player_pin = TextureRect.new()
	player_pin.texture = load("res://assets/ui/progress_pin_haliya.png")
	player_pin.position = Vector2(52, -12) # At 25%
	player_pin.size = Vector2(16, 18)
	progress_root.add_child(player_pin)

	# 2. Test Main Menu Loading Bar with newly generated assets
	var load_cont = Control.new()
	load_cont.position = Vector2(146, 90) # center 640 - 348 / 2 = 146
	canvas.add_child(load_cont)

	var status_lbl = Label.new()
	status_lbl.text = "AWAKENING THE SEVEN MOONS..."
	status_lbl.size = Vector2(348, 16)
	status_lbl.position = Vector2(0, -2)
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_override("font", font)
	status_lbl.add_theme_font_size_override("font_size", 10)
	status_lbl.add_theme_color_override("font_color", Color(0.92, 0.85, 0.72))
	load_cont.add_child(status_lbl)

	var load_frame = TextureRect.new()
	load_frame.texture = load("res://assets/ui/loading_bar_frame.png")
	load_frame.position = Vector2(0, 16)
	load_frame.size = Vector2(348, 20)
	load_cont.add_child(load_frame)

	var load_fill = TextureRect.new()
	load_fill.texture = load("res://assets/ui/loading_bar_fill.png")
	load_fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	load_fill.stretch_mode = TextureRect.STRETCH_TILE
	load_fill.position = Vector2(6, 20)
	load_fill.size = Vector2(336 * 0.65, 12) # 65%
	load_cont.add_child(load_fill)

	var pct_lbl = Label.new()
	pct_lbl.text = "65%"
	pct_lbl.size = Vector2(348, 20)
	pct_lbl.position = Vector2(0, 15)
	pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pct_lbl.add_theme_font_override("font", font)
	pct_lbl.add_theme_font_size_override("font_size", 10)
	pct_lbl.add_theme_color_override("font_color", Color.WHITE)
	pct_lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	pct_lbl.add_theme_constant_override("shadow_offset_x", 1)
	pct_lbl.add_theme_constant_override("shadow_offset_y", 1)
	load_cont.add_child(pct_lbl)

	# 3. Test Main Menu Buttons (Normal vs Hovered - No Diamond Icon!)
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(52, 170)
	vbox.add_theme_constant_override("separation", 3)
	canvas.add_child(vbox)

	var btns = ["CONTINUE", "BEGIN JOURNEY", "STAGE SELECT", "QUIT"]
	for i in range(btns.size()):
		var b = Button.new()
		b.text = "   " + btns[i]
		b.custom_minimum_size = Vector2(196, 24)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_override("font", font)
		b.add_theme_font_size_override("font_size", 12)

		var sb = StyleBoxTexture.new()
		if i == 0: # First button hovered
			sb.texture = load("res://assets/ui/menu_btn_hover.png")
			b.add_theme_color_override("font_color", Color(1.0, 0.94, 0.65))
		else:
			sb.texture = load("res://assets/ui/menu_btn_normal.png")
			b.add_theme_color_override("font_color", Color(0.85, 0.82, 0.76))

		sb.texture_margin_left = 6
		sb.texture_margin_right = 6
		sb.texture_margin_top = 4
		sb.texture_margin_bottom = 4
		sb.content_margin_left = 12
		sb.content_margin_right = 8
		sb.content_margin_top = 2
		sb.content_margin_bottom = 2

		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
		b.add_theme_constant_override("shadow_offset_x", 1)
		b.add_theme_constant_override("shadow_offset_y", 1)
		vbox.add_child(b)

	await process_frame
	await process_frame

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("scratch/test_new_ui_assets.png")
	print("Saved scratch/test_new_ui_assets.png")
	quit()

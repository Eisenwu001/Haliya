extends SceneTree

func _init() -> void:
	# Ensure mock save exists in slot 1
	var save_path = SaveManager.get_save_path(1)
	var mock_save = {
		"version": 1,
		"level_idx": 0,
		"highest_level_idx": 1,
		"stage_title": "Whispering Canopy (Level 1-1)",
		"date_string": "2026-11-02 14:00",
		"play_time_seconds": 125.0,
		"current_hp": 5,
		"current_armor": 3,
		"upgrades_count": 2
	}
	var f = FileAccess.open(save_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(mock_save))
	f.close()

	_run_test()

func _run_test() -> void:
	var canvas = CanvasLayer.new()
	root.add_child(canvas)

	var font = load("res://alagard.ttf")

	# 1. Background
	var bg = ColorRect.new()
	bg.size = Vector2(640, 360)
	bg.color = Color(0.015, 0.02, 0.03, 1.0)
	canvas.add_child(bg)

	var bg_root = Node2D.new()
	canvas.add_child(bg_root)

	# Sky
	var sky_tex = load("res://assets/platform_assets/background_layers/normal_bg/background_layer_5.png")
	if sky_tex:
		var sky_spr = Sprite2D.new()
		sky_spr.texture = sky_tex
		sky_spr.centered = false
		sky_spr.scale = Vector2(1.5, 1.5)
		sky_spr.modulate = Color(0.60, 0.65, 0.80, 1.0)
		bg_root.add_child(sky_spr)

	# Astrolabe (behind trees, rotating)
	var astrolabe = Sprite2D.new()
	astrolabe.texture = load("res://assets/ui/celestial_astrolabe.png")
	astrolabe.position = Vector2(500, 75)
	astrolabe.scale = Vector2(1.15, 1.15)
	astrolabe.modulate = Color(1.0, 0.95, 0.85, 0.50)
	bg_root.add_child(astrolabe)

	# Moon & Aura
	var moon_cont = Node2D.new()
	moon_cont.position = Vector2(500, 58)
	bg_root.add_child(moon_cont)

	var moon_spr = Sprite2D.new()
	moon_spr.texture = load("res://assets/ui/crescent_moon.png")
	moon_cont.add_child(moon_spr)

	# God Rays slanting across center
	var god_ray = Sprite2D.new()
	god_ray.texture = load("res://assets/ui/menu_god_ray.png")
	god_ray.position = Vector2(400, 175)
	god_ray.scale = Vector2(1.8, 1.3)
	god_ray.rotation = deg_to_rad(-22.0)
	god_ray.modulate = Color(0.85, 0.92, 1.0, 0.22)
	bg_root.add_child(god_ray)

	# Forest layers
	var bicol_layers = [
		"res://assets/bicol_bg/Bicol_Forest_Layer4.png",
		"res://assets/bicol_bg/Bicol_Forest_Layer3.png",
		"res://assets/bicol_bg/Bicol_Forest_Layer2.png",
		"res://assets/bicol_bg/Bicol_Forest_Layer1.png"
	]
	for idx in range(bicol_layers.size()):
		var tex = load(bicol_layers[idx])
		if tex:
			var spr = Sprite2D.new()
			spr.texture = tex
			spr.centered = false
			spr.scale = Vector2(0.5, 0.5)
			spr.position = Vector2(0, 360 - 360)
			spr.modulate = Color(0.38 + idx*0.06, 0.42 + idx*0.06, 0.55 + idx*0.06)
			bg_root.add_child(spr)

	# Totem on right
	var totem_tex = load("res://assets/bahay_kubo/totem_haliya.png")
	if totem_tex:
		var totem_spr = Sprite2D.new()
		totem_spr.texture = totem_tex
		var totem_scale = 252.0 / totem_tex.get_height()
		totem_spr.scale = Vector2(totem_scale, totem_scale)
		totem_spr.position = Vector2(531, 372 - (252.0 * 0.5))
		bg_root.add_child(totem_spr)

	# Ambient Forest Fireflies
	var fireflies = CPUParticles2D.new()
	fireflies.position = Vector2(320, 260)
	fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fireflies.emission_rect_extents = Vector2(280.0, 90.0)
	fireflies.amount = 26
	fireflies.lifetime = 5.0
	fireflies.preprocess = 2.5
	fireflies.direction = Vector2(0.2, -1.0)
	fireflies.gravity = Vector2(0, -4.0)
	fireflies.initial_velocity_min = 4.0
	fireflies.initial_velocity_max = 12.0
	fireflies.color = Color(1.0, 0.88, 0.48, 0.70)
	bg_root.add_child(fireflies)

	# Left Column Plaque
	var col_plaque = TextureRect.new()
	col_plaque.texture = load("res://assets/ui/menu_column_plaque.png")
	col_plaque.position = Vector2(38, 48)
	col_plaque.size = Vector2(224, 265)
	canvas.add_child(col_plaque)

	# Title & Subtitle
	var title_lbl = Label.new()
	title_lbl.text = "HALIYA"
	title_lbl.position = Vector2(52, 54)
	title_lbl.add_theme_font_override("font", font)
	title_lbl.add_theme_font_size_override("font_size", 34)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.98, 0.94))
	canvas.add_child(title_lbl)

	var sub_lbl = Label.new()
	sub_lbl.text = "Mask of Sorrows"
	sub_lbl.position = Vector2(52, 94)
	sub_lbl.add_theme_font_override("font", font)
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", Color(0.92, 0.82, 0.58))
	canvas.add_child(sub_lbl)

	# Menu Buttons VBox
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(52, 124)
	vbox.add_theme_constant_override("separation", 3)
	canvas.add_child(vbox)

	var btn_labels = ["CONTINUE", "BEGIN JOURNEY", "STAGE SELECT", "LORE CODEX", "SETTINGS", "HOW TO PLAY", "QUIT"]
	for i in range(btn_labels.size()):
		var b = Button.new()
		b.text = "   " + btn_labels[i]
		b.custom_minimum_size = Vector2(188, 22)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_override("font", font)
		b.add_theme_font_size_override("font_size", 12)

		var sb = StyleBoxTexture.new()
		if i == 0:
			sb.texture = load("res://assets/ui/menu_btn_hover.png")
			b.add_theme_color_override("font_color", Color(1.0, 0.94, 0.65))
			b.custom_minimum_size = Vector2(198, 22)
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

	# Dynamic Chronicle Preview Panel in Center-Right (X=274..494, Y=124..304)
	var preview_root = Control.new()
	preview_root.position = Vector2(274, 124)
	preview_root.size = Vector2(220, 180)
	canvas.add_child(preview_root)

	var panel_tex = TextureRect.new()
	panel_tex.texture = load("res://assets/ui/menu_preview_panel.png")
	panel_tex.size = Vector2(220, 180)
	preview_root.add_child(panel_tex)

	# Header above top divider (Y=28)
	var header_lbl = Label.new()
	header_lbl.position = Vector2(8, 7)
	header_lbl.size = Vector2(204, 18)
	header_lbl.text = "ACTIVE CHRONICLE"
	header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_lbl.add_theme_font_override("font", font)
	header_lbl.add_theme_font_size_override("font_size", 11)
	header_lbl.add_theme_color_override("font_color", Color(0.98, 0.90, 0.65))
	preview_root.add_child(header_lbl)

	# Body content strictly between top divider (Y=28) and bottom divider (Y=152)
	var p_vbox = VBoxContainer.new()
	p_vbox.position = Vector2(10, 34)
	p_vbox.size = Vector2(200, 114)
	p_vbox.add_theme_constant_override("separation", 5)
	preview_root.add_child(p_vbox)

	var badge_lbl = Label.new()
	badge_lbl.text = "SLOT 1: BATHALA'S PATH"
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_lbl.add_theme_font_override("font", font)
	badge_lbl.add_theme_font_size_override("font_size", 10)
	badge_lbl.add_theme_color_override("font_color", Color(0.45, 0.82, 1.0))
	p_vbox.add_child(badge_lbl)

	var stage_lbl = Label.new()
	stage_lbl.text = "Whispering Canopy (Level 1-1)"
	stage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_lbl.add_theme_font_override("font", font)
	stage_lbl.add_theme_font_size_override("font_size", 11)
	stage_lbl.add_theme_color_override("font_color", Color(0.95, 0.88, 0.72))
	p_vbox.add_child(stage_lbl)

	var stats_lbl = Label.new()
	stats_lbl.text = "Time: 02:05  •  HP: 5 / 5\nArmor: 3  •  Blessings: 2"
	stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_lbl.add_theme_font_override("font", font)
	stats_lbl.add_theme_font_size_override("font_size", 10)
	stats_lbl.add_theme_color_override("font_color", Color(0.72, 0.78, 0.88))
	p_vbox.add_child(stats_lbl)

	var lore_lbl = Label.new()
	lore_lbl.text = "\"The moonlight awaits your return, masked warrior.\""
	lore_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lore_lbl.add_theme_font_override("font", font)
	lore_lbl.add_theme_font_size_override("font_size", 9)
	lore_lbl.add_theme_color_override("font_color", Color(0.65, 0.68, 0.74))
	p_vbox.add_child(lore_lbl)

	# Footer prompt below bottom divider (Y=152)
	var prompt_lbl = Label.new()
	prompt_lbl.position = Vector2(8, 156)
	prompt_lbl.size = Vector2(204, 16)
	prompt_lbl.text = "[PRESS ENTER TO RESUME]"
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_override("font", font)
	prompt_lbl.add_theme_font_size_override("font_size", 9)
	prompt_lbl.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
	preview_root.add_child(prompt_lbl)

	# Version Label
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
	img.save_png("scratch/test_full_suite_preview.png")
	print("Saved scratch/test_full_suite_preview.png")
	quit()

extends SceneTree

func _init() -> void:
	print("=== RUNNING HUD SCALE & METRICS VERIFICATION ===")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(15):
		await process_frame

	main._on_player_hp_changed(5, 5)
	main._on_player_armor_changed(3, 3)
	main._on_player_stamina_changed(100.0, 100.0)

	for i in range(5):
		await process_frame

	print("\n--- MEASURED NODE RECTS & METRICS ---")
	var root_pos = main.hud_cluster_root.position
	print("1. HUD Status Cluster Root Position: ", root_pos, " (Margin: ", root_pos.x, "px left, ", root_pos.y, "px top)")

	# HP Row
	var hp_cont = main.hp_pips_container
	var hp_sep = hp_cont.get_theme_constant("separation")
	print("\n2. HP Row (HBoxContainer):")
	print("   Separation: ", hp_sep, "px")
	print("   Child count: ", hp_cont.get_child_count())
	var pip0 = hp_cont.get_child(0) as TextureRect
	var pip_tex = pip0.texture
	print("   Pip texture: ", pip_tex.resource_path, " size: ", pip_tex.get_size())
	print("   Pip 0 size: ", pip0.size, " custom_min_size: ", pip0.custom_minimum_size)
	var hp_total_w = 0.0
	var hp_max_h = 0.0
	for i in range(hp_cont.get_child_count()):
		var p = hp_cont.get_child(i) as Control
		print("   - Pip ", i, ": pos=", p.position, " size=", p.size, " global_pos=", p.global_position)
		hp_total_w = max(hp_total_w, p.position.x + p.size.x)
		hp_max_h = max(hp_max_h, p.size.y)
	print("   Total HP Row Width: ", hp_total_w, "px, Height: ", hp_max_h, "px")

	# Shield Row
	var sh_cont = main.shield_wards_container
	var sh_sep = sh_cont.get_theme_constant("separation")
	print("\n3. Shield Row (HBoxContainer):")
	print("   Offset Y: ", sh_cont.position.y, "px")
	print("   Separation: ", sh_sep, "px")
	print("   Child count: ", sh_cont.get_child_count())
	var ward0 = sh_cont.get_child(0) as TextureRect
	var ward_tex = ward0.texture
	print("   Ward texture: ", ward_tex.resource_path, " size: ", ward_tex.get_size())
	print("   Ward 0 size: ", ward0.size, " custom_min_size: ", ward0.custom_minimum_size)
	var sh_total_w = 0.0
	var sh_max_h = 0.0
	for i in range(sh_cont.get_child_count()):
		var w = sh_cont.get_child(i) as Control
		print("   - Ward ", i, ": pos=", w.position, " size=", w.size, " global_pos=", w.global_position)
		sh_total_w = max(sh_total_w, w.position.x + w.size.x)
		sh_max_h = max(sh_max_h, w.size.y)
	print("   Total Shield Row Width: ", sh_total_w, "px, Height: ", sh_max_h, "px")

	# Gap between HP row and Shield row
	var gap_hp_shield = sh_cont.position.y - hp_max_h
	print("   Gap below HP row (shield_y - hp_height): ", gap_hp_shield, "px")

	# Stamina Bar
	var sta_root = main.stamina_bar_root
	var sta_track = main.stamina_track_rect
	var sta_fill = main.stamina_fill_clip
	var sta_frame = main.stamina_frame_tex
	print("\n4. Stamina Bar:")
	print("   Offset Y: ", sta_root.position.y, "px")
	print("   Stamina Bar Root Size: ", sta_root.size, " custom_min: ", sta_root.custom_minimum_size)
	print("   Stamina Track Rect Pos: ", sta_track.position, " size: ", sta_track.size, " color: ", sta_track.color.to_html())
	print("   Stamina Fill Clip Pos: ", sta_fill.position, " size: ", sta_fill.size)
	print("   Stamina Frame Texture: ", sta_frame.texture.resource_path, " size: ", sta_frame.texture.get_size())

	# Gap between Shield row and Stamina bar
	var shield_bottom_y = sh_cont.position.y + sh_max_h
	var gap_shield_sta = sta_root.position.y - shield_bottom_y
	print("   Gap below Shield row (sta_y - shield_bottom_y): ", gap_shield_sta, "px")

	# Overall Cluster Bounds
	var cluster_w = max(hp_total_w, max(sh_total_w, sta_root.size.x))
	var cluster_h = sta_root.position.y + sta_root.size.y
	var screen_w = 640.0
	var screen_h = 360.0
	var pct_w = (cluster_w / screen_w) * 100.0
	var pct_h = (cluster_h / screen_h) * 100.0

	print("\n=======================================================")
	print("=== CLUSTER PERCENTAGES & BUDGET COMPLIANCE ===")
	print("=======================================================")
	print("Base Resolution: ", screen_w, " x ", screen_h)
	print("Cluster Total Dimensions: ", cluster_w, "px wide x ", cluster_h, "px tall")
	print("Cluster Width Percentage: ", pct_w, "% (Budget: <= 14.0% = ", screen_w * 0.14, "px) -> ", "PASS" if pct_w <= 14.0 else "FAIL")
	print("Cluster Height Percentage: ", pct_h, "% (Budget: <= 13.0% = ", screen_h * 0.13, "px) -> ", "PASS" if pct_h <= 13.0 else "FAIL")
	print("=======================================================\n")

	# Capture full game screenshot and isolated HUD capture
	main.jump_to_level(3) # Rice field (bright daytime)
	for i in range(25):
		await process_frame
	main.update_hud_contrast()
	main._on_player_hp_changed(5, 5)
	main._on_player_armor_changed(3, 3)
	main._on_player_stamina_changed(100.0, 100.0)
	for i in range(5):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://scratch/hud_verification_fullscreen_2560.png")
		print("Saved fullscreen screenshot to scratch/hud_verification_fullscreen_2560.png")

	main.free()
	print("Verification complete.")
	quit(0)

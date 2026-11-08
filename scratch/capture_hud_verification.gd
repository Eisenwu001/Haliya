extends SceneTree

func _init() -> void:
	print("--- Running HUD Status Overhaul Verification & Captures ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(25):
		await process_frame

	if is_instance_valid(main.ui_layer):
		main.ui_layer.layer = 10

	# ── 1. BRIGHT BACKGROUND (Rice Field 2-1, index 3) ──
	print("Switching to Bright Background (Rice Field 2-1)...")
	main.jump_to_level(3)
	for i in range(35):
		await process_frame

	# Ensure contrast background updates
	main.update_hud_contrast()

	# Ensure player does not automatically regen stamina during HUD test snapshots
	if is_instance_valid(main.player):
		main.player.set_physics_process(false)

	# State A: 100% Stamina, Full HP (5/5), 3 Shield
	print("Capturing Bright 100%...")
	main._on_player_hp_changed(5, 5)
	main._on_player_armor_changed(3, 3)
	main._on_player_stamina_changed(100.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_bright_100.png")

	# State B: 50% Stamina, Mid HP (3/5), 2 Shield
	print("Capturing Bright 50%...")
	main._on_player_hp_changed(3, 5)
	main._on_player_armor_changed(2, 3)
	main._on_player_stamina_changed(50.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_bright_50.png")

	# State C: 0% Stamina, 1 HP Critical, 0 Shield
	print("Capturing Bright 0%...")
	main._on_player_hp_changed(1, 5)
	main._on_player_armor_changed(0, 3)
	main._on_player_stamina_changed(0.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_bright_0.png")

	# State D: Exhausted Stamina, Track Flashed #8a3b32
	print("Capturing Bright Exhausted...")
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", true)
	main._play_stamina_exhaust_flash()
	await process_frame
	_save_capture("hud_bright_exhausted.png")

	# ── 2. DARK BACKGROUND (Cave 4-1, index 10) ──
	print("Switching to Dark Background (Cave 4-1, index 10)...")
	main.jump_to_level(10)
	for i in range(35):
		await process_frame

	main.update_hud_contrast()
	if is_instance_valid(main.player):
		main.player.set_physics_process(false)
		main.player.set("is_exhausted", false)

	# State A: 100% Stamina, Full HP (5/5), 3 Shield
	print("Capturing Dark 100%...")
	main._on_player_hp_changed(5, 5)
	main._on_player_armor_changed(3, 3)
	main._on_player_stamina_changed(100.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_dark_100.png")

	# State B: 50% Stamina, Mid HP (3/5), 2 Shield
	print("Capturing Dark 50%...")
	main._on_player_hp_changed(3, 5)
	main._on_player_armor_changed(2, 3)
	main._on_player_stamina_changed(50.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_dark_50.png")

	# State C: 0% Stamina, 1 HP Critical, 0 Shield
	print("Capturing Dark 0%...")
	main._on_player_hp_changed(1, 5)
	main._on_player_armor_changed(0, 3)
	main._on_player_stamina_changed(0.0, 100.0)
	for i in range(5):
		await process_frame
	_save_capture("hud_dark_0.png")

	# State D: Exhausted Stamina, Track Flashed #8a3b32
	print("Capturing Dark Exhausted...")
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", true)
	main._play_stamina_exhaust_flash()
	await process_frame
	_save_capture("hud_dark_exhausted.png")

	# ── 3. DAMAGE FEEDBACK TEST (Hold hp_damaged 0.25s) ──
	print("Capturing HP Damage Hold (hp_damaged)...")
	main._on_player_hp_changed(5, 5)
	for i in range(5):
		await process_frame
	# Take damage from 5 to 4
	main._on_player_hp_changed(4, 5)
	# Immediately after damage, slot 4 is holding hp_damaged
	await process_frame
	_save_capture("hud_hp_damaged_slot.png")

	print("--- ALL HUD SCREENSHOTS CAPTURED SUCCESSFULLY ---")
	main.free()
	quit(0)


func _save_capture(filename: String) -> void:
	var img = root.get_viewport().get_texture().get_image()
	if img:
		var path = "res://" + filename
		img.save_png(path)
		print("Saved screenshot: %s" % filename)
	else:
		push_error("Failed to capture image for %s" % filename)

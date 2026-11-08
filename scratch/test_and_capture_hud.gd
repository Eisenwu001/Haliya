extends SceneTree

func _init() -> void:
	print("--- Running Player Status HUD Verification and Captures ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(20):
		await process_frame

	# ── TEST 1: Hierarchy and Node Setup ──
	assert(is_instance_valid(main.hud_cluster_root), "HUD Status Cluster root must exist")
	assert(is_instance_valid(main.hud_cluster_bg), "HUD Cluster background must exist")
	assert(is_instance_valid(main.hp_pips_container), "HP Pips container must exist")
	assert(is_instance_valid(main.shield_wards_container), "Shield wards container must exist")
	assert(is_instance_valid(main.stamina_bar_root), "Stamina bar root must exist")
	assert(is_instance_valid(main.stamina_fill_clip), "Stamina fill clip must exist")

	# Check geometry
	var hp_sep = main.hp_pips_container.get_theme_constant("separation")
	assert(hp_sep == UIThemeConstants.HUD_HP_SPACING, "HP separation must be 4px, got %d" % hp_sep)

	var shield_sep = main.shield_wards_container.get_theme_constant("separation")
	assert(shield_sep == UIThemeConstants.HUD_SHIELD_SPACING, "Shield separation must be 4px, got %d" % shield_sep)

	# ── TEST 2: Initial Full HP + 3 Shield Wards ──
	main._on_player_armor_changed(3, 3)
	main._on_player_hp_changed(5, 5)
	main._on_player_stamina_changed(100.0, 100.0)

	for i in range(10):
		await process_frame

	var hp_count = main.hp_pips_container.get_child_count()
	assert(hp_count == 5, "HP container must always have exactly 5 base pips, got %d" % hp_count)
	for k in range(5):
		var pip = main.hp_pips_container.get_child(k) as TextureRect
		assert(pip.custom_minimum_size == UIThemeConstants.HUD_HP_PIP_SIZE, "HP pip must be 24x24 px")
		assert(pip.texture.resource_path.ends_with("hud_status_crescent_full.png"), "Pip %d must be full crescent" % k)

	var shield_count = main.shield_wards_container.get_child_count()
	assert(shield_count == 3, "Shield container must have exactly 3 active wards, got %d" % shield_count)
	for s in range(3):
		var ward = main.shield_wards_container.get_child(s) as TextureRect
		assert(ward.custom_minimum_size == UIThemeConstants.HUD_SHIELD_WARD_SIZE, "Ward must be 16x16 px")
		assert(ward.texture.resource_path.ends_with("hud_shield_ward.png"), "Ward %d must be shield ward texture" % s)

	print("SUCCESS: Full HP (5 pips) and Shield (3 wards) verified!")

	# ── TEST 3: Damage and Empty Slots ──
	# Damage to 3 HP, 0 shield
	main._on_player_armor_changed(0, 3)
	main._on_player_hp_changed(3, 5)

	# During crack animation frame
	await process_frame
	for i in range(30):
		await process_frame # wait past 0.20s crack duration

	var hp_count_dmg = main.hp_pips_container.get_child_count()
	assert(hp_count_dmg == 5, "HP container must still have 5 pips total")
	for k in range(3):
		var pip = main.hp_pips_container.get_child(k) as TextureRect
		print("Pip ", k, " resource: ", pip.texture.resource_path)
		assert(pip.texture.resource_path.ends_with("hud_status_crescent_full.png"), "Pip %d must remain full" % k)
	for k in range(3, 5):
		var pip = main.hp_pips_container.get_child(k) as TextureRect
		print("Pip ", k, " resource: ", pip.texture.resource_path)
		assert(pip.texture.resource_path.ends_with("hud_status_crescent_empty.png"), "Pip %d must be empty slot" % k)

	# Shield container has NO empty slots
	var active_shield_after = 0
	for ch in main.shield_wards_container.get_children():
		if not ch.has_meta("is_shattering"):
			active_shield_after += 1
	assert(active_shield_after == 0, "Shield container must have 0 wards when shield is depleted (no empty slots)")

	print("SUCCESS: Damaged state, empty dark crescent slots, and 0 empty shield slots verified!")

	# ── TEST 4: Capture Screenshots in All Required States ──
	print("--- Capturing Screenshots ---")

	# === A. DARK BACKGROUND (Level 13: Cave Scene - Deep Bioluminescent Threshold) ===
	main.jump_to_level(13)
	for i in range(35):
		await process_frame

	assert(main.hud_cluster_bg.modulate.a == 0.0, "Dark background contrast >= 3:1 so cluster BG must be hidden (alpha 0)")

	# 1. Dark: Full HP (5 HP, 3 Shield, 100% Stamina)
	main._on_player_armor_changed(3, 3)
	main._on_player_hp_changed(5, 5)
	main._on_player_stamina_changed(100.0, 100.0)
	main.stamina_bar_root.modulate.a = 1.0
	for i in range(15):
		await process_frame
	_save_capture("hud_dark_full_hp.png")

	# 2. Dark: Damaged (3 HP, 0 Shield, 70% Stamina)
	main._on_player_armor_changed(0, 3)
	main._on_player_hp_changed(3, 5)
	main._on_player_stamina_changed(70.0, 100.0)
	for i in range(20):
		await process_frame
	_save_capture("hud_dark_damaged.png")

	# 3. Dark: With Shield (4 HP, 2 Shield, 85% Stamina)
	main._on_player_armor_changed(2, 3)
	main._on_player_hp_changed(4, 5)
	main._on_player_stamina_changed(85.0, 100.0)
	for i in range(15):
		await process_frame
	_save_capture("hud_dark_with_shield.png")

	# 4. Dark: Exhausted (5 HP, 0 Stamina, Exhausted Track Flash)
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", true)
	main._on_player_stamina_changed(0.0, 100.0)
	for i in range(2): # 2 frames into 3-frame flash
		await process_frame
	_save_capture("hud_dark_exhausted.png")
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", false)

	# === B. BRIGHT BACKGROUND (Level 3: Rice Field 2-1: Emerald Terraces - Bright Daytime Sky) ===
	main.jump_to_level(3)
	for i in range(35):
		await process_frame

	assert(main.hud_cluster_bg.modulate.a == 1.0, "Bright background contrast < 3:1 so cluster BG must be active (alpha 1)")

	# 5. Bright: Full HP (5 HP, 3 Shield, 100% Stamina)
	main._on_player_armor_changed(3, 3)
	main._on_player_hp_changed(5, 5)
	main._on_player_stamina_changed(100.0, 100.0)
	main.stamina_bar_root.modulate.a = 1.0
	for i in range(15):
		await process_frame
	_save_capture("hud_bright_full_hp.png")

	# 6. Bright: Damaged (3 HP, 0 Shield, 70% Stamina)
	main._on_player_armor_changed(0, 3)
	main._on_player_hp_changed(3, 5)
	main._on_player_stamina_changed(70.0, 100.0)
	for i in range(20):
		await process_frame
	_save_capture("hud_bright_damaged.png")

	# 7. Bright: With Shield (4 HP, 2 Shield, 85% Stamina)
	main._on_player_armor_changed(2, 3)
	main._on_player_hp_changed(4, 5)
	main._on_player_stamina_changed(85.0, 100.0)
	for i in range(15):
		await process_frame
	_save_capture("hud_bright_with_shield.png")

	# 8. Bright: Exhausted (5 HP, 0 Stamina, Exhausted Track Flash)
	main._was_exhausted_cached = false
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", true)
	main._on_player_stamina_changed(0.0, 100.0)
	for i in range(2): # 2 frames into 3-frame flash
		await process_frame
	print("Track tex bright: ", main.stamina_track_tex.texture.resource_path)
	_save_capture("hud_bright_exhausted.png")
	if is_instance_valid(main.player):
		main.player.set("is_exhausted", false)

	print("--- ALL 8 HUD SCREENSHOTS CAPTURED SUCCESSFULLY ---")
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

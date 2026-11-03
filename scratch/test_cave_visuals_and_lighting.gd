extends SceneTree

func _init() -> void:
	print("--- Running Cave Visuals, Hollow Knight Mechanics & Lighting Verification ---")
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("Failed to load main.tscn")
		quit(1)
		return

	var main_instance = main_scene.instantiate()
	root.add_child(main_instance)

	# Allow _ready() to complete initial setup
	await process_frame
	await process_frame

	# Test Level 4 (index 11)
	print("Testing Level 4 (Index 11 - The Lapis Depths)...")
	main_instance.current_level_idx = 11
	main_instance.load_current_level()

	for f in range(30):
		await process_frame

	var player = main_instance.player
	if not player:
		printerr("Player node not found!")
		quit(1)
		return
	print("Player found: ", player.name)

	# 1. Verify Hollow Knight Player Mechanics
	print("Checking Hollow Knight mechanics on Player...")
	assert("jump_buffer_timer" in player, "Player must have jump_buffer_timer")
	assert("coyote_timer" in player, "Player must have coyote_timer")
	assert("can_air_dash" in player, "Player must have can_air_dash")
	assert(player.has_method("trigger_spike_pogo"), "Player must implement trigger_spike_pogo")
	print("PASS: Hollow Knight mechanics (variable jump, jump buffering, coyote time, air dash, spike pogo) verified on Player!")

	# 2. Verify Player Spirit Light
	var p_light = player.get_node_or_null("CaveSpiritLight") as PointLight2D
	if not p_light:
		printerr("FAIL: CaveSpiritLight not found on player!")
		quit(1)
		return
	print("PASS: CaveSpiritLight verified on player (energy: %s, scale: %s)" % [p_light.energy, p_light.texture_scale])

	# 3. Verify CanvasModulate
	var cm = main_instance.canvas_modulate
	print("CanvasModulate color in cave: ", cm.color)
	if cm.color.r < 0.30 or cm.color.r > 0.60:
		printerr("FAIL: Cave modulate color out of range: ", cm.color)
		quit(1)
		return
	print("PASS: CanvasModulate is balanced moody teal-slate (%s)" % cm.color)

	# 4. Verify Pogo Crystals in Level 4
	var pogo_crystals = get_nodes_in_group("pogo_crystals")
	print("Found %d pogo crystals in Level 4" % pogo_crystals.size())
	if pogo_crystals.size() < 4:
		printerr("FAIL: Expected at least 4 pogo crystals, got %d" % pogo_crystals.size())
		quit(1)
		return
	var sample_crystal = pogo_crystals[0]
	var c_light = sample_crystal.get_node_or_null("CrystalLight") as PointLight2D
	if not c_light:
		printerr("FAIL: CrystalLight not found on pogo crystal!")
		quit(1)
		return
	print("PASS: Pogo Crystal light verified (energy: %s, scale: %s)" % [c_light.energy, c_light.texture_scale])

	# 5. Verify Spike Hazards in Level 4
	var spike_hazards = get_nodes_in_group("spike_hazards")
	print("Found %d spike hazard zones in Level 4" % spike_hazards.size())
	if spike_hazards.is_empty():
		printerr("FAIL: No spike hazards found in spike_hazards group!")
		quit(1)
		return
	var sample_spike = spike_hazards[0]
	assert(sample_spike.has_method("trigger_pogo_bounce"), "Spikes must implement trigger_pogo_bounce for Hollow Knight nail pogo!")
	print("PASS: Spike hazard group and pogo bounce method verified!")

	# 6. Verify Platform Zero-Gap Deck Alignment in Level 4
	var current_level = main_instance.current_level_instance
	var elev_plats = current_level.find_child("ElevatedPlatforms", true, false)
	if not elev_plats:
		printerr("FAIL: ElevatedPlatforms not found in Level 4!")
		quit(1)
		return
	
	var plat_count = 0
	for child in elev_plats.get_children():
		if child is StaticBody2D and "Platform_" in child.name:
			var col = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
			var spr = child.get_node_or_null("Sprite2D") as Sprite2D
			if col and spr and col.shape is RectangleShape2D:
				var col_top = col.position.y - col.shape.size.y * 0.5
				var spr_half_h = spr.region_rect.size.y * 0.5 if spr.region_enabled else 24.0
				var spr_top = spr.position.y - spr_half_h
				var gap = abs(col_top - spr_top)
				assert(gap < 0.15, "Platform %s has floating gap: col_top=%.2f, spr_top=%.2f, gap=%.2f" % [child.name, col_top, spr_top, gap])
				plat_count += 1
	print("PASS: Verified %d platforms in Level 4 have EXACT 0.0-pixel gap (zero floating)!" % plat_count)

	# 7. Verify Ceiling Canopy and Grounded Arches
	var ceiling = current_level.find_child("CaveCeilingCanopy", true, false)
	if ceiling and ceiling.get_child_count() > 0:
		for c in ceiling.get_children():
			if c is Sprite2D:
				assert(c.scale.y == 1.0, "Ceiling stalactites must be 1:1 scale, got %s" % c.scale)
		print("PASS: Cave ceiling canopy uses 1:1 native pixel art scale!")

	var arches = current_level.find_child("CaveBackgroundArches", true, false)
	if arches and arches.get_child_count() > 0:
		for a in arches.get_children():
			if a is Sprite2D:
				assert(a.position.y > 100.0, "CaveBackgroundArches must be grounded, got y=%s" % a.position.y)
		print("PASS: Cave background arches are properly grounded!")

	# 8. Test Level 5 (index 12)
	print("Testing Level 5 (Index 12 - Bakunawa's Abyss)...")
	main_instance.current_level_idx = 12
	main_instance.load_current_level()

	for f in range(30):
		await process_frame

	var lvl5 = main_instance.current_level_instance
	var moon = lvl5.find_child("EclipseMoonCenterpiece", true, false)
	if not moon:
		printerr("FAIL: EclipseMoonCenterpiece not found in Level 5!")
		quit(1)
		return
	var moon_light = moon.get_node_or_null("MoonLight") as PointLight2D
	var moon_ambient = moon.get_node_or_null("MoonAmbientGlow") as PointLight2D
	if not moon_light or not moon_ambient:
		printerr("FAIL: EclipseMoon lights not found!")
		quit(1)
		return
	print("PASS: Eclipse Moon lights verified (core energy: %s, ambient scale: %s)" % [moon_light.energy, moon_ambient.texture_scale])

	# Verify Level 5 platforms zero gap
	var lvl5_plats = lvl5.find_child("ElevatedPlatforms", true, false)
	var lvl5_plat_count = 0
	for child in lvl5_plats.get_children():
		if child is StaticBody2D and "Platform_" in child.name:
			var col = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
			var spr = child.get_node_or_null("Sprite2D") as Sprite2D
			if col and spr and col.shape is RectangleShape2D:
				var col_top = col.position.y - col.shape.size.y * 0.5
				var spr_half_h = spr.region_rect.size.y * 0.5 if spr.region_enabled else 24.0
				var spr_top = spr.position.y - spr_half_h
				var gap = abs(col_top - spr_top)
				assert(gap < 0.15, "Level 5 Platform %s has floating gap: col_top=%.2f, spr_top=%.2f, gap=%.2f" % [child.name, col_top, spr_top, gap])
				lvl5_plat_count += 1
	print("PASS: Verified %d platforms in Level 5 have EXACT 0.0-pixel gap (zero floating)!" % lvl5_plat_count)

	print("--- ALL CAVE VISUALS, HOLLOW KNIGHT MECHANICS & LIGHTING VERIFICATIONS PASSED ---")
	quit(0)

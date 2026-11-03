extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	await create_timer(0.3).timeout

	# Jump to Level 1-3 (Index 2 in LEVELS_DATA)
	main.jump_to_level(2)
	await create_timer(0.4).timeout

	# Find ForestBruteMiniboss in Level 1-3, and clear other enemies in the arena
	var brute = null
	for e in main.active_enemies:
		if e is ForestBruteMiniboss:
			brute = e
		elif is_instance_valid(e):
			e.global_position = Vector2(-9999.0, -9999.0) # Move non-boss enemies away

	if brute and main.player:
		# Reposition player and miniboss firmly on the ground (y = 288.0) in the arena
		brute.global_position = Vector2(4460.0, 288.0)
		main.player.global_position = Vector2(4340.0, 288.0)
		main.player.velocity = Vector2.ZERO
		main.player.is_facing_left = false
		if main.player.get("sprite"):
			main.player.sprite.flip_h = false
		
		# Teleport camera and reset smoothing immediately
		main.camera.global_position = Vector2(4400.0, 240.0)
		if main.camera.has_method("reset_smoothing"):
			main.camera.reset_smoothing()
		if main.camera.has_method("force_update_scroll"):
			main.camera.force_update_scroll()

		# Freeze boss AI momentarily for clean photography
		brute.set_physics_process(false)

		# 1. Snapshot Phase 1 (Barehanded Combat Stance)
		brute.is_phase_2 = false
		brute.is_enraged = false
		brute.is_invulnerable = false
		brute.health = 18
		brute.set_state(ForestBruteMiniboss.State.IDLE)
		brute.sprite.modulate = Color(1, 1, 1, 1)
		brute.sprite.frame = 0 # Phase 1 Idle
		brute.is_facing_left = true
		brute.sprite.flip_h = true
		await create_timer(0.2).timeout
		var img_p1 = root.get_texture().get_image()
		img_p1.save_png("res://snapshot_miniboss_phase1.png")
		print("Snapshot Miniboss Phase 1 saved")

		# 1b. Snapshot Phase 1 Walk (Smooth striding legs)
		brute.sprite.frame = 12 # Passing crossover stride
		await create_timer(0.2).timeout
		var img_walk1 = root.get_texture().get_image()
		img_walk1.save_png("res://snapshot_miniboss_phase1_walk.png")
		print("Snapshot Miniboss Phase 1 Walk saved")

		# 2. Snapshot Weapon Pickup & Health Regen
		brute.start_weapon_pickup_transition()
		brute.state_timer = 1.15 # Frame 44 (Lifting club from earth with healing aura)
		brute.sprite.frame = 44
		brute.health = 10
		if is_instance_valid(brute.health_pips):
			brute.health_pips.update_health(10, 18, false)
		brute.spawn_green_soul_wisps(6)
		brute.sprite.modulate = Color(0.8, 1.9, 0.8, 1.0)
		await create_timer(0.2).timeout
		var img_pickup = root.get_texture().get_image()
		img_pickup.save_png("res://snapshot_miniboss_pickup_regen.png")
		print("Snapshot Miniboss Weapon Pickup saved")

		# 3. Snapshot Phase 2 Armed Berserker Stance (Club on Shoulder)
		brute.is_phase_2 = true
		brute.is_enraged = true
		brute.is_invulnerable = false
		brute.health = 18
		if is_instance_valid(brute.health_pips):
			brute.health_pips.update_health(18, 18, false)
		brute.set_state(ForestBruteMiniboss.State.IDLE)
		brute.sprite.frame = 80 # Club rested on shoulder
		brute.sprite.modulate = Color(1.25, 0.75, 0.75, 1.0)
		brute.is_facing_left = true
		brute.sprite.flip_h = true
		await create_timer(0.2).timeout
		var img_p2 = root.get_texture().get_image()
		img_p2.save_png("res://snapshot_miniboss_phase2_armed.png")
		print("Snapshot Miniboss Phase 2 Armed saved")

		# 3b. Snapshot Phase 2 Armed Walk (Walking with Spiked Club on Shoulder)
		brute.sprite.frame = 82 # Armed Passing stride with club
		await create_timer(0.2).timeout
		var img_walk2 = root.get_texture().get_image()
		img_walk2.save_png("res://snapshot_miniboss_phase2_walk.png")
		print("Snapshot Miniboss Phase 2 Armed Walk saved")

		# 4. Snapshot Phase 2 Full-Body Green Whirlwind
		brute.sprite.frame = 63 # Emerald Whirlwind Tornado Spin
		await create_timer(0.2).timeout
		var img_whirl = root.get_texture().get_image()
		img_whirl.save_png("res://snapshot_miniboss_phase2_whirlwind.png")
		print("Snapshot Miniboss Phase 2 Whirlwind saved")

	main.free()
	print("ALL FOREST MINIBOSS SNAPSHOTS CAPTURED!")
	quit(0)

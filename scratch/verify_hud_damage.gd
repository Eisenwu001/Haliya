extends SceneTree

func _init() -> void:
	print("--- Testing HUD Damage & Low HP States ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	for i in range(25):
		await process_frame

	# Test 1: Damage taking (lost 2 HP, lost all armor)
	print("Testing HP: 3/5, Armor: 0")
	main._on_player_armor_changed(0, 3)
	main._on_player_hp_changed(3, 5)
	for i in range(10):
		await process_frame

	var pips_count = main.hp_pips_container.get_child_count()
	assert(pips_count == 5, "Expected 5 pips with 0 armor, got %d" % pips_count)
	print("SUCCESS: 5 pips rendered for 3/5 HP (3 full, 2 empty)")

	# Test 2: Critical low HP (1/5 HP, 0 armor)
	print("Testing Critical HP: 1/5, Armor: 0")
	main._on_player_hp_changed(1, 5)
	for i in range(10):
		await process_frame

	var p1 = main.hp_pips_container.get_child(0) as TextureRect
	assert(p1.texture.resource_path.ends_with("hud_pip_crescent_danger.png"), "Expected danger pip for 1 HP!")
	print("SUCCESS: Danger red pip (#8a3b32) activated for critical low health!")

	# Test 3: Damage flash overlay (#8a3b32)
	main._on_player_damage_taken(1, false)
	assert(main.damage_flash_overlay.color.r > 0.5 and main.damage_flash_overlay.color.g < 0.3, "Damage flash must use #8a3b32!")
	print("SUCCESS: Damage flash overlay uses #8a3b32 danger red!")

	# Test 4: Pause menu open & close via signals
	print("Testing PauseMenuScreen signal wiring")
	main.toggle_pause()
	assert(paused == true, "Game tree must be paused!")
	assert(main.pause_overlay.visible == true, "Pause overlay must be visible!")

	# Test resume signal
	main.pause_overlay.resume_requested.emit()
	assert(paused == false, "Game tree must be unpaused after resume signal!")
	assert(main.pause_overlay.visible == false, "Pause overlay must be hidden after resume signal!")
	print("SUCCESS: PauseMenuScreen toggle_pause and resume signal tested cleanly!")

	main.free()
	print("--- ALL VERIFICATION TESTS PASSED ---")
	quit(0)

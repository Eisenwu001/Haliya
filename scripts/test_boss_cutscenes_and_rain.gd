extends SceneTree

func _init() -> void:
	print("--- TESTING BOSS CUTSCENES & STAGE 2 RAIN LOGIC ---")

	var MainScript = load("res://scripts/main.gd")
	if not MainScript:
		print("FAIL: Could not load main.gd")
		quit(1)
		return
	print("PASS: main.gd loaded and compiled successfully")

	var MainMenuScript = load("res://scripts/main_menu.gd")
	if not MainMenuScript:
		print("FAIL: Could not load main_menu.gd")
		quit(1)
		return
	print("PASS: main_menu.gd loaded and compiled successfully")

	var main_node = MainScript.new()
	root.add_child(main_node)

	# Set level to Level 2-5 (Stage 2 Miniboss)
	# In LEVELS_DATA, index 7 is Level 2-5
	var lvl_2_5_idx = -1
	for i in range(main_node.LEVELS_DATA.size()):
		if main_node.LEVELS_DATA[i].get("level_title") == "Level 2-5":
			lvl_2_5_idx = i
			break

	if lvl_2_5_idx == -1:
		print("FAIL: Level 2-5 not found in LEVELS_DATA")
		quit(1)
		return
	print("PASS: Found Level 2-5 at index: ", lvl_2_5_idx)

	main_node.current_level_idx = lvl_2_5_idx
	main_node.is_stage_2_boss_defeated = false

	# Setup a mock player
	var p = CharacterBody2D.new()
	p.name = "Player"
	p.global_position = Vector2(4200, 200) # In the boss arena
	main_node.player = p
	main_node.add_child(p)

	# Setup rain particles mock
	var rain = CPUParticles2D.new()
	rain.name = "RainParticles"
	rain.emitting = false
	main_node.rain_particles = rain
	main_node.add_child(rain)

	# Verify: BEFORE boss defeat, process update leaves rain OFF
	main_node._process(0.016)
	if main_node.current_storm_intensity != 0.0 or rain.emitting:
		print("FAIL: Rain was active in Stage 2 boss arena before boss was defeated! Intensity: ", main_node.current_storm_intensity, " Emitting: ", rain.emitting)
		quit(1)
		return
	print("PASS: Confirmed Stage 2 boss arena is DRY and rain is OFF before defeating boss")

	# Test trigger_miniboss_arena_lockdown
	main_node.active_encounter_type = "mayon_vanguard"
	main_node.has_seen_boss_encounter_cutscene = false
	# Trigger encounter cutscene directly
	if is_instance_valid(main_node.comic_story_viewer):
		main_node.comic_story_viewer.play_cutscene("MAYON VANGUARD", "Champion of the Burning Kiln", ["res://assets/cutscenes/stage2_boss_encounter.jpg"], "", false, false)
		if not main_node.comic_story_viewer.is_active:
			print("FAIL: Encounter cutscene did not become active")
			quit(1)
			return
		print("PASS: Mayon Vanguard encounter cutscene activated")
		main_node.comic_story_viewer.close_story(true)

	# Test handle_miniboss_defeated
	var mock_enemy = Node2D.new()
	main_node.handle_miniboss_defeated(mock_enemy)

	if not main_node.is_stage_2_boss_defeated:
		print("FAIL: is_stage_2_boss_defeated was not set to true on miniboss defeat")
		quit(1)
		return
	print("PASS: is_stage_2_boss_defeated set to true upon defeating Mayon Vanguard")

	# Process update after boss defeat: rain must now be ON!
	main_node._process(0.016)
	if main_node.current_storm_intensity != 1.0 or not rain.emitting:
		print("FAIL: Rain did not activate in Stage 2 after defeating boss! Intensity: ", main_node.current_storm_intensity, " Emitting: ", rain.emitting)
		quit(1)
		return
	print("PASS: Confirmed torrential rain unleashed in Stage 2 after defeating boss!")

	# Clean up
	main_node.queue_free()
	print("ALL CUTSCENE AND RAIN LOGIC TESTS PASSED SUCCESSFULLY!")
	quit(0)

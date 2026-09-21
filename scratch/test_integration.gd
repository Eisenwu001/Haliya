extends SceneTree

func _init() -> void:
	_run()

func _run() -> void:
	print("[INTEGRATION] Loading main scene...")
	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "Failed to load main.tscn")
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	await process_frame
	await process_frame

	print("[INTEGRATION] Main scene instantiated. Current level: ", main_node.current_level_idx)
	assert(main_node.bgm_audio_player != null, "BGM player should be initialized")
	assert(main_node.bgm_audio_player.playing == true, "BGM should be playing")

	# Jump directly to Level 3-5 (Index 10)
	print("[INTEGRATION] Jumping to Level 3-5 (The Tempest Climax)...")
	main_node.jump_to_level(10)
	await process_frame
	await process_frame

	assert(main_node.current_level_idx == 10, "Current level should be 10")
	print("[INTEGRATION] Level 3-5 loaded successfully. Theme: ", main_node.current_bgm_track)

	# Trigger Boss Encounter
	print("[INTEGRATION] Simulating player reaching boss clearing at x=3850...")
	main_node.player.global_position.x = 3850.0
	main_node._process(0.016)
	await process_frame

	assert(main_node.is_boss_active == true, "Boss encounter should be active")
	assert(main_node.boss_instance != null, "Boss instance should be spawned")
	assert(main_node.boss_arena_barriers.size() == 2, "Boss arena barriers should be spawned")
	print("[INTEGRATION] Boss active! Boss HP: ", main_node.boss_instance.health, " BGM: ", main_node.current_bgm_track)

	# Test damaging boss through main scene
	main_node.boss_instance.take_damage(12, 1.0)
	await process_frame
	print("[INTEGRATION] Boss damaged down to: ", main_node.boss_instance.health, " Phase: ", main_node.boss_instance.current_phase)
	assert(main_node.boss_instance.current_phase == 2, "Boss should be in Phase 2 Enrage")

	# Defeat boss
	print("[INTEGRATION] Delivering final blow to boss...")
	main_node.boss_instance.take_damage(20, 1.0)
	await process_frame
	assert(main_node.boss_instance.is_dead == true, "Boss should be dead")
	assert(main_node.boss_arena_barriers.is_empty() == true, "Barriers should be cleared")
	print("[INTEGRATION] Boss defeated cleanly! Barriers cleared.")

	print("[INTEGRATION] ALL PHASE 2 & PHASE 4 TESTS COMPLETED WITH 100% SUCCESS!")
	quit()

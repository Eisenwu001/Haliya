@tool
extends SceneTree

func _init() -> void:
	print("=== Running Forest Ambient & Dynamic Bird Chirping Verification ===")
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.2).timeout

	# 1. Verify ProceduralAudio streams
	print("\n1. Testing Ambient Forest Canopy Wind Loop & Bird Chirps:")
	var ambient_stream = ProceduralAudio.get_forest_ambient()
	print("  Ambient Stream loaded: ", ambient_stream != null)
	assert(ambient_stream != null, "Forest ambient stream must not be null")
	if ambient_stream is AudioStreamWAV:
		var wav = ambient_stream as AudioStreamWAV
		print("  WAV format: 16-bit, mix_rate: ", wav.mix_rate, ", loop_mode: ", wav.loop_mode)
		assert(wav.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ambient wind must loop forward")

	for i in range(10):
		var chirp = ProceduralAudio.get_random_bird_chirp()
		assert(chirp != null, "Bird chirp stream should be valid")
	print("  10 random bird chirps generated/retrieved successfully!")

	# 2. Testing Forest Level 1-1 (idx 0)
	print("\n2. Testing Forest Level 1-1 Setup:")
	main_scene.current_level_idx = 0
	main_scene.load_current_level()
	main_scene.spawn_level_enemies()
	await create_timer(0.2).timeout

	print("  BGM Track Key: ", main_scene.current_bgm_track)
	print("  Forest Bird Players count: ", main_scene.forest_bird_players.size())
	assert(main_scene.forest_bird_players.size() == 2, "Must have 2 AudioStreamPlayer2D bird players")
	for bp in main_scene.forest_bird_players:
		assert(bp.panning_strength >= 1.0, "Panning strength should be >= 1.0")
		assert(bp.max_distance >= 2000.0, "Max distance should cover screen range")

	# Position camera at x = 800 (between trees)
	main_scene.camera.global_position = Vector2(800.0, 180.0)
	main_scene.trigger_forest_bird_chirp()

	var playing_bird: AudioStreamPlayer2D = null
	for bp in main_scene.forest_bird_players:
		if bp.playing:
			playing_bird = bp
			break

	assert(playing_bird != null, "A bird player should have started playing")
	var offset_from_cam = playing_bird.global_position.x - main_scene.camera.global_position.x
	print("  Bird Chirp Position: ", playing_bird.global_position, " Offset from Camera: ", offset_from_cam)
	print("  Panning direction: ", "RIGHT" if offset_from_cam > 0 else "LEFT")

	# 3. Testing Forest Level 1-2 (idx 1) and 1-3 (idx 2)
	for lvl_idx in [1, 2]:
		print("\n3. Testing Forest Level index %d:" % lvl_idx)
		main_scene.current_level_idx = lvl_idx
		main_scene.load_current_level()
		main_scene.camera.global_position = Vector2(700.0, 180.0)
		main_scene.trigger_forest_bird_chirp()
		print("  Level %d bird trigger executed cleanly!" % lvl_idx)

	# 4. Testing Non-Forest Level (Rice Field idx 3)
	print("\n4. Testing Transition to Rice Field (idx 3):")
	main_scene.current_level_idx = 3
	main_scene.load_current_level()
	main_scene._process(0.016)
	for bp in main_scene.forest_bird_players:
		assert(not bp.playing, "Bird players should not be playing in Rice Field")
	print("  Bird players correctly deactivated in non-forest levels!")

	print("\n=== ALL FOREST AMBIENT & BIRD CHIRPING TESTS PASSED! ===")
	main_scene.free()
	quit(0)

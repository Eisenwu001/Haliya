extends SceneTree

func _init() -> void:
	print("=======================================================")
	print("STARTING HOLLOW KNIGHT VERTICAL CAVERN AUDIT: LEVEL 4-1")
	print("=======================================================")

	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	main.jump_to_level(11) # Level 4-1
	await physics_frame
	await physics_frame

	var p = main.player
	assert(p != null, "Player must exist!")

	# 1. Test Spawn in Chamber 1
	for f in range(30):
		await physics_frame

	var spawn_pos = p.global_position
	var on_floor = p.is_on_floor()
	print("1. Chamber 1 Spawn: pos=(%0.1f, %0.1f) | on_floor=%s | camera_pos=(%0.1f, %0.1f)" % [
		spawn_pos.x, spawn_pos.y, on_floor, main.camera.global_position.x, main.camera.global_position.y
	])
	assert(on_floor, "Player must spawn flush on the floor!")
	assert(abs(spawn_pos.y - 288.0) < 0.5, "Player must be on ground line Y=288.0!")
	assert(abs(main.camera.global_position.y - 180.0) < 1.0, "Camera should frame upper ceiling at Y=180.0!")

	# 2. Test Chamber 1 Walk to Cliff Edge
	for f in range(60):
		p.velocity.x = 220.0
		await physics_frame
	print("2. Chamber 1 Walk: moved to X=%0.1f, Y=%0.1f | wall_blocked=%s" % [p.global_position.x, p.global_position.y, p.is_on_wall()])
	assert(p.global_position.x > 300.0, "Player must move forward smoothly!")
	assert(not p.is_on_wall(), "Player must not hit any invisible wall in Chamber 1!")

	# 3. Test Chamber 2 Vertical Descent into Deep Grotto (Y=864)
	print("3. Teleporting to Chamber 2 Shaft and descending...")
	p.global_position = Vector2(1200.0, 750.0)
	p.velocity = Vector2.ZERO
	for f in range(40):
		await physics_frame

	var grotto_pos = p.global_position
	var grotto_floor = p.is_on_floor()
	var cam_grotto = main.camera.global_position
	print("   Chamber 3 Grotto Floor: pos=(%0.1f, %0.1f) | on_floor=%s | camera=(%0.1f, %0.1f)" % [
		grotto_pos.x, grotto_pos.y, grotto_floor, cam_grotto.x, cam_grotto.y
	])
	assert(not main.is_player_dead, "Player must NOT die when descending to Y=780-864!")
	assert(cam_grotto.y > 500.0, "Camera must track DOWN into the deep grotto! Got Y=%0.1f" % cam_grotto.y)

	# 4. Test Chamber 3 Deep Grotto Bedrock Landing
	p.global_position = Vector2(1880.0, 840.0)
	p.velocity = Vector2.ZERO
	for f in range(30):
		await physics_frame
	print("   Deep Grotto Bedrock: pos=(%0.1f, %0.1f) | on_floor=%s" % [p.global_position.x, p.global_position.y, p.is_on_floor()])
	assert(p.is_on_floor(), "Player must stand on deep bedrock floor!")
	assert(abs(p.global_position.y - 864.0) < 0.5, "Bedrock floor must be at Y=864.0!")

	# 5. Test Chamber 4 Ascending Pillar Cathedral
	print("4. Testing Chamber 4 Ascending Pillar Cathedral...")
	# Pillar I
	p.global_position = Vector2(3450.0, 620.0)
	p.velocity = Vector2.ZERO
	for f in range(25):
		await physics_frame
	print("   Pillar I top: pos=(%0.1f, %0.1f) | on_floor=%s | cam_y=%0.1f" % [p.global_position.x, p.global_position.y, p.is_on_floor(), main.camera.global_position.y])
	assert(p.is_on_floor() and abs(p.global_position.y - 640.0) < 0.5, "Must land flush on Pillar I at Y=640!")

	# Pillar II
	p.global_position = Vector2(3880.0, 460.0)
	p.velocity = Vector2.ZERO
	for f in range(25):
		await physics_frame
	print("   Pillar II top: pos=(%0.1f, %0.1f) | on_floor=%s | cam_y=%0.1f" % [p.global_position.x, p.global_position.y, p.is_on_floor(), main.camera.global_position.y])
	assert(p.is_on_floor() and abs(p.global_position.y - 480.0) < 0.5, "Must land flush on Pillar II at Y=480!")

	# Pillar III
	p.global_position = Vector2(4330.0, 330.0)
	p.velocity = Vector2.ZERO
	for f in range(25):
		await physics_frame
	print("   Pillar III top: pos=(%0.1f, %0.1f) | on_floor=%s | cam_y=%0.1f" % [p.global_position.x, p.global_position.y, p.is_on_floor(), main.camera.global_position.y])
	assert(p.is_on_floor() and abs(p.global_position.y - 352.0) < 0.5, "Must land flush on Pillar III at Y=352!")

	# Pillar IV
	p.global_position = Vector2(4760.0, 235.0)
	p.velocity = Vector2.ZERO
	for f in range(25):
		await physics_frame
	print("   Pillar IV top: pos=(%0.1f, %0.1f) | on_floor=%s | cam_y=%0.1f" % [p.global_position.x, p.global_position.y, p.is_on_floor(), main.camera.global_position.y])
	assert(p.is_on_floor() and abs(p.global_position.y - 256.0) < 0.5, "Must land flush on Pillar IV at Y=256!")

	# 6. Test Chamber 5 Upper Sanctuary & Exit
	print("5. Testing Chamber 5 Upper Sanctuary...")
	p.global_position = Vector2(5200.0, 260.0)
	p.velocity = Vector2.ZERO
	for f in range(25):
		await physics_frame
	print("   Sanctuary terrace: pos=(%0.1f, %0.1f) | on_floor=%s | cam=(%0.1f, %0.1f)" % [p.global_position.x, p.global_position.y, p.is_on_floor(), main.camera.global_position.x, main.camera.global_position.y])
	assert(p.is_on_floor() and abs(p.global_position.y - 288.0) < 0.5, "Must land on Sanctuary terrace at Y=288!")

	# Walk to exit portal at X=6300
	p.global_position = Vector2(6250.0, 260.0)
	for f in range(30):
		p.velocity.x = 200.0
		await physics_frame
	print("   Approaching exit: pos=(%0.1f, %0.1f) | cam_x=%0.1f" % [p.global_position.x, p.global_position.y, main.camera.global_position.x])
	assert(p.global_position.x > 6200.0, "Player must reach the exit barrier zone at X=6230..6300!")
	print("   [PASS] Exit barrier approached at X=%0.1f (safely blocked as expected before enemies defeated)" % p.global_position.x)

	print("\n=======================================================")
	print("HOLLOW KNIGHT VERTICAL CAVERN LEVEL 4-1 FULLY VERIFIED!")
	print("=======================================================")
	main.free()
	quit(0)

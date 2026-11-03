extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	# Allow _ready to execute and instantiate player
	await create_timer(0.3).timeout

	# Snapshot 1: Level 4-1 (Entrance)
	main.jump_to_level(11)
	if main.player:
		main.player.global_position = Vector2(250.0, 260.0)
	await create_timer(0.3).timeout
	var img4_1 = root.get_texture().get_image()
	img4_1.save_png("res://snapshot_level4_1.png")
	print("Level 4-1 snapshot saved")

	# Snapshot 2: Level 4-1 (Platforming over Gap 1)
	if main.player:
		main.player.global_position = Vector2(1312.0, 210.0)
	await create_timer(0.3).timeout
	var img4_1_plat = root.get_texture().get_image()
	img4_1_plat.save_png("res://snapshot_level4_1_plat.png")
	print("Level 4-1 platform snapshot saved")

	# Snapshot 3: Level 4-2 (Sunken Lunar Ruins)
	main.jump_to_level(12)
	if main.player:
		main.player.global_position = Vector2(1100.0, 220.0)
	await create_timer(0.3).timeout
	var img4_2 = root.get_texture().get_image()
	img4_2.save_png("res://snapshot_level4_2.png")
	print("Level 4-2 snapshot saved")

	# Snapshot 4: Level 4-3 (The Abyssal Gauntlet / Miniboss Arena)
	main.jump_to_level(13)
	if main.player:
		main.player.global_position = Vector2(4400.0, 260.0)
	await create_timer(0.3).timeout
	var img4_3 = root.get_texture().get_image()
	img4_3.save_png("res://snapshot_level4_3.png")
	print("Level 4-3 snapshot saved")

	# Snapshot 5: Level 5 (Bakunawa Boss Arena)
	main.jump_to_level(14)
	if main.player:
		main.player.global_position = Vector2(4100.0, 260.0)
	main.start_bakunawa_encounter()
	await create_timer(0.4).timeout
	var img5 = root.get_texture().get_image()
	img5.save_png("res://snapshot_level5.png")
	print("Level 5 snapshot saved")

	main.free()
	print("ALL SNAPSHOTS CAPTURED!")
	quit(0)

extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	await create_timer(0.3).timeout

	# 1. Level 2-1: Emerald Terraces (Carabao & Egret in Sunlit Paddies)
	main.jump_to_level(3)
	if main.player:
		main.player.global_position = Vector2(560.0, 260.0)
	await create_timer(0.4).timeout
	var img2_1 = root.get_texture().get_image()
	img2_1.save_png("res://snapshot_rice_field_2_1.png")
	print("Snapshot 2-1 (Carabao & Paddies) saved")

	# 2. Level 2-1: Stilt House & Terraces
	if main.player:
		main.player.global_position = Vector2(2500.0, 260.0)
	await create_timer(0.4).timeout
	var img2_1_b = root.get_texture().get_image()
	img2_1_b.save_png("res://snapshot_rice_field_2_1_farmstead.png")
	print("Snapshot 2-1 (Farmstead) saved")

	# 3. Level 2-2: Stilt Farmstead at Twilight (Bahay Kubo & Scarecrows)
	main.jump_to_level(4)
	if main.player:
		main.player.global_position = Vector2(1150.0, 260.0)
	await create_timer(0.4).timeout
	var img2_2 = root.get_texture().get_image()
	img2_2.save_png("res://snapshot_rice_field_2_2.png")
	print("Snapshot 2-2 (Twilight Farmstead) saved")

	# 4. Level 2-3: The Mayon Crossing (Volcanic Arena & Vanguard Miniboss)
	main.jump_to_level(5)
	if main.player:
		main.player.global_position = Vector2(4350.0, 250.0)
	await create_timer(0.4).timeout
	var img2_3 = root.get_texture().get_image()
	img2_3.save_png("res://snapshot_rice_field_2_3.png")
	print("Snapshot 2-3 (Mayon Arena & Vanguard) saved")

	main.free()
	print("ALL RICE FIELD SNAPSHOTS CAPTURED!")
	quit(0)

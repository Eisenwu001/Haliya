extends SceneTree

func _init() -> void:
	var tut_scene = load("res://scenes/tutorial_stage.tscn")
	var tut = tut_scene.instantiate()
	root.add_child(tut)
	await create_timer(0.4).timeout

	# 1. Spawn & Homestead
	if tut.player:
		tut.player.global_position = Vector2(200.0, 260.0)
	if tut.camera:
		tut.camera.global_position = Vector2(300.0, 240.0)
	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/snap_tut_1_homestead.png")

	# 2. Elevated Jump Platform & Crouch Beam
	if tut.player:
		tut.player.global_position = Vector2(650.0, 210.0)
	if tut.camera:
		tut.camera.global_position = Vector2(700.0, 230.0)
	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/snap_tut_2_jump_crouch.png")

	# 3. Weapon Rack & Pots
	if tut.player:
		tut.player.global_position = Vector2(1050.0, 260.0)
	if tut.camera:
		tut.camera.global_position = Vector2(1050.0, 240.0)
	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/snap_tut_3_weapons_pots.png")

	# 4. Training Dummy
	if tut.player:
		tut.player.global_position = Vector2(1620.0, 260.0)
	if tut.camera:
		tut.camera.global_position = Vector2(1680.0, 240.0)
	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/snap_tut_4_dummy.png")

	# 5. Balete & Kapre & Altar
	if tut.player:
		tut.player.global_position = Vector2(2100.0, 260.0)
	if tut.camera:
		tut.camera.global_position = Vector2(2150.0, 240.0)
	await create_timer(0.2).timeout
	root.get_texture().get_image().save_png("res://scratch/snap_tut_5_kapre_altar.png")

	print("Tutorial snapshots captured successfully!")
	tut.free()
	quit(0)

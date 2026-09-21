@tool
extends SceneTree

func _init() -> void:
	print("--- Starting Main Menu Verification ---")
	var menu_res = load("res://scenes/main_menu.tscn")
	if not menu_res:
		print("ERROR: Failed to load main_menu.tscn")
		quit(1)
		return

	var menu = menu_res.instantiate()
	root.add_child(menu)
	await create_timer(0.3).timeout

	var artifact_dir: String = "C:/Users/Lin/.gemini/antigravity/brain/6c52ed0e-76d1-46ce-a8b4-d7788f2d5ff7/"

	# 1. Capture Main Menu default screen
	await create_timer(0.5).timeout
	var img1 = root.get_texture().get_image()
	if img1:
		img1.save_png(artifact_dir + "menu_main_screen.png")
		print("Saved menu_main_screen.png")

	# 2. Capture Stage Select modal
	menu.stage_select_modal.visible = true
	await create_timer(0.2).timeout
	var img2 = root.get_texture().get_image()
	if img2:
		img2.save_png(artifact_dir + "menu_stage_select.png")
		print("Saved menu_stage_select.png")
	menu.stage_select_modal.visible = false

	# 3. Capture Controls modal
	menu.controls_modal.visible = true
	await create_timer(0.2).timeout
	var img3 = root.get_texture().get_image()
	if img3:
		img3.save_png(artifact_dir + "menu_controls.png")
		print("Saved menu_controls.png")
	menu.controls_modal.visible = false

	print("--- Main Menu Verification PASSED ---")
	menu.free()
	quit(0)

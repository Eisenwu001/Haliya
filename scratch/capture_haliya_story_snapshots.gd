extends SceneTree

const MainMenuScript = preload("res://scripts/main_menu.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)

	var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/"

	# 1. Capture Loading Screen
	var menu = MainMenuScript.new()
	viewport.add_child(menu)
	menu._ready()
	menu._start_loading_sequence()

	# Freeze at 68% for snapshot
	if is_instance_valid(menu.loading_tween) and menu.loading_tween.is_valid():
		menu.loading_tween.kill()
	if is_instance_valid(menu.loading_fill_bar):
		menu.loading_fill_bar.size.x = 336.0 * 0.68
	if is_instance_valid(menu.loading_pct_label):
		menu.loading_pct_label.text = "68%"
	if is_instance_valid(menu.loading_status_label):
		menu.loading_status_label.text = "LOADING ANCIENT ASSETS..."
	if is_instance_valid(menu.loading_container):
		menu.loading_container.visible = true
		menu.loading_container.modulate.a = 1.0
	if is_instance_valid(menu.fade_rect):
		menu.fade_rect.color.a = 0.0

	for i in range(4):
		await process_frame

	var img1 = viewport.get_texture().get_image()
	if img1:
		img1.save_png(artifact_dir + "loading_screen_bottom_bar.png")
		print("SUCCESS: Saved loading_screen_bottom_bar.png")

	menu.queue_free()

	for i in range(2):
		await process_frame

	# 2. Capture Comic Story Viewer
	var viewer = ComicStoryViewerScript.new()
	viewport.add_child(viewer)
	viewer.open_story(true)
	viewer.bg_rect.modulate.a = 1.0

	for i in range(4):
		await process_frame

	var img2 = viewport.get_texture().get_image()
	if img2:
		img2.save_png(artifact_dir + "haliya_comic_panel1_viewer.png")
		print("SUCCESS: Saved haliya_comic_panel1_viewer.png")

	viewer.queue_free()

	for i in range(2):
		await process_frame

	# 3. Capture Main Menu with Prologue Chronicles Button
	MainMenuScript.has_shown_splash = true
	var menu2 = MainMenuScript.new()
	viewport.add_child(menu2)
	menu2._ready()
	menu2.fade_rect.color.a = 0.0

	for i in range(4):
		await process_frame

	var img3 = viewport.get_texture().get_image()
	if img3:
		img3.save_png(artifact_dir + "main_menu_prologue_button.png")
		print("SUCCESS: Saved main_menu_prologue_button.png")

	quit(0)

extends SceneTree

const MainMenuScript = preload("res://scripts/main_menu.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")

func _init() -> void:
	var vp = SubViewport.new()
	vp.size = Vector2(640, 360)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(vp)

	# 1. Snapshot of Loading Screen (at 60% progress)
	var menu = MainMenuScript.new()
	vp.add_child(menu)
	menu._ready()
	menu._start_loading_sequence()

	# Set loading progress to 65%
	if is_instance_valid(menu.loading_fill_bar):
		menu.loading_fill_bar.size.x = 336.0 * 0.65
	if is_instance_valid(menu.loading_pct_label):
		menu.loading_pct_label.text = "65%"
	if is_instance_valid(menu.loading_status_label):
		menu.loading_status_label.text = "LOADING ANCIENT ASSETS..."
	if is_instance_valid(menu.loading_container):
		menu.loading_container.modulate.a = 1.0
	if is_instance_valid(menu.fade_rect):
		menu.fade_rect.color.a = 0.0

	# Render 2 frames
	RenderingServer.frame_post_draw.connect(func():
		var img = vp.get_texture().get_image()
		if img:
			var save_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/loading_screen_bottom_bar.png"
			img.save_png(save_path)
			print("Saved loading screen snapshot to: ", save_path)
	, CONNECT_ONE_SHOT)

	# Give a short delay to trigger frame draw then proceed to next snapshot
	var timer = create_timer(0.20)
	timer.timeout.connect(func():
		menu.queue_free()
		_capture_comic_viewer(vp)
	)


func _capture_comic_viewer(vp: SubViewport) -> void:
	var viewer = ComicStoryViewerScript.new()
	vp.add_child(viewer)
	viewer.open_story(true)
	viewer.bg_rect.modulate.a = 1.0

	RenderingServer.frame_post_draw.connect(func():
		var img = vp.get_texture().get_image()
		if img:
			var save_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/haliya_comic_panel1_viewer.png"
			img.save_png(save_path)
			print("Saved comic panel snapshot to: ", save_path)
	, CONNECT_ONE_SHOT)

	var timer = create_timer(0.20)
	timer.timeout.connect(func():
		viewer.queue_free()
		_capture_main_menu_prologue_button(vp)
	)


func _capture_main_menu_prologue_button(vp: SubViewport) -> void:
	MainMenuScript.has_shown_splash = true
	var menu2 = MainMenuScript.new()
	vp.add_child(menu2)
	menu2._ready()
	menu2.fade_rect.color.a = 0.0

	RenderingServer.frame_post_draw.connect(func():
		var img = vp.get_texture().get_image()
		if img:
			var save_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/main_menu_prologue_button.png"
			img.save_png(save_path)
			print("Saved main menu snapshot to: ", save_path)
		quit(0)
	, CONNECT_ONE_SHOT)

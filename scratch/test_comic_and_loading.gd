extends SceneTree

const MainMenuScript = preload("res://scripts/main_menu.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")

func _init() -> void:
	print("==================================================")
	print("--- TESTING COMIC STRIP & ASSET LOADING FLOW ---")
	print("==================================================")

	var root = Control.new()
	root.size = Vector2(640, 360)
	get_root().add_child(root)

	# 1. Test ComicStoryViewer
	var viewer = ComicStoryViewerScript.new()
	root.add_child(viewer)

	assert(viewer.textures.size() == 9, "Comic must load all 9 panel textures")
	for i in range(9):
		assert(viewer.textures[i] != null, "Panel texture %d must be non-null" % i)
	print("PASS: All 9 Haliya comic strip panels loaded successfully")

	# Test opening story
	viewer.open_story(true)
	assert(viewer.visible == true, "Viewer must be visible when opened")
	assert(viewer.current_panel_idx == 0, "Initial panel must be 0")
	assert(viewer.page_label.text == "[ 1 / 9 ]", "Page label must read [ 1 / 9 ]")
	print("PASS: Comic viewer opened at Panel 1 with [ 1 / 9 ] indicator")

	# Test forward navigation
	viewer.next_panel()
	assert(viewer.current_panel_idx == 1, "Must advance to panel 1")
	assert(viewer.page_label.text == "[ 2 / 9 ]", "Page label must read [ 2 / 9 ]")
	print("PASS: Forward navigation advances to Panel 2 with [ 2 / 9 ] indicator")

	# Test backward navigation
	viewer.prev_panel()
	assert(viewer.current_panel_idx == 0, "Must return to panel 0")
	assert(viewer.page_label.text == "[ 1 / 9 ]", "Page label must read [ 1 / 9 ]")
	print("PASS: Backward navigation returns to Panel 1")

	# Test Skip / Close Story
	var story_finished: Array[bool] = [false]
	viewer.story_completed.connect(func(): story_finished[0] = true)
	viewer.close_story(true)
	assert(story_finished[0] == true, "Skipping story must emit story_completed")
	print("PASS: Skip button cleanly closes comic viewer and emits story_completed")
	viewer.queue_free()

	# 2. Test MainMenu Loading UI & Sequence
	var menu = MainMenuScript.new()
	root.add_child(menu)
	menu._ready()

	assert(menu.loading_container != null, "Loading container must exist")
	assert(menu.loading_fill_bar != null, "Loading fill bar must exist")
	assert(menu.loading_pct_label != null, "Loading percentage label must exist")
	assert(menu.loading_status_label != null, "Loading status label must exist")
	print("PASS: MainMenu 2-second loading UI components instantiated")

	# Test Prologue button in menu
	var found_prologue_btn = false
	for child in menu.menu_vbox.get_children():
		if child is Button and "PROLOGUE" in child.text:
			found_prologue_btn = true
			break
	assert(found_prologue_btn, "PROLOGUE button must be in menu_vbox")
	print("PASS: PROLOGUE CHRONICLES button present in Main Menu")

	# Test loading sequence activation
	menu._start_loading_sequence()
	assert(menu.is_loading_assets == true, "is_loading_assets must be true during loading")
	assert(menu.is_in_press_start == false, "is_in_press_start must be false during loading")
	assert(menu.loading_container.visible == true, "Loading container must be visible")
	print("PASS: _start_loading_sequence() properly activates loading state before Press Start")

	# Test morphing to Press Any Key
	menu._morph_loading_to_press_start()
	assert(menu.is_loading_assets == false, "is_loading_assets must be false after morph")
	print("PASS: _morph_loading_to_press_start() transitions cleanly to Press Start")

	menu.queue_free()

	print("==================================================")
	print("--- ALL COMIC & LOADING TESTS PASSED! ---")
	print("==================================================")
	quit(0)

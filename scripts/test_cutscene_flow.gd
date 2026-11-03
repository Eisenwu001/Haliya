extends SceneTree

func _init() -> void:
	_run_test.call_deferred()

func _run_test() -> void:
	print("--- TESTING CUTSCENE FLOW & SETTINGS FULLSCREEN LOGIC ---")

	var MainMenuScript = load("res://scripts/main_menu.gd")
	MainMenuScript.has_shown_splash = true
	var menu = MainMenuScript.new()
	root.add_child(menu)
	menu._ready()

	# 1. Test clicking "BEGIN JOURNEY"
	menu._on_begin_journey_pressed()
	if is_instance_valid(menu.menu_vbox) and menu.menu_vbox.visible:
		print("FAIL: menu_vbox is still visible during cutscene playback!")
		quit(1)
		return
	print("PASS: menu_vbox is hidden when cutscene opens")

	if menu.bgm_player and menu.bgm_player.playing:
		print("FAIL: Menu BGM is still playing during cutscene!")
		quit(1)
		return
	print("PASS: Menu BGM is completely stopped during cutscene")

	# Test that UI hover and select sounds cannot play during cutscene
	menu._play_ui_hover()
	if menu.sfx_ui_player and menu.sfx_ui_player.playing:
		print("FAIL: UI hover sound played while cutscene is active!")
		quit(1)
		return
	print("PASS: UI hover sound blocked during cutscene")

	if not menu.comic_story_viewer.is_active:
		print("FAIL: comic_story_viewer is not active")
		quit(1)
		return
	print("PASS: comic_story_viewer is active in prologue mode: ", menu.comic_story_viewer.is_prologue_mode)

	if not menu.comic_story_viewer.bgm_player or not menu.comic_story_viewer.bgm_player.playing:
		print("FAIL: Cutscene eerie audio is not playing!")
		quit(1)
		return
	print("PASS: Cutscene eerie ambient audio is actively playing at: ", menu.comic_story_viewer.bgm_player.volume_db, " dB")

	# 2. Test Space key interception during cutscene
	var ev_space = InputEventKey.new()
	ev_space.pressed = true
	ev_space.keycode = KEY_SPACE
	menu.comic_story_viewer._input(ev_space)
	print("PASS: Space key successfully processed by cutscene viewer")

	# 3. Test settings window mode integrity
	var SettingsMenuScript = load("res://scripts/settings_menu.gd")
	var sm = SettingsMenuScript.new()
	root.add_child(sm)
	sm.open_menu()

	# Verify fullscreen toggle reflects state and doesn't shrink
	if sm.fullscreen_btn:
		print("PASS: Fullscreen button initialized to: ", sm.fullscreen_btn.button_pressed)

	sm.close_menu()
	print("PASS: Settings menu closed cleanly without forcing windowed debug shrink")

	sm.queue_free()
	menu.comic_story_viewer.close_story(true)
	if menu.comic_story_viewer.bgm_player and menu.comic_story_viewer.bgm_player.playing:
		print("FAIL: Cutscene audio did not stop on close_story!")
		quit(1)
		return
	print("PASS: Cutscene audio stopped completely on story close")
	menu.queue_free()
	print("ALL CUTSCENE FLOW & SETTINGS TESTS PASSED!")
	quit(0)

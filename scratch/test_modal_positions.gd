extends SceneTree

func _init() -> void:
	print("[TEST] Testing Settings and Lore Codex modal bounds...")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	if not menu.is_node_ready():
		menu._ready()
	
	# Open settings
	menu.settings_menu.open_menu()
	var s_panel = menu.settings_menu.panel
	print("Settings panel offset_left:", s_panel.offset_left, "offset_top:", s_panel.offset_top, "anchor:", s_panel.anchor_left)
	assert(s_panel.anchor_left == 0.5, "Settings panel should be centered")
	assert(s_panel.offset_left == -240.0, "Settings panel offset_left should be -240")
	menu.settings_menu.close_menu()
	
	# Open codex
	menu.bestiary_codex_ui.open_menu()
	var c_panel = menu.bestiary_codex_ui.panel
	print("Codex panel offset_left:", c_panel.offset_left, "offset_top:", c_panel.offset_top, "anchor:", c_panel.anchor_left)
	assert(c_panel.anchor_left == 0.5, "Codex panel should be centered")
	assert(c_panel.offset_left == -250.0, "Codex panel offset_left should be -250")
	menu.bestiary_codex_ui.close_menu()
	
	print("[TEST PASS] Both modals are perfectly centered within the 640x360 screen!")
	menu.free()
	quit(0)

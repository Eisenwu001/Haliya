extends SceneTree

const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const UpgradeSelectUI = preload("res://scripts/upgrade_select_ui.gd")

func _init() -> void:
	print("[SNAPSHOT] Capturing visual verification snapshots...")
	
	# 1. Snapshot: Main Menu with Settings opened
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	if not menu.is_node_ready():
		menu._ready()
	menu.settings_menu.open_menu()
	save_viewport_snapshot("snapshot_menu_settings.png")
	menu.settings_menu.close_menu()
	
	# 2. Snapshot: Main Menu with Codex opened
	menu.bestiary_codex_ui.open_menu()
	save_viewport_snapshot("snapshot_menu_codex.png")
	menu.bestiary_codex_ui.close_menu()
	menu.free()
	
	# 3. Snapshot: Upgrade Selection Shrine with new pixel-art icons
	var ui = UpgradeSelectUI.new()
	root.add_child(ui)
	var drafted = UpgradeManager.draft_upgrades(3)
	ui.display_draft(drafted, 1)
	save_viewport_snapshot("snapshot_shrine_icons.png")
	ui.free()
	
	print("[SNAPSHOT PASS] Snapshots saved successfully!")
	quit(0)

func save_viewport_snapshot(filename: String) -> void:
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.save_png(filename)
		print("Saved: ", filename)

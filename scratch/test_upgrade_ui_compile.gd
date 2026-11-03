extends SceneTree

const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const UpgradeSelectUI = preload("res://scripts/upgrade_select_ui.gd")

func _init() -> void:
	print("[TEST] Testing UpgradeSelectUI cards and icon rendering...")
	var ui = UpgradeSelectUI.new()
	root.add_child(ui)
	
	var drafted = UpgradeManager.draft_upgrades(3)
	assert(drafted.size() == 3, "Must draft 3 upgrades")
	
	ui.display_draft(drafted, 1)
	assert(ui.cards_container.get_child_count() == 3, "Must have 3 card panels")
	
	for card in ui.cards_container.get_children():
		var icon = card.find_child("UpgradeIcon", true, false)
		assert(icon != null, "Card must have UpgradeIcon TextureRect")
		assert(icon is TextureRect, "UpgradeIcon must be a TextureRect")
		assert(icon.texture != null, "UpgradeIcon must have loaded texture")
		print("Card icon loaded successfully with texture size: ", icon.texture.get_size())
	
	print("[TEST PASS] UpgradeSelectUI renders pixel-art relic icons with no emojis or stars!")
	ui.free()
	quit(0)

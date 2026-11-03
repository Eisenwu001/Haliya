extends SceneTree

func _init() -> void:
	print("--- TESTING BOSS PHASE 2 PRESENTATION & FOE VANQUISHED CEREMONY ---")
	root.size = Vector2i(1280, 720)

	var MainScript = load("res://scripts/main.gd")
	if not MainScript:
		print("FAIL: Could not load main.gd")
		quit(1)
		return

	var main = MainScript.new()
	root.add_child(main)
	if not is_instance_valid(main.boss_hud_root):
		main.setup_boss_hud()

	# 1. Verify setup_boss_hud creates enraged badge
	if not is_instance_valid(main.boss_enraged_badge):
		print("FAIL: boss_enraged_badge not created")
		quit(1)
		return
	print("PASS: boss_enraged_badge created. Initial visibility: ", main.boss_enraged_badge.visible)

	# 2. Trigger Phase 2 transition
	main.active_encounter_type = "forest_brute"
	main._on_boss_phase_changed(2)

	if not main.boss_enraged_badge.visible:
		print("FAIL: boss_enraged_badge not visible after phase 2 change")
		quit(1)
		return
	print("PASS: boss_enraged_badge is visible and active on Phase 2!")
	print("PASS: Title text updated to: ", main.boss_title_label.text)
	print("PASS: Enraged flame pulse active on health bar: ", main.boss_fire_tween != null and main.boss_fire_tween.is_valid())

	# 3. Test Foe Vanquished Ceremony
	var callback_called = false
	var initial_pearls = main.pearls_collected_this_run
	main.show_foe_vanquished_ceremony("FOE VANQUISHED", 1500, func():
		callback_called = true
	)

	if not is_instance_valid(main.foe_vanquished_banner):
		print("FAIL: foe_vanquished_banner not created")
		quit(1)
		return
	print("PASS: foe_vanquished_banner created and visible: ", main.foe_vanquished_banner.visible)

	var banner_lbl = main.foe_vanquished_banner.get_node("CenterBand/TextVBox/BannerText") as Label
	var reward_lbl = main.foe_vanquished_banner.get_node("CenterBand/TextVBox/RewardText") as Label
	print("PASS: Banner Text: ", banner_lbl.text)
	print("PASS: Reward Text: ", reward_lbl.text)

	if main.pearls_collected_this_run != initial_pearls + 1500:
		print("FAIL: Pearls not awarded properly")
		quit(1)
		return
	print("PASS: Moon pearls awarded (+1,500). Total this run: ", main.pearls_collected_this_run)

	main.queue_free()
	print("ALL BOSS PRESENTATION & FOE VANQUISHED TESTS PASSED SUCCESSFULLY!")
	quit(0)

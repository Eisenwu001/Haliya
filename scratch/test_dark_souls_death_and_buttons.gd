extends SceneTree

const MainScript = preload("res://scripts/main.gd")
const GameOverUIScript = preload("res://scripts/game_over_ui.gd")

func _init() -> void:
	print("==================================================")
	print("--- TESTING DARK SOULS DEATH & BUTTON FIXES ---")
	print("==================================================")

	var root = Control.new()
	root.size = Vector2(640, 360)
	get_root().add_child(root)

	var game_over = GameOverUIScript.new()
	root.add_child(game_over)

	var test_stats = {
		"deepest_stage": "Forest Scene — Level 1-3: Corrupted Sentry Ridge",
		"kills": 8,
		"elapsed_sec": 58.0,
		"bosses_defeated": 0,
		"parries": 6,
		"pearls": 0,
		"stage_idx": 2,
		"upgrades": {}
	}
	game_over.display_defeat(test_stats)

	# 1. Verify "YOU DIED" Title & Rise Setup
	assert(game_over.title_lbl != null, "TitleLabel must exist")
	assert(game_over.title_lbl.text == "YOU DIED", "Title text must be 'YOU DIED'")
	print("PASS: Title is 'YOU DIED'")

	# 2. Verify Yellow Border Removed from Score Banner
	var score_banner = game_over.panel.find_child("ScoreBanner", true, false) as PanelContainer
	assert(score_banner != null, "ScoreBanner exists")
	var banner_sb = score_banner.get_theme_stylebox("panel") as StyleBoxFlat
	assert(banner_sb != null, "ScoreBanner StyleBox exists")
	assert(banner_sb.border_width_left == 0 and banner_sb.border_width_top == 0, "Yellow border must be 0 (removed)")
	print("PASS: Yellow border completely removed from Score Banner")

	# 3. Verify Button Text: "RISE AGAIN" only (no LEVEL 1-1)
	assert(game_over.btn_restart != null, "btn_restart exists")
	print("Restart button text: '%s'" % game_over.btn_restart.text)
	assert(not ("LEVEL" in game_over.btn_restart.text), "Must not have 'LEVEL' in text")
	assert(not ("(1-1)" in game_over.btn_restart.text), "Must not have '(1-1)' in text")
	assert("RISE AGAIN" in game_over.btn_restart.text, "Must have 'RISE AGAIN' in text")
	print("PASS: Restart button text is clean 'RISE AGAIN'")

	# 4. Verify Mouse Filters allow click penetration
	assert(game_over.center_container.mouse_filter == Control.MOUSE_FILTER_PASS, "center_container must be MOUSE_FILTER_PASS to allow button clicks")
	assert(game_over.panel.mouse_filter == Control.MOUSE_FILTER_PASS, "panel must be MOUSE_FILTER_PASS")
	assert(game_over.btn_row.mouse_filter == Control.MOUSE_FILTER_PASS, "btn_row must be MOUSE_FILTER_PASS")
	assert(game_over.btn_restart.mouse_filter == Control.MOUSE_FILTER_STOP, "btn_restart must be MOUSE_FILTER_STOP to capture clicks")
	assert(game_over.btn_menu.mouse_filter == Control.MOUSE_FILTER_STOP, "btn_menu must be MOUSE_FILTER_STOP to capture clicks")
	print("PASS: All container mouse filters properly configured for click transparency")

	# 5. Verify Button Signals work on click and Stage 1 disables clicks
	var restart_emitted: Array[bool] = [false]
	var menu_emitted: Array[bool] = [false]
	game_over.restart_run_requested.connect(func(): restart_emitted[0] = true)
	game_over.return_to_title_requested.connect(func(): menu_emitted[0] = true)

	# In Stage 1, buttons are disabled -> clicking should NOT trigger restart
	game_over.btn_restart.emit_signal("pressed")
	assert(not restart_emitted[0], "Stage 1: Disabled button must not trigger restart")
	print("PASS: Stage 1 properly ignores button clicks while 'YOU DIED' is rising")

	# In Stage 2, buttons become enabled -> clicking triggers restart
	game_over.btn_restart.disabled = false
	game_over.btn_restart.emit_signal("pressed")
	assert(restart_emitted[0], "Stage 2: Enabled RISE AGAIN button must emit restart_run_requested")
	print("PASS: Stage 2 clicking RISE AGAIN properly emits restart_run_requested")

	game_over.is_active = true
	game_over.btn_menu.disabled = false
	game_over.btn_menu.emit_signal("pressed")
	assert(menu_emitted[0], "Clicking RETURN TO TITLE must emit return_to_title_requested")
	print("PASS: Clicking RETURN TO TITLE properly emits return_to_title_requested")

	# Test reset() method
	game_over.reset()
	assert(not game_over.is_active and not game_over.visible, "reset() must deactivate and hide UI")
	print("PASS: GameOverUI reset() properly restores initial idle state")

	# 6. Verify Main.gd Scene Path for Return to Title exists
	var target_scene = "res://scenes/main_menu.tscn"
	assert(ResourceLoader.exists(target_scene), "Main menu target scene must exist: " + target_scene)
	print("PASS: Main menu scene res://scenes/main_menu.tscn exists and is loadable")

	# 7. Verify Main.gd Restart resets checkpoint
	var main_scene = MainScript.new()
	root.add_child(main_scene)
	main_scene.has_activated_boss_checkpoint = true
	main_scene._on_restart_run_requested()
	assert(main_scene.has_activated_boss_checkpoint == false, "Restarting run must clear boss checkpoint")
	print("PASS: _on_restart_run_requested properly resets checkpoint and starts fresh run")

	print("==================================================")
	print("--- ALL DARK SOULS DEATH & BUTTON TESTS PASSED ---")
	print("==================================================")
	quit(0)

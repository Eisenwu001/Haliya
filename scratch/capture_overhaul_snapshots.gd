extends SceneTree

var _ran: bool = false

func _process(delta: float) -> bool:
	if _ran:
		return true
	_ran = true

	# 1. Capture Game Over UI Screen
	var go_script = load("res://scripts/game_over_ui.gd")
	var go_ui = go_script.new()
	root.add_child(go_ui)

	var stats = {
		"deepest_stage": "Stage I: Forest Realm — Level 1-3",
		"kills": 32,
		"elapsed_sec": 248.0,
		"bosses_defeated": 1,
		"parries": 14,
		"pearls": 58,
		"stage_idx": 2,
		"upgrades": {"blade_sharpness": 2, "feather_dash": 1, "lunar_vitality": 2}
	}
	go_ui.display_defeat(stats)
	go_ui.overlay.modulate.a = 1.0 # Force full opacity immediately for snapshot

	# Let view render 2 frames
	create_timer(0.1).timeout.connect(func():
		var img = root.get_viewport().get_texture().get_image()
		if img:
			img.save_png("C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/game_over_centered_score_snapshot.png")
			print("Saved game_over_centered_score_snapshot.png")
		go_ui.queue_free()

		# 2. Capture Boss Health Bar
		_capture_boss_hud()
	)
	return true

func _capture_boss_hud() -> void:
	var main_script = load("res://scripts/main.gd")
	var main = main_script.new()
	root.add_child(main)

	var brute_script = load("res://scripts/forest_brute_miniboss.gd")
	var brute = brute_script.new()
	brute.name = "ForestBruteMiniboss"
	main.enemies_container.add_child(brute)
	main.active_enemies.append(brute)

	main.trigger_miniboss_arena_lockdown()
	main.boss_hud_root.modulate.a = 1.0

	create_timer(0.1).timeout.connect(func():
		var img = root.get_viewport().get_texture().get_image()
		if img:
			img.save_png("C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/boss_health_bar_snapshot.png")
			print("Saved boss_health_bar_snapshot.png")
		main.queue_free()
		quit(0)
	)

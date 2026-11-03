extends SceneTree

const GameOverUIScript = preload("res://scripts/game_over_ui.gd")

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)

	var game_over = GameOverUIScript.new()
	viewport.add_child(game_over)

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

	# Snapshot 2: Stage 2 (Stats & Actions revealed with buttons enabled)
	game_over.overlay.modulate.a = 1.0
	game_over.title_lbl.modulate.a = 1.0
	game_over.title_lbl.position = Vector2(0, 0)
	game_over.lore_lbl.modulate.a = 1.0
	game_over.stats_group.visible = true
	game_over.stats_group.modulate.a = 1.0
	game_over.btn_row.visible = true
	game_over.btn_row.modulate.a = 1.0
	game_over.btn_restart.disabled = false
	game_over.btn_menu.disabled = false

	for i in range(4):
		await process_frame

	var img2 = viewport.get_texture().get_image()
	if img2:
		img2.save_png("scratch/darksouls_stage2_stats_revealed.png")
		print("SUCCESS: Saved scratch/darksouls_stage2_stats_revealed.png")

	quit(0)

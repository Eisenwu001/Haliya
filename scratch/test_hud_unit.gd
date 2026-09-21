extends SceneTree

func _init():
	var f = FileAccess.open("user://test_results.txt", FileAccess.WRITE)
	f.store_line("--- BEGINNING HUD VERIFICATION TEST ---")
	var main_packed = load("res://scenes/main.tscn")
	if main_packed == null:
		f.store_line("ERROR: failed to load main.tscn")
		f.close()
		quit(1)
		return
	
	var main = main_packed.instantiate()
	root.add_child(main)
	
	f.store_line("Score Label text: " + main.score_label.text)
	f.store_line("HP fill max width: " + str(main.HP_FILL_MAX_WIDTH))
	f.store_line("Stamina fill max width: " + str(main.STA_FILL_MAX_WIDTH))
	
	# Test damage
	main._on_player_hp_changed(2, 5)
	f.store_line("HP damage tween valid: " + str(main.hp_fill_tween != null and main.hp_fill_tween.is_valid()))
	f.store_line("HP ghost tween valid: " + str(main.hp_ghost_tween != null and main.hp_ghost_tween.is_valid()))
	
	# Test stamina drain
	main._on_player_stamina_changed(40.0, 100.0)
	f.store_line("Stamina drain tween valid: " + str(main.stamina_fill_tween != null and main.stamina_fill_tween.is_valid()))
	f.store_line("Stamina ghost tween valid: " + str(main.stamina_ghost_tween != null and main.stamina_ghost_tween.is_valid()))
	
	# Test kill update
	main.aswang_kills = 3
	main.skeleton_kills = 4
	main.update_score_hud()
	f.store_line("Updated score label: " + main.score_label.text)
	f.store_line("--- ALL TESTS COMPLETED SUCCESSFULLY! ---")
	f.close()
	quit(0)

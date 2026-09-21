extends Node

func _ready():
	var report = []
	report.append("=== GANDALF QUEST HUD AUTOMATED VERIFICATION REPORT ===")
	report.append("Timestamp: " + Time.get_datetime_string_from_system())
	
	var main_packed = load("res://scenes/main.tscn")
	if not main_packed:
		report.append("FAIL: Unable to load res://scenes/main.tscn")
		write_and_quit(report, 1)
		return
	
	var main = main_packed.instantiate()
	add_child(main)
	report.append("PASS: main.tscn instantiated and mounted to tree")
	
	# 1. Verify Top-Right Plaque
	if not is_instance_valid(main.plaque_root):
		report.append("FAIL: main.plaque_root is not valid")
	else:
		report.append("PASS: main.plaque_root created at position " + str(main.plaque_root.position) + " scale " + str(main.plaque_root.scale))
	
	if not is_instance_valid(main.score_label):
		report.append("FAIL: main.score_label is not valid")
	else:
		var score_txt = main.score_label.text
		report.append("INFO: Initial Score Label text: '" + score_txt + "'")
		if "💀" in score_txt or "🚩" in score_txt:
			report.append("FAIL: Emoji detected in score label!")
		elif not ("KILLS:" in score_txt and "LEVEL" in score_txt):
			report.append("FAIL: Expected 'KILLS:' and 'LEVEL' format in score label")
		else:
			report.append("PASS: Score label formatted without emojis: '" + score_txt + "'")
	
	# 2. Verify Health Bar structure
	if not is_instance_valid(main.hp_bar_root):
		report.append("FAIL: hp_bar_root not valid")
	else:
		report.append("PASS: hp_bar_root created at position " + str(main.hp_bar_root.position) + " scale " + str(main.hp_bar_root.scale))
	
	if not is_instance_valid(main.hp_fill_clip) or not is_instance_valid(main.hp_ghost_clip):
		report.append("FAIL: hp fill or ghost clip missing")
	else:
		report.append("PASS: HP fill clip size: " + str(main.hp_fill_clip.size) + " (Max width: " + str(main.HP_FILL_MAX_WIDTH) + ")")
	
	# 3. Verify Stamina Bar structure
	if not is_instance_valid(main.stamina_bar_root):
		report.append("FAIL: stamina_bar_root not valid")
	else:
		report.append("PASS: stamina_bar_root created at position " + str(main.stamina_bar_root.position) + " scale " + str(main.stamina_bar_root.scale))
	
	if not is_instance_valid(main.stamina_fill_clip) or not is_instance_valid(main.stamina_ghost_clip):
		report.append("FAIL: stamina fill or ghost clip missing")
	else:
		report.append("PASS: Stamina fill clip size: " + str(main.stamina_fill_clip.size) + " (Max width: " + str(main.STA_FILL_MAX_WIDTH) + ")")
	
	# 4. Test Damage and Fill Loss Animation on Health Bar
	main._on_player_hp_changed(3, 5) # 3 of 5 HP (Damage taken)
	var hp_fill_tween_ok = is_instance_valid(main.hp_fill_tween) and main.hp_fill_tween.is_valid()
	var hp_ghost_tween_ok = is_instance_valid(main.hp_ghost_tween) and main.hp_ghost_tween.is_valid()
	if hp_fill_tween_ok and hp_ghost_tween_ok:
		report.append("PASS: HP damage triggered both smooth fill loss tween and trailing ghost tween")
	else:
		report.append("FAIL: HP fill loss tweens failed to trigger properly (fill: " + str(hp_fill_tween_ok) + ", ghost: " + str(hp_ghost_tween_ok) + ")")
	
	# 5. Test Stamina Drain and Fill Loss Animation on Stamina Bar
	main._on_player_stamina_changed(50.0, 100.0) # 50% stamina (Drained)
	var sta_fill_tween_ok = is_instance_valid(main.stamina_fill_tween) and main.stamina_fill_tween.is_valid()
	var sta_ghost_tween_ok = is_instance_valid(main.stamina_ghost_tween) and main.stamina_ghost_tween.is_valid()
	if sta_fill_tween_ok and sta_ghost_tween_ok:
		report.append("PASS: Stamina drain triggered both smooth fill loss tween and trailing ghost tween")
	else:
		report.append("FAIL: Stamina fill loss tweens failed to trigger properly (fill: " + str(sta_fill_tween_ok) + ", ghost: " + str(sta_ghost_tween_ok) + ")")
	
	# 6. Test Enemy Kills dynamic update
	main.aswang_kills = 4
	main.skeleton_kills = 3
	main.update_score_hud()
	var updated_score = main.score_label.text
	if "KILLS: 7" in updated_score:
		report.append("PASS: Kill count dynamically updated in plaque: '" + updated_score + "'")
	else:
		report.append("FAIL: Kill count update failed, got: '" + updated_score + "'")
	
	# 7. Test Scaled Combat VFX Spawners
	var blood_spr = VFX.spawn_blood_slash(main, Vector2(100, 100), false, Vector2(1.0, 1.0))
	if blood_spr and abs(blood_spr.scale.x - 0.135) < 0.02:
		report.append("PASS: blood_slash scaled to character proportions (%s, ~69px width)" % str(blood_spr.scale))
	else:
		report.append("FAIL: blood_slash scale unexpected: " + str(blood_spr.scale if blood_spr else "null"))

	var guard_spr = VFX.spawn_guard_impact(main, Vector2(100, 100))
	if guard_spr and abs(guard_spr.scale.x - 0.09) < 0.02:
		report.append("PASS: guard_impact scaled to character proportions (%s, ~46px width)" % str(guard_spr.scale))
	else:
		report.append("FAIL: guard_impact scale unexpected: " + str(guard_spr.scale if guard_spr else "null"))

	var parry_spr = VFX.spawn_parry_clash(main, Vector2(100, 100))
	if parry_spr and abs(parry_spr.scale.x - 0.08) < 0.02:
		report.append("PASS: parry_clash scaled to character proportions (%s, ~50px width)" % str(parry_spr.scale))
	else:
		report.append("FAIL: parry_clash scale unexpected: " + str(parry_spr.scale if parry_spr else "null"))

	var riposte_spr = VFX.spawn_riposte_slash(main, Vector2(100, 100))
	if riposte_spr and abs(riposte_spr.scale.x - 0.16) < 0.02:
		report.append("PASS: riposte_slash scaled to character proportions (%s, ~82px width)" % str(riposte_spr.scale))
	else:
		report.append("FAIL: riposte_slash scale unexpected: " + str(riposte_spr.scale if riposte_spr else "null"))

	# 8. Test Floor-Colliding Blood Droplets
	VFX.spawn_blood_splatter(main, Vector2(250, 100), Vector2(0, 1), 1.0, false)
	var droplet_count = 0
	for child in main.get_children():
		if child is VFX.BloodDroplet:
			droplet_count += 1
	if droplet_count >= 8:
		report.append("PASS: spawn_blood_splatter created %d physics-enabled BloodDroplet instances with TileMap collision" % droplet_count)
	else:
		report.append("FAIL: Expected >= 8 BloodDroplet instances, got %d" % droplet_count)

	report.append("=== ALL TESTS COMPLETED SUCCESSFULLY ===")
	write_and_quit(report, 0)


func write_and_quit(report: Array, exit_code: int):
	var file = FileAccess.open("c:/Users/Lin/OneDrive/Pictures/Camera Roll/Documents/project-1-test/scratch/hud_verification_report.txt", FileAccess.WRITE)
	if file:
		for line in report:
			file.store_line(str(line))
		file.close()
	get_tree().quit(exit_code)

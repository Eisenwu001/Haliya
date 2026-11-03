extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")
const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const MainScript = preload("res://scripts/main.gd")

var passed_count: int = 0
var failed_count: int = 0

func _init() -> void:
	print("\n==================================================")
	print("--- COMPREHENSIVE ARMOR SYSTEM TEST SUITE ---")
	print("==================================================")

	test_armor_capacity_and_ratio()
	test_armor_damage_absorption()
	test_armor_spillover_damage()
	test_armor_break_and_hp_vulnerability()
	test_hazard_damage_absorption()
	test_guard_chip_damage_absorption()
	test_armor_regen_delay_and_ticks()
	test_armor_regen_reset_on_damage()
	test_armor_max_cap()
	test_reset_combat_state()
	test_main_hud_integration()

	print("\n==================================================")
	if failed_count == 0:
		print("--- ALL %d ARMOR TESTS PASSED PERFECTLY! ---" % passed_count)
	else:
		print("--- %d PASSED, %d FAILED ---" % [passed_count, failed_count])
	print("==================================================\n")

	quit(1 if failed_count > 0 else 0)

func _assert(condition: bool, msg: String) -> void:
	if condition:
		passed_count += 1
		print("  [PASS] %s" % msg)
	else:
		failed_count += 1
		printerr("  [FAIL] %s" % msg)

func test_armor_capacity_and_ratio() -> void:
	print("\n[Test 1] Armor Capacity Scaling (2/3 of Max Health)...")
	var player = PlayerScript.new()
	player._ready()

	# Base HP is 5 -> round(5 * 2/3) = round(3.333) = 3
	_assert(player.get_max_hp() == 5, "Base Max HP should be 5")
	_assert(player.get_max_armor() == 3, "Base Max Armor must be 3 (2/3 of 5)")
	_assert(player.current_armor == 3, "Spawned player should start with full Armor (3/3)")

	# Bonus HP = 1 (Total 6) -> round(6 * 2/3) = 4
	player.bonus_max_hp = 1
	player.refresh_max_stats()
	_assert(player.get_max_hp() == 6, "Max HP increased to 6")
	_assert(player.get_max_armor() == 4, "Max Armor dynamically scales to 4 (2/3 of 6)")

	# Bonus HP = 4 (Total 9) -> round(9 * 2/3) = 6
	player.bonus_max_hp = 4
	player.refresh_max_stats()
	_assert(player.get_max_hp() == 9, "Max HP increased to 9")
	_assert(player.get_max_armor() == 6, "Max Armor dynamically scales to 6 (2/3 of 9)")
	player.free()

func test_armor_damage_absorption() -> void:
	print("\n[Test 2] Armor Damage Absorption (Overshield)...")
	var player = PlayerScript.new()
	player._ready()

	var armor_signals: Array = []
	player.armor_changed.connect(func(cur, max_arm): armor_signals.append([cur, max_arm]))

	# Take 1 damage: armor absorbs it completely, HP untouched
	player.take_damage(1)
	_assert(player.current_armor == 2, "Armor should absorb 1 damage (3 -> 2)")
	_assert(player.current_hp == 5, "Health remains intact at 5/5")
	_assert(armor_signals.size() == 1 and armor_signals[0][0] == 2, "armor_changed signal emitted (2, 3)")
	player.free()

func test_armor_spillover_damage() -> void:
	print("\n[Test 3] Armor Spillover Damage to Health...")
	var player = PlayerScript.new()
	player._ready()
	player.current_armor = 1 # 1 Armor, 5 HP

	# Attack deals 2 damage: 1 absorbed by armor, 1 carries over to HP
	player.take_damage(2)
	_assert(player.current_armor == 0, "Armor depleted to 0")
	_assert(player.current_hp == 4, "Remaining 1 damage spilled over into HP (5 -> 4)")
	player.free()

func test_armor_break_and_hp_vulnerability() -> void:
	print("\n[Test 4] Armor Depletion & Subsequent Damage...")
	var player = PlayerScript.new()
	player._ready()
	player.current_armor = 0 # Armor fully broken

	player.take_damage(2)
	_assert(player.current_armor == 0, "Armor stays at 0")
	_assert(player.current_hp == 3, "Direct hit damages HP when armor is 0 (5 -> 3)")
	player.free()

func test_hazard_damage_absorption() -> void:
	print("\n[Test 5] Environmental Hazard Damage to Armor...")
	var player = PlayerScript.new()
	player._ready()

	# Falling into pit / hazard calls respawn_at_safe_ledge(1)
	player.respawn_at_safe_ledge(1)
	_assert(player.current_armor == 2, "Hazard depletes 1 Armor before touching HP")
	_assert(player.current_hp == 5, "Health remains intact after hazard absorption")
	player.free()

func test_guard_chip_damage_absorption() -> void:
	print("\n[Test 6] Imperfect Guard Chip Damage to Armor...")
	var player = PlayerScript.new()
	player._ready()
	player.current_state = player.State.GUARD
	player.is_facing_left = false
	player.guard_time_held = 0.50 # Past parry window (imperfect block)

	# Enemy hits from front (+1 chip damage)
	player.take_damage_from_enemy(2, -1.0, null)
	_assert(player.current_armor == 2, "Guard chip damage depletes Armor first (3 -> 2)")
	_assert(player.current_hp == 5, "Health remains protected behind armor while blocking")
	player.free()

func test_armor_regen_delay_and_ticks() -> void:
	print("\n[Test 7] 3-Second Passive Armor Regeneration...")
	var player = PlayerScript.new()
	player._ready()

	# Damage player to 1 armor
	player.take_damage(2)
	player.invulnerable_timer = 0.0
	_assert(player.current_armor == 1, "Armor starts at 1")
	_assert(player.armor_regen_timer == 3.0, "Regen delay set to 3.0s after damage")

	# Advance 1.5 seconds: no regen yet
	player._physics_process(1.5)
	_assert(player.current_armor == 1, "Armor unchanged after 1.5s (timer at 1.5s)")

	# Advance another 1.6 seconds (total 3.1s without damage): +1 armor tick!
	player._physics_process(1.6)
	_assert(player.current_armor == 2, "Armor regenerated +1 point after 3.0s without damage (1 -> 2)")

	# Advance another 3.0 seconds: +1 armor tick!
	player._physics_process(3.0)
	_assert(player.current_armor == 3, "Armor regenerated to full 3/3 after another 3.0s")
	player.free()

func test_armor_regen_reset_on_damage() -> void:
	print("\n[Test 8] Combat Hit Resets 3-Second Regen Delay...")
	var player = PlayerScript.new()
	player._ready()
	player.take_damage(1)
	player.invulnerable_timer = 0.0
	_assert(player.current_armor == 2, "Armor reduced to 2")

	# Wait 2.8 seconds (almost about to regen)
	player._physics_process(2.8)
	_assert(player.current_armor == 2, "Not regenerated yet at 2.8s")

	# Take another hit at 2.8s
	player.take_damage(1)
	player.invulnerable_timer = 0.0
	_assert(player.current_armor == 1, "Hit taken, armor reduced to 1")
	_assert(player.armor_regen_timer == 3.0, "Regen delay reset back to full 3.0s")

	# Advance 1.0s (total time 3.8s from start, but only 1.0s since last hit)
	player._physics_process(1.0)
	_assert(player.current_armor == 1, "Regen did NOT trigger early because cooldown was reset")
	player.free()

func test_armor_max_cap() -> void:
	print("\n[Test 9] Armor Regen Capped at Max Armor...")
	var player = PlayerScript.new()
	player._ready()
	_assert(player.current_armor == 3, "Full armor at 3")

	# Advance 10 seconds while full
	player._physics_process(10.0)
	_assert(player.current_armor == 3, "Armor cannot exceed maximum capacity (stays at 3)")
	player.free()

func test_reset_combat_state() -> void:
	print("\n[Test 10] Combat Reset / Checkpoint Replenishment...")
	var player = PlayerScript.new()
	player._ready()
	player.current_armor = 0
	player.current_hp = 1

	player.reset_combat_state(true)
	_assert(player.current_armor == player.get_max_armor(), "reset_combat_state(true) replenishes Armor to full")
	_assert(player.current_hp == player.get_max_hp(), "reset_combat_state(true) replenishes HP to full")
	player.free()

func test_main_hud_integration() -> void:
	print("\n[Test 11] Main HUD Shield Overlay Integration...")
	var main = MainScript.new()
	var hud_cont = Control.new()
	main.hud_container = hud_cont
	main.add_child(hud_cont)

	# Verify main has shield overlay variables
	_assert("hp_shield_clip" in main, "Main script has hp_shield_clip")
	_assert("hp_shield_tex" in main, "Main script has hp_shield_tex")
	_assert("hp_text_label" in main, "Main script has hp_text_label")

	# Call setup_ui()
	main.setup_ui()
	_assert(is_instance_valid(main.hp_shield_clip), "Shield overlay clip created inside health bar")
	_assert(is_instance_valid(main.hp_text_label), "Health & shield text label created in setup_ui")

	# Shield active: (+2) appended
	main._on_player_armor_changed(2, 3)
	_assert(main.hp_text_label.text == "HP  5 / 5  (+2)", "HUD displays shielded status: 'HP  5 / 5  (+2)'")

	# Shield depleted: returns to standard HP display
	main._on_player_armor_changed(0, 3)
	_assert(main.hp_text_label.text == "HP  5 / 5", "HUD displays unshielded status: 'HP  5 / 5'")
	main.free()

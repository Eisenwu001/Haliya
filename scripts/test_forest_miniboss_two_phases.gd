extends SceneTree

var _ran: bool = false

func _check(cond: bool, msg: String) -> void:
	if not cond:
		push_error("FAIL: " + msg)
		print("FAIL: " + msg)
		quit(1)

func _process(delta: float) -> bool:
	if _ran:
		return true
	_ran = true

	print("==================================================")
	print("--- FOREST MINIBOSS TWO-STAGE VALIDATION TEST ---")
	print("==================================================")

	var brute_script = load("res://scripts/forest_brute_miniboss.gd")
	_check(brute_script != null, "forest_brute_miniboss.gd must load successfully")

	var brute = brute_script.new()
	root.add_child(brute)

	# 1. Verify Nodes & Spritesheet Setup
	_check(brute.sprite != null, "Sprite2D must exist")
	_check(brute.sprite.hframes == 10 and brute.sprite.vframes == 9, "Sprite2D must have 10 cols x 9 rows (90 frames)")
	_check(brute.health == 112, "Initial health must be 112")
	_check(not brute.is_phase_2, "Must start in Phase 1 (without weapon)")
	_check(not brute.has_transitioned_to_phase_2, "Must not be transitioned initially")
	print("PASS: Miniboss initialized in Phase 1 (Barehanded, 112 HP, 10x9 grid)")

	# Track signals
	var hp_signal_received: Array[int] = [0]
	var phase_signal_received: Array[int] = [0]
	brute.boss_hp_changed.connect(func(cur, _max): hp_signal_received[0] = cur)
	brute.boss_phase_changed.connect(func(p): phase_signal_received[0] = p)

	# 2. Test Phase 1 Damage & 10% Threshold Trigger
	# Deal 80 damage (112 -> 32 HP)
	brute.take_damage(80, 1.0)
	_check(brute.health == 32, "Health should be 32 after 80 damage")
	_check(not brute.is_phase_2, "Should still be in Phase 1 at 32 HP (~28%)")
	_check(hp_signal_received[0] == 32, "boss_hp_changed signal should emit 32")

	# Deal 20 more damage (32 -> 12 HP, hitting <= 12, exactly 10% threshold!)
	brute.take_damage(20, 1.0)
	_check(brute.has_transitioned_to_phase_2, "Phase transition must trigger at 10% HP (<= 12 HP)")
	_check(brute.current_state == ForestBruteMiniboss.State.WEAPON_PICKUP_REGEN, "Must enter WEAPON_PICKUP_REGEN state")
	_check(brute.is_invulnerable, "Must be invulnerable during weapon pickup")
	print("PASS: 10% HP trigger successfully initiated weapon pickup & regen state!")

	# 3. Simulate Weapon Pickup & Health Regen
	# Advance physics process through the pickup sequence
	var total_time: float = 0.0
	while total_time < 2.5:
		brute._physics_process(0.1)
		total_time += 0.1

	_check(brute.is_phase_2, "Must now be in Phase 2 (Armed with weapon)")
	_check(brute.is_enraged, "Must be enraged in Phase 2")
	_check(phase_signal_received[0] == 2, "boss_phase_changed signal must have emitted 2")
	_check(not brute.is_invulnerable, "Must not be invulnerable after completing pickup")
	_check(brute.health == 112, "Health must have regenerated to full (112 HP), got %d" % brute.health)
	print("PASS: Weapon pickup completed! Health regenerated to full 112 HP and Phase 2 armed state active!")

	# 4. Test Phase 2 Combat & Final Defeat
	var died_signal_emitted: Array[bool] = [false]
	var miniboss_died_emitted: Array[bool] = [false]
	brute.aswang_died.connect(func(_e): died_signal_emitted[0] = true)
	brute.miniboss_died.connect(func(_e): miniboss_died_emitted[0] = true)

	# Take fatal damage in Phase 2 (112 damage)
	brute.take_damage(112, -1.0)
	_check(brute.is_dead, "Must be dead after taking fatal damage in Phase 2")
	_check(brute.current_state == ForestBruteMiniboss.State.DEATH, "Must enter DEATH state")
	_check(died_signal_emitted[0], "Must emit aswang_died signal")
	_check(miniboss_died_emitted[0], "Must emit miniboss_died signal")
	print("PASS: Phase 2 fatal defeat and complete death sequence triggered successfully!")

	brute.free()

	print("==================================================")
	print("--- ALL FOREST MINIBOSS TWO-STAGE TESTS PASSED! ---")
	print("==================================================")
	quit(0)
	return true

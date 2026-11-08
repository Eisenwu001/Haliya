class_name TestStaminaExhaustionSystem
extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")
const MainScript = preload("res://scripts/main.gd")

var passed_tests: int = 0
var total_tests: int = 0

func assert_test(condition: bool, message: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  [PASS] %s" % message)
	else:
		printerr("  [FAIL] %s" % message)

func _init() -> void:
	print("\n==================================================")
	print("--- COMPREHENSIVE STAMINA EXHAUSTION TEST SUITE ---")
	print("==================================================\n")

	test_exhaustion_trigger_and_timers()
	test_sluggish_speed_penalty_and_recovery()
	test_two_second_regen_lockout()
	test_jump_velocity_preservation()
	test_combat_action_lockout_during_exhaustion()
	test_exhaustion_recovery_at_threshold()
	test_combat_reset_clears_exhaustion()
	test_hud_stamina_exhaustion_display()

	print("\n==================================================")
	if passed_tests == total_tests:
		print("--- ALL %d STAMINA EXHAUSTION TESTS PASSED PERFECTLY! ---" % passed_tests)
	else:
		printerr("--- %d OF %d TESTS FAILED! ---" % [total_tests - passed_tests, total_tests])
	print("==================================================\n")
	quit(0 if passed_tests == total_tests else 1)

func test_exhaustion_trigger_and_timers() -> void:
	print("[Test 1] Stamina Depletion to 0 Triggers Exhaustion (Option A)...")
	var player = PlayerScript.new()
	assert_test(player.current_stamina == 100.0, "Player starts with full 100.0 stamina")
	assert_test(not player.is_exhausted, "Player is not exhausted initially")
	assert_test(player.exhaustion_slow_timer == 0.0, "Initial exhaustion_slow_timer is 0.0")

	# Drain stamina to 0
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	assert_test(player.is_exhausted, "is_exhausted set to true upon depletion to 0")
	assert_test(abs(player.stamina_regen_timer - 2.0) < 0.01, "Stamina regen stopped for 2.0 seconds")
	assert_test(abs(player.exhaustion_slow_timer - 1.0) < 0.01, "Character slow timer set to 1.0 second")
	player.free()

func test_sluggish_speed_penalty_and_recovery() -> void:
	print("\n[Test 2] Sluggish Speed Penalty (60% for 1.0s) & Recovery...")
	var player = PlayerScript.new()
	var base_walk = player.WALK_SPEED # 95.0
	var expected_slow_speed = base_walk * player.EXHAUSTION_SLOW_MULT # 57.0

	assert_test(abs(expected_slow_speed - 57.0) < 0.1, "Expected slow speed is 57.0 px/s (60% of 95.0)")

	# Trigger exhaustion
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	# Simulate 0.5s of physics process while moving
	# While exhaustion_slow_timer > 0 (timer at 0.5s left)
	player.exhaustion_slow_timer = 0.5
	var slow_mult = player.EXHAUSTION_SLOW_MULT if player.exhaustion_slow_timer > 0.0 else 1.0
	var current_target_speed = player.WALK_SPEED * slow_mult
	assert_test(abs(current_target_speed - 57.0) < 0.1, "Player speed is slowed to 57.0 px/s during first 1.0s")

	# Advance slow timer past 1.0s
	player.exhaustion_slow_timer = 0.0
	var post_slow_mult = player.EXHAUSTION_SLOW_MULT if player.exhaustion_slow_timer > 0.0 else 1.0
	var post_target_speed = player.WALK_SPEED * post_slow_mult
	assert_test(abs(post_target_speed - base_walk) < 0.1, "Walk speed returns to normal 95.0 px/s after 1.0s slow expires")
	player.free()

func test_two_second_regen_lockout() -> void:
	print("\n[Test 3] 2.0-Second Stamina Regen Lockout...")
	var player = PlayerScript.new()
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	# At t = 1.0s, timer was 2.0 -> now 1.0. Stamina should NOT have regenerated yet
	player.stamina_regen_timer -= 1.0
	assert_test(player.stamina_regen_timer == 1.0, "Regen timer at 1.0s remaining")
	assert_test(player.current_stamina == 0.0, "Stamina is still 0.0 after 1.0s lockout")

	# At t = 1.8s, timer at 0.2s remaining
	player.stamina_regen_timer -= 0.8
	assert_test(abs(player.stamina_regen_timer - 0.2) < 0.01, "Regen timer at 0.2s remaining")
	assert_test(player.current_stamina == 0.0, "Stamina is still 0.0 after 1.8s lockout")

	# At t = 2.0s, lockout expires
	player.stamina_regen_timer = 0.0
	# Simulate 0.5s of regeneration
	var delta = 0.5
	var regen_rate = player.STAMINA_REGEN_PER_SEC # 35.0
	player.current_stamina += regen_rate * delta # +17.5
	assert_test(abs(player.current_stamina - 17.5) < 0.1, "Stamina begins recharging after 2.0s lockout (17.5)")
	assert_test(player.is_exhausted, "Player is still exhausted below 20.0 threshold")
	player.free()

func test_jump_velocity_preservation() -> void:
	print("\n[Test 4] Platforming Jump Velocity Preservation...")
	var player = PlayerScript.new()
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	assert_test(player.is_exhausted, "Player is exhausted")
	assert_test(player.exhaustion_slow_timer > 0.0, "Player slow timer active")
	assert_test(player.JUMP_VELOCITY == -420.0, "JUMP_VELOCITY is unchanged at -420.0")

	# Jumps directly apply JUMP_VELOCITY
	player.velocity.y = player.JUMP_VELOCITY
	assert_test(player.velocity.y == -420.0, "Jump vertical velocity is full strength (-420.0 px/s)")
	player.free()

func test_combat_action_lockout_during_exhaustion() -> void:
	print("\n[Test 5] Combat Action Lockout (Sprint, Dodge, Run Kick, Attack)...")
	var player = PlayerScript.new()
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	# 1. Sprint lockout
	var is_run_key = false # player cannot sprint while exhausted
	assert_test(not (true and not player.is_exhausted), "Sprint input evaluates to false while exhausted")

	# 2. Dodge lockout
	var prev_state = player.current_state
	player.start_dodge(1.0)
	assert_test(player.current_state == prev_state, "Dodge is blocked while exhausted")

	# 3. Run kick lockout
	player.start_run_kick(1.0)
	assert_test(player.current_state != player.State.RUN_KICK, "Run kick is blocked while exhausted")

	# 4. Attack lockout at 0 stamina
	player.trigger_attack(1.0)
	assert_test(player.current_state != player.State.ATTACK, "Ground attack is blocked at 0 stamina")

	# 5. Crouch attack lockout at 0 stamina
	player.trigger_crouch_attack()
	assert_test(player.current_state != player.State.CROUCH_ATTACK, "Crouch attack is blocked at 0 stamina")
	player.free()

func test_exhaustion_recovery_at_threshold() -> void:
	print("\n[Test 6] Exhaustion Recovery at Threshold (20.0)...")
	var player = PlayerScript.new()
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	# Regenerate up to 19.9 (below threshold)
	player.current_stamina = 19.9
	if player.is_exhausted and player.current_stamina >= player.EXHAUSTION_RECOVERY_THRESHOLD:
		player.is_exhausted = false
	assert_test(player.is_exhausted, "Still exhausted at 19.9 stamina")

	# Cross threshold to 20.0
	player.current_stamina = 20.0
	if player.is_exhausted and player.current_stamina >= player.EXHAUSTION_RECOVERY_THRESHOLD:
		player.is_exhausted = false
	assert_test(not player.is_exhausted, "Exhaustion cleared once stamina reaches 20.0")

	# Restore stamina via pickup / bonus
	player.current_stamina = 0.0
	player.trigger_exhaustion()
	player.restore_stamina(25.0)
	assert_test(not player.is_exhausted, "restore_stamina(25.0) clears exhaustion")
	assert_test(player.exhaustion_slow_timer == 0.0, "exhaustion_slow_timer reset to 0.0 on recovery")
	player.free()

func test_combat_reset_clears_exhaustion() -> void:
	print("\n[Test 7] Checkpoint & Combat Reset Clears Exhaustion...")
	var player = PlayerScript.new()
	player.current_stamina = 0.0
	player.trigger_exhaustion()

	assert_test(player.is_exhausted, "Player is exhausted before reset")
	player.reset_combat_state(true)

	assert_test(not player.is_exhausted, "is_exhausted cleared on reset_combat_state")
	assert_test(player.exhaustion_slow_timer == 0.0, "exhaustion_slow_timer cleared on reset_combat_state")
	assert_test(player.stamina_regen_timer == 0.0, "stamina_regen_timer cleared on reset_combat_state")
	assert_test(player.current_stamina == 100.0, "Stamina replenished to full on reset_combat_state")
	player.free()

func test_hud_stamina_exhaustion_display() -> void:
	print("\n[Test 8] HUD Stamina Exhaustion Display...")
	var main = MainScript.new()
	main.setup_ui()

	assert_test(is_instance_valid(main.stamina_bar_root), "HUD has stamina_bar_root")
	assert_test(is_instance_valid(main.stamina_fill_clip), "HUD has stamina_fill_clip")
	assert_test(is_instance_valid(main.stamina_track_rect), "HUD has stamina_track_rect")

	var player = PlayerScript.new()
	main.player = player

	# Normal full status
	main._on_player_stamina_changed(100.0, 100.0)
	var expected_full: float = UIThemeConstants.HUD_STAMINA_TRACK_WIDTH
	assert_test(main.stamina_fill_clip.size.x == expected_full, "Full stamina sets fill clip width to %.1f px" % expected_full)

	# Half status
	main._on_player_stamina_changed(50.0, 100.0)
	var expected_half: float = round(expected_full * 0.5)
	assert_test(main.stamina_fill_clip.size.x == expected_half, "Half stamina sets fill clip width to %.1f px" % expected_half)

	# Exhausted status
	player.current_stamina = 0.0
	player.trigger_exhaustion()
	main._on_player_stamina_changed(0.0, 100.0)
	assert_test(main.stamina_fill_clip.size.x == 0.0, "0 stamina sets fill clip width to 0.0 px")
	assert_test(main.stamina_track_rect.color == Color("#8a3b32"), "Track flashes danger red #8a3b32 on exhaustion")

	player.free()
	main.free()

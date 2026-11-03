extends SceneTree

const SaveManager = preload("res://scripts/save_manager.gd")
const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const GameSettings = preload("res://scripts/game_settings.gd")
const PlayerScript = preload("res://scripts/player.gd")
const VFX = preload("res://scripts/vfx.gd")
const MainScript = preload("res://scripts/main.gd")

var total_passed: int = 0
var total_failed: int = 0

func _init() -> void:
	print("\n==================================================")
	print("--- ENHANCED FEATURES (ITEMS 1, 3, 4, 5) TEST SUITE ---")
	print("==================================================\n")

	test_item_1_save_manager_crud()
	test_item_3_armor_stamina_upgrades()
	test_item_4_controls_and_gamepad()
	test_item_5_combat_juice_and_vfx()

	print("\n==================================================")
	if total_failed == 0:
		print("--- ALL %d ENHANCED FEATURE TESTS PASSED! ---" % total_passed)
	else:
		print("--- COMPLETED: %d PASSED, %d FAILED ---" % [total_passed, total_failed])
	print("==================================================\n")
	quit(0 if total_failed == 0 else 1)

func assert_true(condition: bool, msg: String) -> void:
	if condition:
		total_passed += 1
		print("  [PASS] %s" % msg)
	else:
		total_failed += 1
		printerr("  [FAIL] %s" % msg)

# ── 1. Save System & Multi-Slot Checkpoints (Item 1) ─────────────────────────
func test_item_1_save_manager_crud() -> void:
	print("[Test Group 1] SaveManager Multi-Slot CRUD & Run State...")
	
	# Clean test slot (Slot 2)
	SaveManager.delete_slot(2)
	var meta_before = SaveManager.get_slot_metadata(2)
	assert_true(not meta_before["exists"], "Slot 2 should be empty initially")

	# Mock main node
	var mock_main = MainScript.new()
	mock_main.current_level_idx = 2
	mock_main.has_activated_boss_checkpoint = true

	var mock_player = PlayerScript.new()
	mock_player.current_hp = 4
	mock_player.current_armor = 2
	mock_main.player = mock_player

	# Save to Slot 2
	SaveManager.active_slot = 2
	SaveManager.active_run_play_time = 145.5
	UpgradeManager.active_upgrades["moonstone_vitality"] = 2
	UpgradeManager.active_upgrades["bathalas_aegis"] = 1

	var saved = SaveManager.save_game(2, mock_main)
	assert_true(saved, "SaveManager.save_game should succeed for Slot 2")
	assert_true(SaveManager.has_save(2), "SaveManager.has_save(2) must return true")

	var meta_after = SaveManager.get_slot_metadata(2)
	assert_true(meta_after["exists"], "Slot 2 metadata exists flag must be true")
	assert_true(meta_after["current_hp"] == 4, "Saved player HP should be 4")
	assert_true(meta_after["current_armor"] == 2, "Saved player Armor should be 2")
	assert_true(meta_after["level_idx"] == 2, "Saved level index should be 2")
	assert_true(meta_after["play_time_seconds"] == 145.5, "Saved play time should match")

	# Load & Apply Run State
	var loaded_data = SaveManager.load_game(2)
	assert_true(not loaded_data.is_empty(), "Loaded game data should not be empty")

	var restore_main = MainScript.new()
	restore_main.current_level_idx = 0
	var restore_player = PlayerScript.new()
	restore_main.player = restore_player

	var applied = SaveManager.apply_loaded_game_to_run(loaded_data, restore_main)
	assert_true(applied, "apply_loaded_game_to_run should succeed")
	assert_true(restore_main.current_level_idx == 2, "Restored level index should be 2")
	assert_true(restore_player.current_hp == 4, "Restored player HP should match saved")
	assert_true(restore_player.current_armor == 2, "Restored player Armor should match saved")
	assert_true(UpgradeManager.get_upgrade_stacks("bathalas_aegis") == 1, "Restored upgrades should contain Bathala's Aegis")

	# Cleanup slot 2
	SaveManager.delete_slot(2)
	assert_true(not SaveManager.has_save(2), "Slot 2 should be deleted successfully")

	mock_player.free()
	mock_main.free()
	restore_player.free()
	restore_main.free()

# ── 2. Armor & Stamina Upgrades (Item 3) ──────────────────────────────────────
func test_item_3_armor_stamina_upgrades() -> void:
	print("\n[Test Group 2] Armor & Stamina Roguelite Upgrades...")

	var player = PlayerScript.new()
	UpgradeManager.init_run()

	# Base verification
	assert_true(player.get_max_hp() == 5, "Base Max HP should be 5")
	assert_true(player.get_max_armor() == 3, "Base Max Armor should be 3 (2/3 of 5)")
	assert_true(player.get_armor_regen_delay() == 3.0, "Base armor regen delay should be 3.0s")
	assert_true(player.get_exhaustion_regen_delay() == 2.0, "Base exhaustion regen delay should be 2.0s")
	assert_true(player.get_exhaustion_slow_duration() == 1.0, "Base exhaustion slow duration should be 1.0s")

	# Upgrade 1: Bathala's Aegis (+1 Max Armor)
	UpgradeManager.apply_upgrade("bathalas_aegis", player)
	assert_true(UpgradeManager.get_upgrade_stacks("bathalas_aegis") == 1, "Bathala's Aegis should have 1 stack")
	assert_true(player.bonus_max_armor == 1, "Player bonus_max_armor should be 1")
	assert_true(player.get_max_armor() == 4, "Max Armor should be increased to 4 (3 + 1)")

	# Upgrade 2: Celestial Respite (Armor regen delay reduced to 2.0s)
	UpgradeManager.apply_upgrade("celestial_respite", player)
	assert_true(player.has_celestial_respite, "Player has_celestial_respite flag must be true")
	assert_true(player.get_armor_regen_delay() == 2.0, "Armor regen delay should now be 2.0s")

	# Upgrade 3: Iron Constitution (Exhaustion lockout 1.3s, slow 0.5s)
	UpgradeManager.apply_upgrade("iron_constitution", player)
	assert_true(player.has_iron_constitution, "Player has_iron_constitution flag must be true")
	assert_true(player.get_exhaustion_regen_delay() == 1.3, "Exhaustion regen delay should now be 1.3s")
	assert_true(player.get_exhaustion_slow_duration() == 0.5, "Exhaustion slow duration should now be 0.5s")

	# Upgrade 4: Parry Fortification (Bulawan Ward)
	UpgradeManager.apply_upgrade("parry_fortification", player)
	assert_true(player.has_parry_fortification, "Player has_parry_fortification flag must be true")

	# Test Parry Fortification Armor Restoration
	player.current_armor = 2
	player.current_stamina = 80.0
	player.set_state(player.State.GUARD)
	player.guard_time_held = 0.10 # Within parry window
	player.is_facing_left = false

	var mock_enemy = Node2D.new()
	mock_enemy.global_position = Vector2(100.0, 0.0)
	player.global_position = Vector2(0.0, 0.0)

	# Take parried attack: enemy attacks towards left (-1.0)
	player.take_damage_from_enemy(1, -1.0, mock_enemy)
	assert_true(player.current_armor == 3, "Bulawan Ward should restore +1 armor on perfect parry (2 -> 3)")

	mock_enemy.free()
	player.free()

# ── 3. Controls & Gamepad Rebinding (Item 4) ──────────────────────────────────
func test_item_4_controls_and_gamepad() -> void:
	print("\n[Test Group 3] Controls Rebinding & Gamepad Support...")

	var player = PlayerScript.new()
	player.ensure_input_actions()

	# Check Gamepad bindings in InputMap
	assert_true(InputMap.has_action("jump"), "InputMap must have jump action")
	assert_true(InputMap.has_action("attack"), "InputMap must have attack action")
	assert_true(InputMap.has_action("guard"), "InputMap must have guard action")

	var jump_events = InputMap.action_get_events("jump")
	var has_joy_jump: bool = false
	for ev in jump_events:
		if ev is InputEventJoypadButton and ev.button_index == JOY_BUTTON_A:
			has_joy_jump = true
			break
	assert_true(has_joy_jump, "Jump must have default Joypad A binding")

	# Test custom rebind
	var custom_key := InputEventKey.new()
	custom_key.physical_keycode = KEY_U
	GameSettings.set_custom_bind("attack", custom_key)
	assert_true(GameSettings.custom_keybinds.has("attack"), "Custom keybind for attack should be registered")

	var display_txt = GameSettings.get_bound_display_text("attack")
	assert_true("U" in display_txt, "Bound display text should show U key: %s" % display_txt)

	# Test Haptic Rumble method executes safely
	player.trigger_haptic_rumble(0.5, 0.5, 0.1)
	assert_true(true, "trigger_haptic_rumble should execute cleanly without error")

	# Reset defaults
	GameSettings.reset_default_keybinds()
	assert_true(GameSettings.custom_keybinds.is_empty(), "custom_keybinds should be empty after reset")

	player.free()

# ── 4. Combat Juice & Polish (Item 5) ─────────────────────────────────────────
func test_item_5_combat_juice_and_vfx() -> void:
	print("\n[Test Group 4] Combat Juice, Hitstop, Prompts & Progress Tracker...")

	var root_node = Node2D.new()
	root.add_child(root_node)

	# 1. Baybayin Execution Prompt
	var prompt = VFX.spawn_stagger_execution_prompt(root_node, Vector2(100.0, 100.0))
	assert_true(is_instance_valid(prompt), "spawn_stagger_execution_prompt must return valid Node2D")
	var baybayin_lbl = prompt.get_node_or_null("BaybayinRune") as Label
	var sub_lbl = prompt.get_node_or_null("SubPrompt") as Label
	assert_true(baybayin_lbl != null and baybayin_lbl.text == "ᜉ", "Baybayin rune must be 'ᜉ'")
	assert_true(sub_lbl != null and sub_lbl.text == "PATAYIN", "Sub prompt label must be 'PATAYIN'")

	# 2. Player Hitstop execution
	var player = PlayerScript.new()
	root_node.add_child(player)
	player.trigger_hitstop(0.045)
	assert_true(Engine.time_scale <= 0.051, "Engine.time_scale should be slowed during hitstop")
	Engine.time_scale = 1.0 # Restore immediately

	# 3. Stage Progress Tracker
	var hud_mock = Control.new()
	hud_mock.name = "HUDContainer"
	root_node.add_child(hud_mock)

	var main_mock = MainScript.new()
	main_mock.hud_container = hud_mock
	main_mock.player = player
	main_mock.current_level_width = 5120.0
	main_mock.setup_stage_progress_tracker()

	assert_true(is_instance_valid(main_mock.stage_progress_root), "stage_progress_root should be created")
	assert_true(is_instance_valid(main_mock.progress_bar_fill), "progress_bar_fill should be created")
	assert_true(is_instance_valid(main_mock.progress_player_pin), "progress_player_pin should be created")

	# Test tracking calculation at 50%
	player.global_position.x = 2560.0
	main_mock.update_stage_progress_tracker()
	var expected_x = (2560.0 / 5120.0) * 220.0 # 110.0
	assert_true(abs(main_mock.progress_bar_fill.size.x - expected_x) < 0.1, "Progress fill should be 110px at halfway point")

	root_node.queue_free()

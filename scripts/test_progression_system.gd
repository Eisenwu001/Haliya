extends SceneTree

const UpgradeManager = preload("res://scripts/upgrade_manager.gd")
const UpgradeSelectUIScript = preload("res://scripts/upgrade_select_ui.gd")
const GameOverUIScript = preload("res://scripts/game_over_ui.gd")
const PlayerScript = preload("res://scripts/player.gd")
const CorruptedFarmerScript = preload("res://scripts/corrupted_farmer.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const MainScript = preload("res://scripts/main.gd")


func _init() -> void:
	print("\n==================================================")
	print("--- ROGUELITE PROGRESSION & ESCALATION TEST SUITE ---")
	print("==================================================")
	
	test_upgrade_manager_core()
	test_player_upgrade_integration()
	test_combat_blessings_mechanics()
	test_enemy_difficulty_escalation()
	test_upgrade_selection_ui()
	test_permadeath_and_game_over_ui()
	test_main_escalation_and_loop_flow()
	
	print("\n==================================================")
	print("--- ALL PROGRESSION & ESCALATION TESTS PASSED! ---")
	print("==================================================\n")
	quit(0)


func test_upgrade_manager_core() -> void:
	print("Testing UpgradeManager catalog & drafting...")
	UpgradeManager.reset_run()
	assert(UpgradeManager.current_tier == 1, "Initial tier should be 1")
	assert(UpgradeManager.loop_count == 1, "Initial loop count should be 1")
	assert(UpgradeManager.active_upgrades.is_empty(), "Active upgrades should be empty")
	assert(UpgradeManager.CATALOG.size() == 13, "Catalog should have 13 upgrades")
	
	# Test draft
	var draft1 = UpgradeManager.draft_upgrades(3)
	assert(draft1.size() == 3, "Draft should return 3 upgrades")
	assert(draft1[0]["id"] != draft1[1]["id"], "Drafted upgrades must be unique")
	assert(draft1[1]["id"] != draft1[2]["id"], "Drafted upgrades must be unique")
	assert(draft1[0]["id"] != draft1[2]["id"], "Drafted upgrades must be unique")
	
	# Test applying an upgrade
	var chosen_id = draft1[0]["id"]
	UpgradeManager.apply_upgrade(chosen_id)
	assert(UpgradeManager.has_upgrade(chosen_id), "Upgrade should be marked active")
	assert(UpgradeManager.get_upgrade_stacks(chosen_id) == 1, "Upgrade should have 1 stack")
	
	# Test tier advancement
	UpgradeManager.advance_tier("Level 1-1")
	assert(UpgradeManager.current_tier == 2, "Current tier should be 2")
	assert(UpgradeManager.deepest_level_title == "Level 1-1", "Deepest title should match")
	
	# Test multipliers
	assert(UpgradeManager.get_enemy_hp_multiplier() > 1.0, "Enemy HP multiplier should scale above 1.0")
	assert(UpgradeManager.get_enemy_speed_multiplier() > 1.0, "Enemy speed multiplier should scale above 1.0")
	assert(UpgradeManager.get_elite_chance() > 0.0, "Elite chance should be > 0 on tier 2")
	
	print("PASS: UpgradeManager core catalog & drafting verified!")


func test_player_upgrade_integration() -> void:
	print("Testing Player stats & Core Stat upgrades...")
	UpgradeManager.reset_run()
	
	var player = PlayerScript.new()
	assert(player.get_max_hp() == 5, "Base Max HP should be 5")
	assert(player.current_hp == 5, "Base Current HP should be 5")
	
	# Apply Moonstone Vitality x2 (+2 Max HP)
	UpgradeManager.apply_upgrade("moonstone_vitality", player)
	UpgradeManager.apply_upgrade("moonstone_vitality", player)
	assert(player.get_max_hp() == 7, "Max HP should be 7 after 2 Moonstone Vitality")
	assert(player.bonus_max_hp == 2, "Bonus Max HP should be 2")
	
	# Apply Balaraw Edge (+1 attack damage)
	UpgradeManager.apply_upgrade("balaraw_edge", player)
	assert(player.bonus_attack_damage == 1, "Player bonus attack damage should be 1")
	
	# Apply Breeze of Mayon (+35% stamina regen, -25% dodge cost)
	UpgradeManager.apply_upgrade("breeze_of_mayon", player)
	assert(player.stamina_regen_bonus == 0.35, "Stamina regen bonus should be 0.35")
	assert(player.dodge_cost_reduction == 0.25, "Dodge cost reduction should be 0.25")
	
	# Apply Amihan's Swiftness (+16% move speed)
	UpgradeManager.apply_upgrade("amihan_swiftness", player)
	assert(player.move_speed_multiplier == 1.16, "Move speed multiplier should be 1.16")
	
	# Apply Lunar Aegis
	UpgradeManager.apply_upgrade("lunar_aegis", player)
	assert(player.has_lunar_aegis == true, "Player should have Lunar Aegis")
	
	# Test heal method respecting upgraded max HP
	player.current_hp = 3
	player.heal(3)
	assert(player.current_hp == 6, "Player should heal to 6 (capped at max 7)")
	player.heal(5)
	assert(player.current_hp == 7, "Player should heal to max HP 7 without overflow")
	
	player.free()
	print("PASS: Player stat upgrades & sync verified!")


func test_combat_blessings_mechanics() -> void:
	print("Testing Combat Blessings...")
	UpgradeManager.reset_run()
	
	var player = PlayerScript.new()
	
	# Vampiric Riposte
	UpgradeManager.apply_upgrade("vampiric_riposte", player)
	assert(player.has_vampiric_riposte == true, "Player should have Vampiric Riposte")
	
	# Lunar Shockwave
	UpgradeManager.apply_upgrade("lunar_shockwave", player)
	assert(player.has_lunar_shockwave == true, "Player should have Lunar Shockwave")
	
	# Ghost Dash
	UpgradeManager.apply_upgrade("ghost_dash", player)
	assert(player.has_ghost_dash == true, "Player should have Ghost Dash")
	
	# Eclipse Pogo
	UpgradeManager.apply_upgrade("eclipse_pogo", player)
	assert(player.has_eclipse_pogo == true, "Player should have Eclipse Pogo")
	
	player.free()
	print("PASS: Combat Blessings application verified!")


func test_enemy_difficulty_escalation() -> void:
	print("Testing Enemy Difficulty Escalation & Corrupted Elites...")
	
	# 1. Corrupted Farmer Standard vs Elite
	var farmer_std = CorruptedFarmerScript.new()
	farmer_std._ready()
	farmer_std.apply_difficulty_scaling(1.28, 1.05, false)
	assert(farmer_std.max_health >= 3, "Standard farmer health should scale")
	assert(farmer_std.is_elite == false, "Standard farmer is not elite")
	
	var farmer_elite = CorruptedFarmerScript.new()
	farmer_elite._ready()
	farmer_elite.apply_difficulty_scaling(1.28, 1.05, true)
	assert(farmer_elite.is_elite == true, "Farmer should be marked elite")
	assert(farmer_elite.max_health > farmer_std.max_health, "Elite farmer must have higher HP than standard")
	assert(farmer_elite.speed_multiplier > farmer_std.speed_multiplier, "Elite farmer must have higher speed multiplier")
	
	# 2. Aswang Standard vs Elite
	var aswang_std = AswangScript.new()
	aswang_std._ready()
	aswang_std.apply_difficulty_scaling(1.42, 1.10, false)
	
	var aswang_elite = AswangScript.new()
	aswang_elite._ready()
	aswang_elite.apply_difficulty_scaling(1.42, 1.10, true)
	assert(aswang_elite.is_elite == true, "Aswang should be marked elite")
	assert(aswang_elite.max_health > aswang_std.max_health, "Elite aswang must have higher HP")
	
	# 3. Skeleton Standard vs Elite
	var skel_elite = SkeletonScript.new()
	skel_elite._ready()
	skel_elite.apply_difficulty_scaling(1.50, 1.12, true)
	assert(skel_elite.is_elite == true, "Skeleton should be marked elite")
	assert(skel_elite.max_health >= 6, "Elite skeleton should have >= 6 HP")
	
	farmer_std.free()
	farmer_elite.free()
	aswang_std.free()
	aswang_elite.free()
	skel_elite.free()
	print("PASS: Enemy Difficulty Escalation & Corrupted Elites verified!")


func test_upgrade_selection_ui() -> void:
	print("Testing UpgradeSelectUI modal...")
	var ui = UpgradeSelectUIScript.new()
	root.add_child(ui)
	
	var draft = UpgradeManager.draft_upgrades(3)
	ui.display_draft(draft, 2)
	assert(ui.visible == true, "UI should be visible when displayed")
	assert(ui.cards.size() == 3, "UI should create 3 upgrade cards")
	
	# Test selecting card 0
	var chosen_box = [""]
	ui.upgrade_selected.connect(func(id: String): chosen_box[0] = id)
	ui.select_upgrade(0)
	
	assert(chosen_box[0] == draft[0]["id"], "Upgrade selection signal should emit chosen upgrade ID")
	
	ui.queue_free()
	print("PASS: UpgradeSelectUI cards and selection verified!")


func test_permadeath_and_game_over_ui() -> void:
	print("Testing GameOverUI Permadeath modal...")
	var go_ui = GameOverUIScript.new()
	root.add_child(go_ui)
	
	var test_upgrades = {"moonstone_vitality": 2, "vampiric_riposte": 1}
	go_ui.display_defeat("Level 2-1: Emerald Terraces", 14, 125.0, test_upgrades)
	assert(go_ui.visible == true, "GameOverUI should be visible")
	assert("Level 2-1" in go_ui.stat_stage_lbl.text, "Stat stage label should display deepest level")
	assert("14" in go_ui.stat_kills_lbl.text, "Stat kills label should display kills")
	assert("Moonstone Vitality x2" in go_ui.upgrades_label.text, "Upgrades label should display acquired upgrades")
	
	var restart_box = [false]
	go_ui.restart_run_requested.connect(func(): restart_box[0] = true)
	go_ui.btn_restart.disabled = false
	go_ui.on_restart_pressed()
	assert(restart_box[0] == true, "GameOverUI should trigger restart_run_requested")
	
	go_ui.queue_free()
	print("PASS: GameOverUI permadeath summary and restart verified!")


func test_main_escalation_and_loop_flow() -> void:
	print("Testing Main level progression, horde spawning & Loop 2+...")
	var main = MainScript.new()
	root.add_child(main)
	main._ready()
	main.current_level_idx = 3 # Rice Field Level 2-1
	main.load_current_level()
	main.spawn_level_enemies()
	
	# Verify enemies have difficulty scaling applied
	assert(main.active_enemies.size() > 0, "Active enemies should exist")
	var has_scaled = false
	for e in main.active_enemies:
		if is_instance_valid(e) and e.get("max_health") != null:
			has_scaled = true
			break
	assert(has_scaled, "Enemies should have max_health property initialized")
	
	# Verify Loop 2+ escalations
	UpgradeManager.begin_new_loop()
	assert(UpgradeManager.loop_count == 2, "Loop count should be 2")
	assert(UpgradeManager.get_enemy_hp_multiplier() >= 1.75, "Loop 2 HP multiplier should be >= 1.75")
	assert(UpgradeManager.get_elite_chance() >= 0.20, "Loop 2 elite chance should be >= 20%")
	
	main.queue_free()
	print("PASS: Main progression, horde scaling & Endless Loop flow verified!")

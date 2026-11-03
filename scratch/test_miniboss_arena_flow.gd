extends Node2D

const MainScript = preload("res://scripts/main.gd")
const ForestBruteClass = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardClass = preload("res://scripts/mayon_vanguard_miniboss.gd")

func _ready() -> void:
	print("=== Running Full In-Game Miniboss Arena Lockdown & Defeat Test ===")
	test_level_1_3_flow()

func test_level_1_3_flow() -> void:
	print("Testing Level 1-3 Arena Lockdown Flow...")
	var main = MainScript.new()
	main.start_level_idx = 2 # Level 1-3
	add_child(main)
	
	# Simulate 2 frames for ready and loading
	main._process(0.016)
	main._process(0.016)
	
	assert(main.current_level_idx == 2, "Should be on level index 2 (Level 1-3)")
	assert(main.player != null, "Player must be initialized")
	
	# Verify Forest Brute is present in active enemies
	var brute: ForestBruteClass = null
	for e in main.active_enemies:
		if e is ForestBruteClass:
			brute = e
			break
	assert(brute != null, "Level 1-3 must have active ForestBruteMiniboss")
	print("  ✓ Forest Brute present in level at position: %s" % str(brute.global_position))
	
	# Move player to x = 4150 (crossing into the final arena)
	main.player.global_position = Vector2(4150.0, 250.0)
	main._process(0.016)
	
	assert(main.is_miniboss_arena_locked == true, "Arena lockdown should be active when player reaches x >= 4050")
	assert(main.miniboss_rear_barrier != null, "Miniboss rear barrier must be spawned at x = 3980")
	assert(is_instance_valid(main.miniboss_rear_barrier), "Rear barrier must be valid node")
	print("  ✓ Arena Lockdown triggered: Rear Barrier active at x = %f" % main.miniboss_rear_barrier.global_position.x)
	
	# Defeat the miniboss
	print("  Defeating Forest Brute Miniboss...")
	brute.take_damage(999, 1.0)
	main._process(0.016)
	
	assert(main.miniboss_rear_barrier == null, "Miniboss rear barrier must be removed upon miniboss defeat")
	print("  ✓ Rear barrier removed, pathway unlocked!")
	
	main.queue_free()
	test_level_2_3_flow()

func test_level_2_3_flow() -> void:
	print("\nTesting Level 2-3 Arena Lockdown Flow...")
	var main = MainScript.new()
	main.start_level_idx = 5 # Level 2-3
	add_child(main)
	
	main._process(0.016)
	main._process(0.016)
	
	assert(main.current_level_idx == 5, "Should be on level index 5 (Level 2-3)")
	assert(main.player != null, "Player must be initialized")
	
	var vanguard: MayonVanguardClass = null
	for e in main.active_enemies:
		if e is MayonVanguardClass:
			vanguard = e
			break
	assert(vanguard != null, "Level 2-3 must have active MayonVanguardMiniboss")
	print("  ✓ Mayon Vanguard present in level at position: %s" % str(vanguard.global_position))
	
	# Move player to x = 4150
	main.player.global_position = Vector2(4150.0, 250.0)
	main._process(0.016)
	
	assert(main.is_miniboss_arena_locked == true, "Arena lockdown should be active for Mayon Vanguard")
	assert(main.miniboss_rear_barrier != null, "Rear barrier must be active")
	print("  ✓ Arena Lockdown triggered: Rear Barrier active at x = %f" % main.miniboss_rear_barrier.global_position.x)
	
	# Defeat Mayon Vanguard
	print("  Defeating Mayon Vanguard Miniboss...")
	vanguard.take_damage(999, 1.0)
	main._process(0.016)
	
	assert(main.miniboss_rear_barrier == null, "Rear barrier must be removed upon vanguard defeat")
	print("  ✓ Rear barrier removed, pathway unlocked!")
	
	main.queue_free()
	print("\n>>> IN-GAME MINIBOSS ARENA LOCKDOWN & VICTORY FLOW TEST PASSED! <<<")
	get_tree().quit()

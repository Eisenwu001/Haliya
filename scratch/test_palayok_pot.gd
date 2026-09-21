extends SceneTree

var frame: int = 0
var root_node: Node2D
var pot_intact: PalayokPot
var pot_cracked: PalayokPot

func _init() -> void:
	root_node = Node2D.new()
	root.add_child(root_node)

func _process(_delta: float) -> bool:
	frame += 1
	if frame == 2:
		print("========================================")
		print("RUNNING PALAYOK POT TEST SUITE")
		print("========================================")
		
		print("\n--- Test 1: Intact Pot Multi-Stage Destruction ---")
		pot_intact = PalayokPot.new()
		pot_intact.initial_state = PalayokPot.PotState.INTACT
		root_node.add_child(pot_intact)
		
		print("\n--- Test 2: Pre-Cracked Pot 1-Hit Destruction ---")
		pot_cracked = PalayokPot.new()
		pot_cracked.initial_state = PalayokPot.PotState.CRACKED
		root_node.add_child(pot_cracked)

	elif frame == 4:
		# _ready() has executed
		assert(pot_intact.current_state == PalayokPot.PotState.INTACT, "Pot should start INTACT")
		assert(pot_intact.is_broken == false, "Pot should not be broken initially")
		assert(pot_intact.sprite.texture == PalayokPot.TEX_INTACT, "Sprite should be TEX_INTACT")
		print("PASSED: Intact pot initialized correctly with TEX_INTACT")
		
		# Hit 1 on intact pot
		pot_intact.smash(Vector2.RIGHT)
		assert(pot_intact.current_state == PalayokPot.PotState.CRACKED, "Pot should transition to CRACKED on Hit 1")
		assert(pot_intact.is_broken == false, "Pot should NOT have is_broken=true on Hit 1")
		assert(not pot_intact.col_shape.disabled, "Collision should remain active after Hit 1")
		print("PASSED: Hit 1 transitioned to CRACKED, is_broken remains false, collision active")
		
		# Test cracked pot (1-hit break)
		assert(pot_cracked.current_state == PalayokPot.PotState.CRACKED, "Pot should start CRACKED")
		assert(pot_cracked.is_broken == false, "Pre-cracked pot should not be broken initially")
		assert(pot_cracked.sprite.texture == PalayokPot.TEX_CRACKED, "Sprite should be TEX_CRACKED")
		
		# Single hit breaks pre-cracked pot
		pot_cracked.smash(Vector2.RIGHT)
		assert(pot_cracked.is_broken == true, "Pre-cracked pot should break immediately on first hit")
		assert(pot_cracked.sprite.texture == PalayokPot.TEX_BURST, "Sprite should switch to TEX_BURST")
		print("PASSED: Pre-cracked pot shattered on 1st hit as expected")

	elif frame == 25:
		# After wobble tween (~0.2s = ~12 frames) finishes, deliver Hit 2
		pot_intact.smash(Vector2.RIGHT)
		assert(pot_intact.is_broken == true, "Pot should have is_broken=true after final hit")
		assert(pot_intact.col_shape.disabled, "Collision should be disabled after final hit")
		assert(pot_intact.sprite.texture == PalayokPot.TEX_BURST, "Sprite should switch to TEX_BURST on shatter")
		print("PASSED: Hit 2 shattered pot: is_broken=true, collision disabled, TEX_BURST active")

	elif frame == 28:
		print("\n--- Test 3: Auto-Randomization across Positions ---")
		var count_intact := 0
		var count_cracked := 0
		for i in range(10):
			var pot = PalayokPot.new()
			pot.initial_state = PalayokPot.PotState.AUTO_RANDOM
			pot.position = Vector2(i * 120.0 + 50.0, 200.0)
			root_node.add_child(pot)
			if pot.current_state == PalayokPot.PotState.INTACT:
				count_intact += 1
			elif pot.current_state == PalayokPot.PotState.CRACKED:
				count_cracked += 1
		
		print("Spawned 10 random pots -> Intact: %d, Cracked: %d" % [count_intact, count_cracked])
		assert(count_intact > 0 and count_cracked > 0, "Both Intact and Cracked pots should appear naturally")
		print("PASSED: Auto-randomization creates healthy mix of both states")

	elif frame == 30:
		print("\n--- Test 4: Existing Level Scenes Integrity ---")
		var lvl22_res = load("res://scenes/rice_field/level_2_2.tscn")
		assert(lvl22_res != null, "level_2_2.tscn should load cleanly")
		var lvl22 = lvl22_res.instantiate()
		assert(lvl22 != null, "level_2_2 should instantiate")
		root_node.add_child(lvl22)
		
		var breakables = lvl22.get_node_or_null("Breakables")
		assert(breakables != null, "level_2_2 Breakables container exists")
		print("Found %d pots in level_2_2" % breakables.get_child_count())
		assert(breakables.get_child_count() > 0, "level_2_2 should have pots")
		for child in breakables.get_children():
			assert(child is PalayokPot, "Child should be PalayokPot instance")
			print("  -> %s state: %s" % [child.name, "INTACT" if child.current_state == PalayokPot.PotState.INTACT else "CRACKED"])
		
		lvl22.queue_free()
		
		var lvl23_res = load("res://scenes/rice_field/level_2_3.tscn")
		assert(lvl23_res != null, "level_2_3.tscn should load cleanly")
		var lvl23 = lvl23_res.instantiate()
		assert(lvl23 != null, "level_2_3 should instantiate")
		root_node.add_child(lvl23)
		var breakables_23 = lvl23.get_node_or_null("Breakables")
		assert(breakables_23 != null, "level_2_3 Breakables container exists")
		print("Found %d pots in level_2_3" % breakables_23.get_child_count())
		assert(breakables_23.get_child_count() > 0, "level_2_3 should have pots")
		for child in breakables_23.get_children():
			assert(child is PalayokPot, "Child should be PalayokPot instance")
			print("  -> %s state: %s" % [child.name, "INTACT" if child.current_state == PalayokPot.PotState.INTACT else "CRACKED"])
		
		lvl23.queue_free()
		print("PASSED: User scenes level_2_2 and level_2_3 load perfectly with new pot features")
		
		print("\n========================================")
		print("ALL PALAYOK POT TESTS PASSED SUCCESSFULLY!")
		print("========================================")
		quit(0)
	
	return false

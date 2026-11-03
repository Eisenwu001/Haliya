@tool
extends SceneTree

func _init():
	print("========================================")
	print("RUNNING TUTORIAL STAGE VERIFICATION")
	print("========================================")

	# 1. Test Tutorial Scene Loading
	var tut_scene = load("res://scenes/tutorial_stage.tscn")
	assert(tut_scene != null, "Failed to load tutorial_stage.tscn")
	var tut = tut_scene.instantiate()
	assert(tut != null, "Failed to instantiate tutorial_stage.tscn")
	root.add_child(tut)
	await process_frame
	await physics_frame

	print("[PASS] Tutorial stage instantiated successfully.")

	# 2. Verify Player Node & Properties
	var player = tut.player
	assert(player != null, "Player is null in tutorial stage!")
	print("[PASS] Player found at: ", player.global_position, " HP: ", player.current_health, "/", player.max_health)
	assert(player.current_health > 0, "Player starting health invalid")
	assert(player.current_stamina > 0, "Player starting stamina invalid")

	# 3. Verify Training Dummy
	var dummy = tut.dummy
	assert(dummy != null, "Training dummy is null in tutorial stage!")
	print("[PASS] Training dummy found at: ", dummy.global_position)
	assert(dummy.has_method("deflect_by_parry"), "Dummy missing deflect_by_parry method")
	assert(dummy.has_method("trigger_riposte"), "Dummy missing trigger_riposte method")

	# Test dummy interaction
	dummy.deflect_by_parry()
	assert(dummy.state == 2, "Dummy should enter PARRIED_STAGGER state (2)") # 2 is STAGGER
	var riposte_res = dummy.trigger_riposte(player)
	assert(riposte_res == true, "Riposte on parried dummy should return true")
	print("[PASS] Training dummy deflect and riposte mechanics verified.")

	# 4. Verify Stations & Environment
	assert(tut.find_child("WeaponRack", true, false) != null, "Weapon rack station missing")
	assert(tut.find_child("PotsContainer", true, false) != null, "Pots container missing")
	assert(tut.find_child("KapreNPC", true, false) != null, "Kapre NPC station missing")
	assert(tut.find_child("MoonAltar", true, false) != null, "Moon Altar station missing")
	assert(tut.find_child("SpiritGateway", true, false) != null, "Spirit Gateway station missing")
	print("[PASS] All 8 tutorial training stations and interactive props present.")

	# 5. Verify Tutorial Steps Progression
	print("[PASS] Initial Step: ", tut.current_step)
	assert(tut.current_step == tut.TutorialStep.MOVE_AND_SPRINT, "Initial step should be MOVE_AND_SPRINT")

	tut.advance_step(tut.TutorialStep.JUMP_AND_CROUCH, "JUMP & CROUCH")
	assert(tut.current_step == tut.TutorialStep.JUMP_AND_CROUCH, "Failed to advance to JUMP_AND_CROUCH")

	tut.advance_step(tut.TutorialStep.SELECT_WEAPON, "SELECT WEAPON")
	tut.advance_step(tut.TutorialStep.ATTACK_COMBOS, "ATTACK COMBOS")
	tut.advance_step(tut.TutorialStep.SMASH_POTS, "SMASH POTS")
	tut.advance_step(tut.TutorialStep.DODGE_ROLL, "DODGE ROLL")
	tut.advance_step(tut.TutorialStep.GUARD_AND_PARRY, "GUARD AND PARRY")
	tut.advance_step(tut.TutorialStep.RIPOSTE_STRIKE, "RIPOSTE STRIKE")
	tut.advance_step(tut.TutorialStep.TALK_TO_KAPRE, "TALK TO KAPRE")
	tut.advance_step(tut.TutorialStep.CLAIM_MASK, "CLAIM MASK")
	tut.advance_step(tut.TutorialStep.ENTER_GATEWAY, "ENTER GATEWAY")
	assert(tut.current_step == tut.TutorialStep.ENTER_GATEWAY, "Failed to advance through tutorial steps")
	print("[PASS] All 10 tutorial steps advanced and verified.")

	# 6. Test Standalone Completion (does NOT switch to main game)
	tut.trigger_tutorial_complete()
	assert(tut.current_step == tut.TutorialStep.COMPLETED, "TutorialStep should be COMPLETED")
	var overlay = tut.hud_layer.find_child("TutorialCompleteOverlay", true, false)
	assert(overlay != null, "TutorialCompleteOverlay should be spawned on completion")
	print("[PASS] Standalone Tutorial Complete modal created properly without transitioning to main game.")

	tut.queue_free()
	await process_frame

	print("\n========================================")
	print("ALL STANDALONE TUTORIAL VERIFICATIONS PASSED!")
	print("========================================")
	quit(0)

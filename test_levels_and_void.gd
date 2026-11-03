extends SceneTree

func _init() -> void:
	print("--- Running Verification Test ---")
	
	# 1. Test script compilation
	var main_script = load("res://scripts/main.gd")
	if not main_script:
		print("FAIL: main.gd failed to load")
		quit(1)
		return
	print("PASS: main.gd loaded successfully")

	var bakunawa_script = load("res://scripts/bakunawa_boss.gd")
	if not bakunawa_script:
		print("FAIL: bakunawa_boss.gd failed to load")
		quit(1)
		return
	print("PASS: bakunawa_boss.gd loaded successfully")

	# 2. Test scenes exist and load
	var lvl4_scene = load("res://scenes/cave/level_4.tscn")
	if not lvl4_scene or not (lvl4_scene is PackedScene):
		print("FAIL: level_4.tscn failed to load")
		quit(1)
		return
	var inst4 = lvl4_scene.instantiate()
	print("PASS: Level 4 instantiated successfully with %d children" % inst4.get_child_count())
	inst4.free()

	var lvl5_scene = load("res://scenes/cave/level_5.tscn")
	if not lvl5_scene or not (lvl5_scene is PackedScene):
		print("FAIL: level_5.tscn failed to load")
		quit(1)
		return
	var inst5 = lvl5_scene.instantiate()
	print("PASS: Level 5 instantiated successfully with %d children" % inst5.get_child_count())
	inst5.free()

	# 3. Test Bakunawa boss instantiation & mechanics
	var boss = bakunawa_script.new()
	print("PASS: Bakunawa boss created, max HP: %d" % boss.MAX_HEALTH)
	boss.take_damage(15, 1.0)
	print("PASS: Bakunawa boss took 15 damage, current HP: %d, Phase: %d" % [boss.health, boss.current_phase])
	boss.free()

	# 4. Test Skeleton void death
	var skel_script = load("res://scripts/skeleton.gd")
	var skel = skel_script.new()
	root.add_child(skel)
	skel.global_position = Vector2(500, 400) # Below 360
	var died_box = [false]
	skel.skeleton_died.connect(func(_s): died_box[0] = true)
	skel._physics_process(0.016)
	if died_box[0]:
		print("PASS: Skeleton void fall detected and died signal emitted!")
	else:
		print("FAIL: Skeleton void fall signal was not emitted")
		quit(1)
		return
	skel.free()

	# 5. Test Aswang void death
	var aswang_script = load("res://scripts/aswang.gd")
	var aswang = aswang_script.new()
	root.add_child(aswang)
	aswang.global_position = Vector2(500, 400) # Below 360
	var aswang_died_box = [false]
	aswang.aswang_died.connect(func(_a): aswang_died_box[0] = true)
	aswang._physics_process(0.016)
	if aswang_died_box[0]:
		print("PASS: Aswang void fall detected and died signal emitted!")
	else:
		print("FAIL: Aswang void fall signal was not emitted")
		quit(1)
		return
	aswang.free()

	print("--- ALL VERIFICATION TESTS PASSED ---")
	quit(0)

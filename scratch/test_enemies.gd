extends SceneTree

const AswangClass = preload("res://scripts/aswang.gd")
const SkeletonClass = preload("res://scripts/skeleton.gd")

func _init() -> void:
	_run_tests()

func _run_tests() -> void:
	print("[TEST] Initializing enemy tests...")
	var root_node = Node2D.new()
	root.add_child(root_node)

	# Test Aswang
	var aswang = AswangClass.new()
	root_node.add_child(aswang)
	await process_frame

	aswang.take_damage(1, 1.0)
	print("[TEST] Aswang health after 1 hit: ", aswang.health, " (expected 2)")
	assert(aswang.health == 2, "Aswang health mismatch")

	# Test Parried Stagger
	aswang.deflect_by_parry(-1.0)
	assert(aswang.is_stunned_vulnerable == true, "Aswang should be stunned vulnerable")

	# Test Riposte lethal hit
	aswang.take_damage(1, 1.0)
	print("[TEST] Aswang health after riposte: ", aswang.health, " (expected 0)")
	assert(aswang.health == 0, "Aswang riposte should kill")

	# Test Skeleton
	var skel = SkeletonClass.new()
	root_node.add_child(skel)
	await process_frame

	skel.take_damage(1, 1.0)
	print("[TEST] Skeleton health after 1 hit: ", skel.health, " (expected 3)")
	assert(skel.health == 3, "Skeleton health mismatch")

	skel.deflect_by_parry(-1.0)
	assert(skel.is_stunned_vulnerable == true, "Skeleton should be stunned vulnerable")

	skel.take_damage(1, 1.0)
	print("[TEST] Skeleton health after riposte: ", skel.health, " (expected 0)")
	assert(skel.health == 0, "Skeleton riposte should kill")

	print("[TEST] All enemy health pips and combat tests PASSED!")
	quit()

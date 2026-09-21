extends SceneTree

const AswangBossClass = preload("res://scripts/aswang_boss.gd")

func _init() -> void:
	_run_tests()

func _run_tests() -> void:
	print("[TEST] Initializing AswangBoss test...")
	var root_node = Node2D.new()
	root.add_child(root_node)

	var boss = AswangBossClass.new()
	root_node.add_child(boss)
	await process_frame

	print("[TEST] Boss initial health: ", boss.health, " / ", boss.MAX_HEALTH)
	assert(boss.health == 20, "Boss health should be 20")

	# Damage boss by 4
	boss.take_damage(4, 1.0)
	print("[TEST] Boss health after 4 dmg: ", boss.health, " (expected 16)")
	assert(boss.health == 16, "Boss health mismatch")

	# Parried stagger
	boss.deflect_by_parry(-1.0)
	assert(boss.is_stunned_vulnerable == true, "Boss should be stunned")

	# Riposte hit (should deal 4x damage = 1x4 = 4)
	boss.take_damage(1, 1.0)
	print("[TEST] Boss health after riposte: ", boss.health, " (expected 12)")
	assert(boss.health == 12, "Boss riposte damage mismatch")

	# Hit again to drop <= 10 and trigger enrage
	boss.take_damage(3, 1.0)
	print("[TEST] Boss health after enrage hit: ", boss.health, " (expected 9), phase: ", boss.current_phase)
	assert(boss.health == 9, "Boss health mismatch")
	assert(boss.current_phase == 2, "Boss should enter Phase 2")

	# Lethal blow
	boss.take_damage(10, 1.0)
	print("[TEST] Boss health after lethal blow: ", boss.health, " (expected 0), is_dead: ", boss.is_dead)
	assert(boss.health == 0, "Boss should be 0 hp")
	assert(boss.is_dead == true, "Boss should be dead")

	print("[TEST] AswangBoss tests PASSED successfully!")
	quit()

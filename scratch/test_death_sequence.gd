extends Node2D

const ForestBruteClass = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardClass = preload("res://scripts/mayon_vanguard_miniboss.gd")

func _ready() -> void:
	print("=== Running Death Sequence & Ground Pinning Verification ===")
	
	# Test Forest Brute Ground Pinning & Death
	var brute = ForestBruteClass.new()
	brute.global_position = Vector2(4450.0, 250.0)
	add_child(brute)
	
	var initial_y = brute.global_position.y
	brute.take_damage(999, 1.0)
	assert(brute.is_dead == true, "Must be flagged dead")
	assert(brute.is_physics_processing() == false, "Physics process must be stopped so gravity cannot pull into pit")
	assert(brute.velocity == Vector2.ZERO, "Velocity must be zeroed out")
	assert(brute.global_position.y == initial_y, "Must stay anchored at exact ground altitude")
	assert(brute.sprite.frame == 26, "Stage 1 death must be frame 26")
	print("  ✓ Forest Brute floor pinning verified: Y never falls, frame 26 active")
	brute.queue_free()
	
	# Test Mayon Vanguard Ground Pinning & Death
	var vanguard = MayonVanguardClass.new()
	vanguard.global_position = Vector2(4450.0, 250.0)
	add_child(vanguard)
	
	var v_initial_y = vanguard.global_position.y
	vanguard.take_damage(999, 1.0)
	assert(vanguard.is_dead == true, "Must be flagged dead")
	assert(vanguard.is_physics_processing() == false, "Physics process must be stopped so gravity cannot pull into pit")
	assert(vanguard.velocity == Vector2.ZERO, "Velocity must be zeroed out")
	assert(vanguard.global_position.y == v_initial_y, "Must stay anchored at exact ground altitude")
	assert(vanguard.sprite.frame == 26, "Stage 1 death must be frame 26")
	print("  ✓ Mayon Vanguard floor pinning verified: Y never falls, frame 26 active")
	vanguard.queue_free()
	
	print("\n>>> ALL MINIBOSS DEATH SEQUENCE & GROUND PINNING TESTS PASSED! <<<")
	get_tree().quit()

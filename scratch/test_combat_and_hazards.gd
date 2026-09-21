extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const PalayokPotScript = preload("res://scripts/palayok_pot.gd")
const PickupItemScript = preload("res://scripts/pickup_item.gd")
const WaterHazardScript = preload("res://scripts/water_hazard.gd")

var frame_count: int = 0
var test_root: Node2D
var player: CharacterBody2D
var pot: StaticBody2D
var skeleton: CharacterBody2D

func _init() -> void:
	test_root = Node2D.new()
	root.add_child(test_root)
	
	player = PlayerScript.new()
	player.global_position = Vector2(200.0, 300.0)
	test_root.add_child(player)
	
	pot = PalayokPotScript.new()
	pot.global_position = Vector2(300.0, 300.0)
	test_root.add_child(pot)
	
	skeleton = SkeletonScript.new()
	skeleton.global_position = Vector2(400.0, 300.0)
	test_root.add_child(skeleton)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count == 2:
		print("Starting combat & mechanics test on frame 2...")
		player.last_safe_ground_pos = Vector2(200.0, 300.0)
		
		# 1. Test water hazard ledge reset
		player.global_position = Vector2(250.0, 320.0)
		player.respawn_at_safe_ledge(1)
		assert(player.current_hp == Player.MAX_HEALTH - 1, "Player should take 1 damage from water hazard")
		assert(player.global_position == Vector2(200.0, 300.0), "Player should be restored to last safe ground pos")
		print("PASSED: Water hazard safe-ledge recovery")
		
		# Test healing pickup
		player.heal(1)
		assert(player.current_hp == Player.MAX_HEALTH, "Player should heal back to max health")
		print("PASSED: Player heal")
		
		# 2. Test Palayok Pot breaking and pickup drop
		pot.smash(Vector2(1.0, -0.5))
		assert(pot.is_broken == true, "Pot should be marked broken")
		
		var found_pickup = false
		for child in test_root.get_children():
			if child is PickupItem:
				found_pickup = true
				break
		assert(found_pickup, "Smashing pot must spawn a PickupItem")
		print("PASSED: Pot smash and pickup spawn")
		
		# 3. Test Skeleton Enemy combat and parry stagger
		skeleton.deflect_by_parry(1.0)
		assert(skeleton.current_state == Skeleton.State.PARRIED_STAGGER, "Skeleton should enter PARRIED_STAGGER on parry")
		assert(skeleton.is_stunned_vulnerable == true, "Skeleton should be stunned vulnerable")
		print("PASSED: Skeleton parry stagger")
		
		# Test damage and shatter death
		skeleton.take_damage(4, 1.0)
		assert(skeleton.is_dead == true, "Skeleton should die from lethal damage")
		assert(skeleton.current_state == Skeleton.State.DEATH, "Skeleton should be in DEATH state")
		print("PASSED: Skeleton shatter death")
		
		print("ALL COMBAT & MECHANICS TESTS PASSED!")
		quit(0)
	return false

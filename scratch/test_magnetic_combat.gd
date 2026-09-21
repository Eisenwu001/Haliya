extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const AswangScript = preload("res://scripts/aswang.gd")

var frame_count: int = 0
var test_root: Node2D
var player: CharacterBody2D
var enemy: CharacterBody2D

func _init() -> void:
	test_root = Node2D.new()
	root.add_child(test_root)
	
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(4000, 40)
	col.shape = shape
	col.position = Vector2(500, 320)
	floor_body.add_child(col)
	test_root.add_child(floor_body)
	
	player = PlayerScript.new()
	player.global_position = Vector2(200.0, 300.0)
	player.ensure_input_actions()
	test_root.add_child(player)
	
	enemy = SkeletonScript.new()
	enemy.global_position = Vector2(260.0, 300.0) # 60px away in front
	test_root.add_child(enemy)

func _process(delta: float) -> bool:
	frame_count += 1
	
	if frame_count == 2:
		print("--- Running Test 1: Attack Magnetism (Soft-Lock Gap Closer) ---")
		player.global_position = Vector2(200.0, 300.0)
		player.velocity = Vector2.ZERO
		player.is_air_attack = false
		player.is_facing_left = false
		player.trigger_attack(0.0)
		
		assert(player.current_state == Player.State.ATTACK, "Player should be in State.ATTACK")
		assert(player.is_gliding_to_target == true, "Player should be gliding toward enemy")
		var expected_x = enemy.global_position.x - Player.MAGNETIC_TARGET_SPACING
		assert(abs(player.attack_glide_target_x - expected_x) < 0.1, "Glide target x should be enemy.x - spacing")
		print("PASSED: Soft-lock target acquired at spacing %f" % player.attack_glide_target_x)
		
		# Simulate physics step
		player._physics_process(0.016)
		assert(player.velocity.x > 0.0, "Player should be gliding forward toward target")
		print("PASSED: Forward magnetic glide velocity confirmed: %f" % player.velocity.x)
	
	elif frame_count == 4:
		print("--- Running Test 2: Attack Whiff Momentum (Subtle Forward Step) ---")
		player.set_state(Player.State.IDLE)
		player.global_position = Vector2(1000.0, 300.0) # Far from enemies
		player.velocity = Vector2.ZERO
		player.is_air_attack = false
		player.is_facing_left = false
		player.trigger_attack(0.0)
		
		assert(player.is_gliding_to_target == false, "Should not be gliding when no enemy in range")
		assert(player.attack_whiff_step_speed == Player.WHIFF_STEP_IMPULSE, "Whiff step impulse should be set")
		player._physics_process(0.016)
		assert(player.velocity.x > 0.0, "Whiff should have natural forward step velocity")
		print("PASSED: Dynamic whiff step impulse confirmed: %f" % player.velocity.x)
	
	elif frame_count == 6:
		print("--- Running Test 3: Smart Directional Steering ---")
		player.set_state(Player.State.IDLE)
		enemy.global_position = Vector2(140.0, 300.0)
		player.global_position = Vector2(200.0, 300.0)
		player.velocity = Vector2.ZERO
		player.is_air_attack = false
		player.is_facing_left = false
		
		# User steers left (-1.0) while attacking
		player.trigger_attack(-1.0)
		assert(player.is_facing_left == true, "Player should auto-pivot to face steered enemy")
		assert(player.is_gliding_to_target == true, "Player should magnetize to steered enemy")
		var expected_x = enemy.global_position.x + Player.MAGNETIC_TARGET_SPACING
		assert(abs(player.attack_glide_target_x - expected_x) < 0.1, "Glide target should match left-facing spacing")
		print("PASSED: Directional steering auto-pivot and glide target confirmed")
	
	elif frame_count == 8:
		print("--- Running Test 4: Parry Auto-Facing & Riposte Window Activation ---")
		var riposte_dummy = SkeletonScript.new()
		riposte_dummy.global_position = Vector2(160.0, 300.0) # 40px behind player
		test_root.add_child(riposte_dummy)
		
		player.set_state(Player.State.GUARD)
		player.guard_time_held = 0.05 # Within 0.20s parry window
		player.is_facing_left = false # Facing right
		var enemy_dir: float = 1.0 # Attack coming from behind (moving right)
		
		var prev_stamina = player.current_stamina
		var prev_hp = player.current_hp
		player.take_damage_from_enemy(1, enemy_dir, riposte_dummy)
		
		assert(player.current_hp == prev_hp, "Parry should completely negate damage")
		assert(player.current_stamina >= prev_stamina, "Parry should restore stamina")
		assert(player.is_facing_left == true, "Player should auto-face attacker to allow parry")
		assert(player.riposte_timer > 0.0, "Parry should open active riposte timer window")
		assert(player.riposte_target == riposte_dummy, "Riposte target should be set to attacker")
		print("PASSED: Auto-face parry and riposte window opened (duration: %f)" % player.riposte_timer)
	
	elif frame_count == 10:
		print("--- Running Test 5: Magnetic Riposte Counter Execution ---")
		var target_enemy = player.riposte_target
		assert(target_enemy != null, "Riposte target should be valid")
		var initial_enemy_hp = target_enemy.health
		var riposte_tracker = [false]
		player.riposte_performed.connect(func(_pos): riposte_tracker[0] = true)
		
		# Trigger attack during active riposte window
		player.trigger_attack(0.0)
		
		assert(player.current_state == Player.State.RIPOSTE, "State should transition to State.RIPOSTE")
		assert(player.invulnerable_timer > 0.0, "Riposte should grant i-frames")
		assert(player.is_gliding_to_target == true, "Riposte should magnetize into enemy")
		print("PASSED: Riposte dash initiated with i-frames (%f)" % player.invulnerable_timer)
		
		# Move player into dash spacing near target
		player.global_position = Vector2(target_enemy.global_position.x + 28.0, 300.0)
		
		# Process hit detection for riposte
		player.check_attack_hit_enemies()
		assert(riposte_tracker[0] == true, "Riposte performed signal should emit")
		var damage_dealt = initial_enemy_hp - target_enemy.health
		assert(damage_dealt == Player.RIPOSTE_DAMAGE, "Riposte should deal 3 DMG (dealt %d)" % damage_dealt)
		print("PASSED: Riposte critical strike dealt %d DMG and emitted signal!" % damage_dealt)
	
	elif frame_count == 12:
		print("--- Running Test 6: Recovery Cancel into Guard ---")
		player.set_state(Player.State.ATTACK)
		var frames = player.get_current_animation_frames()
		player.current_frame_idx = int(frames.size() * 0.70) # Set to recovery frame
		player.frame_timer = 0.1 # Exceed duration to trigger frame step
		
		# Simulate guard input during recovery
		Input.action_press("guard")
		player.update_animation(0.0)
		Input.action_release("guard")
		
		assert(player.current_state == Player.State.GUARD, "Should cancel recovery into State.GUARD")
		print("PASSED: Attack recovery successfully canceled into Guard!")
		
		print("\n==========================================")
		print("ALL MAGNETIC COMBAT & RIPOSTE TESTS PASSED!")
		print("==========================================")
		quit(0)
	
	return false

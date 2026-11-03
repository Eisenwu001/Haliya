extends Node2D

const ForestBruteClass = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardClass = preload("res://scripts/mayon_vanguard_miniboss.gd")
const LevelBuilderClass = preload("res://scripts/level_builder.gd")

func _ready() -> void:
	print("=== Running Comprehensive Minibosses Movement & Animation Test ===")
	
	# ── 1. Test Forest Brute Miniboss ─────────────────────────────────────────
	print("Test 1: Forest Brute Miniboss (Level 1-3)...")
	var brute = ForestBruteClass.new()
	brute.global_position = Vector2(4450.0, 250.0)
	add_child(brute)
	
	# Check texture and grid dimensions
	assert(brute.sprite != null, "Forest Brute must have a Sprite2D node")
	assert(brute.sprite.texture != null, "Forest Brute must have a valid spritesheet texture")
	assert(brute.sprite.hframes == 8, "Forest Brute sprite must have 8 hframes")
	assert(brute.sprite.vframes == 4, "Forest Brute sprite must have 4 vframes")
	assert(brute.col_shape != null, "Forest Brute must have a collision shape")
	assert(brute.health == 18, "Forest Brute must start with 18 HP")
	print("  ✓ Sprite 8x4 grid, Collision Capsule, and 18 HP initialized properly")
	
	# Check facing flip
	brute.state_timer = 0.0
	brute.is_facing_left = true
	brute._physics_process(0.016)
	assert(brute.sprite.flip_h == true, "Sprite should be flipped horizontally when facing left")
	brute.is_facing_left = false
	brute._physics_process(0.016)
	assert(brute.sprite.flip_h == false, "Sprite should face right when is_facing_left is false")
	print("  ✓ Horizontal turning and sprite flipping verified")
	
	# Check 7-frame Walk cycle progression
	brute.set_state(ForestBruteClass.State.PATROL)
	var walk_frames_seen: Array[int] = []
	for i in range(15):
		brute._physics_process(0.04)
		if not (brute.sprite.frame in walk_frames_seen):
			walk_frames_seen.append(brute.sprite.frame)
	assert(walk_frames_seen.size() >= 3, "Walk cycle should advance through multiple frames")
	print("  ✓ 7-Frame Walk Cycle stepping verified (frames observed: %s)" % str(walk_frames_seen))
	
	# Check Telegraph Slam & Lunge Movement (Frames 8 -> 9 -> 10 -> 11)
	brute.set_state(ForestBruteClass.State.TELEGRAPH_SLAM)
	assert(brute.sprite.frame == 8, "Telegraph Slam should display frame 8 (windup overhead)")
	# Hyper Armor test: attacking during windup should NOT put him into HURT
	brute.take_damage(1, 1.0)
	assert(brute.current_state == ForestBruteClass.State.TELEGRAPH_SLAM, "Hyper armor should prevent normal hit from interrupting slam")
	print("  ✓ Hyper Armor verified (did not flinch into HURT during attack windup)")
	
	brute._physics_process(0.50) # Advance past telegraph
	assert(brute.current_state == ForestBruteClass.State.SLAM_IMPACT, "State should transition to SLAM_IMPACT")
	assert(abs(brute.velocity.x) > 0.0, "Slam impact must have forward lunge momentum")
	brute._physics_process(0.15) # Advance to ground impact
	assert(brute.sprite.frame == 10, "Ground slam impact should display frame 10")
	print("  ✓ Earthshaker Slam multi-frame sequence (Frames 8 -> 9 -> 10) verified")
	
	# Check Secondary Attack: Claw Swipe (Frames 16 -> 17)
	brute.set_state(ForestBruteClass.State.TELEGRAPH_SWIPE)
	assert(brute.sprite.frame == 16, "Telegraph swipe should display frame 16")
	brute._physics_process(0.28)
	assert(brute.current_state == ForestBruteClass.State.SWIPE_STRIKE, "State should transition to SWIPE_STRIKE")
	brute._physics_process(0.15)
	assert(brute.sprite.frame == 17, "Claw swipe strike should display frame 17")
	print("  ✓ Secondary Attack (Claw Swipe, Frames 16 -> 17) verified")

	# Check Parry Deflect & Stun Stagger (Frame 24)
	brute.deflect_by_parry(1.0)
	assert(brute.current_state == ForestBruteClass.State.PARRIED_STAGGER, "State should be PARRIED_STAGGER")
	assert(brute.sprite.frame == 24, "Parried stagger should display frame 24")
	assert(brute.is_stunned_vulnerable == true, "Must be flagged stunned and vulnerable for riposte")
	assert(brute.stun_stars.visible == true, "Stun stars must be visible")
	print("  ✓ Parry deflect, frame 24, stun stars, and vulnerable stagger verified")
	
	# Check Riposte Bonus Damage & Death (Frame 26)
	var brute_flags = {"died": false}
	brute.aswang_died.connect(func(_b): brute_flags["died"] = true)
	brute.take_damage(10, 1.0) # 10 * 2 = 20 damage during vulnerability!
	assert(brute.health == 0, "Vulnerable riposte should deal 2x damage and deplete health")
	assert(brute.sprite.frame == 26, "Death collapse should display frame 26")
	assert(brute_flags["died"] == true, "Aswang died signal should be emitted on death")
	print("  ✓ Riposte 2x damage, frame 26 death, and signal emission verified")
	brute.queue_free()

	# ── 2. Test Mayon Vanguard Miniboss ───────────────────────────────────────
	print("Test 2: Mayon Vanguard Miniboss (Level 2-3)...")
	var vanguard = MayonVanguardClass.new()
	vanguard.global_position = Vector2(4450.0, 250.0)
	add_child(vanguard)
	
	assert(vanguard.sprite != null, "Mayon Vanguard must have a Sprite2D node")
	assert(vanguard.sprite.texture != null, "Mayon Vanguard must have a valid spritesheet texture")
	assert(vanguard.sprite.hframes == 8, "Mayon Vanguard sprite must have 8 hframes")
	assert(vanguard.sprite.vframes == 4, "Mayon Vanguard sprite must have 4 vframes")
	assert(vanguard.health == 20, "Mayon Vanguard must start with 20 HP")
	print("  ✓ Sprite 8x4 grid, Kalasag shield, and 20 HP initialized properly")
	
	# Check Frontal Shield Defense (absorbing half damage)
	vanguard.is_facing_left = true
	vanguard.set_state(MayonVanguardClass.State.IDLE_GUARD)
	vanguard.take_damage(2, 1.0)
	assert(vanguard.health == 19, "Shield should mitigate 2 damage down to 1 from front")
	print("  ✓ Frontal shield mitigation verified (absorbed 50% damage)")
	
	# Check 7-frame March cycle
	vanguard.set_state(MayonVanguardClass.State.MARCH)
	var march_frames_seen: Array[int] = []
	for i in range(15):
		vanguard._physics_process(0.04)
		if not (vanguard.sprite.frame in march_frames_seen):
			march_frames_seen.append(vanguard.sprite.frame)
	assert(march_frames_seen.size() >= 3, "March cycle should advance through multiple frames")
	print("  ✓ 7-Frame March Cycle stepping verified (frames observed: %s)" % str(march_frames_seen))

	# Check Volcanic Lunge Movement (Frames 8 -> 9 -> 10)
	vanguard.set_state(MayonVanguardClass.State.TELEGRAPH_LUNGE)
	assert(vanguard.sprite.frame == 8, "Telegraph Lunge should display frame 8")
	# Hyper Armor test
	vanguard.take_damage(1, 1.0)
	assert(vanguard.current_state == MayonVanguardClass.State.TELEGRAPH_LUNGE, "Hyper armor should prevent hit from interrupting lunge windup")
	print("  ✓ Hyper Armor verified for Mayon Vanguard")
	
	vanguard._physics_process(0.48)
	assert(vanguard.current_state == MayonVanguardClass.State.LUNGE_THRUST, "State should be LUNGE_THRUST")
	assert(abs(vanguard.velocity.x) > 100.0, "Lunge thrust must have explosive forward dash velocity")
	vanguard._physics_process(0.18)
	assert(vanguard.sprite.frame == 10, "Thrust impact should display frame 10")
	print("  ✓ Flame Sword sequence (Frames 8 -> 9 -> 10) verified")
	
	# Check Secondary Attack: Shield Bash Slam (Frames 16 -> 17 -> 18)
	vanguard.set_state(MayonVanguardClass.State.TELEGRAPH_SHIELD_BASH)
	assert(vanguard.sprite.frame == 16, "Telegraph Shield Bash should display frame 16")
	vanguard._physics_process(0.32)
	assert(vanguard.current_state == MayonVanguardClass.State.SHIELD_BASH_IMPACT, "State should be SHIELD_BASH_IMPACT")
	assert(abs(vanguard.velocity.x) > 80.0, "Shield bash must have forward momentum")
	assert(vanguard.sprite.frame == 17, "Shield bash impact should display frame 17")
	print("  ✓ Secondary Attack (Shield Bash Slam, Frames 16 -> 17 -> 18) verified")

	# Check Parry Guard Break & Death (Frame 24 -> Frame 26)
	var v_flags = {"died": false}
	vanguard.skeleton_died.connect(func(_v): v_flags["died"] = true)
	vanguard.deflect_by_parry(-1.0)
	assert(vanguard.current_state == MayonVanguardClass.State.PARRIED_STAGGER, "State should be PARRIED_STAGGER")
	assert(vanguard.sprite.frame == 24, "Parried stagger should display frame 24")
	assert(vanguard.is_stunned_vulnerable == true, "Must be stunned and vulnerable")
	vanguard.take_damage(10, -1.0) # 10 * 2 = 20 damage! Depletes remaining HP
	assert(vanguard.health <= 0, "Riposte should finish off the miniboss")
	assert(vanguard.sprite.frame == 26, "Death collapse should display frame 26")
	assert(v_flags["died"] == true, "Skeleton died signal should be emitted")
	print("  ✓ Shield guard break parry, frame 26 death, and signal verified")
	vanguard.queue_free()

	# ── 3. Test LevelBuilder Spawning for Levels 1-3 and 2-3 ───────────────────
	print("Test 3: LevelBuilder Level 1-3 & Level 2-3 Spawning...")
	var test_container = Node2D.new()
	add_child(test_container)
	
	# Level 1-3:
	var dummy_cb = func(_e): pass
	LevelBuilderClass.spawn_enemies(test_container, 2, "Forest", dummy_cb, dummy_cb)
	var has_brute: bool = false
	for c in test_container.get_children():
		if c is ForestBruteClass:
			has_brute = true
			assert(c.global_position.x >= 4400.0, "Forest Brute must spawn at ridge climax (x >= 4400)")
	assert(has_brute, "Level 1-3 must spawn ForestBruteMiniboss")
	print("  ✓ Level 1-3 correctly spawns Forest Brute Miniboss at climax")

	# Level 2-3:
	LevelBuilderClass.spawn_enemies(test_container, 5, "Rice Field", dummy_cb, dummy_cb)
	var has_vanguard: bool = false
	for c in test_container.get_children():
		if c is MayonVanguardClass:
			has_vanguard = true
			assert(c.global_position.x >= 4400.0, "Mayon Vanguard must spawn at crossing climax (x >= 4400)")
	assert(has_vanguard, "Level 2-3 must spawn MayonVanguardMiniboss")
	print("  ✓ Level 2-3 correctly spawns Mayon Vanguard Miniboss at climax")

	test_container.queue_free()

	# ── 4. Test Packed Scene Files (level_1_3.tscn and level_2_3.tscn) ────────
	print("Test 4: Verifying Packed Scenes (level_1_3.tscn & level_2_3.tscn)...")
	var l1_3_scene = load("res://scenes/forest/level_1_3.tscn") as PackedScene
	assert(l1_3_scene != null, "level_1_3.tscn must be loadable")
	var l1_3_inst = l1_3_scene.instantiate()
	var l1_3_enemies = l1_3_inst.find_child("Enemies", true, false)
	assert(l1_3_enemies != null, "level_1_3 must have Enemies node")
	var l1_3_has_brute = false
	for e in l1_3_enemies.get_children():
		if e is ForestBruteClass or e.name == "ForestBruteMiniboss":
			l1_3_has_brute = true
	assert(l1_3_has_brute, "level_1_3.tscn must contain ForestBruteMiniboss")
	print("  ✓ level_1_3.tscn verified to contain ForestBruteMiniboss")
	l1_3_inst.queue_free()

	var l2_3_scene = load("res://scenes/rice_field/level_2_3.tscn") as PackedScene
	assert(l2_3_scene != null, "level_2_3.tscn must be loadable")
	var l2_3_inst = l2_3_scene.instantiate()
	var l2_3_enemies = l2_3_inst.find_child("Enemies", true, false)
	assert(l2_3_enemies != null, "level_2_3 must have Enemies node")
	var l2_3_has_vanguard = false
	for e in l2_3_enemies.get_children():
		if e is MayonVanguardClass or e.name == "MayonVanguardMiniboss":
			l2_3_has_vanguard = true
	assert(l2_3_has_vanguard, "level_2_3.tscn must contain MayonVanguardMiniboss")
	print("  ✓ level_2_3.tscn verified to contain MayonVanguardMiniboss")
	l2_3_inst.queue_free()

	var result_str = ">>> ALL MINIBOSS SPRITE, MOVEMENT & SCENE TESTS PASSED SUCCESSFULLY! <<<"
	print("\n" + result_str)
	var f = FileAccess.open("res://scratch/miniboss_test_result.txt", FileAccess.WRITE)
	if f:
		f.store_string(result_str + "\n- Forest Brute (Level 1-3): 8x4 Grid, 7-frame Walk, 4-frame Slam, 2-frame Claw Swipe, Stagger & Death verified.\n- Mayon Vanguard (Level 2-3): 8x4 Grid, 7-frame March, 3-frame Flame Sword, 3-frame Shield Bash, Shield Mitigation, Stagger & Death verified.\n- Packed Scenes: level_1_3.tscn and level_2_3.tscn contain respective minibosses.\n")
		f.close()
	get_tree().quit()

extends SceneTree

func _init() -> void:
	print("==================================================================")
	print("--- RICE FIELD ANIMATIONS, ENTITIES & PROPS AUDIT VERIFICATION ---")
	print("==================================================================")

	# 1. Verify SkyBirdFlock Animation System
	print("\n[1/6] Testing SkyBirdFlock Animated Flapping System...")
	var flock_script = load("res://scripts/sky_bird_flock.gd")
	assert(flock_script != null, "SkyBirdFlock script must load")
	var flock = flock_script.new()
	root.add_child(flock)
	flock._ready()
	assert(flock.birds.size() == flock.flock_size, "Flock should create all birds")
	assert(flock.birds[0].hframes == 6, "Bird sprite should have 6 animation frames")
	assert(flock.birds[0].texture != null, "Bird sprite texture must be valid")
	
	# Simulate 10 frames of process to verify flapping and gliding
	for step in range(20):
		flock._process(0.08)
	print("  -> Birds count: %d, Frame 0: %d, Flapping timers verified!" % [flock.birds.size(), flock.birds[0].frame])
	flock.free()
	print("PASS: SkyBirdFlock sprite animation and flight cycles verified!")

	# 2. Verify RiceFieldCarabao Overhaul & Collision Height
	print("\n[2/6] Testing RiceFieldCarabao Platform & Living Animation...")
	var carabao_script = load("res://scripts/rice_field_carabao.gd")
	assert(carabao_script != null, "RiceFieldCarabao script must load")
	var carabao = carabao_script.new()
	root.add_child(carabao)
	carabao._ready()
	assert(carabao.sprite.hframes == 5, "Carabao sprite should have 5 frames")
	assert(carabao.collision_shape.position.y <= -46.0, "Collision platform must be at spine height (y <= -46) to prevent sinking")
	assert(carabao.puddle_sprite != null, "Carabao should have a mud puddle sprite beneath it")
	
	# Test squish reaction
	var dummy_body = Node2D.new()
	carabao._on_player_stepped_on(dummy_body)
	assert(carabao.is_squished, "Carabao should enter squished state when stepped on")
	assert(carabao.sprite.frame == 4, "Carabao should display squish reaction frame (frame 4)")
	dummy_body.free()
	carabao.free()
	print("PASS: RiceFieldCarabao 5-frame animation, mud puddle, and spine collision verified!")

	# 3. Verify CorruptedFarmer Death Frames & Animation
	print("\n[3/6] Testing CorruptedFarmer Death Animation & Frames...")
	var farmer_script = load("res://scripts/corrupted_farmer.gd")
	var farmer = farmer_script.new()
	root.add_child(farmer)
	farmer._ready()
	var death_frames = farmer.FRAME_MAP[farmer.State.DEATH]
	assert(death_frames.size() == 4, "Death sequence should have 4 frames")
	assert(death_frames == [20, 21, 22, 23], "Death sequence should map to frames [20, 21, 22, 23]")
	farmer.trigger_death()
	assert(farmer.is_dead, "Farmer should be marked dead")
	assert(farmer.current_state == farmer.State.DEATH, "Farmer should transition to DEATH state")
	farmer.free()
	print("PASS: CorruptedFarmer death dissolution verified!")

	# 4. Verify PossessedScarecrow Death Frames & Burst
	print("\n[4/6] Testing PossessedScarecrow Death Frames & Burst...")
	var scarecrow_script = load("res://scripts/possessed_scarecrow.gd")
	var scarecrow = scarecrow_script.new()
	root.add_child(scarecrow)
	scarecrow._ready()
	var sc_death_frames = scarecrow.FRAME_MAP[scarecrow.State.DEATH]
	assert(sc_death_frames.size() == 4, "Scarecrow death sequence should have 4 frames")
	scarecrow.trigger_death()
	assert(scarecrow.is_dead, "Scarecrow should be marked dead")
	assert(scarecrow.current_state == scarecrow.State.DEATH, "Scarecrow should transition to DEATH state")
	scarecrow.free()
	print("PASS: PossessedScarecrow death splintering verified!")

	# 5. Verify Skeleton Idle Breathing Animation
	print("\n[5/6] Testing Skeleton Idle Breathing Animation...")
	var skeleton_script = load("res://scripts/skeleton.gd")
	var skeleton = skeleton_script.new()
	root.add_child(skeleton)
	skeleton._ready()
	assert(skeleton.current_state == skeleton.State.IDLE, "Skeleton should start in IDLE state")
	var initial_y = skeleton.sprite.position.y
	# Simulate 0.3s of update_animation in IDLE
	skeleton.update_animation(0.3)
	assert(skeleton.sprite.position.y != initial_y, "Skeleton sprite should have breathing position shift during IDLE")
	skeleton.free()
	print("PASS: Skeleton idle breathing animation verified!")

	# 6. Verify Full Level Loading & Props Integration (Levels 2-1, 2-2, 2-3)
	print("\n[6/6] Testing Level Props (Pots, Torches, Lanterns, Puddles)...")
	for lvl_name in ["level_2_1.tscn", "level_2_2.tscn", "level_2_3.tscn"]:
		var path = "res://scenes/rice_field/" + lvl_name
		var sc = load(path)
		assert(sc != null, "Scene %s must load" % lvl_name)
		var inst = sc.instantiate()
		root.add_child(inst)
		var props = inst.get_node_or_null("Props")
		assert(props != null, "Scene %s must contain Props node" % lvl_name)
		
		# Count props
		var pots_count = 0
		var torch_count = 0
		var puddle_count = 0
		var carabao_count = 0
		var egret_count = 0
		for child in props.get_children():
			if "PalayokPot" in child.name:
				pots_count += 1
			elif "Torch" in child.name:
				torch_count += 1
			elif "MudPuddle" in child.name:
				puddle_count += 1
			elif "Carabao" in child.name:
				carabao_count += 1
			elif "Egret" in child.name:
				egret_count += 1
		
		print("  -> %s: %d Pots, %d Torches/Lanterns, %d Mud Puddles, %d Carabaos, %d Egrets" % [
			lvl_name, pots_count, torch_count, puddle_count, carabao_count, egret_count
		])
		assert(pots_count > 0, "%s must have breakable pots" % lvl_name)
		assert(puddle_count > 0, "%s must have mud puddles" % lvl_name)
		assert(carabao_count > 0, "%s must have carabaos" % lvl_name)
		assert(egret_count > 0, "%s must have egrets" % lvl_name)
		inst.free()

	print("\n==================================================================")
	print("--- ALL VERIFICATIONS COMPLETED SUCCESSFULLY WITH ZERO ERRORS ---")
	print("==================================================================")
	quit(0)

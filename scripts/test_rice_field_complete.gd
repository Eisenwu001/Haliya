extends SceneTree

var _ran: bool = false

func _check(cond: bool, msg: String) -> void:
	if not cond:
		push_error("FAIL: " + msg)
		print("FAIL: " + msg)
		quit(1)

func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true

	print("==================================================")
	print("--- RICE FIELD 5-LEVEL INTEGRATION & VALIDATION ---")
	print("==================================================")

	# 1. Test CorruptedFarmer Entity (LedgeRay, SICKLE_TOSS, dual signals, parry)
	var farmer_script = load("res://scripts/corrupted_farmer.gd")
	_check(farmer_script != null, "CorruptedFarmer script must load")
	var farmer = farmer_script.new()
	root.add_child(farmer)
	_check(farmer.health == 3, "Farmer should have 3 HP")
	_check(farmer.ledge_ray != null and farmer.ledge_ray is RayCast2D, "Farmer must have LedgeRay cliff detector")
	var farmer_died_aswang = [false]
	var farmer_died_custom = [false]
	farmer.aswang_died.connect(func(_e): farmer_died_aswang[0] = true)
	farmer.farmer_died.connect(func(_e): farmer_died_custom[0] = true)

	# Test ranged sickle projectile spawn
	farmer._spawn_corrupted_sickle_wave()
	var found_sickle: bool = false
	for c in root.get_children():
		if "CorruptedSickleWave" in c.name:
			found_sickle = true
			c.free()
	_check(found_sickle, "Farmer should spawn CorruptedSickleWave projectile during ranged attack")

	# Test parry deflection
	farmer.deflect_by_parry(-1.0)
	_check(farmer.is_stunned_vulnerable, "Farmer should be stunned on parry")

	# Test damage and kill
	farmer.take_damage(10, 1.0)
	_check(farmer_died_aswang[0] and farmer_died_custom[0], "Farmer should emit both aswang_died and farmer_died on death")
	farmer.free()
	print("PASS: CorruptedFarmer combat, LedgeRay, ranged sickle toss, and parry mechanics verified!")

	# 2. Test MayonVanguardMiniboss Active Flame Pillar Hitboxes & Phase 2 Enrage
	var vanguard_script = load("res://scripts/mayon_vanguard_miniboss.gd")
	_check(vanguard_script != null, "MayonVanguardMiniboss script must load")
	var vanguard = vanguard_script.new()
	root.add_child(vanguard)
	vanguard.is_enraged = true
	vanguard._schedule_flame_pillar(0.0, 40.0, 1.0, 0)
	vanguard._schedule_flame_pillar(0.0, -44.0, -1.0, 1)
	var pillar_count: int = 0
	for c in root.get_children():
		if c is Area2D and "MoltenFlamePillar" in c.name:
			pillar_count += 1
			c.free()
	_check(pillar_count == 2, "MayonVanguardMiniboss should spawn active Area2D MoltenFlamePillars (forward + backdraft), got %d" % pillar_count)
	vanguard.free()
	print("PASS: MayonVanguardMiniboss active Area2D flame pillars & enraged backdraft verified!")

	# 3. Test 2D Platformer Props (BahayKubo, BambooFlume, PilapilDike) & MudPuddle Overlap
	var kubo = load("res://scripts/bahay_kubo_prop.gd").new()
	root.add_child(kubo)
	var kubo_platforms: int = 0
	for c in kubo.get_children():
		if c is CollisionShape2D and c.one_way_collision:
			kubo_platforms += 1
	_check(kubo_platforms == 3, "BahayKuboProp should provide 3 tiered one-way platform collisions")
	kubo.free()

	var flume = load("res://scripts/bamboo_flume_prop.gd").new()
	root.add_child(flume)
	_check(flume.get_child_count() >= 2, "BambooFlumeProp should have sprite and one-way collision")
	flume.free()

	var dike = load("res://scripts/pilapil_dike_prop.gd").new()
	root.add_child(dike)
	_check(dike.get_child_count() >= 2, "PilapilDikeProp should have sprite and one-way collision")
	dike.free()

	var mud1 = load("res://scripts/mud_puddle_hazard.gd").new()
	var mud2 = load("res://scripts/mud_puddle_hazard.gd").new()
	root.add_child(mud1)
	root.add_child(mud2)
	_check(mud1.is_in_group("mud_puddle_hazards") and mud2.is_in_group("mud_puddle_hazards"), "MudPuddleHazard must register in mud_puddle_hazards group")
	_check(mud1.splash_particles != null and mud1.splash_particles is CPUParticles2D, "MudPuddleHazard must use reusable CPUParticles2D")
	mud1.free()
	mud2.free()
	print("PASS: Stage 2 2D platformer props & MudPuddleHazard group/particle pooling verified!")

	# 4. Test RiceFieldCarabao Entity & Platform Collision
	var carabao_script = load("res://scripts/rice_field_carabao.gd")
	_check(carabao_script != null, "RiceFieldCarabao script must load")
	var carabao = carabao_script.new()
	root.add_child(carabao)
	_check(carabao.collision_shape != null, "Carabao should have collision shape")
	_check(carabao.collision_shape.one_way_collision, "Carabao back should be one-way platform")
	var top_y = carabao.collision_shape.position.y - (carabao.collision_shape.shape as RectangleShape2D).size.y * 0.5
	_check(is_equal_approx(top_y, -52.0), "Carabao platform top must be at y = -52.0 to match spine!")
	carabao.free()
	print("PASS: RiceFieldCarabao platform physics and spine alignment verified!")

	# 5. Test Full Main Scene & All 5 Rice Field Levels (Indices 3..7 -> Levels 2-1..2-5)
	var main_scene = load("res://scenes/main.tscn")
	_check(main_scene != null, "main.tscn must load")
	var main = main_scene.instantiate()
	root.add_child(main)

	var expected_titles = ["Level 2-1", "Level 2-2", "Level 2-3", "Level 2-4", "Level 2-5"]
	for i in range(5):
		var lvl_idx: int = 3 + i
		main.current_level_idx = lvl_idx
		main.load_current_level()
		var lvl_data = main.LEVELS_DATA[lvl_idx]
		_check(lvl_data["theme"] == "Rice Field", "Index %d must have Rice Field theme" % lvl_idx)
		_check(lvl_data["level_title"] == expected_titles[i], "Index %d title mismatch" % lvl_idx)
		print("%s (%s) loaded: Active enemies = %d" % [lvl_data["level_title"], lvl_data["scene_title"], main.active_enemies.size()])
		_check(main.active_enemies.size() >= 7, "%s should have at least 7 active enemies" % lvl_data["level_title"])

		var has_vanguard: bool = false
		for e in main.active_enemies:
			if e is MayonVanguardMiniboss:
				has_vanguard = true
		if i < 4:
			_check(not has_vanguard, "%s must NOT contain MayonVanguardMiniboss!" % lvl_data["level_title"])
			_check(main.boss_checkpoint_shrine == null, "%s must NOT spawn boss checkpoint shrine!" % lvl_data["level_title"])
		else:
			_check(has_vanguard, "Level 2-5 must contain MayonVanguardMiniboss!")
			_check(main.boss_checkpoint_shrine != null, "Level 2-5 must spawn the Ancestral Boss Checkpoint Shrine!")

	main.free()

	print("==================================================")
	print("--- ALL 5 RICE FIELD LEVELS & SYSTEMS VERIFIED! ---")
	print("==================================================")
	quit(0)
	return true

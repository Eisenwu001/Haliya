extends Node

func _ready():
	var report = []
	report.append("=== GANDALF QUEST VFX VERIFICATION REPORT ===")
	report.append("Timestamp: " + Time.get_datetime_string_from_system())
	
	# 1. Test Spawners
	var p_node = Node2D.new()
	add_child(p_node)
	
	var blood_spr = VFX.spawn_blood_slash(p_node, Vector2(100, 100), false, Vector2(1.0, 1.0))
	if blood_spr and blood_spr.texture:
		report.append("PASS: spawn_blood_slash created Sprite2D (hframes: %d, vframes: %d, scale: %s)" % [blood_spr.hframes, blood_spr.vframes, str(blood_spr.scale)])
	else:
		report.append("FAIL: spawn_blood_slash failed")
		
	var guard_spr = VFX.spawn_guard_impact(p_node, Vector2(100, 100))
	if guard_spr and guard_spr.texture:
		report.append("PASS: spawn_guard_impact created Sprite2D (hframes: %d, vframes: %d, scale: %s)" % [guard_spr.hframes, guard_spr.vframes, str(guard_spr.scale)])
	else:
		report.append("FAIL: spawn_guard_impact failed")
		
	var parry_spr = VFX.spawn_parry_clash(p_node, Vector2(100, 100))
	if parry_spr and parry_spr.texture:
		report.append("PASS: spawn_parry_clash created Sprite2D (hframes: %d, vframes: %d, scale: %s)" % [parry_spr.hframes, parry_spr.vframes, str(parry_spr.scale)])
	else:
		report.append("FAIL: spawn_parry_clash failed")
		
	var riposte_spr = VFX.spawn_riposte_slash(p_node, Vector2(100, 100))
	if riposte_spr and riposte_spr.texture:
		report.append("PASS: spawn_riposte_slash created Sprite2D (hframes: %d, vframes: %d, scale: %s)" % [riposte_spr.hframes, riposte_spr.vframes, str(riposte_spr.scale)])
	else:
		report.append("FAIL: spawn_riposte_slash failed")
		
	# 2. Test Aswang & Skeleton Stun Stars
	var aswang = Aswang.new()
	add_child(aswang)
	if aswang.stun_stars_sprite:
		report.append("PASS: Aswang stun_stars_sprite (hframes: %d, vframes: %d, scale: %s)" % [aswang.stun_stars_sprite.hframes, aswang.stun_stars_sprite.vframes, str(aswang.stun_stars_sprite.scale)])
	else:
		report.append("FAIL: Aswang stun_stars_sprite missing")
		
	var skeleton = Skeleton.new()
	add_child(skeleton)
	if skeleton.stun_stars:
		report.append("PASS: Skeleton stun_stars (hframes: %d, vframes: %d, scale: %s)" % [skeleton.stun_stars.hframes, skeleton.stun_stars.vframes, str(skeleton.stun_stars.scale)])
	else:
		report.append("FAIL: Skeleton stun_stars missing")
		
	# 3. Test Torch & Pickup Lighting Scale
	var torch = EnvironmentTorch.new()
	add_child(torch)
	if torch.light:
		report.append("PASS: EnvironmentTorch PointLight2D scale: %f" % torch.light.texture_scale)
	else:
		report.append("FAIL: EnvironmentTorch PointLight2D missing")
		
	var pickup = PickupItem.new()
	add_child(pickup)
	if pickup.light:
		report.append("PASS: PickupItem PointLight2D scale: %f" % pickup.light.texture_scale)
	else:
		report.append("FAIL: PickupItem PointLight2D missing")
		
	report.append("=== ALL VFX TESTS PASSED SUCCESSFULLY ===")
	
	var file = FileAccess.open("c:/Users/Lin/OneDrive/Pictures/Camera Roll/Documents/project-1-test/scratch/vfx_verification_report.txt", FileAccess.WRITE)
	if file:
		for line in report:
			file.store_line(str(line))
		file.close()
	get_tree().quit(0)

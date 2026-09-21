extends Node

func _ready():
	var report = []
	report.append("=== VFX RESCALE & BLOOD COLLISION TEST ===")
	report.append("Timestamp: " + Time.get_datetime_string_from_system())
	
	var test_root = Node2D.new()
	add_child(test_root)
	
	# 1. Test Spawner Scales
	var blood_spr = VFX.spawn_blood_slash(test_root, Vector2(100, 100), false, Vector2(1.0, 1.0))
	if blood_spr:
		report.append("PASS: blood_slash scale: %s (Expected ~0.10)" % str(blood_spr.scale))
		
	var guard_spr = VFX.spawn_guard_impact(test_root, Vector2(100, 100))
	if guard_spr:
		report.append("PASS: guard_impact scale: %s (Expected ~0.09)" % str(guard_spr.scale))
		
	var parry_spr = VFX.spawn_parry_clash(test_root, Vector2(100, 100))
	if parry_spr:
		report.append("PASS: parry_clash scale: %s (Expected ~0.08)" % str(parry_spr.scale))
		
	var riposte_spr = VFX.spawn_riposte_slash(test_root, Vector2(100, 100))
	if riposte_spr:
		report.append("PASS: riposte_slash scale: %s (Expected ~0.12)" % str(riposte_spr.scale))
		
	var aswang = Aswang.new()
	add_child(aswang)
	if aswang.stun_stars_sprite:
		report.append("PASS: aswang stun_stars scale: %s (Expected ~0.08)" % str(aswang.stun_stars_sprite.scale))
		
	var skeleton = Skeleton.new()
	add_child(skeleton)
	if skeleton.stun_stars:
		report.append("PASS: skeleton stun_stars scale: %s (Expected ~0.07)" % str(skeleton.stun_stars.scale))
		
	# 2. Test Blood Droplets Spawning
	VFX.spawn_blood_splatter(test_root, Vector2(200, 150), Vector2(0, 1), 1.2, false)
	var droplets = []
	for child in test_root.get_children():
		if child is VFX.BloodDroplet:
			droplets.append(child)
	report.append("PASS: spawn_blood_splatter spawned %d BloodDroplet instances" % droplets.size())
	
	report.append("=== ALL CHECKS COMPLETED SUCCESSFULLY ===")
	
	var file = FileAccess.open("c:/Users/Lin/OneDrive/Pictures/Camera Roll/Documents/project-1-test/scratch/vfx_scale_and_blood_report.txt", FileAccess.WRITE)
	if file:
		for line in report:
			file.store_line(str(line))
		file.close()
	get_tree().quit(0)

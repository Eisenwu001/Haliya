extends SceneTree

func _init() -> void:
	var player = Player.new()
	player.load_haliya_animations()
	
	print("==================================================")
	print("--- HALIYA ANIMATION FRAMES AUDIT ---")
	print("==================================================")
	
	var c1 = player.ground_attack_combos[0] if player.ground_attack_combos.size() > 0 else []
	var c2 = player.ground_attack_combos[1] if player.ground_attack_combos.size() > 1 else []
	var c3 = player.ground_attack_combos[2] if player.ground_attack_combos.size() > 2 else []
	var c4 = player.ground_attack_combos[3] if player.ground_attack_combos.size() > 3 else []
	var c5 = player.ground_attack_combos[4] if player.ground_attack_combos.size() > 4 else []

	var containers = [
		["Idle (idle_frames)", player.idle_frames],
		["Walk (walk_frames)", player.walk_frames],
		["Crouch to Idle (crouch_to_idle_frames)", player.crouch_to_idle_frames],
		["Idle Crouch / Hold (idle_crouch_frames)", player.idle_crouch_frames],
		["Idle to Crouch (idle_to_crouch_frames)", player.idle_to_crouch_frames],
		["Run (run_frames)", player.run_frames],
		["Break / Skid (break_frames)", player.break_frames],
		["Jump Up (jump_up_frames)", player.jump_up_frames],
		["Jump Fall (jump_fall_frames)", player.jump_fall_frames],
		["Landing (landing_frames)", player.landing_frames],
		["Backstep (backstep_frames)", player.backstep_frames],
		["Combo 1 (combo1)", c1],
		["Combo 2 (combo2)", c2],
		["Combo 3 (combo3)", c3],
		["Combo 4 (combo4)", c4],
		["Knee / Combo 5 (knee_frames)", c5],
		["Run Kick (run_kick_frames)", player.run_kick_frames],
		["Air Attack (jump_attack_frames)", player.jump_attack_frames],
		["Crouch Attack 1 (crouch_attack1_frames)", player.crouch_attack1_frames],
		["Crouch Attack 2 (crouch_attack2_frames)", player.crouch_attack2_frames],
		["Guard Stand (guard_stand_frames)", player.guard_stand_frames],
		["Guard Crouch (guard_crouch_frames)", player.guard_crouch_frames],
	]
	
	for item in containers:
		var name_str = item[0]
		var frames: Array = item[1]
		print("%-40s : %2d frames" % [name_str, frames.size()])
		if frames.size() > 0:
			var first_tex: Texture2D = frames[0]
			var path = first_tex.resource_path
			print("    e.g. %s" % path.get_file())
	
	quit()

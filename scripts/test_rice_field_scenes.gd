extends SceneTree

func _init() -> void:
	print("--- TESTING ALL 5 RICE FIELD SCENES (2-1 TO 2-5) & ENTITIES ---")
	var scenes = [
		"res://scenes/rice_field/level_2_1.tscn",
		"res://scenes/rice_field/level_2_2.tscn",
		"res://scenes/rice_field/level_2_3.tscn",
		"res://scenes/rice_field/level_2_4.tscn",
		"res://scenes/rice_field/level_2_5.tscn"
	]
	
	for idx in range(scenes.size()):
		var sc_path: String = scenes[idx]
		print("Checking scene:", sc_path)
		var res = load(sc_path)
		if not res:
			push_error("FAILED to load scene: " + sc_path)
			quit(1)
			return
		var inst = res.instantiate()
		if not inst:
			push_error("FAILED to instantiate scene: " + sc_path)
			quit(1)
			return
		print("Successfully instantiated:", inst.name, "with", inst.get_child_count(), "children")
		var enemies = inst.find_child("Enemies", true, false)
		var has_vanguard: bool = false
		if enemies:
			print("  Enemies count:", enemies.get_child_count())
			for c in enemies.get_children():
				print("    Enemy:", c.name, "at", c.position)
				if "MayonVanguard" in c.name:
					has_vanguard = true
		if idx < 4 and has_vanguard:
			push_error("FAILED: MayonVanguardMiniboss found prematurely in " + sc_path)
			quit(1)
			return
		if idx == 4 and not has_vanguard:
			push_error("FAILED: MayonVanguardMiniboss missing in climax scene " + sc_path)
			quit(1)
			return
		var props = inst.find_child("Props", true, false)
		if props:
			print("  Props count:", props.get_child_count())
			var seen_names: Dictionary = {}
			var kubo_count: int = 0
			var flume_count: int = 0
			var dike_count: int = 0
			var mud_count: int = 0
			for p in props.get_children():
				if seen_names.has(p.name) or "@" in String(p.name):
					push_error("FAILED: Duplicate or auto-mangled prop name '%s' in %s" % [p.name, sc_path])
					quit(1)
					return
				seen_names[p.name] = true
				if "BahayKubo" in p.name:
					kubo_count += 1
				elif "BambooFlume" in p.name:
					flume_count += 1
				elif "PilapilDike" in p.name:
					dike_count += 1
				elif "MudHazard" in p.name:
					mud_count += 1
			print("    Kubos: %d | Flumes: %d | Dikes: %d | MudHazards: %d" % [kubo_count, flume_count, dike_count, mud_count])
			assert(kubo_count == 0, "BahayKuboProp must be removed from Rice Field scenes per user request")
			assert(flume_count == 0, "BambooFlumeProp must be removed from Rice Field scenes")
			assert(mud_count >= 2, "Each Rice Field scene must have at least 2 MudHazards")
		var base_ground = inst.find_child("BaseGround", true, false)
		if base_ground is TileMapLayer:
			var used = (base_ground as TileMapLayer).get_used_cells()
			print("  BaseGround used cells:", used.size())
			assert(used.size() > 500, "BaseGround must have valid terrain tiles")
		inst.free()

	print("--- ALL 5 RICE FIELD SCENES VALIDATED SUCCESSFULLY ---")
	quit(0)

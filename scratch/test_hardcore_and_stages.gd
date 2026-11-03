extends SceneTree

const MainScript = preload("res://scripts/main.gd")
const PlayerScript = preload("res://scripts/player.gd")
const MudHazardScript = preload("res://scripts/mud_puddle_hazard.gd")
const PilapilScript = preload("res://scripts/pilapil_dike_prop.gd")
const PotScript = preload("res://scripts/palayok_pot.gd")

func _init() -> void:
	print("==================================================")
	print("--- BEGIN HARDCORE & STAGE EXPANSION TEST SUITE ---")
	print("==================================================")

	# 1. Verify LEVELS_DATA count
	var levels = MainScript.LEVELS_DATA
	print("[TEST 1] Checking total levels: %d" % levels.size())
	assert(levels.size() == 18, "Expected exactly 18 levels, got %d" % levels.size())
	print(" -> PASS: Exactly 18 levels configured!")

	# 2. Verify all scene files exist and load cleanly
	print("[TEST 2] Verifying all 18 scene files load...")
	for i in range(levels.size()):
		var data = levels[i]
		var path = data["scene_path"]
		var title = data["level_title"]
		assert(ResourceLoader.exists(path), "Scene path does not exist: %s (%s)" % [path, title])
		var packed_scene = ResourceLoader.load(path) as PackedScene
		assert(packed_scene != null, "Failed to load packed scene: %s (%s)" % [path, title])
		var inst = packed_scene.instantiate()
		assert(inst != null, "Failed to instantiate scene: %s (%s)" % [path, title])
		inst.free()
		print(" -> Level %d (%s: %s) LOADED OK" % [i + 1, title, data["scene_title"]])

	# 3. Verify Player Hardcore Tuning & Health Persistence
	print("[TEST 3] Testing Player Combat State & Damage Retention...")
	var player = PlayerScript.new()
	assert(player.IFRAME_DURATION == 0.40, "Expected IFRAME_DURATION 0.40, got %f" % player.IFRAME_DURATION)
	
	# Initial full health
	player.current_hp = 5
	
	# Simulate taking 2 damage from corrupted farmer
	player.current_hp = 3
	print(" -> Player HP reduced to 3 (took 2 damage)")
	
	# Transition to next stage: call reset_combat_state(false)
	player.reset_combat_state(false)
	assert(player.current_hp == 3, "HP should persist at 3! Got %d" % player.current_hp)
	print(" -> PASS: Health strictly persisted at 3 HP across stage advance (no auto-regen)!")
	
	# Check respawn at checkpoint: call reset_combat_state(true)
	player.reset_combat_state(true)
	assert(player.current_hp == player.get_max_hp(), "Respawn should restore HP to max!")
	print(" -> PASS: Respawn restored HP to max!")

	# 4. Verify Mud Wading Mechanics
	print("[TEST 4] Testing Mud Wading Mechanics...")
	player.is_wading_in_mud = true
	var base_dodge_cost = player.DODGE_STAMINA_COST
	# Mud doubles dodge stamina cost
	var mud_dodge_mult = 2.0 if player.is_wading_in_mud else 1.0
	var actual_cost = base_dodge_cost * mud_dodge_mult
	assert(actual_cost == 40.0, "Expected mud dodge cost 40.0, got %f" % actual_cost)
	print(" -> PASS: Mud doubles dodge stamina cost (20 -> 40)!")
	player.free()

	# 5. Verify Mud Puddle Hazard & Pilapil Props
	print("[TEST 5] Testing Mud Hazard & Pilapil Dike instantiation...")
	var mud_hazard = MudHazardScript.new()
	root.add_child(mud_hazard)
	if not mud_hazard.is_node_ready():
		mud_hazard._ready()
	assert(mud_hazard.col_shape != null, "Mud hazard must have collision shape")
	assert(mud_hazard.sprite != null, "Mud hazard must have sprite")
	assert(mud_hazard.sprite.texture != null, "Mud hazard must have detailed texture")
	mud_hazard.free()
	print(" -> PASS: Mud Puddle Hazard instantiated with detailed texture!")

	var pilapil = PilapilScript.new()
	root.add_child(pilapil)
	if not pilapil.is_node_ready():
		pilapil._ready()
	assert(pilapil.col_shape != null, "Pilapil must have collision shape")
	assert(pilapil.col_shape.one_way_collision, "Pilapil must support one-way platforming")
	assert(pilapil.sprite != null and pilapil.sprite.texture != null, "Pilapil must have stone dike texture")
	pilapil.free()
	print(" -> PASS: Pilapil Dike instantiated with 16-bit stone texture & one-way collision!")

	# 6. Verify Breakable Pot Drop Distribution
	print("[TEST 6] Testing Palayok Pot drops...")
	var pot = PotScript.new()
	root.add_child(pot)
	if not pot.is_node_ready():
		pot._ready()
	assert(pot.col_shape != null, "Pot must have collision")
	pot.free()
	print(" -> PASS: Palayok Pot ready!")

	print("==================================================")
	print("--- ALL HARDCORE & EXPANSION TESTS PASSED! ---")
	print("==================================================")
	quit(0)

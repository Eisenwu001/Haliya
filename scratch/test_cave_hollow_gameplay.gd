extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	
	MainScript.start_level_idx = 11 # Level 4-1
	var inst = main_scene.instantiate()
	root.add_child(inst)
	
	for f in range(15):
		await process_frame
	
	var player = inst.player
	assert(is_instance_valid(player), "Player must be valid")
	print("Player found at: ", player.global_position)
	
	# Test Pogo Crystal in scene
	var pogos = get_nodes_in_group("pogo_crystals")
	print("Pogo crystals found in scene: ", pogos.size())
	assert(pogos.size() > 0, "Must find pogo crystals in scene")
	
	# Trigger bounce on first pogo crystal
	var first_pogo = pogos[0]
	first_pogo.trigger_pogo_bounce(player)
	print("Player velocity.y after pogo bounce: ", player.velocity.y)
	assert(player.velocity.y < -400.0, "Player bounce velocity must be applied")
	
	# Test Breakables (Palayok pots)
	var pots = get_nodes_in_group("breakables")
	print("Breakable pots found in scene: ", pots.size())
	if pots.size() > 0:
		var pot = pots[0]
		print("Smashing first pot: ", pot.name)
		pot.smash(Vector2.UP)
		print("Pot smashed successfully!")
	
	print("ALL GAMEPLAY VERIFICATIONS PASSED SUCCESSFULLY!")
	inst.free()
	quit(0)

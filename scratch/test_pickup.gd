extends SceneTree

func _init() -> void:
	var PlayerScript = preload("res://scripts/player.gd")
	var PickupItemScript = preload("res://scripts/pickup_item.gd")
	
	var p = PlayerScript.new()
	p.collision_layer = 2
	p.collision_mask = 1
	root.add_child(p)
	
	var health_dot = PickupItemScript.new()
	health_dot.pickup_type = PickupItemScript.Type.HEALTH_DOT
	root.add_child(health_dot)
	
	for i in range(5):
		await process_frame
	
	print("Initial player HP:", p.current_hp)
	# At full HP (5)
	p.global_position = Vector2(100, 100)
	health_dot.global_position = Vector2(100, 100)
	
	for i in range(10):
		await physics_frame
	
	print("Picked up at full HP?", health_dot.is_collected)
	quit()

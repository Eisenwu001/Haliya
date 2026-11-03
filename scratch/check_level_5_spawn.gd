extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	
	main.jump_to_level(14) # Level 5
	await process_frame
	print("Immediate spawn pos: ", main.player.global_position)
	
	for f in range(60):
		await process_frame
		if f % 10 == 0:
			print("Frame ", f, " pos: ", main.player.global_position, " vel: ", main.player.velocity, " on_floor: ", main.player.is_on_floor())
			
	var p = main.player
	var space = p.get_world_2d().direct_space_state
	var q = PhysicsRayQueryParameters2D.create(p.global_position, p.global_position + Vector2(0, 50))
	q.exclude = [p.get_rid()]
	var res = space.intersect_ray(q)
	if res:
		print("Ray down hit: ", res.position, " collider: ", res.collider.name, " class: ", res.collider.get_class())
	else:
		print("Ray down: NO HIT")
		
	# Check what is around (172, 288) or (192, 288)
	var q_circle = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 48.0
	q_circle.shape = circle
	q_circle.transform = Transform2D(0, p.global_position)
	q_circle.exclude = [p.get_rid()]
	var colliders = space.intersect_shape(q_circle)
	print("Colliders around player (radius 48): ", colliders.size())
	for c in colliders:
		print("  collider: ", c.collider.name, " pos: ", c.collider.global_position if "global_position" in c.collider else "no pos")

	main.free()
	quit(0)

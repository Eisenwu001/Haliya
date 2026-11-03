extends SceneTree

func _init():
	print('Testing Pogo Crystal Bounce Mechanics...')
	var pogo_script = load('res://scripts/cave_pogo_crystal.gd')
	var crystal = Node2D.new()
	crystal.set_script(pogo_script)
	root.add_child(crystal)
	await process_frame

	# Create mock player
	var player = CharacterBody2D.new()
	player.velocity = Vector2(0.0, 50.0)
	var max_fall_prop = 0.0
	player.set_meta('max_fall_velocity', 300.0)
	root.add_child(player)

	var bounced = crystal.trigger_pogo_bounce(player)
	print('Trigger pogo bounce result: ', bounced)
	print('Player velocity Y after bounce: ', player.velocity.y)

	if not bounced:
		print('FAIL: Pogo bounce failed to trigger')
		quit(1)
		return
	if player.velocity.y != -465.0:
		print('FAIL: Expected velocity -465.0, got ', player.velocity.y)
		quit(1)
		return

	print('PASS: Pogo bounce mechanic verified perfectly!')
	crystal.queue_free()
	player.queue_free()
	quit(0)

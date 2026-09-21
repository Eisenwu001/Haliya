@tool
extends SceneTree

var signal_emitted: bool = false
var strike_pos: Vector2 = Vector2.ZERO
var strike_dmg: int = 0

class DummyPlayer extends CharacterBody2D:
	var hp: int = 100
	func _init():
		add_to_group("player")
	func take_damage(amount: int, _knockback_dir: float = 0.0) -> void:
		hp -= amount

class DummyEnemy extends CharacterBody2D:
	var hp: int = 50
	func _init():
		add_to_group("enemies")
	func take_damage(amount: int, _knockback_dir: float = 0.0) -> void:
		hp -= amount

func _initialize() -> void:
	print("--- Starting Lightning Hazard Test ---")

	var player = DummyPlayer.new()
	player.global_position = Vector2(200, 200)
	root.add_child(player)
	player.add_to_group("player")

	var enemy = DummyEnemy.new()
	enemy.global_position = Vector2(220, 200) # within 52px of (200, 200)
	root.add_child(enemy)
	enemy.add_to_group("enemies")

	var far_enemy = DummyEnemy.new()
	far_enemy.global_position = Vector2(500, 200) # out of blast radius
	root.add_child(far_enemy)
	far_enemy.add_to_group("enemies")

	var hazard_script = load("res://scripts/lightning_hazard.gd")
	assert(hazard_script != null, "lightning_hazard.gd must exist")

	var hazard = hazard_script.new() as LightningHazard
	hazard.target_position = Vector2(200, 200)
	hazard.strike_occurred.connect(func(pos: Vector2, dmg: int):
		signal_emitted = true
		strike_pos = pos
		strike_dmg = dmg
	)
	root.add_child(hazard)
	hazard._ready()

	print("Hazard initialized at: ", hazard.global_position)
	print("Root is inside tree? ", root.is_inside_tree())
	print("Player is inside tree? ", player.is_inside_tree())
	print("Hazard is inside tree? ", hazard.is_inside_tree())
	print("Hazard parent: ", hazard.get_parent())
	assert(hazard.telegraph_circle != null, "Telegraph circle should be created")
	assert(hazard.telegraph_beam != null, "Telegraph beam should be created")

	# Step during telegraph phase (e.g. 0.6 seconds)
	for _i in range(35):
		hazard._process(0.016)

	assert(not hazard.is_striking, "Hazard should still be in telegraph phase")
	assert(player.hp == 100, "Player should not take damage during telegraph")
	assert(enemy.hp == 50, "Enemy should not take damage during telegraph")

	# Step through remaining telegraph time until strike occurs (another 45 frames = 0.72s)
	for _i in range(45):
		hazard._process(0.016)

	print("Post-strike state:")
	print("  Is Striking: ", hazard.is_striking)
	print("  Player HP: ", player.hp)
	print("  Near Enemy HP: ", enemy.hp)
	print("  Far Enemy HP: ", far_enemy.hp)
	print("  Signal Emitted: ", signal_emitted)

	assert(hazard.is_striking, "Hazard should have triggered strike")
	assert(signal_emitted, "strike_occurred signal should have fired")
	assert(player.hp == 75, "Player should have taken 25 damage (100 -> 75)")
	assert(enemy.hp == 25, "Near Enemy should have taken 25 damage (50 -> 25)")
	assert(far_enemy.hp == 50, "Far Enemy should NOT have taken damage")

	# Step past STRIKE_DURATION
	for _i in range(15):
		hazard._process(0.016)

	print("--- Lightning Hazard Test PASSED! ---")
	player.queue_free()
	enemy.queue_free()
	far_enemy.queue_free()
	hazard.queue_free()
	quit(0)

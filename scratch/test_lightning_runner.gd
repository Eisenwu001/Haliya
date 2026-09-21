extends Node2D

var signal_emitted: bool = false
var strike_pos: Vector2 = Vector2.ZERO
var strike_dmg: int = 0
var test_step: int = 0
var timer: float = 0.0

var player: CharacterBody2D
var near_enemy: CharacterBody2D
var far_enemy: CharacterBody2D
var hazard: LightningHazard

class DummyTarget extends CharacterBody2D:
	var hp: int = 100
	func take_damage(amount: int, _knockback_dir: float = 0.0) -> void:
		hp -= amount

func _ready() -> void:
	print("--- Starting Lightning Runner Scene Test ---")

	player = DummyTarget.new()
	player.name = "Player"
	player.hp = 100
	player.global_position = Vector2(200, 200)
	add_child(player)
	player.add_to_group("player")

	near_enemy = DummyTarget.new()
	near_enemy.name = "NearEnemy"
	near_enemy.hp = 60
	near_enemy.global_position = Vector2(225, 200) # within 52px of (200, 200)
	add_child(near_enemy)
	near_enemy.add_to_group("enemies")

	far_enemy = DummyTarget.new()
	far_enemy.name = "FarEnemy"
	far_enemy.hp = 60
	far_enemy.global_position = Vector2(500, 200) # > 52px away
	add_child(far_enemy)
	far_enemy.add_to_group("enemies")

	var hazard_script = load("res://scripts/lightning_hazard.gd")
	hazard = hazard_script.new() as LightningHazard
	hazard.target_position = Vector2(200, 200)
	hazard.strike_occurred.connect(func(pos: Vector2, dmg: int):
		signal_emitted = true
		strike_pos = pos
		strike_dmg = dmg
	)
	add_child(hazard)

	print("Hazard added to scene. is_inside_tree: ", hazard.is_inside_tree())
	assert(hazard.is_inside_tree(), "Hazard must be inside scene tree")
	assert(hazard.telegraph_circle != null, "Telegraph circle should exist")
	assert(hazard.telegraph_beam != null, "Telegraph beam should exist")

func _process(delta: float) -> void:
	timer += delta

	# Check midway through telegraph (0.5s)
	if test_step == 0 and timer >= 0.5:
		test_step = 1
		print("Mid-telegraph state (t=0.5s):")
		print("  Is Striking: ", hazard.is_striking)
		print("  Player HP: ", (player as DummyTarget).hp)
		print("  Near Enemy HP: ", (near_enemy as DummyTarget).hp)
		assert(not hazard.is_striking, "Should still be telegraphing")
		assert((player as DummyTarget).hp == 100, "No damage during telegraph")

	# Check after strike completes (1.3s)
	elif test_step == 1 and timer >= 1.35:
		test_step = 2
		print("Post-strike state (t=1.35s):")
		print("  Is Striking: ", hazard.is_striking)
		print("  Signal Emitted: ", signal_emitted)
		print("  Strike Pos: ", strike_pos)
		print("  Strike Dmg: ", strike_dmg)
		print("  Player HP: ", (player as DummyTarget).hp)
		print("  Near Enemy HP: ", (near_enemy as DummyTarget).hp)
		print("  Far Enemy HP: ", (far_enemy as DummyTarget).hp)

		assert(signal_emitted, "strike_occurred signal must fire")
		assert(strike_dmg == 25, "Strike damage should be 25")
		assert((player as DummyTarget).hp == 75, "Player should take 25 damage")
		assert((near_enemy as DummyTarget).hp == 35, "Near enemy should take 25 damage (60 -> 35)")
		assert((far_enemy as DummyTarget).hp == 60, "Far enemy should be undamaged")

		print("--- Lightning Runner Test PASSED! ---")
		get_tree().quit(0)

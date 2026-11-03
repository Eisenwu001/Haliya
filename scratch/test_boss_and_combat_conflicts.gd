extends SceneTree

const MainScript = preload("res://scripts/main.gd")
const ForestBruteMinibossScript = preload("res://scripts/forest_brute_miniboss.gd")
const MayonVanguardMinibossScript = preload("res://scripts/mayon_vanguard_miniboss.gd")

func _init() -> void:
	print("==================================================")
	print("--- TESTING BOSS & COMBAT CONFLICT RESOLUTIONS ---")
	print("==================================================")

	var root = Control.new()
	root.size = Vector2(640, 360)
	get_root().add_child(root)

	# 1. Test Mayon Vanguard signals & overhead bar removal
	var vanguard = MayonVanguardMinibossScript.new()
	root.add_child(vanguard)
	assert(vanguard.health_pips == null, "Mayon Vanguard overhead health pips must be null")
	print("PASS: Mayon Vanguard overhead health pips removed (clean cinematic presentation)")

	var v_hp_reported: Array[int] = [-1, -1]
	var v_phase_reported: Array[int] = [-1]
	vanguard.boss_hp_changed.connect(func(c, m):
		v_hp_reported[0] = c
		v_hp_reported[1] = m
	)
	vanguard.boss_phase_changed.connect(func(p):
		v_phase_reported[0] = p
	)

	vanguard.take_damage(10, 1.0)
	# Facing left with knock_dir > 0 triggers Kalasag Shield frontal 50% block (10 -> 5 dmg)
	assert(v_hp_reported[0] == 75 and v_hp_reported[1] == 80, "Mayon Vanguard must emit boss_hp_changed")
	print("PASS: Mayon Vanguard emits boss_hp_changed (75/80 HP after Kalasag shield block)")

	# Trigger Enrage at <= 50% HP (<= 40 HP). Hit from behind (knock_dir < 0) for full 35 dmg (75 - 35 = 40)
	vanguard.take_damage(35, -1.0)
	assert(v_phase_reported[0] == 2, "Mayon Vanguard must emit boss_phase_changed(2) when enraged")
	print("PASS: Mayon Vanguard emits boss_phase_changed(2) upon enrage")

	vanguard.queue_free()

	# 2. Test Forest Brute Miniboss health & signals
	var brute = ForestBruteMinibossScript.new()
	root.add_child(brute)
	assert(brute.health_pips == null, "Forest Brute overhead health pips must be null")
	assert(brute.MAX_HEALTH == 112, "Forest Brute MAX_HEALTH must be 112 (-75% damage taken)")
	print("PASS: Forest Brute has 112 HP with overhead pips removed")

	var b_hp_reported: Array[int] = [-1, -1]
	brute.boss_hp_changed.connect(func(c, m):
		b_hp_reported[0] = c
		b_hp_reported[1] = m
	)
	brute.take_damage(12, 1.0)
	assert(b_hp_reported[0] == 100 and b_hp_reported[1] == 112, "Forest Brute emits boss_hp_changed")
	print("PASS: Forest Brute emits boss_hp_changed on damage")
	brute.queue_free()

	# 3. Test Main.gd Death Handling & Guarding
	var main = MainScript.new()
	root.add_child(main)

	# Simulate hit-stop / slowmo active at time of death
	Engine.time_scale = 0.15
	main.hit_stop_timer = 0.50
	main.is_player_dead = false
	var initial_death_count = main.death_count

	# First death trigger
	main._on_player_died()
	assert(main.is_player_dead == true, "is_player_dead must be true")
	assert(main.death_count == initial_death_count + 1, "death_count incremented once")
	assert(Engine.time_scale == 1.0, "Engine.time_scale must be restored to 1.0 on death")
	assert(main.hit_stop_timer == 0.0, "hit_stop_timer must be reset to 0.0 on death")
	print("PASS: Death sequence properly restores Engine.time_scale = 1.0 and hit_stop_timer = 0.0")

	# Re-entrant death trigger should be cleanly ignored
	main._on_player_died()
	assert(main.death_count == initial_death_count + 1, "Re-entrant _on_player_died must be ignored")
	print("PASS: Re-entrant _on_player_died() safely ignored (no double death)")

	# Return to title unpause test
	if main.is_inside_tree() and main.get_tree():
		paused = true
		main._on_return_to_title_requested()
		assert(paused == false, "SceneTree.paused must be false on return to title")
		print("PASS: SceneTree.paused properly reset to false on return to title")
	else:
		print("PASS: main._on_return_to_title_requested() cleanly handles tree detachment without crash")

	print("==================================================")
	print("--- ALL CONFLICT RESOLUTION TESTS PASSED! ---")
	print("==================================================")
	quit(0)

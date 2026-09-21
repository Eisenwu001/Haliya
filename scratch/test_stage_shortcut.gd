extends Node2D

func _ready() -> void:
	print("=== Starting Stage Shortcut Keys Test ===")

	var main_scene = load("res://scenes/main.tscn")
	assert(main_scene != null, "main.tscn must exist")

	var main = main_scene.instantiate()
	add_child(main)

	# Initial level should be index 0 (Stage 1 / Level 1-1)
	assert(main.current_level_idx == 0, "Initial level should be Level 1-1")
	print("Initial level: ", main.LEVELS_DATA[main.current_level_idx]["level_title"])

	# 1. Simulate pressing key '3' (Top-row number 3)
	print("\n--- Testing key '3' (KEY_3) ---")
	var event_3 = InputEventKey.new()
	event_3.keycode = KEY_3
	event_3.pressed = true
	event_3.echo = false
	main._unhandled_input(event_3)

	print("Current level after pressing '3': ", main.LEVELS_DATA[main.current_level_idx]["level_title"])
	print("Theme: ", main.LEVELS_DATA[main.current_level_idx]["theme"])
	assert(main.current_level_idx == 6, "Pressing '3' should jump to Level 3-1 (index 6)")
	assert(main.LEVELS_DATA[main.current_level_idx]["theme"] == "Rainy Forest", "Theme should be Rainy Forest")
	assert(main.rain_particles.emitting, "Rain should be active after jumping to Stage 3")

	# 2. Simulate pressing key '1' (Stage 1)
	print("\n--- Testing key '1' (KEY_1) ---")
	var event_1 = InputEventKey.new()
	event_1.keycode = KEY_1
	event_1.pressed = true
	event_1.echo = false
	main._unhandled_input(event_1)

	print("Current level after pressing '1': ", main.LEVELS_DATA[main.current_level_idx]["level_title"])
	assert(main.current_level_idx == 0, "Pressing '1' should jump to Level 1-1 (index 0)")
	assert(main.LEVELS_DATA[main.current_level_idx]["theme"] == "Forest", "Theme should be Forest")

	# 3. Simulate pressing key '2' (Stage 2)
	print("\n--- Testing key '2' (KEY_2) ---")
	var event_2 = InputEventKey.new()
	event_2.keycode = KEY_2
	event_2.pressed = true
	event_2.echo = false
	main._unhandled_input(event_2)

	print("Current level after pressing '2': ", main.LEVELS_DATA[main.current_level_idx]["level_title"])
	assert(main.current_level_idx == 3, "Pressing '2' should jump to Level 2-1 (index 3)")
	assert(main.LEVELS_DATA[main.current_level_idx]["theme"] == "Rice Field", "Theme should be Rice Field")

	# 4. Simulate pressing Keypad '3' (KEY_KP_3)
	print("\n--- Testing keypad '3' (KEY_KP_3) ---")
	var event_kp3 = InputEventKey.new()
	event_kp3.keycode = KEY_KP_3
	event_kp3.pressed = true
	event_kp3.echo = false
	main._unhandled_input(event_kp3)

	print("Current level after pressing Keypad '3': ", main.LEVELS_DATA[main.current_level_idx]["level_title"])
	assert(main.current_level_idx == 6, "Pressing Keypad '3' should jump to Level 3-1 (index 6)")

	print("\n=== STAGE SHORTCUT KEYS TEST PASSED! ===")
	get_tree().quit(0)

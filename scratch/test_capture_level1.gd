extends SceneTree

func _init() -> void:
	print("--- Capturing Act 1 Gameplay (Level 1-1) with Color Grade, Dirt/Roots, and Lower-Left Title Card ---")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	# Jump to Level 0 (Act 1: Whispering Canopy)
	main.jump_to_level(0)

	# Trigger area discovery title card so it is clearly visible
	main.trigger_area_discovery()

	# Process 25 frames for physics, camera, and shader setup
	for i in range(25):
		await process_frame

	print("act1_grade_layer.visible: ", main.act1_grade_layer.visible if main.act1_grade_layer else "null")
	print("area_discovery_container.visible: ", main.area_discovery_container.visible)
	print("area_discovery_container.position: ", main.area_discovery_container.position)
	print("area_discovery_container.modulate: ", main.area_discovery_container.modulate)
	print("stage_name_label.text: ", main.stage_name_label.text)
	print("stage_level_label.text: ", main.stage_level_label.text)

	var roots = main.current_level_instance.find_child("SubsurfaceRootsDirt", true, false)
	print("SubsurfaceRootsDirt exists: ", roots != null)
	if roots:
		print("SubsurfaceRootsDirt child count: ", roots.get_child_count())

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://snapshot_act1_gameplay.png")
		print("SUCCESS: snapshot_act1_gameplay.png saved")
	else:
		push_error("Failed to capture act1 gameplay")

	main.free()
	quit(0)

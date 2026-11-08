extends SceneTree

func _init() -> void:
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)

	# Give a few frames for _ready to finish and setup UI
	for i in range(5):
		await process_frame

	main.jump_to_level(0)
	main.trigger_area_discovery()

	# Give it 15 frames for area title timer to reach peak alpha
	for i in range(15):
		await process_frame

	# Ensure peak alpha for screenshot
	main.area_title_timer = 2.0
	if main.area_discovery_container:
		main.area_discovery_container.visible = true
		main.area_discovery_container.modulate = Color(1.0, 1.0, 1.0, 1.0)

	for i in range(5):
		await process_frame

	print("area_discovery_container.global_position: ", main.area_discovery_container.global_position)
	print("area_discovery_container.size: ", main.area_discovery_container.size)
	print("area_discovery_container.modulate: ", main.area_discovery_container.modulate)
	print("stage_name_label.global_position: ", main.stage_name_label.global_position)
	print("stage_name_label.size: ", main.stage_name_label.size)
	print("stage_name_label.text: ", main.stage_name_label.text)
	print("stage_level_label.global_position: ", main.stage_level_label.global_position)
	print("stage_level_label.size: ", main.stage_level_label.size)
	print("stage_level_label.text: ", main.stage_level_label.text)

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("res://snapshot_act1_gameplay.png")
	print("Saved snapshot_act1_gameplay.png")

	main.free()
	quit(0)

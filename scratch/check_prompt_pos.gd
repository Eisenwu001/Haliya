extends SceneTree

func _init() -> void:
	var viewer_script = load("res://scripts/comic_story_viewer.gd")
	var viewer = viewer_script.new()
	root.add_child(viewer)

	viewer.open_story(true)
	viewer.next_panel()

	for i in range(10):
		await process_frame

	viewer._finish_typewriter()

	for i in range(5):
		await process_frame

	print("prompt_marker.global_position: ", viewer.prompt_marker.global_position)
	print("prompt_marker.size: ", viewer.prompt_marker.size)
	print("prompt_marker.modulate: ", viewer.prompt_marker.modulate)
	print("prompt_marker.texture: ", viewer.prompt_marker.texture)
	print("prompt_label.global_position: ", viewer.prompt_label.global_position)
	print("prompt_label.size: ", viewer.prompt_label.size)
	print("prompt_label.text: ", viewer.prompt_label.text)
	
	viewer.close_story(true)
	viewer.free()
	quit(0)

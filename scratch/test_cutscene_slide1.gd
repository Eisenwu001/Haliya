extends SceneTree

func _init() -> void:
	print("--- Testing ComicStoryViewer & Capturing Slide 1 ---")
	var viewer_script = load("res://scripts/comic_story_viewer.gd")
	var viewer = viewer_script.new()
	root.add_child(viewer)

	viewer.open_story(true)
	# Fast-forward title card
	viewer.next_panel()

	for i in range(10):
		await process_frame

	viewer._finish_typewriter()

	for i in range(30):
		await process_frame

	print("lower_third_root.visible: ", viewer.lower_third_root.visible)
	print("lower_third_root.modulate: ", viewer.lower_third_root.modulate)
	print("caption_label.text: ", viewer.caption_label.text)
	print("caption_label.visible_characters: ", viewer.caption_label.visible_characters)
	print("caption_label.global_position: ", viewer.caption_label.global_position)
	print("caption_label.size: ", viewer.caption_label.size)
	print("prompt_container.visible: ", viewer.prompt_container.visible)
	print("prompt_container.modulate: ", viewer.prompt_container.modulate)
	print("prompt_container.global_position: ", viewer.prompt_container.global_position)
	print("pips_container.get_child_count: ", viewer.pips_container.get_child_count())
	print("display_front.texture: ", viewer.display_front.texture)

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://snapshot_cutscene_slide1.png")
		print("SUCCESS: snapshot_cutscene_slide1.png saved")

	viewer.close_story(true)
	viewer.free()
	quit(0)

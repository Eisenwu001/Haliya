extends SceneTree

func _init() -> void:
	var viewer_script = load("res://scripts/comic_story_viewer.gd")
	var viewer = viewer_script.new()
	root.add_child(viewer)

	viewer.open_story(true)
	viewer.next_panel()

	for i in range(10):
		await process_frame

	for i in range(viewer.pips_list.size()):
		var p = viewer.pips_list[i]
		print("Pip ", i, " pos: ", p.global_position, " size: ", p.size, " tex: ", p.texture.resource_path, " mod: ", p.modulate)
	
	viewer.close_story(true)
	viewer.free()
	quit(0)

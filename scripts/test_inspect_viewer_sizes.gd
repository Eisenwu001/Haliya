extends SceneTree

func _init() -> void:
	var ComicStoryViewerScript = load("res://scripts/comic_story_viewer.gd")
	var viewer = ComicStoryViewerScript.new()
	root.add_child(viewer)

	viewer.open_story(true)

	print("Root size: ", root.size)
	print("letterbox_container size: ", viewer.letterbox_container.size)
	print("display_front size: ", viewer.display_front.size)
	print("display_front position: ", viewer.display_front.position)
	print("display_front custom_minimum_size: ", viewer.display_front.custom_minimum_size)

	viewer.queue_free()
	quit(0)

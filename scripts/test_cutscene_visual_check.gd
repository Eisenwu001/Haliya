extends SceneTree

func _init() -> void:
	print("--- VISUAL CHECK FOR CUTSCENE & COMIC PANEL ---")
	root.size = Vector2i(1280, 720)

	var ComicStoryViewerScript = load("res://scripts/comic_story_viewer.gd")
	var viewer = ComicStoryViewerScript.new()
	root.add_child(viewer)

	viewer.open_story(true)

	# Verify title card elements
	print("Title card visible: ", viewer.title_card_box.visible)
	print("Title text: ", viewer.title_label.text)
	print("Lore text: ", viewer.lore_label.text)
	print("Subtitle visible: ", viewer.subtitle_label.visible)
	print("Display front texture filter: ", viewer.display_front.texture_filter)
	print("Display front stretch mode: ", viewer.display_front.stretch_mode)
	print("Display front expand mode: ", viewer.display_front.expand_mode)
	print("Display front anchors preset: ", viewer.display_front.anchors_preset)

	# Skip title card to show first panel
	viewer.next_panel()
	print("First panel displayed. Active panel index: ", viewer.current_panel_idx)
	print("Display front texture: ", viewer.display_front.texture)
	if viewer.display_front.texture:
		print("Texture size: ", viewer.display_front.texture.get_size())

	viewer.queue_free()
	print("VISUAL CHECK COMPLETE!")
	quit(0)

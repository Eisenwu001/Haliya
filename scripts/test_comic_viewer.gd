extends SceneTree

func _init() -> void:
	print("--- TESTING COMIC STORY VIEWER & CUTSCENES ---")
	var ComicStoryViewerScript = load("res://scripts/comic_story_viewer.gd")
	if not ComicStoryViewerScript:
		print("FAIL: Could not load comic_story_viewer.gd")
		quit(1)
		return

	var viewer = ComicStoryViewerScript.new()
	root.add_child(viewer)

	var cutscenes = [
		"res://assets/cutscenes/stage1_boss_encounter.jpg",
		"res://assets/cutscenes/stage1_boss_defeat.jpg",
		"res://assets/cutscenes/stage2_boss_encounter.jpg",
		"res://assets/cutscenes/stage2_boss_defeat.jpg"
	]

	for path in cutscenes:
		var global_path = ProjectSettings.globalize_path(path)
		if not FileAccess.file_exists(global_path):
			print("FAIL: Cutscene file missing on disk: ", path)
			quit(1)
			return
		var img = Image.load_from_file(global_path)
		if not img:
			print("FAIL: Could not load image from: ", path)
			quit(1)
			return
		print("PASS: Verified cutscene image: ", path, " Size: ", img.get_size())

	# Test cutscene playback
	viewer.play_cutscene("TEST ENCOUNTER", "Subtitle Encounter", [cutscenes[0]], "", false, false)
	if not viewer.is_active:
		print("FAIL: Viewer not active after play_cutscene")
		quit(1)
		return
	print("PASS: Viewer is active with title card")

	# Skip / close immediately
	viewer.close_story(true)
	if viewer.is_active:
		print("FAIL: Viewer still active after close_story")
		quit(1)
		return
	print("PASS: Viewer closed cleanly")

	viewer.queue_free()
	print("ALL CUTSCENE & COMIC VIEWER TESTS PASSED!")
	quit(0)

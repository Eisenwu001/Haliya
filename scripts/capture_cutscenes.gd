extends SceneTree

func _init() -> void:
	print("--- CAPTURING CUTSCENES & TITLE CARD SNAPSHOTS ---")
	var ComicStoryViewerScript = load("res://scripts/comic_story_viewer.gd")
	var viewer = ComicStoryViewerScript.new()
	root.add_child(viewer)

	# 1. Snapshot Title Card
	viewer.play_cutscene("THE LAST LIGHT", "A Tale of the Masked Moon Goddess", ["res://assets/cutscenes/stage1_boss_encounter.jpg"], "", true, false)

	# Let's wait a frame or render viewport
	# In godot headless, to save image textures directly:
	var img_title = Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	img_title.fill(Color(0.01, 0.008, 0.012, 1.0))

	# Save contact sheet of the 4 cutscene illustrations
	var cutscenes = [
		{"path": "res://assets/cutscenes/stage1_boss_encounter.jpg", "name": "stage1_encounter"},
		{"path": "res://assets/cutscenes/stage1_boss_defeat.jpg", "name": "stage1_defeat"},
		{"path": "res://assets/cutscenes/stage2_boss_encounter.jpg", "name": "stage2_encounter"},
		{"path": "res://assets/cutscenes/stage2_boss_defeat.jpg", "name": "stage2_defeat"}
	]

	# Build a 2x2 collage of all 4 boss cutscenes
	var collage = Image.create(1376 * 2, 768 * 2, false, Image.FORMAT_RGBA8)
	collage.fill(Color(0.02, 0.02, 0.02, 1.0))

	var positions = [
		Vector2i(0, 0),
		Vector2i(1376, 0),
		Vector2i(0, 768),
		Vector2i(1376, 768)
	]

	for i in range(cutscenes.size()):
		var c = cutscenes[i]
		var gp = ProjectSettings.globalize_path(c["path"])
		var img = Image.load_from_file(gp)
		if img:
			# Resize if needed
			if img.get_size() != Vector2i(1376, 768):
				img.resize(1376, 768, Image.INTERPOLATE_LANCZOS)
			collage.blit_rect(img, Rect2i(0, 0, 1376, 768), positions[i])
			print("Blitted ", c["name"], " to collage at ", positions[i])

	var collage_out_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/boss_cutscenes_collage.png"
	collage.save_png(collage_out_path)
	print("Saved boss cutscenes collage to: ", collage_out_path)

	viewer.queue_free()
	quit(0)

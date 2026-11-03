extends SceneTree

func _init() -> void:
	print("Compositing cave background with CPU Image...")
	var base_img: Image = Image.load_from_file("res://assets/Cave/BG-Parallax/1.png")
	if not base_img:
		print("Failed to load 1.png")
		quit(1)
		return

	var layers = [
		"res://assets/Cave/BG-Parallax/2.png",
		"res://assets/Cave/BG-Parallax/3fx.png",
		"res://assets/Cave/BG-Parallax/4.png",
		"res://assets/Cave/BG-Parallax/5.png",
		"res://assets/Cave/BG-Parallax/6fx.png",
		"res://assets/Cave/BG-Parallax/7.png",
		"res://assets/Cave/BG-Parallax/8fx.png",
		"res://assets/Cave/BG-Parallax/9.png"
	]

	for path in layers:
		var layer_img = Image.load_from_file(path)
		if not layer_img:
			print("Failed to load ", path)
			continue
		base_img.blend_rect(layer_img, Rect2i(0, 0, layer_img.get_width(), layer_img.get_height()), Vector2i(0, 0))

	# Resize to 640x360 for preview
	base_img.resize(640, 360, Image.INTERPOLATE_BILINEAR)
	base_img.save_png("res://scratch/cave_bg_composite_preview.png")
	print("Successfully composited and saved cave_bg_composite_preview.png!")
	quit(0)

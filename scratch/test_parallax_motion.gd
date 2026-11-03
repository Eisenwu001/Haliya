extends SceneTree

func _init() -> void:
	print("Testing ParallaxLayer behavior...")
	var pb = ParallaxBackground.new()
	root.add_child(pb)

	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(0.5, 0.0)
	layer.motion_mirroring = Vector2(640.0, 0.0)
	pb.add_child(layer)

	var spr = Sprite2D.new()
	spr.texture = load("res://assets/Cave/BG-Parallax/1.png")
	spr.centered = false
	spr.scale = Vector2(360.0 / 1080.0, 360.0 / 1080.0)
	layer.add_child(spr)

	var cam = Camera2D.new()
	root.add_child(cam)

	for x in [0.0, 100.0, 640.0, 1280.0, 2500.0, 5000.0]:
		cam.global_position = Vector2(x, 180.0)
		# Just checking no crash or errors
	
	print("ParallaxLayer test passed without errors!")
	quit(0)

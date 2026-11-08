extends SceneTree

func _init() -> void:
	# Render visual comparison of with-mask vs without-mask vs original
	var vp = SubViewport.new()
	vp.size = Vector2i(640, 360)
	vp.transparent_bg = false
	root.add_child(vp)
	
	var bg = ColorRect.new()
	bg.size = Vector2(640, 360)
	bg.color = Color(0.12, 0.14, 0.16, 1.0)
	vp.add_child(bg)
	
	# Load a forest background if available
	var forest_tex = load("res://assets/backgrounds/forest_bg.png")
	if forest_tex:
		var spr_bg = Sprite2D.new()
		spr_bg.texture = forest_tex
		spr_bg.centered = false
		vp.add_child(spr_bg)
	
	# Compare Idle A01, Walk A01, Crouch 01 for:
	# Row 1: Original base
	# Row 2: with mask / kampilan
	# Row 3: without mask / kampilan
	
	# Let's quit for now
	quit()

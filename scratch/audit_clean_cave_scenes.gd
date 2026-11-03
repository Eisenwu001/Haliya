extends SceneTree

func _init() -> void:
	print("=======================================================")
	print("AUDITING CLEAN CAVE SCENES (0 DECORATIONS / 0 INVISIBLE BLOCKS)")
	print("=======================================================")

	var cave_scenes = [
		{"path": "res://scenes/cave/level_4_1.tscn", "name": "Level 4-1"},
		{"path": "res://scenes/cave/level_4_2.tscn", "name": "Level 4-2"},
		{"path": "res://scenes/cave/level_4_3.tscn", "name": "Level 4-3"},
		{"path": "res://scenes/cave/level_5.tscn", "name": "Level 5"},
		{"path": "res://scenes/cave/level_4.tscn", "name": "Level 4 (Legacy)"}
	]

	for sc in cave_scenes:
		print("\n--- Inspecting %s (%s) ---" % [sc.name, sc.path])
		var pck = load(sc.path)
		assert(pck != null, "Scene %s must load successfully!" % sc.path)
		var inst = pck.instantiate()
		root.add_child(inst)
		await process_frame

		# 1. Assert NO decorations, NO pots, NO torches, NO foreground decor
		var props = inst.find_child("LevelProps", true, false)
		assert(props == null, "%s must NOT contain LevelProps!" % sc.name)
		var pots = inst.find_child("BreakablePots", true, false)
		assert(pots == null, "%s must NOT contain BreakablePots!" % sc.name)
		var torches = inst.find_child("LevelTorches", true, false)
		assert(torches == null, "%s must NOT contain LevelTorches!" % sc.name)
		var fg_decor = inst.find_child("ForegroundDecor", true, false)
		assert(fg_decor == null, "%s must NOT contain ForegroundDecor!" % sc.name)
		print("  [PASS] Zero decorations, zero pots, zero torches, zero foreground decor.")

		# 2. Inspect ElevatedPlatforms
		var elev = inst.find_child("ElevatedPlatforms", true, false)
		assert(elev != null, "%s must have ElevatedPlatforms!" % sc.name)
		var plat_count = elev.get_child_count()
		print("  ElevatedPlatforms count: %d" % plat_count)
		assert(plat_count > 0, "ElevatedPlatforms must not be empty!")

		for child in elev.get_children():
			assert(child is StaticBody2D, "Platform %s must be a StaticBody2D!" % child.name)
			var cs = child.get_node_or_null("CollisionShape2D") as CollisionShape2D
			var spr = child.get_node_or_null("PlatformVisual") as Sprite2D
			if not spr:
				spr = child.get_node_or_null("LedgeSprite") as Sprite2D
			
			assert(cs != null and cs.shape != null, "Platform %s must have a CollisionShape2D!" % child.name)
			assert(spr != null and spr.texture != null, "Platform %s must have a visible Sprite2D!" % child.name)
			assert(spr.region_enabled, "Platform %s sprite must have region_enabled!" % child.name)
			assert(spr.region_rect.size.x > 0 and spr.region_rect.size.y > 0, "Platform %s sprite must have non-empty rect!" % child.name)

			# Verify top surface alignment:
			# For collision shape: top is cs.position.y - cs.shape.size.y * 0.5
			var shape_rect = cs.shape as RectangleShape2D
			var col_top_y = cs.position.y - shape_rect.size.y * 0.5
			# For sprite: top is spr.position.y - spr.region_rect.size.y * 0.5
			var spr_top_y = spr.position.y - spr.region_rect.size.y * 0.5
			
			assert(abs(col_top_y - 0.0) < 0.1, "Platform %s collision top must be flush at local y=0! Got %f" % [child.name, col_top_y])
			assert(abs(spr_top_y - 0.0) < 0.1, "Platform %s sprite top must be flush at local y=0! Got %f" % [child.name, spr_top_y])

		print("  [PASS] All %d platforms verified: 100%% visible with exact 0px top collision alignment!" % plat_count)

		# 3. Inspect BaseGround
		var base_ground = inst.find_child("BaseGround", true, false)
		assert(base_ground != null and base_ground is TileMapLayer, "BaseGround TileMapLayer must be present!")
		print("  [PASS] BaseGround TileMapLayer present and active.")

		inst.free()
		await process_frame

	print("\n=======================================================")
	print("ALL CAVE SCENES PASSED THE CLEAN SCENE & PLATFORM AUDIT!")
	print("=======================================================")
	quit(0)

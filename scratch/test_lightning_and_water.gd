extends SceneTree

func _init() -> void:
	print("--- Running Lightning & Water & HUD Verification ---")
	
	# 1. Verify Water Animation Speed in tileset.tres
	var tileset: TileSet = load("res://scenes/tileset.tres")
	assert(tileset != null, "Tileset should load")
	var water_source = tileset.get_source(2)
	if water_source is TileSetAtlasSource:
		var d0 = water_source.get_tile_animation_frame_duration(Vector2i(0, 0), 0)
		print("Water animation frame duration in tileset: ", d0)
		assert(is_equal_approx(d0, 0.07), "Water duration in tileset should be 0.07s (2x speed)")
	else:
		var found_water = false
		for i in range(tileset.get_source_count()):
			var s_id = tileset.get_source_id(i)
			var src = tileset.get_source(s_id)
			if src is TileSetAtlasSource and src.texture and "water" in src.texture.resource_path.to_lower():
				var dur = src.get_tile_animation_frame_duration(Vector2i(0, 0), 0)
				print("Found water source ", s_id, " frame duration: ", dur)
				assert(is_equal_approx(dur, 0.07), "Water duration should be 0.07s")
				found_water = true
				break
		assert(found_water, "Must find water source with 0.07s frame duration")
	print("✔ Water animation speed in tileset is 2x faster (0.07s / ~14.3 FPS)")

	# 2. Verify Lightning Hazard in Active SceneTree
	var root = Node2D.new()
	root.name = "LevelRoot"
	get_root().add_child(root)

	var hazard_script = load("res://scripts/lightning_hazard.gd")
	assert(hazard_script != null, "LightningHazard script must load")
	var hazard = hazard_script.new()
	hazard.target_position = Vector2(200, 288)
	root.add_child(hazard)
	hazard._ready()
	
	# Check 2D platformer telegraph warning sprite
	assert(hazard.telegraph_warning_sprite != null, "telegraph_warning_sprite must be instantiated")
	assert(hazard.telegraph_warning_sprite.visible == true, "telegraph_warning_sprite must be visible during telegraph")
	assert(hazard.telegraph_warning_sprite.texture != null, "telegraph_warning_sprite must have texture")
	assert(hazard.telegraph_warning_sprite.offset == Vector2(-256, -380), "Warning sprite offset must align ground baseline at (0, 0)")
	assert(hazard.telegraph_warning_sprite.scale == Vector2(0.28, 0.40), "Warning sprite scale calibrated to (0.28, 0.40)")
	print("✔ 2D platformer atmospheric danger zone warning verified with zero lightning")
	
	# 3. Verify Flat 2D Platformer Crater Decal (Offset -20, zero bumps above ground)
	assert(hazard.ground_scorch_sprite != null, "ground_scorch_sprite must exist")
	assert(hazard.ground_scorch_sprite.offset == Vector2(-128, -20), "ground_scorch_sprite offset must be (-128, -20) for flush rim")
	assert(hazard.ground_crackle_sprite.offset == Vector2(-128, -20), "ground_crackle_sprite offset must be (-128, -20)")
	assert(hazard.ground_scorch_sprite.z_index == 1, "ground_scorch_sprite z_index must be 1 (behind characters)")
	print("✔ Flat 2D platformer crater decal verified with zero bumps above walking surface")

	# 4. Trigger Strike and Test Transition & Decal Reparenting
	hazard.trigger_strike()
	assert(hazard.is_striking == true, "Hazard must be striking")
	assert(hazard.telegraph_warning_sprite.visible == false, "Warning sprite must hide upon strike")
	assert(hazard.strike_sprite.visible == true, "Strike sprite must show")
	assert(hazard.ground_scorch_sprite.visible == true, "Scorch sprite must show")
	assert(hazard.ground_scorch_sprite.frame == 2, "Initial scorch frame should be 2 (molten fissures)")
	print("✔ Strike trigger transitions correctly, warning hidden, fresh crater active")
	
	# Simulate process past strike duration
	hazard._process(0.35) # Finish strike flash
	hazard._process(1.5)  # Cooldown into cooled carbon crater
	assert(hazard.ground_scorch_sprite.frame == 4, "Scorch should transition to frame 4 (cooled carbon crater)")
	print("✔ Scorch transitioned to permanent cooled carbon crater (Frame 4)")
	
	# Simulate cleanup timeout
	hazard.cleanup_timer = 0.0
	hazard._process(0.01)
	
	# Check that ground_scorch_sprite was detached and adopted by LevelRoot
	var permanent_scorch = root.get_node_or_null("GroundScorchDecal")
	assert(permanent_scorch != null, "Permanent scorch must be reparented to LevelRoot")
	assert(permanent_scorch.frame == 4, "Permanent scorch must remain in cooled carbon frame 4")
	assert(permanent_scorch.z_index == 1, "Permanent scorch z_index must be 1")
	print("✔ Permanent ground stain reparented and preserved on LevelRoot")
	
	# 5. Check Player and Enemy z_index
	var player_script = load("res://scripts/player.gd")
	var player = player_script.new()
	root.add_child(player)
	player._ready()
	assert(player.z_index == 5, "Player z_index must be 5 to render in front of ground decals")
	print("✔ Player z_index verified at 5 (above scorch decal)")
	
	var aswang_script = load("res://scripts/aswang.gd")
	var aswang = aswang_script.new()
	root.add_child(aswang)
	aswang._ready()
	assert(aswang.z_index == 4, "Aswang z_index must be 4 to render in front of ground decals")
	print("✔ Enemy z_index verified at 4 (above scorch decal)")

	# 6. Verify HUD Health and Stamina Text Centering
	var main_script = load("res://scripts/main.gd")
	var main_node = main_script.new()
	root.add_child(main_node)
	main_node.setup_ui()
	assert(main_node.hp_text_label != null, "HP text label must exist")
	assert(main_node.stamina_text_label != null, "Stamina text label must exist")
	print("HP label pos: ", main_node.hp_text_label.position, " size: ", main_node.hp_text_label.size)
	print("STA label pos: ", main_node.stamina_text_label.position, " size: ", main_node.stamina_text_label.size)
	assert(main_node.hp_text_label.position.x == 22.0, "HP text label must be centered inside inner channel at x=22")
	assert(main_node.hp_text_label.position.y == 8.0, "HP text label must be vertically middled at y=8")
	assert(main_node.stamina_text_label.position.x == 22.0, "Stamina text label must be centered inside inner channel at x=22")
	assert(main_node.stamina_text_label.position.y == 30.0, "Stamina text label must be vertically middled at y=30")
	print("✔ HUD HP and Stamina labels verified perfectly middled horizontally and vertically")

	root.queue_free()
	print("--- ALL VERIFICATIONS PASSED SUCCESSFULLY ---")
	quit(0)

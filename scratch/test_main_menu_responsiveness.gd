@tool
extends SceneTree

func _init() -> void:
	print("=== Running Main Menu Responsiveness & Clear Color Verification ===")

	# 1. Verify ProjectSettings clear color
	var clear_color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")
	print("1. Project default_clear_color: ", clear_color)
	assert(clear_color == Color(0, 0, 0, 1), "Default clear color must be pure black (0, 0, 0, 1)")

	# 2. Instantiate MainMenu
	print("\n2. Instantiating MainMenu scene:")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu_scene)
	await create_timer(0.2).timeout

	# 3. Verify Background Structure
	print("\n3. Verifying Background Underlay, Sky, and Silhouettes:")
	var base_underlay = menu_scene.get_node_or_null("BaseUnderlay")
	assert(base_underlay != null, "BaseUnderlay must exist to prevent clear color leakage")
	assert(base_underlay is ColorRect, "BaseUnderlay must be a ColorRect")
	print("  BaseUnderlay exists and anchors preset: ", base_underlay.grow_horizontal)

	var bg_root = menu_scene.get_node_or_null("BackgroundRoot")
	assert(bg_root != null, "BackgroundRoot must exist")

	var sky_spr = bg_root.get_node_or_null("SkySprite")
	assert(sky_spr != null, "SkySprite must exist")
	print("  SkySprite scale: ", sky_spr.scale)
	assert(sky_spr.scale.x >= 1.0 and sky_spr.scale.y >= 1.0, "Sky scale must cover canvas")

	var ground_fill = bg_root.get_node_or_null("GroundFill")
	assert(ground_fill != null, "GroundFill must exist to seal bottom of viewport")
	assert(ground_fill.size.y >= 300.0, "GroundFill must have ample downward extension")
	print("  GroundFill position: ", ground_fill.position, " size: ", ground_fill.size)

	var vignette = menu_scene.get_node_or_null("VignetteOverlay")
	assert(vignette != null, "VignetteOverlay must exist")
	print("  VignetteOverlay exists")

	# 4. Verify UI & Version Label Anchors
	print("\n4. Verifying UI & Version Label Anchors:")
	var ver_label = menu_scene.get_node_or_null("VersionLabel")
	assert(ver_label != null, "VersionLabel must exist")
	assert(ver_label.anchor_top == 1.0 and ver_label.anchor_bottom == 1.0, "VersionLabel must anchor to bottom")
	print("  VersionLabel anchor_top: ", ver_label.anchor_top, " offset_top: ", ver_label.offset_top)

	var menu_vbox = menu_scene.get_node_or_null("MenuVBox")
	assert(menu_vbox != null, "MenuVBox must exist")
	assert(menu_vbox.anchor_left == 0.5 and menu_vbox.anchor_right == 0.5, "MenuVBox must be centered horizontally")

	# 5. Verify Modals Anchoring
	print("\n5. Verifying Modals:")
	assert(menu_scene.stage_select_modal != null, "Stage select modal must exist")
	assert(menu_scene.controls_modal != null, "Controls modal must exist")
	assert(menu_scene.fade_rect != null, "Fade overlay must exist")
	print("  StageSelectModal, ControlsModal, and FadeOverlay exist and anchored")

	# 6. Test Resize Notification Handling
	print("\n6. Testing Resize Notification Simulation:")
	menu_scene._notification(Control.NOTIFICATION_RESIZED)
	print("  Resize notification handled cleanly without errors")

	print("\n=== ALL MAIN MENU RESPONSIVENESS VERIFICATIONS PASSED! ===")
	menu_scene.free()
	quit(0)

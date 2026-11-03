extends SceneTree

var frames = 0
var elapsed = 0.0
var target_times = [0.2, 0.5, 1.0, 2.0, 4.0, 6.0, 8.0, 10.0]
var target_idx = 0
var artifact_dir = "C:/Users/Lin/.gemini/antigravity/brain/370c75b3-591d-4ff9-a2ef-a82753b68d30/"

func _init() -> void:
	print("--- Running Normal Game Launch Diagnostic ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)

	while target_idx < target_times.size():
		await process_frame
		frames += 1
		# assume ~60 fps
		elapsed += 1.0 / 60.0
		if elapsed >= target_times[target_idx]:
			var img = root.get_viewport().get_texture().get_image()
			var filename = "diagnostic_time_%.1fs.png" % target_times[target_idx]
			img.save_png(artifact_dir + filename)
			print("Captured: ", filename, " (visible nodes: splash=", menu.splash_layer.visible if is_instance_valid(menu.splash_layer) else false, 
				  " bg_root=", menu.bg_root.visible if is_instance_valid(menu.bg_root) else false, 
				  " menu_vbox=", menu.menu_vbox.visible if is_instance_valid(menu.menu_vbox) else false, ")")
			target_idx += 1

	print("--- Diagnostic Finished ---")
	quit(0)

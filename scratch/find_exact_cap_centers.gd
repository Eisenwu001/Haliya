extends SceneTree

func _init() -> void:
	var th = load("res://ui/theme/haliya_theme.tres") as Theme

	var tiers = [
		{"tier": "MenuButtonPrimary", "size": 22, "text": "CONTINUE"},
		{"tier": "MenuButtonMedium", "size": 12, "text": "BEGIN JOURNEY"},
		{"tier": "MenuButtonSmall", "size": 10, "text": "SETTINGS"},
		{"tier": "MenuButtonMuted", "size": 9, "text": "QUIT"}
	]

	for t in tiers:
		var btn = Button.new()
		btn.theme = th
		btn.theme_type_variation = t["tier"]
		btn.text = t["text"]
		root.add_child(btn)

		await process_frame
		await process_frame

		var font = btn.get_theme_font(&"font", t["tier"])
		var font_size = btn.get_theme_font_size(&"font_size", t["tier"])
		var ascent = font.get_ascent(font_size)
		var descent = font.get_descent(font_size)
		var total_h = ascent + descent
		print("--- ", t["tier"], " (size ", font_size, ") ---")
		print("Button height: ", btn.size.y, " Font line height: ", total_h, " ascent: ", ascent, " descent: ", descent)

		var img = root.get_viewport().get_texture().get_image()
		# Scale down if viewport was larger
		var sx = img.get_width() / 640.0
		var sy = img.get_height() / 360.0
		var py = []
		for y in range(0, int(btn.size.y * sy) + 5):
			for x in range(0, int(btn.size.x * sx)):
				var p = img.get_pixel(x, y)
				if p.a > 0.5 and (p.r > 0.5 or p.g > 0.5):
					py.append(int(round(y / sy)))
		if py:
			var min_y = py.min()
			var max_y = py.max()
			var cap_cy = (min_y + max_y) / 2.0
			print("Rendered text pixels y: [", min_y, "..", max_y, "] -> visual center = ", cap_cy)
		
		btn.queue_free()
		await process_frame

	quit(0)

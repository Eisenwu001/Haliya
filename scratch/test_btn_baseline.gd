extends SceneTree

func _init() -> void:
	var th = load("res://ui/theme/haliya_theme.tres") as Theme
	var tiers = [
		{"tier": "MenuButtonPrimary", "text": "CONTINUE"},
		{"tier": "MenuButtonMedium", "text": "STAGE SELECT"},
		{"tier": "MenuButtonSmall", "text": "SETTINGS"},
		{"tier": "MenuButtonMuted", "text": "QUIT"}
	]

	var vbox = VBoxContainer.new()
	root.add_child(vbox)

	for t in tiers:
		var btn = Button.new()
		btn.theme = th
		btn.theme_type_variation = t["tier"]
		btn.text = t["text"]
		vbox.add_child(btn)

	await process_frame
	await process_frame

	for i in range(tiers.size()):
		var btn = vbox.get_child(i) as Button
		var font = btn.get_theme_font(&"font", tiers[i]["tier"])
		var font_size = btn.get_theme_font_size(&"font_size", tiers[i]["tier"])
		var ascent = font.get_ascent(font_size)
		var descent = font.get_descent(font_size)
		print(tiers[i]["tier"], ": btn size=", btn.size, " ascent=", ascent, " descent=", descent)

	quit(0)

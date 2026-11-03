extends SceneTree

const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")

func _init() -> void:
	var label = BaybayinLabelScript.new()
	root.add_child(label)
	label.set_text("Haliya", "ᜑᜎᜒᜌ")
	assert(label.baybayin_label.text.contains("ᜑᜎᜒᜌ"), "Baybayin label text should contain haliya glyphs")
	assert(label.english_label.text == "Haliya", "English label text should match")
	label.play_decode_sequence("Emerald Terraces")
	print("PASS: BaybayinLabel component verified!")
	label.queue_free()
	quit(0)

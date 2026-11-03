extends SceneTree

func _init() -> void:
	var font = FontFile.new()
	var bytes = FileAccess.get_file_as_bytes("res://assets/fonts/NotoSansTagalog-Regular.ttf")
	assert(bytes.size() > 0, "Font bytes must not be empty")
	font.data = bytes
	print("NotoSansTagalog loaded via font.data successfully! Byte count:", bytes.size())
	
	var haliya_baybayin = "\u1711\u170e\u1712\u170c" # ᜑᜎᜒᜌ
	var size = font.get_string_size(haliya_baybayin, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
	print("Baybayin string rendered size:", size)
	assert(size.x > 0, "Baybayin string size.x should be > 0")
	print("PASS: Baybayin font loading and rendering verified in Godot 4.7!")
	quit(0)

extends SceneTree

func _init() -> void:
	var bytes = FileAccess.get_file_as_bytes("res://assets/audio/music/kulintang_exploration.mp3")
	assert(bytes.size() > 0, "bytes should not be empty")
	var stream = AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = true
	print("AudioStreamMP3 loaded successfully! Length: ", stream.get_length(), " seconds")
	assert(stream.get_length() > 0.0, "Length should be > 0")
	print("PASS: Kulintang MP3 loaded and parsed by Godot!")
	quit(0)

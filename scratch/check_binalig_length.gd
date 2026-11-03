extends SceneTree

func _init() -> void:
	var bytes = FileAccess.get_file_as_bytes("res://assets/audio/music/kulintang_binalig.mp3")
	var stream = AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = true
	print("kulintang_binalig.mp3 length: ", stream.get_length(), " seconds (approx ", int(stream.get_length()) / 60, " min ", int(stream.get_length()) % 60, " sec)")
	quit(0)

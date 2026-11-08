extends SceneTree

func _init() -> void:
	print("Testing Haliya sprite loading...")
	var player = Player.new()
	player.load_haliya_animations()
	print("Loaded idle frames:", player.idle_frames.size())
	print("Loaded walk frames:", player.walk_frames.size())
	print("Loaded crouch_to_idle frames:", player.crouch_to_idle_frames.size())
	quit()

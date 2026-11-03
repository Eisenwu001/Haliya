extends SceneTree

func _init() -> void:
	var sb = StyleBoxEmpty.new()
	sb.content_margin_left = 2.0
	print("StyleBoxEmpty content_margin_left: ", sb.content_margin_left)
	quit(0)

extends SceneTree

func _init() -> void:
	print("Checking UIConstants...")
	var ui_const = preload("res://ui/theme/ui_theme_constants.gd")
	print("UIConstants OK!")
	print("Checking Main...")
	var main_script = preload("res://scripts/main.gd")
	print("Main script OK!")
	quit(0)

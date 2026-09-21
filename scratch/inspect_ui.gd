extends SceneTree

func _init():
	var paths = [
		"res://assets/ui/hud_hp_bar_frame.png",
		"res://assets/ui/hud_score_plaque.png",
		"res://assets/ui/hud_score_plaque_backed.png",
		"res://assets/ui/hud_score_plaque_new.png",
		"res://assets/ui/hud_zone_ribbon.png",
		"res://assets/ui/hud_controls_badge.png",
		"res://assets/ui/hud_hero_plate.png",
		"res://assets/ui_panel.png"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var tex = load(p)
			if tex:
				print(p, " -> size: ", tex.get_size())
			else:
				print(p, " -> failed to load")
		else:
			print(p, " -> does not exist")
	quit(0)

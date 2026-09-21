extends SceneTree

func _init() -> void:
	var p := CPUParticles2D.new()
	p.particle_flag_align_y = true
	var tex = load("res://assets/vfx/rain_streak_mid.png")
	p.texture = tex
	print("particle_flag_align_y test succeeded!")
	quit(0)

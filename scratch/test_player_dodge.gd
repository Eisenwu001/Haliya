extends SceneTree

func _init() -> void:
	print("Verifying Player and ProceduralAudio...")
	var audio = preload("res://scripts/procedural_audio.gd")
	var menu_m = audio.get_menu_ambient()
	var forest_m = audio.get_forest_ambient()
	var boss_m = audio.get_boss_battle_music()
	var whoosh = audio.get_dodge_whoosh()
	var roar = audio.get_boss_roar()
	print("Audio verification complete: all streams generated!")
	
	var PlayerScript = preload("res://scripts/player.gd")
	var p = PlayerScript.new()
	root.add_child(p)
	print("Player initialized, initial state=", p.current_state)
	p.start_dodge(1.0)
	print("Player dodge started, current state=", p.current_state, " stamina=", p.current_stamina)
	assert(p.current_state == PlayerScript.State.DODGE, "State should be DODGE")
	print("Player Dodge verified successfully!")
	quit()

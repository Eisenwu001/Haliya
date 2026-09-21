@tool
extends SceneTree
func _init():
    var p = AudioStreamPlayer2D.new()
    print('panning_strength:', p.panning_strength)
    print('max_distance:', p.max_distance)
    print('attenuation:', p.attenuation)
    print('volume_db:', p.volume_db)
    quit(0)

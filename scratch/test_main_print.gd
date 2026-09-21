extends SceneTree

func _init():
	var main_scn = load('res://scenes/main.tscn')
	var main_inst = main_scn.instantiate()
	root.add_child(main_inst)
	# Process one frame so _ready runs
	process_frame

extends Node

func _ready():
	get_viewport().size = Vector2i(1280, 720)
	var main_scn = load('res://scenes/main.tscn')
	var main_inst = main_scn.instantiate()
	add_child(main_inst)
	# Wait 3 frames
	for i in range(5):
		await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	img.save_png('scratch/main_screen.png')
	print('Saved screenshot to scratch/main_screen.png')
	get_tree().quit(0)

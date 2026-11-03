extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	MainScript.start_level_idx = 11
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	for f in range(10):
		await process_frame
		
	var inst = main.current_level_instance
	print("Current level name: ", inst.name)
	for c in inst.get_children():
		print("  Child: ", c.name, " (", c.get_class(), ")")
		
	var bg = inst.find_child("BaseGround", false, false) as TileMapLayer
	if bg:
		print("BaseGround tile at (50, 8): ", bg.get_cell_source_id(Vector2i(50, 8)))
		print("BaseGround tile at (50, 9): ", bg.get_cell_source_id(Vector2i(50, 9)))
		
	main.free()
	quit(0)

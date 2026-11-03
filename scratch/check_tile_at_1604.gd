extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	main.jump_to_level(11)
	await create_timer(0.2).timeout
	
	var inst = main.current_level_instance
	var bg = inst.find_child("BaseGround", true, false) as TileMapLayer
	if bg:
		print("BaseGround layer found. Checking tile at world X=1604, Y=256:")
		var local_pos = bg.to_local(Vector2(1604, 256))
		var map_pos = bg.local_to_map(local_pos)
		print("Map coords: ", map_pos, " Cell source: ", bg.get_cell_source_id(map_pos), " atlas_coords: ", bg.get_cell_atlas_coords(map_pos))
		var td = bg.get_cell_tile_data(map_pos)
		if td:
			print("TileData found! Collision polygons: ", td.get_collision_polygons_count(0))
		else:
			print("No TileData at map_pos!")
			
		# Also check if another tilemap layer exists in current_level_instance
		for c in inst.get_children():
			if c is TileMapLayer:
				print("TileMapLayer: ", c.name, " z_index: ", c.z_index, " collision_enabled: ", c.collision_enabled)

	main.free()
	quit(0)

extends SceneTree

func _init() -> void:
	var s = load("res://scenes/scene_03.tscn").instantiate()
	var tile_data = s.tile_set.get_source(2).get_tile_data(Vector2i(0, 0), 0)
	print("scene_03 water 0:0 collision polygons count: ", tile_data.get_collision_polygons_count(0))
	quit(0)

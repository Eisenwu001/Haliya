@tool
extends SceneTree

const FLOOR_TILES_2_TEX = preload("res://assets/platform_assets/Floor Tiles2.png")
const OTHER_TILES_2_TEX = preload("res://assets/platform_assets/Other Tiles2.png")
const ORES_TEX = preload("res://assets/platform_assets/Ores.png")

func _init() -> void:
	var ts: TileSet = load("res://scenes/tileset.tres")
	if not ts:
		printerr("Failed to load tileset.tres")
		quit(1)
		return

	var poly_points = PackedVector2Array([
		Vector2(-16, -16),
		Vector2(16, -16),
		Vector2(16, 16),
		Vector2(-16, 16)
	])

	# 1. Source 8: Floor Tiles2.png (288x576 -> 9 cols x 18 rows)
	if ts.has_source(8):
		ts.remove_source(8)
	var s8 = TileSetAtlasSource.new()
	s8.texture = FLOOR_TILES_2_TEX
	s8.texture_region_size = Vector2i(32, 32)
	for r in range(18):
		for c in range(9):
			s8.create_tile(Vector2i(c, r))
	ts.add_source(s8, 8)

	for r in range(18):
		for c in range(9):
			var td = s8.get_tile_data(Vector2i(c, r), 0)
			if td:
				if td.get_collision_polygons_count(0) == 0:
					td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, poly_points)
	print("Added Source 8 (Floor Tiles2): %d tiles with collisions" % s8.get_tiles_count())

	# 2. Source 9: Other Tiles2.png (288x224 -> 9 cols x 7 rows)
	if ts.has_source(9):
		ts.remove_source(9)
	var s9 = TileSetAtlasSource.new()
	s9.texture = OTHER_TILES_2_TEX
	s9.texture_region_size = Vector2i(32, 32)
	for r in range(7):
		for c in range(9):
			s9.create_tile(Vector2i(c, r))
	ts.add_source(s9, 9)

	for r in range(7):
		for c in range(9):
			var td = s9.get_tile_data(Vector2i(c, r), 0)
			if td:
				if td.get_collision_polygons_count(0) == 0:
					td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, poly_points)
	print("Added Source 9 (Other Tiles2): %d tiles with collisions" % s9.get_tiles_count())

	# 3. Source 11: Ores.png (128x128 -> 4 cols x 4 rows) - Non-solid decor
	if ts.has_source(11):
		ts.remove_source(11)
	var s11 = TileSetAtlasSource.new()
	s11.texture = ORES_TEX
	s11.texture_region_size = Vector2i(32, 32)
	for r in range(4):
		for c in range(4):
			s11.create_tile(Vector2i(c, r))
	ts.add_source(s11, 11)
	print("Added Source 11 (Ores): %d tiles" % s11.get_tiles_count())

	var err = ResourceSaver.save(ts, "res://scenes/tileset.tres")
	if err != OK:
		printerr("Failed to save tileset.tres: ", err)
		quit(1)
		return

	print("Successfully updated and saved res://scenes/tileset.tres without errors!")
	quit(0)

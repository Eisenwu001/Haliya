extends SceneTree

const LevelBuilderScript = preload("res://scripts/level_builder.gd")
const AswangScript = preload("res://scripts/aswang.gd")
const SkeletonScript = preload("res://scripts/skeleton.gd")
const AssetsScript = preload("res://scripts/assets.gd")

func set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)

func _init() -> void:
	var root_node = Node2D.new()
	root_node.name = "Level_1_1"
	
	# 1. BaseGround TileMapLayer
	var ground_tm = TileMapLayer.new()
	ground_tm.name = "BaseGround"
	ground_tm.tile_set = load("res://scenes/tileset.tres")
	root_node.add_child(ground_tm)
	
	# Set some ground tiles
	for col in range(0, 160):
		# Ground surface at row 9 (Y=288)
		ground_tm.set_cell(Vector2i(col, 9), 0, Vector2i(2, 0))
		for row in range(10, 14):
			ground_tm.set_cell(Vector2i(col, row), 0, Vector2i(6, 1))
	
	# 2. LevelBuilder nodes
	var builder_container = Node2D.new()
	builder_container.name = "LevelElements"
	root_node.add_child(builder_container)
	LevelBuilderScript.build_level(builder_container, 0, "Forest")
	
	# 3. Enemies
	var enemies = Node2D.new()
	enemies.name = "Enemies"
	root_node.add_child(enemies)
	
	var aswang = AswangScript.new()
	aswang.name = "Aswang_01"
	aswang.position = Vector2(800.0, 260.0)
	enemies.add_child(aswang)
	
	var skeleton = SkeletonScript.new()
	skeleton.name = "Skeleton_01"
	skeleton.position = Vector2(1100.0, 220.0)
	enemies.add_child(skeleton)
	
	# 4. Portal
	var portal = Sprite2D.new()
	portal.name = "LevelExitPortal"
	portal.texture = load(AssetsScript.PATH_PORTAL)
	portal.region_enabled = true
	portal.region_rect = Rect2(0, 0, 64, 64)
	portal.position = Vector2(4900.0, 288.0)
	portal.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root_node.add_child(portal)
	
	# Set owner recursively so all nodes are saved
	set_owner_recursive(root_node, root_node)
	
	var packed = PackedScene.new()
	var err = packed.pack(root_node)
	print("Packed result: ", err)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/forest/test_pack.tscn")
		print("Save result: ", save_err)
		
		# Now test loading it back!
		var loaded = load("res://scenes/forest/test_pack.tscn")
		var inst = loaded.instantiate()
		print("Loaded successfully! Child count: ", inst.get_child_count())
		for child in inst.get_children():
			print(" - Child: ", child.name, " (", child.get_class(), ")")
	
	quit(0)

@tool
extends SceneTree

func set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		set_owner_recursive(child, root_node)

func duplicate_scene(source_path: String, target_path: String, new_name: String):
	var src_scene = load(source_path) as PackedScene
	var inst = src_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	inst.name = new_name
	set_owner_recursive(inst, inst)
	
	var packed = PackedScene.new()
	var pack_err = packed.pack(inst)
	print("Pack ", new_name, ": ", pack_err)
	if pack_err == OK:
		var save_err = ResourceSaver.save(packed, target_path)
		print("Save to ", target_path, ": ", save_err)
	inst.free()

func _init():
	print("Duplicating level_2_1 to level_2_2 and level_2_3...")
	duplicate_scene("res://scenes/rice_field/level_2_1.tscn", "res://scenes/rice_field/level_2_2.tscn", "Level_2_2")
	duplicate_scene("res://scenes/rice_field/level_2_1.tscn", "res://scenes/rice_field/level_2_3.tscn", "Level_2_3")
	
	# Verify both can be loaded
	for path in ["res://scenes/rice_field/level_2_2.tscn", "res://scenes/rice_field/level_2_3.tscn"]:
		var loaded = load(path) as PackedScene
		var inst = loaded.instantiate()
		print("Verified ", path, " -> Root name: ", inst.name, " children: ", inst.get_child_count())
		var base_ground = inst.find_child("BaseGround") as TileMapLayer
		if base_ground:
			print("  BaseGround cell count: ", base_ground.get_used_cells().size())
		var breakables = inst.find_child("Breakables")
		if breakables:
			print("  Breakables count: ", breakables.get_child_count())
		var enemies = inst.find_child("Enemies")
		if enemies:
			print("  Enemies count: ", enemies.get_child_count())
		inst.free()
		
	quit()

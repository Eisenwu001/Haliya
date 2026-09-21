@tool
extends SceneTree

func _init():
	var levels = [
		"res://scenes/forest/level_1_1.tscn",
		"res://scenes/forest/level_1_2.tscn",
		"res://scenes/forest/level_1_3.tscn",
		"res://scenes/rice_field/level_2_1.tscn",
		"res://scenes/rice_field/level_2_2.tscn",
		"res://scenes/rice_field/level_2_3.tscn"
	]
	
	for path in levels:
		print("========================================")
		print("Checking all collision shapes at end for: ", path)
		var scene = load(path)
		var inst = scene.instantiate()
		root.add_child(inst)
		
		# Check all children recursively
		var nodes_to_check = [inst]
		while nodes_to_check.size() > 0:
			var n = nodes_to_check.pop_back()
			for c in n.get_children():
				nodes_to_check.append(c)
			
			if n is CollisionShape2D or n is CollisionPolygon2D:
				var parent = n.get_parent()
				var gpos = n.global_position
				if gpos.x > 4500.0 or (parent and parent.global_position.x > 4500.0):
					print("  CollNode: ", n.name, " parent: ", parent.name, " (", parent.get_class(), ") pos: ", n.position, " gpos: ", gpos)
			elif n is StaticBody2D or n is Area2D:
				if n.global_position.x > 4500.0:
					print("  Body/Area: ", n.name, " (", n.get_class(), ") gpos: ", n.global_position)
		
		inst.free()
	quit()

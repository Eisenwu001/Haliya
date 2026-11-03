extends SceneTree

func _init() -> void:
	var MainScript = load("res://scripts/main.gd")
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	for lvl_idx in [11, 12, 13, 14]:
		main.jump_to_level(lvl_idx)
		await create_timer(0.2).timeout
		var p = main.player
		var space = p.get_world_2d().direct_space_state
		
		print("\n==========================================")
		print("AUDITING WALK PATH FOR LEVEL IDX ", lvl_idx, " (", main.LEVELS_DATA[lvl_idx]["level_title"], ")")
		print("==========================================")
		
		var float_issues = []
		var invisible_blocks = []
		
		for x in range(100, 5100, 32):
			var q = PhysicsRayQueryParameters2D.create(Vector2(x, 150), Vector2(x, 350))
			q.exclude = [p.get_rid()]
			var res = space.intersect_ray(q)
			if res:
				var hit_y = res.position.y
				var col = res.collider
				var col_name = col.name if col else "unknown"
				var col_parent = col.get_parent().name if (col and col.get_parent()) else ""
				
				if "Crumble" in col_name or "crumble" in col_name.to_lower():
					invisible_blocks.append({"x": x, "y": hit_y, "name": col_name, "parent": col_parent})
				elif col_name == "BaseGround":
					if hit_y != 288.0:
						float_issues.append({"x": x, "hit_y": hit_y, "col": col_name, "collider": str(col)})
				elif "Platform" in col_name:
					pass
				elif "Geode" in col_name or "Pot" in col_name:
					float_issues.append({"x": x, "hit_y": hit_y, "col": col_name, "collider": str(col)})
				else:
					float_issues.append({"x": x, "hit_y": hit_y, "col": col_name, "collider": str(col)})

		print("Found ", invisible_blocks.size(), " Crumble / Invisible block hits:")
		for ib in invisible_blocks:
			print("  Invisible Block at X=", ib["x"], " Y=", ib["y"], " Name=", ib["name"], " Parent=", ib["parent"])
			
		print("Other hits on walk path: ", float_issues.size())
		for fi in float_issues.slice(0, 15):
			print("  Hit at X=", fi["x"], " Y=", fi["hit_y"], " col=", fi["col"], " obj=", fi["collider"])
			
	main.free()
	quit(0)

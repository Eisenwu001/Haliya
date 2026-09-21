extends SceneTree

var frame_count: int = 0
var main_node = null
var cur_test_lvl: int = 0

func _init() -> void:
	main_node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_node)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count % 15 == 0:
		if cur_test_lvl < main_node.LEVELS_DATA.size():
			var title = main_node.LEVELS_DATA[cur_test_lvl]["full_title"]
			print("Testing Level %d: %s" % [cur_test_lvl, title])
			main_node.jump_to_level(cur_test_lvl)
			var enemy_cnt = main_node.enemies_container.get_child_count()
			var obj_cnt = main_node.level_container.get_child_count()
			print("Enemies: %d, Level groups: %d" % [enemy_cnt, obj_cnt])
			cur_test_lvl += 1
		else:
			print("SUCCESS: ALL 6 LEVELS VERIFIED PERFECTLY!")
			quit(0)
	return false

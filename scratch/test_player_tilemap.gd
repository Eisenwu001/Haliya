extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")

func _init() -> void:
	var root_node = Node2D.new()
	
	# 1. BaseGround TileMapLayer
	var ground_tm = TileMapLayer.new()
	ground_tm.name = "BaseGround"
	ground_tm.tile_set = load("res://scenes/tileset.tres")
	root_node.add_child(ground_tm)
	
	# Surface at row 9 (Y=288)
	for col in range(0, 50):
		ground_tm.set_cell(Vector2i(col, 9), 0, Vector2i(2, 0)) # grass top with collision
		for row in range(10, 14):
			ground_tm.set_cell(Vector2i(col, row), 0, Vector2i(6, 1))
	
	# 2. Player
	var player = PlayerScript.new()
	player.name = "Player"
	player.position = Vector2(192.0, 260.0) # slightly above row 9
	root_node.add_child(player)
	
	root.add_child(root_node)

var frames = 0
func _process(_delta: float) -> bool:
	frames += 1
	var player = root.find_child("Player", true, false)
	if frames < 30:
		return false
	
	print("Frame 30: Player Y = ", player.position.y, " is_on_floor = ", player.is_on_floor())
	if player.is_on_floor() and abs(player.position.y - 288.0) < 5.0:
		print("SUCCESS: Player landed and is solid on BaseGround TileMapLayer!")
	else:
		print("FAILED: Player did not land on BaseGround! Y=", player.position.y)
	quit(0)
	return false

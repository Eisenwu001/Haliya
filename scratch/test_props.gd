extends SceneTree

const BahayKuboProp = preload("res://scripts/bahay_kubo_prop.gd")
const BambooFlumeProp = preload("res://scripts/bamboo_flume_prop.gd")

func _init() -> void:
	print("[TEST] Testing pixel-art rice field props...")
	var kubo = BahayKuboProp.new()
	root.add_child(kubo)
	if not kubo.is_node_ready():
		kubo._ready()
	assert(kubo.get_child_count() == 3, "Kubo should have Sprite + 2 collision platforms")
	
	var flume = BambooFlumeProp.new()
	root.add_child(flume)
	if not flume.is_node_ready():
		flume._ready()
	assert(flume.get_child_count() >= 2, "Flume should have Sprite + collision platform")
	
	print("[TEST PASS] Pixel-art rice field props verified!")
	kubo.free()
	flume.free()
	quit(0)

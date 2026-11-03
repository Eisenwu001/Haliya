class_name BambooFlumeProp
extends StaticBody2D

## BambooFlumeProp - Traditional Philippine Bamboo Water Flume (Patubig)
## Delivers mountain water across terraced paddies.
## Sturdy A-frame trestles ground the structure at local y = 0.0; top bamboo channel serves as a jump platform at y = -46.0.

const FLUME_TEX = preload("res://assets/rice_field/bamboo_flume.png")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var spr = Sprite2D.new()
	spr.texture = FLUME_TEX
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Image is 144x56, anchored so bottom of trestles rests at local y = 0.0
	spr.offset = Vector2(0.0, -28.0)
	spr.z_index = -1
	add_child(spr)

	# Water trough platform (top edge at y = -46.0)
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(124.0, 8.0)
	col.shape = box
	col.position = Vector2(-6.0, -42.0)
	col.one_way_collision = true
	col.one_way_collision_margin = 4.0
	add_child(col)

	# Water splash particles at spout (right end)
	var splash = CPUParticles2D.new()
	splash.emitting = true
	splash.amount = 10
	splash.lifetime = 0.65
	splash.direction = Vector2(0.3, -1.0)
	splash.spread = 45.0
	splash.gravity = Vector2(0.0, 240.0)
	splash.initial_velocity_min = 18.0
	splash.initial_velocity_max = 38.0
	splash.scale_amount_min = 1.2
	splash.scale_amount_max = 2.4
	splash.color = Color(0.55, 0.88, 1.0, 0.80)
	splash.position = Vector2(64.0, -2.0)
	add_child(splash)

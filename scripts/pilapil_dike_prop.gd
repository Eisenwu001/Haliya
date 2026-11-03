class_name PilapilDikeProp
extends StaticBody2D

## PilapilDikeProp - Traditional Terraced Stone & Earthen Dike (Pilapil)
## Raised platform ledge between flooded rice terraces allowing safe footing above mud hazards.

const TEX_DIKE = preload("res://assets/rice_field/pilapil_dike.png")

var sprite: Sprite2D
var col_shape: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	
	sprite = Sprite2D.new()
	sprite.texture = TEX_DIKE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Image is 120x32; top grass surface aligns with local y = 0.0
	sprite.position = Vector2(0.0, 14.0)
	sprite.z_index = -1
	add_child(sprite)
	
	col_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(116.0, 28.0)
	col_shape.shape = rect
	col_shape.position = Vector2(0.0, 14.0)
	col_shape.one_way_collision = true
	col_shape.one_way_collision_margin = 4.0
	add_child(col_shape)

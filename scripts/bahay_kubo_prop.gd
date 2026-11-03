class_name BahayKuboProp
extends StaticBody2D

## BahayKuboProp - Authentic Philippine Stilt Nipa Hut (16-Bit 2D Platformer Prop)
## Grounded bamboo stilts rooted at local y = 0.0 with 3-tier one-way jumpable platforms:
## - Tier 1: Slatted bamboo porch deck (y = -48.0, width 182px)
## - Tier 2: Thatched nipa eaves ledge (y = -96.0, width 168px)
## - Tier 3: Bamboo roof ridge peak (y = -138.0, width 96px)

const KUBO_TEX = preload("res://assets/rice_field/bahay_kubo.png")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var spr = Sprite2D.new()
	spr.texture = KUBO_TEX
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Image is 192x144; bottom of stilts rests at local y = 0.0
	spr.offset = Vector2(0.0, -72.0)
	spr.z_index = -1
	add_child(spr)

	# Tier 1: Slatted Bamboo Porch Deck (y = -48.0)
	var deck_col = CollisionShape2D.new()
	var deck_box = RectangleShape2D.new()
	deck_box.size = Vector2(182.0, 8.0)
	deck_col.shape = deck_box
	deck_col.position = Vector2(0.0, -44.0)
	deck_col.one_way_collision = true
	deck_col.one_way_collision_margin = 5.0
	add_child(deck_col)

	# Tier 2: Thatched Nipa Eaves Ledge (y = -96.0)
	var eaves_col = CollisionShape2D.new()
	var eaves_box = RectangleShape2D.new()
	eaves_box.size = Vector2(168.0, 8.0)
	eaves_col.shape = eaves_box
	eaves_col.position = Vector2(0.0, -92.0)
	eaves_col.one_way_collision = true
	eaves_col.one_way_collision_margin = 5.0
	add_child(eaves_col)

	# Tier 3: Top Bamboo Roof Ridge (y = -138.0)
	var ridge_col = CollisionShape2D.new()
	var ridge_box = RectangleShape2D.new()
	ridge_box.size = Vector2(96.0, 8.0)
	ridge_col.shape = ridge_box
	ridge_col.position = Vector2(0.0, -134.0)
	ridge_col.one_way_collision = true
	ridge_col.one_way_collision_margin = 5.0
	add_child(ridge_col)

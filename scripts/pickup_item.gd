class_name PickupItem
extends Area2D

enum Type {
	HEALTH_DUMPLING,
	STAMINA_TALISMAN
}

@export var pickup_type: Type = Type.HEALTH_DUMPLING

const TEX_DUMPLING = preload("res://assets/props/pickup_dumpling.png")
const TEX_TALISMAN = preload("res://assets/props/pickup_talisman.png")
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")

var sprite: Sprite2D
var light: PointLight2D
var base_y: float = 0.0
var float_timer: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	collision_layer = 16
	collision_mask = 2 # Player layer
	
	base_y = position.y
	float_timer = randf() * 6.28 # Randomize initial phase
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	col.shape = shape
	add_child(col)
	
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if pickup_type == Type.HEALTH_DUMPLING:
		sprite.texture = TEX_DUMPLING
	else:
		sprite.texture = TEX_TALISMAN
	add_child(sprite)
	
	# Glowing aura
	light = PointLight2D.new()
	light.texture = LIGHT_TEX
	light.texture_scale = 0.06
	if pickup_type == Type.HEALTH_DUMPLING:
		light.color = Color(0.4, 1.0, 0.5, 0.75) # Warm green
	else:
		light.color = Color(1.0, 0.85, 0.35, 0.85) # Radiant amber
	light.energy = 0.8
	add_child(light)
	
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	float_timer += delta * 4.0
	sprite.position.y = sin(float_timer) * 3.0
	light.position.y = sprite.position.y
	light.energy = 0.75 + 0.25 * sin(float_timer * 1.5)

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body is Player or body.is_in_group("player"):
		is_collected = true
		if pickup_type == Type.HEALTH_DUMPLING:
			if body.has_method("heal"):
				body.heal(1)
		else:
			if body.has_method("restore_stamina"):
				body.restore_stamina(60.0)
		
		# Collection bounce and fade
		var tween = create_tween()
		tween.tween_property(sprite, "position:y", sprite.position.y - 20.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
		tween.parallel().tween_property(light, "energy", 0.0, 0.25)
		tween.tween_callback(queue_free)

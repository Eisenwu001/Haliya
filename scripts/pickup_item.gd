class_name PickupItem
extends Area2D

const ProceduralAudioScript = preload("res://scripts/procedural_audio.gd")
const MetaProgression = preload("res://scripts/meta_progression.gd")
const VFXScript = preload("res://scripts/vfx.gd")

enum Type {
	HEALTH_DOT,
	STAMINA_TALISMAN,
	MOON_PEARL
}

@export var pickup_type: Type = Type.HEALTH_DOT
var is_moon_pearl: bool = false

const TEX_HEALTH_DOT = preload("res://assets/props/pickup_health_dot.png")
const TEX_TALISMAN = preload("res://assets/props/pickup_talisman.png")
const TEX_MOON_PEARL = preload("res://assets/props/pickup_moon_pearl.png")
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")

var sprite: Sprite2D
var light: PointLight2D
var base_y: float = 0.0
var float_timer: float = 0.0
var is_collected: bool = false
var is_settled: bool = true

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	collision_layer = 16
	collision_mask = 2 | 1 # Detect Player (Layer 2 or fallback Layer 1)
	
	base_y = position.y
	float_timer = randf() * 6.28 # Randomize initial phase
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20.0 # Generous pickup radius so player easily collects
	col.shape = shape
	add_child(col)
	
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if is_moon_pearl:
		pickup_type = Type.MOON_PEARL
	if pickup_type == Type.MOON_PEARL:
		sprite.texture = TEX_MOON_PEARL
	elif pickup_type == Type.HEALTH_DOT:
		sprite.texture = TEX_HEALTH_DOT
	else:
		sprite.texture = TEX_TALISMAN
	add_child(sprite)
	
	# Glowing aura
	light = PointLight2D.new()
	light.texture = LIGHT_TEX
	light.texture_scale = 0.065
	if pickup_type == Type.MOON_PEARL:
		light.color = Color(0.45, 0.90, 1.0, 0.90) # Radiant cyan-silver lunar glow
	elif pickup_type == Type.HEALTH_DOT:
		light.color = Color(1.0, 0.25, 0.35, 0.85) # Luminous ruby vitality glow
	else:
		light.color = Color(1.0, 0.85, 0.35, 0.85) # Radiant amber
	light.energy = 0.85
	add_child(light)
	
	body_entered.connect(_on_body_entered)

func launch_scatter(offset: Vector2) -> void:
	is_settled = false
	var start_pos = global_position
	var target_pos = start_pos + offset
	var peak_y = min(start_pos.y, target_pos.y) - randf_range(16.0, 26.0)
	
	var x_tween = create_tween()
	x_tween.tween_property(self, "global_position:x", target_pos.x, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var y_tween = create_tween()
	y_tween.tween_property(self, "global_position:y", peak_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	y_tween.tween_property(self, "global_position:y", target_pos.y, 0.24).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	y_tween.tween_callback(func():
		base_y = position.y
		is_settled = true
	)

func _process(delta: float) -> void:
	if is_collected:
		return
	if not is_settled:
		return
	float_timer += delta * 4.0
	sprite.position.y = sin(float_timer) * 3.0
	light.position.y = sprite.position.y
	light.energy = 0.75 + 0.25 * sin(float_timer * 1.5)

	# Overlap safety check in case player was already standing on item when it spawned
	for b in get_overlapping_bodies():
		if _try_collect(b):
			break

func _on_body_entered(body: Node2D) -> void:
	_try_collect(body)

func _try_collect(body: Node2D) -> bool:
	if is_collected:
		return false
	
	if body is Player or body.is_in_group("player") or body.name == "Player":
		is_collected = true
		if pickup_type == Type.MOON_PEARL or is_moon_pearl:
			MetaProgression.add_moon_pearls(15)
			if body.has_method("heal"):
				body.heal(1)
			if VFXScript:
				var parent_node = get_parent()
				if is_instance_valid(parent_node):
					VFXScript.spawn_floating_text(parent_node, global_position + Vector2(0, -14), "+15 MOON PEARLS", Color(0.55, 0.92, 1.0))
			var main_node = get_tree().root.get_node_or_null("Main") if is_inside_tree() else null
			if is_instance_valid(main_node) and main_node.get("pearl_hud_label"):
				main_node.pearl_hud_label.text = str(MetaProgression.get_moon_pearls())
			_play_pickup_sfx(true)
		elif pickup_type == Type.HEALTH_DOT:
			if body.has_method("heal"):
				body.heal(1)
			_play_pickup_sfx(true)
		else:
			if body.has_method("restore_stamina"):
				body.restore_stamina(60.0)
			_play_pickup_sfx(false)
		
		# Collection bounce, glint, and fade
		if is_instance_valid(sprite):
			var tween = create_tween()
			tween.tween_property(sprite, "position:y", sprite.position.y - 18.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.22)
			tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.22)
			if is_instance_valid(light):
				tween.parallel().tween_property(light, "energy", 0.0, 0.22)
			tween.tween_callback(queue_free)
		else:
			queue_free()
		return true
	return false

func _play_pickup_sfx(is_health: bool) -> void:
	if not is_inside_tree():
		return
	var audio := AudioStreamPlayer2D.new()
	audio.bus = "Master"
	if is_health and ProceduralAudioScript:
		audio.stream = ProceduralAudioScript.get_health_dot_pickup_sfx()
	elif ProceduralAudioScript:
		audio.stream = ProceduralAudioScript.get_ui_select()
	audio.position = global_position
	var p = get_parent()
	if is_instance_valid(p):
		p.add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	else:
		audio.queue_free()

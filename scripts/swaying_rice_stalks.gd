class_name SwayingRiceStalks
extends Node2D

## SwayingRiceStalks - Responsive golden palay (rice) vegetation
## Sways gently in the breeze and bends dynamically as characters rush through.

const STALKS_TEX_WIDE = preload("res://assets/rice_field/palay_cluster_wide.png")
const STALKS_TEX_SINGLE = preload("res://assets/rice_field/palay_stalks_detailed.png")

@export var is_wide_cluster: bool = true

var sprite: Sprite2D
var area: Area2D
var phase_offset: float = 0.0
var bend_angle: float = 0.0
var return_speed: float = 7.0

func _ready() -> void:
	phase_offset = randf_range(0.0, 6.28)

	sprite = Sprite2D.new()
	sprite.texture = STALKS_TEX_WIDE if is_wide_cluster else STALKS_TEX_SINGLE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Anchor at bottom center so rotation/skew pivots from roots
	sprite.offset = Vector2(0.0, -19.0)
	add_child(sprite)

	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2 | 4 # Player (2) and Enemies (4)
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var w = 56.0 if is_wide_cluster else 28.0
	rect.size = Vector2(w, 28.0)
	col.shape = rect
	col.position = Vector2(0.0, -14.0)
	area.add_child(col)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

func _process(delta: float) -> void:
	# Gentle ambient wind sway
	var t = Time.get_ticks_msec() * 0.003 + phase_offset
	var wind_sway = sin(t) * 0.08 + sin(t * 1.8) * 0.035
	
	# Relax bend back to 0
	bend_angle = lerp(bend_angle, 0.0, delta * return_speed)
	
	sprite.skew = wind_sway + bend_angle

func _on_body_entered(body: Node2D) -> void:
	var vel_x: float = 0.0
	if "velocity" in body:
		vel_x = body.velocity.x
	elif "linear_velocity" in body:
		vel_x = body.linear_velocity.x
	
	if abs(vel_x) > 10.0:
		# Bend in direction of character movement
		bend_angle = clamp(sign(vel_x) * 0.32, -0.40, 0.40)
		_emit_rustle_chaff()

func _emit_rustle_chaff() -> void:
	if randf() < 0.45:
		var p = CPUParticles2D.new()
		p.emitting = true
		p.one_shot = true
		p.explosiveness = 0.8
		p.amount = 4
		p.lifetime = 0.5
		p.direction = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()
		p.spread = 45.0
		p.gravity = Vector2(0, 120)
		p.initial_velocity_min = 20.0
		p.initial_velocity_max = 45.0
		p.color = Color(0.98, 0.84, 0.35, 0.9)
		p.scale_amount_min = 1.0
		p.scale_amount_max = 2.0
		p.position = Vector2(randf_range(-8.0, 8.0), -24.0)
		add_child(p)
		get_tree().create_timer(0.6).timeout.connect(p.queue_free)

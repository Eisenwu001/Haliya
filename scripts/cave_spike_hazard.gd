class_name CaveSpikeHazard
extends Area2D

const CaveAssetsScript = preload("res://scripts/cave_assets.gd")

@export var hazard_width: float = 160.0
@export var safe_respawn_pos: Vector2 = Vector2.ZERO


func _init(w: float = 160.0, respawn_pos: Vector2 = Vector2.ZERO) -> void:
	hazard_width = w
	safe_respawn_pos = respawn_pos


func _ready() -> void:
	add_to_group("spike_hazards")
	collision_layer = 0
	collision_mask = 2 # Player layer

	if not get_node_or_null("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var rect := RectangleShape2D.new()
		rect.size = Vector2(max(32.0, hazard_width - 8.0), 24.0)
		col.shape = rect
		col.position = Vector2(hazard_width * 0.5, 16.0)
		add_child(col)

	if not get_node_or_null("SpikeVisuals"):
		var vis := Node2D.new()
		vis.name = "SpikeVisuals"
		add_child(vis)

		var props_tex := CaveAssetsScript.get_props_tex()
		var seg_count: int = max(1, int(ceil(hazard_width / 96.0)))
		for i in range(seg_count):
			var seg_w: float = min(96.0, hazard_width - i * 96.0)
			if seg_w <= 4.0:
				break
			var spr := Sprite2D.new()
			spr.texture = props_tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.region_enabled = true
			spr.region_rect = Rect2(64, 64, seg_w, 32)
			spr.position = Vector2(i * 96.0 + seg_w * 0.5, 16.0)
			spr.z_index = 0
			vis.add_child(spr)

		var light_tex = load("res://assets/vfx/radial_light_falloff.png")
		if light_tex:
			var pl := PointLight2D.new()
			pl.texture = light_tex
			pl.position = Vector2(hazard_width * 0.5, 12.0)
			pl.color = Color(0.20, 0.45, 0.65, 0.55)
			pl.energy = 0.55
			pl.texture_scale = 0.35
			vis.add_child(pl)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func trigger_pogo_bounce(player: CharacterBody2D) -> bool:
	if not is_instance_valid(player):
		return false
	if player.has_method("trigger_spike_pogo"):
		player.trigger_spike_pogo(self)
		return true
	return false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Hollow Knight Down-Slash Pogo Check:
	# If player is airborne and performing an attack downward, pogo bounce instead of damage!
	if body.get("spike_pogo_immunity_timer") != null and body.spike_pogo_immunity_timer > 0.0:
		return
	
	if body.get("is_air_attack") == true and body.velocity.y >= -80.0:
		trigger_pogo_bounce(body as CharacterBody2D)
		return
	
	if body.has_method("respawn_at_safe_ledge"):
		if safe_respawn_pos != Vector2.ZERO and "last_safe_ground_pos" in body:
			body.last_safe_ground_pos = safe_respawn_pos
		body.respawn_at_safe_ledge(1)

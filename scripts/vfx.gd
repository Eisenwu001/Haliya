class_name VFX
extends RefCounted

const PARRY_CLASH_TEX = preload("res://assets/vfx/vfx_parry_clash.png")
const RIPOSTE_SLASH_TEX = preload("res://assets/vfx/vfx_riposte_slash.png")
const GUARD_IMPACT_TEX = preload("res://assets/vfx/vfx_guard_impact.png")
const STUN_STARS_TEX = preload("res://assets/vfx/vfx_stun_stars.png")
const BLOOD_SLASH_TEX = preload("res://assets/vfx/vfx_blood_slash.png")
const FONT_ALAGARD = preload("res://alagard.ttf")

static func spawn_animated_vfx(parent: Node, texture: Texture2D, pos: Vector2, hframes: int, vframes: int = 1, total_frames: int = 0, fps: float = 24.0, vfx_scale: Vector2 = Vector2(1, 1), flip_h: bool = false) -> Sprite2D:
	if not is_instance_valid(parent) or not texture:
		return null
	
	var spr := Sprite2D.new()
	spr.texture = texture
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.hframes = hframes
	spr.vframes = vframes
	spr.frame = 0
	spr.centered = true
	spr.global_position = pos
	spr.scale = vfx_scale
	spr.flip_h = flip_h
	spr.z_index = 25
	
	parent.add_child(spr)
	
	var count: int = total_frames if total_frames > 0 else (hframes * vframes)
	var frame_dur: float = 1.0 / fps
	_step_frame(spr, 0, count, frame_dur)
	return spr

static func _step_frame(spr: Sprite2D, current_frame: int, total_frames: int, frame_dur: float) -> void:
	if not is_instance_valid(spr):
		return
	
	if current_frame >= total_frames - 1:
		spr.queue_free()
		return
	
	spr.get_tree().create_timer(frame_dur, false, false, true).timeout.connect(func():
		if is_instance_valid(spr):
			spr.frame = current_frame + 1
			_step_frame(spr, current_frame + 1, total_frames, frame_dur)
	)

static func spawn_parry_clash(parent: Node, pos: Vector2) -> Sprite2D:
	return spawn_animated_vfx(parent, PARRY_CLASH_TEX, pos, 2, 2, 4, 20.0, Vector2(0.08, 0.08))

static func spawn_riposte_slash(parent: Node, pos: Vector2, flip_h: bool = false) -> Sprite2D:
	return spawn_animated_vfx(parent, RIPOSTE_SLASH_TEX, pos, 3, 2, 6, 22.0, Vector2(0.16, 0.16), flip_h)

static func spawn_guard_impact(parent: Node, pos: Vector2) -> Sprite2D:
	return spawn_animated_vfx(parent, GUARD_IMPACT_TEX, pos, 3, 2, 6, 22.0, Vector2(0.09, 0.09))

static func spawn_blood_slash(parent: Node, pos: Vector2, flip_h: bool = false, vfx_scale: Vector2 = Vector2(1.0, 1.0)) -> Sprite2D:
	var final_scale = vfx_scale * 0.135
	return spawn_animated_vfx(parent, BLOOD_SLASH_TEX, pos, 3, 2, 6, 24.0, final_scale, flip_h)


# ── Floor-Colliding Blood Droplet Simulation ──────────────────────────────────
class BloodDroplet extends Node2D:
	var velocity: Vector2 = Vector2.ZERO
	var gravity: float = 650.0
	var blood_color: Color = Color(0.75, 0.05, 0.10, 0.95)
	var drop_size: float = 2.0
	var is_stuck: bool = false
	var lifetime: float = 0.0

	func _draw() -> void:
		draw_circle(Vector2.ZERO, drop_size, blood_color)

	func _physics_process(delta: float) -> void:
		if is_stuck:
			return
		
		lifetime += delta
		if lifetime > 2.5:
			queue_free()
			return
		
		var move_step: Vector2 = velocity * delta
		var space_state = get_world_2d().direct_space_state
		# Collision mask 1 = TileMapLayer ground and platforms
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + move_step, 1)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Struck the floor/platform!
			global_position = result.position
			is_stuck = true
			set_physics_process(false)
			velocity = Vector2.ZERO
			
			# Flatten into an organic blood pool/stain on the floor surface
			scale = Vector2(randf_range(1.6, 2.5), randf_range(0.4, 0.7))
			z_index = 2 # Renders on top of tilemap floor
			
			# Stick to the ground for 5.0 seconds, then smoothly fade out
			var tween = create_tween()
			tween.tween_interval(randf_range(4.5, 5.5))
			tween.tween_property(self, "modulate:a", 0.0, 1.2)
			tween.tween_callback(queue_free)
		else:
			global_position += move_step
			velocity.y += gravity * delta

static func spawn_blood_splatter(parent: Node, pos: Vector2, dir: Vector2 = Vector2.ZERO, intensity: float = 1.0, is_player: bool = false) -> void:
	if not is_instance_valid(parent):
		return

	var count = int(clamp(11 * intensity, 8, 24))
	var base_color = Color(0.92, 0.12, 0.16, 0.95) if is_player else Color(0.72, 0.04, 0.08, 0.95)

	# 1. Quick airborne burst puff for instantaneous strike impact
	var p := CPUParticles2D.new()
	p.z_index = 26
	p.global_position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.98
	p.amount = int(clamp(8 * intensity, 6, 16))
	p.lifetime = 0.22
	p.spread = 60.0
	p.direction = dir.normalized() if dir != Vector2.ZERO else Vector2(0, -1)
	p.gravity = Vector2(0, 400)
	p.initial_velocity_min = 70.0 * intensity
	p.initial_velocity_max = 160.0 * intensity
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.0
	p.color = base_color
	parent.add_child(p)
	if p.is_inside_tree():
		p.get_tree().create_timer(0.3, false, false, true).timeout.connect(func():
			if is_instance_valid(p):
				p.queue_free()
		)
	else:
		p.queue_free()

	# 2. Physics droplets that fall and collide with the tilemap floor
	for i in range(count):
		var drop = BloodDroplet.new()
		drop.global_position = pos + Vector2(randf_range(-3, 3), randf_range(-3, 3))
		drop.blood_color = base_color.darkened(randf_range(0.0, 0.25))
		drop.drop_size = randf_range(1.2, 2.4)
		
		var angle: float
		if dir != Vector2.ZERO:
			angle = dir.angle() + randf_range(-0.75, 0.75)
		else:
			angle = randf_range(-PI * 0.85, -PI * 0.15)
		
		var speed = randf_range(70.0, 220.0) * clamp(intensity, 0.8, 1.5)
		drop.velocity = Vector2(cos(angle), sin(angle)) * speed
		drop.z_index = 25
		parent.add_child(drop)


# ── Floating Combat Text (Damage & Status Alerts) ─────────────────────────────
static func spawn_floating_text(parent: Node, pos: Vector2, text: String, color: Color = Color(1, 1, 1, 1), font_size: int = 14, is_crit: bool = false) -> Label:
	if not is_instance_valid(parent):
		return null
	
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT_ALAGARD)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index = 60
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Random subtle horizontal scatter (+/- 12px)
	var start_pos = pos + Vector2(randf_range(-10.0, 10.0), -12.0)
	label.global_position = start_pos
	
	if is_crit:
		label.scale = Vector2(1.35, 1.35)
		label.pivot_offset = Vector2(30.0, 10.0)
	
	parent.add_child(label)
	
	var tw = label.create_tween()
	var float_dist: float = 34.0 if is_crit else 24.0
	var dur: float = 0.65 if is_crit else 0.50
	
	tw.tween_property(label, "global_position:y", start_pos.y - float_dist, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_crit:
		tw.parallel().tween_property(label, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, dur * 0.45).set_delay(dur * 0.55)
	tw.tween_callback(label.queue_free)
	
	return label


# ── Evasive Ghost Trail / Shadow Afterimage ───────────────────────────────────
static func spawn_ghost_trail(parent: Node, texture: Texture2D, pos: Vector2, spr_scale: Vector2, flip_h: bool, tint: Color = Color(0.35, 0.65, 1.0, 0.65)) -> Sprite2D:
	if not is_instance_valid(parent) or not texture:
		return null
	
	var spr := Sprite2D.new()
	spr.texture = texture
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.centered = true
	spr.global_position = pos
	spr.scale = spr_scale
	spr.flip_h = flip_h
	spr.modulate = tint
	spr.z_index = 8
	
	parent.add_child(spr)
	
	var tw = spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(spr, "scale", spr_scale * 1.08, 0.28)
	tw.tween_callback(spr.queue_free)
	
	return spr



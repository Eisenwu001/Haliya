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

static func spawn_armor_impact(parent: Node, pos: Vector2) -> Sprite2D:
	var spr = spawn_parry_clash(parent, pos)
	if spr:
		spr.modulate = Color(0.4, 1.2, 1.8, 1.0)
	return spr

static func spawn_armor_break(parent: Node, pos: Vector2) -> void:
	if not is_instance_valid(parent):
		return
	var p := CPUParticles2D.new()
	p.z_index = 28
	p.global_position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 18
	p.lifetime = 0.35
	p.spread = 180.0
	p.gravity = Vector2(0, 320)
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 210.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.5
	p.color = Color(0.4, 0.9, 1.8, 1.0)
	parent.add_child(p)
	if p.is_inside_tree():
		p.get_tree().create_timer(0.45, false, false, true).timeout.connect(func():
			if is_instance_valid(p):
				p.queue_free()
		)
	else:
		p.queue_free()

static func spawn_armor_regen_pulse(parent: Node, pos: Vector2) -> void:
	if not is_instance_valid(parent):
		return
	var p := CPUParticles2D.new()
	p.z_index = 26
	p.global_position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.85
	p.amount = 12
	p.lifetime = 0.40
	p.spread = 180.0
	p.gravity = Vector2(0, -60)
	p.initial_velocity_min = 25.0
	p.initial_velocity_max = 70.0
	p.scale_amount_min = 1.8
	p.scale_amount_max = 3.2
	p.color = Color(0.5, 1.1, 1.9, 0.9)
	parent.add_child(p)
	if p.is_inside_tree():
		p.get_tree().create_timer(0.50, false, false, true).timeout.connect(func():
			if is_instance_valid(p):
				p.queue_free()
		)
	else:
		p.queue_free()

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


# ── Boss Blood-Moon Shockwave & Cinematic Flares ────────────────────────────
class BloodShockwaveRing extends Node2D:
	var radius: float = 14.0
	var max_radius: float = 160.0
	var ring_color: Color = Color(1.0, 0.22, 0.22, 0.95)
	var ring_width: float = 4.5

	func _ready() -> void:
		z_index = 32
		var tw = create_tween()
		tw.tween_property(self, "radius", max_radius, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "ring_width", 1.0, 0.55)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(queue_free)

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 36, ring_color, ring_width, true)
		if radius > 18.0:
			draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 28, Color(ring_color.r, 0.6, 0.6, ring_color.a * 0.45), ring_width * 0.6, true)


class RedEyeGlint extends Node2D:
	func _ready() -> void:
		z_index = 35
		scale = Vector2(0.2, 0.2)
		var tw = create_tween()
		tw.tween_property(self, "scale", Vector2(1.3, 1.3), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2(0.0, 0.0), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		var flare_col = Color(2.5, 0.35, 0.35, 1.0)
		var white_center = Color(3.0, 2.0, 2.0, 1.0)
		draw_line(Vector2(-16, 0), Vector2(16, 0), flare_col, 2.5)
		draw_line(Vector2(0, -16), Vector2(0, 16), flare_col, 2.5)
		var pts = PackedVector2Array([Vector2(-4, 0), Vector2(0, -4), Vector2(4, 0), Vector2(0, 4)])
		draw_colored_polygon(pts, white_center)


class DeathEmberParticle extends Node2D:
	var vel: Vector2
	var col: Color
	var p_size: float = 3.0

	func _ready() -> void:
		z_index = 28
		p_size = randf_range(2.0, 4.2)
		var dur = randf_range(1.4, 2.4)
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(self, "scale", Vector2.ZERO, dur).set_delay(dur * 0.4)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		global_position += vel * delta
		vel.y -= 25.0 * delta
		vel.x = move_toward(vel.x, 0.0, 12.0 * delta)
		queue_redraw()

	func _draw() -> void:
		draw_circle(Vector2.ZERO, p_size, col)


static func spawn_blood_moon_shockwave(parent: Node, pos: Vector2, max_radius: float = 160.0, color: Color = Color(1.0, 0.22, 0.22, 0.95)) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var wave = BloodShockwaveRing.new()
	wave.global_position = pos
	wave.max_radius = max_radius
	wave.ring_color = color
	parent.add_child(wave)
	return wave


static func spawn_red_eye_glint(parent: Node, pos: Vector2) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var glint = RedEyeGlint.new()
	glint.global_position = pos
	parent.add_child(glint)
	return glint


static func spawn_boss_death_embers(parent: Node, pos: Vector2, count: int = 36) -> void:
	if not is_instance_valid(parent):
		return
	for i in range(count):
		var ember = DeathEmberParticle.new()
		ember.global_position = pos + Vector2(randf_range(-36.0, 36.0), randf_range(-60.0, 10.0))
		var is_crimson = (i % 2 == 0)
		ember.col = Color(1.0, 0.35, 0.25, 0.95) if is_crimson else Color(0.85, 0.92, 1.0, 0.90)
		var angle = randf_range(-PI * 0.9, -PI * 0.1)
		var spd = randf_range(40.0, 160.0)
		ember.vel = Vector2(cos(angle), sin(angle)) * spd
		parent.add_child(ember)



# ── Evasive Ghost Trail / Shadow Afterimage ───────────────────────────────────
static func spawn_ghost_trail(parent: Node, texture: Texture2D, pos: Vector2, spr_scale: Vector2, flip_h: bool, tint: Color = Color(0.35, 0.65, 1.0, 0.65), hframes: int = 1, vframes: int = 1, frame: int = 0, offset: Vector2 = Vector2.ZERO) -> Sprite2D:
	if not is_instance_valid(parent) or not texture:
		return null
	
	var spr := Sprite2D.new()
	spr.texture = texture
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.centered = true
	spr.hframes = max(1, hframes)
	spr.vframes = max(1, vframes)
	spr.frame = clampi(frame, 0, spr.hframes * spr.vframes - 1)
	spr.offset = offset
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


# ── Exhausted Sweat Droplets ────────────────────────────────────────────────
class ExhaustedSweatParticle extends Node2D:
	var vel: Vector2
	var life: float = 0.60
	var max_life: float = 0.60
	var col: Color = Color(0.72, 0.90, 1.0, 0.90)
	var radius: float = 2.0

	func _ready() -> void:
		z_index = 10

	func _draw() -> void:
		var alpha = clampf(life / max_life, 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius * alpha, Color(col.r, col.g, col.b, col.a * alpha))

	func _physics_process(delta: float) -> void:
		global_position += vel * delta
		vel.y += 180.0 * delta # Gravity pull on sweat drop
		life -= delta
		queue_redraw()
		if life <= 0.0:
			queue_free()

static func spawn_exhausted_sweat(parent: Node, pos: Vector2, count: int = 4) -> void:
	if not is_instance_valid(parent):
		return
	for i in range(count):
		var p = ExhaustedSweatParticle.new()
		p.global_position = pos + Vector2(randf_range(-8.0, 8.0), randf_range(-10.0, -2.0))
		var angle = randf_range(-PI * 0.85, -PI * 0.15)
		var spd = randf_range(25.0, 75.0)
		p.vel = Vector2(cos(angle), sin(angle)) * spd
		p.radius = randf_range(1.6, 2.4)
		p.life = randf_range(0.40, 0.60)
		p.max_life = p.life
		parent.add_child(p)


static func spawn_stagger_execution_prompt(parent: Node, pos: Vector2) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var prompt_root := Node2D.new()
	prompt_root.name = "StaggerExecutionPrompt"
	prompt_root.global_position = pos
	prompt_root.z_index = 85
	parent.add_child(prompt_root)

	# 1. Baybayin Glowing Rune 'ᜉ' (Patayin / Slay)
	var rune_lbl := Label.new()
	rune_lbl.name = "BaybayinRune"
	rune_lbl.text = "ᜉ"
	rune_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rune_lbl.position = Vector2(-20, -32)
	rune_lbl.size = Vector2(40, 30)
	rune_lbl.add_theme_font_override("font", FONT_ALAGARD)
	rune_lbl.add_theme_font_size_override("font_size", 22)
	rune_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 1.0))
	rune_lbl.add_theme_color_override("font_shadow_color", Color(0.85, 0.15, 0.15, 0.95))
	rune_lbl.add_theme_constant_override("shadow_offset_x", 1)
	rune_lbl.add_theme_constant_override("shadow_offset_y", 1)
	prompt_root.add_child(rune_lbl)

	# 2. Subtext Prompt: [PATAYIN]
	var sub_lbl := Label.new()
	sub_lbl.name = "SubPrompt"
	sub_lbl.text = "PATAYIN"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.position = Vector2(-40, -6)
	sub_lbl.size = Vector2(80, 16)
	sub_lbl.add_theme_font_override("font", FONT_ALAGARD)
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
	prompt_root.add_child(sub_lbl)

	# Pulsing scale and floating tween, then auto-despawn
	prompt_root.scale = Vector2(0.5, 0.5)
	var tw = prompt_root.create_tween()
	tw.tween_property(prompt_root, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(prompt_root, "scale", Vector2(1.0, 1.0), 0.08)
	tw.tween_property(prompt_root, "position:y", pos.y - 12.0, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(prompt_root, "modulate:a", 0.0, 0.3)
	tw.tween_callback(prompt_root.queue_free)

	return prompt_root

class_name Skeleton
extends CharacterBody2D

signal skeleton_died(enemy: Skeleton)

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	GUARD,
	PARRIED_STAGGER,
	HURT,
	DEATH
}

const GRAVITY: float = 980.0
const PATROL_SPEED: float = 28.0
const CHASE_SPEED: float = 68.0
const AGGRO_RANGE: float = 220.0
const ATTACK_RANGE: float = 46.0
const MAX_HEALTH: int = 4
const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")

var current_state: State = State.IDLE
var health: int = MAX_HEALTH
var is_facing_left: bool = false
var is_dead: bool = false

# AI & Patrol variables
var spawn_x: float = 0.0
var patrol_direction: float = 1.0
var patrol_distance: float = 140.0
var state_timer: float = 0.0
var attack_cooldown: float = 0.0
var has_hit_player_this_swing: bool = false
var is_stunned_vulnerable: bool = false
var stun_timer: float = 0.0
var guard_timer: float = 0.0

# Animation Frames
var idle_tex: Texture2D
var walk_frames: Array[Texture2D] = []
var attack_frames: Array[Texture2D] = []
var guard_tex: Texture2D
var hurt_frames: Array[Texture2D] = []
var debris_textures: Array[Texture2D] = []

var cur_frame_idx: int = 0
var anim_timer: float = 0.0
var hurt_flash_timer: float = 0.0

# Node references
var sprite: Sprite2D
var stun_stars: Sprite2D
var col_shape: CollisionShape2D
var health_pips: Node2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	add_to_group("skeleton")
	
	spawn_x = global_position.x
	load_sprites()
	setup_nodes()
	
	patrol_direction = -1.0 if randf() > 0.5 else 1.0
	is_facing_left = (patrol_direction < 0.0)
	set_state(State.IDLE)

func load_sprites() -> void:
	idle_tex = load("res://assets/skeleton/common_01_idle01.png")
	guard_tex = load("res://assets/skeleton/common_03_turn_stand01.png")
	
	walk_frames.clear()
	for i in range(2, 9):
		var p = "res://assets/skeleton/common_11_walk0%d.png" % i
		var tex = load(p) as Texture2D
		if tex:
			walk_frames.append(tex)
	
	attack_frames.clear()
	for i in range(1, 7):
		var p = "res://assets/skeleton/attack_01_sword0%d.png" % i
		var tex = load(p) as Texture2D
		if tex:
			attack_frames.append(tex)
	
	hurt_frames.clear()
	var h1 = load("res://assets/skeleton/damage_01_damage_head.png") as Texture2D
	var h2 = load("res://assets/skeleton/damage_02_damage_body.png") as Texture2D
	if h1: hurt_frames.append(h1)
	if h2: hurt_frames.append(h2)
	
	# Debris textures for bone collapse
	debris_textures.clear()
	var debris_names = [
		"debris_skul001.png", "debris_chest001.png", "debris_sword001.png",
		"debris_shiield001.png", "debris_bone001.png", "debris_bone002.png",
		"debris_waist001.png", "debris_bone003.png"
	]
	for d_name in debris_names:
		var tex = load("res://assets/skeleton/" + d_name) as Texture2D
		if tex:
			debris_textures.append(tex)

func setup_nodes() -> void:
	collision_layer = 4 # Enemies layer
	collision_mask = 1  # Ground layer
	
	if has_node("Sprite2D"):
		sprite = get_node("Sprite2D")
		col_shape = get_node_or_null("CollisionShape2D")
		stun_stars = get_node_or_null("StunStars")
		if not has_node("EnemyHealthPips"):
			health_pips = EnemyHealthPipsClass.new()
			health_pips.name = "EnemyHealthPips"
			health_pips.position = Vector2(0, -68.0)
			add_child(health_pips)
		else:
			health_pips = get_node("EnemyHealthPips")
		return
	
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = idle_tex
	sprite.centered = true
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(0, -59.0)
	add_child(sprite)
	
	col_shape = CollisionShape2D.new()
	col_shape.name = "CollisionShape2D"
	var shape := CapsuleShape2D.new()
	shape.radius = 10.0
	shape.height = 36.0
	col_shape.shape = shape
	col_shape.position = Vector2(0, -18.0)
	add_child(col_shape)
	
	stun_stars = Sprite2D.new()
	stun_stars.texture = load("res://assets/vfx/vfx_stun_stars.png") as Texture2D
	stun_stars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stun_stars.hframes = 3
	stun_stars.vframes = 2
	stun_stars.scale = Vector2(0.07, 0.07)
	stun_stars.position = Vector2(0, -50.0)
	stun_stars.visible = false
	add_child(stun_stars)
	
	health_pips = EnemyHealthPipsClass.new()
	health_pips.name = "EnemyHealthPips"
	health_pips.position = Vector2(0, -68.0)
	add_child(health_pips)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0
	
	# Cooldowns
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	
	# Hurt flash decay
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and sprite:
			sprite.modulate = Color(1, 1, 1, 1)
	
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			state_timer -= delta
			if player and is_instance_valid(player) and global_position.distance_to(player.global_position) < AGGRO_RANGE:
				set_state(State.CHASE)
			elif state_timer <= 0.0:
				patrol_direction *= -1.0
				is_facing_left = (patrol_direction < 0.0)
				set_state(State.PATROL)
		
		State.PATROL:
			velocity.x = patrol_direction * PATROL_SPEED
			is_facing_left = (patrol_direction < 0.0)
			
			# Check distance from origin or wall contact
			if abs(global_position.x - spawn_x) > patrol_distance or is_on_wall():
				patrol_direction *= -1.0
				is_facing_left = (patrol_direction < 0.0)
				set_state(State.IDLE)
			
			if player and is_instance_valid(player) and global_position.distance_to(player.global_position) < AGGRO_RANGE:
				set_state(State.CHASE)
		
		State.CHASE:
			if not player or not is_instance_valid(player):
				set_state(State.IDLE)
				return
			
			var dist = global_position.distance_to(player.global_position)
			var dir_to_player = sign(player.global_position.x - global_position.x)
			if dir_to_player != 0:
				patrol_direction = dir_to_player
				is_facing_left = (dir_to_player < 0)
			
			if dist <= ATTACK_RANGE and attack_cooldown <= 0.0:
				set_state(State.ATTACK)
			elif dist > AGGRO_RANGE * 1.3:
				set_state(State.IDLE)
			else:
				velocity.x = dir_to_player * CHASE_SPEED
		
		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			# Hitbox active during frames 2 and 3 of swing
			if cur_frame_idx in [2, 3] and not has_hit_player_this_swing:
				check_sword_hit_player()
		
		State.GUARD:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			guard_timer -= delta
			if guard_timer <= 0.0:
				set_state(State.CHASE)
		
		State.PARRIED_STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
			stun_timer -= delta
			if stun_stars:
				stun_stars.rotation += delta * 6.0
				stun_stars.frame = int(Time.get_ticks_msec() / 100.0) % 6
			if stun_timer <= 0.0:
				is_stunned_vulnerable = false
				if stun_stars:
					stun_stars.visible = false
				if is_instance_valid(health_pips):
					health_pips.set_vulnerable(false)
				set_state(State.CHASE)
		
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				set_state(State.CHASE)
	
	update_animation(delta)
	move_and_slide()

func set_state(new_state: State) -> void:
	current_state = new_state
	cur_frame_idx = 0
	anim_timer = 0.0
	
	match new_state:
		State.IDLE:
			state_timer = randf_range(1.0, 2.2)
			if sprite and idle_tex:
				sprite.texture = idle_tex
		State.PATROL:
			state_timer = randf_range(3.0, 5.0)
		State.CHASE:
			pass
		State.ATTACK:
			has_hit_player_this_swing = false
		State.GUARD:
			guard_timer = 1.0
			if sprite and guard_tex:
				sprite.texture = guard_tex
		State.PARRIED_STAGGER:
			is_stunned_vulnerable = true
			stun_timer = 1.6
			if stun_stars:
				stun_stars.visible = true
			if sprite and not hurt_frames.is_empty():
				sprite.texture = hurt_frames[0]
		State.HURT:
			state_timer = 0.25
			if sprite and not hurt_frames.is_empty():
				sprite.texture = hurt_frames[0]

func update_animation(delta: float) -> void:
	if not sprite:
		return
	
	sprite.flip_h = is_facing_left
	
	match current_state:
		State.PATROL, State.CHASE:
			anim_timer += delta
			var dur = 0.10 if current_state == State.CHASE else 0.13
			if anim_timer >= dur:
				anim_timer -= dur
				if not walk_frames.is_empty():
					cur_frame_idx = (cur_frame_idx + 1) % walk_frames.size()
					sprite.texture = walk_frames[cur_frame_idx]
		
		State.ATTACK:
			anim_timer += delta
			if anim_timer >= 0.09:
				anim_timer -= 0.09
				cur_frame_idx += 1
				if cur_frame_idx >= attack_frames.size():
					attack_cooldown = 1.2
					# 30% chance to immediately raise guard after attack
					if randf() < 0.35:
						set_state(State.GUARD)
					else:
						set_state(State.CHASE)
				else:
					sprite.texture = attack_frames[cur_frame_idx]

func check_sword_hit_player() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player or not is_instance_valid(player):
		return
	
	var dist = global_position.distance_to(player.global_position)
	var dx = player.global_position.x - global_position.x
	var facing_correct = (is_facing_left and dx < 8.0) or (not is_facing_left and dx > -8.0)
	
	if dist <= ATTACK_RANGE + 8.0 and facing_correct:
		has_hit_player_this_swing = true
		var enemy_dir: float = -1.0 if is_facing_left else 1.0
		if player.has_method("take_damage_from_enemy"):
			player.take_damage_from_enemy(1, enemy_dir, self)

func take_damage(amount: int, knockback_dir: float) -> void:
	if is_dead:
		return
	
	# If Skeleton is in Guard stance and facing the attack, deflect!
	var attack_from_front = (is_facing_left and knockback_dir < 0) or (not is_facing_left and knockback_dir > 0)
	if current_state == State.GUARD and attack_from_front:
		# Deflected! Metallic shield spark
		VFX.spawn_guard_impact(get_parent(), global_position + Vector2(0, -25.0))
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -42.0), "BLOCKED", Color(0.65, 0.75, 0.95), 13, false)
		velocity.x = knockback_dir * 40.0
		return
	
	# If hit while Vulnerable / Stunned from a Perfect Block -> Instant 1-Hit Lethal Riposte!
	if is_stunned_vulnerable:
		is_stunned_vulnerable = false
		if stun_stars:
			stun_stars.visible = false
		health = 0
		if is_instance_valid(health_pips):
			health_pips.update_health(0, MAX_HEALTH, false)
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -50.0), "CRIT 99!", Color(1.0, 0.9, 0.2), 16, true)
		shatter_death(knockback_dir)
		return
	
	health -= amount
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, false)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -42.0), str(amount), Color(1.0, 0.35, 0.25), 14, false)
	
	hurt_flash_timer = 0.22
	if sprite:
		sprite.modulate = Color(2.0, 0.4, 0.4, 1.0)
	
	velocity.x = knockback_dir * 90.0
	
	if health <= 0:
		shatter_death(knockback_dir)
	else:
		set_state(State.HURT)

func shatter_death(knock_dir: float) -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	
	if is_instance_valid(col_shape):
		col_shape.set_deferred("disabled", true)
	if is_instance_valid(sprite):
		sprite.visible = false
	if is_instance_valid(stun_stars):
		stun_stars.visible = false
	if is_instance_valid(health_pips):
		health_pips.visible = false
	
	skeleton_died.emit(self)
	
	# Spawn bursting bone debris pieces
	for tex in debris_textures:
		var bone_spr := Sprite2D.new()
		bone_spr.texture = tex
		bone_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bone_spr.scale = Vector2(0.5, 0.5)
		bone_spr.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-40, -10))
		get_parent().add_child(bone_spr)
		
		# Animate physics scatter & fade
		var target_x = bone_spr.global_position.x + randf_range(30, 90) * knock_dir + randf_range(-20, 20)
		var target_y = bone_spr.global_position.y + randf_range(10, 40)
		var rot_target = randf_range(-6.0, 6.0)
		
		var tween = create_tween()
		tween.parallel().tween_property(bone_spr, "global_position:x", target_x, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(bone_spr, "global_position:y", target_y, 0.65).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(bone_spr, "rotation", rot_target, 0.65)
		tween.tween_property(bone_spr, "modulate:a", 0.0, 0.5)
		tween.tween_callback(bone_spr.queue_free)
	
	if is_inside_tree():
		get_tree().create_timer(1.2).timeout.connect(queue_free)
	else:
		queue_free()

func trigger_parried_stagger() -> void:
	deflect_by_parry(1.0)

func deflect_by_parry(knock_dir: float) -> void:
	is_stunned_vulnerable = true
	stun_timer = 1.2
	if stun_stars:
		stun_stars.visible = true
	if is_instance_valid(health_pips):
		health_pips.update_health(health, MAX_HEALTH, true)
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -52.0), "STAGGERED!", Color(1.0, 0.85, 0.2), 14, true)
	set_state(State.PARRIED_STAGGER)
	velocity.x = knock_dir * 180.0

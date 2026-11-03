class_name Santelmo
extends CharacterBody2D

## Santelmo (St. Elmo's Fire)
## Atmospheric Philippine mythological spirit flame that dances above rice terraces and flooded waters.

signal santelmo_died(enemy: Node)

static var _santelmo_tex: Texture2D = null

static func get_santelmo_texture() -> Texture2D:
	if _santelmo_tex != null:
		return _santelmo_tex
	if ResourceLoader.exists("res://assets/enemies/santelmo_spritesheet.png"):
		var res = load("res://assets/enemies/santelmo_spritesheet.png")
		if res is Texture2D:
			_santelmo_tex = res
			return res
	var global_p: String = ProjectSettings.globalize_path("res://assets/enemies/santelmo_spritesheet.png")
	if FileAccess.file_exists(global_p):
		var img := Image.new()
		if img.load(global_p) == OK:
			_santelmo_tex = ImageTexture.create_from_image(img)
			return _santelmo_tex
	return null
const LIGHT_TEX = preload("res://assets/vfx/radial_light_falloff.png")
const EnemyHealthPipsClass = preload("res://scripts/enemy_health_pips.gd")
const VFX_SCRIPT = preload("res://scripts/vfx.gd")
const PickupItemScript = preload("res://scripts/pickup_item.gd")

enum State { IDLE_FLOAT, CHASE, FLARE_ATTACK, HURT, DEATH }

const BASE_MAX_HEALTH: int = 4
var health: int = BASE_MAX_HEALTH
var max_health: int = BASE_MAX_HEALTH
var is_dead: bool = false
var is_elite: bool = false
var is_stunned_vulnerable: bool = false
var speed_multiplier: float = 1.0

var current_state: State = State.IDLE_FLOAT
var spawn_pos: Vector2 = Vector2.ZERO
var patrol_radius: float = 120.0
var patrol_angle: float = 0.0
var time_alive: float = 0.0
var aggro_range: float = 230.0
var flare_range: float = 48.0
var flare_timer: float = 0.0
var flare_cooldown: float = 0.0
var hurt_flash_timer: float = 0.0

var target_player: CharacterBody2D = null

# Visuals
var sprite: Sprite2D
var light: PointLight2D
var health_pips: Node2D
var frame_timer: float = 0.0
var current_frame: int = 0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("enemies")
	spawn_pos = global_position
	patrol_angle = randf() * TAU
	
	# Collision shape (layer 4: enemies, mask 1: terrain, 2: player)
	collision_layer = 4
	collision_mask = 1 | 2
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	col.shape = shape
	add_child(col)
	
	# Sprite setup
	sprite = Sprite2D.new()
	sprite.texture = get_santelmo_texture()
	sprite.hframes = 6
	sprite.vframes = 1
	sprite.frame = 0
	add_child(sprite)
	
	# Spirit Light
	light = PointLight2D.new()
	light.texture = LIGHT_TEX
	light.texture_scale = 0.38
	light.color = Color(0.35, 0.85, 1.0, 0.92)
	light.energy = 1.35
	add_child(light)
	
	# Health Pips
	health_pips = EnemyHealthPipsClass.new()
	health_pips.position = Vector2(0, -28.0)
	add_child(health_pips)
	health_pips.update_health(health, max_health)


func apply_difficulty_scaling(hp_mult: float, spd_mult: float, elite: bool = false) -> void:
	is_elite = elite
	speed_multiplier = spd_mult
	if is_elite:
		max_health = int(round(BASE_MAX_HEALTH * hp_mult * 1.5))
		speed_multiplier *= 1.25
		if is_instance_valid(light):
			light.color = Color(1.0, 0.40, 0.85, 1.0) # Violet-crimson elite flame
		if is_instance_valid(sprite):
			sprite.modulate = Color(1.3, 0.5, 0.9, 1.0)
	else:
		max_health = int(round(BASE_MAX_HEALTH * hp_mult))
	health = max_health
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	time_alive += delta
	patrol_angle += 1.2 * delta
	
	# Animation step
	frame_timer += delta
	if frame_timer >= 0.09:
		frame_timer = 0.0
		current_frame = (current_frame + 1) % 6
		if sprite:
			sprite.frame = current_frame
	
	# Light sine pulsing
	if light:
		light.energy = 1.20 + sin(time_alive * 5.0) * 0.25
	
	# Hurt flash decay
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0.0 and sprite:
			sprite.modulate = Color(1.3, 0.5, 0.9, 1.0) if is_elite else Color(1, 1, 1, 1)
	
	if flare_cooldown > 0.0:
		flare_cooldown -= delta
	
	# Find player target
	if not is_instance_valid(target_player):
		var p_nodes = get_tree().get_nodes_in_group("player")
		if not p_nodes.is_empty():
			target_player = p_nodes[0] as CharacterBody2D
	
	match current_state:
		State.IDLE_FLOAT:
			handle_idle_float(delta)
		State.CHASE:
			handle_chase(delta)
		State.FLARE_ATTACK:
			handle_flare_attack(delta)
		State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	
	move_and_slide()


func handle_idle_float(delta: float) -> void:
	# Graceful orbital hovering around spawn point
	var target_x = spawn_pos.x + cos(patrol_angle) * (patrol_radius * 0.5)
	var target_y = spawn_pos.y - 20.0 + sin(patrol_angle * 1.5) * 16.0
	var target = Vector2(target_x, target_y)
	
	velocity = (target - global_position).normalized() * (45.0 * speed_multiplier)
	
	# Check aggro
	if is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position + Vector2(0, -30))
		if dist <= aggro_range:
			current_state = State.CHASE


func handle_chase(delta: float) -> void:
	if not is_instance_valid(target_player):
		current_state = State.IDLE_FLOAT
		return
	
	var p_center = target_player.global_position + Vector2(0, -28.0)
	var to_player = p_center - global_position
	var dist = to_player.length()
	
	if dist > aggro_range * 1.3:
		current_state = State.IDLE_FLOAT
		return
	
	# Move toward player with weaving undulating flight
	var weave = Vector2(-to_player.normalized().y, to_player.normalized().x) * sin(time_alive * 4.0) * 35.0
	var desired_vel = (to_player.normalized() * (85.0 * speed_multiplier)) + weave
	velocity = velocity.move_toward(desired_vel, 220.0 * delta)
	
	if dist <= flare_range and flare_cooldown <= 0.0:
		start_flare_attack()


func start_flare_attack() -> void:
	current_state = State.FLARE_ATTACK
	flare_timer = 0.55
	velocity = Vector2.ZERO
	# Telegraph flare: flash bright white-cyan
	if sprite:
		sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	if light:
		light.energy = 2.2


func handle_flare_attack(delta: float) -> void:
	flare_timer -= delta
	if flare_timer <= 0.0:
		# Detonate burst
		if is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position + Vector2(0, -28.0))
			if dist <= 56.0 and target_player.has_method("take_damage_from_enemy"):
				var dir = 1.0 if target_player.global_position.x >= global_position.x else -1.0
				target_player.take_damage_from_enemy(1, dir, self)
		
		VFX_SCRIPT.spawn_blood_slash(get_parent(), global_position, false, Vector2(1.2, 1.2))
		flare_cooldown = 2.0
		current_state = State.CHASE
		if sprite:
			sprite.modulate = Color(1.3, 0.5, 0.9, 1.0) if is_elite else Color(1, 1, 1, 1)


func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if is_dead:
		return
	
	health -= amount
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health)
	
	VFX_SCRIPT.spawn_floating_text(get_parent(), global_position + Vector2(0, -32.0), str(amount), Color(0.4, 0.85, 1.0), 14, false)
	VFX_SCRIPT.spawn_blood_splatter(get_parent(), global_position, Vector2(knockback_dir, -0.4), 1.0, false)
	
	if sprite:
		sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	hurt_flash_timer = 0.18
	
	velocity = Vector2(knockback_dir * 140.0, -80.0)
	
	if health <= 0:
		trigger_death()
	else:
		current_state = State.HURT
		get_tree().create_timer(0.20).timeout.connect(func():
			if not is_dead:
				current_state = State.CHASE
		)


func deflect_by_parry(deflect_dir: float) -> void:
	# Perfect parry immediately extinguishes Santelmo!
	is_stunned_vulnerable = true
	health = 0
	if is_instance_valid(health_pips):
		health_pips.update_health(0, max_health)
	VFX_SCRIPT.spawn_floating_text(get_parent(), global_position + Vector2(0, -40.0), "DEFLECTED! 99", Color(1.0, 0.9, 0.2), 15, true)
	trigger_death()


func trigger_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	
	if is_elite:
		VFX_SCRIPT.spawn_floating_text(get_parent(), global_position + Vector2(0, -48.0), "ELITE SLAIN", Color(1.0, 0.85, 0.35), 14, true)
	
	santelmo_died.emit(self)
	
	# Spawn Moon Pearl Pickup
	spawn_moon_pearl_drop()
	
	# Death dissolve tween
	if is_instance_valid(sprite) and is_inside_tree():
		var tw = create_tween()
		if tw:
			tw.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
			if light:
				tw.parallel().tween_property(light, "energy", 0.0, 0.25)
			tw.tween_callback(queue_free)
		else:
			queue_free()
	else:
		queue_free()


func spawn_moon_pearl_drop() -> void:
	var pearl = PickupItemScript.new()
	pearl.pickup_type = PickupItemScript.Type.MOON_PEARL
	pearl.is_moon_pearl = true
	pearl.global_position = global_position
	get_parent().add_child(pearl)
	pearl.launch_scatter(Vector2(randf_range(-25.0, 25.0), randf_range(-10.0, 15.0)))

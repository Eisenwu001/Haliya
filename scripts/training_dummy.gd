class_name TrainingDummy
extends CharacterBody2D

signal parried_by_player
signal riposte_received
signal attack_blocked
signal dummy_defeated

const MAIN_SHEET_TEX = preload("res://assets/props/training_dummy_sheet.png")
const TELEGRAPH_ICON_TEX = preload("res://assets/vfx/vfx_telegraph_mark.png")
const FONT_RES = preload("res://alagard.ttf")

enum State {
	IDLE,
	TELEGRAPH,
	ATTACK,
	PARRIED_STAGGER,
	HURT,
	RECOVERING
}

const GRAVITY: float = 980.0
const TELEGRAPH_TIME: float = 0.70  # Generous window for learning parry timing
const STAGGER_TIME: float = 2.0    # Extended riposte opportunity window

var current_state: State = State.IDLE
var is_facing_left: bool = true
var is_dead: bool = false
var is_stunned_vulnerable: bool = false
var health: int = 3
var max_health: int = 3

var state_timer: float = 0.0
var attack_cooldown: float = 1.6
var target_player: CharacterBody2D = null

# Visual elements
var sprite: Sprite2D
var cue_label: Label
var telegraph_icon: Sprite2D
var health_bar_bg: ColorRect
var health_bar_fill: ColorRect

func _ready() -> void:
	name = "TrainingDummy"
	add_to_group("enemies")
	add_to_group("training_dummy")
	
	collision_layer = 4   # Enemy layer
	collision_mask = 1    # World layer
	
	setup_visuals()
	setup_collision()

func setup_visuals() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = MAIN_SHEET_TEX
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hframes = 5
	sprite.vframes = 1
	sprite.frame = 0
	sprite.modulate = Color.WHITE
	add_child(sprite)

	# Overhead status cue ("! PARRY NOW !")
	cue_label = Label.new()
	cue_label.name = "CueLabel"
	cue_label.position = Vector2(-75, -78)
	cue_label.size = Vector2(150, 20)
	cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cue_label.add_theme_font_override("font", FONT_RES)
	cue_label.add_theme_font_size_override("font_size", 12)
	cue_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.35, 1.0))
	cue_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	cue_label.add_theme_constant_override("shadow_offset_x", 1)
	cue_label.add_theme_constant_override("shadow_offset_y", 1)
	cue_label.visible = false
	add_child(cue_label)

	# Dedicated pixel-art combat telegraph glint icon
	telegraph_icon = Sprite2D.new()
	telegraph_icon.name = "TelegraphIcon"
	telegraph_icon.texture = TELEGRAPH_ICON_TEX
	telegraph_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	telegraph_icon.position = Vector2(0, -48)
	telegraph_icon.visible = false
	add_child(telegraph_icon)

	# Mini health bar
	health_bar_bg = ColorRect.new()
	health_bar_bg.position = Vector2(-20, -36)
	health_bar_bg.size = Vector2(40, 4)
	health_bar_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	add_child(health_bar_bg)

	health_bar_fill = ColorRect.new()
	health_bar_fill.position = Vector2(-20, -36)
	health_bar_fill.size = Vector2(40, 4)
	health_bar_fill.color = Color(0.9, 0.7, 0.2, 1.0)
	add_child(health_bar_fill)

func setup_collision() -> void:
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(28, 60)
	col.shape = rect
	col.position = Vector2(0, 6)
	add_child(col)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	# Find player
	if not is_instance_valid(target_player):
		var p_list = get_tree().get_nodes_in_group("player")
		if not p_list.is_empty():
			target_player = p_list[0] as CharacterBody2D

	if is_instance_valid(target_player):
		is_facing_left = target_player.global_position.x < global_position.x
		sprite.flip_h = is_facing_left

	# State Machine
	state_timer -= delta
	match current_state:
		State.IDLE:
			velocity.x = 0.0
			sprite.frame = (int(Time.get_ticks_msec() / 450.0) % 2)
			if is_instance_valid(target_player):
				var dist: float = abs(target_player.global_position.x - global_position.x)
				if dist < 65.0 and state_timer <= 0.0:
					start_telegraph()

		State.TELEGRAPH:
			velocity.x = 0.0
			var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 60.0)
			sprite.modulate = Color(1.0 + pulse * 0.35, 0.95 + pulse * 0.25, 0.70 + pulse * 0.30, 1.0)
			telegraph_icon.visible = true
			telegraph_icon.scale = Vector2(1.0 + pulse * 0.35, 1.0 + pulse * 0.35)
			telegraph_icon.modulate = Color(1.0, 0.95 + pulse * 0.05, 0.6 + pulse * 0.4, 1.0)
			cue_label.visible = true
			cue_label.text = "★ PREPARE TO PARRY [K]! ★"
			cue_label.add_theme_color_override("font_color", Color(1.0, 0.85 + pulse * 0.15, 0.2, 1.0))
			sprite.frame = 2

			if state_timer <= 0.0:
				execute_attack()

		State.ATTACK:
			velocity.x = 0.0
			sprite.frame = 3
			if state_timer <= 0.0:
				finish_attack()

		State.PARRIED_STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			sprite.frame = 4
			sprite.modulate = Color(1.3, 1.2, 0.8, 1.0)
			cue_label.visible = true
			cue_label.text = "⚡ STAGGERED! PRESS [J] TO RIPOSTE! ⚡"
			cue_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
			telegraph_icon.visible = false

			# Little wobble star effect
			cue_label.position.y = -78.0 + sin(Time.get_ticks_msec() / 100.0) * 3.0

			if state_timer <= 0.0:
				recover_from_stagger()

		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			sprite.frame = 4
			if state_timer <= 0.0:
				recover_from_hurt()

		State.RECOVERING:
			velocity.x = 0.0
			sprite.frame = 0
			cue_label.visible = false
			telegraph_icon.visible = false
			if state_timer <= 0.0:
				current_state = State.IDLE
				state_timer = attack_cooldown
				sprite.modulate = Color.WHITE

	move_and_slide()

func start_telegraph() -> void:
	current_state = State.TELEGRAPH
	state_timer = TELEGRAPH_TIME
	cue_label.visible = true
	telegraph_icon.visible = true
	sprite.frame = 2

func execute_attack() -> void:
	current_state = State.ATTACK
	state_timer = 0.35
	telegraph_icon.visible = false
	sprite.frame = 3
	sprite.modulate = Color.WHITE

	# Deliver attack to player
	if is_instance_valid(target_player):
		var p_dist: float = abs(target_player.global_position.x - global_position.x)
		if p_dist < 60.0:
			var attack_dir: float = 1.0 if target_player.global_position.x >= global_position.x else -1.0
			if target_player.has_method("take_damage_from_enemy"):
				target_player.take_damage_from_enemy(1, attack_dir, self)

func finish_attack() -> void:
	current_state = State.RECOVERING
	state_timer = 1.2
	cue_label.visible = false
	telegraph_icon.visible = false
	sprite.frame = 0
	sprite.modulate = Color.WHITE

## Called by Player when player lands a PERFECT PARRY within 0.20s
func deflect_by_parry(knockback_dir: float) -> void:
	current_state = State.PARRIED_STAGGER
	state_timer = STAGGER_TIME
	is_stunned_vulnerable = true

	velocity.x = knockback_dir * 180.0
	velocity.y = -80.0

	sprite.frame = 4
	sprite.modulate = Color(1.3, 1.2, 0.8, 1.0)

	parried_by_player.emit()
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -50), "PARRIED!", Color(1.0, 0.9, 0.3), 16, true)

func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if current_state == State.PARRIED_STAGGER or is_stunned_vulnerable:
		# Riposte execution!
		is_stunned_vulnerable = false
		riposte_received.emit()
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -52), "RIPOSTE CRIT 99!", Color(1.0, 0.85, 0.2), 16, true)
		health = 0
		update_health_display()
		trigger_defeat()
		return

	health = max(0, health - amount)
	update_health_display()
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -45), str(amount), Color(1.0, 0.5, 0.3), 13, false)

	current_state = State.HURT
	state_timer = 0.30
	velocity.x = knockback_dir * 140.0
	sprite.modulate = Color(2.0, 0.5, 0.5, 1.0)

	if health <= 0:
		trigger_defeat()

func trigger_defeat() -> void:
	dummy_defeated.emit()
	current_state = State.RECOVERING
	state_timer = 3.0
	cue_label.visible = true
	cue_label.text = "✓ PRACTICE SUCCESSFUL! ✓"
	cue_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0))
	telegraph_icon.visible = false

	# Respawn/Reset dummy so player can keep practicing
	get_tree().create_timer(3.0).timeout.connect(func():
		reset_dummy()
	)

func reset_dummy() -> void:
	health = max_health
	update_health_display()
	is_stunned_vulnerable = false
	current_state = State.IDLE
	state_timer = 1.0
	cue_label.visible = false
	telegraph_icon.visible = false
	sprite.texture = MAIN_SHEET_TEX
	sprite.hframes = 5
	sprite.vframes = 1
	sprite.frame = 0
	sprite.modulate = Color.WHITE

func recover_from_stagger() -> void:
	is_stunned_vulnerable = false
	current_state = State.RECOVERING
	state_timer = 1.0
	cue_label.visible = false
	sprite.texture = MAIN_SHEET_TEX
	sprite.hframes = 5
	sprite.vframes = 1
	sprite.frame = 0
	sprite.modulate = Color.WHITE

func recover_from_hurt() -> void:
	current_state = State.RECOVERING
	state_timer = 0.8
	sprite.frame = 0
	sprite.modulate = Color.WHITE

func update_health_display() -> void:
	if is_instance_valid(health_bar_fill):
		var ratio = float(health) / float(max_health)
		health_bar_fill.size.x = 40.0 * ratio

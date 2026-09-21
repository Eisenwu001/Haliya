class_name MaskAltar
extends Area2D

signal mask_claimed

const FONT_RES = preload("res://alagard.ttf")

var prompt_label: Label
var sprite: Sprite2D
var is_player_nearby: bool = false
var is_claimed: bool = false
var guardian_enemy: Node2D = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.position = Vector2(-80, -48)
	prompt_label.size = Vector2(160, 20)
	prompt_label.text = "✦ [E] Claim Mask of Sorrow ✦"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_override("font", FONT_RES)
	prompt_label.add_theme_font_size_override("font_size", 12)
	prompt_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.65, 1.0))
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	prompt_label.add_theme_constant_override("shadow_offset_x", 1)
	prompt_label.add_theme_constant_override("shadow_offset_y", 1)
	prompt_label.visible = false
	add_child(prompt_label)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if prompt_label.visible:
		var float_y = sin(Time.get_ticks_msec() / 200.0) * 3.0
		prompt_label.position.y = -48.0 + float_y

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		is_player_nearby = true
		if not is_claimed:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_player_nearby and not is_claimed and (event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E)):
		claim_mask()

func claim_mask() -> void:
	# Check if tutorial guardian is still alive
	if is_instance_valid(guardian_enemy) and not guardian_enemy.get("is_dead"):
		var dm = get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
		if dm and not dm.is_active:
			dm.start_dialogue([
				{"speaker": "Mask of Sorrow", "portrait": "none", "text": "The corrupted guardian still stands watch over the altar. Defeat it first."}
			])
		return
	
	var dm = get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
	if not dm or dm.is_active:
		return
	
	is_claimed = true
	prompt_label.visible = false
	
	var lines: Array[Dictionary] = [
		{"speaker": "Haliya", "portrait": "haliya", "text": "(Internal) It's lighter than I expected... and then, the moment it settles against my face, unbearably heavy."},
		{"speaker": "Haliya", "portrait": "haliya", "text": "(Internal) As if it's been waiting this whole time to finally have somewhere to put down what it's carrying."},
		{"speaker": "Haliya", "portrait": "haliya", "text": "(Internal) This is what grief is supposed to feel like. Not gone. Held."},
		{"speaker": "Kapre", "portrait": "kapre", "text": "Now you know what it costs. Remember that, out there. It only gets more expensive."},
		{"speaker": "System", "portrait": "none", "text": "✦ Mask of Sorrow Claimed! The gateway to the Corrupted Overworld is now open. ✦"}
	]
	
	dm.start_dialogue(lines, func():
		mask_claimed.emit()
	)

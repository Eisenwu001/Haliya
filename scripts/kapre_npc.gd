class_name KapreNPC
extends Area2D

const FONT_RES = preload("res://alagard.ttf")

var prompt_label: Label
var sprite: Sprite2D
var is_player_nearby: bool = false
var has_talked_intro: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer (2 = mask of player or CharacterBody2D)
	
	# Prompt label floating above Kapre
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.position = Vector2(-70, -75)
	prompt_label.size = Vector2(140, 20)
	prompt_label.text = "✦ [E] Speak to Kapre ✦"
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
		prompt_label.position.y = -75.0 + float_y

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_player_nearby and (event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E)):
		trigger_dialogue()

func trigger_dialogue() -> void:
	var dm = get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
	if not dm or dm.is_active:
		return
	
	prompt_label.visible = false
	
	var lines: Array[Dictionary] = []
	
	if not has_talked_intro:
		has_talked_intro = true
		lines = [
			{"speaker": "Kapre", "portrait": "kapre", "text": "You're the seventh. The last light."},
			{"speaker": "Kapre", "portrait": "kapre", "text": "I watched this land before it went quiet like this. I watched what took it from us."},
			{"speaker": "Kapre", "portrait": "kapre", "text": "You don't remember all of it. Maybe that's kindness. What's left is this — he took them from you. One by one. If you're going after him, you won't be the same when you come back."},
			{"speaker": "Kapre", "portrait": "kapre", "text": "Your family carried grief the way other people carry water — in a vessel, not in their bare hands. There's one left. It was your mother's, and her mother's before that."},
			{"speaker": "Kapre", "portrait": "kapre", "text": "Take a weapon from the rack ahead. Then claim the Mask from the glade if you're to walk into what's left of this world."}
		]
	else:
		lines = [
			{"speaker": "Kapre", "portrait": "kapre", "text": "The weapon rack stands to the east. Choose your blade, then defeat the guardian at the glade to claim your mother's mask."},
			{"speaker": "Kapre", "portrait": "kapre", "text": "Remember what it costs, child. It only gets more expensive."}
		]
	
	dm.start_dialogue(lines, func():
		if is_player_nearby:
			prompt_label.visible = true
	)

class_name WeaponRack
extends Area2D

signal weapon_selected(weapon_name: String)

const FONT_RES = preload("res://alagard.ttf")

var prompt_label: Label
var is_player_nearby: bool = false
var chosen_weapon: String = ""

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.position = Vector2(-70, -45)
	prompt_label.size = Vector2(140, 20)
	prompt_label.text = "✦ [E] Choose Weapon ✦"
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
		prompt_label.position.y = -45.0 + float_y

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
		open_weapon_selection()

func open_weapon_selection() -> void:
	var dm = get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
	if not dm or dm.is_active:
		return
	
	prompt_label.visible = false
	
	var lines: Array[Dictionary] = [
		{"speaker": "Weapon Rack", "portrait": "none", "text": "Three traditional blades rest on the weathered bamboo rack. Which calls to you?"},
		{
			"speaker": "Select Your Blade",
			"choices": [
				"Kampilan — Long reach & ceremonial blade (High range, wide sweep)",
				"Kris — Wavy flame blade (Fast & unpredictable strikes)",
				"Bolo — Practical iron blade (Balanced & heavy cleaves)"
			]
		}
	]
	
	var choice_conn = dm.choice_selected.connect(_on_choice_made, CONNECT_ONE_SHOT)
	dm.start_dialogue(lines, func():
		if is_player_nearby:
			prompt_label.visible = true
	)

func _on_choice_made(idx: int, _text: String) -> void:
	match idx:
		0:
			chosen_weapon = "Kampilan"
		1:
			chosen_weapon = "Kris"
		2:
			chosen_weapon = "Bolo"
	
	weapon_selected.emit(chosen_weapon)
	
	# Apply to player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.set("equipped_weapon", chosen_weapon)
	
	prompt_label.text = "✦ Equipped: %s ✦" % chosen_weapon

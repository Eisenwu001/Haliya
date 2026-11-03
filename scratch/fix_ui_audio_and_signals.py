# Update upgrade_select_ui.gd
with open("scripts/upgrade_select_ui.gd", "r", encoding="utf-8") as f:
    up_code = f.read()

target_up_init = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	setup_ui()
	visible = false

func _ready() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = "Master"
		add_child(audio_player)"""

repl_up_init = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	setup_ui()
	visible = false"""

up_code = up_code.replace(target_up_init, repl_up_init)

target_up_select = """func select_upgrade(index: int) -> void:
	if not is_active or index < 0 or index >= card_data.size():
		return
	
	is_active = false
	var chosen = card_data[index]
	var chosen_id = chosen["id"]
	
	# Chime sound effect
	play_chime()
	
	# Animation: Selected card flashes bright gold, other cards fade
	for i in range(cards.size()):
		var card = cards[i]
		var tw = card.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		if i == index:
			tw.tween_property(card, "scale", Vector2(1.10, 1.10), 0.20)
			tw.parallel().tween_property(card, "modulate", Color(1.8, 1.6, 1.0, 1.0), 0.20)
		else:
			tw.tween_property(card, "modulate:a", 0.0, 0.20)
	
	var fade_tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tw.tween_interval(0.40)
	fade_tw.tween_property(overlay, "modulate:a", 0.0, 0.30)
	fade_tw.tween_callback(func():
		visible = false
		upgrade_selected.emit(chosen_id)
	)"""

repl_up_select = """func select_upgrade(index: int) -> void:
	if not is_active or index < 0 or index >= card_data.size():
		return
	
	is_active = false
	var chosen = card_data[index]
	var chosen_id = chosen["id"]
	
	# Chime sound effect
	play_chime()
	
	# Emit signal immediately for instant progression response
	upgrade_selected.emit(chosen_id)
	
	# Animation: Selected card flashes bright gold, other cards fade
	for i in range(cards.size()):
		var card = cards[i]
		if is_instance_valid(card):
			var tw = card.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			if i == index:
				tw.tween_property(card, "scale", Vector2(1.10, 1.10), 0.20)
				tw.parallel().tween_property(card, "modulate", Color(1.8, 1.6, 1.0, 1.0), 0.20)
			else:
				tw.tween_property(card, "modulate:a", 0.0, 0.20)
	
	var fade_tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tw.tween_interval(0.30)
	fade_tw.tween_property(overlay, "modulate:a", 0.0, 0.20)
	fade_tw.tween_callback(func():
		visible = false
	)"""

up_code = up_code.replace(target_up_select, repl_up_select)

up_code = up_code.replace(
    "func play_chime() -> void:\n",
    "func play_chime() -> void:\n\tif not is_instance_valid(audio_player) or not is_inside_tree():\n\t\treturn\n"
)

with open("scripts/upgrade_select_ui.gd", "w", encoding="utf-8") as f:
    f.write(up_code)
print("upgrade_select_ui updated!")

# Update game_over_ui.gd
with open("scripts/game_over_ui.gd", "r", encoding="utf-8") as f:
    go_code = f.read()

target_go_init = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 130
	setup_ui()
	visible = false

func _ready() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = "Master"
		add_child(audio_player)"""

repl_go_init = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 130
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	setup_ui()
	visible = false"""

go_code = go_code.replace(target_go_init, repl_go_init)

go_code = go_code.replace(
    "func play_somber_drone() -> void:\n",
    "func play_somber_drone() -> void:\n\tif not is_instance_valid(audio_player) or not is_inside_tree():\n\t\treturn\n"
)

with open("scripts/game_over_ui.gd", "w", encoding="utf-8") as f:
    f.write(go_code)
print("game_over_ui updated!")

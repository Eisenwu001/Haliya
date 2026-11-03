# Update upgrade_select_ui.gd
with open("scripts/upgrade_select_ui.gd", "r", encoding="utf-8") as f:
    up_code = f.read()

target_up = """func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120 # Above main HUD
	
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	
	setup_ui()
	visible = false"""

repl_up = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	setup_ui()
	visible = false

func _ready() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = "Master"
		add_child(audio_player)"""

up_code = up_code.replace(target_up, repl_up)
with open("scripts/upgrade_select_ui.gd", "w", encoding="utf-8") as f:
    f.write(up_code)
print("upgrade_select_ui updated!")

# Update game_over_ui.gd
with open("scripts/game_over_ui.gd", "r", encoding="utf-8") as f:
    go_code = f.read()

target_go = """func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 130 # Topmost layer
	
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	
	setup_ui()
	visible = false"""

repl_go = """func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 130
	setup_ui()
	visible = false

func _ready() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = "Master"
		add_child(audio_player)"""

go_code = go_code.replace(target_go, repl_go)
with open("scripts/game_over_ui.gd", "w", encoding="utf-8") as f:
    f.write(go_code)
print("game_over_ui updated!")

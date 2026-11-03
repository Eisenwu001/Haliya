with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\r\n', '\n')

# 1. _process restart guard
old_proc = """func _process(delta: float) -> void:
\tif Input.is_action_just_pressed("restart"):
\t\trestart_game()
\t\treturn"""

new_proc = """func _process(delta: float) -> void:
\tif is_game_won and Input.is_action_just_pressed("restart"):
\t\trestart_game()
\t\treturn"""

assert old_proc in text, "old_proc not found"
text = text.replace(old_proc, new_proc)

# 2. _on_player_died guards & BGM fade
old_death = """func _on_player_died() -> void:
\tdeath_count += 1
\tis_player_dead = true"""

new_death = """func _on_player_died() -> void:
\tif is_player_dead:
\t\treturn
\tis_player_dead = true
\tdeath_count += 1
\tEngine.time_scale = 1.0
\thit_stop_timer = 0.0

\tif is_instance_valid(bgm_audio_player) and bgm_audio_player.playing:
\t\tvar tw_bgm = create_tween()
\t\ttw_bgm.tween_property(bgm_audio_player, "volume_db", -50.0, 0.8)
\t\ttw_bgm.tween_callback(func():
\t\t\tif is_instance_valid(bgm_audio_player):
\t\t\t\tbgm_audio_player.stop()
\t\t)"""

assert old_death in text, "old_death not found"
text = text.replace(old_death, new_death)

# 3. _on_return_to_title_requested unpause
old_ret = """func _on_return_to_title_requested() -> void:
\tEngine.time_scale = 1.0
\tget_tree().change_scene_to_file("res://scenes/main_menu.tscn")"""

new_ret = """func _on_return_to_title_requested() -> void:
\tEngine.time_scale = 1.0
\tget_tree().paused = false
\tget_tree().change_scene_to_file("res://scenes/main_menu.tscn")"""

assert old_ret in text, "old_ret not found"
text = text.replace(old_ret, new_ret)

# 4. restart_game reset game_over_ui
old_rst = """\tif is_instance_valid(game_over_ui):
\t\tgame_over_ui.visible = false"""

new_rst = """\tif is_instance_valid(game_over_ui):
\t\tif game_over_ui.has_method("reset"):
\t\t\tgame_over_ui.reset()
\t\telse:
\t\t\tgame_over_ui.visible = false"""

assert old_rst in text, "old_rst not found"
text = text.replace(old_rst, new_rst, 1) # Only first occurrence in restart_game

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Successfully patched scripts/main.gd")

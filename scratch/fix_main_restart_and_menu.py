with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target1 = 'get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")'
repl1 = 'get_tree().change_scene_to_file("res://scenes/main_menu.tscn")'

assert target1 in c, "target1 not found in main.gd"
c = c.replace(target1, repl1)

# In _on_restart_run_requested, reset has_activated_boss_checkpoint
target2 = """func _on_restart_run_requested() -> void:
\trestart_game()"""

repl2 = """func _on_restart_run_requested() -> void:
\thas_activated_boss_checkpoint = false
\trestart_game()"""

assert target2 in c, "target2 not found in main.gd"
c = c.replace(target2, repl2)

# In restart_game(), reset has_activated_boss_checkpoint = false
target3 = """\tis_game_won = false
\tis_player_dead = false"""

repl3 = """\tis_game_won = false
\tis_player_dead = false
\thas_activated_boss_checkpoint = false"""

assert target3 in c, "target3 not found in main.gd"
c = c.replace(target3, repl3)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: scripts/main.gd title scene path and restart logic fixed!")

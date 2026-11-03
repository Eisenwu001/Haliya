with open('scripts/game_over_ui.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = """func play_somber_drone() -> void:
\tif not is_instance_valid(audio_player):
\t\treturn"""

repl = """func play_somber_drone() -> void:
\tif not is_inside_tree() or not is_instance_valid(audio_player):
\t\treturn"""

assert target in c, "target not found"
c = c.replace(target, repl)

with open('scripts/game_over_ui.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Guarded play_somber_drone with is_inside_tree()")

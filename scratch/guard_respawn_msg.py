with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = """func show_respawn_message() -> void:
\tif has_activated_boss_checkpoint:
\t\trespawn_label.text = "Respawned at Ancestral Shrine: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
\telse:
\t\trespawn_label.text = "Respawned at Checkpoint: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
\trespawn_label.modulate = Color(1, 1, 1, 1)
\trespawn_label.visible = true
\trespawn_msg_timer = RESPAWN_MSG_DURATION"""

repl = """func show_respawn_message() -> void:
\tif not is_instance_valid(respawn_label):
\t\treturn
\tif has_activated_boss_checkpoint:
\t\trespawn_label.text = "Respawned at Ancestral Shrine: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
\telse:
\t\trespawn_label.text = "Respawned at Checkpoint: %s" % LEVELS_DATA[current_level_idx]["scene_title"]
\trespawn_label.modulate = Color(1, 1, 1, 1)
\trespawn_label.visible = true
\trespawn_msg_timer = RESPAWN_MSG_DURATION"""

assert target in c, "target not found in main.gd"
c = c.replace(target, repl)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Guarded show_respawn_message in main.gd")

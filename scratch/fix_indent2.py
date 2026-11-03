with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = """\t\tif respawn_msg_timer <= 0.0:
\t\t\tif is_instance_valid(respawn_label):
\t\trespawn_label.visible = false
\t\t\tis_player_dead = false"""

repl = """\t\tif respawn_msg_timer <= 0.0:
\t\t\tif is_instance_valid(respawn_label):
\t\t\t\trespawn_label.visible = false
\t\t\tis_player_dead = false"""

assert target in c, "target not found"
c = c.replace(target, repl)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Fixed indentation in main.gd line 3040-3044")

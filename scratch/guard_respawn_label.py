with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = "\trespawn_label.visible = false"
repl = "\tif is_instance_valid(respawn_label):\n\t\trespawn_label.visible = false"

assert target in c, "target not found"
c = c.replace(target, repl)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Guarded respawn_label in restart_game()")

with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = "win_overlay.visible = false"
repl = "if is_instance_valid(win_overlay):\n\t\twin_overlay.visible = false"

assert target in c, "target not found"
c = c.replace(target, repl)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Guarded win_overlay in restart_game()")

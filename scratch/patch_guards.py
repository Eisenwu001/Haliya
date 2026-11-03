# Patch forest_brute_miniboss.gd
with open('scripts/forest_brute_miniboss.gd', 'r', encoding='utf-8') as f:
    fb = f.read().replace('\r\n', '\n')

fb = fb.replace(
    '\thurt_flash_timer = 0.22\n\tsprite.modulate = Color(2.5, 0.4, 0.4, 1.0)',
    '\thurt_flash_timer = 0.22\n\tif is_instance_valid(sprite):\n\t\tsprite.modulate = Color(2.5, 0.4, 0.4, 1.0)'
)

fb = fb.replace(
    'func _trigger_screen_shake(amount: float) -> void:\n\tvar main_node = get_tree().current_scene',
    'func _trigger_screen_shake(amount: float) -> void:\n\tif not is_inside_tree() or not get_tree():\n\t\treturn\n\tvar main_node = get_tree().current_scene'
)

fb = fb.replace(
    'func _trigger_hit_stop(duration: float = 0.045) -> void:\n\tvar main_node = get_tree().current_scene',
    'func _trigger_hit_stop(duration: float = 0.045) -> void:\n\tif not is_inside_tree() or not get_tree():\n\t\treturn\n\tvar main_node = get_tree().current_scene'
)

with open('scripts/forest_brute_miniboss.gd', 'w', encoding='utf-8') as f:
    f.write(fb)

# Patch mayon_vanguard_miniboss.gd
with open('scripts/mayon_vanguard_miniboss.gd', 'r', encoding='utf-8') as f:
    mv = f.read().replace('\r\n', '\n')

mv = mv.replace(
    'func _trigger_screen_shake(amount: float) -> void:\n\tvar main_node = get_tree().current_scene',
    'func _trigger_screen_shake(amount: float) -> void:\n\tif not is_inside_tree() or not get_tree():\n\t\treturn\n\tvar main_node = get_tree().current_scene'
)

mv = mv.replace(
    'func _trigger_hit_stop(duration: float = 0.045) -> void:\n\tvar main_node = get_tree().current_scene',
    'func _trigger_hit_stop(duration: float = 0.045) -> void:\n\tif not is_inside_tree() or not get_tree():\n\t\treturn\n\tvar main_node = get_tree().current_scene'
)

with open('scripts/mayon_vanguard_miniboss.gd', 'w', encoding='utf-8') as f:
    f.write(mv)

print("Guards patched successfully in forest_brute and mayon_vanguard")

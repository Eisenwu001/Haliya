with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\r\n', '\n')
old_block = """func _on_return_to_title_requested() -> void:
\tEngine.time_scale = 1.0
\tget_tree().paused = false
\tget_tree().change_scene_to_file("res://scenes/main_menu.tscn")"""

new_block = """func _on_return_to_title_requested() -> void:
\tEngine.time_scale = 1.0
\tif is_inside_tree() and get_tree():
\t\tget_tree().paused = false
\t\tget_tree().change_scene_to_file("res://scenes/main_menu.tscn")"""

assert old_block in text, "old_block not found"
text = text.replace(old_block, new_block)

with open('scripts/main.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated _on_return_to_title_requested in main.gd")

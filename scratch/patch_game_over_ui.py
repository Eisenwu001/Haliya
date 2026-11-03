with open('scripts/game_over_ui.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\r\n', '\n')

# 1. Make center_container sibling of overlay
old_hier = """\t# 2. Fullscreen CenterContainer: MOUSE_FILTER_PASS allows mouse clicks to reach buttons
\tcenter_container = CenterContainer.new()
\tcenter_container.name = "CenterContainer"
\tcenter_container.set_anchors_preset(Control.PRESET_FULL_RECT)
\tcenter_container.mouse_filter = Control.MOUSE_FILTER_PASS
\toverlay.add_child(center_container)"""

new_hier = """\t# 2. Fullscreen CenterContainer: MOUSE_FILTER_PASS allows mouse clicks to reach buttons
\tcenter_container = CenterContainer.new()
\tcenter_container.name = "CenterContainer"
\tcenter_container.set_anchors_preset(Control.PRESET_FULL_RECT)
\tcenter_container.mouse_filter = Control.MOUSE_FILTER_PASS
\tadd_child(center_container)"""

assert old_hier in text, "old_hier not found"
text = text.replace(old_hier, new_hier)

# 2. Guard buttons in on_restart_pressed and on_menu_pressed + add reset()
old_handlers = """func on_restart_pressed() -> void:
\tif not is_active:
\t\treturn
\tis_active = false
\tvisible = false
\trestart_run_requested.emit()


func on_menu_pressed() -> void:
\tif not is_active:
\t\treturn
\tis_active = false
\tvisible = false
\treturn_to_title_requested.emit()"""

new_handlers = """func reset() -> void:
\tis_active = false
\tvisible = false
\tif is_instance_valid(btn_restart):
\t\tbtn_restart.disabled = true
\tif is_instance_valid(btn_menu):
\t\tbtn_menu.disabled = true
\tif is_instance_valid(audio_player) and audio_player.playing:
\t\taudio_player.stop()


func on_restart_pressed() -> void:
\tif not is_active or (is_instance_valid(btn_restart) and btn_restart.disabled):
\t\treturn
\tis_active = false
\tvisible = false
\trestart_run_requested.emit()


func on_menu_pressed() -> void:
\tif not is_active or (is_instance_valid(btn_menu) and btn_menu.disabled):
\t\treturn
\tis_active = false
\tvisible = false
\treturn_to_title_requested.emit()"""

assert old_handlers in text, "old_handlers not found"
text = text.replace(old_handlers, new_handlers)

with open('scripts/game_over_ui.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Successfully patched scripts/game_over_ui.gd")

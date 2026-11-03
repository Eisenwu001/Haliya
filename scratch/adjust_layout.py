with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    'press_start_container.offset_left = -190.0\n\tpress_start_container.offset_right = 190.0\n\tpress_start_container.offset_top = 65.0\n\tpress_start_container.offset_bottom = 105.0\n\tpress_start_container.pivot_offset = Vector2(190.0, 20.0)',
    'press_start_container.offset_left = -160.0\n\tpress_start_container.offset_right = 130.0\n\tpress_start_container.offset_top = 70.0\n\tpress_start_container.offset_bottom = 106.0\n\tpress_start_container.pivot_offset = Vector2(145.0, 18.0)'
)

text = text.replace(
    'press_start_container.offset_left = -190.0\r\n\tpress_start_container.offset_right = 190.0\r\n\tpress_start_container.offset_top = 65.0\r\n\tpress_start_container.offset_bottom = 105.0\r\n\tpress_start_container.pivot_offset = Vector2(190.0, 20.0)',
    'press_start_container.offset_left = -160.0\r\n\tpress_start_container.offset_right = 130.0\r\n\tpress_start_container.offset_top = 70.0\r\n\tpress_start_container.offset_bottom = 106.0\r\n\tpress_start_container.pivot_offset = Vector2(145.0, 18.0)'
)

text = text.replace(
    'press_start_label.add_theme_font_size_override("font_size", 14)',
    'press_start_label.add_theme_font_size_override("font_size", 13)'
)

with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Adjusted layout successfully!")

with open('scripts/test_cultural_and_settings_features.gd', 'r', encoding='utf-8') as f:
    text = f.read().replace('\r\n', '\n')

old_line = 'assert(santelmo.health == 2, "Santelmo initial health must be 2")'
new_line = 'assert(santelmo.health == 4, "Santelmo initial health must be 4")'

assert old_line in text, "old_line not found"
text = text.replace(old_line, new_line)

with open('scripts/test_cultural_and_settings_features.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated test_cultural_and_settings_features.gd")

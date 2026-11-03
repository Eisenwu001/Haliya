with open("scripts/test_cultural_and_settings_features.gd", "r", encoding="utf-8") as f:
    c = f.read()

target = 'assert(main_inst.get("baybayin_area_label") != null, "main.tscn must have baybayin_area_label")'
replacement = 'assert(main_inst.get("stage_name_label") != null, "main.tscn must have stage_name_label")'
assert target in c, "target not found"
c = c.replace(target, replacement, 1)

with open("scripts/test_cultural_and_settings_features.gd", "w", encoding="utf-8") as f:
    f.write(c)

print("test_cultural_and_settings_features.gd updated!")

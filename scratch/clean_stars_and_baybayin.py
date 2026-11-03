# clean_stars_and_baybayin.py

def clean_file(path, replacements):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
        else:
            print(f"Warning: pattern not found in {path}: {repr(old[:30])}")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Cleaned {path}")

# 1. scripts/upgrade_select_ui.gd
clean_file("scripts/upgrade_select_ui.gd", [
    ('title_lbl.text = "✦ ANCESTRAL LUNAR SHRINE ✦"', 'title_lbl.text = "ANCESTRAL LUNAR SHRINE"'),
])

# 2. scripts/main_menu.gd
clean_file("scripts/main_menu.gd", [
    ('const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")\n', ''),
    ("""\tvar baybayin_header = Label.new()
\tbaybayin_header.name = "BaybayinHeader"
\tbaybayin_header.position = Vector2(0, -6)
\tbaybayin_header.size = Vector2(260, 18)
\tbaybayin_header.text = "✦  ᜑᜎᜒᜌ: ᜋᜐ᜔ᜃᜇ ᜅ᜔ ᜎᜓᜅ᜔ᜃᜓᜆ᜔  ✦"
\tvar b_font = BaybayinLabelScript.get_baybayin_font()
\tif b_font:
\t\tbaybayin_header.add_theme_font_override("font", b_font)
\tbaybayin_header.add_theme_font_size_override("font_size", 12)
\tbaybayin_header.add_theme_color_override("font_color", Color(1.0, 0.90, 0.50, 0.92))
\tbaybayin_header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tbaybayin_header.add_theme_constant_override("shadow_offset_x", 1)
\tbaybayin_header.add_theme_constant_override("shadow_offset_y", 1)
\ttitle_container.add_child(baybayin_header)
""", ''),
    ("""\tvar s3_baybayin = Label.new()
\ts3_baybayin.name = "Step3Baybayin"
\ts3_baybayin.text = "✦  ᜑᜎᜒᜌ: ᜋᜐ᜔ᜃᜇ ᜅ᜔ ᜎᜓᜅ᜔ᜃᜓᜆ᜔  ✦"
\tvar b_font3 = BaybayinLabelScript.get_baybayin_font()
\tif b_font3:
\t\ts3_baybayin.add_theme_font_override("font", b_font3)
\ts3_baybayin.add_theme_font_size_override("font_size", 16)
\ts3_baybayin.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 0.95))
\ts3_baybayin.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\ts3_baybayin.add_theme_constant_override("shadow_offset_x", 1)
\ts3_baybayin.add_theme_constant_override("shadow_offset_y", 1)
\ts3_baybayin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tstep3_title_box.add_child(s3_baybayin)
""", ''),
])

# 3. scripts/main.gd
clean_file("scripts/main.gd", [
    ('const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")\n', ''),
    ('var baybayin_area_label: Control\n', ''),
    ("""\tbaybayin_area_label = BaybayinLabelScript.new()
\tbaybayin_area_label.name = "BaybayinAreaLabel"
\tbaybayin_area_label.position = Vector2(0, 0)
\tbaybayin_area_label.size = Vector2(640, 52)
\tarea_discovery_container.add_child(baybayin_area_label)

\tstage_name_label = Label.new()
\tstage_name_label.name = "StageNameLabel"
\tstage_name_label.visible = false""",
     """\tstage_name_label = Label.new()
\tstage_name_label.name = "StageNameLabel"
\tstage_name_label.position = Vector2(0, 0)
\tstage_name_label.size = Vector2(640, 36)
\tstage_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tstage_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tstage_name_label.text = cur_data.get("scene_title", "")
\tstage_name_label.add_theme_font_override("font", custom_font)
\tstage_name_label.add_theme_font_size_override("font_size", 24)
\tstage_name_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1.0))
\tstage_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tstage_name_label.add_theme_constant_override("shadow_offset_x", 2)
\tstage_name_label.add_theme_constant_override("shadow_offset_y", 2)"""),
    ("""\tif is_instance_valid(baybayin_area_label):
\t\tbaybayin_area_label.play_decode_sequence(display_stage, "", 22)
\tif stage_name_label:""",
     """\tif stage_name_label:
\t\tstage_name_label.text = display_stage
\t\t# Elegant golden glow shimmer
\t\tstage_name_label.modulate = Color(1.4, 1.3, 0.9, 1.0)
\t\tvar tw = stage_name_label.create_tween()
\t\ttw.tween_property(stage_name_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)"""),
    ('ep_title.text = "✦ THE SEVENTH MOON RESTORED ✦"', 'ep_title.text = "THE SEVENTH MOON RESTORED"'),
])

# 4. scripts/act1_bahay_kubo.gd
clean_file("scripts/act1_bahay_kubo.gd", [
    ('const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")\n', ''),
    ('var baybayin_area_label: Control\n', ''),
    ("""\t# Baybayin Discovery Banner
\tbaybayin_area_label = BaybayinLabelScript.new()
\tbaybayin_area_label.name = "BaybayinAreaLabel"
\tbaybayin_area_label.position = Vector2(120, 38)
\tbaybayin_area_label.size = Vector2(400, 48)
\tui_layer.add_child(baybayin_area_label)

\t# Area Discovery Label (Center Upper)
\tarea_title_label = Label.new()
\tarea_title_label.visible = false""",
     """\t# Area Discovery Label (Center Upper)
\tarea_title_label = Label.new()
\tarea_title_label.position = Vector2(120, 50)
\tarea_title_label.size = Vector2(400, 32)
\tarea_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tarea_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tarea_title_label.text = "ACT 1 — BAHAY KUBO (THE HOMESTEAD)"
\tarea_title_label.add_theme_font_override("font", custom_font)
\tarea_title_label.add_theme_font_size_override("font_size", 16)
\tarea_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
\tarea_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tarea_title_label.visible = true"""),
    ("""func trigger_area_discovery(text_title: String) -> void:
\tif is_instance_valid(baybayin_area_label):
\t\tbaybayin_area_label.play_decode_sequence(text_title, "", 18)
\t\tbaybayin_area_label.modulate.a = 1.0
\tarea_title_timer = 3.6""",
     """func trigger_area_discovery(text_title: String) -> void:
\tif area_title_label:
\t\tarea_title_label.text = text_title
\t\tarea_title_label.modulate.a = 1.0
\tarea_title_timer = 3.6"""),
    ("""\tif area_title_timer > 0.0:
\t\tarea_title_timer -= delta
\t\tvar alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
\t\tif is_instance_valid(baybayin_area_label):
\t\t\tbaybayin_area_label.modulate.a = alpha
\t\telif area_title_label:
\t\t\tarea_title_label.modulate.a = alpha""",
     """\tif area_title_timer > 0.0:
\t\tarea_title_timer -= delta
\t\tvar alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
\t\tif area_title_label:
\t\t\tarea_title_label.modulate.a = alpha"""),
    ('trigger_area_discovery("✦ PATH TO THE OVERWORLD UNLOCKED ✦")', 'trigger_area_discovery("PATH TO THE OVERWORLD UNLOCKED")'),
])

# 5. scripts/game_over_ui.gd
clean_file("scripts/game_over_ui.gd", [
    ('title_lbl.text = "✦ THE ECLIPSE CLAIMS ANOTHER ✦"', 'title_lbl.text = "THE ECLIPSE CLAIMS ANOTHER"'),
])

# 6. NPC & Enemies floating text / prompts
clean_file("scripts/kapre_npc.gd", [
    ('prompt_label.text = "✦ [E] Speak to Kapre ✦"', 'prompt_label.text = "[E] Speak to Kapre"'),
])
clean_file("scripts/mask_altar.gd", [
    ('prompt_label.text = "✦ [E] Claim Mask of Sorrow ✦"', 'prompt_label.text = "[E] Claim Mask of Sorrow"'),
    ('✦ Mask of Sorrow Claimed! The gateway to the Corrupted Overworld is now open. ✦', 'Mask of Sorrow Claimed! The gateway to the Corrupted Overworld is now open.'),
])
clean_file("scripts/weapon_rack.gd", [
    ('prompt_label.text = "✦ [E] Choose Weapon ✦"', 'prompt_label.text = "[E] Choose Weapon"'),
    ('prompt_label.text = "✦ Equipped: %s ✦"', 'prompt_label.text = "Equipped: %s"'),
])
clean_file("scripts/dialogue_manager.gd", [
    ('btn.text = "✦ " + choice_text', 'btn.text = "> " + choice_text'),
])

for enemy_file in ["scripts/aswang.gd", "scripts/corrupted_farmer.gd", "scripts/santelmo.gd", "scripts/skeleton.gd"]:
    clean_file(enemy_file, [
        ('"✦ ELITE SLAIN ✦"', '"ELITE SLAIN"'),
    ])

print("All stars and Baybayin UI cleanly stripped!")

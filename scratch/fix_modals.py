# Update scripts/settings_menu.gd
with open("scripts/settings_menu.gd", "r", encoding="utf-8") as f:
    sm = f.read()

# Remove BaybayinLabelScript preload
sm = sm.replace('const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")\n', '')

# Fix panel positioning and centering
old_panel = """\tpanel = PanelContainer.new()
\tpanel.name = "SettingsPanel"
\tpanel.set_anchors_preset(Control.PRESET_CENTER)
\tpanel.custom_minimum_size = Vector2(480, 310)
\tpanel.position = Vector2(80, 25)"""

new_panel = """\tpanel = PanelContainer.new()
\tpanel.name = "SettingsPanel"
\tpanel.anchor_left = 0.5
\tpanel.anchor_right = 0.5
\tpanel.anchor_top = 0.5
\tpanel.anchor_bottom = 0.5
\tpanel.offset_left = -240.0
\tpanel.offset_right = 240.0
\tpanel.offset_top = -150.0
\tpanel.offset_bottom = 150.0
\tpanel.grow_horizontal = Control.GROW_DIRECTION_BOTH
\tpanel.grow_vertical = Control.GROW_DIRECTION_BOTH"""

assert old_panel in sm, "old_panel not found in settings_menu.gd"
sm = sm.replace(old_panel, new_panel, 1)

# Replace Baybayin header with pure Alagard header
old_header = """\t# Header with Baybayin
\tvar baybayin_header := BaybayinLabelScript.new()
\tbaybayin_header.set_text("REALM SETTINGS & OPTIONS", "ᜉᜄ᜔ᜉᜒᜉᜒᜎᜒ")
\tmain_vbox.add_child(baybayin_header)"""

new_header = """\t# Header
\tvar header_lbl := Label.new()
\theader_lbl.name = "SettingsHeader"
\theader_lbl.text = "SETTINGS & OPTIONS"
\theader_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\theader_lbl.add_theme_font_override("font", FONT_ALAGARD)
\theader_lbl.add_theme_font_size_override("font_size", 16)
\theader_lbl.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
\theader_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\theader_lbl.add_theme_constant_override("shadow_offset_x", 1)
\theader_lbl.add_theme_constant_override("shadow_offset_y", 1)
\tmain_vbox.add_child(header_lbl)"""

assert old_header in sm, "old_header not found in settings_menu.gd"
sm = sm.replace(old_header, new_header, 1)

with open("scripts/settings_menu.gd", "w", encoding="utf-8") as f:
    f.write(sm)
print("settings_menu.gd updated!")

# Update scripts/bestiary_codex_ui.gd
with open("scripts/bestiary_codex_ui.gd", "r", encoding="utf-8") as f:
    bc = f.read()

bc = bc.replace('const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")\n', '')

old_bc_panel = """\tpanel = PanelContainer.new()
\tpanel.name = "CodexPanel"
\tpanel.set_anchors_preset(Control.PRESET_CENTER)
\tpanel.custom_minimum_size = Vector2(500, 310)
\tpanel.position = Vector2(70, 25)"""

new_bc_panel = """\tpanel = PanelContainer.new()
\tpanel.name = "CodexPanel"
\tpanel.anchor_left = 0.5
\tpanel.anchor_right = 0.5
\tpanel.anchor_top = 0.5
\tpanel.anchor_bottom = 0.5
\tpanel.offset_left = -250.0
\tpanel.offset_right = 250.0
\tpanel.offset_top = -150.0
\tpanel.offset_bottom = 150.0
\tpanel.grow_horizontal = Control.GROW_DIRECTION_BOTH
\tpanel.grow_vertical = Control.GROW_DIRECTION_BOTH"""

assert old_bc_panel in bc, "old_bc_panel not found in bestiary_codex_ui.gd"
bc = bc.replace(old_bc_panel, new_bc_panel, 1)

old_bc_header = """\t# Header with Baybayin
\tvar baybayin_header := BaybayinLabelScript.new()
\tbaybayin_header.set_text("ANCESTRAL ALTAR & LORE CODEX", "ᜇᜋ᜔ᜊᜈ")
\tmain_vbox.add_child(baybayin_header)"""

new_bc_header = """\t# Header
\tvar header_lbl := Label.new()
\theader_lbl.name = "CodexHeader"
\theader_lbl.text = "ANCESTRAL ALTAR & LORE CODEX"
\theader_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\theader_lbl.add_theme_font_override("font", FONT_ALAGARD)
\theader_lbl.add_theme_font_size_override("font_size", 16)
\theader_lbl.add_theme_color_override("font_color", Color(0.96, 0.90, 0.75, 1.0))
\theader_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\theader_lbl.add_theme_constant_override("shadow_offset_x", 1)
\theader_lbl.add_theme_constant_override("shadow_offset_y", 1)
\tmain_vbox.add_child(header_lbl)"""

assert old_bc_header in bc, "old_bc_header not found in bestiary_codex_ui.gd"
bc = bc.replace(old_bc_header, new_bc_header, 1)

# Remove stars from pearls label
bc = bc.replace('pearls_label.text = "✦ MOON PEARLS: %d ✦" % MetaProgression.moon_pearls', 'pearls_label.text = "MOON PEARLS: %d" % MetaProgression.moon_pearls')

# Remove Baybayin label and stars from bestiary card loop
old_card_content = """\t\tif is_unlocked:
\t\t\tvar b_lbl := Label.new()
\t\t\tb_lbl.text = "✦ %s ✦" % data.get("baybayin", "")
\t\t\tif b_font:
\t\t\t\tb_lbl.add_theme_font_override("font", b_font)
\t\t\tb_lbl.add_theme_font_size_override("font_size", 16)
\t\t\tb_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
\t\t\tcvbox.add_child(b_lbl)
\t\t\t
\t\t\tvar name_lbl := Label.new()
\t\t\tname_lbl.text = data.get("name", key)
\t\t\tname_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tname_lbl.add_theme_font_size_override("font_size", 13)
\t\t\tname_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
\t\t\tcvbox.add_child(name_lbl)
\t\t\t
\t\t\tvar lore_lbl := Label.new()
\t\t\tlore_lbl.text = data.get("lore", "")
\t\t\tlore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\t\t\tlore_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tlore_lbl.add_theme_font_size_override("font_size", 10)
\t\t\tlore_lbl.add_theme_color_override("font_color", Color(0.80, 0.85, 0.92, 0.85))
\t\t\tcvbox.add_child(lore_lbl)
\t\telse:
\t\t\tvar locked_lbl := Label.new()
\t\t\tlocked_lbl.text = "✦ ??? (Undiscovered Mythological Night Terror) ✦\\nDefeat this monster during your journey to decipher its ancient lore."
\t\t\tlocked_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\t\t\tlocked_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tlocked_lbl.add_theme_font_size_override("font_size", 10)
\t\t\tlocked_lbl.add_theme_color_override("font_color", Color(0.45, 0.50, 0.60, 0.70))
\t\t\tcvbox.add_child(locked_lbl)"""

new_card_content = """\t\tif is_unlocked:
\t\t\tvar name_lbl := Label.new()
\t\t\tname_lbl.text = data.get("name", key)
\t\t\tname_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tname_lbl.add_theme_font_size_override("font_size", 13)
\t\t\tname_lbl.add_theme_color_override("font_color", Color(0.98, 0.92, 0.75, 1.0))
\t\t\tcvbox.add_child(name_lbl)
\t\t\t
\t\t\tvar lore_lbl := Label.new()
\t\t\tlore_lbl.text = data.get("lore", "")
\t\t\tlore_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\t\t\tlore_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tlore_lbl.add_theme_font_size_override("font_size", 10)
\t\t\tlore_lbl.add_theme_color_override("font_color", Color(0.80, 0.85, 0.92, 0.85))
\t\t\tcvbox.add_child(lore_lbl)
\t\telse:
\t\t\tvar locked_lbl := Label.new()
\t\t\tlocked_lbl.text = "??? (Undiscovered Mythological Night Terror)\\nDefeat this creature during your journey to decipher its ancient lore."
\t\t\tlocked_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
\t\t\tlocked_lbl.add_theme_font_override("font", FONT_ALAGARD)
\t\t\tlocked_lbl.add_theme_font_size_override("font_size", 10)
\t\t\tlocked_lbl.add_theme_color_override("font_color", Color(0.45, 0.50, 0.60, 0.70))
\t\t\tcvbox.add_child(locked_lbl)"""

assert old_card_content in bc, "old_card_content not found in bestiary_codex_ui.gd"
bc = bc.replace(old_card_content, new_card_content, 1)

bc = bc.replace("var b_font = BaybayinLabelScript.get_baybayin_font()\n\t\n", "")

with open("scripts/bestiary_codex_ui.gd", "w", encoding="utf-8") as f:
    f.write(bc)
print("bestiary_codex_ui.gd updated!")

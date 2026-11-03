# 1. Update scripts/upgrade_manager.gd
with open("scripts/upgrade_manager.gd", "r", encoding="utf-8") as f:
    um = f.read()

# Add icon_path to each upgrade
replacements = [
    ('"icon": "❤",', '"icon": "❤",\n\t\t"icon_path": "res://assets/ui/icons/icon_vitality.png",'),
    ('"icon": "⚔",', '"icon": "⚔",\n\t\t"icon_path": "res://assets/ui/icons/icon_damage.png",'),
    ('"icon": "⚡",', '"icon": "⚡",\n\t\t"icon_path": "res://assets/ui/icons/icon_stamina.png",'),
    ('"icon": "🍃",', '"icon": "🍃",\n\t\t"icon_path": "res://assets/ui/icons/icon_swiftness.png",'),
    ('"icon": "🛡",', '"icon": "🛡",\n\t\t"icon_path": "res://assets/ui/icons/icon_aegis.png",'),
    ('"icon": "🩸",', '"icon": "🩸",\n\t\t"icon_path": "res://assets/ui/icons/icon_riposte.png",'),
    ('"icon": "🌙",', '"icon": "🌙",\n\t\t"icon_path": "res://assets/ui/icons/icon_shockwave.png",'),
    ('"icon": "👻",', '"icon": "👻",\n\t\t"icon_path": "res://assets/ui/icons/icon_ghost_dash.png",'),
    ('"icon": "💫",', '"icon": "💫",\n\t\t"icon_path": "res://assets/ui/icons/icon_eclipse_pogo.png",'),
]

for old, new in replacements:
    assert old in um, f"Target {old} not found in upgrade_manager.gd"
    um = um.replace(old, new, 1)

with open("scripts/upgrade_manager.gd", "w", encoding="utf-8") as f:
    f.write(um)
print("Updated upgrade_manager.gd with icon paths!")

# 2. Update scripts/upgrade_select_ui.gd
with open("scripts/upgrade_select_ui.gd", "r", encoding="utf-8") as f:
    ui = f.read()

old_icon_block = """\t# Icon Glyph
\tvar icon_lbl := Label.new()
\ticon_lbl.text = data.get("icon", "✦")
\ticon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\ticon_lbl.add_theme_font_override("font", FONT_RES)
\ticon_lbl.add_theme_font_size_override("font_size", 28)
\ticon_lbl.add_theme_color_override("font_color", cat_col)
\tvbox.add_child(icon_lbl)"""

new_icon_block = """\t# Icon - Authentic Philippine Mythology Pixel-Art Relic
\tvar icon_container := CenterContainer.new()
\ticon_container.custom_minimum_size = Vector2(36, 36)
\tvbox.add_child(icon_container)
\t
\tvar icon_rect := TextureRect.new()
\ticon_rect.name = "UpgradeIcon"
\ticon_rect.custom_minimum_size = Vector2(32, 32)
\ticon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\ticon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\t
\tvar icon_path: String = data.get("icon_path", "")
\tvar icon_tex: Texture2D = null
\tif icon_path != "":
\t\tif ResourceLoader.exists(icon_path):
\t\t\tvar res = load(icon_path)
\t\t\tif res is Texture2D:
\t\t\t\ticon_tex = res
\t\tif not icon_tex:
\t\t\tvar global_p = ProjectSettings.globalize_path(icon_path)
\t\t\tif FileAccess.file_exists(global_p):
\t\t\t\tvar img = Image.new()
\t\t\t\tif img.load(global_p) == OK:
\t\t\t\t\ticon_tex = ImageTexture.create_from_image(img)
\tif icon_tex:
\t\ticon_rect.texture = icon_tex
\ticon_container.add_child(icon_rect)"""

assert old_icon_block in ui, "old_icon_block not found in upgrade_select_ui.gd"
ui = ui.replace(old_icon_block, new_icon_block, 1)

with open("scripts/upgrade_select_ui.gd", "w", encoding="utf-8") as f:
    f.write(ui)
print("Updated upgrade_select_ui.gd with TextureRect icon rendering!")

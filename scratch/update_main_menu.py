with open("scripts/main_menu.gd", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add preloads & script constants
old_head = """const AssetsScript = preload("res://scripts/assets.gd")
const MainScript = preload("res://scripts/main.gd")
const FONT_ALAGARD = preload("res://alagard.ttf")"""

new_head = """const AssetsScript = preload("res://scripts/assets.gd")
const MainScript = preload("res://scripts/main.gd")
const FONT_ALAGARD = preload("res://alagard.ttf")
const SettingsMenuScript = preload("res://scripts/settings_menu.gd")
const BestiaryCodexUIScript = preload("res://scripts/bestiary_codex_ui.gd")
const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")"""

assert old_head in content, "old_head not found"
content = content.replace(old_head, new_head, 1)

# 2. Add variable declarations
old_vars = """var is_transitioning: bool = false
var bgm_player: AudioStreamPlayer
var sfx_ui_player: AudioStreamPlayer"""

new_vars = """var is_transitioning: bool = false
var bgm_player: AudioStreamPlayer
var sfx_ui_player: AudioStreamPlayer
var settings_menu: SettingsMenu
var bestiary_codex_ui: BestiaryCodexUI"""

assert old_vars in content, "old_vars not found"
content = content.replace(old_vars, new_vars, 1)

# 3. In _ready(), initialize settings_menu and bestiary_codex_ui
old_ready_setup = """\tsetup_stage_select_modal()
\tsetup_controls_modal()"""

new_ready_setup = """\tsetup_stage_select_modal()
\tsetup_controls_modal()
\tsetup_settings_and_codex_modals()"""

assert old_ready_setup in content, "old_ready_setup not found"
content = content.replace(old_ready_setup, new_ready_setup, 1)

# 4. In setup_ui(), add baybayin_header in title_container
old_title_box = """\ttitle_container = Control.new()
\ttitle_container.name = "TitleContainer"
\ttitle_container.anchor_left = 0.0
\ttitle_container.anchor_right = 0.0
\ttitle_container.offset_left = 52.0
\ttitle_container.offset_right = 320.0
\ttitle_container.offset_top = 40.0
\ttitle_container.offset_bottom = 140.0
\ttitle_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tadd_child(title_container)

\ttitle_label = Label.new()"""

new_title_box = """\ttitle_container = Control.new()
\ttitle_container.name = "TitleContainer"
\ttitle_container.anchor_left = 0.0
\ttitle_container.anchor_right = 0.0
\ttitle_container.offset_left = 52.0
\ttitle_container.offset_right = 320.0
\ttitle_container.offset_top = 34.0
\ttitle_container.offset_bottom = 140.0
\ttitle_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tadd_child(title_container)

\tvar baybayin_header = Label.new()
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

\ttitle_label = Label.new()"""

assert old_title_box in content, "old_title_box not found"
content = content.replace(old_title_box, new_title_box, 1)

# 5. In step3_title_box, add decorative Baybayin banner above HALIYA
old_step3_title = """\tvar t_label = Label.new()
\tt_label.name = "Step3TitleLabel"
\tt_label.text = "HALIYA\""""

new_step3_title = """\tvar s3_baybayin = Label.new()
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

\tvar t_label = Label.new()
\tt_label.name = "Step3TitleLabel"
\tt_label.text = "HALIYA\""""

assert old_step3_title in content, "old_step3_title not found"
content = content.replace(old_step3_title, new_step3_title, 1)

# 6. In menu_vbox, add CODEX and SETTINGS buttons
old_menu_btns = """\tvar btn_stages = create_menu_button("STAGE SELECT")
\tbtn_stages.pressed.connect(_on_stage_select_pressed)
\tmenu_vbox.add_child(btn_stages)

\tvar btn_controls = create_menu_button("HOW TO PLAY")
\tbtn_controls.pressed.connect(_on_controls_pressed)
\tmenu_vbox.add_child(btn_controls)"""

new_menu_btns = """\tvar btn_stages = create_menu_button("STAGE SELECT")
\tbtn_stages.pressed.connect(_on_stage_select_pressed)
\tmenu_vbox.add_child(btn_stages)

\tvar btn_codex = create_menu_button("LORE CODEX & ALTAR")
\tbtn_codex.pressed.connect(_on_codex_pressed)
\tmenu_vbox.add_child(btn_codex)

\tvar btn_settings = create_menu_button("SETTINGS")
\tbtn_settings.pressed.connect(_on_settings_pressed)
\tmenu_vbox.add_child(btn_settings)

\tvar btn_controls = create_menu_button("HOW TO PLAY")
\tbtn_controls.pressed.connect(_on_controls_pressed)
\tmenu_vbox.add_child(btn_controls)"""

assert old_menu_btns in content, "old_menu_btns not found"
content = content.replace(old_menu_btns, new_menu_btns, 1)

# Adjust menu_vbox sizing and separation for 6-7 buttons
content = content.replace('menu_vbox.offset_top = 148.0', 'menu_vbox.offset_top = 136.0')
content = content.replace('menu_vbox.offset_bottom = 316.0', 'menu_vbox.offset_bottom = 332.0')
content = content.replace('menu_vbox.add_theme_constant_override("separation", 7)', 'menu_vbox.add_theme_constant_override("separation", 4)')
content = content.replace('btn.custom_minimum_size = Vector2(196, 28)', 'btn.custom_minimum_size = Vector2(196, 24)')
content = content.replace('btn.add_theme_font_size_override("font_size", 15)', 'btn.add_theme_font_size_override("font_size", 13)')

# 7. Add setup_settings_and_codex_modals and handlers
methods_to_add = """
func setup_settings_and_codex_modals() -> void:
\tsettings_menu = SettingsMenuScript.new()
\tsettings_menu.name = "SettingsMenu"
\tadd_child(settings_menu)
\tsettings_menu.closed.connect(func(): _set_totem_modal_mode(false))

\tbestiary_codex_ui = BestiaryCodexUIScript.new()
\tbestiary_codex_ui.name = "BestiaryCodexUI"
\tadd_child(bestiary_codex_ui)
\tbestiary_codex_ui.closed.connect(func(): _set_totem_modal_mode(false))


func _on_settings_pressed() -> void:
\tif is_transitioning:
\t\treturn
\tif is_instance_valid(settings_menu):
\t\t_set_totem_modal_mode(true)
\t\tsettings_menu.open_menu()


func _on_codex_pressed() -> void:
\tif is_transitioning:
\t\treturn
\tif is_instance_valid(bestiary_codex_ui):
\t\t_set_totem_modal_mode(true)
\t\tbestiary_codex_ui.open_menu()
"""

# In _close_modals:
old_close = """func _close_modals() -> void:
\tif is_instance_valid(stage_select_modal):
\t\tstage_select_modal.visible = false
\tif is_instance_valid(controls_modal):
\t\tcontrols_modal.visible = false
\t_set_totem_modal_mode(false)"""

new_close = """func _close_modals() -> void:
\tif is_instance_valid(stage_select_modal):
\t\tstage_select_modal.visible = false
\tif is_instance_valid(controls_modal):
\t\tcontrols_modal.visible = false
\tif is_instance_valid(settings_menu) and settings_menu.visible:
\t\tsettings_menu.close_menu()
\tif is_instance_valid(bestiary_codex_ui) and bestiary_codex_ui.visible:
\t\tbestiary_codex_ui.close_menu()
\t_set_totem_modal_mode(false)"""

assert old_close in content, "old_close not found"
content = content.replace(old_close, new_close, 1)

# Connect menu BGM to Kulintang
content = content.replace(
    "bgm_player.stream = ProceduralAudio.get_menu_ambient()",
    "bgm_player.stream = ProceduralAudio.get_kulintang_exploration_bgm()"
)

# Append new methods before the end
content += methods_to_add

with open("scripts/main_menu.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("scripts/main_menu.gd successfully updated!")

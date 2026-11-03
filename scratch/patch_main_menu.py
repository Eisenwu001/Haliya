with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    text = f.read().replace('\r\n', '\n')

# 1. Preloads & vars
old_preloads = """const SettingsMenuScript = preload("res://scripts/settings_menu.gd")
const BestiaryCodexUIScript = preload("res://scripts/bestiary_codex_ui.gd")"""

new_preloads = """const SettingsMenuScript = preload("res://scripts/settings_menu.gd")
const BestiaryCodexUIScript = preload("res://scripts/bestiary_codex_ui.gd")
const ComicStoryViewerScript = preload("res://scripts/comic_story_viewer.gd")"""

assert old_preloads in text, "old_preloads not found"
text = text.replace(old_preloads, new_preloads)

old_vars = """var step3_container: Control
var step3_title_box: VBoxContainer
var step3_press_start_label: Label"""

new_vars = """var step3_container: Control
var step3_title_box: VBoxContainer
var step3_press_start_label: Label
var loading_container: Control
var loading_fill_bar: ColorRect
var loading_pct_label: Label
var loading_status_label: Label
var is_loading_assets: bool = false
var loading_tween: Tween = null
var comic_story_viewer: CanvasLayer"""

assert old_vars in text, "old_vars not found"
text = text.replace(old_vars, new_vars)

# 2. _ready additions
old_ready = """\tsetup_step3_ui()
\tsetup_stage_select_modal()"""

new_ready = """\tsetup_step3_ui()
\tsetup_loading_ui()
\tsetup_comic_story_viewer()
\tsetup_stage_select_modal()"""

assert old_ready in text, "old_ready not found"
text = text.replace(old_ready, new_ready)

# 3. setup_ui prologue button
old_buttons = """\tvar btn_play = create_menu_button("BEGIN JOURNEY")
\tbtn_play.pressed.connect(_on_begin_journey_pressed)
\tmenu_vbox.add_child(btn_play)

\tvar btn_stages = create_menu_button("STAGE SELECT")"""

new_buttons = """\tvar btn_play = create_menu_button("BEGIN JOURNEY")
\tbtn_play.pressed.connect(_on_begin_journey_pressed)
\tmenu_vbox.add_child(btn_play)

\tvar btn_prologue = create_menu_button("PROLOGUE CHRONICLES")
\tbtn_prologue.pressed.connect(_on_prologue_pressed)
\tmenu_vbox.add_child(btn_prologue)

\tvar btn_stages = create_menu_button("STAGE SELECT")"""

assert old_buttons in text, "old_buttons not found"
text = text.replace(old_buttons, new_buttons)

# 4. _advance_splash_stage to loading sequence
old_adv = """\t\telif current_splash_stage == 2:
\t\t\t# Stage 3: Title Screen
\t\t\tcurrent_splash_stage = 3
\t\t\t_complete_splash_to_title()"""

new_adv = """\t\telif current_splash_stage == 2:
\t\t\t# Stage 3: 2-Second Bottom Asset Loading Screen
\t\t\tcurrent_splash_stage = 3
\t\t\t_start_loading_sequence()"""

assert old_adv in text, "old_adv not found"
text = text.replace(old_adv, new_adv)

# 5. Add setup_comic_story_viewer, setup_loading_ui, _start_loading_sequence, _morph_loading_to_press_start, button handlers
new_methods = """
func setup_comic_story_viewer() -> void:
\tcomic_story_viewer = ComicStoryViewerScript.new()
\tcomic_story_viewer.name = "ComicStoryViewer"
\tadd_child(comic_story_viewer)
\tcomic_story_viewer.story_completed.connect(_on_story_completed)


func setup_loading_ui() -> void:
\tloading_container = Control.new()
\tloading_container.name = "LoadingContainer"
\tloading_container.anchor_left = 0.5
\tloading_container.anchor_right = 0.5
\tloading_container.anchor_top = 1.0
\tloading_container.anchor_bottom = 1.0
\tloading_container.offset_left = -170.0
\tloading_container.offset_right = 170.0
\tloading_container.offset_top = -54.0
\tloading_container.offset_bottom = -16.0
\tloading_container.visible = false
\tloading_container.modulate.a = 0.0
\tstep3_container.add_child(loading_container)

\tloading_status_label = Label.new()
\tloading_status_label.name = "LoadingStatusLabel"
\tloading_status_label.text = "AWAKENING THE SEVEN MOONS..."
\tloading_status_label.position = Vector2(0, 0)
\tloading_status_label.size = Vector2(340, 16)
\tloading_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tloading_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tloading_status_label.add_theme_font_override("font", FONT_ALAGARD)
\tloading_status_label.add_theme_font_size_override("font_size", 10)
\tloading_status_label.add_theme_color_override("font_color", Color(0.92, 0.85, 0.72, 0.90))
\tloading_status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
\tloading_status_label.add_theme_constant_override("shadow_offset_x", 1)
\tloading_status_label.add_theme_constant_override("shadow_offset_y", 1)
\tloading_container.add_child(loading_status_label)

\tvar bar_frame := ColorRect.new()
\tbar_frame.name = "BarFrame"
\tbar_frame.position = Vector2(0, 18)
\tbar_frame.size = Vector2(340, 14)
\tbar_frame.color = Color(0.04, 0.03, 0.06, 0.95)
\tloading_container.add_child(bar_frame)

\tvar border := ReferenceRect.new()
\tborder.name = "GildedBorder"
\tborder.position = Vector2(0, 18)
\tborder.size = Vector2(340, 14)
\tborder.border_color = Color(0.72, 0.60, 0.35, 1.0)
\tborder.border_width = 1.0
\tborder.editor_only = false
\tloading_container.add_child(border)

\tfor side in [-1.0, 1.0]:
\t\tvar dia := Polygon2D.new()
\t\tdia.polygon = PackedVector2Array([Vector2(-3, 0), Vector2(0, -3), Vector2(3, 0), Vector2(0, 3)])
\t\tdia.color = Color(0.95, 0.80, 0.40, 1.0)
\t\tdia.position = Vector2(0 if side < 0 else 340, 25)
\t\tloading_container.add_child(dia)

\tvar channel := ColorRect.new()
\tchannel.name = "Channel"
\tchannel.position = Vector2(2, 20)
\tchannel.size = Vector2(336, 10)
\tchannel.color = Color(0.08, 0.05, 0.10, 0.85)
\tloading_container.add_child(channel)

\tloading_fill_bar = ColorRect.new()
\tloading_fill_bar.name = "LoadingFillBar"
\tloading_fill_bar.position = Vector2(2, 20)
\tloading_fill_bar.size = Vector2(0, 10)
\tloading_fill_bar.color = Color(0.35, 0.82, 1.0, 1.0)
\tloading_container.add_child(loading_fill_bar)

\tloading_pct_label = Label.new()
\tloading_pct_label.name = "LoadingPctLabel"
\tloading_pct_label.text = "0%"
\tloading_pct_label.position = Vector2(0, 18)
\tloading_pct_label.size = Vector2(340, 14)
\tloading_pct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tloading_pct_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tloading_pct_label.add_theme_font_override("font", FONT_ALAGARD)
\tloading_pct_label.add_theme_font_size_override("font_size", 9)
\tloading_pct_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
\tloading_pct_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
\tloading_pct_label.add_theme_constant_override("shadow_offset_x", 1)
\tloading_pct_label.add_theme_constant_override("shadow_offset_y", 1)
\tloading_container.add_child(loading_pct_label)


func _start_loading_sequence() -> void:
\tis_in_splash = false
\thas_shown_splash = true
\tis_loading_assets = true
\tis_in_press_start = false

\tif is_instance_valid(splash_layer):
\t\tsplash_layer.visible = false

\tif is_instance_valid(step3_container):
\t\tstep3_container.visible = true
\t\tstep3_container.modulate = Color(1, 1, 1, 1)
\t\tstep3_container.scale = Vector2.ONE

\tif is_instance_valid(step3_press_start_label):
\t\tstep3_press_start_label.visible = false
\t\tstep3_press_start_label.modulate.a = 0.0

\tif is_instance_valid(loading_container):
\t\tloading_container.visible = true
\t\tloading_container.modulate.a = 0.0
\t\tif is_instance_valid(loading_fill_bar):
\t\t\tloading_fill_bar.size.x = 0.0
\t\tif is_instance_valid(loading_pct_label):
\t\t\tloading_pct_label.text = "0%"

\tif is_instance_valid(title_container):
\t\ttitle_container.visible = false
\t\ttitle_container.modulate.a = 0.0
\tif is_instance_valid(menu_vbox):
\t\tmenu_vbox.visible = false
\t\tmenu_vbox.modulate.a = 0.0
\tif is_instance_valid(ver_label):
\t\tver_label.visible = false
\t\tver_label.modulate.a = 0.0
\tif is_instance_valid(altar_spr):
\t\taltar_spr.visible = false
\t\taltar_spr.modulate.a = 0.0
\tvar motes = get_node_or_null("AltarMotes")
\tif is_instance_valid(motes):
\t\tmotes.emitting = false
\t\tmotes.visible = false

\tvar tw_in = create_tween()
\ttw_in.tween_property(fade_rect, "color:a", 0.0, 0.60).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\ttw_in.parallel().tween_property(loading_container, "modulate:a", 1.0, 0.40)

\tif is_instance_valid(bgm_player):
\t\tvar bgm_tw = create_tween()
\t\tbgm_tw.tween_property(bgm_player, "volume_db", -8.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif loading_tween and loading_tween.is_valid():
\t\tloading_tween.kill()
\tloading_tween = create_tween()
\tloading_tween.tween_method(func(val: float):
\t\tif is_instance_valid(loading_fill_bar):
\t\t\tloading_fill_bar.size.x = 336.0 * val
\t\tif is_instance_valid(loading_pct_label):
\t\t\tloading_pct_label.text = "%d%%" % int(val * 100.0)
\t\tif is_instance_valid(loading_status_label):
\t\t\tif val < 0.28:
\t\t\t\tloading_status_label.text = "AWAKENING THE SEVEN MOONS..."
\t\t\telif val < 0.60:
\t\t\t\tloading_status_label.text = "LOADING ANCIENT ASSETS..."
\t\t\telif val < 0.88:
\t\t\t\tloading_status_label.text = "TUNING KULINTANG HARMONICS..."
\t\t\telse:
\t\t\t\tloading_status_label.text = "PREPARING ECLIPSE CHRONICLES..."
\t, 0.0, 1.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tloading_tween.tween_interval(0.18)
\tloading_tween.tween_callback(func():
\t\t_morph_loading_to_press_start()
\t)


func _morph_loading_to_press_start() -> void:
\tis_loading_assets = false

\tvar tw = create_tween()
\tif is_instance_valid(loading_container):
\t\ttw.tween_property(loading_container, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
\t\ttw.tween_callback(func():
\t\t\tif is_instance_valid(loading_container):
\t\t\t\tloading_container.visible = false
\t\t)

\ttw.tween_callback(func():
\t\tif is_instance_valid(step3_press_start_label):
\t\t\tstep3_press_start_label.visible = true
\t\t\tstep3_press_start_label.modulate.a = 0.0
\t\t\tvar tw_show = create_tween()
\t\ttw_show.tween_property(step3_press_start_label, "modulate:a", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_show.tween_callback(func():
\t\t\tis_in_press_start = true
\t\t\t_start_press_start_breathing()
\t\t)
\t)
"""

# Place new methods before _complete_splash_to_title
assert "func _complete_splash_to_title() -> void:" in text, "_complete_splash_to_title not found"
text = text.replace("func _complete_splash_to_title() -> void:", new_methods + "\n\nfunc _complete_splash_to_title() -> void:")

# 6. Update _on_begin_journey_pressed and add _on_prologue_pressed & _on_story_completed
old_begin = """func _on_begin_journey_pressed() -> void:
\t_start_game_at_level(0)"""

new_begin = """func _on_begin_journey_pressed() -> void:
\tif is_transitioning:
\t\treturn
\tif is_instance_valid(comic_story_viewer):
\t\tcomic_story_viewer.open_story(true)
\telse:
\t\t_start_game_at_level(0)


func _on_prologue_pressed() -> void:
\tif is_transitioning:
\t\treturn
\tif is_instance_valid(comic_story_viewer):
\t\tmenu_vbox.visible = false
\t\tcomic_story_viewer.open_story(false)


func _on_story_completed() -> void:
\tif is_instance_valid(comic_story_viewer) and comic_story_viewer.is_prologue_mode:
\t\t_start_game_at_level(0)
\telse:
\t\tif is_instance_valid(menu_vbox):
\t\t\tmenu_vbox.visible = true
\t\t\tmenu_vbox.modulate.a = 1.0"""

assert old_begin in text, "old_begin not found"
text = text.replace(old_begin, new_begin)

with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Successfully patched scripts/main_menu.gd with loading screen and comic viewer")

import os

with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    code = f.read()

is_crlf = '\r\n' in code
code_lf = code.replace('\r\n', '\n')

# 1. Update variables
old_vars = """var fade_rect: ColorRect

static var has_shown_splash: bool = false
var splash_layer: Control
var splash_content: Control
var press_start_container: Control
var press_start_label: Label
var is_in_splash: bool = false
var is_in_press_start: bool = false
var splash_tween: Tween = null
var press_start_tween: Tween = null

var is_transitioning: bool = false"""

new_vars = """var fade_rect: ColorRect

static var has_shown_splash: bool = false
var splash_layer: Control
var group2_page: Control
var logs_page: Control
var current_splash_stage: int = 0
var press_start_container: Control
var press_start_label: Label
var is_in_splash: bool = false
var is_in_press_start: bool = false
var splash_tween: Tween = null
var press_start_tween: Tween = null

var is_transitioning: bool = false"""

assert old_vars in code_lf, "old_vars not found"
code_lf = code_lf.replace(old_vars, new_vars, 1)

# 2. Remove mouse sway in _process
old_sway = """\t# 2. Subtle mouse-driven interactive parallax for living depth
\tvar vp_size: Vector2 = get_viewport_rect().size
\tif vp_size.x > 0 and vp_size.y > 0:
\t\tvar m_pos: Vector2 = get_viewport().get_mouse_position()
\t\tvar norm_x: float = clampf((m_pos.x - vp_size.x * 0.5) / (vp_size.x * 0.5), -1.0, 1.0)
\t\tvar norm_y: float = clampf((m_pos.y - vp_size.y * 0.5) / (vp_size.y * 0.5), -1.0, 1.0)
\t\tmouse_parallax_offset = mouse_parallax_offset.lerp(Vector2(norm_x, norm_y), delta * 2.5)

\t\tif is_instance_valid(stars_container):
\t\t\tstars_container.position = mouse_parallax_offset * Vector2(-3.0, -1.5)

\t\tif is_instance_valid(moon_container):
\t\t\tmoon_container.position = base_moon_pos + mouse_parallax_offset * Vector2(-10.0, -5.0)

\t\t# Grounded totem only has slight horizontal parallax, zero vertical parallax to never float
\t\tif is_instance_valid(altar_spr):
\t\t\taltar_spr.position = base_altar_pos + mouse_parallax_offset * Vector2(-2.0, 0.0)"""

new_sway = """\t# 2. Mouse parallax removed to keep the view rock-steady with zero sway as requested
\tpass"""

assert old_sway in code_lf, "old_sway not found"
code_lf = code_lf.replace(old_sway, new_sway, 1)

# 3. Replace methods from func setup_press_start_ui() to end of file
setup_marker = "func setup_press_start_ui() -> void:"
assert setup_marker in code_lf, "setup_marker not found"

prefix = code_lf[:code_lf.index(setup_marker)]

new_tail = """func setup_press_start_ui() -> void:
\tpress_start_container = Control.new()
\tpress_start_container.name = "PressStartContainer"
\tpress_start_container.anchor_left = 0.5
\tpress_start_container.anchor_right = 0.5
\tpress_start_container.anchor_top = 0.5
\tpress_start_container.anchor_bottom = 0.5
\t# Perfectly centered in the middle horizontally, positioned in the lower-middle zone
\tpress_start_container.offset_left = -190.0
\tpress_start_container.offset_right = 190.0
\tpress_start_container.offset_top = 65.0
\tpress_start_container.offset_bottom = 105.0
\tpress_start_container.pivot_offset = Vector2(190.0, 20.0)
\tpress_start_container.mouse_filter = Control.MOUSE_FILTER_PASS
\tadd_child(press_start_container)

\t# Elegant dark translucent backing pill for high contrast and readability
\tvar pill_bg = ColorRect.new()
\tpill_bg.name = "StartPillBG"
\tpill_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
\tpill_bg.color = Color(0.012, 0.018, 0.03, 0.52)
\tpill_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tpress_start_container.add_child(pill_bg)

\t# Sleek golden accent borders top & bottom
\tvar line_top = ColorRect.new()
\tline_top.name = "LineTop"
\tline_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
\tline_top.offset_bottom = 1.0
\tline_top.color = Color(0.85, 0.72, 0.42, 0.55)
\tline_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tpress_start_container.add_child(line_top)

\tvar line_bot = ColorRect.new()
\tline_bot.name = "LineBottom"
\tline_bot.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
\tline_bot.offset_top = -1.0
\tline_bot.color = Color(0.85, 0.72, 0.42, 0.55)
\tline_bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tpress_start_container.add_child(line_bot)

\tpress_start_label = Label.new()
\tpress_start_label.name = "PressStartLabel"
\tpress_start_label.set_anchors_preset(Control.PRESET_FULL_RECT)
\tpress_start_label.text = "◆   PRESS ANY KEY TO START   ◆"
\tpress_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tpress_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tpress_start_label.add_theme_font_override("font", FONT_ALAGARD)
\tpress_start_label.add_theme_font_size_override("font_size", 14)
\tpress_start_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 1.0))
\tpress_start_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tpress_start_label.add_theme_constant_override("shadow_offset_x", 2)
\tpress_start_label.add_theme_constant_override("shadow_offset_y", 2)
\tpress_start_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tpress_start_container.add_child(press_start_label)


func setup_splash_layer() -> void:
\tsplash_layer = Control.new()
\tsplash_layer.name = "SplashLayer"
\tsplash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
\tsplash_layer.z_index = 90
\tsplash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
\tadd_child(splash_layer)

\tvar splash_bg = ColorRect.new()
\tsplash_bg.name = "SplashBG"
\tsplash_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
\tsplash_bg.color = Color(0.010, 0.013, 0.018, 1.0)
\tsplash_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_layer.add_child(splash_bg)

\t# ── Stage 1: Group 2 Page ────────────────────────────────────────────────
\tgroup2_page = Control.new()
\tgroup2_page.name = "Group2Page"
\tgroup2_page.set_anchors_preset(Control.PRESET_FULL_RECT)
\tgroup2_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_layer.add_child(group2_page)

\tvar g2_box = VBoxContainer.new()
\tg2_box.name = "Group2Box"
\tg2_box.anchor_left = 0.5
\tg2_box.anchor_right = 0.5
\tg2_box.anchor_top = 0.5
\tg2_box.anchor_bottom = 0.5
\tg2_box.offset_left = -220.0
\tg2_box.offset_right = 220.0
\tg2_box.offset_top = -50.0
\tg2_box.offset_bottom = 50.0
\tg2_box.alignment = BoxContainer.ALIGNMENT_CENTER
\tg2_box.add_theme_constant_override("separation", 6)
\tg2_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tgroup2_page.add_child(g2_box)

\tvar g2_title = Label.new()
\tg2_title.name = "Group2Title"
\tg2_title.text = "G R O U P   2"
\tg2_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tg2_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tg2_title.add_theme_font_override("font", FONT_ALAGARD)
\tg2_title.add_theme_font_size_override("font_size", 30)
\tg2_title.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 1.0))
\tg2_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tg2_title.add_theme_constant_override("shadow_offset_x", 2)
\tg2_title.add_theme_constant_override("shadow_offset_y", 2)
\tg2_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tg2_box.add_child(g2_title)

\tvar g2_divider = Label.new()
\tg2_divider.name = "Group2Divider"
\tg2_divider.text = "————————"
\tg2_divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tg2_divider.add_theme_font_override("font", FONT_ALAGARD)
\tg2_divider.add_theme_font_size_override("font_size", 11)
\tg2_divider.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42, 0.75))
\tg2_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tg2_box.add_child(g2_divider)

\tvar g2_sub = Label.new()
\tg2_sub.name = "Group2Sub"
\tg2_sub.text = "P R E S E N T S"
\tg2_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tg2_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tg2_sub.add_theme_font_override("font", FONT_ALAGARD)
\tg2_sub.add_theme_font_size_override("font_size", 13)
\tg2_sub.add_theme_color_override("font_color", Color(0.82, 0.76, 0.65, 0.90))
\tg2_sub.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tg2_sub.add_theme_constant_override("shadow_offset_x", 1)
\tg2_sub.add_theme_constant_override("shadow_offset_y", 1)
\tg2_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tg2_box.add_child(g2_sub)

\t# ── Stage 2: Log's Production Page ───────────────────────────────────────
\tlogs_page = Control.new()
\tlogs_page.name = "LogsPage"
\tlogs_page.set_anchors_preset(Control.PRESET_FULL_RECT)
\tlogs_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tlogs_page.visible = false
\tsplash_layer.add_child(logs_page)

\tvar logo_rect = TextureRect.new()
\tlogo_rect.name = "LogoRect"
\tlogo_rect.anchor_left = 0.5
\tlogo_rect.anchor_right = 0.5
\tlogo_rect.anchor_top = 0.5
\tlogo_rect.anchor_bottom = 0.5
\tlogo_rect.offset_left = -180.0
\tlogo_rect.offset_right = 180.0
\tlogo_rect.offset_top = -80.0
\tlogo_rect.offset_bottom = 80.0
\tlogo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\tlogo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\tlogo_rect.texture = _load_logs_production_texture()
\tlogo_rect.modulate = Color(0.98, 0.96, 0.92, 1.0)
\tlogo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tlogs_page.add_child(logo_rect)


func _load_logs_production_texture() -> Texture2D:
\tif ResourceLoader.exists(AssetsScript.PATH_LOGS_PRODUCTION_DARK):
\t\tvar res = load(AssetsScript.PATH_LOGS_PRODUCTION_DARK)
\t\tif res is Texture2D:
\t\t\treturn res
\tvar global_path: String = ProjectSettings.globalize_path(AssetsScript.PATH_LOGS_PRODUCTION_DARK)
\tif FileAccess.file_exists(global_path):
\t\tvar img = Image.new()
\t\tif img.load(global_path) == OK:
\t\t\treturn ImageTexture.create_from_image(img)
\treturn null


func _start_splash_sequence() -> void:
\tcurrent_splash_stage = 1
\tgroup2_page.visible = true
\tgroup2_page.modulate.a = 1.0
\tlogs_page.visible = false
\tlogs_page.modulate.a = 0.0

\tif is_instance_valid(sfx_ui_player):
\t\tsfx_ui_player.stream = ProceduralAudio.get_splash_chime()
\t\tsfx_ui_player.volume_db = -4.0
\t\tsfx_ui_player.play()

\tif splash_tween and splash_tween.is_valid():
\t\tsplash_tween.kill()

\tsplash_tween = create_tween()
\t# Fade in from black to Group 2 (smooth 0.65s)
\tsplash_tween.tween_property(fade_rect, "color:a", 0.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t# Hold for 1.4s steady without sway
\tsplash_tween.tween_interval(1.4)
\t# Smooth fade to black
\tsplash_tween.tween_callback(func(): _advance_splash_stage(false))


func _advance_splash_stage(is_skip: bool = false) -> void:
\tif splash_tween and splash_tween.is_valid():
\t\tsplash_tween.kill()

\tvar fade_out_time: float = 0.28 if is_skip else 0.55

\tvar tw = create_tween()
\ttw.tween_property(fade_rect, "color:a", 1.0, fade_out_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
\ttw.tween_callback(func():
\t\tif current_splash_stage == 1:
\t\t\t# Stage 2: Log's Production
\t\t\tcurrent_splash_stage = 2
\t\t\tgroup2_page.visible = false
\t\t\tlogs_page.visible = true
\t\t\tlogs_page.modulate.a = 1.0

\t\t\tsplash_tween = create_tween()
\t\t\tsplash_tween.tween_property(fade_rect, "color:a", 0.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\t\tsplash_tween.tween_interval(1.5)
\t\t\tsplash_tween.tween_callback(func(): _advance_splash_stage(false))

\t\telif current_splash_stage == 2:
\t\t\t# Stage 3: Title Screen
\t\t\tcurrent_splash_stage = 3
\t\t\t_complete_splash_to_title()
\t)


func _skip_splash() -> void:
\tif not is_in_splash:
\t\treturn
\tif current_splash_stage == 1:
\t\t_advance_splash_stage(true)
\telif current_splash_stage == 2:
\t\t_advance_splash_stage(true)


func _complete_splash_to_title() -> void:
\tis_in_splash = false
\thas_shown_splash = true
\tif is_instance_valid(splash_layer):
\t\tsplash_layer.visible = false

\tis_in_press_start = true
\tif is_instance_valid(press_start_container):
\t\tpress_start_container.visible = true
\t\tpress_start_container.modulate = Color(1, 1, 1, 1)
\t\tpress_start_container.scale = Vector2.ONE
\t\t_start_press_start_breathing()
\tif is_instance_valid(menu_vbox):
\t\tmenu_vbox.visible = false
\t\tmenu_vbox.modulate.a = 0.0

\tvar tw_in = create_tween()
\ttw_in.tween_property(fade_rect, "color:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif is_instance_valid(bgm_player):
\t\tvar bgm_tw = create_tween()
\t\tbgm_tw.tween_property(bgm_player, "volume_db", -8.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _start_press_start_breathing() -> void:
\tif press_start_tween and press_start_tween.is_valid():
\t\tpress_start_tween.kill()
\tif not is_instance_valid(press_start_container):
\t\treturn
\tpress_start_container.modulate.a = 1.0
\tpress_start_tween = create_tween().set_loops()
\tpress_start_tween.tween_property(press_start_container, "modulate:a", 0.45, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\tpress_start_tween.tween_property(press_start_container, "modulate:a", 1.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_press_start_triggered() -> void:
\tif not is_in_press_start or is_transitioning:
\t\treturn
\tis_in_press_start = false

\tif is_instance_valid(sfx_ui_player):
\t\tsfx_ui_player.stream = ProceduralAudio.get_title_start_chime()
\t\tsfx_ui_player.volume_db = -3.0
\t\tsfx_ui_player.play()

\tif press_start_tween and press_start_tween.is_valid():
\t\tpress_start_tween.kill()

\t# Smooth, stylish dissolution of the start prompt in the middle
\tif is_instance_valid(press_start_container):
\t\tvar dissolve_tw = create_tween().set_parallel(true)
\t\tdissolve_tw.tween_property(press_start_container, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\tdissolve_tw.tween_property(press_start_container, "scale", Vector2(1.05, 1.05), 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\tdissolve_tw.chain().tween_callback(func():
\t\t\tif is_instance_valid(press_start_container):
\t\t\t\tpress_start_container.visible = false
\t\t)

\t# Silky smooth reveal of main menu buttons
\tif is_instance_valid(menu_vbox):
\t\tmenu_vbox.visible = true
\t\tmenu_vbox.modulate.a = 0.0
\t\tmenu_vbox.offset_left = 32.0
\t\tmenu_vbox.offset_right = 242.0
\t\tvar tw = create_tween().set_parallel(true)
\t\ttw.tween_property(menu_vbox, "modulate:a", 1.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw.tween_property(menu_vbox, "offset_left", 52.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw.tween_property(menu_vbox, "offset_right", 262.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _input(event: InputEvent) -> void:
\tif is_in_splash:
\t\tif (event is InputEventKey and event.pressed and not event.echo) or \\
\t\t   (event is InputEventMouseButton and event.pressed):
\t\t\t_skip_splash()
\t\t\tget_viewport().set_input_as_handled()
\t\t\treturn

\tif is_in_press_start:
\t\tif (event is InputEventKey and event.pressed and not event.echo) or \\
\t\t   (event is InputEventMouseButton and event.pressed):
\t\t\t_on_press_start_triggered()
\t\t\tget_viewport().set_input_as_handled()
\t\t\treturn
"""

new_code_lf = prefix + new_tail
final_code = new_code_lf.replace('\n', '\r\n') if is_crlf else new_code_lf

with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(final_code)

print("Applied 3-stage opening cleanly to scripts/main_menu.gd!")

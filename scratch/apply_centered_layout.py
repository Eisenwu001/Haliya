import os

with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    code = f.read()

is_crlf = '\r\n' in code
code_lf = code.replace('\r\n', '\n')

# 1. Remove altar_spr from _update_background_bounds
old_bounds = """\t# Keep moon and totem anchored to right side
\tbase_moon_pos = Vector2(target_w * 0.78, 58.0)
\tif is_instance_valid(moon_container):
\t\tmoon_container.position = base_moon_pos

\tif is_instance_valid(altar_spr) and altar_spr.texture:
\t\tvar totem_target_h: float = 252.0 * (target_h / 360.0)
\t\tvar totem_scale_val: float = totem_target_h / altar_spr.texture.get_height()
\t\taltar_spr.scale = Vector2(totem_scale_val, totem_scale_val)
\t\tbase_altar_pos = Vector2(target_w * 0.83, target_h + 12.0 - (totem_target_h * 0.5))
\t\taltar_spr.position = base_altar_pos

\tvar motes_node = get_node_or_null("AltarMotes")
\tif is_instance_valid(motes_node):
\t\tmotes_node.position = Vector2(target_w * 0.83, target_h - 130.0 * (target_h / 360.0))"""

new_bounds = """\t# Keep moon anchored to upper right sky
\tbase_moon_pos = Vector2(target_w * 0.78, 58.0)
\tif is_instance_valid(moon_container):
\t\tmoon_container.position = base_moon_pos"""

assert old_bounds in code_lf, "old_bounds not found"
code_lf = code_lf.replace(old_bounds, new_bounds, 1)

# 2. Remove totem setup from setup_background()
old_totem_bg = """\t# 4. Sacred Haliya Totem firmly grounded on the right ridge
\tvar totem_tex = load(AssetsScript.PATH_TOTEM_HALIYA)
\tif totem_tex:
\t\tvar totem_target_h: float = 252.0 * (target_h / 360.0)
\t\tvar totem_scale_val: float = totem_target_h / totem_tex.get_height()
\t\tbase_altar_pos = Vector2(target_w * 0.83, target_h + 12.0 - (totem_target_h * 0.5))
\t\taltar_spr = Sprite2D.new()
\t\taltar_spr.name = "TotemHaliya"
\t\taltar_spr.texture = totem_tex
\t\taltar_spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
\t\taltar_spr.scale = Vector2(totem_scale_val, totem_scale_val)
\t\taltar_spr.position = base_altar_pos
\t\taltar_spr.z_index = 0
\t\tbg_root.add_child(altar_spr)

\t\t# Soft celestial lunar aura around the mask of sorrow on the totem
\t\tvar altar_glow = Sprite2D.new()
\t\taltar_glow.name = "AltarGlow"
\t\taltar_glow.texture = create_radial_glow_texture(110, Color(0.96, 0.94, 0.82, 0.32), Color(0.88, 0.85, 0.72, 0.0))
\t\t# The golden mask face is at local Y = -337.5 relative to the center of the totem
\t\taltar_glow.position = Vector2(0, -337.5)
\t\taltar_spr.add_child(altar_glow)

\t\tvar tw_altar = create_tween().set_loops()
\t\ttw_altar.tween_property(altar_glow, "modulate:a", 0.45, 2.5).set_trans(Tween.TRANS_SINE)
\t\ttw_altar.tween_property(altar_glow, "modulate:a", 0.18, 2.5).set_trans(Tween.TRANS_SINE)

\t\t# Overgrown forest grass tufts rooting the stone foundation into the earth
\t\tvar grass_tex = load("res://assets/platform_assets/Tall Grass.png")
\t\tif grass_tex:
\t\t\tvar grass_l = Sprite2D.new()
\t\t\tgrass_l.name = "GrassLeft"
\t\t\tgrass_l.texture = grass_tex
\t\t\tgrass_l.scale = Vector2(2.6, 2.2)
\t\t\tgrass_l.position = Vector2(-105.0, 440.0)
\t\t\tgrass_l.modulate = Color(0.24, 0.32, 0.30, 0.95)
\t\t\taltar_spr.add_child(grass_l)

\t\t\tvar grass_r = Sprite2D.new()
\t\t\tgrass_r.name = "GrassRight"
\t\t\tgrass_r.texture = grass_tex
\t\t\tgrass_r.flip_h = true
\t\t\tgrass_r.scale = Vector2(2.4, 2.0)
\t\t\tgrass_r.position = Vector2(100.0, 442.0)
\t\t\tgrass_r.modulate = Color(0.22, 0.30, 0.28, 0.95)
\t\t\taltar_spr.add_child(grass_r)"""

new_totem_bg = """\t# 4. Totem removed for clean open landscape as requested"""

assert old_totem_bg in code_lf, "old_totem_bg not found"
code_lf = code_lf.replace(old_totem_bg, new_totem_bg, 1)

# 3. Remove altar_motes from setup_ambient_particles()
old_motes = """\t# Localized spirit motes rising around the totem
\tvar altar_motes = CPUParticles2D.new()
\taltar_motes.name = "AltarMotes"
\taltar_motes.position = Vector2(target_w * 0.83, target_h - 130.0)
\taltar_motes.amount = 16
\taltar_motes.lifetime = 4.5
\taltar_motes.preprocess = 2.0
\taltar_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
\taltar_motes.emission_rect_extents = Vector2(28.0, 95.0)
\taltar_motes.direction = Vector2(0, -1.0)
\taltar_motes.spread = 25.0
\taltar_motes.gravity = Vector2(-2, -6)
\taltar_motes.initial_velocity_min = 6.0
\taltar_motes.initial_velocity_max = 18.0
\taltar_motes.scale_amount_min = 1.2
\taltar_motes.scale_amount_max = 2.5
\taltar_motes.color = Color(0.96, 0.94, 0.84, 0.60)
\tadd_child(altar_motes)"""

new_motes = """\t# Altar motes removed with totem"""

assert old_motes in code_lf, "old_motes not found"
code_lf = code_lf.replace(old_motes, new_motes, 1)

# 4. Update setup_ui() for centered title and menu_vbox, removing divider
old_setup_ui = """func setup_ui() -> void:
\t# ── Title Container (Cinematic Left Anchor) ──────────────────────────────
\ttitle_container = Control.new()
\ttitle_container.name = "TitleContainer"
\ttitle_container.anchor_left = 0.0
\ttitle_container.anchor_right = 0.0
\ttitle_container.offset_left = 52.0
\ttitle_container.offset_right = 320.0
\ttitle_container.offset_top = 40.0
\ttitle_container.offset_bottom = 140.0
\ttitle_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tadd_child(title_container)

\ttitle_label = Label.new()
\ttitle_label.name = "TitleLabel"
\ttitle_label.position = Vector2(0, 0)
\ttitle_label.size = Vector2(260, 52)
\ttitle_label.text = "HALIYA"
\ttitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
\ttitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\ttitle_label.add_theme_font_override("font", FONT_ALAGARD)
\ttitle_label.add_theme_font_size_override("font_size", 50)
\ttitle_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 1.0))
\ttitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\ttitle_label.add_theme_constant_override("shadow_offset_x", 3)
\ttitle_label.add_theme_constant_override("shadow_offset_y", 3)
\ttitle_container.add_child(title_label)

\tvar divider = Label.new()
\tdivider.name = "TitleDivider"
\tdivider.position = Vector2(2, 52)
\tdivider.size = Vector2(175, 16)
\tdivider.text = "————————————————"
\tdivider.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
\tdivider.add_theme_font_override("font", FONT_ALAGARD)
\tdivider.add_theme_font_size_override("font_size", 11)
\tdivider.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42, 0.75))
\tdivider.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
\tdivider.add_theme_constant_override("shadow_offset_x", 1)
\tdivider.add_theme_constant_override("shadow_offset_y", 1)
\ttitle_container.add_child(divider)

\tsubtitle_label = Label.new()
\tsubtitle_label.name = "SubtitleLabel"
\tsubtitle_label.position = Vector2(2, 68)
\tsubtitle_label.size = Vector2(240, 20)
\tsubtitle_label.text = "Mask of Sorrows"
\tsubtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
\tsubtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tsubtitle_label.add_theme_font_override("font", FONT_ALAGARD)
\tsubtitle_label.add_theme_font_size_override("font_size", 14)
\tsubtitle_label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.65, 0.92))
\tsubtitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tsubtitle_label.add_theme_constant_override("shadow_offset_x", 2)
\tsubtitle_label.add_theme_constant_override("shadow_offset_y", 2)
\ttitle_container.add_child(subtitle_label)

\t# Gentle breathing animation on title
\tvar tw = create_tween().set_loops()
\ttw.tween_property(title_label, "modulate", Color(1.08, 1.05, 0.95, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\ttw.tween_property(title_label, "modulate", Color(0.92, 0.90, 0.85, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

\t# ── Main Menu Buttons (Left-Aligned List) ────────────────────────────────
\tmenu_vbox = VBoxContainer.new()
\tmenu_vbox.name = "MenuVBox"
\tmenu_vbox.anchor_left = 0.0
\tmenu_vbox.anchor_right = 0.0
\tmenu_vbox.offset_left = 52.0
\tmenu_vbox.offset_right = 262.0
\tmenu_vbox.offset_top = 148.0
\tmenu_vbox.offset_bottom = 316.0"""

new_setup_ui = """func setup_ui() -> void:
\t# ── Title Container (Cinematic Center Anchor) ───────────────────────────
\ttitle_container = Control.new()
\ttitle_container.name = "TitleContainer"
\ttitle_container.anchor_left = 0.5
\ttitle_container.anchor_right = 0.5
\ttitle_container.offset_left = -200.0
\ttitle_container.offset_right = 200.0
\ttitle_container.offset_top = 40.0
\ttitle_container.offset_bottom = 120.0
\ttitle_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tadd_child(title_container)

\ttitle_label = Label.new()
\ttitle_label.name = "TitleLabel"
\ttitle_label.position = Vector2(0, 0)
\ttitle_label.size = Vector2(400, 52)
\ttitle_label.text = "HALIYA"
\ttitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\ttitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\ttitle_label.add_theme_font_override("font", FONT_ALAGARD)
\ttitle_label.add_theme_font_size_override("font_size", 50)
\ttitle_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 1.0))
\ttitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\ttitle_label.add_theme_constant_override("shadow_offset_x", 3)
\ttitle_label.add_theme_constant_override("shadow_offset_y", 3)
\ttitle_container.add_child(title_label)

\tsubtitle_label = Label.new()
\tsubtitle_label.name = "SubtitleLabel"
\tsubtitle_label.position = Vector2(0, 52)
\tsubtitle_label.size = Vector2(400, 22)
\tsubtitle_label.text = "Mask of Sorrows"
\tsubtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tsubtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tsubtitle_label.add_theme_font_override("font", FONT_ALAGARD)
\tsubtitle_label.add_theme_font_size_override("font_size", 15)
\tsubtitle_label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.65, 0.92))
\tsubtitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tsubtitle_label.add_theme_constant_override("shadow_offset_x", 2)
\tsubtitle_label.add_theme_constant_override("shadow_offset_y", 2)
\ttitle_container.add_child(subtitle_label)

\t# Gentle breathing animation on title
\tvar tw = create_tween().set_loops()
\ttw.tween_property(title_label, "modulate", Color(1.08, 1.05, 0.95, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\ttw.tween_property(title_label, "modulate", Color(0.92, 0.90, 0.85, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

\t# ── Main Menu Buttons (Centered List) ───────────────────────────────────
\tmenu_vbox = VBoxContainer.new()
\tmenu_vbox.name = "MenuVBox"
\tmenu_vbox.anchor_left = 0.5
\tmenu_vbox.anchor_right = 0.5
\tmenu_vbox.offset_left = -105.0
\tmenu_vbox.offset_right = 105.0
\tmenu_vbox.offset_top = 138.0
\tmenu_vbox.offset_bottom = 312.0"""

assert old_setup_ui in code_lf, "old_setup_ui not found"
code_lf = code_lf.replace(old_setup_ui, new_setup_ui, 1)

# 5. Update create_menu_button alignment to center
old_btn = """func create_menu_button(label_text: String) -> Button:
\tvar btn = Button.new()
\tvar default_text = "   " + label_text
\tvar active_text = "   " + label_text

\tbtn.text = default_text
\tbtn.custom_minimum_size = Vector2(196, 28)
\tbtn.focus_mode = Control.FOCUS_ALL
\tbtn.alignment = HORIZONTAL_ALIGNMENT_LEFT"""

new_btn = """func create_menu_button(label_text: String) -> Button:
\tvar btn = Button.new()
\tvar default_text = label_text
\tvar active_text = label_text

\tbtn.text = default_text
\tbtn.custom_minimum_size = Vector2(210, 28)
\tbtn.focus_mode = Control.FOCUS_ALL
\tbtn.alignment = HORIZONTAL_ALIGNMENT_CENTER"""

assert old_btn in code_lf, "old_btn not found"
code_lf = code_lf.replace(old_btn, new_btn, 1)

# 6. Replace setup_press_start_ui() and splash methods to the end
setup_marker = "func setup_press_start_ui() -> void:"
assert setup_marker in code_lf, "setup_marker not found"

prefix = code_lf[:code_lf.index(setup_marker)]

new_tail = """func setup_press_start_ui() -> void:
\tpress_start_container = Control.new()
\tpress_start_container.name = "PressStartContainer"
\tpress_start_container.anchor_left = 0.5
\tpress_start_container.anchor_right = 0.5
\tpress_start_container.anchor_top = 1.0
\tpress_start_container.anchor_bottom = 1.0
\t# Placed at the very bottom, centered in the middle
\tpress_start_container.offset_left = -160.0
\tpress_start_container.offset_right = 160.0
\tpress_start_container.offset_top = -44.0
\tpress_start_container.offset_bottom = -16.0
\tpress_start_container.pivot_offset = Vector2(160.0, 14.0)
\tpress_start_container.mouse_filter = Control.MOUSE_FILTER_PASS
\tadd_child(press_start_container)

\tpress_start_label = Label.new()
\tpress_start_label.name = "PressStartLabel"
\tpress_start_label.set_anchors_preset(Control.PRESET_FULL_RECT)
\tpress_start_label.text = "PRESS ANY KEY TO START"
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

\t# ── Stage 1: Group 2 Page (Clean, no line) ──────────────────────────────
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
\tg2_box.offset_top = -36.0
\tg2_box.offset_bottom = 36.0
\tg2_box.alignment = BoxContainer.ALIGNMENT_CENTER
\tg2_box.add_theme_constant_override("separation", 10)
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
\t# Fade in from black to Group 2
\tsplash_tween.tween_property(fade_rect, "color:a", 0.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t# Hold for 1.4s steady
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
\tpress_start_tween.tween_property(press_start_container, "modulate:a", 0.40, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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

\t# Smooth, stylish dissolution of the start prompt at the bottom
\tif is_instance_valid(press_start_container):
\t\tvar dissolve_tw = create_tween().set_parallel(true)
\t\tdissolve_tw.tween_property(press_start_container, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\tdissolve_tw.chain().tween_callback(func():
\t\t\tif is_instance_valid(press_start_container):
\t\t\t\tpress_start_container.visible = false
\t\t)

\t# Silky smooth reveal of centered main menu buttons
\tif is_instance_valid(menu_vbox):
\t\tmenu_vbox.visible = true
\t\tmenu_vbox.modulate.a = 0.0
\t\tmenu_vbox.offset_top = 146.0
\t\tmenu_vbox.offset_bottom = 320.0
\t\tvar tw = create_tween().set_parallel(true)
\t\ttw.tween_property(menu_vbox, "modulate:a", 1.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw.tween_property(menu_vbox, "offset_top", 138.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw.tween_property(menu_vbox, "offset_bottom", 312.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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

print("Applied centered layout and removed totem successfully!")

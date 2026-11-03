import os

with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    orig = f.read()

is_crlf = '\r\n' in orig
code = orig.replace('\r\n', '\n')

# 1. Variables at top
var_old = """var fade_rect: ColorRect

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

var_new = """var fade_rect: ColorRect
var ver_label: Label

static var has_shown_splash: bool = false
var splash_layer: Control
var group2_page: Control
var logs_page: Control
var current_splash_stage: int = 0

var step3_container: Control
var step3_title_box: VBoxContainer
var step3_press_start_label: Label

var is_in_splash: bool = false
var is_in_press_start: bool = false
var splash_tween: Tween = null
var press_start_tween: Tween = null

var is_transitioning: bool = false"""

assert var_old in code, "var_old not found"
code = code.replace(var_old, var_new, 1)

# 2. _ready()
ready_old = """\tif not has_shown_splash:
\t\tis_in_splash = true
\t\tis_in_press_start = false
\t\tsplash_layer.visible = true
\t\tmenu_vbox.visible = false
\t\tmenu_vbox.modulate.a = 0.0
\t\tpress_start_container.visible = false
\t\tpress_start_container.modulate.a = 0.0
\t\tfade_rect.color = Color(0, 0, 0, 1.0)
\t\t_start_splash_sequence()
\telse:
\t\tis_in_splash = false
\t\tis_in_press_start = false
\t\tsplash_layer.visible = false
\t\tpress_start_container.visible = false
\t\tmenu_vbox.visible = true
\t\tmenu_vbox.modulate.a = 1.0
\t\tfade_rect.color = Color(0, 0, 0, 1.0)
\t\tvar tw = create_tween()
\t\ttw.tween_property(fade_rect, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

ready_new = """\tif not has_shown_splash:
\t\tis_in_splash = true
\t\tis_in_press_start = false
\t\tsplash_layer.visible = true
\t\tstep3_container.visible = false
\t\ttitle_container.visible = false
\t\tmenu_vbox.visible = false
\t\tver_label.visible = false
\t\tif is_instance_valid(altar_spr):
\t\t\taltar_spr.visible = false
\t\tvar motes = get_node_or_null("AltarMotes")
\t\tif is_instance_valid(motes):
\t\t\tmotes.emitting = false
\t\t\tmotes.visible = false
\t\tfade_rect.color = Color(0, 0, 0, 1.0)
\t\t_start_splash_sequence()
\telse:
\t\tis_in_splash = false
\t\tis_in_press_start = false
\t\tsplash_layer.visible = false
\t\tstep3_container.visible = false
\t\ttitle_container.visible = true
\t\ttitle_container.modulate.a = 1.0
\t\tmenu_vbox.visible = true
\t\tmenu_vbox.modulate.a = 1.0
\t\tver_label.visible = true
\t\tver_label.modulate.a = 1.0
\t\tif is_instance_valid(altar_spr):
\t\t\taltar_spr.visible = true
\t\t\taltar_spr.modulate.a = 1.0
\t\tvar motes = get_node_or_null("AltarMotes")
\t\tif is_instance_valid(motes):
\t\t\tmotes.emitting = true
\t\t\tmotes.visible = true
\t\tfade_rect.color = Color(0, 0, 0, 1.0)
\t\tvar tw = create_tween()
\t\ttw.tween_property(fade_rect, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

assert ready_old in code, "ready_old not found"
code = code.replace(ready_old, ready_new, 1)

# In _ready() change setup_press_start_ui() to setup_step3_ui()
code = code.replace("setup_press_start_ui()", "setup_step3_ui()", 1)

# 3. Restore totem in _update_background_bounds
bounds_old = """\t# Keep moon anchored to upper right sky
\tbase_moon_pos = Vector2(target_w * 0.78, 58.0)
\tif is_instance_valid(moon_container):
\t\tmoon_container.position = base_moon_pos"""

bounds_new = """\t# Keep moon anchored to upper right sky
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

assert bounds_old in code, "bounds_old not found"
code = code.replace(bounds_old, bounds_new, 1)

# 4. Restore totem in setup_background()
totem_bg_old = """\t# 4. Totem removed for clean open landscape as requested"""

totem_bg_new = """\t# 4. Sacred Haliya Totem firmly grounded on the right ridge
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

assert totem_bg_old in code, "totem_bg_old not found"
code = code.replace(totem_bg_old, totem_bg_new, 1)

# 5. Restore altar_motes in setup_ambient_particles()
motes_old = """\t# Altar motes removed with totem"""

motes_new = """\t# Localized spirit motes rising around the totem
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

assert motes_old in code, "motes_old not found"
code = code.replace(motes_old, motes_new, 1)

# 6. Restore classic left-aligned setup_ui()
setup_ui_old = """func setup_ui() -> void:
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

setup_ui_new = """func setup_ui() -> void:
\t# ── Step 4 Classic Title Container (Left Anchor, Just Like Before) ──────
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

\t# ── Step 4 Classic Menu Buttons (Left-Aligned List, Just Like Before) ───
\tmenu_vbox = VBoxContainer.new()
\tmenu_vbox.name = "MenuVBox"
\tmenu_vbox.anchor_left = 0.0
\tmenu_vbox.anchor_right = 0.0
\tmenu_vbox.offset_left = 52.0
\tmenu_vbox.offset_right = 262.0
\tmenu_vbox.offset_top = 148.0
\tmenu_vbox.offset_bottom = 316.0"""

assert setup_ui_old in code, "setup_ui_old not found"
code = code.replace(setup_ui_old, setup_ui_new, 1)

# In setup_ui() replace ver_label assignment:
code = code.replace("var ver_label = Label.new()", "ver_label = Label.new()", 1)

# 7. Restore create_menu_button to left-aligned with indent
btn_old = """func create_menu_button(label_text: String) -> Button:
\tvar btn = Button.new()
\tvar default_text = label_text
\tvar active_text = label_text

\tbtn.text = default_text
\tbtn.custom_minimum_size = Vector2(210, 28)
\tbtn.focus_mode = Control.FOCUS_ALL
\tbtn.alignment = HORIZONTAL_ALIGNMENT_CENTER"""

btn_new = """func create_menu_button(label_text: String) -> Button:
\tvar btn = Button.new()
\tvar default_text = "   " + label_text
\tvar active_text = "   " + label_text

\tbtn.text = default_text
\tbtn.custom_minimum_size = Vector2(196, 28)
\tbtn.focus_mode = Control.FOCUS_ALL
\tbtn.alignment = HORIZONTAL_ALIGNMENT_LEFT"""

assert btn_old in code, "btn_old not found"
code = code.replace(btn_old, btn_new, 1)

# 8. Replace setup_press_start_ui() and splash methods with setup_step3_ui() etc.
marker = "func setup_press_start_ui() -> void:"
assert marker in code, "marker not found"

prefix = code[:code.index(marker)]

tail = """func setup_step3_ui() -> void:
\tstep3_container = Control.new()
\tstep3_container.name = "Step3TitleContainer"
\tstep3_container.set_anchors_preset(Control.PRESET_FULL_RECT)
\tstep3_container.mouse_filter = Control.MOUSE_FILTER_PASS
\tadd_child(step3_container)

\t# Atmospheric soft celestial lunar aura filling the central vista
\tvar title_aura = Sprite2D.new()
\ttitle_aura.name = "TitleAura"
\ttitle_aura.position = Vector2(320.0, 142.0)
\ttitle_aura.texture = create_radial_glow_texture(150, Color(0.98, 0.95, 0.85, 0.16), Color(0.85, 0.82, 0.70, 0.0))
\tstep3_container.add_child(title_aura)

\t# Centered Title Box (brought down to the center so it does not look empty)
\tstep3_title_box = VBoxContainer.new()
\tstep3_title_box.name = "Step3TitleBox"
\tstep3_title_box.anchor_left = 0.5
\tstep3_title_box.anchor_right = 0.5
\tstep3_title_box.anchor_top = 0.5
\tstep3_title_box.anchor_bottom = 0.5
\tstep3_title_box.offset_left = -260.0
\tstep3_title_box.offset_right = 260.0
\tstep3_title_box.offset_top = -62.0
\tstep3_title_box.offset_bottom = 38.0
\tstep3_title_box.alignment = BoxContainer.ALIGNMENT_CENTER
\tstep3_title_box.add_theme_constant_override("separation", 6)
\tstep3_title_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tstep3_container.add_child(step3_title_box)

\tvar t_label = Label.new()
\tt_label.name = "Step3TitleLabel"
\tt_label.text = "HALIYA"
\tt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tt_label.add_theme_font_override("font", FONT_ALAGARD)
\tt_label.add_theme_font_size_override("font_size", 54)
\tt_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 1.0))
\tt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tt_label.add_theme_constant_override("shadow_offset_x", 3)
\tt_label.add_theme_constant_override("shadow_offset_y", 3)
\tt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tstep3_title_box.add_child(t_label)

\tvar s_label = Label.new()
\ts_label.name = "Step3SubLabel"
\ts_label.text = "Mask of Sorrows"
\ts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\ts_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\ts_label.add_theme_font_override("font", FONT_ALAGARD)
\ts_label.add_theme_font_size_override("font_size", 16)
\ts_label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.65, 0.95))
\ts_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\ts_label.add_theme_constant_override("shadow_offset_x", 2)
\ts_label.add_theme_constant_override("shadow_offset_y", 2)
\ts_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tstep3_title_box.add_child(s_label)

\t# Gentle breathing pulsation on title
\tvar tw = create_tween().set_loops()
\ttw.tween_property(t_label, "modulate", Color(1.08, 1.05, 0.95, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\ttw.tween_property(t_label, "modulate", Color(0.92, 0.90, 0.85, 1.0), 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

\t# Start prompt placed at the very bottom middle without lines or diamonds
\tstep3_press_start_label = Label.new()
\tstep3_press_start_label.name = "Step3PressStartLabel"
\tstep3_press_start_label.anchor_left = 0.5
\tstep3_press_start_label.anchor_right = 0.5
\tstep3_press_start_label.anchor_top = 1.0
\tstep3_press_start_label.anchor_bottom = 1.0
\tstep3_press_start_label.offset_left = -160.0
\tstep3_press_start_label.offset_right = 160.0
\tstep3_press_start_label.offset_top = -44.0
\tstep3_press_start_label.offset_bottom = -16.0
\tstep3_press_start_label.text = "PRESS ANY KEY TO START"
\tstep3_press_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tstep3_press_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tstep3_press_start_label.add_theme_font_override("font", FONT_ALAGARD)
\tstep3_press_start_label.add_theme_font_size_override("font_size", 14)
\tstep3_press_start_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 1.0))
\tstep3_press_start_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tstep3_press_start_label.add_theme_constant_override("shadow_offset_x", 2)
\tstep3_press_start_label.add_theme_constant_override("shadow_offset_y", 2)
\tstep3_press_start_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tstep3_container.add_child(step3_press_start_label)


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
\tgroup2_box = g2_box
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

\t# Step 3: Centered Title Screen
\tis_in_press_start = true
\tif is_instance_valid(step3_container):
\t\tstep3_container.visible = true
\t\tstep3_container.modulate = Color(1, 1, 1, 1)
\t\tstep3_container.scale = Vector2.ONE
\t\t_start_press_start_breathing()

\t# Keep Step 4 elements hidden during Step 3
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
\ttw_in.tween_property(fade_rect, "color:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif is_instance_valid(bgm_player):
\t\tvar bgm_tw = create_tween()
\t\tbgm_tw.tween_property(bgm_player, "volume_db", -8.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _start_press_start_breathing() -> void:
\tif press_start_tween and press_start_tween.is_valid():
\t\tpress_start_tween.kill()
\tif not is_instance_valid(step3_press_start_label):
\t\treturn
\tstep3_press_start_label.modulate.a = 1.0
\tpress_start_tween = create_tween().set_loops()
\tpress_start_tween.tween_property(step3_press_start_label, "modulate:a", 0.35, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\tpress_start_tween.tween_property(step3_press_start_label, "modulate:a", 1.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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

\t# Dissolve Step 3 centered title and start prompt
\tif is_instance_valid(step3_container):
\t\tvar dissolve_tw = create_tween().set_parallel(true)
\t\tdissolve_tw.tween_property(step3_container, "modulate:a", 0.0, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\tdissolve_tw.chain().tween_callback(func():
\t\t\tif is_instance_valid(step3_container):
\t\t\t\tstep3_container.visible = false
\t\t)

\t# Reveal Step 4 classic left-aligned menu, totem, and version label
\tif is_instance_valid(title_container):
\t\ttitle_container.visible = true
\t\ttitle_container.modulate.a = 0.0
\t\ttitle_container.offset_left = 36.0
\t\ttitle_container.offset_right = 304.0
\t\tvar tw_title = create_tween().set_parallel(true)
\t\ttw_title.tween_property(title_container, "modulate:a", 1.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_title.tween_property(title_container, "offset_left", 52.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_title.tween_property(title_container, "offset_right", 320.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif is_instance_valid(menu_vbox):
\t\tmenu_vbox.visible = true
\t\tmenu_vbox.modulate.a = 0.0
\t\tmenu_vbox.offset_left = 36.0
\t\tmenu_vbox.offset_right = 246.0
\t\tvar tw_menu = create_tween().set_parallel(true)
\t\ttw_menu.tween_property(menu_vbox, "modulate:a", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_menu.tween_property(menu_vbox, "offset_left", 52.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_menu.tween_property(menu_vbox, "offset_right", 262.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif is_instance_valid(altar_spr):
\t\taltar_spr.visible = true
\t\taltar_spr.modulate.a = 0.0
\t\tvar tw_totem = create_tween()
\t\ttw_totem.tween_property(altar_spr, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tvar motes = get_node_or_null("AltarMotes")
\tif is_instance_valid(motes):
\t\tmotes.visible = true
\t\tmotes.emitting = true

\tif is_instance_valid(ver_label):
\t\tver_label.visible = true
\t\tver_label.modulate.a = 0.0
\t\tvar tw_ver = create_tween()
\t\ttw_ver.tween_property(ver_label, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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

full_code = prefix + tail
final_code = full_code.replace('\n', '\r\n') if is_crlf else full_code

with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(final_code)

print("Applied perfect opening sequence successfully!")

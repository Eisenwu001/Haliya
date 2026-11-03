import os

with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    code = f.read()

# Normalize CRLF / LF for reliable matching
is_crlf = '\r\n' in code
code_lf = code.replace('\r\n', '\n')

# 1. Variables
var_target = """var fade_rect: ColorRect

var is_transitioning: bool = false"""

var_replace = """var fade_rect: ColorRect

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

assert var_target in code_lf, "var_target not found"
code_lf = code_lf.replace(var_target, var_replace, 1)

# 2. _ready()
ready_target = """func _ready() -> void:
\ttexture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\tRenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
\tsetup_sfx()
\tsetup_background()
\tsetup_ambient_particles()
\tsetup_ui()
\tsetup_stage_select_modal()
\tsetup_controls_modal()
\tsetup_fade_overlay()
\tsetup_bgm()

\t# Initial fade in from black
\tfade_rect.color = Color(0, 0, 0, 1.0)
\tvar tw = create_tween()
\ttw.tween_property(fade_rect, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

ready_replace = """func _ready() -> void:
\ttexture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\tRenderingServer.set_default_clear_color(Color(0.015, 0.02, 0.03, 1.0))
\tsetup_sfx()
\tsetup_background()
\tsetup_ambient_particles()
\tsetup_ui()
\tsetup_press_start_ui()
\tsetup_stage_select_modal()
\tsetup_controls_modal()
\tsetup_splash_layer()
\tsetup_fade_overlay()
\tsetup_bgm()

\tif not has_shown_splash:
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

assert ready_target in code_lf, "ready_target not found"
code_lf = code_lf.replace(ready_target, ready_replace, 1)

# 3. setup_bgm()
bgm_target = """func setup_bgm() -> void:
\tbgm_player = AudioStreamPlayer.new()
\tbgm_player.name = "MenuBGMPlayer"
\tbgm_player.bus = "Master"
\tbgm_player.stream = ProceduralAudio.get_menu_ambient()
\tbgm_player.volume_db = -80.0
\tadd_child(bgm_player)
\tbgm_player.play()

\tvar tw = create_tween()
\ttw.tween_property(bgm_player, "volume_db", -8.0, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

bgm_replace = """func setup_bgm() -> void:
\tbgm_player = AudioStreamPlayer.new()
\tbgm_player.name = "MenuBGMPlayer"
\tbgm_player.bus = "Master"
\tbgm_player.stream = ProceduralAudio.get_menu_ambient()
\tbgm_player.volume_db = -80.0
\tadd_child(bgm_player)
\tbgm_player.play()

\tif has_shown_splash:
\t\tvar tw = create_tween()
\t\ttw.tween_property(bgm_player, "volume_db", -8.0, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\telse:
\t\tvar tw = create_tween()
\t\ttw.tween_property(bgm_player, "volume_db", -26.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)"""

assert bgm_target in code_lf, "bgm_target not found"
code_lf = code_lf.replace(bgm_target, bgm_replace, 1)

# 4. New methods
new_methods = """

func setup_press_start_ui() -> void:
\tpress_start_container = Control.new()
\tpress_start_container.name = "PressStartContainer"
\tpress_start_container.anchor_left = 0.0
\tpress_start_container.anchor_right = 0.0
\tpress_start_container.offset_left = 52.0
\tpress_start_container.offset_right = 420.0
\tpress_start_container.offset_top = 160.0
\tpress_start_container.offset_bottom = 220.0
\tpress_start_container.mouse_filter = Control.MOUSE_FILTER_PASS
\tadd_child(press_start_container)

\tpress_start_label = Label.new()
\tpress_start_label.name = "PressStartLabel"
\tpress_start_label.position = Vector2(0, 0)
\tpress_start_label.size = Vector2(360, 36)
\tpress_start_label.text = "[ PRESS ANY KEY OR CLICK TO START ]"
\tpress_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
\tpress_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tpress_start_label.add_theme_font_override("font", FONT_ALAGARD)
\tpress_start_label.add_theme_font_size_override("font_size", 14)
\tpress_start_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78, 1.0))
\tpress_start_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tpress_start_label.add_theme_constant_override("shadow_offset_x", 2)
\tpress_start_label.add_theme_constant_override("shadow_offset_y", 2)
\tpress_start_label.mouse_filter = Control.MOUSE_FILTER_PASS
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
\tsplash_bg.color = Color(0.012, 0.015, 0.022, 1.0)
\tsplash_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_layer.add_child(splash_bg)

\tsplash_content = Control.new()
\tsplash_content.name = "SplashContent"
\tsplash_content.anchor_left = 0.5
\tsplash_content.anchor_right = 0.5
\tsplash_content.anchor_top = 0.5
\tsplash_content.anchor_bottom = 0.5
\tsplash_content.offset_left = -180.0
\tsplash_content.offset_top = -105.0
\tsplash_content.offset_right = 180.0
\tsplash_content.offset_bottom = 105.0
\tsplash_content.pivot_offset = Vector2(180.0, 105.0)
\tsplash_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_layer.add_child(splash_content)

\tvar logo_rect = TextureRect.new()
\tlogo_rect.name = "LogoRect"
\tlogo_rect.position = Vector2(0, 0)
\tlogo_rect.size = Vector2(360, 140)
\tlogo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\tlogo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\tlogo_rect.texture = _load_logs_production_texture()
\tlogo_rect.modulate = Color(0.98, 0.96, 0.92, 1.0)
\tlogo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_content.add_child(logo_rect)

\tvar sub_label = Label.new()
\tsub_label.name = "SplashSubtitle"
\tsub_label.position = Vector2(0, 146)
\tsub_label.size = Vector2(360, 24)
\tsub_label.text = "A  G R O U P  2  P R O D U C T I O N"
\tsub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tsub_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tsub_label.add_theme_font_override("font", FONT_ALAGARD)
\tsub_label.add_theme_font_size_override("font_size", 13)
\tsub_label.add_theme_color_override("font_color", Color(0.86, 0.80, 0.68, 0.95))
\tsub_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tsub_label.add_theme_constant_override("shadow_offset_x", 1)
\tsub_label.add_theme_constant_override("shadow_offset_y", 1)
\tsub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_content.add_child(sub_label)

\tvar skip_label = Label.new()
\tskip_label.name = "SkipPrompt"
\tskip_label.anchor_left = 0.5
\tskip_label.anchor_right = 0.5
\tskip_label.anchor_top = 1.0
\tskip_label.anchor_bottom = 1.0
\tskip_label.offset_left = -160.0
\tskip_label.offset_top = -28.0
\tskip_label.offset_right = 160.0
\tskip_label.offset_bottom = -8.0
\tskip_label.text = "[ PRESS ANY KEY TO SKIP ]"
\tskip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tskip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tskip_label.add_theme_font_override("font", FONT_ALAGARD)
\tskip_label.add_theme_font_size_override("font_size", 10)
\tskip_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65, 0.40))
\tskip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tsplash_layer.add_child(skip_label)


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
\tif splash_tween and splash_tween.is_valid():
\t\tsplash_tween.kill()

\tif is_instance_valid(sfx_ui_player):
\t\tsfx_ui_player.stream = ProceduralAudio.get_splash_chime()
\t\tsfx_ui_player.volume_db = -4.0
\t\tsfx_ui_player.play()

\tsplash_tween = create_tween()
\tsplash_tween.tween_property(fade_rect, "color:a", 0.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\tif is_instance_valid(splash_content):
\t\tsplash_content.scale = Vector2(0.97, 0.97)
\t\tvar zoom_tw = create_tween()
\t\tzoom_tw.tween_property(splash_content, "scale", Vector2(1.02, 1.02), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

\tsplash_tween.tween_interval(1.8)
\tsplash_tween.tween_callback(func(): _transition_splash_to_title(false))


func _skip_splash() -> void:
\tif not is_in_splash:
\t\treturn
\tis_in_splash = false
\tif splash_tween and splash_tween.is_valid():
\t\tsplash_tween.kill()
\t_transition_splash_to_title(true)


func _transition_splash_to_title(is_skip: bool = false) -> void:
\tis_in_splash = false
\tvar fade_out_time: float = 0.35 if is_skip else 0.70

\tvar tw = create_tween()
\ttw.tween_property(fade_rect, "color:a", 1.0, fade_out_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
\ttw.tween_callback(func():
\t\thas_shown_splash = true
\t\tif is_instance_valid(splash_layer):
\t\t\tsplash_layer.visible = false

\t\tis_in_press_start = true
\t\tif is_instance_valid(press_start_container):
\t\t\tpress_start_container.visible = true
\t\t\tpress_start_container.modulate.a = 1.0
\t\t\t_start_press_start_breathing()
\t\tif is_instance_valid(menu_vbox):
\t\t\tmenu_vbox.visible = false
\t\t\tmenu_vbox.modulate.a = 0.0

\t\tvar tw_in = create_tween()
\t\ttw_in.tween_property(fade_rect, "color:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

\t\tif is_instance_valid(bgm_player):
\t\t\tvar bgm_tw = create_tween()
\t\t\tbgm_tw.tween_property(bgm_player, "volume_db", -8.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t)


func _start_press_start_breathing() -> void:
\tif press_start_tween and press_start_tween.is_valid():
\t\tpress_start_tween.kill()
\tif not is_instance_valid(press_start_label):
\t\treturn
\tpress_start_label.modulate = Color(1.0, 0.95, 0.85, 1.0)
\tpress_start_tween = create_tween().set_loops()
\tpress_start_tween.tween_property(press_start_label, "modulate:a", 0.35, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
\tpress_start_tween.tween_property(press_start_label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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

\tif is_instance_valid(press_start_label):
\t\tvar flash_tw = create_tween()
\t\tflash_tw.tween_property(press_start_label, "modulate", Color(1.8, 1.6, 1.1, 1.0), 0.08).set_trans(Tween.TRANS_QUAD)
\t\tflash_tw.tween_property(press_start_label, "modulate", Color(1.0, 0.95, 0.8, 0.0), 0.22).set_trans(Tween.TRANS_QUAD)
\t\tflash_tw.tween_callback(func():
\t\t\tif is_instance_valid(press_start_container):
\t\t\t\tpress_start_container.visible = false
\t\t)

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

code_lf = code_lf + new_methods

final_code = code_lf.replace('\n', '\r\n') if is_crlf else code_lf
with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(final_code)
print('Successfully patched scripts/main_menu.gd!')

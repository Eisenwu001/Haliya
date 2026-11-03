with open("scripts/act1_bahay_kubo.gd", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Preloads
old_preloads = """const WeaponRackScript = preload("res://scripts/weapon_rack.gd")
const MaskAltarScript = preload("res://scripts/mask_altar.gd")"""

new_preloads = """const WeaponRackScript = preload("res://scripts/weapon_rack.gd")
const MaskAltarScript = preload("res://scripts/mask_altar.gd")
const BestiaryCodexUIScript = preload("res://scripts/bestiary_codex_ui.gd")
const BaybayinLabelScript = preload("res://scripts/baybayin_label.gd")"""

assert old_preloads in content, "old_preloads not found"
content = content.replace(old_preloads, new_preloads, 1)

# 2. Add variables
old_vars = """var is_transitioning: bool = false

# UI references"""

new_vars = """var is_transitioning: bool = false
var bestiary_codex_ui: CanvasLayer
var bgm_player: AudioStreamPlayer
var baybayin_area_label: Control
var altar_prompt_label: Label

# UI references"""

assert old_vars in content, "old_vars not found"
content = content.replace(old_vars, new_vars, 1)

# 3. In _ready, call setup_bgm()
old_ready = """\tsetup_kapre_and_altar()
\tsetup_ui()
\ttrigger_area_discovery("ACT 1 — BAHAY KUBO (THE HOMESTEAD)")"""

new_ready = """\tsetup_bgm()
\tsetup_kapre_and_altar()
\tsetup_ui()
\ttrigger_area_discovery("ACT 1 — BAHAY KUBO (THE HOMESTEAD)")"""

assert old_ready in content, "old_ready not found"
content = content.replace(old_ready, new_ready, 1)

# 4. In setup_ui, add bestiary_codex_ui, baybayin_area_label, and altar prompt
old_ui_disc = """\t# Area Discovery Label (Center Upper)
\tarea_title_label = Label.new()
\tarea_title_label.position = Vector2(120, 55)
\tarea_title_label.size = Vector2(400, 32)
\tarea_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\tarea_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
\tarea_title_label.text = "✦ ACT 1 — BAHAY KUBO ✦"
\tarea_title_label.add_theme_font_override("font", custom_font)
\tarea_title_label.add_theme_font_size_override("font_size", 16)
\tarea_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
\tarea_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\tui_layer.add_child(area_title_label)"""

new_ui_disc = """\t# Codex & Ancestral Altar UI
\tbestiary_codex_ui = BestiaryCodexUIScript.new()
\tbestiary_codex_ui.name = "BestiaryCodexUI"
\tadd_child(bestiary_codex_ui)

\t# Baybayin Discovery Banner
\tbaybayin_area_label = BaybayinLabelScript.new()
\tbaybayin_area_label.name = "BaybayinAreaLabel"
\tbaybayin_area_label.position = Vector2(120, 38)
\tbaybayin_area_label.size = Vector2(400, 48)
\tui_layer.add_child(baybayin_area_label)

\t# Area Discovery Label (Center Upper)
\tarea_title_label = Label.new()
\tarea_title_label.visible = false
\tui_layer.add_child(area_title_label)

\t# Altar interaction prompt
\taltar_prompt_label = Label.new()
\taltar_prompt_label.name = "AltarPromptLabel"
\taltar_prompt_label.position = Vector2(160, 295)
\taltar_prompt_label.size = Vector2(320, 24)
\taltar_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\taltar_prompt_label.text = "[E / ENTER] COMMUNE WITH ANCESTRAL ALTAR"
\taltar_prompt_label.add_theme_font_override("font", custom_font)
\taltar_prompt_label.add_theme_font_size_override("font_size", 12)
\taltar_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.45, 0.95))
\taltar_prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
\taltar_prompt_label.visible = false
\tui_layer.add_child(altar_prompt_label)"""

assert old_ui_disc in content, "old_ui_disc not found"
content = content.replace(old_ui_disc, new_ui_disc, 1)

# 5. In trigger_area_discovery, play decode sequence
old_trigger_disc = """func trigger_area_discovery(text_title: String) -> void:
\tif area_title_label:
\t\tarea_title_label.text = text_title
\t\tarea_title_timer = 3.2
\t\tarea_title_label.modulate.a = 1.0"""

new_trigger_disc = """func trigger_area_discovery(text_title: String) -> void:
\tif is_instance_valid(baybayin_area_label):
\t\tbaybayin_area_label.play_decode_sequence(text_title, "", 18)
\t\tbaybayin_area_label.modulate.a = 1.0
\tarea_title_timer = 3.6"""

assert old_trigger_disc in content, "old_trigger_disc not found"
content = content.replace(old_trigger_disc, new_trigger_disc, 1)

# 6. In _process, handle area title fade, altar proximity prompt, and BGM setup
old_process = """\t# Area title fade
\tif area_title_timer > 0.0:
\t\tarea_title_timer -= delta
\t\tvar alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
\t\tif area_title_label:
\t\t\tarea_title_label.modulate.a = alpha"""

new_process = """\t# Area title fade
\tif area_title_timer > 0.0:
\t\tarea_title_timer -= delta
\t\tvar alpha = clamp(area_title_timer / 0.6, 0.0, 1.0)
\t\tif is_instance_valid(baybayin_area_label):
\t\t\tbaybayin_area_label.modulate.a = alpha
\t\telif area_title_label:
\t\t\tarea_title_label.modulate.a = alpha

\t# Altar interaction check
\tif player and is_instance_valid(mask_altar) and is_instance_valid(altar_prompt_label):
\t\tvar dist_to_altar = abs(player.global_position.x - mask_altar.global_position.x)
\t\tvar is_near = dist_to_altar < 65.0
\t\taltar_prompt_label.visible = is_near
\t\tif is_near and Input.is_action_just_pressed("ui_accept"):
\t\t\tif is_instance_valid(bestiary_codex_ui) and not bestiary_codex_ui.visible:
\t\t\t\tbestiary_codex_ui.open_menu()"""

assert old_process in content, "old_process not found"
content = content.replace(old_process, new_process, 1)

# Add setup_bgm method
bgm_method = """
func setup_bgm() -> void:
\tbgm_player = AudioStreamPlayer.new()
\tbgm_player.name = "BGMPlayer"
\tbgm_player.bus = "Master"
\tbgm_player.stream = ProceduralAudio.get_kulintang_exploration_bgm()
\tbgm_player.volume_db = -10.0
\tadd_child(bgm_player)
\tbgm_player.play()
"""
content += bgm_method

with open("scripts/act1_bahay_kubo.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("scripts/act1_bahay_kubo.gd successfully updated!")

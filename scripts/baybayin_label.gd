class_name BaybayinLabel
extends VBoxContainer

## BaybayinLabel
## Visual UI component that displays ancient Baybayin script that animates and decodes into English.

const BaybayinTextScript = preload("res://scripts/baybayin_text.gd")
const FONT_ALAGARD = preload("res://alagard.ttf")

static var cached_baybayin_font: FontFile = null

var baybayin_label: Label
var english_label: Label
var current_english: String = ""
var current_baybayin: String = ""
var reveal_tween: Tween = null


static func get_baybayin_font() -> FontFile:
	if not cached_baybayin_font:
		cached_baybayin_font = FontFile.new()
		var bytes = FileAccess.get_file_as_bytes("res://assets/fonts/NotoSansTagalog-Regular.ttf")
		if bytes.size() > 0:
			cached_baybayin_font.data = bytes
	return cached_baybayin_font


func _init() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 1. Baybayin Glyph Label (Upper / Leading Script)
	baybayin_label = Label.new()
	baybayin_label.name = "BaybayinGlyphs"
	baybayin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	baybayin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var b_font = get_baybayin_font()
	if b_font:
		baybayin_label.add_theme_font_override("font", b_font)
	baybayin_label.add_theme_font_size_override("font_size", 22)
	baybayin_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.50, 1.0))
	baybayin_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	baybayin_label.add_theme_constant_override("shadow_offset_x", 1)
	baybayin_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(baybayin_label)
	
	# 2. English Translated Label (Main / Subtitle)
	english_label = Label.new()
	english_label.name = "EnglishText"
	english_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	english_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	english_label.add_theme_font_override("font", FONT_ALAGARD)
	english_label.add_theme_font_size_override("font_size", 18)
	english_label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88, 1.0))
	english_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	english_label.add_theme_constant_override("shadow_offset_x", 2)
	english_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(english_label)


func set_text(english_str: String, custom_baybayin: String = "") -> void:
	current_english = english_str
	current_baybayin = custom_baybayin if custom_baybayin != "" else BaybayinTextScript.get_baybayin(english_str)
	
	baybayin_label.text = "✦  %s  ✦" % current_baybayin
	english_label.text = current_english


func play_decode_sequence(english_str: String, custom_baybayin: String = "", font_size_en: int = 20) -> void:
	current_english = english_str
	current_baybayin = custom_baybayin if custom_baybayin != "" else BaybayinTextScript.get_baybayin(english_str)
	english_label.add_theme_font_size_override("font_size", font_size_en)
	
	if is_instance_valid(reveal_tween) and reveal_tween.is_valid():
		reveal_tween.kill()
	
	# Initial state: Baybayin glowing bright, English hidden
	baybayin_label.text = "✦  %s  ✦" % current_baybayin
	baybayin_label.modulate = Color(2.0, 1.8, 0.8, 0.0)
	baybayin_label.scale = Vector2(1.15, 1.15)
	baybayin_label.pivot_offset = Vector2(baybayin_label.size.x * 0.5, baybayin_label.size.y * 0.5)
	
	english_label.text = current_english
	english_label.modulate.a = 0.0
	
	reveal_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Step 1: Baybayin bursts in with radiant golden moonlight
	reveal_tween.tween_property(baybayin_label, "modulate", Color(1.0, 0.90, 0.55, 1.0), 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal_tween.parallel().tween_property(baybayin_label, "scale", Vector2(1.0, 1.0), 0.40).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Step 2: Dramatic ancient rune hold
	reveal_tween.tween_interval(0.65)
	
	# Step 3: English title decodes/fades in below while Baybayin softly recedes to celestial header
	reveal_tween.tween_property(english_label, "modulate:a", 1.0, 0.50).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reveal_tween.parallel().tween_property(baybayin_label, "modulate", Color(0.75, 0.85, 1.0, 0.75), 0.50)

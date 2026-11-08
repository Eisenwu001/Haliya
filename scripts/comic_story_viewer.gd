class_name ComicStoryViewer
extends CanvasLayer

signal story_completed
signal typewriter_tick(character: String)

const UIConstants = preload("res://ui/theme/ui_theme_constants.gd")
const FONT_REGULAR = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const FONT_BOLD = preload("res://assets/fonts/Silkscreen-Bold.ttf")

const DEFAULT_BGM_PATH: String = "res://assets/audio/ambient/eerie_cutscene_dark_ambience.wav"

const PROLOGUE_PANEL_FILES: Array[String] = [
	"res://Haliya Story/Haliya comic scene.png",
	"res://Haliya Story/Haliya comic scene(1).png",
	"res://Haliya Story/Haliya comic scene(2).png",
	"res://Haliya Story/Haliya comic scene(3).png",
	"res://Haliya Story/Haliya comic scene(4).png",
	"res://Haliya Story/Haliya comic scene(5).png",
	"res://Haliya Story/Haliya comic scene(6).png",
	"res://Haliya Story/Haliya comic scene(7).png",
	"res://Haliya Story/Haliya comic scene(8).png"
]

const PROLOGUE_CAPTIONS: Array[String] = [
	"A kind of safe that feels borrowed.",
	"Six lights going out. A shape standing over my sisters.",
	"She doesn't remember walking here.",
	"Kapre finds her.",
	"\"You're the seventh. The last light.\nI watched this land before it went quiet like this. I watched what took it from us.\"",
	"\"You don't remember all of it. Maybe that's kindness. What's left is this: he took them from you. One by one.\"",
	"\"If you're going after him, you won't be the same when you come back.\"",
	"\"Your family carried grief the way other people carry water, in a vessel, not in their bare hands.\"\nThere's one left.",
	"She follows. She doesn't look back."
]

# Drift direction offsets per slide for stepped pan/zoom
const DRIFT_VECTORS: Array[Vector2] = [
	Vector2(8.0, -6.0),
	Vector2(-10.0, 4.0),
	Vector2(6.0, 8.0),
	Vector2(-8.0, -6.0),
	Vector2(10.0, 6.0),
	Vector2(-6.0, -8.0),
	Vector2(8.0, 4.0),
	Vector2(-10.0, 8.0),
	Vector2(6.0, -6.0)
]

const PIP_FULL = preload("res://assets/ui/hud_pip_crescent_full.png")
const PIP_GOLD = preload("res://assets/ui/hud_pip_crescent_gold.png")
const PIP_EMPTY = preload("res://assets/ui/hud_pip_crescent_empty.png")
const CRESCENT_MARKER = preload("res://assets/ui/crescent_sel_0.png")
const LOWER_GRADIENT_TEX = preload("res://assets/ui/cutscene_lower_gradient.png")
const CUTSCENE_SHADER = preload("res://shaders/cutscene_grade.gdshader")

var current_panel_paths: Array[String] = []
var active_textures: Array[Texture2D] = []
var current_captions: Array[String] = []
var current_panel_idx: int = 0
var is_active: bool = false
var is_prologue_mode: bool = false
var is_transitioning: bool = false
var is_in_title_card: bool = false
var is_pausing_tree: bool = false

# UI Components
var bg_rect: ColorRect
var display_back: TextureRect
var display_front: TextureRect
var material_front: ShaderMaterial
var material_back: ShaderMaterial

# Cinematic Title Card
var title_card_box: VBoxContainer
var title_label: Label
var lore_label: Label
var subtitle_label: Label
var title_tween: Tween

# Lower third container & text
var lower_third_root: Control
var lower_gradient: TextureRect
var caption_label: Label
var pips_container: HBoxContainer
var pips_list: Array[TextureRect] = []

# Continue prompt
var prompt_container: HBoxContainer
var prompt_marker: TextureRect
var prompt_label: Label
var prompt_tween: Tween

# Audio
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var typewriter_sfx_player: AudioStreamPlayer

# Stepped pan/zoom state
var pan_zoom_timer: float = 0.0
var pan_zoom_step: int = 0
const STEP_INTERVAL: float = 0.08
const MAX_PAN_STEPS: int = 60

# Typewriter state
var is_typewriting: bool = false
var typewriter_char_index: int = 0
var typewriter_timer: float = 0.0
const TYPEWRITER_SPEED: float = 0.035 # seconds per character
var current_slide_caption: String = ""


func _init() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio()
	setup_ui()
	visible = false


func _process(delta: float) -> void:
	if not is_active or is_in_title_card:
		return

	# 1. Stepped pan/zoom
	if not is_transitioning and is_instance_valid(display_front) and display_front.texture != null:
		pan_zoom_timer += delta
		if pan_zoom_timer >= STEP_INTERVAL:
			pan_zoom_timer = 0.0
			pan_zoom_step = mini(pan_zoom_step + 1, MAX_PAN_STEPS)
			var t: float = float(pan_zoom_step) / float(MAX_PAN_STEPS)
			var cur_scale: float = 1.0 + t * 0.05
			var drift_dir: Vector2 = DRIFT_VECTORS[current_panel_idx % DRIFTVECTORS_COUNT()]
			var offset: Vector2 = (drift_dir * t).round()
			display_front.scale = Vector2(cur_scale, cur_scale)
			display_front.position = offset

	# 2. Stepped typewriter reveal
	if is_typewriting:
		typewriter_timer += delta
		if typewriter_timer >= TYPEWRITER_SPEED:
			typewriter_timer = 0.0
			_typewriter_step()


func DRIFTVECTORS_COUNT() -> int:
	return DRIFT_VECTORS.size()


func setup_audio() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "ComicBGM"
	bgm_player.bus = "Master"
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "ComicSFX"
	sfx_player.bus = "Master"
	add_child(sfx_player)

	typewriter_sfx_player = AudioStreamPlayer.new()
	typewriter_sfx_player.name = "TypewriterSFX"
	typewriter_sfx_player.bus = "Master"
	typewriter_sfx_player.volume_db = -18.0
	add_child(typewriter_sfx_player)

	typewriter_tick.connect(_on_typewriter_tick)


func setup_ui() -> void:
	# 1. Fullscreen pure black canvas
	bg_rect = ColorRect.new()
	bg_rect.name = "CinematicBackdrop"
	bg_rect.color = Color(0.04, 0.05, 0.06, 1.0)
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg_rect)

	# 2. Dual TextureRects with cutscene grade shader
	material_back = ShaderMaterial.new()
	material_back.shader = CUTSCENE_SHADER
	material_back.set_shader_parameter("dissolve_progress", 1.0)

	material_front = ShaderMaterial.new()
	material_front.shader = CUTSCENE_SHADER
	material_front.set_shader_parameter("dissolve_progress", 1.0)

	display_back = TextureRect.new()
	display_back.name = "DisplayBack"
	display_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	display_back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display_back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display_back.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	display_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display_back.material = material_back
	bg_rect.add_child(display_back)

	display_front = TextureRect.new()
	display_front.name = "DisplayFront"
	display_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	display_front.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display_front.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display_front.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	display_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display_front.material = material_front
	bg_rect.add_child(display_front)

	# Center pivots for clean stepped zoom
	display_back.pivot_offset = Vector2(320.0, 180.0)
	display_front.pivot_offset = Vector2(320.0, 180.0)

	# 3. Cinematic Title Card (Theme font Silkscreen, warm gold & bone cream)
	title_card_box = VBoxContainer.new()
	title_card_box.name = "TitleCardBox"
	title_card_box.anchor_left = 0.0
	title_card_box.anchor_right = 1.0
	title_card_box.anchor_top = 0.5
	title_card_box.anchor_bottom = 0.5
	title_card_box.offset_top = -60.0
	title_card_box.offset_bottom = 60.0
	title_card_box.alignment = BoxContainer.ALIGNMENT_CENTER
	title_card_box.add_theme_constant_override("separation", 14)
	title_card_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_rect.add_child(title_card_box)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "THE LAST LIGHT"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_override("font", FONT_BOLD)
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", UIConstants.COLOR_WARM_GOLD)
	title_label.add_theme_color_override("font_shadow_color", Color(0.06, 0.08, 0.07, 1.0))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	title_label.add_theme_constant_override("outline_size", 2)
	title_card_box.add_child(title_label)

	lore_label = Label.new()
	lore_label.name = "LoreLabel"
	lore_label.text = "\"When the sacred moons are swallowed by the void, one masked guardian carries the dawn.\""
	lore_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_label.add_theme_font_override("font", FONT_REGULAR)
	lore_label.add_theme_font_size_override("font_size", 10)
	lore_label.add_theme_color_override("font_color", UIConstants.COLOR_BONE_CREAM)
	lore_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	lore_label.add_theme_constant_override("shadow_offset_x", 1)
	lore_label.add_theme_constant_override("shadow_offset_y", 1)
	title_card_box.add_child(lore_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_override("font", FONT_REGULAR)
	subtitle_label.add_theme_font_size_override("font_size", 10)
	subtitle_label.add_theme_color_override("font_color", UIConstants.COLOR_BONE_CREAM)
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 1)
	title_card_box.add_child(subtitle_label)

	# 4. Lower Third Dithered Gradient & Text Overlay
	lower_third_root = Control.new()
	lower_third_root.name = "LowerThirdRoot"
	lower_third_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	lower_third_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_rect.add_child(lower_third_root)

	lower_gradient = TextureRect.new()
	lower_gradient.name = "LowerGradient"
	lower_gradient.texture = LOWER_GRADIENT_TEX
	lower_gradient.anchor_left = 0.0
	lower_gradient.anchor_right = 1.0
	lower_gradient.anchor_top = 1.0
	lower_gradient.anchor_bottom = 1.0
	lower_gradient.offset_left = 0.0
	lower_gradient.offset_right = 0.0
	lower_gradient.offset_top = -120.0
	lower_gradient.offset_bottom = 0.0
	lower_gradient.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lower_gradient.stretch_mode = TextureRect.STRETCH_SCALE
	lower_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower_third_root.add_child(lower_gradient)

	# Left-aligned caption text in Theme font
	caption_label = Label.new()
	caption_label.name = "CaptionLabel"
	caption_label.anchor_left = 0.0
	caption_label.anchor_right = 1.0
	caption_label.anchor_top = 1.0
	caption_label.anchor_bottom = 1.0
	caption_label.offset_left = 28.0
	caption_label.offset_right = -160.0
	caption_label.offset_top = -88.0
	caption_label.offset_bottom = -16.0
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	caption_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption_label.add_theme_font_override("font", FONT_REGULAR)
	caption_label.add_theme_font_size_override("font_size", 10)
	caption_label.add_theme_constant_override("line_spacing", 6)
	caption_label.add_theme_color_override("font_color", UIConstants.COLOR_BONE_CREAM)
	caption_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	caption_label.add_theme_constant_override("shadow_offset_x", 1)
	caption_label.add_theme_constant_override("shadow_offset_y", 1)
	caption_label.add_theme_color_override("font_outline_color", Color(0.06, 0.08, 0.07, 0.90))
	caption_label.add_theme_constant_override("outline_size", 2)
	caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower_third_root.add_child(caption_label)

	# Crescent Pips indicator replacing [1/9]
	pips_container = HBoxContainer.new()
	pips_container.name = "CrescentPipsContainer"
	pips_container.anchor_left = 1.0
	pips_container.anchor_right = 1.0
	pips_container.anchor_top = 1.0
	pips_container.anchor_bottom = 1.0
	pips_container.offset_left = -164.0
	pips_container.offset_right = -24.0
	pips_container.offset_top = -88.0
	pips_container.offset_bottom = -72.0
	pips_container.alignment = BoxContainer.ALIGNMENT_END
	pips_container.add_theme_constant_override("separation", 5)
	pips_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower_third_root.add_child(pips_container)

	pips_list.clear()
	for i in range(9):
		var pip := TextureRect.new()
		pip.name = "Pip_%d" % i
		pip.custom_minimum_size = Vector2(10.0, 10.0)
		pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pip.texture = PIP_EMPTY
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pips_container.add_child(pip)
		pips_list.append(pip)

	# Continue prompt: Crescent marker + dim "SPACE" hint
	prompt_container = HBoxContainer.new()
	prompt_container.name = "PromptContainer"
	prompt_container.anchor_left = 1.0
	prompt_container.anchor_right = 1.0
	prompt_container.anchor_top = 1.0
	prompt_container.anchor_bottom = 1.0
	prompt_container.offset_left = -164.0
	prompt_container.offset_right = -24.0
	prompt_container.offset_top = -34.0
	prompt_container.offset_bottom = -16.0
	prompt_container.alignment = BoxContainer.ALIGNMENT_END
	prompt_container.add_theme_constant_override("separation", 6)
	prompt_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower_third_root.add_child(prompt_container)

	prompt_marker = TextureRect.new()
	prompt_marker.name = "PromptCrescent"
	prompt_marker.texture = CRESCENT_MARKER
	prompt_marker.custom_minimum_size = Vector2(10.0, 10.0)
	prompt_marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	prompt_marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	prompt_marker.modulate = Color(1.0, 1.0, 1.0, 0.95)
	prompt_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_container.add_child(prompt_marker)

	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.text = "SPACE"
	prompt_label.add_theme_font_override("font", FONT_REGULAR)
	prompt_label.add_theme_font_size_override("font_size", 9)
	prompt_label.add_theme_color_override("font_color", UIConstants.COLOR_QUIT_MUTED)
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.90))
	prompt_label.add_theme_constant_override("shadow_offset_x", 1)
	prompt_label.add_theme_constant_override("shadow_offset_y", 1)
	prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_container.add_child(prompt_label)


func _create_paused_tween() -> Tween:
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tw


func play_cutscene(title_text: String, subtitle_text: String, panel_paths: Array, music_path: String = "", is_prologue: bool = false, pauses_tree: bool = false, captions: Array[String] = []) -> void:
	is_active = true
	is_prologue_mode = is_prologue
	is_transitioning = false
	current_panel_idx = 0
	visible = true

	if is_inside_tree() and get_viewport():
		get_viewport().gui_release_focus()

	is_pausing_tree = pauses_tree
	if is_pausing_tree and is_inside_tree():
		get_tree().paused = true

	_silence_all_external_audio()

	current_panel_paths.clear()
	for p in panel_paths:
		current_panel_paths.append(str(p))

	# Setup captions
	current_captions.clear()
	if not captions.is_empty():
		for c in captions:
			current_captions.append(c)
	elif is_prologue:
		for c in PROLOGUE_CAPTIONS:
			current_captions.append(c)

	active_textures.clear()
	active_textures.resize(current_panel_paths.size())
	for i in range(active_textures.size()):
		active_textures[i] = null
	if not current_panel_paths.is_empty():
		_get_panel_texture(0)

	_setup_pips(current_panel_paths.size())

	var track = music_path if music_path != "" else DEFAULT_BGM_PATH
	play_music_track(track)

	# Visual prep
	bg_rect.modulate.a = 1.0
	display_front.texture = null
	display_front.modulate.a = 1.0
	display_front.position = Vector2.ZERO
	display_front.scale = Vector2.ONE
	material_front.set_shader_parameter("dissolve_progress", 1.0)
	display_back.texture = null
	display_back.position = Vector2.ZERO
	display_back.scale = Vector2.ONE
	material_back.set_shader_parameter("dissolve_progress", 1.0)

	lower_third_root.visible = false
	lower_third_root.modulate.a = 0.0

	if title_tween and title_tween.is_valid():
		title_tween.kill()

	if title_text != "":
		is_in_title_card = true
		title_card_box.visible = true
		title_card_box.modulate.a = 1.0
		title_label.text = title_text
		title_label.modulate.a = 0.0

		title_tween = _create_paused_tween()

		if is_prologue:
			subtitle_label.visible = false
			lore_label.visible = true
			lore_label.text = "\"When the sacred moons are swallowed by the void, one masked guardian carries the dawn.\""
			lore_label.modulate.a = 0.0

			title_tween.tween_property(title_label, "modulate:a", 1.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			title_tween.tween_interval(0.5)
			title_tween.tween_property(lore_label, "modulate:a", 0.95, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			title_tween.tween_interval(2.2)
			title_tween.tween_property(title_card_box, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			title_tween.tween_callback(func():
				if not is_active:
					return
				is_in_title_card = false
				title_card_box.visible = false
				display_first_panel()
			)
		else:
			lore_label.visible = false
			subtitle_label.visible = (subtitle_text != "")
			subtitle_label.text = subtitle_text
			subtitle_label.modulate.a = 0.0

			title_tween.tween_property(title_label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			if subtitle_label.visible:
				title_tween.tween_interval(0.3)
				title_tween.tween_property(subtitle_label, "modulate:a", 0.88, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			title_tween.tween_interval(1.8)
			title_tween.tween_property(title_card_box, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			title_tween.tween_callback(func():
				if not is_active:
					return
				is_in_title_card = false
				title_card_box.visible = false
				display_first_panel()
			)
	else:
		is_in_title_card = false
		title_card_box.visible = false
		display_first_panel()


func _setup_pips(count: int) -> void:
	for pip in pips_list:
		pip.queue_free()
	pips_list.clear()

	for i in range(count):
		var pip := TextureRect.new()
		pip.name = "Pip_%d" % i
		pip.custom_minimum_size = Vector2(10.0, 10.0)
		pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pip.texture = PIP_EMPTY
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pips_container.add_child(pip)
		pips_list.append(pip)


func _update_pips(current_idx: int) -> void:
	for i in range(pips_list.size()):
		var pip = pips_list[i]
		if i < current_idx:
			pip.texture = PIP_FULL
			pip.modulate = Color(0.85, 0.81, 0.66, 0.60)
		elif i == current_idx:
			pip.texture = PIP_GOLD
			pip.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			pip.texture = PIP_EMPTY
			pip.modulate = Color(0.40, 0.44, 0.48, 0.50)


func _get_panel_texture(idx: int) -> Texture2D:
	if idx < 0 or idx >= current_panel_paths.size():
		return null
	if active_textures[idx] != null:
		return active_textures[idx]
	var path: String = current_panel_paths[idx]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if not tex:
		var global_path = ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(global_path):
			var img = Image.load_from_file(global_path)
			if img:
				tex = ImageTexture.create_from_image(img)
	active_textures[idx] = tex
	return tex


func display_first_panel() -> void:
	if current_panel_paths.size() == 0:
		close_story(true)
		return

	display_panel(0, false)
	lower_third_root.visible = true
	var tw_hud = _create_paused_tween()
	tw_hud.tween_property(lower_third_root, "modulate:a", 1.0, 0.40)


func open_story(as_prologue: bool = false) -> void:
	play_cutscene("THE LAST LIGHT", "", PROLOGUE_PANEL_FILES, DEFAULT_BGM_PATH, as_prologue)


func close_story(immediate: bool = false) -> void:
	if not is_active:
		return
	is_active = false
	is_in_title_card = false
	is_typewriting = false
	if title_tween and title_tween.is_valid():
		title_tween.kill()
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()

	stop_music()

	if is_pausing_tree and is_inside_tree():
		is_pausing_tree = false
		get_tree().paused = false

	if immediate or is_prologue_mode:
		visible = false
		story_completed.emit()
		return

	var tw = _create_paused_tween()
	tw.tween_property(bg_rect, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		visible = false
		story_completed.emit()
	)


func display_panel(idx: int, animate_crossfade: bool = true) -> void:
	if idx < 0 or idx >= current_panel_paths.size():
		return

	var new_tex = _get_panel_texture(idx)
	current_panel_idx = idx

	if idx + 1 < current_panel_paths.size():
		_get_panel_texture(idx + 1)

	_update_pips(idx)

	# Reset stepped pan/zoom
	pan_zoom_step = 0
	pan_zoom_timer = 0.0
	display_front.position = Vector2.ZERO
	display_front.scale = Vector2.ONE

	# Setup caption and typewriter
	current_slide_caption = ""
	if idx < current_captions.size():
		current_slide_caption = current_captions[idx]

	_start_typewriter(current_slide_caption)

	if not animate_crossfade:
		is_transitioning = false
		display_front.texture = new_tex
		material_front.set_shader_parameter("dissolve_progress", 1.0)
		display_back.texture = null
		return

	# Dithered dissolve transition
	is_transitioning = true
	display_back.texture = display_front.texture
	display_back.position = display_front.position
	display_back.scale = display_front.scale
	material_back.set_shader_parameter("dissolve_progress", 1.0)

	display_front.texture = new_tex
	material_front.set_shader_parameter("dissolve_progress", 0.0)

	play_page_turn_sfx()

	var tw = _create_paused_tween()
	tw.tween_method(
		func(val: float):
			material_front.set_shader_parameter("dissolve_progress", val),
		0.0,
		1.0,
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func():
		is_transitioning = false
		display_back.texture = null
	)


func _start_typewriter(text: String) -> void:
	caption_label.text = text
	caption_label.visible_characters = 0
	typewriter_char_index = 0
	typewriter_timer = 0.0
	is_typewriting = true
	prompt_container.visible = false
	prompt_container.modulate.a = 0.0

	if text == "":
		_finish_typewriter()


func _typewriter_step() -> void:
	if not is_typewriting:
		return
	if typewriter_char_index < current_slide_caption.length():
		typewriter_char_index += 1
		caption_label.visible_characters = typewriter_char_index
		var ch: String = current_slide_caption[typewriter_char_index - 1]
		typewriter_tick.emit(ch)
	else:
		_finish_typewriter()


func _finish_typewriter() -> void:
	is_typewriting = false
	caption_label.visible_characters = -1
	prompt_container.visible = true
	var tw = _create_paused_tween()
	tw.tween_property(prompt_container, "modulate:a", 1.0, 0.25)
	_start_prompt_breathing()


func _on_typewriter_tick(character: String) -> void:
	if character == " " or character == "\n" or character == "\t":
		return
	play_typewriter_tick_sfx()


func next_panel() -> void:
	if not is_active:
		return
	if is_in_title_card:
		if title_tween and title_tween.is_valid():
			title_tween.kill()
		is_in_title_card = false
		title_card_box.visible = false
		display_first_panel()
		return

	# If text is still typing, skip typing first!
	if is_typewriting:
		_finish_typewriter()
		return

	if current_panel_idx < current_panel_paths.size() - 1:
		display_panel(current_panel_idx + 1, true)
	else:
		close_story()


func prev_panel() -> void:
	if not is_active or is_in_title_card:
		return
	if is_typewriting:
		_finish_typewriter()
	if current_panel_idx > 0:
		display_panel(current_panel_idx - 1, true)


func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()
		close_story()
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_RIGHT)):
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()
		next_panel()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_LEFT:
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()
		prev_panel()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()
		next_panel()


func _start_prompt_breathing() -> void:
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()
	prompt_marker.modulate.a = 0.95
	prompt_label.modulate.a = 0.70
	prompt_tween = _create_paused_tween().set_loops()
	prompt_tween.tween_property(prompt_marker, "modulate:a", 0.40, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.parallel().tween_property(prompt_label, "modulate:a", 0.35, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.tween_property(prompt_marker, "modulate:a", 0.95, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.parallel().tween_property(prompt_label, "modulate:a", 0.70, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func play_music_track(path: String) -> void:
	if not is_instance_valid(bgm_player):
		return
	var stream: AudioStream = null
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is AudioStream:
			stream = res
	if stream == null:
		stream = ProceduralAudio.get_eerie_cutscene_ambient()
	if stream != null:
		bgm_player.stream = stream
		bgm_player.volume_db = -2.0
		if bgm_player.is_inside_tree():
			bgm_player.play()


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		if is_active and is_instance_valid(bgm_player) and bgm_player.is_inside_tree() and bgm_player.stream != null and not bgm_player.playing:
			bgm_player.play()


func stop_music() -> void:
	if is_instance_valid(bgm_player):
		bgm_player.stop()


func _silence_all_external_audio() -> void:
	if not is_inside_tree() or not get_tree():
		return
	var root_node = get_tree().root
	if not is_instance_valid(root_node):
		return
	for n in root_node.find_children("MenuBGMPlayer", "AudioStreamPlayer", true, false):
		if is_instance_valid(n) and n is AudioStreamPlayer:
			n.stop()
	for n in root_node.find_children("MenuSFXPlayer", "AudioStreamPlayer", true, false):
		if is_instance_valid(n) and n is AudioStreamPlayer:
			n.stop()
	for n in root_node.find_children("BGMPlayer", "AudioStreamPlayer", true, false):
		if is_instance_valid(n) and n is AudioStreamPlayer:
			n.stop()


func fade_out_music() -> void:
	if not is_instance_valid(bgm_player) or not bgm_player.playing:
		return
	var tw = _create_paused_tween()
	tw.tween_property(bgm_player, "volume_db", -50.0, 0.40)
	tw.tween_callback(func():
		if is_instance_valid(bgm_player):
			bgm_player.stop()
	)


func play_typewriter_tick_sfx() -> void:
	if not is_inside_tree() or not is_instance_valid(typewriter_sfx_player):
		return
	var sample_rate: int = 22050
	var duration: float = 0.018
	var total_samples: int = int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0 - (t / duration)
		var click = sin(TAU * 780.0 * t) * env * 0.28
		var val: int = clampi(int(click * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data

	typewriter_sfx_player.stream = stream
	typewriter_sfx_player.pitch_scale = randf_range(0.92, 1.08)
	typewriter_sfx_player.play()


func play_page_turn_sfx() -> void:
	if not is_inside_tree() or not is_instance_valid(sfx_player):
		return
	var sample_rate: int = 22050
	var duration: float = 0.16
	var total_samples: int = int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0 - (t / duration)
		var noise = randf_range(-1.0, 1.0) * env
		var gentle = (sin(TAU * 320.0 * t) * 0.4 + noise * 0.6) * env * 0.35
		var val: int = clampi(int(gentle * 32767.0), -32768, 32767)
		data.encode_s16(i * 2, val)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data

	sfx_player.stream = stream
	sfx_player.volume_db = -10.0
	sfx_player.pitch_scale = randf_range(0.95, 1.05)
	sfx_player.play()

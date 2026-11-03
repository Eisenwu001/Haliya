class_name ComicStoryViewer
extends CanvasLayer

signal story_completed

const FONT_RES = preload("res://alagard.ttf")
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

var current_panel_paths: Array[String] = []
var active_textures: Array[Texture2D] = []
var current_panel_idx: int = 0
var is_active: bool = false
var is_prologue_mode: bool = false
var is_transitioning: bool = false
var is_in_title_card: bool = false
var is_pausing_tree: bool = false

# UI Components (Full-screen native display, zero shrinking, zero shaking)
var bg_rect: ColorRect
var display_back: TextureRect
var display_front: TextureRect

# Cinematic Title Card
var title_card_box: VBoxContainer
var title_label: Label
var lore_label: Label
var subtitle_label: Label
var title_tween: Tween

# Minimalist Movie Subtitle Prompts
var hud_root: Control
var page_label: Label
var prompt_label: Label
var prompt_tween: Tween

# Audio
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _init() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio()
	setup_ui()
	visible = false


func setup_audio() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "ComicBGM"
	bgm_player.bus = "Master"
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "ComicSFX"
	sfx_player.bus = "Master"
	add_child(sfx_player)


func setup_ui() -> void:
	# 1. Fullscreen pure black canvas
	bg_rect = ColorRect.new()
	bg_rect.name = "CinematicBackdrop"
	bg_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg_rect)

	# 2. Dual TextureRects mounted directly on fullscreen canvas with Linear Mipmaps
	# Expands to the screen's full dimensions preserving native aspect ratio
	# without any shrinking or artificial letterbox container crushing.
	display_back = TextureRect.new()
	display_back.name = "DisplayBack"
	display_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	display_back.offset_left = 0
	display_back.offset_top = 0
	display_back.offset_right = 0
	display_back.offset_bottom = 0
	display_back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display_back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display_back.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	display_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_rect.add_child(display_back)

	display_front = TextureRect.new()
	display_front.name = "DisplayFront"
	display_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	display_front.offset_left = 0
	display_front.offset_top = 0
	display_front.offset_right = 0
	display_front.offset_bottom = 0
	display_front.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display_front.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display_front.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	display_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_rect.add_child(display_front)

	# 3. Cinematic Title Card (Clean typography, no diamond lines or fireflies, slow elegant text fade)
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
	title_label.add_theme_font_override("font", FONT_RES)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0.12, 0.06, 0.02, 1.0))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	title_label.add_theme_constant_override("outline_size", 2)
	title_card_box.add_child(title_label)

	lore_label = Label.new()
	lore_label.name = "LoreLabel"
	lore_label.text = "\"When the sacred moons are swallowed by the void, one masked guardian carries the dawn.\""
	lore_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lore_label.add_theme_font_override("font", FONT_RES)
	lore_label.add_theme_font_size_override("font_size", 11)
	lore_label.add_theme_color_override("font_color", Color(0.85, 0.82, 0.74, 0.90))
	lore_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	lore_label.add_theme_constant_override("shadow_offset_x", 1)
	lore_label.add_theme_constant_override("shadow_offset_y", 1)
	title_card_box.add_child(lore_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_override("font", FONT_RES)
	subtitle_label.add_theme_font_size_override("font_size", 11)
	subtitle_label.add_theme_color_override("font_color", Color(0.85, 0.82, 0.74, 0.90))
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 1)
	title_card_box.add_child(subtitle_label)

	# 4. Minimalist HUD Overlay (Subtle text floating over bottom, crisp outline, never blocking the scene)
	hud_root = Control.new()
	hud_root.name = "HUDOverlay"
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_rect.add_child(hud_root)

	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.text = "Press Space or Click to continue  •  [ESC] Skip"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_override("font", FONT_RES)
	prompt_label.add_theme_font_size_override("font_size", 10)
	prompt_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.82, 0.85))
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	prompt_label.add_theme_constant_override("shadow_offset_x", 1)
	prompt_label.add_theme_constant_override("shadow_offset_y", 1)
	prompt_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	prompt_label.add_theme_constant_override("outline_size", 2)
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.anchor_top = 1.0
	prompt_label.anchor_bottom = 1.0
	prompt_label.offset_left = -260.0
	prompt_label.offset_right = 260.0
	prompt_label.offset_top = -24.0
	prompt_label.offset_bottom = -8.0
	prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(prompt_label)

	page_label = Label.new()
	page_label.name = "PageLabel"
	page_label.text = "[ 1 / 9 ]"
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	page_label.add_theme_font_override("font", FONT_RES)
	page_label.add_theme_font_size_override("font_size", 10)
	page_label.add_theme_color_override("font_color", Color(0.82, 0.74, 0.52, 0.80))
	page_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	page_label.add_theme_constant_override("shadow_offset_x", 1)
	page_label.add_theme_constant_override("shadow_offset_y", 1)
	page_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	page_label.add_theme_constant_override("outline_size", 2)
	page_label.anchor_left = 1.0
	page_label.anchor_right = 1.0
	page_label.anchor_top = 1.0
	page_label.anchor_bottom = 1.0
	page_label.offset_left = -100.0
	page_label.offset_right = -18.0
	page_label.offset_top = -24.0
	page_label.offset_bottom = -8.0
	page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(page_label)


func _create_paused_tween() -> Tween:
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tw


func play_cutscene(title_text: String, subtitle_text: String, panel_paths: Array, music_path: String = "", is_prologue: bool = false, pauses_tree: bool = false) -> void:
	is_active = true
	is_prologue_mode = is_prologue
	is_transitioning = false
	current_panel_idx = 0
	visible = true

	# Release any button focus in background to prevent Spacebar hijacking
	if is_inside_tree() and get_viewport():
		get_viewport().gui_release_focus()

	is_pausing_tree = pauses_tree
	if is_pausing_tree and is_inside_tree():
		get_tree().paused = true

	# Silence and kill all external menu music and SFX so nothing bleeds into the cutscene
	_silence_all_external_audio()

	# Setup panels for fast progressive on-demand loading
	current_panel_paths.clear()
	for p in panel_paths:
		current_panel_paths.append(str(p))
	active_textures.clear()
	active_textures.resize(current_panel_paths.size())
	for i in range(active_textures.size()):
		active_textures[i] = null
	if not current_panel_paths.is_empty():
		_get_panel_texture(0)

	# Start Kulintang music track
	var track = music_path if music_path != "" else DEFAULT_BGM_PATH
	play_music_track(track)

	# Prepare visuals (clean, fixed transform, zero jitter)
	bg_rect.modulate.a = 1.0
	display_front.texture = null
	display_front.modulate.a = 1.0
	display_front.position = Vector2.ZERO
	display_front.scale = Vector2.ONE
	display_front.pivot_offset = Vector2.ZERO
	display_back.texture = null
	display_back.position = Vector2.ZERO
	display_back.scale = Vector2.ONE
	display_back.pivot_offset = Vector2.ZERO
	hud_root.visible = false
	hud_root.modulate.a = 0.0

	if title_tween and title_tween.is_valid():
		title_tween.kill()

	if title_text != "":
		# ── Phase 1: Cinematic Title Card (Slow sequenced text fade-in) ────────
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

			# 1. "THE LAST LIGHT" slowly fades in
			title_tween.tween_property(title_label, "modulate:a", 1.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			# 2. Quiet pause
			title_tween.tween_interval(0.6)
			# 3. Sacred moon lore text slowly fades in
			title_tween.tween_property(lore_label, "modulate:a", 0.92, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			# 4. Hold both on screen for contemplation
			title_tween.tween_interval(2.5)
			# 5. Dissolve title card smoothly into comic panel 1
			title_tween.tween_property(title_card_box, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
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

			# Boss cutscene title
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
	hud_root.visible = true
	var tw_hud = _create_paused_tween()
	tw_hud.tween_property(hud_root, "modulate:a", 1.0, 0.50)
	_start_prompt_breathing()


func open_story(as_prologue: bool = false) -> void:
	play_cutscene("THE LAST LIGHT", "", PROLOGUE_PANEL_FILES, DEFAULT_BGM_PATH, as_prologue)


func close_story(immediate: bool = false) -> void:
	if not is_active:
		return
	is_active = false
	is_in_title_card = false
	if title_tween and title_tween.is_valid():
		title_tween.kill()
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()

	stop_music()

	if is_pausing_tree and is_inside_tree():
		is_pausing_tree = false
		get_tree().paused = false

	# If prologue mode, KEEP PURE BLACK and emit signal immediately!
	# Never fade out to reveal the main menu before game scene loads!
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

	# Pre-load next panel in sequence to eliminate page turn latency
	if idx + 1 < current_panel_paths.size():
		_get_panel_texture(idx + 1)

	if current_panel_paths.size() > 1:
		page_label.visible = true
		page_label.text = "[ %d / %d ]" % [idx + 1, current_panel_paths.size()]
	else:
		page_label.visible = false

	if is_prologue_mode and idx == current_panel_paths.size() - 1:
		prompt_label.text = "Press Space or Click to begin the journey  •  [ESC] Skip"
	else:
		prompt_label.text = "Press Space or Click to continue  •  [ESC] Skip"

	# Fixed positioning: zero camera jitter/shaking
	display_front.position = Vector2.ZERO
	display_front.scale = Vector2.ONE
	display_front.pivot_offset = Vector2.ZERO
	display_back.position = Vector2.ZERO
	display_back.scale = Vector2.ONE
	display_back.pivot_offset = Vector2.ZERO

	if not animate_crossfade:
		is_transitioning = false
		display_front.texture = new_tex
		display_front.modulate.a = 1.0
		display_back.texture = null
		return

	# Smooth crossfade between panels
	is_transitioning = true
	display_back.texture = display_front.texture
	display_back.modulate.a = 1.0

	display_front.texture = new_tex
	display_front.modulate.a = 0.0

	play_page_turn_sfx()

	var tw = _create_paused_tween()
	tw.tween_property(display_front, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		is_transitioning = false
		display_back.texture = null
	)


func next_panel() -> void:
	if not is_active:
		return
	if is_in_title_card:
		# Fast-forward title card immediately
		if title_tween and title_tween.is_valid():
			title_tween.kill()
		is_in_title_card = false
		title_card_box.visible = false
		display_first_panel()
		return
	if current_panel_idx < current_panel_paths.size() - 1:
		display_panel(current_panel_idx + 1, true)
	else:
		close_story()


func prev_panel() -> void:
	if not is_active or is_in_title_card:
		return
	if current_panel_idx > 0:
		display_panel(current_panel_idx - 1, true)


# High priority input interceptor: consumes Space, Enter, Escape, Clicks so background never receives them
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
	prompt_label.modulate.a = 0.85
	prompt_tween = _create_paused_tween().set_loops()
	prompt_tween.tween_property(prompt_label, "modulate:a", 0.40, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.tween_property(prompt_label, "modulate:a", 0.85, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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
		if is_active and is_instance_valid(bgm_player) and bgm_player.stream != null and not bgm_player.playing:
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
	# Silence any MenuBGMPlayer and MenuSFXPlayer across the tree
	for n in root_node.find_children("MenuBGMPlayer", "AudioStreamPlayer", true, false):
		if is_instance_valid(n) and n is AudioStreamPlayer:
			n.stop()
	for n in root_node.find_children("MenuSFXPlayer", "AudioStreamPlayer", true, false):
		if is_instance_valid(n) and n is AudioStreamPlayer:
			n.stop()
	# Silence any gameplay BGMPlayer across the tree
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

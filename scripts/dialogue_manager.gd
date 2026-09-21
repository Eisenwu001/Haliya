class_name DialogueManager
extends CanvasLayer

signal dialogue_started
signal dialogue_finished
signal choice_selected(choice_index: int, choice_text: String)

const FONT_RES = preload("res://alagard.ttf")
const PORTRAIT_KAPRE = preload("res://assets/bahay_kubo/portrait_kapre.png")
const PORTRAIT_HALIYA = preload("res://assets/bahay_kubo/portrait_haliya.png")

var root_panel: Panel
var portrait_rect: TextureRect
var speaker_label: Label
var text_label: Label
var continue_indicator: Label
var choices_container: VBoxContainer

var dialogue_queue: Array[Dictionary] = []
var is_active: bool = false
var is_typing: bool = false
var current_full_text: String = ""
var text_timer: float = 0.0
var char_index: int = 0
var char_delay: float = 0.025
var on_finish_callback: Callable = Callable()

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialogue_manager")
	setup_ui()
	visible = false

func setup_ui() -> void:
	root_panel = Panel.new()
	root_panel.name = "DialoguePanel"
	root_panel.position = Vector2(30, 235)
	root_panel.size = Vector2(580, 110)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.07, 0.10, 0.94)
	style_box.border_color = Color(0.55, 0.45, 0.35, 1.0)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.corner_radius_bottom_right = 4
	root_panel.add_theme_stylebox_override("panel", style_box)
	add_child(root_panel)
	
	portrait_rect = TextureRect.new()
	portrait_rect.name = "Portrait"
	portrait_rect.position = Vector2(14, 15)
	portrait_rect.size = Vector2(80, 80)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root_panel.add_child(portrait_rect)
	
	speaker_label = Label.new()
	speaker_label.name = "SpeakerLabel"
	speaker_label.position = Vector2(104, 10)
	speaker_label.size = Vector2(400, 20)
	speaker_label.add_theme_font_override("font", FONT_RES)
	speaker_label.add_theme_font_size_override("font_size", 16)
	speaker_label.add_theme_color_override("font_color", Color(0.96, 0.85, 0.55, 1.0))
	speaker_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	speaker_label.add_theme_constant_override("shadow_offset_x", 1)
	speaker_label.add_theme_constant_override("shadow_offset_y", 1)
	root_panel.add_child(speaker_label)
	
	text_label = Label.new()
	text_label.name = "TextLabel"
	text_label.position = Vector2(104, 32)
	text_label.size = Vector2(460, 68)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_override("font", FONT_RES)
	text_label.add_theme_font_size_override("font_size", 14)
	text_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.86, 1.0))
	text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	text_label.add_theme_constant_override("shadow_offset_x", 1)
	text_label.add_theme_constant_override("shadow_offset_y", 1)
	root_panel.add_child(text_label)
	
	continue_indicator = Label.new()
	continue_indicator.name = "ContinueIndicator"
	continue_indicator.position = Vector2(545, 84)
	continue_indicator.size = Vector2(25, 20)
	continue_indicator.text = "▼"
	continue_indicator.add_theme_font_override("font", FONT_RES)
	continue_indicator.add_theme_font_size_override("font_size", 14)
	continue_indicator.add_theme_color_override("font_color", Color(0.96, 0.85, 0.55, 1.0))
	root_panel.add_child(continue_indicator)
	
	choices_container = VBoxContainer.new()
	choices_container.name = "ChoicesContainer"
	choices_container.position = Vector2(104, 30)
	choices_container.size = Vector2(460, 72)
	choices_container.visible = false
	root_panel.add_child(choices_container)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if continue_indicator.visible:
		var blink = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 150.0)
		continue_indicator.modulate.a = blink
	
	if is_typing:
		text_timer += delta
		if text_timer >= char_delay:
			text_timer = 0.0
			if char_index < current_full_text.length():
				char_index += 1
				text_label.text = current_full_text.substr(0, char_index)
			else:
				is_typing = false
				continue_indicator.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump") or event.is_action_pressed("attack") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventKey and event.pressed and event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]):
		if choices_container.visible:
			return
		
		if is_typing:
			text_label.text = current_full_text
			char_index = current_full_text.length()
			is_typing = false
			continue_indicator.visible = true
			get_viewport().set_input_as_handled()
		else:
			advance_dialogue()
			get_viewport().set_input_as_handled()

func start_dialogue(entries: Array[Dictionary], finish_callback: Callable = Callable()) -> void:
	dialogue_queue = entries.duplicate()
	on_finish_callback = finish_callback
	is_active = true
	visible = true
	dialogue_started.emit()
	advance_dialogue()

func advance_dialogue() -> void:
	if dialogue_queue.is_empty():
		close_dialogue()
		return
	
	var entry: Dictionary = dialogue_queue.pop_front()
	
	if entry.has("choices"):
		present_choices(entry)
		return
	
	choices_container.visible = false
	text_label.visible = true
	
	var speaker: String = entry.get("speaker", "")
	var text: String = entry.get("text", "")
	var portrait_type: String = entry.get("portrait", "none")
	
	speaker_label.text = speaker
	current_full_text = text
	text_label.text = ""
	char_index = 0
	text_timer = 0.0
	is_typing = true
	continue_indicator.visible = false
	
	match portrait_type:
		"kapre":
			portrait_rect.texture = PORTRAIT_KAPRE
			portrait_rect.visible = true
			speaker_label.position.x = 104
			text_label.position.x = 104
		"haliya":
			portrait_rect.texture = PORTRAIT_HALIYA
			portrait_rect.visible = true
			speaker_label.position.x = 104
			text_label.position.x = 104
		_:
			portrait_rect.visible = false
			speaker_label.position.x = 24
			text_label.position.x = 24

func present_choices(entry: Dictionary) -> void:
	speaker_label.text = entry.get("speaker", "Select Weapon")
	text_label.visible = false
	continue_indicator.visible = false
	choices_container.visible = true
	
	for child in choices_container.get_children():
		child.queue_free()
	
	var choices: Array = entry.get("choices", [])
	for i in range(choices.size()):
		var choice_text: String = choices[i]
		var btn = Button.new()
		btn.text = "✦ " + choice_text
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_override("font", FONT_RES)
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color", Color(0.96, 0.88, 0.65, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		
		var normal_sb = StyleBoxFlat.new()
		normal_sb.bg_color = Color(0.14, 0.12, 0.16, 0.85)
		normal_sb.corner_radius_top_left = 3
		normal_sb.corner_radius_top_right = 3
		normal_sb.corner_radius_bottom_left = 3
		normal_sb.corner_radius_bottom_right = 3
		btn.add_theme_stylebox_override("normal", normal_sb)
		
		var hover_sb = StyleBoxFlat.new()
		hover_sb.bg_color = Color(0.28, 0.22, 0.32, 0.95)
		hover_sb.border_color = Color(0.9, 0.8, 0.4, 1.0)
		hover_sb.border_width_left = 1
		hover_sb.border_width_right = 1
		hover_sb.border_width_top = 1
		hover_sb.border_width_bottom = 1
		btn.add_theme_stylebox_override("hover", hover_sb)
		btn.add_theme_stylebox_override("pressed", hover_sb)
		
		var idx = i
		btn.pressed.connect(func():
			choices_container.visible = false
			choice_selected.emit(idx, choice_text)
			advance_dialogue()
		)
		choices_container.add_child(btn)
		if i == 0:
			btn.grab_focus()

func close_dialogue() -> void:
	is_active = false
	visible = false
	dialogue_finished.emit()
	if on_finish_callback.is_valid():
		on_finish_callback.call()
		on_finish_callback = Callable()

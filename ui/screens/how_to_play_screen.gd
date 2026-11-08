class_name HaliyaHowToPlayScreen
extends "res://ui/components/haliya_panel_dialog.gd"

## HaliyaHowToPlayScreen
## Concise paginated guide with pixel-art keyboard and mouse prompt icons.
## Inherits all styling from res://ui/theme/haliya_theme.tres.

const PAGES := [
	{
		"title": "PAGE 1 / 3  •  MOVEMENT AND TRAVERSAL",
		"rows": [
			{"keys": ["A", "D"], "mouse": "", "action": "MOVE LEFT / RIGHT", "desc": "Traverse the moonlit forest floor and highland ridges."},
			{"keys": ["SPACE"], "mouse": "", "action": "JUMP AND WALL JUMP", "desc": "Leap across chasms or rebound off vertical cliff faces."},
			{"keys": ["S"], "mouse": "", "action": "CROUCH AND DROP", "desc": "Duck beneath projectiles or drop through bamboo platforms."},
			{"keys": ["C"], "mouse": "", "action": "SHADOW DASH", "desc": "Evade through enemy strikes with brief invulnerability."}
		]
	},
	{
		"title": "PAGE 2 / 3  •  BLADE ARTS AND PARRYING",
		"rows": [
			{"keys": ["J"], "mouse": "LMB", "action": "KAMPILAN STRIKE", "desc": "Chain 3-hit combos; strike downward in mid-air to pogo."},
			{"keys": ["K"], "mouse": "RMB", "action": "DEFLECT AND PARRY", "desc": "Raise ward just before impact to shatter enemy posture."},
			{"keys": ["E"], "mouse": "", "action": "PATAYIN EXECUTION", "desc": "Execute staggered foes when the Baybayin rune appears."},
			{"keys": ["R"], "mouse": "", "action": "SANCTUARY RESET", "desc": "Return to the nearest moonlit altar if trapped."}
		]
	},
	{
		"title": "PAGE 3 / 3  •  STAMINA, ARMOR AND SHRINES",
		"rows": [
			{"keys": ["STA"], "mouse": "", "action": "STAMINA DISCIPLINE", "desc": "Attacks and dashes consume stamina; avoid full exhaustion."},
			{"keys": ["ARM"], "mouse": "", "action": "ANCESTRAL WARD", "desc": "Absorbs hits before HP and regenerates out of combat."},
			{"keys": ["E"], "mouse": "", "action": "BALETE SHRINES", "desc": "Commune at shrines to save progress and draft blessings."}
		]
	}
]

var current_page: int = 0
var page_title_label: Label
var rows_container: VBoxContainer
var prev_page_btn: Button
var next_page_btn: Button


func _init() -> void:
	super._init()
	dialog_title = "HOW TO PLAY"
	panel_size = Vector2(536, 304)
	_build_how_to_play_ui()


func _build_how_to_play_ui() -> void:
	var nav_bar := HBoxContainer.new()
	nav_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_bar.add_theme_constant_override("separation", C.SPACING_MD)
	body_container.add_child(nav_bar)

	prev_page_btn = Button.new()
	prev_page_btn.text = "< PREV"
	prev_page_btn.theme_type_variation = &"ActionButton"
	prev_page_btn.custom_minimum_size = Vector2(76, 20)
	prev_page_btn.pressed.connect(func(): _set_page(current_page - 1))
	nav_bar.add_child(prev_page_btn)

	page_title_label = Label.new()
	page_title_label.theme_type_variation = &"SectionHeaderLabel"
	page_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_bar.add_child(page_title_label)

	next_page_btn = Button.new()
	next_page_btn.text = "NEXT >"
	next_page_btn.theme_type_variation = &"ActionButton"
	next_page_btn.custom_minimum_size = Vector2(76, 20)
	next_page_btn.pressed.connect(func(): _set_page(current_page + 1))
	nav_bar.add_child(next_page_btn)

	var inner_panel := PanelContainer.new()
	inner_panel.theme_type_variation = &"InnerPanelContainer"
	inner_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_container.add_child(inner_panel)

	rows_container = VBoxContainer.new()
	rows_container.add_theme_constant_override("separation", C.SPACING_MD)
	inner_panel.add_child(rows_container)

	_set_page(0)


func _set_page(page_idx: int) -> void:
	current_page = posmod(page_idx, PAGES.size())
	var pdata: Dictionary = PAGES[current_page]
	page_title_label.text = str(pdata["title"])

	for c in rows_container.get_children():
		c.queue_free()

	var tex_sm: Texture2D = load(C.TEX_KEY_SM)
	var tex_wide: Texture2D = load(C.TEX_KEY_WIDE)
	var tex_lmb: Texture2D = load(C.TEX_MOUSE_LMB)
	var tex_rmb: Texture2D = load(C.TEX_MOUSE_RMB)

	for r in pdata["rows"]:
		var row_hbox := HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", C.SPACING_MD)
		rows_container.add_child(row_hbox)

		# Prompt Icons Box (fixed width so action text aligns cleanly)
		var prompts_box := HBoxContainer.new()
		prompts_box.custom_minimum_size = Vector2(92, 22)
		prompts_box.alignment = BoxContainer.ALIGNMENT_BEGIN
		prompts_box.add_theme_constant_override("separation", 3)
		row_hbox.add_child(prompts_box)

		for k_str in r["keys"]:
			var is_wide: bool = String(k_str).length() > 1
			var cap_rect := TextureRect.new()
			cap_rect.texture = tex_wide if is_wide else tex_sm
			cap_rect.custom_minimum_size = Vector2(38 if is_wide else 18, 18)
			cap_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			prompts_box.add_child(cap_rect)

			var k_lbl := Label.new()
			k_lbl.text = String(k_str)
			k_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			k_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			k_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			cap_rect.add_child(k_lbl)

		var mouse_type: String = String(r["mouse"])
		if not mouse_type.is_empty():
			var m_rect := TextureRect.new()
			m_rect.texture = tex_lmb if mouse_type == "LMB" else tex_rmb
			m_rect.custom_minimum_size = Vector2(16, 20)
			m_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			prompts_box.add_child(m_rect)

		# Action & Description VBox
		var text_vbox := VBoxContainer.new()
		text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_vbox.add_theme_constant_override("separation", 1)
		row_hbox.add_child(text_vbox)

		var act_lbl := Label.new()
		act_lbl.text = str(r["action"])
		act_lbl.theme_type_variation = &"SectionHeaderLabel"
		text_vbox.add_child(act_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = str(r["desc"])
		desc_lbl.theme_type_variation = &"MutedBodyLabel"
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_vbox.add_child(desc_lbl)


func on_screen_opened() -> void:
	_set_page(0)
	if is_instance_valid(next_page_btn):
		next_page_btn.grab_focus()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_requested.emit()
	elif event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		_set_page(current_page - 1)
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		_set_page(current_page + 1)

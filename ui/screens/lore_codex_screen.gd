class_name HaliyaLoreCodexScreen
extends "res://ui/components/haliya_panel_dialog.gd"

## HaliyaLoreCodexScreen
## Left list of folklore/bestiary entries with codex icons (showing "???" when locked)
## paired with a right reading pane displaying Baybayin script and tribal lore.
## Inherits all styling from res://ui/theme/haliya_theme.tres.

const MetaProgression = preload("res://scripts/meta_progression.gd")

const ENTRY_ORDER := [
	"aswang",
	"corrupted_farmer",
	"skeleton",
	"santelmo",
	"forest_brute",
	"mayon_vanguard",
	"sinag_ulap",
	"bakunawa"
]

var tally_label: Label
var entry_list_vbox: VBoxContainer
var entry_buttons: Array[Button] = []

var detail_status_label: Label
var detail_title_label: Label
var detail_baybayin_label: Label
var detail_lore_label: Label
var selected_entry_idx: int = 0


func _init() -> void:
	super._init()
	dialog_title = "LORE CODEX"
	panel_size = Vector2(556, 316)
	_build_codex_ui()


func _build_codex_ui() -> void:
	var split_hbox := HBoxContainer.new()
	split_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_hbox.add_theme_constant_override("separation", C.SPACING_MD)
	body_container.add_child(split_hbox)

	# ── Left Pane: List of Codex Entries ─────────────────────────────────────
	var left_panel := PanelContainer.new()
	left_panel.theme_type_variation = &"InnerPanelContainer"
	left_panel.custom_minimum_size = Vector2(236, 0)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.add_child(left_panel)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", C.SPACING_XS)
	left_panel.add_child(left_vbox)

	tally_label = Label.new()
	tally_label.theme_type_variation = &"SectionHeaderLabel"
	left_vbox.add_child(tally_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(scroll)

	entry_list_vbox = VBoxContainer.new()
	entry_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry_list_vbox.add_theme_constant_override("separation", 3)
	scroll.add_child(entry_list_vbox)

	# ── Right Pane: Reading Pane ─────────────────────────────────────────────
	var right_panel := PanelContainer.new()
	right_panel.theme_type_variation = &"InnerPanelContainer"
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.add_child(right_panel)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	right_panel.add_child(right_vbox)

	detail_status_label = Label.new()
	detail_status_label.theme_type_variation = &"CaptionLabel"
	right_vbox.add_child(detail_status_label)

	detail_title_label = Label.new()
	detail_title_label.theme_type_variation = &"PanelHeaderLabel"
	detail_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_vbox.add_child(detail_title_label)

	detail_baybayin_label = Label.new()
	detail_baybayin_label.theme_type_variation = &"BaybayinLabel"
	right_vbox.add_child(detail_baybayin_label)

	var zig := TextureRect.new()
	zig.texture = load(C.TEX_DIVIDER_ZIGZAG)
	zig.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	zig.custom_minimum_size = Vector2(180, 7)
	right_vbox.add_child(zig)

	detail_lore_label = Label.new()
	detail_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_lore_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(detail_lore_label)


func refresh_entries() -> void:
	MetaProgression.load_meta()
	# Ensure starter act creatures are unlocked so codex shows both unlocked & locked ("???") entries
	if MetaProgression.unlocked_bestiary.is_empty():
		MetaProgression.unlocked_bestiary["aswang"] = true
		MetaProgression.unlocked_bestiary["corrupted_farmer"] = true
		MetaProgression.unlocked_bestiary["santelmo"] = true

	for c in entry_list_vbox.get_children():
		c.queue_free()
	entry_buttons.clear()

	var tex_unlocked: Texture2D = load(C.TEX_CODEX_UNLOCKED)
	var tex_locked: Texture2D = load(C.TEX_CODEX_LOCKED)
	var unlocked_count: int = 0

	for i in range(ENTRY_ORDER.size()):
		var cid: String = ENTRY_ORDER[i]
		var is_unlocked: bool = bool(MetaProgression.unlocked_bestiary.get(cid, false))
		if is_unlocked:
			unlocked_count += 1

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", C.SPACING_SM)
		entry_list_vbox.add_child(row)

		var icon_rect := TextureRect.new()
		icon_rect.texture = tex_unlocked if is_unlocked else tex_locked
		icon_rect.custom_minimum_size = Vector2(14, 14)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		row.add_child(icon_rect)

		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.clip_text = true
		if is_unlocked:
			var raw_name: String = str(MetaProgression.BESTIARY_DATA[cid]["name"])
			var paren := raw_name.find("(")
			btn.text = raw_name.substr(0, paren).strip_edges().to_upper() if paren > 0 else raw_name.to_upper()
		else:
			btn.text = "???"
		var idx := i
		btn.focus_entered.connect(func(): _select_entry(idx))
		btn.mouse_entered.connect(func(): btn.grab_focus())
		btn.pressed.connect(func(): _select_entry(idx))
		row.add_child(btn)
		entry_buttons.append(btn)

	tally_label.text = "CHRONICLE ENTRIES: %d / %d" % [unlocked_count, ENTRY_ORDER.size()]
	_select_entry(0)


func _select_entry(idx: int) -> void:
	selected_entry_idx = clampi(idx, 0, ENTRY_ORDER.size() - 1)
	var cid: String = ENTRY_ORDER[selected_entry_idx]
	var data: Dictionary = MetaProgression.BESTIARY_DATA.get(cid, {})
	var is_unlocked: bool = bool(MetaProgression.unlocked_bestiary.get(cid, false))

	if is_unlocked:
		detail_status_label.text = "[ DECIPHERED TABLET • ENTRY %02d ]" % (selected_entry_idx + 1)
		detail_title_label.text = str(data.get("name", cid)).to_upper()
		detail_baybayin_label.text = str(data.get("baybayin", ""))
		detail_lore_label.text = str(data.get("lore", ""))
	else:
		detail_status_label.text = "[ UNDECIPHERED TABLET • ENTRY %02d ]" % (selected_entry_idx + 1)
		detail_title_label.text = "???"
		detail_baybayin_label.text = "ᜃ᜔ ᜃ᜔ ᜃ᜔"
		detail_lore_label.text = "???: Encounter or vanquish this entity in the moonlit wilds of Ibalong to decipher its carved lore."


func on_screen_opened() -> void:
	refresh_entries()
	if not entry_buttons.is_empty() and is_instance_valid(entry_buttons[0]):
		entry_buttons[0].grab_focus()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_requested.emit()

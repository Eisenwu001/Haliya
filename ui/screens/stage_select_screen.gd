class_name HaliyaStageSelectScreen
extends "res://ui/components/haliya_panel_dialog.gd"

## HaliyaStageSelectScreen
## Displays stages as interactive nodes along a carved tribal path (with completed,
## unlocked, and locked states) paired with a right-side stage description panel.
## Inherits all styling from res://ui/theme/haliya_theme.tres.

signal stage_launched(level_idx: int)

const SaveManager = preload("res://scripts/save_manager.gd")
const MenuBtnScript = preload("res://ui/components/haliya_menu_button.gd")

const STAGES_DATA := [
	{
		"level_idx": -1,
		"code": "PROLOGUE",
		"title": "SACRED HOMESTEAD",
		"region": "Bicol Bamboo Clearing & Altar",
		"lore": "Hone the ancestral blade arts beneath the elder's guidance before entering the eclipsed canopy."
	},
	{
		"level_idx": 0,
		"code": "ACT I",
		"title": "WHISPERING CANOPY",
		"region": "Ancient Balete Forest • Level 1-1",
		"lore": "Moonlight filters through strangler figs where nocturnal Aswang stalk the mossy boughs."
	},
	{
		"level_idx": 1,
		"code": "ACT II",
		"title": "SENTRY RIDGE",
		"region": "Highland Cliffside • Level 1-2",
		"lore": "Uprooted stone monoliths and colossal forest brutes guard the ascent toward the terraces."
	},
	{
		"level_idx": 2,
		"code": "ACT III",
		"title": "BANAUE TERRACES",
		"region": "Flooded Rice Terraces • Level 1-3",
		"lore": "Drifting Santelmo spirit fires hover above the ancestral waters warped by the sixth eclipse."
	},
	{
		"level_idx": 3,
		"code": "ACT IV",
		"title": "LAPIS CAVERNS",
		"region": "Subterranean Depths • Level 1-4",
		"lore": "Crystalline echoes awaken terracotta bone sentinels deep beneath the volcanic roots."
	},
	{
		"level_idx": 4,
		"code": "ACT V",
		"title": "MAYON CROSSING",
		"region": "Volcanic Caldera Rim • Level 1-5",
		"lore": "Confront the vanguard of the abyssal serpent where ash and lunar fire collide."
	}
]

var selected_index: int = 0
var highest_unlocked_level: int = 1
var node_buttons: Array[Button] = []
var node_reticles: Array[TextureRect] = []
var node_icons: Array[TextureRect] = []

var status_badge_label: Label
var stage_code_label: Label
var stage_title_label: Label
var stage_region_label: Label
var stage_lore_label: Label
var embark_btn: HaliyaMenuButton


func _init() -> void:
	super._init()
	dialog_title = "STAGE SELECT"
	panel_size = Vector2(556, 316)
	_build_stage_select_ui()


func _build_stage_select_ui() -> void:
	var split_hbox := HBoxContainer.new()
	split_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_hbox.add_theme_constant_override("separation", C.SPACING_MD)
	body_container.add_child(split_hbox)

	# ── Left Pane: Carved Pilgrimage Path with Stage Nodes ───────────────────
	var path_panel := PanelContainer.new()
	path_panel.theme_type_variation = &"InnerPanelContainer"
	path_panel.custom_minimum_size = Vector2(276, 0)
	path_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.add_child(path_panel)

	var path_vbox := VBoxContainer.new()
	path_vbox.add_theme_constant_override("separation", 2)
	path_panel.add_child(path_vbox)

	var map_hdr := Label.new()
	map_hdr.text = "PILGRIMAGE PATH OF IBALONG"
	map_hdr.theme_type_variation = &"SectionHeaderLabel"
	path_vbox.add_child(map_hdr)

	var tex_path_seg: Texture2D = load(C.TEX_STAGE_PATH)
	var tex_sel_reticle: Texture2D = load(C.TEX_STAGE_SELECTED)

	for i in range(STAGES_DATA.size()):
		var st: Dictionary = STAGES_DATA[i]
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_BEGIN
		row.add_theme_constant_override("separation", C.SPACING_SM)
		path_vbox.add_child(row)

		# Stepped indentation along the carved path
		var indent := Control.new()
		indent.custom_minimum_size = Vector2(float((i % 2) * 14), 28)
		row.add_child(indent)

		# Node Holder (28x28) with Reticle + State Icon
		var node_holder := Control.new()
		node_holder.custom_minimum_size = Vector2(28, 28)
		row.add_child(node_holder)

		var icon_rect := TextureRect.new()
		icon_rect.position = Vector2(2, 2)
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		node_holder.add_child(icon_rect)
		node_icons.append(icon_rect)

		var reticle_rect := TextureRect.new()
		reticle_rect.texture = tex_sel_reticle
		reticle_rect.custom_minimum_size = Vector2(28, 28)
		reticle_rect.visible = false
		node_holder.add_child(reticle_rect)
		node_reticles.append(reticle_rect)

		# Carved path connector segment
		var seg_rect := TextureRect.new()
		seg_rect.texture = tex_path_seg
		seg_rect.custom_minimum_size = Vector2(20, 6)
		seg_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		row.add_child(seg_rect)

		# Frameless Stage Node Button
		var btn := Button.new()
		btn.text = "%s: %s" % [st["code"], st["title"]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx := i
		btn.focus_entered.connect(func(): _select_stage(idx))
		btn.mouse_entered.connect(func(): btn.grab_focus())
		btn.pressed.connect(func(): _activate_stage(idx))
		row.add_child(btn)
		node_buttons.append(btn)

	# ── Right Pane: Stage Description & Embark Action ────────────────────────
	var desc_panel := PanelContainer.new()
	desc_panel.theme_type_variation = &"InnerPanelContainer"
	desc_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_hbox.add_child(desc_panel)

	var desc_vbox := VBoxContainer.new()
	desc_vbox.add_theme_constant_override("separation", C.SPACING_SM)
	desc_panel.add_child(desc_vbox)

	status_badge_label = Label.new()
	status_badge_label.theme_type_variation = &"CaptionLabel"
	desc_vbox.add_child(status_badge_label)

	stage_code_label = Label.new()
	stage_code_label.theme_type_variation = &"SectionHeaderLabel"
	desc_vbox.add_child(stage_code_label)

	stage_title_label = Label.new()
	stage_title_label.theme_type_variation = &"PanelHeaderLabel"
	stage_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_vbox.add_child(stage_title_label)

	stage_region_label = Label.new()
	stage_region_label.theme_type_variation = &"SubtitleLabel"
	desc_vbox.add_child(stage_region_label)

	var zig := TextureRect.new()
	zig.texture = load(C.TEX_DIVIDER_ZIGZAG)
	zig.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	zig.custom_minimum_size = Vector2(180, 7)
	desc_vbox.add_child(zig)

	stage_lore_label = Label.new()
	stage_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_lore_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_vbox.add_child(stage_lore_label)

	embark_btn = MenuBtnScript.new()
	embark_btn.setup("EMBARK ON STAGE", C.MenuTier.MEDIUM)
	embark_btn.item_activated.connect(func(): _activate_stage(selected_index))
	desc_vbox.add_child(embark_btn)


func _refresh_node_states() -> void:
	highest_unlocked_level = 1
	for s in range(1, SaveManager.DEFAULT_SLOT_COUNT + 1):
		var meta := SaveManager.get_slot_metadata(s)
		if meta.get("exists", false):
			highest_unlocked_level = max(highest_unlocked_level, int(meta.get("highest_level_idx", 1)) + 1)

	var tex_completed: Texture2D = load(C.TEX_STAGE_COMPLETED)
	var tex_unlocked: Texture2D = load(C.TEX_STAGE_UNLOCKED)
	var tex_locked: Texture2D = load(C.TEX_STAGE_LOCKED)

	for i in range(STAGES_DATA.size()):
		var st: Dictionary = STAGES_DATA[i]
		var lvl: int = int(st["level_idx"])
		var state := _get_stage_state(lvl)
		if state == "completed":
			node_icons[i].texture = tex_completed
		elif state == "unlocked":
			node_icons[i].texture = tex_unlocked
		else:
			node_icons[i].texture = tex_locked


func _get_stage_state(lvl_idx: int) -> String:
	if lvl_idx < 0 or lvl_idx < highest_unlocked_level:
		return "completed"
	elif lvl_idx <= highest_unlocked_level + 1:
		return "unlocked"
	return "locked"


func _select_stage(idx: int) -> void:
	selected_index = clampi(idx, 0, STAGES_DATA.size() - 1)
	for i in range(node_reticles.size()):
		node_reticles[i].visible = (i == selected_index)

	var st: Dictionary = STAGES_DATA[selected_index]
	var state := _get_stage_state(int(st["level_idx"]))
	if state == "completed":
		status_badge_label.text = "[ COMPLETED SANCTUARY ]"
	elif state == "unlocked":
		status_badge_label.text = "[ UNLOCKED REALM ]"
	else:
		status_badge_label.text = "[ SEALED BY ECLIPSE — PLAYABLE ARCHIVE ]"

	stage_code_label.text = st["code"]
	stage_title_label.text = st["title"]
	stage_region_label.text = st["region"]
	stage_lore_label.text = st["lore"]


func _activate_stage(idx: int) -> void:
	var st: Dictionary = STAGES_DATA[clampi(idx, 0, STAGES_DATA.size() - 1)]
	stage_launched.emit(int(st["level_idx"]))


func on_screen_opened() -> void:
	_refresh_node_states()
	_select_stage(1) # Default to Act I: Whispering Canopy
	if node_buttons.size() > 1 and is_instance_valid(node_buttons[1]):
		node_buttons[1].grab_focus()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_requested.emit()

extends SceneTree

## Builds and saves the shared Godot Theme resource to res://ui/theme/haliya_theme.tres
## Uses ONE pixel font family (Silkscreen-Regular.ttf, OFL-1.1) across all UI text at
## different sizes with zero anti-aliasing, reduced letter spacing, clear word gaps,
## and high-contrast palette colors (>= 5.0:1 WCAG contrast).

const C = preload("res://ui/theme/ui_theme_constants.gd")

func _init() -> void:
	var theme := Theme.new()

	var f_ui: FontFile = load(C.PATH_FONT_UI)
	if f_ui:
		f_ui.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		f_ui.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		f_ui.hinting = TextServer.HINTING_NONE

	var f_baybayin: FontFile = load(C.PATH_FONT_BAYBAYIN)

	# Single font family variations: reduced letter-spacing (1px on primary, 0px on smaller)
	# with extra word spacing so word gaps ("BEGIN JOURNEY", "STAGE SELECT") are crystal clear.
	var fv_menu_primary := FontVariation.new()
	fv_menu_primary.base_font = f_ui
	fv_menu_primary.spacing_glyph = 2
	fv_menu_primary.spacing_space = 6

	var fv_menu_item := FontVariation.new()
	fv_menu_item.base_font = f_ui
	fv_menu_item.spacing_glyph = 0
	fv_menu_item.spacing_space = 3

	var fv_subtitle := FontVariation.new()
	fv_subtitle.base_font = f_ui
	fv_subtitle.spacing_glyph = 0
	fv_subtitle.spacing_space = 3

	var fv_caption := FontVariation.new()
	fv_caption.base_font = f_ui
	fv_caption.spacing_glyph = -1
	fv_caption.spacing_space = -1

	var fv_splash_title := FontVariation.new()
	fv_splash_title.base_font = f_ui
	fv_splash_title.spacing_glyph = 2
	fv_splash_title.spacing_space = 6

	theme.default_font = f_ui
	theme.default_font_size = C.FONT_SIZE_BODY

	# Store all typography sizes as theme constants on "HaliyaTypography"
	theme.set_constant("size_splash_title", "HaliyaTypography", C.FONT_SIZE_SPLASH_TITLE)
	theme.set_constant("size_primary", "HaliyaTypography", C.FONT_SIZE_PRIMARY)
	theme.set_constant("size_header", "HaliyaTypography", C.FONT_SIZE_HEADER)
	theme.set_constant("size_medium", "HaliyaTypography", C.FONT_SIZE_MEDIUM)
	theme.set_constant("size_small", "HaliyaTypography", C.FONT_SIZE_SMALL)
	theme.set_constant("size_subtitle", "HaliyaTypography", C.FONT_SIZE_SUBTITLE)
	theme.set_constant("size_status", "HaliyaTypography", C.FONT_SIZE_STATUS)
	theme.set_constant("size_caption", "HaliyaTypography", C.FONT_SIZE_CAPTION)
	theme.set_constant("size_muted", "HaliyaTypography", C.FONT_SIZE_MUTED)
	theme.set_constant("size_body", "HaliyaTypography", C.FONT_SIZE_BODY)
	theme.set_constant("size_tiny", "HaliyaTypography", C.FONT_SIZE_TINY)

	# ── 1. Base Label & Label Type Variations ────────────────────────────────
	theme.set_font("font", "Label", f_ui)
	theme.set_font_size("font_size", "Label", C.FONT_SIZE_BODY)
	theme.set_color("font_color", "Label", C.COLOR_BONE_CREAM)
	theme.set_color("font_shadow_color", "Label", C.COLOR_CHARCOAL_DEEP)
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	# SubtitleLabel ("Mask of Sorrows" — unified font family, brighter contrast, 10px)
	theme.set_type_variation("SubtitleLabel", "Label")
	theme.set_font("font", "SubtitleLabel", fv_subtitle)
	theme.set_font_size("font_size", "SubtitleLabel", C.FONT_SIZE_SUBTITLE)
	theme.set_color("font_color", "SubtitleLabel", C.COLOR_SUBTITLE_BRIGHT)

	# CaptionLabel ("Act 1 · Whispering Canopy" — 9px, high contrast, narrower than parent item)
	theme.set_type_variation("CaptionLabel", "Label")
	theme.set_font("font", "CaptionLabel", fv_caption)
	theme.set_font_size("font_size", "CaptionLabel", C.FONT_SIZE_CAPTION)
	theme.set_color("font_color", "CaptionLabel", C.COLOR_CAPTION_HIGH)

	# LoadingStatusLabel (Above the 8-moon phase loader — bone cream at 85%, 10px)
	theme.set_type_variation("LoadingStatusLabel", "Label")
	theme.set_font("font", "LoadingStatusLabel", fv_menu_item)
	theme.set_font_size("font_size", "LoadingStatusLabel", C.FONT_SIZE_STATUS)
	theme.set_color("font_color", "LoadingStatusLabel", C.COLOR_STATUS_TEXT)

	# LoadingPctLabel (Outside/below the 8-moon phase loader — small, high contrast, 9px)
	theme.set_type_variation("LoadingPctLabel", "Label")
	theme.set_font("font", "LoadingPctLabel", f_ui)
	theme.set_font_size("font_size", "LoadingPctLabel", C.FONT_SIZE_BODY)
	theme.set_color("font_color", "LoadingPctLabel", C.COLOR_BONE_CREAM)

	# PressStartLabel ("PRESS ANY KEY TO START" — bone cream, 12px)
	theme.set_type_variation("PressStartLabel", "Label")
	theme.set_font("font", "PressStartLabel", fv_subtitle)
	theme.set_font_size("font_size", "PressStartLabel", C.FONT_SIZE_HEADER)
	theme.set_color("font_color", "PressStartLabel", C.COLOR_BONE_CREAM)

	# SplashTitleLabel ("GROUP 2" — ~1.5x larger, 18px bone cream)
	theme.set_type_variation("SplashTitleLabel", "Label")
	theme.set_font("font", "SplashTitleLabel", fv_splash_title)
	theme.set_font_size("font_size", "SplashTitleLabel", C.FONT_SIZE_SPLASH_TITLE)
	theme.set_color("font_color", "SplashTitleLabel", C.COLOR_BONE_CREAM)

	# SplashSubLabel ("PRESENTS" — high contrast, 11px)
	theme.set_type_variation("SplashSubLabel", "Label")
	theme.set_font("font", "SplashSubLabel", fv_subtitle)
	theme.set_font_size("font_size", "SplashSubLabel", C.FONT_SIZE_MEDIUM)
	theme.set_color("font_color", "SplashSubLabel", C.COLOR_SUBTITLE_BRIGHT)

	# VersionLabel (bottom-left, tiny 8px, readable > 4.5:1 contrast)
	theme.set_type_variation("VersionLabel", "Label")
	theme.set_font("font", "VersionLabel", f_ui)
	theme.set_font_size("font_size", "VersionLabel", C.FONT_SIZE_TINY)
	theme.set_color("font_color", "VersionLabel", C.COLOR_VERSION_TEXT)

	# PanelHeaderLabel (Sub-screen main header — unified font family, 12px)
	theme.set_type_variation("PanelHeaderLabel", "Label")
	theme.set_font("font", "PanelHeaderLabel", fv_subtitle)
	theme.set_font_size("font_size", "PanelHeaderLabel", C.FONT_SIZE_HEADER)
	theme.set_color("font_color", "PanelHeaderLabel", C.COLOR_BONE_CREAM)

	# SectionHeaderLabel (Sub-header in high-contrast teal/bone, 10px)
	theme.set_type_variation("SectionHeaderLabel", "Label")
	theme.set_font("font", "SectionHeaderLabel", fv_menu_item)
	theme.set_font_size("font_size", "SectionHeaderLabel", C.FONT_SIZE_SMALL)
	theme.set_color("font_color", "SectionHeaderLabel", C.COLOR_TEAL_LIGHT)

	# MutedBodyLabel (9px, readable > 5.0:1 contrast)
	theme.set_type_variation("MutedBodyLabel", "Label")
	theme.set_font("font", "MutedBodyLabel", f_ui)
	theme.set_font_size("font_size", "MutedBodyLabel", C.FONT_SIZE_BODY)
	theme.set_color("font_color", "MutedBodyLabel", C.COLOR_BONE_MUTED)

	# LockedEntryLabel
	theme.set_type_variation("LockedEntryLabel", "Label")
	theme.set_font("font", "LockedEntryLabel", f_ui)
	theme.set_font_size("font_size", "LockedEntryLabel", C.FONT_SIZE_BODY)
	theme.set_color("font_color", "LockedEntryLabel", C.COLOR_SLATE_LIGHT)

	# BaybayinLabel
	theme.set_type_variation("BaybayinLabel", "Label")
	theme.set_font("font", "BaybayinLabel", f_baybayin)
	theme.set_font_size("font_size", "BaybayinLabel", 14)
	theme.set_color("font_color", "BaybayinLabel", C.COLOR_BONE_MUTED)

	# ── 2. Frameless Menu Buttons & Hierarchy Variations ─────────────────────
	var sb_empty := StyleBoxEmpty.new()
	sb_empty.content_margin_left = 0
	sb_empty.content_margin_right = 0
	sb_empty.content_margin_top = 0
	sb_empty.content_margin_bottom = 0
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme.set_stylebox(st, "Button", sb_empty)
	theme.set_font("font", "Button", fv_menu_item)
	theme.set_font_size("font_size", "Button", C.FONT_SIZE_SMALL)
	theme.set_color("font_color", "Button", C.COLOR_UNSELECTED_ITEM)
	theme.set_color("font_hover_color", "Button", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "Button", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "Button", C.COLOR_BONE_CREAM)
	theme.set_color("font_shadow_color", "Button", C.COLOR_CHARCOAL_DEEP)
	theme.set_constant("shadow_offset_x", "Button", 1)
	theme.set_constant("shadow_offset_y", "Button", 1)

	# Tier 1: MenuButtonPrimary ("Continue" / "Begin Journey" — 16px, largest & brightest)
	theme.set_type_variation("MenuButtonPrimary", "Button")
	theme.set_font("font", "MenuButtonPrimary", fv_menu_primary)
	theme.set_font_size("font_size", "MenuButtonPrimary", C.FONT_SIZE_PRIMARY)
	theme.set_color("font_color", "MenuButtonPrimary", C.COLOR_BONE_CREAM)
	theme.set_color("font_hover_color", "MenuButtonPrimary", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "MenuButtonPrimary", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "MenuButtonPrimary", C.COLOR_WARM_GOLD)

	# Tier 2: MenuButtonMedium ("Begin Journey", "Stage Select" — 11px, 74% opacity unselected)
	theme.set_type_variation("MenuButtonMedium", "Button")
	theme.set_font("font", "MenuButtonMedium", fv_menu_item)
	theme.set_font_size("font_size", "MenuButtonMedium", C.FONT_SIZE_MEDIUM)
	theme.set_color("font_color", "MenuButtonMedium", C.COLOR_UNSELECTED_ITEM)
	theme.set_color("font_hover_color", "MenuButtonMedium", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "MenuButtonMedium", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "MenuButtonMedium", C.COLOR_BONE_CREAM)

	# Tier 3: MenuButtonSmall ("Lore Codex", "Settings", "How to Play" — 10px, 74% opacity unselected)
	theme.set_type_variation("MenuButtonSmall", "Button")
	theme.set_font("font", "MenuButtonSmall", fv_menu_item)
	theme.set_font_size("font_size", "MenuButtonSmall", C.FONT_SIZE_SMALL)
	theme.set_color("font_color", "MenuButtonSmall", C.COLOR_UNSELECTED_ITEM)
	theme.set_color("font_hover_color", "MenuButtonSmall", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "MenuButtonSmall", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "MenuButtonSmall", C.COLOR_BONE_CREAM)

	# Tier 4: MenuButtonMuted ("Quit" — 9px, smallest menu item, muted yet > 5.0:1 contrast)
	theme.set_type_variation("MenuButtonMuted", "Button")
	theme.set_font("font", "MenuButtonMuted", fv_menu_item)
	theme.set_font_size("font_size", "MenuButtonMuted", C.FONT_SIZE_MUTED)
	theme.set_color("font_color", "MenuButtonMuted", C.COLOR_QUIT_MUTED)
	theme.set_color("font_hover_color", "MenuButtonMuted", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "MenuButtonMuted", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "MenuButtonMuted", C.COLOR_BONE_CREAM)

	# ActionButton (Sub-screen notched interactive button)
	var sb_inner := StyleBoxTexture.new()
	sb_inner.texture = load(C.TEX_PANEL_INNER)
	sb_inner.texture_margin_left = 8
	sb_inner.texture_margin_right = 8
	sb_inner.texture_margin_top = 8
	sb_inner.texture_margin_bottom = 8
	sb_inner.content_margin_left = 8
	sb_inner.content_margin_right = 8
	sb_inner.content_margin_top = 4
	sb_inner.content_margin_bottom = 4

	var sb_inner_hl := StyleBoxTexture.new()
	sb_inner_hl.texture = load(C.TEX_PANEL_INNER_HL)
	sb_inner_hl.texture_margin_left = 8
	sb_inner_hl.texture_margin_right = 8
	sb_inner_hl.texture_margin_top = 8
	sb_inner_hl.texture_margin_bottom = 8
	sb_inner_hl.content_margin_left = 8
	sb_inner_hl.content_margin_right = 8
	sb_inner_hl.content_margin_top = 4
	sb_inner_hl.content_margin_bottom = 4

	theme.set_type_variation("ActionButton", "Button")
	theme.set_stylebox("normal", "ActionButton", sb_inner)
	theme.set_stylebox("hover", "ActionButton", sb_inner_hl)
	theme.set_stylebox("focus", "ActionButton", sb_inner_hl)
	theme.set_stylebox("pressed", "ActionButton", sb_inner_hl)
	theme.set_font("font", "ActionButton", fv_menu_item)
	theme.set_font_size("font_size", "ActionButton", C.FONT_SIZE_BODY)
	theme.set_color("font_color", "ActionButton", C.COLOR_BONE_MUTED)
	theme.set_color("font_hover_color", "ActionButton", C.COLOR_WARM_GOLD)
	theme.set_color("font_focus_color", "ActionButton", C.COLOR_WARM_GOLD)
	theme.set_color("font_pressed_color", "ActionButton", C.COLOR_BONE_CREAM)

	# ── 3. Stepped Carved-Notch PanelContainer ───────────────────────────────
	var sb_panel := StyleBoxTexture.new()
	sb_panel.texture = load(C.TEX_PANEL_NOTCHED)
	sb_panel.texture_margin_left = 12
	sb_panel.texture_margin_right = 12
	sb_panel.texture_margin_top = 12
	sb_panel.texture_margin_bottom = 12
	sb_panel.content_margin_left = 14
	sb_panel.content_margin_right = 14
	sb_panel.content_margin_top = 12
	sb_panel.content_margin_bottom = 12
	theme.set_stylebox("panel", "PanelContainer", sb_panel)

	theme.set_type_variation("InnerPanelContainer", "PanelContainer")
	theme.set_stylebox("panel", "InnerPanelContainer", sb_inner)

	theme.set_type_variation("HighlightPanelContainer", "PanelContainer")
	theme.set_stylebox("panel", "HighlightPanelContainer", sb_inner_hl)

	# ── 4. HSlider, CheckBox, CheckButton & VScrollBar ───────────────────────
	var sb_slider_trk := StyleBoxTexture.new()
	sb_slider_trk.texture = load("res://assets/ui/slider_track.png")
	sb_slider_trk.texture_margin_left = 4
	sb_slider_trk.texture_margin_right = 4
	sb_slider_trk.texture_margin_top = 3
	sb_slider_trk.texture_margin_bottom = 3

	var sb_slider_fill := StyleBoxTexture.new()
	sb_slider_fill.texture = load("res://assets/ui/slider_fill.png")
	sb_slider_fill.texture_margin_left = 4
	sb_slider_fill.texture_margin_right = 4
	sb_slider_fill.texture_margin_top = 3
	sb_slider_fill.texture_margin_bottom = 3

	theme.set_stylebox("slider", "HSlider", sb_slider_trk)
	theme.set_stylebox("grabber_area", "HSlider", sb_slider_fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", sb_slider_fill)
	theme.set_icon("grabber", "HSlider", load("res://assets/ui/slider_grabber.png"))
	theme.set_icon("grabber_highlight", "HSlider", load("res://assets/ui/slider_grabber_hl.png"))

	var cb_off: Texture2D = load("res://assets/ui/checkbox_off.png")
	var cb_on: Texture2D = load("res://assets/ui/checkbox_on.png")
	for ctype in ["CheckBox", "CheckButton"]:
		theme.set_icon("unchecked", ctype, cb_off)
		theme.set_icon("checked", ctype, cb_on)
		theme.set_stylebox("normal", ctype, sb_empty)
		theme.set_stylebox("hover", ctype, sb_empty)
		theme.set_stylebox("pressed", ctype, sb_empty)
		theme.set_stylebox("focus", ctype, sb_empty)
		theme.set_font("font", ctype, f_ui)
		theme.set_font_size("font_size", ctype, C.FONT_SIZE_BODY)
		theme.set_color("font_color", ctype, C.COLOR_BONE_CREAM)
		theme.set_color("font_hover_color", ctype, C.COLOR_WARM_GOLD)
		theme.set_color("font_focus_color", ctype, C.COLOR_WARM_GOLD)
		theme.set_color("font_pressed_color", ctype, C.COLOR_BONE_CREAM)

	var sb_scroll_trk := StyleBoxTexture.new()
	sb_scroll_trk.texture = load("res://assets/ui/scroll_track.png")
	sb_scroll_trk.texture_margin_left = 2
	sb_scroll_trk.texture_margin_right = 2
	sb_scroll_trk.texture_margin_top = 4
	sb_scroll_trk.texture_margin_bottom = 4

	var sb_scroll_grb := StyleBoxTexture.new()
	sb_scroll_grb.texture = load("res://assets/ui/scroll_grabber.png")
	sb_scroll_grb.texture_margin_left = 2
	sb_scroll_grb.texture_margin_right = 2
	sb_scroll_grb.texture_margin_top = 4
	sb_scroll_grb.texture_margin_bottom = 4

	var sb_scroll_grb_hl := StyleBoxTexture.new()
	sb_scroll_grb_hl.texture = load("res://assets/ui/scroll_grabber_hl.png")
	sb_scroll_grb_hl.texture_margin_left = 2
	sb_scroll_grb_hl.texture_margin_right = 2
	sb_scroll_grb_hl.texture_margin_top = 4
	sb_scroll_grb_hl.texture_margin_bottom = 4

	theme.set_stylebox("scroll", "VScrollBar", sb_scroll_trk)
	theme.set_stylebox("grabber", "VScrollBar", sb_scroll_grb)
	theme.set_stylebox("grabber_highlight", "VScrollBar", sb_scroll_grb_hl)
	theme.set_stylebox("grabber_pressed", "VScrollBar", sb_scroll_grb_hl)

	var err := ResourceSaver.save(theme, C.PATH_THEME)
	if err == OK:
		print("[build_haliya_theme] Saved shared theme to ", C.PATH_THEME)
	else:
		push_error("[build_haliya_theme] Failed to save theme: " + str(err))
	quit()

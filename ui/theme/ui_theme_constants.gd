class_name UIThemeConstants
extends RefCounted

## UIThemeConstants
## Single source of truth for palette colors, typography sizes, spacing,
## hierarchy tiers, timing constants, and asset paths across the HALIYA UI system.
## All values match tools/generate_ui_assets.py and res://ui/theme/haliya_theme.tres.

# ── 1. Core Palette (Matches tools/generate_ui_assets.py PALETTE) ────────────
const COLOR_SLATE_BLUE: Color = Color("#3a4a5c")
const COLOR_CHARCOAL: Color = Color("#1e2420")
const COLOR_BONE_CREAM: Color = Color("#d8cfa8")
const COLOR_MUTED_TEAL: Color = Color("#3f6b66")
const COLOR_WARM_GOLD: Color = Color("#c9a24a") # Used ONLY for selection and title

# Derived High-Contrast Tints & Shades (All text colors >= 5.0:1 WCAG contrast on charcoal)
const COLOR_CHARCOAL_DEEP: Color = Color("#101412")
const COLOR_CHARCOAL_OVERLAY: Color = Color(0.063, 0.078, 0.071, 0.88)
const COLOR_SLATE_DARK: Color = Color("#27323f")
const COLOR_SLATE_LIGHT: Color = Color("#8c9695")
const COLOR_TEAL_DARK: Color = Color("#294642")
const COLOR_TEAL_LIGHT: Color = Color("#98b5a6")
const COLOR_BONE_MUTED: Color = Color("#a8a082")
const COLOR_SUBTITLE_BRIGHT: Color = Color(0.847, 0.812, 0.659, 0.88) # 88% bone cream
const COLOR_STATUS_TEXT: Color = Color(0.847, 0.812, 0.659, 0.85)     # 85% bone cream
const COLOR_CAPTION_HIGH: Color = Color("#b8c8be")                    # High-contrast bone-teal
const COLOR_UNSELECTED_ITEM: Color = Color(0.847, 0.812, 0.659, 0.74) # 74% bone cream (70-75% range)
const COLOR_QUIT_MUTED: Color = Color(0.847, 0.812, 0.659, 0.66)      # Muted Quit (> 5.0:1 contrast)
const COLOR_VERSION_TEXT: Color = Color(0.847, 0.812, 0.659, 0.62)    # Tiny bottom-left version (> 4.8:1)

# ── 2. Unified Pixel Font Sizes (Applied via haliya_theme.tres) ──────────────
const FONT_SIZE_SPLASH_TITLE: int = 24  # "GROUP 2" splash header (~1.5x larger)
const FONT_SIZE_PRIMARY: int = 22       # "Continue" / "Begin Journey"
const FONT_SIZE_HEADER: int = 12        # Sub-screen headers & "PRESS ANY KEY TO START"
const FONT_SIZE_MEDIUM: int = 12        # "Stage Select" / secondary medium buttons
const FONT_SIZE_SMALL: int = 10         # "Lore Codex", "Settings", "How to Play"
const FONT_SIZE_SUBTITLE: int = 10      # "Mask of Sorrows"
const FONT_SIZE_STATUS: int = 10        # Loading status copy above moon phase loader
const FONT_SIZE_CAPTION: int = 8        # "Act 1 · Whispering Canopy" (strictly narrower than parent item)
const FONT_SIZE_MUTED: int = 9          # "Quit" (smallest menu item, readable)
const FONT_SIZE_BODY: int = 9           # Sub-screen body copy & loader percentage
const FONT_SIZE_TINY: int = 8           # Bottom-left version text

# ── 3. Menu Hierarchy Tiers ──────────────────────────────────────────────────
enum MenuTier {
	PRIMARY, # "Continue" / "Begin Journey" — largest & brightest (16px)
	MEDIUM,  # "Stage Select" / secondary "Begin Journey" — medium (11px)
	SMALL,   # "Lore Codex", "Settings", "How to Play" — small (10px)
	MUTED    # "Quit" — smallest & most muted with extra top spacing (9px)
}

# ── 4. Layout, Spacing, Intro & Motion Constants ─────────────────────────────
const MENU_LEFT_EDGE_X: float = 26.0    # Shared left x edge for Title, Subtitle, Caption, Menu, Version
const MENU_BLOCK_TOP_Y: float = 48.0    # Vertically balanced top y for Title + Menu block
const MENU_ITEMS_OFFSET_Y: float = 68.0 # Distance from TitleLockup top to MenuVBox top

const SPACING_XS: int = 2
const SPACING_SM: int = 4
const SPACING_MD: int = 8
const SPACING_LG: int = 12
const SPACING_QUIT_TOP: int = 8

# Selector alignment & caption grouping constants (Polish Pass 2)
const SELECTOR_GAP_PRIMARY: int = 12  # Exact gap from crescent marker to large label left edge
const SELECTOR_GAP_MEDIUM: int = 8   # Scaled for medium tier
const SELECTOR_GAP_SMALL: int = 7    # Scaled for small tier
const SELECTOR_GAP_MUTED: int = 6    # Scaled for muted tier
const CAPTION_SEPARATION_PX: int = -4 # Produces exact 7px visual space (6-8px range) between label and caption text

const STAGGER_DELAY_SEC: float = 0.08        # 80ms staggered fade-in per menu item
const CRESCENT_FRAME_SEC: float = 0.14       # 2-frame snappy crescent selector cadence
const SLIDE_OFFSET_PX: float = 6.0           # Only the selected item slides right
const SPLASH_CARD_DURATION_SEC: float = 2.5  # 2.5s hold per studio card
const DISSOLVE_STEP_SEC: float = 0.088       # 8-step Bayer dither dissolve cadence (~0.70s in/out)
const LOADING_MIN_HOLD_SEC: float = 3.5      # Smooth ~3.5s loading progression across all 8 moons
const LOADING_MAX_HOLD_SEC: float = 4.2      # Maximum loading screen hold
const LOADING_COMPLETE_HOLD_SEC: float = 0.50 # 0.5s pause at 100% before dissolving to Title Screen
const PRESS_START_STEP_SEC: float = 0.28     # 4-step pulse cadence for "PRESS ANY KEY TO START"

# ── 5. Shared Theme & Asset Paths ────────────────────────────────────────────
const PATH_THEME: String = "res://ui/theme/haliya_theme.tres"
const PATH_FONT_UI: String = "res://assets/fonts/Silkscreen-Regular.ttf"
const PATH_FONT_BAYBAYIN: String = "res://assets/fonts/NotoSansTagalog-Regular.ttf"

# Generated Pixel-Art Sprites (replaceable with custom hand-drawn pixel art later)
const TEX_TITLE_HALIYA: String = "res://assets/ui/title_haliya.png"
const TEX_LEFT_GRADIENT: String = "res://assets/ui/menu_left_gradient.png"
const TEX_LOGS_PIXEL: String = "res://assets/ui/logs_production_pixel.png"
const TEX_CRESCENT_0: String = "res://assets/ui/crescent_sel_0.png"
const TEX_CRESCENT_1: String = "res://assets/ui/crescent_sel_1.png"
const TEX_DIVIDER_ZIGZAG: String = "res://assets/ui/divider_zigzag.png"
const TEX_DIVIDER_SPIRAL: String = "res://assets/ui/divider_spiral.png"
const TEX_SPIRAL_ACCENT: String = "res://assets/ui/spiral_accent.png"
const TEX_PANEL_NOTCHED: String = "res://assets/ui/panel_notched_9slice.png"
const TEX_PANEL_INNER: String = "res://assets/ui/panel_inner_9slice.png"
const TEX_PANEL_INNER_HL: String = "res://assets/ui/panel_inner_hl_9slice.png"
const TEX_STAGE_LOCKED: String = "res://assets/ui/stage_node_locked.png"
const TEX_STAGE_UNLOCKED: String = "res://assets/ui/stage_node_unlocked.png"
const TEX_STAGE_COMPLETED: String = "res://assets/ui/stage_node_completed.png"
const TEX_STAGE_SELECTED: String = "res://assets/ui/stage_node_selected.png"
const TEX_STAGE_PATH: String = "res://assets/ui/stage_path_segment.png"
const TEX_CODEX_UNLOCKED: String = "res://assets/ui/codex_icon_unlocked.png"
const TEX_CODEX_LOCKED: String = "res://assets/ui/codex_icon_locked.png"
const TEX_KEY_SM: String = "res://assets/ui/key_cap_sm.png"
const TEX_KEY_WIDE: String = "res://assets/ui/key_cap_wide.png"
const TEX_MOUSE_LMB: String = "res://assets/ui/mouse_lmb.png"
const TEX_MOUSE_RMB: String = "res://assets/ui/mouse_rmb.png"
const TEX_CURSOR: String = "res://assets/ui/cursor_arrow.png"

# Atmosphere Layers (Polish Pass 2 & 3)
const TEX_MIST_BAND_0: String = "res://assets/ui/menu_mist_band_0.png"
const TEX_MIST_BAND_1: String = "res://assets/ui/menu_mist_band_1.png"
const TEX_TOTEM_HALO: String = "res://assets/ui/totem_halo_dithered.png"

# Organic Pixel-Art Pipeline (Polish Pass 3 & Incoming Art Integration)
const TEX_TOTEM_SHRINE: String = "res://assets/art/totem_shrine.png"
const TEX_CORNER_FRONDS_LEFT: String = "res://assets/art/corner_fronds_left.png"
const TEX_CORNER_FRONDS_RIGHT: String = "res://assets/art/corner_fronds_right.png"
const TEX_HANGING_LEAVES: String = "res://assets/art/hanging_leaves.png"
const TEX_BOTTOM_FOLIAGE: String = "res://assets/art/bottom_foliage.png"
const TEX_FG_LEAVES_LEFT: String = "res://assets/art/corner_fronds_left.png"
const TEX_FG_LEAVES_RIGHT: String = "res://assets/art/corner_fronds_right.png"
const TEX_GROUND_MOUND: String = "res://assets/art/totem_shrine.png"
const TEX_OFFERINGS: String = "res://assets/art/totem_shrine.png"
const TEX_OFFERINGS_FLAME_0: String = "res://assets/art/offerings_flame_0.png"
const TEX_OFFERINGS_FLAME_1: String = "res://assets/art/offerings_flame_1.png"
const TEX_CHARMS: String = "res://assets/art/charms.png"
const TEX_FG_GROUND_STRIP: String = "res://assets/art/bottom_foliage.png"

const TEX_DISSOLVE_STEPS: Array[String] = [
	"res://assets/ui/dissolve_step_1.png",
	"res://assets/ui/dissolve_step_2.png",
	"res://assets/ui/dissolve_step_3.png",
	"res://assets/ui/dissolve_step_4.png",
	"res://assets/ui/dissolve_step_5.png",
	"res://assets/ui/dissolve_step_6.png",
	"res://assets/ui/dissolve_step_7.png",
	"res://assets/ui/dissolve_step_8.png",
]


static func get_moon_phase_texture_path(phase_idx: int, is_lit: bool) -> String:
	var clamped_idx: int = clampi(phase_idx, 0, 7)
	return "res://assets/ui/moon_phase_%d_%s.png" % [clamped_idx, "lit" if is_lit else "unlit"]


static func ensure_ui_input_actions() -> void:
	"""
	Ensures InputMap actions exist for full keyboard navigation (Arrows + WASD,
	Enter/Space confirm, Esc back) and default gameplay actions without hardcoding keys in UI screens.
	"""
	_add_key_to_action("ui_up", KEY_W)
	_add_key_to_action("ui_down", KEY_S)
	_add_key_to_action("ui_left", KEY_A)
	_add_key_to_action("ui_right", KEY_D)
	_add_key_to_action("ui_accept", KEY_ENTER)
	_add_key_to_action("ui_accept", KEY_KP_ENTER)
	_add_key_to_action("ui_accept", KEY_SPACE)
	_add_key_to_action("ui_cancel", KEY_ESCAPE)

	_add_key_to_action("move_left", KEY_A)
	_add_key_to_action("move_right", KEY_D)
	_add_key_to_action("jump", KEY_SPACE)
	_add_key_to_action("crouch", KEY_S)
	_add_key_to_action("attack", KEY_J)
	_add_key_to_action("guard", KEY_K)
	_add_key_to_action("dodge", KEY_C)
	_add_key_to_action("interact", KEY_E)


static func _add_key_to_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventKey and (ev.physical_keycode == keycode or ev.keycode == keycode):
			return
	var key_ev := InputEventKey.new()
	key_ev.keycode = keycode
	key_ev.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_ev)

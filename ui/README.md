# HALIYA: Mask of Sorrows — Pixel-Art UI System

This directory (`res://ui/`) contains the redesigned, pixel-perfect UI architecture for **HALIYA: Mask of Sorrows** (Godot 4.3+ / GDScript), inspired by Philippine/Southeast Asian tribal craft and carved stone/bone motifs.

---

## 1. Directory Structure

```text
res://
├── assets/
│   ├── fonts/
│   │   ├── PressStart2P-Regular.ttf     # OFL chunky display pixel font (Title)
│   │   ├── Silkscreen-Regular.ttf       # OFL readable pixel font (Body/Menu)
│   │   ├── Silkscreen-Bold.ttf          # OFL bold pixel font (Primary/Medium tiers)
│   │   └── LICENSES.md                  # Full SIL Open Font License 1.1 records
│   └── ui/                              # Procedurally generated pixel-art sprites
├── tools/
│   ├── generate_ui_assets.py            # Deterministic Python + Pillow sprite generator
│   └── build_haliya_theme.gd            # Headless Godot builder for haliya_theme.tres
└── ui/
    ├── theme/
    │   ├── ui_theme_constants.gd        # Palette, spacing, font sizes & InputMap setup
    │   └── haliya_theme.tres            # Single shared Godot Theme resource
    ├── components/
    │   ├── haliya_menu_button.gd/.tscn  # Frameless hierarchical button + 2-frame crescent
    │   └── haliya_panel_dialog.gd/.tscn # Translucent notched 9-slice sub-screen container
    └── screens/
        ├── screen_manager.gd            # Stepped transitions & focus restoration manager
        ├── main_menu_screen.tscn        # Main Menu screen
        ├── settings_screen.gd/.tscn     # Audio, Video & Controls (key-rebinding) screen
        ├── stage_select_screen.gd/.tscn # Carved path stage nodes + description pane
        ├── lore_codex_screen.gd/.tscn   # Entry list ("???" locked) + Baybayin reading pane
        ├── how_to_play_screen.gd/.tscn  # Paginated guide with pixel key/mouse icons
        └── quit_confirm_screen.gd/.tscn # Centered Yes/No confirmation dialog
```

---

## 2. How to Change the Palette & Regenerate Sprites

All colors live in **one single `PALETTE` dictionary** at the top of `tools/generate_ui_assets.py` (mirrored in `res://ui/theme/ui_theme_constants.gd` for theme building):

| Token | Hex | Role |
| :--- | :--- | :--- |
| `slate_blue` | `#3a4a5c` | Stepped panel borders, structural lines, locked glyphs |
| `charcoal` | `#1e2420` | Dithered Main Menu left gradient, translucent sub-screen fill |
| `bone_cream` | `#d8cfa8` | Primary text, carved highlights, `HALIYA` title body |
| `muted_teal` | `#3f6b66` | Slider fill, completed/unlocked accents, section headers |
| `warm_gold` | `#c9a24a` | **Selection and Title ONLY** (2-frame crescent, selected item/node, title top bevel) |

### Step-by-Step Regeneration
1. Edit the RGBA tuples in `PALETTE` at the top of `tools/generate_ui_assets.py` and the matching `Color(...)` constants in `res://ui/theme/ui_theme_constants.gd`.
2. Regenerate all pixel-art PNGs into `res://assets/ui/`:
   ```powershell
   python tools/generate_ui_assets.py
   ```
3. Rebuild the shared Godot theme (`res://ui/theme/haliya_theme.tres`):
   ```powershell
   godot --headless --path . --import
   godot --headless --path . -s res://tools/build_haliya_theme.gd
   ```

> **Replacing Generated Sprites with Hand-Drawn Pixel Art:**  
> Any generated PNG in `res://assets/ui/` can be replaced directly with custom hand-drawn pixel art of the same dimensions. Comments in `ui_theme_constants.gd`, `haliya_menu_button.gd`, and `haliya_panel_dialog.gd` mark the exact texture constants (`TEX_*`) and 9-slice margin sizes.

---

## 3. How to Add a New Sub-Screen

No UI scene may hardcode colors, fonts, or font sizes — all controls inherit automatically from `res://ui/theme/haliya_theme.tres`.

1. **Create the Script (`res://ui/screens/my_new_screen.gd`)** extending `"res://ui/components/haliya_panel_dialog.gd"`:
   ```gdscript
   class_name HaliyaMyNewScreen
   extends "res://ui/components/haliya_panel_dialog.gd"

   func _init() -> void:
       super._init()
       dialog_title = "MY NEW SCREEN"
       panel_size = Vector2(520, 290)
       _build_ui()

   func _build_ui() -> void:
       var title_lbl := Label.new()
       title_lbl.theme_type_variation = &"SectionHeaderLabel"
       title_lbl.text = "TRIBAL ARCHIVE"
       body_container.add_child(title_lbl)

   func on_screen_opened() -> void:
       # Grab initial focus when opened so keyboard navigation is seamless
       if is_instance_valid(back_button):
           back_button.grab_focus()
   ```
2. **Create the Scene (`res://ui/screens/my_new_screen.tscn`)** with `theme = ExtResource("res://ui/theme/haliya_theme.tres")` and `texture_filter = 1` (Nearest).
3. **Register in `MainMenu.setup_screen_manager()` (`res://scripts/main_menu.gd`)**:
   ```gdscript
   var my_scr = preload("res://ui/screens/my_new_screen.tscn").instantiate()
   screen_manager.register_screen("my_new_screen", my_scr)
   ```
4. **Open from any Menu Button**:
   ```gdscript
   screen_manager.open_screen("my_new_screen")
   ```
   `UIScreenManager` automatically handles the stepped pixel fade-in, audio hook signals (`sfx_confirm`, `sfx_back`), `Esc` cancellation, and restoring keyboard focus to the originating menu button on close.

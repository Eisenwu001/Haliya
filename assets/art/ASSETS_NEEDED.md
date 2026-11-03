# HALIYA Organic Art Assets Specification (Incoming Art Integration Pass)

This document catalogs all swappable organic pixel-art assets in `res://assets/art/`.
All incoming art from `res://assets/art/incoming/` has been processed through `tools/pixelate_import.py`, quantized to the 15-color master palette, cleaned of fringes/isolated speckles, and wired into Godot 4.3+ via exported `Texture2D` properties.

---

## Master Palette Reference
- **Charcoal** (`#1e2420`): Base silhouette shadow. Dark: `#151a17`, Light: `#2a342e`.
- **Slate Blue** (`#3a4a5c`): Atmospheric edge highlight. Dark: `#263240`, Light: `#52667c`.
- **Bone Cream** (`#d8cfa8`): Lunar highlights, flowers, stone highlights. Dark: `#b0a886`, Light: `#ece6cc`.
- **Muted Teal** (`#3f6b66`): Moss, foliage accents, carvings. Dark: `#2b4a46`, Light: `#59918b`.
- **Warm Gold** (`#c9a24a`): Lamp flames and sacred embers ONLY. Dark: `#9b7a32`, Light: `#e4c376`.

---

## Integrated Asset Catalog

### 1. `totem_shrine.png` (Active)
- **File**: `res://assets/art/totem_shrine.png`
- **Source**: `res://assets/art/incoming/totem_shrine.png`
- **Resolution**: 146 × 46 pixels (640×360 native)
- **Role**: Stone altar shrine with mossy cobblestone platform, roots, ritual clay lamps, offering bowls, and sampaguita flower garland.
- **Placement**: Flush under the totem base in `scenes/totem_surround.tscn` (`position = Vector2(0.0, 127.0)`), leaving $\ge 26$px clear bottom margin.
- **Constraints**: Flat top sits flush with the totem base so it looks planted; completely clear of the carved chest, crossed arms, and face.
- **Animation**: 3 flickering flame sprites (`offerings_flame_0.png` / `offerings_flame_1.png`) at `(3, 121)`, `(-17, 127)`, `(22, 127)` with warm glow overlay.

### 2. `corner_fronds_left.png` & `corner_fronds_right.png` (Active)
- **Files**: `res://assets/art/corner_fronds_left.png` and `res://assets/art/corner_fronds_right.png`
- **Source**: `res://assets/art/incoming/corner_fronds_left.png` (mirrored horizontally for right corner)
- **Resolution**: 134 × 88 pixels
- **Role**: Deep charcoal canopy fern fronds and banana leaves framing top-left and top-right screen corners.
- **Placement**: 
  - Left fronds: `Vector2(-20.0, -42.0)`, maintains $>3$px clearance above title at $y=48$.
  - Right fronds: `Vector2(target_w - 114.0, -42.0)`, maintains $>43$px clearance from the moon at $x=483$.
- **Animation**: 2-frame subtle stepped sway (1px offset, slow 0.9s cycle), frozen when `GameSettings.reduce_motion` is enabled.

### 3. `hanging_leaves.png` (Active)
- **File**: `res://assets/art/hanging_leaves.png`
- **Source**: `res://assets/art/incoming/hanging_leaves.png`
- **Resolution**: 160 × 76 pixels
- **Role**: Upper canopy foliage hanging between the left corner and the moon.
- **Placement**: `Vector2(round(target_w * 0.36), -12.0)` (`x = 230`), leaving 42px margin from the title on the left and 70px margin from the moon on the right.
- **Animation**: 2-frame subtle stepped sway, synchronized with corner fronds.

### 4. `bottom_foliage.png` (Active)
- **File**: `res://assets/art/bottom_foliage.png`
- **Source**: `res://assets/art/incoming/bottom_foliage.png`
- **Resolution**: 640 × 54 pixels
- **Role**: Full-width dense undergrowth framing the bottom of the screen.
- **Placement**: Flush with bottom edge (`position = Vector2(0.0, target_h - 54.0)`).
- **Z-Index Layering**: Drawn in `ForegroundFoliage` at `z_index = 4`, strictly behind `UILayer` (`z_index = 25`).
- **Readability**: Version label sits at `z_index = 2` inside `UILayer`, achieving 5.19:1 contrast over the dark foliage.

### 5. `charms.png` (Active)
- **File**: `res://assets/art/charms.png`
- **Resolution**: 26 × 12 pixels
- **Role**: Tribal braided neck collar with bone beads and ribbon tails.
- **Placement**: Anchored at the neck (`y = -47.0` in `TotemSurround`), completely clear of chest and arms.
- **Animation**: 4-step discrete sway (frozen when `reduce_motion = true`).

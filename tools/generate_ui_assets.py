#!/usr/bin/env python3
"""
Procedural True Pixel-Art UI Asset Generator for "HALIYA: Mask of Sorrows".
Deterministic and re-runnable. Uses ONLY the 5 core palette colors plus
programmatically derived tints/shades. Zero anti-aliasing, zero blur, hard pixel edges.
"""

import os
from PIL import Image, ImageDraw, ImageFont

# ============================================================================
# 1. MASTER PALETTE (Single source of truth for all UI colors)
# ============================================================================
PALETTE = {
    "slate_blue": (58, 74, 92, 255),      # #3a4a5c
    "charcoal": (30, 36, 32, 255),        # #1e2420
    "bone_cream": (216, 207, 168, 255),   # #d8cfa8
    "muted_teal": (63, 107, 102, 255),    # #3f6b66
    "warm_gold": (201, 162, 74, 255),     # #c9a24a (Selection & Title ONLY)
    "danger_red": (138, 59, 50, 255),     # #8a3b32 (Damage & Low Health)
}


def shade(rgba: tuple, factor: float) -> tuple:
    """Darkens a palette color deterministically (0.0 = black, 1.0 = original)."""
    return (
        max(0, min(255, int(round(rgba[0] * factor)))),
        max(0, min(255, int(round(rgba[1] * factor)))),
        max(0, min(255, int(round(rgba[2] * factor)))),
        rgba[3],
    )


def tint(rgba: tuple, factor: float) -> tuple:
    """Lightens a palette color toward bone_cream deterministically."""
    target = PALETTE["bone_cream"]
    return (
        max(0, min(255, int(round(rgba[0] + (target[0] - rgba[0]) * factor)))),
        max(0, min(255, int(round(rgba[1] + (target[1] - rgba[1]) * factor)))),
        max(0, min(255, int(round(rgba[2] + (target[2] - rgba[2]) * factor)))),
        rgba[3],
    )


def with_alpha(rgba: tuple, alpha: int) -> tuple:
    """Returns the palette color with a specific alpha (0..255)."""
    return (rgba[0], rgba[1], rgba[2], max(0, min(255, int(alpha))))


# Derived shades/tints from PALETTE
C_TRANSPARENT = (0, 0, 0, 0)
C_CHARCOAL_DEEP = shade(PALETTE["charcoal"], 0.55)       # #101412
C_CHARCOAL = PALETTE["charcoal"]                         # #1e2420
C_CHARCOAL_LIFT = tint(PALETTE["charcoal"], 0.10)        # #31352e
C_SLATE_DARK = shade(PALETTE["slate_blue"], 0.68)        # #27323f
C_SLATE = PALETTE["slate_blue"]                          # #3a4a5c
C_SLATE_LIGHT = tint(PALETTE["slate_blue"], 0.32)        # #6d7574
C_TEAL_DARK = shade(PALETTE["muted_teal"], 0.65)         # #294642
C_TEAL = PALETTE["muted_teal"]                           # #3f6b66
C_TEAL_LIGHT = tint(PALETTE["muted_teal"], 0.35)         # #758e7d
C_BONE_DARK = shade(PALETTE["bone_cream"], 0.54)         # #75705b
C_BONE_MUTED = shade(PALETTE["bone_cream"], 0.72)        # #9c9579
C_BONE = PALETTE["bone_cream"]                           # #d8cfa8
C_GOLD_DARK = shade(PALETTE["warm_gold"], 0.72)          # #917535
C_GOLD = PALETTE["warm_gold"]                            # #c9a24a

# Classic 4x4 Bayer ordered dithering matrix (normalized 0..15)
BAYER_4X4 = [
    [0,  8,  2, 10],
    [12, 4, 14,  6],
    [3, 11,  1,  9],
    [15, 7, 13,  5],
]

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DIR = os.path.join(PROJECT_ROOT, "assets", "ui")
FONTS_DIR = os.path.join(PROJECT_ROOT, "assets", "fonts")


def put_px(img: Image.Image, x: int, y: int, col: tuple) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), col)


def fill_rect(img: Image.Image, x0: int, y0: int, x1: int, y1: int, col: tuple) -> None:
    for y in range(max(0, y0), min(img.height, y1)):
        for x in range(max(0, x0), min(img.width, x1)):
            img.putpixel((x, y), col)


# ============================================================================
# 2. TITLE SPRITE ("HALIYA" — Carved Stone/Bone + Forehead Cracks + Teal Moss)
# ============================================================================
def generate_title_haliya() -> None:
    """
    Generates res://assets/ui/title_haliya.png (152x38).
    - Left-aligned at x=0 so its left edge matches all menu items exactly.
    - Chunky pixel lettering in bone cream (#d8cfa8).
    - Chiseled notches along letter edges.
    - Clearly visible hairline cracks echoing the totem mask's diagonal forehead crack.
    - Muted teal (#3f6b66) moss/wear tint at the base of letters.
    - 1px darker offset shadow (#101412).
    - Single deliberate warm gold (#c9a24a) crescent notch perched over the 'I' (no random gold on A/Y).
    """
    font_path = os.path.join(FONTS_DIR, "PressStart2P-Regular.ttf")
    raw_mask = Image.new("L", (200, 42), 0)
    draw = ImageDraw.Draw(raw_mask)
    if os.path.exists(font_path):
        font = ImageFont.truetype(font_path, 28)
        draw.text((0, 7), "HALIYA", fill=255, font=font)
    else:
        draw.text((0, 7), "HALIYA", fill=255)

    # Find exact horizontal bounds so first column of 'H' is at x=0
    raw_coords = set()
    min_x, max_x = 200, 0
    min_y, max_y = 42, 0
    for y in range(raw_mask.height):
        for x in range(raw_mask.width):
            if raw_mask.getpixel((x, y)) > 127:
                raw_coords.add((x, y))
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    glyph_coords = {(x - min_x, y) for (x, y) in raw_coords}
    span_w = (max_x - min_x + 1)
    w = span_w + 2  # +2px on right for 1px offset shadow
    h = 38
    img = Image.new("RGBA", (w, h), C_TRANSPARENT)

    # 1. Chiseled edge notches (cut into the outer silhouette of letters)
    chisel_cutouts = {
        # H left & right outer edge notches
        (0, 12), (0, 13), (1, 12),
        (19, 22), (19, 23), (18, 22),
        # First A left & right slope notches
        (28, 21), (28, 22), (47, 17), (47, 18),
        # L vertical stem & foot notch
        (56, 14), (56, 15), (57, 14), (69, 30), (70, 30),
        # I stem side chisel
        (88, 19), (88, 20), (103, 15), (103, 16),
        # Y upper arm & stem notch
        (112, 11), (112, 12), (122, 25), (122, 26),
        # Second A outer slope chisel
        (140, 20), (140, 21), (159, 23), (159, 24),
    }
    glyph_coords -= chisel_cutouts

    # 2. Prominent hairline cracks echoing the totem mask's diagonal forehead fissure
    crack_paths = [
        # H: deep diagonal fissure from top-right stem down-left across crossbar
        [
            (16, 7), (16, 8), (15, 9), (15, 10), (14, 11), (14, 12),
            (13, 13), (12, 14), (12, 15), (11, 16), (10, 17), (10, 18), (9, 19),
            (13, 11), (16, 13)  # small side fork like the totem forehead crack
        ],
        # First A: diagonal crack from apex down right leg
        [
            (37, 7), (37, 8), (38, 9), (38, 10), (39, 11), (40, 12),
            (40, 13), (41, 14), (41, 15), (42, 16), (43, 17), (43, 18)
        ],
        # L: stepped stone fracture near base corner
        [
            (59, 20), (60, 21), (60, 22), (61, 23), (62, 24), (62, 25), (63, 26)
        ],
        # I: vertical-diagonal forehead crack from top crown
        [
            (96, 7), (96, 8), (95, 9), (95, 10), (94, 11), (94, 12), (95, 13), (95, 14)
        ],
        # Y: diagonal fork fracture across center junction
        [
            (126, 11), (125, 12), (124, 13), (123, 14), (123, 15),
            (122, 16), (121, 17), (121, 18), (120, 19), (120, 20)
        ],
        # Second A: hairline fissure from upper-left shoulder across bar
        [
            (146, 10), (147, 11), (147, 12), (148, 13), (149, 14),
            (149, 15), (150, 16), (151, 17), (151, 18), (152, 19)
        ],
    ]
    crack_pixels = set()
    for path in crack_paths:
        for pt in path:
            if pt in glyph_coords:
                crack_pixels.add(pt)

    # 3. Draw 1px darker offset shadow (#101412)
    for (x, y) in glyph_coords:
        if (x, y) not in crack_pixels:
            put_px(img, x + 1, y + 1, C_CHARCOAL_DEEP)

    # 4. Draw carved bone-cream body with chiseled bevels, cracks, and base teal moss/wear
    for (x, y) in sorted(glyph_coords):
        if (x, y) in crack_pixels:
            # Deep carved fissure core in dark charcoal
            put_px(img, x, y, C_CHARCOAL_DEEP)
            continue

        dist_from_bottom = max_y - y
        is_top_edge = (x, y - 1) not in glyph_coords
        is_bottom_edge = (x, y + 1) not in glyph_coords
        is_left_edge = (x - 1, y) not in glyph_coords
        is_right_edge = (x + 1, y) not in glyph_coords
        near_crack = (
            (x - 1, y) in crack_pixels
            or (x, y - 1) in crack_pixels
            or (x + 1, y) in crack_pixels
            or (x, y + 1) in crack_pixels
        )
        near_chisel = (
            (x - 1, y) in chisel_cutouts
            or (x + 1, y) in chisel_cutouts
            or (x, y - 1) in chisel_cutouts
            or (x, y + 1) in chisel_cutouts
        )

        # Base moss/wear tint (muted teal #3f6b66 & dark teal at the bottom of letters)
        if is_bottom_edge:
            put_px(img, x, y, C_TEAL_DARK if (x % 2 == 0) else C_BONE_DARK)
        elif dist_from_bottom == 1:
            put_px(img, x, y, C_TEAL if ((x + y) % 2 == 0) else C_BONE_MUTED)
        elif dist_from_bottom == 2 and ((x * 3 + y) % 4 in (0, 1)):
            put_px(img, x, y, C_TEAL if (x % 3 == 0) else C_BONE_MUTED)
        elif dist_from_bottom == 3 and (x % 4 == 0):
            put_px(img, x, y, C_TEAL_LIGHT)
        elif near_chisel:
            # Chiseled notch bevel lip in muted bone
            put_px(img, x, y, C_BONE_MUTED)
        elif near_crack and ((x + y) % 2 == 0):
            # Subtle weathered stone lip beside hairline cracks (NO gold!)
            put_px(img, x, y, C_BONE_MUTED)
        elif is_top_edge:
            put_px(img, x, y, C_BONE)
        elif is_right_edge or is_left_edge:
            put_px(img, x, y, C_BONE_MUTED if (y % 3 == 0) else C_BONE)
        else:
            put_px(img, x, y, C_BONE)

    # 5. HALIYA title: Clean letter tops without any diacritic or mark over 'I'
    # (Per Polish Pass 2: removed crescent notch over 'I')
    img.save(os.path.join(OUT_DIR, "title_haliya.png"))


# ============================================================================
# 3. DITHERED LEFT-THIRD DARK GRADIENT & BAYER DISSOLVE FRAMES
# ============================================================================
def generate_menu_left_gradient() -> None:
    """
    260x360 pixel-art overlay for the left third of the Main Menu.
    Uses multi-step Bayer 4x4 ordered dithering from ~68% charcoal-black on the left
    to 0% transparent on the right, guaranteeing >= 4.5:1 contrast for all menu text.
    """
    w, h = 260, 360
    img = Image.new("RGBA", (w, h), C_TRANSPARENT)
    max_alpha = 176  # ~69% deep charcoal on the left edge for strong text contrast
    num_bands = 10

    for x in range(w):
        t = x / float(w - 1)
        exact_band = (1.0 - t) * num_bands
        band_low = int(exact_band)
        frac = exact_band - band_low
        alpha_low = int(round((band_low / float(num_bands)) * max_alpha))
        alpha_high = int(round((min(num_bands, band_low + 1) / float(num_bands)) * max_alpha))
        col_low = with_alpha(C_CHARCOAL_DEEP, alpha_low)
        col_high = with_alpha(C_CHARCOAL_DEEP, alpha_high)
        bx = x & 3
        for y in range(h):
            threshold = (BAYER_4X4[y & 3][bx] + 0.5) / 16.0
            img.putpixel((x, y), col_high if frac > threshold else col_low)

    img.save(os.path.join(OUT_DIR, "menu_left_gradient.png"))


def generate_dissolve_frames() -> None:
    """
    Generates 8 stepped Bayer 4x4 pixel-dissolve tile textures (64x64, binary alpha 0 or 255,
    zero smooth alpha ramp) in 12.5% increments for smooth pixel-dissolve transitions.
    """
    thresholds = [2, 4, 6, 8, 10, 12, 14, 16]  # 8 steps from 12.5% to 100% opaque pixels per 4x4 block
    for idx, thresh in enumerate(thresholds, start=1):
        img = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        for y in range(64):
            for x in range(64):
                bval = BAYER_4X4[y & 3][x & 3]
                if bval < thresh:
                    img.putpixel((x, y), C_CHARCOAL_DEEP)
        img.save(os.path.join(OUT_DIR, f"dissolve_step_{idx}.png"))


# ============================================================================
# 4. PIXELATED BONE-CREAM STUDIO LOGO (Log's Production)
# ============================================================================
def generate_logs_production_pixel_logo() -> None:
    """
    Reads assets/ui/logs_production_original.png, crops to the logo bounds,
    pixelates it at native pixel resolution (280x92) with hard binary thresholding
    (zero anti-aliasing), and tints all logo pixels to bone cream (#d8cfa8).
    Preserves the exact brand logo design while matching the pixel-art UI.
    """
    orig_path = os.path.join(OUT_DIR, "logs_production_original.png")
    target_w, target_h = 280, 92
    out_img = Image.new("RGBA", (target_w, target_h), C_TRANSPARENT)

    if os.path.exists(orig_path):
        src = Image.open(orig_path).convert("L")
        # Find tight bounding box of dark ink pixels (< 180)
        min_x, min_y = src.width, src.height
        max_x, max_y = 0, 0
        for y in range(src.height):
            for x in range(src.width):
                if src.getpixel((x, y)) < 180:
                    if x < min_x:
                        min_x = x
                    if x > max_x:
                        max_x = x
                    if y < min_y:
                        min_y = y
                    if y > max_y:
                        max_y = y

        if max_x > min_x and max_y > min_y:
            cropped = src.crop((min_x, min_y, max_x + 1, max_y + 1))
            # Fit inside (target_w - 8) x (target_h - 8) preserving exact aspect ratio
            avail_w = target_w - 8
            avail_h = target_h - 8
            scale = min(avail_w / float(cropped.width), avail_h / float(cropped.height))
            rw = max(1, int(round(cropped.width * scale)))
            rh = max(1, int(round(cropped.height * scale)))
            # Area-average downsample then hard threshold for crisp 1-bit pixel art
            resized = cropped.resize((rw, rh), Image.Resampling.BILINEAR)
            ox = (target_w - rw) // 2
            oy = (target_h - rh) // 2

            logo_pts = set()
            for y in range(rh):
                for x in range(rw):
                    if resized.getpixel((x, y)) < 165:
                        logo_pts.add((ox + x, oy + y))

            # 1px deep charcoal shadow + bone cream (#d8cfa8) pixel body
            for (px, py) in logo_pts:
                put_px(out_img, px + 1, py + 1, C_CHARCOAL_DEEP)
            for (px, py) in logo_pts:
                put_px(out_img, px, py, C_BONE)

    out_img.save(os.path.join(OUT_DIR, "logs_production_pixel.png"))
    out_img.save(os.path.join(OUT_DIR, "logs_production_dark.png"))


# ============================================================================
# 5. CRESCENT SELECTOR (2 Frames — Snappy Tribal Crescent Moon)
# ============================================================================
def generate_crescent_selectors() -> None:
    for frame in (0, 1):
        img = Image.new("RGBA", (14, 14), C_TRANSPARENT)
        ox = 1 if frame == 1 else 0

        crescent_body = [
            (5, 2), (6, 2), (7, 2),
            (3, 3), (4, 3), (5, 3), (8, 3),
            (2, 4), (3, 4), (4, 4),
            (2, 5), (3, 5),
            (2, 6), (3, 6),
            (2, 7), (3, 7),
            (2, 8), (3, 8), (4, 8),
            (3, 9), (4, 9), (5, 9), (8, 9),
            (5, 10), (6, 10), (7, 10),
        ]
        for (x, y) in crescent_body:
            put_px(img, x + ox + 1, y + 1, C_CHARCOAL_DEEP)
        for (x, y) in crescent_body:
            put_px(img, x + ox, y, C_GOLD)
        for (x, y) in [(7, 2), (8, 3), (3, 5), (3, 6), (3, 7), (8, 9), (7, 10)]:
            put_px(img, x + ox, y, C_BONE if frame == 1 else C_GOLD)

        if frame == 0:
            put_px(img, 7 + ox, 6, C_GOLD_DARK)
        else:
            put_px(img, 7 + ox, 6, C_BONE)
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                put_px(img, 7 + ox + dx, 6 + dy, C_GOLD)

        img.save(os.path.join(OUT_DIR, f"crescent_sel_{frame}.png"))


# ============================================================================
# 6. UNIFIED TOTEM DIVIDERS (Zigzag with Center Crescent/Spiral Ornament)
# ============================================================================
def generate_dividers() -> None:
    """
    Generates the unified zigzag divider (160x9) starting at x=0 with a small
    carved crescent/spiral ornament at its exact center (x=80), used identically
    in the reusable HaliyaTitleLockup on both the Title screen and Main Menu.
    """
    w, h = 160, 9
    zig = Image.new("RGBA", (w, h), C_TRANSPARENT)
    mid = w // 2  # 80
    cy = 4

    # Left and right sawtooth zigzag arms flanking the center ornament
    for x in range(3, w - 3):
        if abs(x - mid) <= 7:
            continue
        phase = x % 6
        dy = (phase - 1) if phase <= 3 else (5 - phase)  # oscillates -1, 0, 1, 2, 1, 0
        y = cy - 1 + dy
        put_px(zig, x + 1, y + 1, C_CHARCOAL_DEEP)
        put_px(zig, x, y, C_BONE if abs(x - mid) < 56 else C_BONE_MUTED)

    # Left & right carved notch terminals at x=0..2 and x=w-3..w-1
    for dx, dy in [(0, cy), (1, cy - 1), (1, cy + 1), (2, cy)]:
        put_px(zig, dx + 1, dy + 1, C_CHARCOAL_DEEP)
        put_px(zig, dx, dy, C_BONE)
        rx = (w - 1) - dx
        put_px(zig, rx + 1, dy + 1, C_CHARCOAL_DEEP)
        put_px(zig, rx, dy, C_BONE_MUTED)

    # Center carved crescent + spiral ornament (at x = mid, y = cy)
    ornament_bone = [
        (-5, 0), (5, 0),
        (-3, -1), (-3, 0), (-3, 1),
        (-2, -2), (-2, 2),
        (-1, -3), (0, -3), (1, -3),
        (-1, 3), (0, 3), (1, 3),
        (2, -2), (2, 2),
        (3, -1), (3, 1),
    ]
    ornament_gold = [
        (0, -1), (-1, 0), (0, 0), (1, 0), (0, 1),
    ]
    for (dx, dy) in ornament_bone + ornament_gold:
        put_px(zig, mid + dx + 1, cy + dy + 1, C_CHARCOAL_DEEP)
    for (dx, dy) in ornament_bone:
        put_px(zig, mid + dx, cy + dy, C_BONE)
    for (dx, dy) in ornament_gold:
        put_px(zig, mid + dx, cy + dy, C_GOLD)

    zig.save(os.path.join(OUT_DIR, "divider_zigzag.png"))

    # B. Spiral Divider for Sub-Screen Headers (220x11)
    sw, sh = 220, 11
    spir = Image.new("RGBA", (sw, sh), C_TRANSPARENT)
    smid = sw // 2
    scy = sh // 2

    for x in range(12, smid - 10):
        col = C_BONE_MUTED if (x % 4 != 0) else C_CHARCOAL_DEEP
        put_px(spir, x, scy, col)
        put_px(spir, sw - 1 - x, scy, col)
    for ex in (10, sw - 11):
        put_px(spir, ex, scy - 1, C_SLATE_LIGHT)
        put_px(spir, ex, scy + 1, C_SLATE_LIGHT)

    spiral_pts = [
        (0, 0), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0), (-1, 1), (-1, 2),
        (0, 2), (1, 2), (2, 2), (3, 1), (3, 0), (3, -1), (2, -2), (1, -3),
        (0, -3), (-1, -3), (-2, -2), (-3, -1), (-3, 0), (-3, 1), (-2, 3),
        (-1, 4), (0, 4), (1, 4), (2, 4), (4, 2), (4, 0),
    ]
    for dx, dy in spiral_pts:
        put_px(spir, smid + dx + 1, scy + dy + 1, C_CHARCOAL_DEEP)
    for dx, dy in spiral_pts:
        put_px(spir, smid + dx, scy + dy, C_BONE)

    spir.save(os.path.join(OUT_DIR, "divider_spiral.png"))

    # C. Standalone 16x16 Spiral Accent
    acc = Image.new("RGBA", (16, 16), C_TRANSPARENT)
    acx, acy = 7, 7
    for dx, dy in spiral_pts:
        put_px(acc, acx + dx + 1, acy + dy + 1, C_CHARCOAL_DEEP)
    for dx, dy in spiral_pts:
        put_px(acc, acx + dx, acy + dy, C_GOLD if abs(dx) <= 1 and abs(dy) <= 1 else C_BONE)
    acc.save(os.path.join(OUT_DIR, "spiral_accent.png"))


# ============================================================================
# 7. MOON PHASE LOADER SPRITES (8 Pixel Moons — Lit & Unlit States)
# ============================================================================
def generate_moon_phases() -> None:
    """
    Generates 8 pixel-art moon phase sprites (18x18 each) in both lit (bone cream #d8cfa8
    lit side, charcoal #1e2420 / slate #3a4a5c dark side) and unlit (recessed charcoal/slate)
    states for the 8-moon sequential phase loader:
      0: New Moon (eclipsed charcoal disc with bone-cream corona rim)
      1: Waxing Crescent
      2: First Quarter
      3: Waxing Gibbous
      4: Full Moon
      5: Waning Gibbous
      6: Third Quarter
      7: Waning Crescent
    """
    size = 18
    cx, cy = 8.5, 8.5
    r_outer = 7.2
    r_inner = 5.8

    for phase_idx in range(8):
        for is_lit in (True, False):
            img = Image.new("RGBA", (size, size), C_TRANSPARENT)

            for y in range(size):
                for x in range(size):
                    dx = (x - cx)
                    dy = (y - cy)
                    dist_sq = dx * dx + dy * dy
                    if dist_sq > r_outer * r_outer:
                        continue

                    # 1px offset drop shadow
                    put_px(img, min(size - 1, x + 1), min(size - 1, y + 1), C_CHARCOAL_DEEP)

            for y in range(size):
                for x in range(size):
                    dx = (x - cx)
                    dy = (y - cy)
                    dist_sq = dx * dx + dy * dy
                    if dist_sq > r_outer * r_outer:
                        continue

                    is_rim = dist_sq > r_inner * r_inner

                    # Determine whether this pixel is on the illuminated side for phase_idx
                    # using curved spherical terminators for crescents and gibbous phases
                    lit_pixel = False
                    if phase_idx == 0:
                        # New moon: dark charcoal core with thin bone-cream eclipse corona rim
                        lit_pixel = is_rim
                    elif phase_idx == 1:
                        # Waxing crescent: curved crescent on the right
                        shadow_dist_sq = (dx + 2.8) ** 2 + dy * dy
                        lit_pixel = (dx > -1.0) and (shadow_dist_sq >= 6.2 * 6.2)
                    elif phase_idx == 2:
                        # First quarter: right half
                        lit_pixel = (dx >= 0.0)
                    elif phase_idx == 3:
                        # Waxing gibbous: curved bulge on the left
                        lit_dist_sq = (dx - 2.6) ** 2 + dy * dy
                        lit_pixel = (dx >= 0.0) or (lit_dist_sq <= 6.2 * 6.2)
                    elif phase_idx == 4:
                        # Full moon: entire disc lit in bone cream
                        lit_pixel = True
                    elif phase_idx == 5:
                        # Waning gibbous: left 3/4 with curved bulge on right
                        lit_dist_sq = (dx + 2.6) ** 2 + dy * dy
                        lit_pixel = (dx <= 0.0) or (lit_dist_sq <= 6.2 * 6.2)
                    elif phase_idx == 6:
                        # Third quarter: left half
                        lit_pixel = (dx <= 0.0)
                    elif phase_idx == 7:
                        # Waning crescent: curved crescent on the left
                        shadow_dist_sq = (dx - 2.8) ** 2 + dy * dy
                        lit_pixel = (dx < 1.0) and (shadow_dist_sq >= 6.2 * 6.2)

                    if not is_lit:
                        # Unlit waiting slot: slate rim + slate-dark phase silhouette so all 8 moons
                        # are clearly discernible at 0% before filling in with bone cream
                        if is_rim:
                            put_px(img, x, y, C_SLATE_LIGHT if lit_pixel else C_SLATE)
                        else:
                            put_px(img, x, y, C_SLATE_DARK if lit_pixel else C_CHARCOAL_DEEP)
                    else:
                        # Lit active moon: bone cream lit side, charcoal/slate dark side (no gold!)
                        if lit_pixel:
                            if is_rim:
                                put_px(img, x, y, C_BONE)
                            else:
                                is_crater = (phase_idx in (3, 4, 5)) and ((x, y) in {(6, 6), (10, 7), (7, 11)})
                                put_px(img, x, y, C_BONE_MUTED if is_crater else C_BONE)
                        else:
                            put_px(img, x, y, C_SLATE if is_rim else C_CHARCOAL)

            suffix = "lit" if is_lit else "unlit"
            img.save(os.path.join(OUT_DIR, f"moon_phase_{phase_idx}_{suffix}.png"))


# ============================================================================
# 8. STEPPED CARVED-NOTCH 9-SLICE PANELS
# ============================================================================
def generate_notched_panels() -> None:
    w, h = 48, 48
    img = Image.new("RGBA", (w, h), C_TRANSPARENT)
    bg_fill = with_alpha(C_CHARCOAL_DEEP, 224)

    for y in range(2, h - 2):
        for x in range(2, w - 2):
            if (x < 4 or x >= w - 4) and (y < 4 or y >= h - 4):
                continue
            img.putpixel((x, y), bg_fill)

    for y in range(4, h - 4):
        for x in range(4, w - 4):
            if (x in (4, w - 5) or y in (4, h - 5)) and ((x + y) % 2 == 0):
                img.putpixel((x, y), with_alpha(C_CHARCOAL, 235))

    for x in range(4, w - 4):
        if x in (10, w - 11):
            put_px(img, x, 2, C_BONE_MUTED)
            put_px(img, x, h - 3, C_SLATE)
        else:
            put_px(img, x, 1, C_BONE_MUTED)
            put_px(img, x, 2, C_CHARCOAL_DEEP)
            put_px(img, x, h - 2, C_SLATE)
            put_px(img, x, h - 3, C_CHARCOAL_DEEP)

    for y in range(4, h - 4):
        if y in (10, h - 11):
            put_px(img, 2, y, C_BONE_MUTED)
            put_px(img, w - 3, y, C_SLATE)
        else:
            put_px(img, 1, y, C_SLATE_LIGHT)
            put_px(img, 2, y, C_CHARCOAL_DEEP)
            put_px(img, w - 2, y, C_SLATE)
            put_px(img, w - 3, y, C_CHARCOAL_DEEP)

    corners = [
        [(2, 3), (3, 3), (3, 2), (5, 4), (4, 5)],
        [(w - 3, 3), (w - 4, 3), (w - 4, 2), (w - 6, 4), (w - 5, 5)],
        [(2, h - 4), (3, h - 4), (3, h - 3), (5, h - 5), (4, h - 6)],
        [(w - 3, h - 4), (w - 4, h - 4), (w - 4, h - 3), (w - 6, h - 5), (w - 5, h - 6)],
    ]
    for c_pts in corners:
        for (cx, cy) in c_pts[:3]:
            put_px(img, cx, cy, C_BONE_MUTED)
        for (cx, cy) in c_pts[3:]:
            put_px(img, cx, cy, C_TEAL)

    img.save(os.path.join(OUT_DIR, "panel_notched_9slice.png"))

    iw, ih = 32, 32
    inner = Image.new("RGBA", (iw, ih), C_TRANSPARENT)
    inner_fill = with_alpha(C_CHARCOAL, 195)
    for y in range(1, ih - 1):
        for x in range(1, iw - 1):
            if (x in (1, iw - 2)) and (y in (1, ih - 2)):
                continue
            inner.putpixel((x, y), inner_fill)

    for x in range(2, iw - 2):
        put_px(inner, x, 1, C_SLATE if x not in (6, iw - 7) else C_CHARCOAL_DEEP)
        put_px(inner, x, ih - 2, C_SLATE_DARK if x not in (6, iw - 7) else C_CHARCOAL_DEEP)
    for y in range(2, ih - 2):
        put_px(inner, 1, y, C_SLATE if y not in (6, ih - 7) else C_CHARCOAL_DEEP)
        put_px(inner, iw - 2, y, C_SLATE_DARK if y not in (6, ih - 7) else C_CHARCOAL_DEEP)

    inner_hl = inner.copy()
    for x in range(2, iw - 2):
        put_px(inner_hl, x, 1, C_BONE_MUTED if x not in (6, iw - 7) else C_TEAL)
        put_px(inner_hl, x, ih - 2, C_TEAL)
    for y in range(2, ih - 2):
        put_px(inner_hl, 1, y, C_BONE_MUTED if y not in (6, ih - 7) else C_TEAL)
        put_px(inner_hl, iw - 2, y, C_TEAL)

    inner.save(os.path.join(OUT_DIR, "panel_inner_9slice.png"))
    inner_hl.save(os.path.join(OUT_DIR, "panel_inner_hl_9slice.png"))


# ============================================================================
# 9. SLIDER, CHECKBOX & SCROLLBAR PIECES
# ============================================================================
def generate_controls_widgets() -> None:
    tw, th = 120, 8
    track = Image.new("RGBA", (tw, th), C_TRANSPARENT)
    fill_rect(track, 1, 2, tw - 1, th - 2, C_CHARCOAL_DEEP)
    for x in range(1, tw - 1):
        put_px(track, x, 1, C_SLATE_DARK)
        put_px(track, x, th - 2, C_SLATE)
        if x % 12 == 0:
            put_px(track, x, 2, C_SLATE_DARK)
    for y in range(2, th - 2):
        put_px(track, 0, y, C_SLATE)
        put_px(track, tw - 1, y, C_SLATE)
    track.save(os.path.join(OUT_DIR, "slider_track.png"))

    sfill = Image.new("RGBA", (tw, th), C_TRANSPARENT)
    fill_rect(sfill, 1, 2, tw - 1, th - 2, C_TEAL)
    for x in range(1, tw - 1):
        put_px(sfill, x, 2, C_TEAL_LIGHT if (x % 2 == 0) else C_TEAL)
        put_px(sfill, x, th - 3, C_TEAL_DARK)
        if x % 8 == 0:
            put_px(sfill, x, 3, C_TEAL_DARK)
    sfill.save(os.path.join(OUT_DIR, "slider_fill.png"))

    for is_hl, fname in [(False, "slider_grabber.png"), (True, "slider_grabber_hl.png")]:
        gw, gh = 10, 14
        grab = Image.new("RGBA", (gw, gh), C_TRANSPARENT)
        border_c = C_GOLD if is_hl else C_BONE
        body_c = C_CHARCOAL_LIFT if is_hl else C_CHARCOAL
        fill_rect(grab, 2, 1, gw - 2, gh - 1, body_c)
        for x in range(2, gw - 2):
            put_px(grab, x, 0, border_c)
            put_px(grab, x, gh - 1, C_CHARCOAL_DEEP)
            put_px(grab, x, gh - 2, border_c)
        for y in range(1, gh - 2):
            put_px(grab, 1, y, border_c if y != gh // 2 else C_CHARCOAL_DEEP)
            put_px(grab, gw - 2, y, border_c if y != gh // 2 else C_CHARCOAL_DEEP)
        for y in range(4, gh - 5):
            put_px(grab, gw // 2 - 1, y, border_c)
            put_px(grab, gw // 2, y, C_CHARCOAL_DEEP)
        grab.save(os.path.join(OUT_DIR, fname))

    for is_on, fname in [(False, "checkbox_off.png"), (True, "checkbox_on.png")]:
        cw, ch = 14, 14
        cb = Image.new("RGBA", (cw, ch), C_TRANSPARENT)
        fill_rect(cb, 2, 2, cw - 2, ch - 2, C_CHARCOAL_DEEP)
        rim = C_BONE if is_on else C_SLATE_LIGHT
        for i in range(2, cw - 2):
            put_px(cb, i, 1, rim)
            put_px(cb, i, ch - 2, C_SLATE if not is_on else C_TEAL)
            put_px(cb, 1, i, rim)
            put_px(cb, cw - 2, i, C_SLATE if not is_on else C_TEAL)
        if is_on:
            fill_rect(cb, 4, 4, cw - 4, ch - 4, C_TEAL_DARK)
            check_pts = [
                (3, 7), (4, 8), (5, 9), (6, 10), (7, 8), (8, 6), (9, 5), (10, 4),
                (4, 7), (5, 8), (6, 9), (7, 7), (8, 5), (9, 4)
            ]
            for (px, py) in check_pts:
                put_px(cb, px, py, C_GOLD if py <= 7 else C_BONE)
        cb.save(os.path.join(OUT_DIR, fname))

    strk = Image.new("RGBA", (8, 32), C_TRANSPARENT)
    fill_rect(strk, 2, 1, 6, 31, C_CHARCOAL_DEEP)
    for y in range(1, 31):
        put_px(strk, 1, y, C_SLATE_DARK)
        put_px(strk, 6, y, C_SLATE_DARK)
    strk.save(os.path.join(OUT_DIR, "scroll_track.png"))

    for is_hl, fname in [(False, "scroll_grabber.png"), (True, "scroll_grabber_hl.png")]:
        sgrb = Image.new("RGBA", (8, 16), C_TRANSPARENT)
        c_main = C_GOLD if is_hl else C_TEAL_LIGHT
        fill_rect(sgrb, 2, 1, 6, 15, c_main)
        for y in (6, 8, 10):
            put_px(sgrb, 3, y, C_CHARCOAL_DEEP)
            put_px(sgrb, 4, y, C_CHARCOAL_DEEP)
        sgrb.save(os.path.join(OUT_DIR, fname))


# ============================================================================
# 10. STAGE-NODE ICONS, CODEX ICONS, KEY-PROMPT ICONS & CURSOR
# ============================================================================
def generate_stage_nodes() -> None:
    for state in ("locked", "unlocked", "completed"):
        w, h = 24, 24
        node = Image.new("RGBA", (w, h), C_TRANSPARENT)
        cx, cy = 12, 12

        if state == "locked":
            outer_c = C_SLATE_DARK
            inner_c = C_CHARCOAL_DEEP
            glyph_c = C_SLATE
        elif state == "unlocked":
            outer_c = C_TEAL_LIGHT
            inner_c = C_CHARCOAL
            glyph_c = C_BONE
        else:
            outer_c = C_BONE
            inner_c = C_TEAL_DARK
            glyph_c = C_BONE

        for y in range(3, h - 3):
            for x in range(3, w - 3):
                dist = abs(x - cx) + abs(y - cy)
                if dist <= 12:
                    put_px(node, x + 1, y + 1, C_CHARCOAL_DEEP)
        for y in range(3, h - 3):
            for x in range(3, w - 3):
                dist = abs(x - cx) + abs(y - cy)
                if dist == 12 or dist == 11:
                    put_px(node, x, y, outer_c)
                elif dist < 11:
                    put_px(node, x, y, inner_c)

        if state == "locked":
            for d in range(-3, 4):
                put_px(node, cx + d, cy + d, glyph_c)
                put_px(node, cx + d, cy - d, glyph_c)
        elif state == "unlocked":
            for dx, dy in [(0, -3), (-1, -2), (1, -2), (-2, -1), (2, -1), (-3, 0), (3, 0), (-2, 1), (2, 1), (-1, 2), (1, 2), (0, 3), (0, 0)]:
                put_px(node, cx + dx, cy + dy, glyph_c)
        else:
            for dx, dy in [(-4, -2), (-3, -1), (-3, 0), (-2, 1), (-1, 2), (0, 2), (1, 2), (2, 1), (3, 0), (3, -1), (4, -2), (0, -2)]:
                put_px(node, cx + dx, cy + dy, C_GOLD if dy >= 0 else C_BONE)

        node.save(os.path.join(OUT_DIR, f"stage_node_{state}.png"))

    sel = Image.new("RGBA", (28, 28), C_TRANSPARENT)
    for ox, oy, sx, sy in [(1, 1, 1, 1), (26, 1, -1, 1), (1, 26, 1, -1), (26, 26, -1, -1)]:
        for i in range(6):
            put_px(sel, ox + sx * i, oy, C_GOLD)
            put_px(sel, ox, oy + sy * i, C_GOLD)
        put_px(sel, ox + sx * 2, oy + sy * 2, C_BONE)
    sel.save(os.path.join(OUT_DIR, "stage_node_selected.png"))

    path_seg = Image.new("RGBA", (32, 6), C_TRANSPARENT)
    for x in range(0, 32):
        if (x // 4) % 2 == 0:
            put_px(path_seg, x, 2, C_BONE_MUTED)
            put_px(path_seg, x, 3, C_SLATE)
            put_px(path_seg, x, 4, C_CHARCOAL_DEEP)
        else:
            put_px(path_seg, x, 3, C_CHARCOAL)
    path_seg.save(os.path.join(OUT_DIR, "stage_path_segment.png"))


def generate_codex_and_prompt_icons() -> None:
    for unlocked, fname in [(True, "codex_icon_unlocked.png"), (False, "codex_icon_locked.png")]:
        ic = Image.new("RGBA", (14, 14), C_TRANSPARENT)
        border = C_BONE if unlocked else C_SLATE
        fill = C_TEAL_DARK if unlocked else C_CHARCOAL_DEEP
        fill_rect(ic, 2, 1, 12, 13, fill)
        for x in range(3, 11):
            put_px(ic, x, 1, border)
            put_px(ic, x, 12, border)
        for y in range(2, 12):
            put_px(ic, 2, y, border)
            put_px(ic, 11, y, border)
        if unlocked:
            put_px(ic, 5, 4, C_GOLD)
            put_px(ic, 8, 4, C_GOLD)
            for x in range(4, 10):
                put_px(ic, x, 7, C_BONE)
            for x in range(5, 9):
                put_px(ic, x, 9, C_BONE_MUTED)
        else:
            for px, py in [(6, 4), (7, 4), (8, 5), (7, 6), (6, 7), (6, 9)]:
                put_px(ic, px, py, C_SLATE_LIGHT)
        ic.save(os.path.join(OUT_DIR, fname))

    for kw, fname in [(18, "key_cap_sm.png"), (38, "key_cap_wide.png")]:
        kh = 18
        kc = Image.new("RGBA", (kw, kh), C_TRANSPARENT)
        fill_rect(kc, 1, 3, kw - 1, kh - 1, C_CHARCOAL_DEEP)
        fill_rect(kc, 1, 1, kw - 1, kh - 3, C_CHARCOAL)
        for x in range(2, kw - 2):
            put_px(kc, x, 1, C_BONE)
            put_px(kc, x, kh - 4, C_SLATE)
            put_px(kc, x, kh - 3, C_SLATE_DARK)
        for y in range(2, kh - 3):
            put_px(kc, 1, y, C_BONE_MUTED)
            put_px(kc, kw - 2, y, C_SLATE)
        kc.save(os.path.join(OUT_DIR, fname))

    for btn_side, fname in [("left", "mouse_lmb.png"), ("right", "mouse_rmb.png")]:
        mw, mh = 16, 20
        ms = Image.new("RGBA", (mw, mh), C_TRANSPARENT)
        fill_rect(ms, 3, 2, 13, 17, C_CHARCOAL)
        if btn_side == "left":
            fill_rect(ms, 3, 2, 8, 9, C_GOLD)
        else:
            fill_rect(ms, 8, 2, 13, 9, C_GOLD)
        for x in range(4, 12):
            put_px(ms, x, 1, C_BONE)
            put_px(ms, x, 9, C_CHARCOAL_DEEP)
            put_px(ms, x, 17, C_BONE_MUTED)
        for y in range(3, 17):
            put_px(ms, 2, y, C_BONE if y < 9 and btn_side == "left" else C_SLATE_LIGHT)
            put_px(ms, 13, y, C_BONE if y < 9 and btn_side == "right" else C_SLATE_LIGHT)
        for y in range(2, 9):
            put_px(ms, 7, y, C_CHARCOAL_DEEP)
            put_px(ms, 8, y, C_CHARCOAL_DEEP)
        ms.save(os.path.join(OUT_DIR, fname))

    cur = Image.new("RGBA", (16, 16), C_TRANSPARENT)
    for y in range(1, 13):
        for x in range(1, min(12, y + 2)):
            if x + y <= 14:
                put_px(cur, x + 1, y + 1, C_CHARCOAL_DEEP)
    for y in range(1, 12):
        for x in range(1, min(11, y + 1)):
            if x + y <= 13:
                if x == 1 or y == 1 or x == y or x + y == 13:
                    put_px(cur, x, y, C_BONE)
                else:
                    put_px(cur, x, y, C_GOLD if (x <= 3 and y <= 4) else C_CHARCOAL)
    put_px(cur, 1, 1, C_GOLD)
    cur.save(os.path.join(OUT_DIR, "cursor_arrow.png"))


def generate_in_game_progress_bars() -> None:
    def make_notched_bar(w: int, h: int, pad_x: int, pad_y: int) -> Image.Image:
        bar = Image.new("RGBA", (w, h), C_TRANSPARENT)
        fill_rect(bar, 1, 1, w - 1, h - 1, with_alpha(C_CHARCOAL_DEEP, 235))
        for x in range(2, w - 2):
            put_px(bar, x, 1, C_BONE_MUTED if x % 16 != 0 else C_CHARCOAL_DEEP)
            put_px(bar, x, h - 2, C_SLATE)
        for y in range(2, h - 2):
            put_px(bar, 1, y, C_BONE_MUTED)
            put_px(bar, w - 2, y, C_SLATE)
        fill_rect(bar, pad_x, pad_y, w - pad_x, h - pad_y, C_CHARCOAL_DEEP)
        for x in range(pad_x - 1, w - pad_x + 1):
            put_px(bar, x, pad_y - 1, C_SLATE)
            put_px(bar, x, h - pad_y, C_SLATE_DARK)
        return bar

    def make_woven_fill(w: int, h: int) -> Image.Image:
        fimg = Image.new("RGBA", (w, h), C_TRANSPARENT)
        for y in range(h):
            for x in range(w):
                is_weave = ((x + y * 2) % 4 == 0)
                col = C_TEAL_LIGHT if is_weave else C_TEAL
                if y == 0:
                    col = C_BONE_MUTED
                elif y == h - 1:
                    col = C_TEAL_DARK
                fimg.putpixel((x, y), col)
        return fimg

    make_notched_bar(240, 20, 10, 5).save(os.path.join(OUT_DIR, "progress_track_frame.png"))
    make_woven_fill(220, 10).save(os.path.join(OUT_DIR, "progress_track_fill.png"))


# ============================================================================
# 13. POLISH PASS 2: BACKGROUND ATMOSPHERE ASSETS (Dithered Pixel Art Only)
# ============================================================================
def generate_ground_mist_bands() -> None:
    """
    Generates 2 seamless Bayer-dithered ground mist bands (640x52) for subtle
    parallax floating near the bottom third. Very low opacity (12-20%), soft
    slate-teal tint, left-side attenuation so menu text stays 100% legible.
    """
    import math

    w, h = 640, 52
    col_mist = (48, 72, 76)  # Dark muted slate-teal

    for band_idx, speed_mult in [(0, 1.0), (1, 1.4)]:
        img = Image.new("RGBA", (w, h), C_TRANSPARENT)
        for y in range(h):
            # Vertical envelope: smooth rise and fall inside band
            y_norm = y / float(h - 1)
            vert_env = math.sin(y_norm * math.pi)

            for x in range(w):
                # Harmonic wave for seamless horizontal looping
                wave = (
                    math.sin(x * 2.0 * math.pi / 320.0 + band_idx * 1.5) * 0.4
                    + math.sin(x * 4.0 * math.pi / 640.0 + band_idx * 3.1) * 0.3
                    + math.sin(x * 6.0 * math.pi / 640.0) * 0.15
                    + 0.5
                )
                dens = vert_env * (0.35 + 0.65 * wave)

                # Keep mist very subtle on the left side (x < 260) to protect menu legibility
                if x < 260:
                    left_factor = max(0.2, (x / 260.0) ** 1.3)
                    dens *= left_factor

                max_a = 42 if band_idx == 0 else 34  # ~13-16% max alpha
                target_alpha = dens * max_a
                # 4x4 Bayer dither thresholding
                bval = BAYER_4X4[y & 3][x & 3] / 16.0
                norm_a = target_alpha / 255.0
                if norm_a > bval * 0.22:
                    out_a = min(255, int(round(target_alpha * 2.2)))
                    if out_a > 10:
                        img.putpixel((x, y), (col_mist[0], col_mist[1], col_mist[2], out_a))

        img.save(os.path.join(OUT_DIR, f"menu_mist_band_{band_idx}.png"))


def generate_foreground_silhouettes() -> None:
    """
    Generates foreground silhouettes in near-black charcoal (#141815) framing the scene:
    1. Dark fern/cogon grass/leaf strip along the bottom edge (640x36, 2 sway frames)
    2. Hanging canopy vines/leaves at top-left (120x84, 2 sway frames)
    3. Hanging canopy vines/leaves at top-right (130x84, 2 sway frames)
    """
    import math

    col_fg = (18, 22, 20, 255)       # Charcoal deep silhouette #121614
    col_fg_soft = (28, 34, 30, 255)  # Subtle rim edge

    # 1. Ground strip (640x36) - 2 sway frames
    gw, gh = 640, 36
    for frame in (0, 1):
        gimg = Image.new("RGBA", (gw, gh), C_TRANSPARENT)
        sway_dir = 1 if frame == 1 else -1

        # Solid ground base at bottom (last 8px)
        for y in range(gh - 8, gh):
            for x in range(gw):
                gimg.putpixel((x, y), col_fg)

        # Procedural blades of grass and fern fronds across the 640px span
        for x in range(0, gw, 3):
            # Deterministic variation by x
            seed_val = math.sin(x * 12.9898) * 43758.5453
            frac = seed_val - math.floor(seed_val)
            blade_h = int(14 + frac * 18)  # Blade heights 14..32px
            curve = (frac - 0.5) * 4.0

            # Sway deflection affects blade tips
            tip_sway = sway_dir * (1 if frac > 0.4 else 0)

            for by in range(blade_h):
                py = (gh - 8) - by
                if py < 0:
                    break
                t = by / float(blade_h)
                px = int(round(x + curve * t + tip_sway * (t ** 2)))
                if 0 <= px < gw:
                    gimg.putpixel((px, py), col_fg)
                    # Thicker base
                    if by < blade_h * 0.6 and px + 1 < gw:
                        gimg.putpixel((px + 1, py), col_fg)

        gimg.save(os.path.join(OUT_DIR, f"menu_fg_ground_strip_{frame}.png"))

    # 2. Hanging vines top-left (120x84) - 2 sway frames
    vw, vh = 120, 84
    for frame in (0, 1):
        vimg = Image.new("RGBA", (vw, vh), C_TRANSPARENT)
        sway = 1 if frame == 1 else 0

        # Solid ceiling mass
        for y in range(0, 12):
            for x in range(0, vw - y * 4):
                vimg.putpixel((x, y), col_fg)

        # 4 hanging vine strands
        vine_roots = [(16, 68), (38, 54), (62, 74), (88, 42)]
        for (vx, max_len) in vine_roots:
            curve = math.sin(vx) * 3.0
            for vy in range(10, max_len):
                if vy >= vh:
                    break
                t = (vy - 10) / float(max_len - 10)
                px = int(round(vx + curve * t + sway * t))
                if 0 <= px < vw:
                    vimg.putpixel((px, vy), col_fg)
                    if px + 1 < vw:
                        vimg.putpixel((px + 1, vy), col_fg)
                    # Leaf clusters along vine
                    if vy % 8 in (0, 1):
                        for lx in (-2, -1, 2, 3):
                            if 0 <= px + lx < vw:
                                vimg.putpixel((px + lx, vy), col_fg)

        vimg.save(os.path.join(OUT_DIR, f"menu_fg_vines_left_{frame}.png"))

    # 3. Hanging vines top-right (130x84) - 2 sway frames
    rw, rh = 130, 84
    for frame in (0, 1):
        rimg = Image.new("RGBA", (rw, rh), C_TRANSPARENT)
        sway = -1 if frame == 1 else 0

        # Solid ceiling mass at upper right
        for y in range(0, 12):
            for x in range(y * 4, rw):
                rimg.putpixel((x, y), col_fg)

        vine_roots = [(32, 52), (60, 72), (86, 60), (108, 76)]
        for (vx, max_len) in vine_roots:
            curve = math.cos(vx) * 3.0
            for vy in range(10, max_len):
                if vy >= rh:
                    break
                t = (vy - 10) / float(max_len - 10)
                px = int(round(vx + curve * t + sway * t))
                if 0 <= px < rw:
                    rimg.putpixel((px, vy), col_fg)
                    if px + 1 < rw:
                        rimg.putpixel((px + 1, vy), col_fg)
                    if vy % 7 in (0, 1):
                        for lx in (-2, -1, 2, 3):
                            if 0 <= px + lx < rw:
                                rimg.putpixel((px + lx, vy), col_fg)

        rimg.save(os.path.join(OUT_DIR, f"menu_fg_vines_right_{frame}.png"))


def generate_moonlight_shafts() -> None:
    """
    Generates faint, dithered diagonal light shafts (340x260) from moon through canopy.
    Very low opacity (6-14%), soft lunar silver-cream, Bayer 4x4 dithering.
    """
    import math

    w, h = 340, 260
    img = Image.new("RGBA", (w, h), C_TRANSPARENT)
    col_shaft = (216, 212, 195)  # Lunar bone-silver

    # 3 diagonal shaft center-lines slanting down-left at ~28 degrees
    # y = tan(theta) * (x - x0) -> slope ~ 0.8
    shafts = [
        {"x0": 260, "width": 46, "alpha": 26},
        {"x0": 190, "width": 38, "alpha": 20},
        {"x0": 120, "width": 30, "alpha": 16},
    ]

    for y in range(h):
        for x in range(w):
            total_dens = 0.0
            for s in shafts:
                # Center of this shaft at line y
                # Slants from top-right towards bottom-left
                center_x = s["x0"] - y * 0.55
                dist = abs(x - center_x)
                half_w = s["width"] * 0.5
                if dist < half_w:
                    # Cosine falloff across shaft width
                    falloff = math.cos((dist / half_w) * (math.pi / 2.0))
                    # Subtle vertical fade near bottom
                    vert_fade = max(0.2, 1.0 - (y / float(h)) * 0.45)
                    total_dens += falloff * vert_fade * (s["alpha"] / 255.0)

            if total_dens > 0.005:
                # 4x4 Bayer dither thresholding
                bval = (BAYER_4X4[y & 3][x & 3] + 0.5) / 16.0
                if total_dens > bval * 0.12:
                    out_a = min(255, int(round(total_dens * 255.0 * 1.6)))
                    if out_a > 4:
                        img.putpixel((x, y), (col_shaft[0], col_shaft[1], col_shaft[2], out_a))

    img.save(os.path.join(OUT_DIR, "menu_moon_shafts.png"))


def generate_totem_halo() -> None:
    """
    Generates a soft Bayer-dithered radial halo behind the totem (220x220).
    Muted teal tinted (#3f6b66), low opacity (~18%), separating totem from forest.
    """
    w, h = 220, 220
    img = Image.new("RGBA", (w, h), C_TRANSPARENT)
    cx, cy = w // 2, h // 2
    max_radius = 96.0
    col_halo = (63, 107, 102)  # Muted teal #3f6b66

    for y in range(h):
        for x in range(w):
            dx = x - cx
            dy = y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist < max_radius:
                norm_d = dist / max_radius
                # Soft cosine curve
                import math
                dens = math.cos(norm_d * (math.pi / 2.0)) ** 1.8
                max_alpha = 46  # ~18% max alpha
                target_a = dens * max_alpha

                bval = (BAYER_4X4[y & 3][x & 3] + 0.5) / 16.0
                if (target_a / 255.0) > bval * 0.20:
                    out_a = min(255, int(round(target_a * 1.9)))
                    if out_a > 6:
                        img.putpixel((x, y), (col_halo[0], col_halo[1], col_halo[2], out_a))

    img.save(os.path.join(OUT_DIR, "totem_halo_dithered.png"))


# ============================================================================
# 15. PLAYER STATUS HUD SUITE (Cluster Bayer Dithered Dark Gradient)
# ============================================================================
def generate_hud_cluster_bg() -> None:
    # Cluster Bayer Dithered Dark Gradient (170x95 px) to cover HP, Shield, and Stamina
    gw, gh = 170, 95
    gimg = Image.new("RGBA", (gw, gh), C_TRANSPARENT)
    for y in range(gh):
        for x in range(gw):
            norm_x = x / float(gw)
            norm_y = y / float(gh)
            fade_x = max(0.0, 1.0 - norm_x ** 1.3)
            fade_y = max(0.0, 1.0 - norm_y ** 1.3)
            dens = fade_x * fade_y
            max_alpha = 180
            target_a = dens * max_alpha

            bval = (BAYER_4X4[y & 3][x & 3] + 0.5) / 16.0
            if (target_a / 255.0) > bval * 0.40:
                out_a = min(220, int(round(target_a * 1.3)))
                if out_a > 12:
                    gimg.putpixel((x, y), (16, 20, 18, out_a))
    gimg.save(os.path.join(OUT_DIR, "hud_cluster_bg_gradient.png"))


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    generate_title_haliya()
    generate_menu_left_gradient()
    generate_dissolve_frames()
    generate_logs_production_pixel_logo()
    generate_crescent_selectors()
    generate_dividers()
    generate_moon_phases()
    generate_notched_panels()
    generate_controls_widgets()
    generate_stage_nodes()
    generate_codex_and_prompt_icons()
    generate_in_game_progress_bars()
    generate_ground_mist_bands()
    generate_totem_halo()
    generate_hud_cluster_bg()
    print(f"[generate_ui_assets] Successfully generated all pixel-art UI sprites in {OUT_DIR}")
    print(f"[generate_ui_assets] Successfully generated all pixel-art UI sprites in {OUT_DIR}")


if __name__ == "__main__":
    main()

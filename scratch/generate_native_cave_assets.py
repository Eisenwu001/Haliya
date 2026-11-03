"""
Native 1:1 Pixel-Art Generator for Subterranean Cavern Assets
Generates:
1. assets/cave_platformer/cave_rock_tiles.png (256x128)
2. assets/cave_platformer/cave_platforms.png (256x160)
3. assets/cave_platformer/cave_props.png (256x160)

Guarantees:
- 100% native 1:1 pixel grid (no Lanczos/bilinear downsampling blur or fringe halos)
- Color palette sampled directly from assets/Cave/BG-Parallax (Layer 9 midnight slate, Layer 7 deep teal, Layer 1 luminescent cyan)
- Zero-gap platform design: walking deck begins EXACTLY at y = 0 to prevent floating collision
- Crisp pixel-art chains, natural stalactite teeth, and authentic Hollow Knight-style pogo spikes and crystals
"""

import math
import random
import os
from PIL import Image, ImageDraw

random.seed(1337)

# ── Color Palette (Sampled Directly from Cave Parallax BG Layers 1, 7 & 9) ─────
C_VOID        = (2, 20, 34, 255)       # Deepest ambient cavern shadow
C_BEDROCK_0   = (4, 38, 60, 255)       # Layer 9 base dark bedrock slate
C_BEDROCK_1   = (4, 46, 68, 255)       # Layer 9 mid slate
C_BEDROCK_2   = (6, 56, 82, 255)       # Slate strata layer
C_BEDROCK_3   = (10, 72, 104, 255)     # Lighter slate stratum
C_BEDROCK_4   = (14, 92, 126, 255)     # Chiseled stone edge
C_RIM_TEAL    = (24, 120, 158, 255)    # Layer 7 near-stalactite rim highlight
C_RIM_CYAN    = (48, 180, 215, 255)    # Specular rim light from cavern god rays
C_RIM_BRIGHT  = (120, 235, 255, 255)   # Intense crystal glint / sharp needle edge

# Resonant Cyan Crystal & Bioluminescence (Layer 1 & 3fx)
C_CRYS_DEEP   = (10, 64, 102, 255)
C_CRYS_MID    = (0, 140, 204, 255)
C_CRYS_CYAN   = (0, 218, 250, 255)
C_CRYS_PALE   = (140, 245, 255, 255)
C_CRYS_CORE   = (225, 255, 255, 255)

# Wrought-Iron Metal & Chains
C_IRON_DARK   = (8, 18, 28, 255)
C_IRON_MID    = (20, 34, 48, 255)
C_IRON_EDGE   = (40, 62, 82, 255)
C_IRON_SPEC   = (88, 130, 165, 255)

# Fissure Energy (Crumbling ledges)
C_FISS_VIOLET = (110, 60, 200, 240)
C_FISS_CYAN   = (0, 230, 255, 255)
C_FISS_CORE   = (220, 255, 255, 255)

# Glass & Lanterns
C_GLASS_TINT  = (30, 95, 130, 180)
C_LUMA_AMBER  = (255, 220, 130, 255)
C_LUMA_GOLD   = (255, 175, 50, 255)


# ═════════════════════════════════════════════════════════════════════════════
# 1. CAVE ROCK TILES (256x128) - 8 columns, 4 rows (32x32 tiles)
# ═════════════════════════════════════════════════════════════════════════════
def generate_rock_tiles():
    img = Image.new("RGBA", (256, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    def draw_stone_slab(x0, y0, w, h, is_left=False, is_right=False, var_seed=0):
        """Draws natural subterranean slate walking slab with 100% crisp pixel art."""
        # Base fill
        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                # Edge bevel cuts
                if is_left and (x - x0) < 3 and (y - y0) < (3 - (x - x0)):
                    continue
                if is_right and (x0 + w - 1 - x) < 3 and (y - y0) < (3 - (x0 + w - 1 - x)):
                    continue
                img.putpixel((x, y), C_BEDROCK_0)

        # Natural horizontal sedimentary rock strata
        for y in range(y0 + 3, y0 + h):
            strata_layer = (y - y0 + var_seed * 3) % 7
            col = C_BEDROCK_1 if strata_layer in [1, 2] else (C_BEDROCK_2 if strata_layer == 4 else C_BEDROCK_0)
            for x in range(x0 + (2 if is_left else 0), x0 + w - (2 if is_right else 0)):
                if random.random() < 0.85:
                    img.putpixel((x, y), col)

        # Walking deck top rim (y0 = 0 -> exactly at top of tile!)
        start_x = x0 + (3 if is_left else 0)
        end_x = x0 + w - (3 if is_right else 0)
        for x in range(start_x, end_x):
            img.putpixel((x, y0), C_RIM_CYAN)       # Specular edge glint
            img.putpixel((x, y0 + 1), C_RIM_TEAL)   # Chiseled bevel highlight
            img.putpixel((x, y0 + 2), C_BEDROCK_3)  # Slate shadow transition

        # Corner bevel highlights
        if is_left:
            img.putpixel((x0 + 1, y0 + 2), C_RIM_CYAN)
            img.putpixel((x0, y0 + 3), C_RIM_TEAL)
            for y in range(y0 + 4, y0 + h):
                img.putpixel((x0, y), C_BEDROCK_2)
                img.putpixel((x0 + 1, y), C_BEDROCK_1)
        if is_right:
            img.putpixel((x0 + w - 2, y0 + 2), C_RIM_TEAL)
            img.putpixel((x0 + w - 1, y0 + 3), C_BEDROCK_2)
            for y in range(y0 + 4, y0 + h):
                img.putpixel((x0 + w - 1, y), C_VOID)
                img.putpixel((x0 + w - 2, y), C_BEDROCK_1)

        # Micro fissures & mineral deposits
        if var_seed == 1:
            # Subtle lapis lazuli crystal speck
            cx, cy = x0 + 14, y0 + 11
            img.putpixel((cx, cy), C_CRYS_CYAN)
            img.putpixel((cx + 1, cy), C_CRYS_CORE)
            img.putpixel((cx, cy + 1), C_CRYS_MID)
        elif var_seed == 2:
            # Weathered natural hair crack
            crack = [(x0 + 8, y0 + 1), (x0 + 11, y0 + 5), (x0 + 10, y0 + 9), (x0 + 14, y0 + 15)]
            for px, py in crack:
                img.putpixel((px, py), C_VOID)
                img.putpixel((px + 1, py), C_BEDROCK_3)
        elif var_seed == 3:
            # Double mineral speck
            img.putpixel((x0 + 20, y0 + 8), C_CRYS_CYAN)
            img.putpixel((x0 + 21, y0 + 8), C_CRYS_PALE)
            img.putpixel((x0 + 6, y0 + 16), C_BEDROCK_4)

    # --- ROW 0: Ground Surface Slabs (y = 0..32) ---
    draw_stone_slab(0, 0, 32, 32, is_left=True, is_right=False, var_seed=0)
    draw_stone_slab(32, 0, 32, 32, is_left=False, is_right=False, var_seed=0)
    draw_stone_slab(64, 0, 32, 32, is_left=False, is_right=True, var_seed=0)

    # --- Carved Subterranean Pillar (96, 0, 32, 96) across rows 0, 1, 2 ---
    px, py, pw, ph = 96, 0, 32, 96
    # Base shaft (fluted vertical slate column)
    for y in range(py + 6, py + ph - 8):
        for x in range(px + 4, px + pw - 4):
            img.putpixel((x, y), C_BEDROCK_0)
        # Vertical fluting grooves
        for fx in [px + 7, px + 13, px + 19, px + 25]:
            img.putpixel((fx, y), C_VOID)
            img.putpixel((fx + 1, y), C_BEDROCK_2)
            img.putpixel((fx + 2, y), C_BEDROCK_3)
    # Pillar Capital (top crown)
    for x in range(px + 2, px + pw - 2):
        img.putpixel((x, py + 1), C_RIM_CYAN)
        img.putpixel((x, py + 2), C_RIM_TEAL)
        img.putpixel((x, py + 3), C_BEDROCK_2)
        img.putpixel((x, py + 4), C_BEDROCK_1)
        img.putpixel((x, py + 5), C_BEDROCK_0)
    # Center crystal talisman in capital
    img.putpixel((px + 15, py + 3), C_CRYS_CORE)
    img.putpixel((px + 16, py + 3), C_CRYS_CYAN)
    # Pillar Plinth (bottom base)
    for y in range(py + ph - 8, py + ph):
        for x in range(px + 2, px + pw - 2):
            img.putpixel((x, y), C_BEDROCK_1)
    for x in range(px + 1, px + pw - 1):
        img.putpixel((x, py + ph - 8), C_RIM_TEAL)
        img.putpixel((x, py + ph - 1), C_VOID)

    # --- Additional Surface Slabs (128..256, 0, 32, 32) ---
    draw_stone_slab(128, 0, 32, 32, is_left=False, is_right=False, var_seed=1)
    draw_stone_slab(160, 0, 32, 32, is_left=False, is_right=False, var_seed=2)
    draw_stone_slab(192, 0, 32, 32, is_left=False, is_right=False, var_seed=3)
    draw_stone_slab(224, 0, 32, 32, is_left=False, is_right=False, var_seed=0)

    # --- ROW 1 (y = 32..64): Subsurface Bedrock ---
    def draw_bedrock_fill(bx, by, var_idx=0):
        for y in range(by, by + 32):
            for x in range(bx, bx + 32):
                img.putpixel((x, y), C_BEDROCK_0)
        # Organic horizontal strata
        for sy in [by + 5, by + 11, by + 18, by + 25]:
            for x in range(bx, bx + 32):
                if (x + sy + var_idx * 5) % 4 != 0:
                    img.putpixel((x, sy), C_BEDROCK_1)
        # Natural stone speckles
        if var_idx == 1:
            for dx, dy in [(6, 8), (7, 8), (20, 22), (21, 22)]:
                img.putpixel((bx + dx, by + dy), C_BEDROCK_2)
        elif var_idx == 2:
            # Embedded lapis nodule
            for px, py in [(bx + 14, by + 12), (bx + 15, by + 12), (bx + 14, by + 13)]:
                img.putpixel((px, py), C_CRYS_CYAN)
            img.putpixel((bx + 15, by + 13), C_CRYS_CORE)
        elif var_idx == 3:
            # Organic fissure
            for px, py in [(bx + 8, by + 6), (bx + 12, by + 14), (bx + 16, by + 24)]:
                img.putpixel((px, py), C_VOID)
                img.putpixel((px + 1, py), C_BEDROCK_2)

    for bi, bx in enumerate([0, 32, 64, 128, 160, 192, 224]):
        draw_bedrock_fill(bx, 32, var_idx=bi % 4)

    # Edge walls for row 1
    for y in range(32, 64):
        img.putpixel((0, y), C_BEDROCK_2)
        img.putpixel((64 + 31, y), C_VOID)

    # --- ROW 2 (y = 64..96): Deep Subsurface Bedrock ---
    for bi, bx in enumerate([0, 32, 64, 128, 160, 192, 224]):
        draw_bedrock_fill(bx, 64, var_idx=(bi + 2) % 4)
    for y in range(64, 96):
        img.putpixel((0, y), C_BEDROCK_2)
        img.putpixel((64 + 31, y), C_VOID)

    # --- ROW 3 (y = 96..128): Ceiling Overhang Rock & Stalactite Teeth ---
    for bx in range(0, 256, 32):
        for y in range(96, 128):
            for x in range(bx, bx + 32):
                img.putpixel((x, y), C_BEDROCK_0)
        # Underside jagged stalactite rim
        for x in range(bx, bx + 32):
            img.putpixel((x, 96), C_VOID)
            img.putpixel((x, 97), C_BEDROCK_1)
        # Small hanging tooth
        tx = bx + 16
        for ty, tw in enumerate([7, 5, 3, 1]):
            for ox in range(-tw // 2, tw // 2 + 1):
                img.putpixel((tx + ox, 98 + ty), C_BEDROCK_2)
            img.putpixel((tx, 98 + ty), C_RIM_TEAL)
        img.putpixel((tx, 102), C_RIM_CYAN)

    return img


# ═════════════════════════════════════════════════════════════════════════════
# 2. CAVE PLATFORMS (256x160) - Zero-gap walking surfaces
# ═════════════════════════════════════════════════════════════════════════════
def generate_platforms():
    img = Image.new("RGBA", (256, 160), (0, 0, 0, 0))

    # Helper: draw clean, solid stone walking ledge starting EXACTLY at y = 0
    def draw_platform_deck(x0, y0, w, h, teeth_profile):
        """
        x0, y0: Top-left of platform bounding box
        w, h: Width and height
        teeth_profile: List of (rel_x, rel_y) polygon points defining natural underside rock
        """
        # 1. Fill solid rock body
        # Generate mask of polygon: top edge is (x0+4, y0) to (x0+w-4, y0)
        poly = [(x0 + 4, y0), (x0 + w - 4, y0)]
        for rx, ry in teeth_profile:
            poly.append((x0 + rx, y0 + ry))
        
        mask = Image.new("L", (img.width, img.height), 0)
        m_draw = ImageDraw.Draw(mask)
        m_draw.polygon(poly, fill=255)

        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                if mask.getpixel((x, y)) > 0:
                    img.putpixel((x, y), C_BEDROCK_0)

        # 2. Add horizontal strata layers
        for y in range(y0 + 3, y0 + h):
            strata_layer = (y - y0) % 6
            col = C_BEDROCK_1 if strata_layer in [1, 2] else (C_BEDROCK_2 if strata_layer == 4 else C_BEDROCK_0)
            for x in range(x0 + 4, x0 + w - 4):
                if mask.getpixel((x, y)) > 0 and random.random() < 0.8:
                    img.putpixel((x, y), col)

        # 3. Walking Deck Surface (y0 = EXACTLY 0 relative to sprite!)
        for x in range(x0 + 4, x0 + w - 4):
            img.putpixel((x, y0), C_RIM_CYAN)       # Specular edge glint
            img.putpixel((x, y0 + 1), C_RIM_TEAL)   # Bevel highlight
            img.putpixel((x, y0 + 2), C_BEDROCK_3)  # Transition

        # Beveled corner edges
        img.putpixel((x0 + 3, y0), C_RIM_TEAL)
        img.putpixel((x0 + 2, y0 + 1), C_RIM_TEAL)
        img.putpixel((x0 + 1, y0 + 2), C_BEDROCK_3)
        img.putpixel((x0 + w - 4, y0), C_RIM_TEAL)
        img.putpixel((x0 + w - 3, y0 + 1), C_RIM_TEAL)
        img.putpixel((x0 + w - 2, y0 + 2), C_BEDROCK_3)

        # Bottom hanging stalactite teeth highlight
        for i in range(len(teeth_profile) - 1):
            x1, y1 = teeth_profile[i]
            x2, y2 = teeth_profile[i + 1]
            # Rim on lowest points
            if y1 > h * 0.6:
                img.putpixel((x0 + x1, y0 + y1), C_RIM_TEAL)
                img.putpixel((x0 + x1, y0 + y1 - 1), C_RIM_CYAN)

        # Embedded lapis nodules on underside
        mid_x = x0 + w // 2
        for ox, oy in [(-w // 4, h // 2), (w // 4, h // 2 + 4)]:
            if mask.getpixel((mid_x + ox, y0 + oy)) > 0:
                img.putpixel((mid_x + ox, y0 + oy), C_CRYS_CYAN)
                img.putpixel((mid_x + ox + 1, y0 + oy), C_CRYS_PALE)
                img.putpixel((mid_x + ox, y0 + oy + 1), C_CRYS_DEEP)

    # --- 1. Large Cavern Island ("island_lg", 0, 0, 128, 56) ---
    lg_teeth = [
        (124, 6), (120, 18), (112, 34), (98, 48), (84, 38),
        (64, 54), # Primary central stalactite tip
        (44, 36), (28, 46), (16, 32), (6, 18), (4, 6)
    ]
    draw_platform_deck(0, 0, 128, 56, lg_teeth)
    # Wrought iron chain shackle mounts at (18, 0) and (110, 0)
    for ax in [18, 110]:
        img.putpixel((ax - 2, 0), C_IRON_SPEC)
        img.putpixel((ax - 1, 0), C_IRON_SPEC)
        img.putpixel((ax, 0), C_IRON_SPEC)
        img.putpixel((ax + 1, 0), C_IRON_SPEC)
        img.putpixel((ax - 2, 1), C_IRON_MID)
        img.putpixel((ax + 1, 1), C_IRON_MID)

    # --- 2. Medium Cavern Island ("island_md", 128, 0, 96, 48) ---
    md_teeth = [
        (92, 6), (88, 16), (78, 30), (62, 44),
        (48, 46), # Central stalactite tip
        (34, 42), (18, 28), (8, 16), (4, 6)
    ]
    draw_platform_deck(128, 0, 96, 48, md_teeth)
    # Center chain shackle mount
    c_ax = 128 + 48
    img.putpixel((c_ax - 2, 0), C_IRON_SPEC)
    img.putpixel((c_ax - 1, 0), C_IRON_SPEC)
    img.putpixel((c_ax, 0), C_IRON_SPEC)
    img.putpixel((c_ax + 1, 0), C_IRON_SPEC)
    img.putpixel((c_ax - 2, 1), C_IRON_MID)
    img.putpixel((c_ax + 1, 1), C_IRON_MID)

    # --- 3. Wrought-Iron Ruin Bridge ("bridge", 0, 64, 128, 40) ---
    bx, by, bw, bh = 0, 64, 128, 40
    # Walking deck slab (y = by -> top at 0 relative to sprite)
    for x in range(bx + 4, bx + bw - 4):
        img.putpixel((x, by), C_RIM_CYAN)
        img.putpixel((x, by + 1), C_RIM_TEAL)
        img.putpixel((x, by + 2), C_BEDROCK_3)
        img.putpixel((x, by + 3), C_BEDROCK_1)
        img.putpixel((x, by + 4), C_BEDROCK_0)
    # Under-truss arches (4 classical stone/iron arches)
    arch_w = (bw - 8) // 4
    for ai in range(4):
        ax1 = bx + 4 + ai * arch_w
        ax2 = ax1 + arch_w
        acx = (ax1 + ax2) // 2
        # Gothic pointed arch curve
        for x in range(ax1, ax2 + 1):
            dx = abs(x - acx)
            curve_y = by + 5 + int(dx * 1.5)
            if curve_y < by + bh - 6:
                img.putpixel((x, curve_y), C_BEDROCK_2)
                img.putpixel((x, curve_y + 1), C_BEDROCK_1)
        # Apex jewel / rivet
        img.putpixel((acx, by + 5), C_CRYS_CYAN)
        img.putpixel((acx, by + 6), C_CRYS_CORE)
    # Masonry abutments at bridge ends
    for y in range(by, by + bh):
        for x in range(bx + 2, bx + 7):
            img.putpixel((x, y), C_BEDROCK_1)
        for x in range(bx + bw - 7, bx + bw - 2):
            img.putpixel((x, y), C_BEDROCK_1)
        img.putpixel((bx + 2, y), C_RIM_TEAL)
        img.putpixel((bx + bw - 3, y), C_VOID)

    # --- 4. Crumbling Ancient Ledge ("crumble", 128, 64, 96, 48) ---
    cr_teeth = [
        (92, 5), (86, 18), (76, 32), (60, 42), (48, 38),
        (32, 44), (16, 26), (6, 14), (4, 5)
    ]
    draw_platform_deck(128, 64, 96, 48, cr_teeth)
    # Cyan/Violet stress fissures splitting across stone
    fissures = [
        [(144, 64), (146, 68), (143, 76), (148, 88), (146, 98)],
        [(172, 64), (176, 72), (174, 82), (180, 94)],
        [(198, 64), (196, 74), (202, 86)]
    ]
    for fissure in fissures:
        for fx, fy in fissure:
            img.putpixel((fx - 1, fy), C_FISS_VIOLET)
            img.putpixel((fx, fy), C_FISS_CYAN)
            img.putpixel((fx + 1, fy), C_FISS_CORE)

    # --- 5. Boss Sanctuary Dais ("sanctuary", 0, 104, 160, 56) ---
    sx, sy, sw, sh = 0, 104, 160, 56
    # Stepped ceremonial stone deck
    for x in range(sx + 4, sx + sw - 4):
        img.putpixel((x, sy), C_RIM_CYAN)
        img.putpixel((x, sy + 1), C_RIM_TEAL)
        img.putpixel((x, sy + 2), C_BEDROCK_3)
        img.putpixel((x, sy + 3), C_BEDROCK_1)
        img.putpixel((x, sy + 4), C_BEDROCK_0)
    # Relief carved border with embedded lapis crystals every 16px
    for gx in range(sx + 10, sx + sw - 10, 14):
        img.putpixel((gx, sy + 6), C_CRYS_CYAN)
        img.putpixel((gx + 1, sy + 6), C_CRYS_CORE)
        img.putpixel((gx, sy + 7), C_CRYS_DEEP)
    # Solid bedrock underside with dramatic stalactite fringe
    sanc_teeth = [
        (156, 5), (148, 20), (134, 38), (116, 48), (96, 42),
        (80, 54), # Primary sanctum stalactite
        (64, 42), (44, 48), (26, 38), (12, 20), (4, 5)
    ]
    s_poly = [(sx + 4, sy + 8), (sx + sw - 4, sy + 8)] + [(sx + rx, sy + ry) for rx, ry in sanc_teeth]
    s_mask = Image.new("L", (img.width, img.height), 0)
    ImageDraw.Draw(s_mask).polygon(s_poly, fill=255)
    for y in range(sy + 8, sy + sh):
        for x in range(sx, sx + sw):
            if s_mask.getpixel((x, y)) > 0:
                img.putpixel((x, y), C_BEDROCK_0)
                if (x + y) % 5 == 0:
                    img.putpixel((x, y), C_BEDROCK_1)

    return img


# ═════════════════════════════════════════════════════════════════════════════
# 3. CAVE PROPS (256x160) - Slender chains, lanterns, pogo spikes & crystals
# ═════════════════════════════════════════════════════════════════════════════
def generate_props():
    img = Image.new("RGBA", (256, 160), (0, 0, 0, 0))

    # --- 1. Wrought-Iron Lumafly Streetlamp (0, 0, 64, 96) ---
    lx, ly, lw, lh = 0, 0, 64, 96
    pcx = lx + 32
    # Base bolted iron pedestal (y = 86..95)
    for y in range(ly + 86, ly + 96):
        bw = 8 + (y - (ly + 86)) * 2
        for x in range(pcx - bw // 2, pcx + bw // 2 + 1):
            img.putpixel((x, y), C_IRON_MID)
        img.putpixel((pcx - bw // 2, y), C_IRON_SPEC)
        img.putpixel((pcx + bw // 2, y), C_IRON_DARK)
    # Slender wrought-iron post (pcx, ly+34 to ly+86)
    for y in range(ly + 34, ly + 86):
        img.putpixel((pcx - 1, y), C_IRON_SPEC)
        img.putpixel((pcx, y), C_IRON_MID)
        img.putpixel((pcx + 1, y), C_IRON_DARK)
    # Mid-post decorative knot
    for x in range(pcx - 3, pcx + 4):
        img.putpixel((x, ly + 60), C_IRON_EDGE)
        img.putpixel((x, ly + 61), C_IRON_SPEC)
    # Swan-neck arch to x = 44, y = 20
    arch_pts = [
        (pcx, ly + 36), (pcx + 2, ly + 28), (pcx + 6, ly + 20),
        (pcx + 12, ly + 14), (pcx + 18, ly + 14), (pcx + 22, ly + 18), (pcx + 22, ly + 24)
    ]
    for ax, ay in arch_pts:
        img.putpixel((ax, ay), C_IRON_SPEC)
        img.putpixel((ax, ay + 1), C_IRON_MID)
    # Lantern bell cage centered at (pcx + 22 = 54, ly + 24)
    hx, hy = pcx + 22, ly + 24
    # Roof cap
    for x in range(hx - 7, hx + 8):
        img.putpixel((x, hy + 2), C_IRON_SPEC)
        img.putpixel((x, hy + 3), C_IRON_MID)
    img.putpixel((hx, hy), C_IRON_SPEC)
    img.putpixel((hx, hy + 1), C_IRON_EDGE)
    # Glass globe & Spirit Lumafly core
    for gy in range(hy + 4, hy + 18):
        for gx in range(hx - 6, hx + 7):
            d2 = (gx - hx)**2 + (gy - (hy + 11))**2
            if d2 <= 28:
                img.putpixel((gx, gy), C_GLASS_TINT)
    # Lumafly core (glowing amber/cyan spirit moth)
    img.putpixel((hx, hy + 10), C_CRYS_CORE)
    img.putpixel((hx - 1, hy + 11), C_CRYS_PALE)
    img.putpixel((hx + 1, hy + 11), C_CRYS_PALE)
    img.putpixel((hx, hy + 11), C_CRYS_CYAN)
    img.putpixel((hx, hy + 12), C_CRYS_MID)
    # Lantern bottom finial
    for y in range(hy + 18, hy + 22):
        img.putpixel((hx, y), C_IRON_SPEC)

    # --- 2. Slender Wrought-Iron Chain (64, 0, 32, 128) ---
    # Width 32, centered at cx = 64 + 16 = 80.
    # Seamless repeating 16px chain links!
    # Vertical link: 12px tall, 6px wide. Horizontal link: 4px tall, 8px wide.
    # Total pattern = 16px, repeating 8 times over 128px!
    cx = 80
    for repeat in range(8):
        base_y = repeat * 16
        # Vertical link (base_y + 0 to base_y + 11)
        for y in range(base_y + 1, base_y + 11):
            img.putpixel((cx - 2, y), C_IRON_SPEC) # Left side highlight
            img.putpixel((cx - 1, y), C_IRON_MID)
            img.putpixel((cx + 1, y), C_IRON_MID)
            img.putpixel((cx + 2, y), C_IRON_DARK) # Right side shadow
        img.putpixel((cx - 1, base_y), C_IRON_SPEC)
        img.putpixel((cx, base_y), C_IRON_SPEC)
        img.putpixel((cx + 1, base_y), C_IRON_SPEC)
        img.putpixel((cx - 1, base_y + 11), C_IRON_MID)
        img.putpixel((cx, base_y + 11), C_IRON_DARK)
        img.putpixel((cx + 1, base_y + 11), C_IRON_DARK)

        # Horizontal link turned edge-on (base_y + 11 to base_y + 15)
        for x in range(cx - 3, cx + 4):
            img.putpixel((x, base_y + 12), C_IRON_SPEC)
            img.putpixel((x, base_y + 13), C_IRON_MID)
            img.putpixel((x, base_y + 14), C_IRON_DARK)

    # --- 3. Resonant Pogo Crystal Cluster (96, 0, 64, 48) ---
    px, py, pw, ph = 96, 0, 64, 48
    pcx, pcy = px + 32, py + 26
    # Central towering crystal shard (pcx, pcy - 22 to pcy + 16)
    c_poly_center = [
        (pcx, pcy - 22), (pcx + 6, pcy - 4), (pcx + 5, pcy + 16),
        (pcx - 5, pcy + 16), (pcx - 6, pcy - 4)
    ]
    c_mask = Image.new("L", (img.width, img.height), 0)
    ImageDraw.Draw(c_mask).polygon(c_poly_center, fill=255)
    for y in range(pcy - 22, pcy + 17):
        for x in range(pcx - 6, pcx + 7):
            if c_mask.getpixel((x, y)) > 0:
                img.putpixel((x, y), C_CRYS_MID if x > pcx else C_CRYS_CYAN)
    # Central crystal spine & apex glint
    for y in range(pcy - 20, pcy + 15):
        img.putpixel((pcx, y), C_CRYS_PALE)
    img.putpixel((pcx, pcy - 22), C_CRYS_CORE)
    img.putpixel((pcx, pcy - 21), C_CRYS_CORE)

    # Left branching crystal shard
    for ox, oy in [(-8, -10), (-12, -2), (-14, 8), (-8, 14), (-4, 8)]:
        img.putpixel((pcx + ox, pcy + oy), C_CRYS_CYAN)
        img.putpixel((pcx + ox + 1, pcy + oy), C_CRYS_PALE)
    # Right branching crystal shard
    for ox, oy in [(8, -8), (12, 0), (14, 10), (8, 14), (4, 8)]:
        img.putpixel((pcx + ox, pcy + oy), C_CRYS_MID)
        img.putpixel((pcx + ox - 1, pcy + oy), C_CRYS_CYAN)

    # --- 4. Subterranean Crystal Spike Hazard Bed (160, 0, 96, 32) ---
    kx, ky, kw, kh = 160, 0, 96, 32
    # Bedrock ground base strip (y = ky + 24..31)
    for y in range(ky + 24, ky + 32):
        for x in range(kx, kx + kw):
            img.putpixel((x, y), C_BEDROCK_0)
    for x in range(kx, kx + kw):
        img.putpixel((x, ky + 24), C_RIM_TEAL)

    # 7 Razor-sharp crystal stalagmites for Hollow Knight pogo bouncing!
    # (tip_x, height)
    spike_configs = [
        (kx + 6, 22), (kx + 19, 28), (kx + 34, 25), (kx + 48, 30),
        (kx + 62, 24), (kx + 76, 29), (kx + 89, 23)
    ]
    for sp_x, sp_h in spike_configs:
        tip_y = ky + 24 - sp_h
        # Draw tapered needle
        base_w = 10
        s_pts = [(sp_x, tip_y), (sp_x + base_w // 2, ky + 24), (sp_x - base_w // 2, ky + 24)]
        s_mask = Image.new("L", (img.width, img.height), 0)
        ImageDraw.Draw(s_mask).polygon(s_pts, fill=255)
        for y in range(tip_y, ky + 25):
            for x in range(sp_x - base_w // 2, sp_x + base_w // 2 + 1):
                if s_mask.getpixel((x, y)) > 0:
                    img.putpixel((x, y), C_CRYS_DEEP if x > sp_x else C_CRYS_MID)
        # Lethal glint needle spine & tip
        for y in range(tip_y + 1, ky + 24):
            img.putpixel((sp_x, y), C_CRYS_CYAN)
        img.putpixel((sp_x, tip_y), C_CRYS_CORE)
        img.putpixel((sp_x, tip_y + 1), C_CRYS_PALE)

    # --- 5. Ancient Lunar Lore Stele (96, 48, 64, 112) ---
    tx, ty, tw, th = 96, 48, 64, 112
    tcx = tx + 32
    # Standing monolith stone slab (y = ty + 12 to ty + 104)
    for y in range(ty + 18, ty + 104):
        for x in range(tcx - 14, tcx + 15):
            img.putpixel((x, y), C_BEDROCK_0)
        img.putpixel((tcx - 14, y), C_RIM_TEAL)
        img.putpixel((tcx + 14, y), C_VOID)
    # Arched crest
    for x in range(tcx - 14, tcx + 15):
        dx = abs(x - tcx)
        arch_top = ty + 8 + int((dx**2) / 28)
        for y in range(arch_top, ty + 18):
            img.putpixel((x, y), C_BEDROCK_0)
        img.putpixel((x, arch_top), C_RIM_CYAN)
    # Inscribed glowing crescent moon
    for y in range(ty + 22, ty + 36):
        for x in range(tcx - 6, tcx + 7):
            d_outer = (x - tcx)**2 + (y - (ty + 29))**2
            d_inner = (x - (tcx + 3))**2 + (y - (ty + 29))**2
            if d_outer <= 26 and d_inner >= 12:
                img.putpixel((x, y), C_CRYS_CYAN)
    img.putpixel((tcx - 1, ty + 29), C_CRYS_CORE)
    # Vertical glowing runic script down center
    for ry in range(ty + 44, ty + 94, 8):
        img.putpixel((tcx, ry), C_CRYS_CORE)
        img.putpixel((tcx - 1, ry + 1), C_CRYS_CYAN)
        img.putpixel((tcx + 1, ry + 1), C_CRYS_CYAN)
        img.putpixel((tcx, ry + 2), C_CRYS_MID)

    # --- 6. Ceiling Stalactite Cluster (160, 32, 96, 128) ---
    # Matches natural background stalactites in Layer 7 and 9
    sx, sy, sw, sh = 160, 32, 96, 128
    # Top rock ceiling base
    for y in range(sy, sy + 10):
        for x in range(sx, sx + sw):
            img.putpixel((x, y), C_BEDROCK_0)
    for x in range(sx, sx + sw):
        img.putpixel((x, sy + 10), C_RIM_TEAL)
    # 5 Tapered stalactite columns of various lengths
    stal_spans = [
        (sx + 14, 12, 54),
        (sx + 32, 18, 98), # Long primary stalactite
        (sx + 52, 14, 72),
        (sx + 72, 16, 112), # Deep primary stalactite
        (sx + 88, 10, 46)
    ]
    for st_x, st_w, st_len in stal_spans:
        tip_y = sy + 10 + st_len
        st_pts = [
            (st_x - st_w // 2, sy + 10),
            (st_x - st_w // 3, sy + 10 + int(st_len * 0.45)),
            (st_x, tip_y),
            (st_x + st_w // 3, sy + 10 + int(st_len * 0.45)),
            (st_x + st_w // 2, sy + 10)
        ]
        s_mask = Image.new("L", (img.width, img.height), 0)
        ImageDraw.Draw(s_mask).polygon(st_pts, fill=255)
        for y in range(sy + 10, tip_y + 1):
            for x in range(st_x - st_w // 2, st_x + st_w // 2 + 1):
                if s_mask.getpixel((x, y)) > 0:
                    img.putpixel((x, y), C_BEDROCK_0 if x > st_x else C_BEDROCK_1)
        # Left rim highlight
        for y in range(sy + 10, tip_y):
            rel_x = st_x - int((tip_y - y) / st_len * (st_w // 2))
            img.putpixel((rel_x, y), C_RIM_TEAL)
        # Dripping water drop on tip
        img.putpixel((st_x, tip_y), C_CRYS_CORE)
        img.putpixel((st_x, tip_y - 1), C_CRYS_CYAN)

    return img


# ═════════════════════════════════════════════════════════════════════════════
# EXECUTION
# ═════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    out_dir = "assets/cave_platformer"
    os.makedirs(out_dir, exist_ok=True)

    print("Generating 1:1 pixel art cave_rock_tiles.png...")
    rock_tiles = generate_rock_tiles()
    rock_tiles.save(os.path.join(out_dir, "cave_rock_tiles.png"))
    print(f" -> Saved {rock_tiles.size} to {out_dir}/cave_rock_tiles.png")

    print("Generating 1:1 pixel art cave_platforms.png (zero-gap walking deck)...")
    platforms = generate_platforms()
    platforms.save(os.path.join(out_dir, "cave_platforms.png"))
    print(f" -> Saved {platforms.size} to {out_dir}/cave_platforms.png")

    print("Generating 1:1 pixel art cave_props.png (slender chains, spikes, crystals)...")
    props = generate_props()
    props.save(os.path.join(out_dir, "cave_props.png"))
    print(f" -> Saved {props.size} to {out_dir}/cave_props.png")

    print("All native 1:1 cave pixel art generated flawlessly!")

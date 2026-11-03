#!/usr/bin/env python3
"""
Builds authentic, high-quality Philippine Subterranean Cavern Assets for Haliya: Mask of Sorrows:
1. assets/cave_platformer/cave_rock_tiles.png & cave_tileset_atlas.png (288x384)
   - Natural Philippine Limestone and Volcanic Mayon Basalt.
   - 100% flush top surface at y=0 so character steps cleanly without floating.
2. assets/cave_platformer/cave_platforms.png (224x160)
   - island_lg: Tiered limestone shelf with abaca vine bindings.
   - island_md: Medium limestone ledge with moss trim.
   - bridge: Authentic Philippine bamboo & abaca rope suspension bridge (Tulay na Kawayan).
   - crumble: Brittle, cracked limestone shelf (100% VISIBLE, zero invisible air blocks!).
   - sanctuary: Ancestral stone terrace with pre-colonial spiral/wave reliefs.
3. assets/cave_platformer/cave_props.png (320x160)
   - Manunggul secondary burial jar (ancient Palawan cave artifact).
   - Carved wooden Anito / Haliya moon totem (Likha).
   - Subterranean river ferns (Pako) and Balete roots.
   - Natural limestone stalactite ceiling clusters.
   - Bamboo torches (Sulo) with rattan cords.
   - Natural limestone stalagmite hazard bed (Tusok ng Bato).
   - Resonant Moon Pearl (Mutya ng Haliya) for pogo bounces.
   - Earthenware Palayok pots.
"""

import math
import os
import random
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(BASE_DIR, "assets", "cave_platformer")
os.makedirs(OUT_DIR, exist_ok=True)

random.seed(42)

# --- Palette Definitions ---
# Subterranean Limestone & Deep Cavern Slate (sampled to harmonize with Cave Parallax BG)
C_LIME_DARKEST = (14, 22, 34, 255)
C_LIME_DEEP    = (24, 36, 52, 255)
C_LIME_MID     = (38, 54, 76, 255)
C_LIME_LIGHT   = (58, 80, 110, 255)
C_LIME_HIGHLIGHT = (88, 120, 155, 255)
C_LIME_CREST   = (130, 170, 205, 255) # Top specular rim on limestone

# Volcanic Basalt (Mayon Lava Tube / Bicol Earth)
C_BASALT_DEEP  = (28, 20, 24, 255)
C_BASALT_MID   = (48, 36, 38, 255)
C_BASALT_LIGHT = (76, 58, 56, 255)
C_BASALT_CREST = (118, 92, 84, 255)
C_EMBER_GLOW   = (210, 110, 45, 255)

# Tropical Cave Moss & Ferns (Pako)
C_MOSS_DARK    = (18, 42, 26, 255)
C_MOSS_MID     = (32, 78, 42, 255)
C_MOSS_LIGHT   = (58, 125, 68, 255)
C_MOSS_BRIGHT  = (92, 185, 105, 255)

# Philippine Bamboo & Abaca Rope (Kawayan at Yantok)
C_BAMBOO_SHD   = (52, 42, 18, 255)
C_BAMBOO_MID   = (112, 92, 42, 255)
C_BAMBOO_LGT   = (165, 142, 68, 255)
C_BAMBOO_HI    = (215, 192, 105, 255)
C_ROPE_DARK    = (48, 32, 16, 255)
C_ROPE_MID     = (96, 68, 36, 255)
C_ROPE_LGT     = (145, 108, 62, 255)

# Terracotta Pottery (Palayok & Manunggul Clay)
C_CLAY_SHADOW  = (58, 24, 16, 255)
C_CLAY_DARK    = (96, 42, 24, 255)
C_CLAY_MID     = (155, 72, 38, 255)
C_CLAY_LIGHT   = (195, 102, 55, 255)
C_CLAY_HI      = (235, 145, 85, 255)

# Haliya Sacred Silver-Blue Moonlight (Mutya ng Buwan)
C_MOON_DEEP    = (22, 65, 105, 255)
C_MOON_MID     = (45, 135, 195, 255)
C_MOON_CYAN    = (95, 205, 245, 255)
C_MOON_WHITE   = (225, 250, 255, 255)


def build_cave_rock_tiles():
    """
    Builds cave_rock_tiles.png (288x384, 9 cols x 12 rows of 32x32 tiles):
    - Rows 0..2: Subterranean Limestone (cols 0..2: 3x3 autotile block, cols 3..5: rocky variations, cols 6..8: stalactites)
    - Rows 6..8: Volcanic Basalt / Obsidian (Mayon lava cavern variant)
    Guarantees row 0 has solid rock pixels from y=0 down to y=31 for seamless step collision!
    """
    im = Image.new("RGBA", (288, 384), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    def draw_3x3_autotile(ox, oy, theme="limestone"):
        w = 96
        h = 96
        # Background base fill
        for y in range(h):
            for x in range(w):
                # Edge masks
                is_top = (y < 4)
                is_left = (x < 4 and y < 80)
                is_right = (x >= 92 and y < 80)
                is_bottom = (y >= 88)

                # Rock texture noise
                noise = (math.sin(x * 0.45) * 0.5 + math.cos(y * 0.4) * 0.5 +
                         math.sin((x + y) * 0.3) * 0.3)
                depth = y / float(h)

                if theme == "limestone":
                    if is_top:
                        # Top surface: crisp limestone cap with gentle moss flecks
                        col = C_LIME_CREST if (y <= 1 and (x + y) % 3 != 0) else C_LIME_LIGHT
                        if noise > 0.4 and y == 0:
                            col = C_MOSS_LIGHT
                        elif noise > 0.2 and y <= 2:
                            col = C_MOSS_MID
                    elif is_left or is_right:
                        col = C_LIME_MID if noise > 0 else C_LIME_DEEP
                    elif is_bottom:
                        col = C_LIME_DARKEST if noise < 0.2 else C_LIME_DEEP
                    else:
                        # Interior solid rock strata
                        if noise > 0.5:
                            col = C_LIME_LIGHT
                        elif noise > 0.1:
                            col = C_LIME_MID
                        elif noise > -0.4:
                            col = C_LIME_DEEP
                        else:
                            col = C_LIME_DARKEST
                else:
                    # Basalt theme
                    if is_top:
                        col = C_BASALT_CREST if y <= 1 else C_BASALT_LIGHT
                        if noise > 0.5 and y <= 2:
                            col = C_EMBER_GLOW
                    elif is_left or is_right:
                        col = C_BASALT_MID if noise > 0 else C_BASALT_DEEP
                    elif is_bottom:
                        col = C_BASALT_DEEP
                    else:
                        if noise > 0.5:
                            col = C_BASALT_LIGHT
                        elif noise > 0.0:
                            col = C_BASALT_MID
                        else:
                            col = C_BASALT_DEEP

                im.putpixel((ox + x, oy + y), col)

        # Chiseled rock fissures on surface
        for rk in range(12):
            fx = random.randint(8, 88)
            fy = random.randint(6, 88)
            flen = random.randint(4, 10)
            fcol = C_LIME_DARKEST if theme == "limestone" else C_BASALT_DEEP
            for i in range(flen):
                px = fx + i
                py = fy + int(math.sin(i * 0.8) * 2)
                if 0 <= px < 96 and 0 <= py < 96:
                    im.putpixel((ox + px, oy + py), fcol)

    # Limestone Block (Rows 0..2, cols 0..2)
    draw_3x3_autotile(0, 0, "limestone")
    # Repeated variations for cols 3..5 and 6..8
    draw_3x3_autotile(96, 0, "limestone")
    draw_3x3_autotile(192, 0, "limestone")

    # Rows 3..5: Limestone subsurface bedrock and hanging stalactite teeth
    for cy in range(3, 6):
        for cx in range(9):
            bx = cx * 32
            by = cy * 32
            # Solid bedrock interior
            for y in range(32):
                for x in range(32):
                    n = math.sin((x + bx) * 0.3) + math.cos((y + by) * 0.3)
                    col = C_LIME_MID if n > 0.6 else (C_LIME_DEEP if n > -0.4 else C_LIME_DARKEST)
                    im.putpixel((bx + x, by + y), col)

    # Volcanic Basalt Block (Rows 6..8)
    draw_3x3_autotile(0, 192, "basalt")
    draw_3x3_autotile(96, 192, "basalt")
    draw_3x3_autotile(192, 192, "basalt")

    # Rows 9..11: Basalt subsurface
    for cy in range(9, 12):
        for cx in range(9):
            bx = cx * 32
            by = cy * 32
            for y in range(32):
                for x in range(32):
                    n = math.sin((x + bx) * 0.3) + math.cos((y + by) * 0.3)
                    col = C_BASALT_MID if n > 0.6 else C_BASALT_DEEP
                    im.putpixel((bx + x, by + y), col)

    # Save both cave_rock_tiles.png and cave_tileset_atlas.png
    p1 = os.path.join(OUT_DIR, "cave_rock_tiles.png")
    p2 = os.path.join(OUT_DIR, "cave_tileset_atlas.png")
    im.save(p1, "PNG")
    im.save(p2, "PNG")
    print(f"Generated {p1} and {p2} (size: {im.size})")


def build_cave_platforms():
    """
    Builds cave_platforms.png (224x160):
    - island_lg: Rect2(0, 0, 128, 56)   - Tiered limestone rock shelf with mossy trim and abaca rope lashings.
    - island_md: Rect2(128, 0, 96, 48)  - Medium mossy limestone ledge.
    - bridge:    Rect2(0, 64, 128, 40)  - Traditional Philippine bamboo footbridge (Tulay na Kawayan).
    - crumble:   Rect2(128, 64, 96, 48) - Brittle, cracked limestone ledge (100% VISIBLE, NO INVISIBLE BLOCKS!).
    - sanctuary: Rect2(0, 104, 160, 56) - Ancestral stone terrace with pre-colonial spiral/wave reliefs.

    STRICT GUARANTEE:
    For every platform, the topmost solid pixels begin EXACTLY at y = 0 within its sub-region!
    """
    im = Image.new("RGBA", (224, 160), (0, 0, 0, 0))

    # --- 1. island_lg: Rect2(0, 0, 128, 56) ---
    # Width 128, Height 56. Top surface at y = 0..12.
    ox, oy, pw, ph = 0, 0, 128, 56
    for x in range(pw):
        # Stepped rock profile underbelly: widest at top, tapering down to stalactite teeth
        dist_from_center = abs(x - (pw * 0.5)) / (pw * 0.5)
        max_depth = int(54 - (dist_from_center ** 1.8) * 36)
        if x < 4 or x >= pw - 4:
            max_depth = max(10, max_depth - 12)

        for y in range(max_depth):
            noise = math.sin(x * 0.3) * 0.5 + math.cos(y * 0.4) * 0.5
            if y == 0:
                col = C_MOSS_LIGHT if noise > 0.1 else C_LIME_CREST
            elif y <= 2:
                col = C_MOSS_MID if noise > 0.0 else C_LIME_LIGHT
            elif y <= 8:
                col = C_LIME_LIGHT if noise > 0.2 else C_LIME_MID
            elif y <= 22:
                col = C_LIME_MID if noise > -0.2 else C_LIME_DEEP
            else:
                col = C_LIME_DEEP if noise > -0.1 else C_LIME_DARKEST

            # Abaca rope lashings at x = 20..24 and x = 104..108
            if (20 <= x <= 23 or 104 <= x <= 107) and y <= 32:
                col = C_ROPE_LGT if (x + y) % 3 == 0 else C_ROPE_MID

            im.putpixel((ox + x, oy + y), col)

    # --- 2. island_md: Rect2(128, 0, 96, 48) ---
    ox, oy, pw, ph = 128, 0, 96, 48
    for x in range(pw):
        dist_from_center = abs(x - (pw * 0.5)) / (pw * 0.5)
        max_depth = int(46 - (dist_from_center ** 1.6) * 30)
        if x < 3 or x >= pw - 3:
            max_depth = max(8, max_depth - 10)

        for y in range(max_depth):
            noise = math.sin(x * 0.4) * 0.5 + math.cos(y * 0.4) * 0.5
            if y == 0:
                col = C_MOSS_LIGHT if noise > 0.0 else C_LIME_CREST
            elif y <= 2:
                col = C_MOSS_MID if noise > -0.1 else C_LIME_LIGHT
            elif y <= 8:
                col = C_LIME_LIGHT if noise > 0.3 else C_LIME_MID
            elif y <= 18:
                col = C_LIME_MID if noise > -0.2 else C_LIME_DEEP
            else:
                col = C_LIME_DEEP if noise > 0.0 else C_LIME_DARKEST
            im.putpixel((ox + x, oy + y), col)

    # --- 3. bridge: Rect2(0, 64, 128, 40) ---
    # Traditional Philippine bamboo footbridge (Tulay na Kawayan at Abaka)
    ox, oy, pw, ph = 0, 64, 128, 40
    # Top handrail ropes at y = 2..4
    for x in range(pw):
        im.putpixel((ox + x, oy + 2), C_ROPE_MID)
        im.putpixel((ox + x, oy + 3), C_ROPE_LGT if x % 4 != 0 else C_ROPE_DARK)

    # Bamboo support posts every 16px
    for px in range(8, pw, 16):
        for y in range(2, 28):
            im.putpixel((ox + px, oy + y), C_BAMBOO_MID)
            im.putpixel((ox + px + 1, oy + y), C_BAMBOO_LGT)
            if y % 8 == 0:
                im.putpixel((ox + px, oy + y), C_BAMBOO_SHD)
                im.putpixel((ox + px + 1, oy + y), C_BAMBOO_SHD)

    # Main walking deck: thick bamboo slats from y = 14 to 22
    for x in range(pw):
        is_slat_gap = (x % 6 == 0)
        for y in range(14, 24):
            if is_slat_gap:
                col = C_BAMBOO_SHD
            elif y == 14:
                col = C_BAMBOO_HI
            elif y <= 17:
                col = C_BAMBOO_LGT
            elif y <= 20:
                col = C_BAMBOO_MID
            else:
                col = C_BAMBOO_SHD
            im.putpixel((ox + x, oy + y), col)

    # Abaca rope lashings tying bamboo slats
    for rx in range(4, pw, 12):
        for ry in range(13, 25):
            im.putpixel((ox + rx, oy + ry), C_ROPE_MID if ry % 2 == 0 else C_ROPE_LGT)

    # Note for bridge: Top deck is at y=14. To make top surface start at y=0, we shift deck or define specs!
    # Let's place the bamboo walking deck at y=0..10 so collision at y=0 is 100% flush!
    # Let's redraw bridge with walking surface starting at y=0:
    for y in range(ph):
        for x in range(pw):
            im.putpixel((ox + x, oy + y), (0, 0, 0, 0))

    # Clean walking deck from y = 0 to 12
    for x in range(pw):
        is_slat_gap = (x % 7 == 0)
        for y in range(0, 12):
            if is_slat_gap:
                col = C_BAMBOO_SHD
            elif y == 0:
                col = C_BAMBOO_HI
            elif y <= 3:
                col = C_BAMBOO_LGT
            elif y <= 7:
                col = C_BAMBOO_MID
            else:
                col = C_BAMBOO_SHD
            im.putpixel((ox + x, oy + y), col)

    # Support bamboo log runners and abaca rope bindings underneath (y = 12..36)
    for x in range(pw):
        for y in range(12, 22):
            im.putpixel((ox + x, oy + y), C_BAMBOO_MID if (y % 5 != 0) else C_BAMBOO_SHD)
    for rx in range(6, pw, 14):
        for ry in range(0, 32):
            col = C_ROPE_LGT if (rx + ry) % 3 == 0 else C_ROPE_MID
            im.putpixel((ox + rx, oy + ry), col)
            if rx + 1 < pw:
                im.putpixel((ox + rx + 1, oy + ry), col)

    # --- 4. crumble: Rect2(128, 64, 96, 48) ---
    # 100% VISIBLE BRITTLE LIMESTONE SHELF WITH VISIBLE FISSURES & ROCK CRUST
    ox, oy, pw, ph = 128, 64, 96, 48
    for x in range(pw):
        # Tapered cracked profile
        dist_from_center = abs(x - (pw * 0.5)) / (pw * 0.5)
        max_depth = int(38 - (dist_from_center ** 1.4) * 24)
        if x < 4 or x >= pw - 4:
            max_depth = max(6, max_depth - 8)

        for y in range(max_depth):
            noise = math.sin(x * 0.6) * 0.5 + math.cos(y * 0.5) * 0.5
            is_crack = ((x * 3 + y * 7) % 17 == 0) or ((x - y * 2) % 19 == 0 and y > 4)

            if is_crack:
                col = C_LIME_DARKEST
            elif y == 0:
                # Solid visible brittle top edge!
                col = (195, 175, 140, 255) if noise > 0.2 else (160, 140, 115, 255)
            elif y <= 2:
                col = (145, 125, 100, 255) if noise > 0.0 else (120, 100, 80, 255)
            elif y <= 8:
                col = C_LIME_LIGHT if noise > 0.2 else C_LIME_MID
            elif y <= 18:
                col = C_LIME_MID if noise > -0.2 else C_LIME_DEEP
            else:
                col = C_LIME_DEEP if noise > 0.1 else C_LIME_DARKEST

            im.putpixel((ox + x, oy + y), col)

    # --- 5. sanctuary: Rect2(0, 104, 160, 56) ---
    # Wide ancestral limestone terrace with carved pre-colonial reliefs
    ox, oy, pw, ph = 0, 104, 160, 56
    for x in range(pw):
        dist_from_center = abs(x - (pw * 0.5)) / (pw * 0.5)
        max_depth = int(54 - (dist_from_center ** 1.8) * 34)
        if x < 4 or x >= pw - 4:
            max_depth = max(10, max_depth - 12)

        for y in range(max_depth):
            noise = math.sin(x * 0.25) * 0.5 + math.cos(y * 0.35) * 0.5
            is_relief_band = (10 <= y <= 16)
            is_relief_motif = is_relief_band and ((x % 16 < 4) or ((x + y) % 8 == 0))

            if y == 0:
                col = C_LIME_CREST if noise > 0.0 else C_LIME_LIGHT
            elif y <= 2:
                col = C_MOSS_LIGHT if noise > 0.3 else C_LIME_LIGHT
            elif is_relief_motif:
                col = (185, 155, 95, 255) # Ancient gold / ochre carved relief
            elif is_relief_band:
                col = C_LIME_DARKEST
            elif y <= 24:
                col = C_LIME_MID if noise > -0.2 else C_LIME_DEEP
            else:
                col = C_LIME_DEEP if noise > 0.0 else C_LIME_DARKEST

            im.putpixel((ox + x, oy + y), col)

    out_p = os.path.join(OUT_DIR, "cave_platforms.png")
    im.save(out_p, "PNG")
    print(f"Generated {out_p} (size: {im.size})")


def build_cave_props():
    """
    Builds cave_props.png (320x160):
    - Rect2(0, 0, 64, 64):   Manunggul Secondary Burial Jar & Ancient Pottery (Palawan cave icon)
    - Rect2(64, 0, 64, 96):  Carved Wooden Anito / Haliya Moon Totem (Likha)
    - Rect2(128, 0, 64, 64): Subterranean River Ferns (Pako) & Hanging Balete Vines
    - Rect2(192, 0, 96, 64): Natural Limestone Ceiling Stalactite Cluster (Tusok ng Bato)
    - Rect2(0, 64, 32, 64):  Philippine Bamboo Torch (Sulo) with rattan cords
    - Rect2(64, 64, 96, 32): Limestone Stalagmite Hazard Bed (Tusok ng Bato)
    - Rect2(160, 64, 64, 64): Resonant Moon Pearl (Mutya ng Haliya) for Pogo Bounces
    - Rect2(224, 64, 48, 48): Traditional Terracotta Clay Palayok Pot
    """
    im = Image.new("RGBA", (320, 160), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # ── 1. Manunggul Jar: Rect2(0, 0, 64, 64) ──────────────────────────────────
    # The world-famous pre-colonial burial jar discovered in Manunggul Cave, Palawan.
    # Features round bulbous clay body with carved wave incised patterns, a lid,
    # and two boatmen paddling the vessel into the afterlife.
    jx, jy = 32, 42  # Jar center
    # Jar body (clay oval)
    for dy in range(-16, 18):
        for dx in range(-20, 21):
            if (dx / 20.0) ** 2 + (dy / 17.0) ** 2 <= 1.0:
                d = (dx / 20.0) ** 2 + (dy / 17.0) ** 2
                # Shading
                if dx < -6:
                    col = C_CLAY_LIGHT
                elif dx > 6:
                    col = C_CLAY_DARK
                else:
                    col = C_CLAY_MID
                # Incised scroll / wave line around shoulder
                if -6 <= dy <= -2 and (dx + dy) % 4 == 0:
                    col = C_CLAY_SHADOW
                im.putpixel((jx + dx, jy + dy), col)

    # Jar Lid & Boat of the Dead on top
    # Lid rim
    for lx in range(-14, 15):
        im.putpixel((jx + lx, jy - 17), C_CLAY_LIGHT if lx < 0 else C_CLAY_MID)
        im.putpixel((jx + lx, jy - 18), C_CLAY_MID)

    # Boat silhouette on lid (y = 16..22)
    for bx in range(-11, 12):
        im.putpixel((jx + bx, jy - 19), C_CLAY_DARK)
        im.putpixel((jx + bx, jy - 20), C_CLAY_MID)
    # Prow and stern curves upward
    im.putpixel((jx - 12, jy - 21), C_CLAY_LIGHT)
    im.putpixel((jx + 12, jy - 21), C_CLAY_LIGHT)

    # Two boatmen figures
    # Front boatman (steersman with paddle)
    im.putpixel((jx - 5, jy - 22), C_CLAY_LIGHT)
    im.putpixel((jx - 5, jy - 23), C_CLAY_HI) # Head
    im.putpixel((jx - 6, jy - 21), C_CLAY_MID) # Arms holding paddle
    im.putpixel((jx - 7, jy - 20), C_CLAY_DARK)
    im.putpixel((jx - 8, jy - 19), C_CLAY_SHADOW)
    # Rear boatman (soul with crossed arms)
    im.putpixel((jx + 5, jy - 22), C_CLAY_LIGHT)
    im.putpixel((jx + 5, jy - 23), C_CLAY_HI) # Head

    # ── 2. Carved Wooden Anito / Haliya Moon Totem: Rect2(64, 0, 64, 96) ───────
    # Weathered Kamagong/Narra timber idol with carved crescent moon emblem and abaca cord bindings.
    tx = 64 + 32
    # Wooden post (width 22, height 80 from y = 14 to 94)
    for y in range(14, 94):
        for dx in range(-11, 12):
            grain = math.sin((dx + y * 0.15) * 1.2)
            if dx == -11:
                col = (68, 48, 28, 255)
            elif dx < -4:
                col = (98, 72, 42, 255)
            elif dx > 6:
                col = (48, 32, 18, 255)
            else:
                col = (82, 58, 34, 255) if grain > 0 else (68, 48, 28, 255)

            # Abaca cord ties at y = 30..33 and y = 65..68
            if (30 <= y <= 33 or 65 <= y <= 68):
                col = C_ROPE_LGT if (dx + y) % 3 == 0 else C_ROPE_MID

            im.putpixel((tx + dx, y), col)

    # Carved Moon Crescent Symbol on totem head (y = 20..38)
    for cy in range(-8, 9):
        for cx in range(-8, 9):
            r1 = cx * cx + cy * cy
            r2 = (cx - 3) * (cx - 3) + cy * cy
            if r1 <= 49 and r2 > 25:
                # Crescent moon inlay (radiant silver shell / mother-of-pearl)
                im.putpixel((tx + cx, 28 + cy), C_MOON_WHITE if cx < 0 else C_MOON_CYAN)

    # ── 3. Subterranean Ferns (Pako) & Balete Roots: Rect2(128, 0, 64, 64) ──────
    fx = 128 + 32
    # Arching fern fronds
    frond_offsets = [
        (-22, 58, -14, 38, -6, 26),
        (22, 58, 14, 38, 6, 26),
        (-12, 58, -8, 34, -2, 20),
        (12, 58, 8, 34, 2, 20),
        (0, 58, 0, 30, 0, 16)
    ]
    for x0, y0, x1, y1, x2, y2 in frond_offsets:
        # Draw curved stem
        for t in np.linspace(0, 1, 24):
            sx = int((1 - t)**2 * x0 + 2 * (1 - t) * t * x1 + t**2 * x2)
            sy = int((1 - t)**2 * y0 + 2 * (1 - t) * t * y1 + t**2 * y2)
            im.putpixel((fx + sx, sy), C_MOSS_LIGHT)
            # Side pinnae (leaflets)
            im.putpixel((fx + sx - 1, sy), C_MOSS_MID)
            im.putpixel((fx + sx + 1, sy), C_MOSS_BRIGHT)

    # Hanging Balete root tendrils from ceiling
    for rx in [-18, -6, 8, 20]:
        rlen = random.randint(16, 32)
        for ry in range(rlen):
            im.putpixel((fx + rx, ry), C_ROPE_MID if (rx + ry) % 4 != 0 else C_ROPE_DARK)

    # ── 4. Natural Limestone Stalactite Cluster: Rect2(192, 0, 96, 64) ──────────
    # Hanging from ceiling y=0 down to y=58. Natural multi-pointed speleothems.
    sx0 = 192
    points = [
        (16, 38, 7),   # x, length, base_half_width
        (32, 56, 10),
        (48, 44, 8),
        (66, 60, 11),
        (82, 34, 6)
    ]
    for px, plen, pw in points:
        for y in range(plen):
            w = max(1, int(pw * (1.0 - (y / float(plen)) ** 0.85)))
            for dx in range(-w, w + 1):
                d_frac = dx / float(w) if w > 0 else 0
                if d_frac < -0.3:
                    col = C_LIME_CREST if y < 4 else C_LIME_LIGHT
                elif d_frac > 0.3:
                    col = C_LIME_DARKEST
                else:
                    col = C_LIME_MID
                # Wet drip tip
                if y == plen - 1:
                    col = (190, 235, 255, 255)
                im.putpixel((sx0 + px + dx, y), col)

    # ── 5. Philippine Bamboo Torch (Sulo): Rect2(0, 64, 32, 64) ────────────────
    # Slender cured bamboo pole with rattan twine and glowing flame head.
    tx = 16
    # Bamboo pole from y = 84 to 126
    for y in range(84, 126):
        im.putpixel((tx - 1, y), C_BAMBOO_SHD)
        im.putpixel((tx, y), C_BAMBOO_MID)
        im.putpixel((tx + 1, y), C_BAMBOO_LGT)
        if y % 12 == 0:
            im.putpixel((tx - 1, y), C_ROPE_MID)
            im.putpixel((tx, y), C_ROPE_LGT)
            im.putpixel((tx + 1, y), C_ROPE_MID)

    # Coconut husk torch head at y = 80..86
    for dx in range(-3, 4):
        for dy in range(7):
            im.putpixel((tx + dx, 80 + dy), C_ROPE_DARK if dx < 0 else C_ROPE_MID)

    # Flickering flame (y = 66..80)
    for fy in range(66, 80):
        fw = max(1, int(4 * (1.0 - (80 - fy) / 14.0)))
        for fdx in range(-fw, fw + 1):
            if abs(fdx) == 0:
                col = (255, 245, 185, 255) # White-hot core
            elif abs(fdx) == 1:
                col = (255, 180, 45, 255)  # Golden flame
            else:
                col = (235, 95, 25, 255)   # Amber edge
            im.putpixel((tx + fdx, fy), col)

    # ── 6. Limestone Stalagmite Hazard Bed: Rect2(64, 64, 96, 32) ───────────────
    # Sharp natural limestone stalagmite spears rising from the cavern floor (y=64..96).
    hx0 = 64
    stalagmites = [
        (8, 22, 6),
        (22, 28, 7),
        (38, 20, 5),
        (52, 30, 8),
        (68, 24, 6),
        (84, 28, 7)
    ]
    for sx, sh, sw in stalagmites:
        for dy in range(sh):
            y = 95 - dy
            w = max(1, int(sw * (1.0 - dy / float(sh))))
            for dx in range(-w, w + 1):
                d_frac = dx / float(w) if w > 0 else 0
                if d_frac < -0.3:
                    col = C_LIME_CREST if dy > sh - 3 else C_LIME_LIGHT
                elif d_frac > 0.3:
                    col = C_LIME_DARKEST
                else:
                    col = C_LIME_MID
                # Sharp needle tip
                if dy == sh - 1:
                    col = (235, 245, 255, 255)
                im.putpixel((hx0 + sx + dx, y), col)

    # ── 7. Resonant Moon Pearl (Mutya ng Haliya): Rect2(160, 64, 64, 64) ───────
    # Sacred glowing moon pearl nestled in ancient limestone and abaca roots.
    # Emits Haliya's gentle silver-blue moon radiance for the pogo bounce mechanic.
    mx, my = 160 + 32, 64 + 32
    # Ancient limestone geode shell
    for dy in range(-20, 21):
        for dx in range(-20, 21):
            r = math.sqrt(dx * dx + dy * dy)
            if 14.0 <= r <= 20.0:
                noise = math.sin(dx * 0.5) + math.cos(dy * 0.5)
                col = C_LIME_LIGHT if (dx < 0 and noise > 0) else C_LIME_DEEP
                im.putpixel((mx + dx, my + dy), col)
            elif r < 14.0:
                # Glowing celestial pearl
                norm = r / 14.0
                if norm < 0.3:
                    col = C_MOON_WHITE
                elif norm < 0.65:
                    col = C_MOON_CYAN
                else:
                    col = C_MOON_MID
                im.putpixel((mx + dx, my + dy), col)

    # ── 8. Traditional Clay Palayok Pot: Rect2(224, 64, 48, 48) ───────────────
    px, py = 224 + 24, 64 + 32
    for dy in range(-12, 14):
        for dx in range(-14, 15):
            if (dx / 14.0) ** 2 + (dy / 13.0) ** 2 <= 1.0:
                if dx < -4:
                    col = C_CLAY_LIGHT
                elif dx > 4:
                    col = C_CLAY_DARK
                else:
                    col = C_CLAY_MID
                # Earthenware rim lip
                if dy <= -9:
                    col = C_CLAY_HI if dx < 0 else C_CLAY_MID
                im.putpixel((px + dx, py + dy), col)

    out_p = os.path.join(OUT_DIR, "cave_props.png")
    im.save(out_p, "PNG")
    print(f"Generated {out_p} (size: {im.size})")


if __name__ == "__main__":
    build_cave_rock_tiles()
    build_cave_platforms()
    build_cave_props()
    print("ALL PHILIPPINE CAVE ASSETS CRAFTED SUCCESSFULLY!")

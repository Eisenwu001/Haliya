import os
import math
from PIL import Image, ImageDraw

UI_DIR = "assets/ui"
os.makedirs(UI_DIR, exist_ok=True)

def create_progress_track_frame():
    # Width 228, Height 14. Inner channel: X=6..221 (width 216), Y=3..10 (height 8)
    w, h = 228, 14
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Recessed channel
    for y in range(3, 11):
        for x in range(6, 222):
            if y == 3:
                im.putpixel((x, y), (10, 12, 18, 240)) # inner top shadow
            elif y == 10:
                im.putpixel((x, y), (22, 26, 36, 220)) # inner bottom bevel
            else:
                im.putpixel((x, y), (14, 18, 26, 235)) # deep obsidian

    # Horizontal bronze rails
    # Top rail Y=1, 2
    for x in range(5, 223):
        im.putpixel((x, 1), (130, 100, 55, 255))
        im.putpixel((x, 2), (210, 175, 95, 255)) # highlight rail
    # Bottom rail Y=11, 12
    for x in range(5, 223):
        im.putpixel((x, 11), (170, 135, 75, 255))
        im.putpixel((x, 12), (100, 75, 40, 255)) # shadow rail

    # Filigree left endcap (X=0..5, Y=1..12)
    left_points = [(5, 1), (2, 4), (0, 7), (2, 10), (5, 12)]
    for i in range(len(left_points)-1):
        draw.line([left_points[i], left_points[i+1]], fill=(195, 160, 85, 255), width=1)
    im.putpixel((1, 7), (245, 220, 135, 255))
    im.putpixel((3, 7), (180, 140, 70, 255))
    im.putpixel((4, 7), (140, 105, 50, 255))
    im.putpixel((2, 6), (220, 185, 100, 255))
    im.putpixel((2, 8), (160, 120, 60, 255))

    # Filigree right endcap (X=222..227, Y=1..12)
    right_points = [(222, 1), (225, 4), (227, 7), (225, 10), (222, 12)]
    for i in range(len(right_points)-1):
        draw.line([right_points[i], right_points[i+1]], fill=(195, 160, 85, 255), width=1)
    im.putpixel((226, 7), (245, 220, 135, 255))
    im.putpixel((224, 7), (180, 140, 70, 255))
    im.putpixel((223, 7), (140, 105, 50, 255))
    im.putpixel((225, 6), (220, 185, 100, 255))
    im.putpixel((225, 8), (160, 120, 60, 255))

    # Milestone notches at 25%, 50%, 75%
    for notch_x in [60, 114, 168]:
        im.putpixel((notch_x, 0), (235, 200, 115, 255))
        im.putpixel((notch_x, 1), (255, 235, 150, 255))
        im.putpixel((notch_x, 2), (180, 140, 70, 255))
        im.putpixel((notch_x, 11), (180, 140, 70, 255))
        im.putpixel((notch_x, 12), (235, 200, 115, 255))
        im.putpixel((notch_x, 13), (120, 90, 45, 255))

    out_path = os.path.join(UI_DIR, "progress_track_frame.png")
    im.save(out_path)
    print("Saved", out_path)

def create_progress_track_fill():
    # Width 216, Height 6
    w, h = 216, 6
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for x in range(w):
        # Subtle horizontal shimmer
        shimmer = math.sin(x * 0.15) * 10
        im.putpixel((x, 0), (255, min(255, int(245 + shimmer)), 180, 255)) # top bright rim
        im.putpixel((x, 1), (245, min(255, int(210 + shimmer)), 100, 255))
        im.putpixel((x, 2), (235, int(185 + shimmer), 60, 255))
        im.putpixel((x, 3), (220, int(165 + shimmer), 45, 255))
        im.putpixel((x, 4), (200, int(145 + shimmer), 35, 255))
        im.putpixel((x, 5), (160, 110, 25, 255)) # bottom darker edge
    out_path = os.path.join(UI_DIR, "progress_track_fill.png")
    im.save(out_path)
    print("Saved", out_path)

def create_progress_pin_haliya():
    # 16 x 18 pixel art of Haliya's Moon Mask
    w, h = 16, 18
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # 1. Outer golden aura contour
    aura = (255, 215, 95, 140)
    for x, y in [(7, 0), (8, 0), (4, 1), (11, 1), (2, 2), (13, 2),
                 (1, 4), (14, 4), (1, 8), (14, 8), (2, 12), (13, 12),
                 (4, 15), (11, 15), (6, 16), (9, 16), (7, 17), (8, 17)]:
        im.putpixel((x, y), aura)

    # 2. Crescent Horns / Crest (Y=1..4)
    crescent_outer = (90, 75, 55, 255)
    crescent_gold = (245, 235, 195, 255)
    crescent_hi = (255, 250, 230, 255)
    # Tips of crescent horns
    im.putpixel((3, 2), crescent_outer)
    im.putpixel((4, 2), crescent_hi)
    im.putpixel((5, 3), crescent_gold)
    im.putpixel((12, 2), crescent_outer)
    im.putpixel((11, 2), crescent_hi)
    im.putpixel((10, 3), crescent_gold)
    # Center crescent arch
    for x in range(6, 10):
        im.putpixel((x, 1), crescent_outer)
        im.putpixel((x, 2), crescent_hi)
        im.putpixel((x, 3), crescent_gold)

    # 3. Mask Oval Body (Y=4..13)
    mask_outline = (60, 50, 45, 255)
    mask_base = (220, 215, 205, 255)
    mask_shadow = (175, 170, 160, 255)
    mask_hi = (245, 242, 235, 255)

    for y in range(4, 14):
        # determine width
        if y in [4, 13]:
            x_start, x_end = 5, 10
        elif y in [5, 12]:
            x_start, x_end = 4, 11
        elif y in [6, 11]:
            x_start, x_end = 3, 12
        else:
            x_start, x_end = 2, 13

        for x in range(x_start, x_end + 1):
            if x == x_start or x == x_end:
                im.putpixel((x, y), mask_outline)
            elif x == x_start + 1 or y == 4:
                im.putpixel((x, y), mask_hi)
            elif x == x_end - 1 or y == 13:
                im.putpixel((x, y), mask_shadow)
            else:
                im.putpixel((x, y), mask_base)

    # 4. Facial Features (Eyes, Sorrow Tears)
    eye_col = (45, 35, 40, 255)
    tear_col = (95, 120, 160, 255)
    tear_dark = (65, 80, 110, 255)

    # Left eye slit
    im.putpixel((5, 7), eye_col)
    im.putpixel((6, 7), eye_col)
    # Right eye slit
    im.putpixel((9, 7), eye_col)
    im.putpixel((10, 7), eye_col)

    # Sorrow Tears running down
    im.putpixel((5, 8), tear_dark)
    im.putpixel((5, 9), tear_col)
    im.putpixel((5, 10), tear_col)
    im.putpixel((5, 11), tear_dark)

    im.putpixel((10, 8), tear_dark)
    im.putpixel((10, 9), tear_col)
    im.putpixel((10, 10), tear_col)
    im.putpixel((10, 11), tear_dark)

    # Mouth line
    im.putpixel((7, 11), (70, 60, 55, 255))
    im.putpixel((8, 11), (70, 60, 55, 255))

    # 5. Bottom pointer finial (Y=14..17)
    im.putpixel((6, 14), (160, 125, 60, 255))
    im.putpixel((7, 14), (255, 225, 120, 255))
    im.putpixel((8, 14), (255, 225, 120, 255))
    im.putpixel((9, 14), (160, 125, 60, 255))

    im.putpixel((7, 15), (255, 215, 90, 255))
    im.putpixel((8, 15), (235, 195, 70, 255))
    im.putpixel((7, 16), (245, 195, 65, 255))
    im.putpixel((8, 16), (195, 150, 45, 255))
    im.putpixel((7, 17), (210, 160, 50, 255))

    out_path = os.path.join(UI_DIR, "progress_pin_haliya.png")
    im.save(out_path)
    print("Saved", out_path)

def create_progress_pin_shrine():
    # 14 x 16 pixel art of Spirit Shrine Checkpoint Pip
    w, h = 14, 16
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Cyan spirit flame aura (Y=0..5)
    aura_cyan = (60, 180, 240, 120)
    flame_bright = (140, 235, 255, 255)
    flame_core = (245, 255, 255, 255)
    flame_outer = (45, 140, 215, 255)

    im.putpixel((6, 0), flame_core)
    im.putpixel((7, 0), flame_bright)
    for x in [5, 6, 7, 8]:
        im.putpixel((x, 1), flame_core if x in [6, 7] else flame_bright)
    for x in range(4, 10):
        im.putpixel((x, 2), flame_core if x in [6, 7] else flame_bright)
    for x in range(5, 9):
        im.putpixel((x, 3), flame_outer)

    # Ambient spirit sparks
    im.putpixel((3, 2), aura_cyan)
    im.putpixel((10, 1), aura_cyan)
    im.putpixel((4, 0), aura_cyan)

    # Bronze Brazier / Cup (Y=4..6)
    brazier_hi = (245, 205, 110, 255)
    brazier_mid = (195, 150, 65, 255)
    brazier_dark = (125, 90, 35, 255)

    for x in range(4, 10):
        im.putpixel((x, 4), brazier_hi if x in [5, 6, 7] else brazier_mid)
    for x in range(5, 9):
        im.putpixel((x, 5), brazier_mid if x in [6, 7] else brazier_dark)

    # Carved Stone Pillar / Altar Base (Y=6..15)
    stone_hi = (165, 175, 195, 255)
    stone_mid = (115, 125, 140, 255)
    stone_dark = (65, 75, 90, 255)

    # Pillar shaft (Y=6..11, X=5..8)
    for y in range(6, 12):
        im.putpixel((5, y), stone_hi)
        im.putpixel((6, y), stone_mid)
        im.putpixel((7, y), stone_mid)
        im.putpixel((8, y), stone_dark)
        # Engraved vertical groove
        if y in [7, 8, 9]:
            im.putpixel((6, y), (40, 50, 65, 255))

    # Stepped Base (Y=12..15)
    # Step 1 (X=4..9)
    for x in range(4, 10):
        im.putpixel((x, 12), stone_hi if x == 4 else (stone_dark if x == 9 else stone_mid))
        im.putpixel((x, 13), stone_dark if x in [4, 9] else stone_mid)
    # Step 2 (X=2..11)
    for x in range(2, 12):
        im.putpixel((x, 14), stone_hi if x in [2, 3] else (stone_dark if x in [10, 11] else stone_mid))
        im.putpixel((x, 15), stone_dark)

    out_path = os.path.join(UI_DIR, "progress_pin_shrine.png")
    im.save(out_path)
    print("Saved", out_path)

def create_progress_pin_boss():
    # 18 x 18 pixel art of Crossed Kris Daggers Boss Marker
    w, h = 18, 18
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Blood/omen aura behind center
    omen = (220, 50, 50, 130)
    for x in range(7, 11):
        for y in range(7, 11):
            im.putpixel((x, y), omen)

    steel_hi = (245, 250, 255, 255)
    steel_mid = (195, 205, 220, 255)
    steel_dark = (90, 100, 120, 255)
    steel_edge = (45, 50, 65, 255)

    gold_hi = (255, 225, 120, 255)
    gold_mid = (195, 150, 60, 255)
    gold_dark = (120, 85, 30, 255)

    # Kris 1: Top-Left to Bottom-Right (\)
    # Blade wavy coords
    k1_blade = [
        (2, 2), (3, 3), (3, 4), (4, 4), (5, 5), (5, 6), (6, 6), (7, 7), (8, 8), (9, 9)
    ]
    for x, y in k1_blade:
        im.putpixel((x, y), steel_hi)
        if x + 1 < w and y < h:
            im.putpixel((x + 1, y), steel_dark)
        if x - 1 >= 0 and y < h:
            im.putpixel((x - 1, y), steel_edge)

    # Guard and Hilt for Kris 1
    im.putpixel((10, 10), gold_hi)
    im.putpixel((11, 9), gold_dark)
    im.putpixel((9, 11), gold_dark)
    im.putpixel((11, 11), gold_mid)
    im.putpixel((12, 12), gold_mid)
    im.putpixel((13, 13), gold_dark)
    # Kakatua pommel curve
    im.putpixel((14, 13), gold_hi)
    im.putpixel((14, 14), gold_mid)

    # Kris 2: Top-Right to Bottom-Left (/)
    k2_blade = [
        (15, 2), (14, 3), (14, 4), (13, 4), (12, 5), (12, 6), (11, 6), (10, 7), (9, 8), (8, 9)
    ]
    for x, y in k2_blade:
        im.putpixel((x, y), steel_hi)
        if x - 1 >= 0 and y < h:
            im.putpixel((x - 1, y), steel_dark)
        if x + 1 < w and y < h:
            im.putpixel((x + 1, y), steel_edge)

    # Guard and Hilt for Kris 2
    im.putpixel((7, 10), gold_dark)
    im.putpixel((8, 10), gold_hi)
    im.putpixel((6, 11), gold_mid)
    im.putpixel((5, 12), gold_mid)
    im.putpixel((4, 13), gold_dark)
    im.putpixel((3, 13), gold_hi)
    im.putpixel((3, 14), gold_mid)

    # Center crossing clash spark
    im.putpixel((8, 8), (255, 255, 255, 255))
    im.putpixel((9, 8), (255, 240, 160, 255))
    im.putpixel((8, 9), (255, 210, 100, 255))

    out_path = os.path.join(UI_DIR, "progress_pin_boss.png")
    im.save(out_path)
    print("Saved", out_path)

def create_loading_bar_assets():
    # Loading bar frame: 348 x 20. Inner channel: X=6..341 (width 336), Y=4..15 (height 12)
    w, h = 348, 20
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Recessed inner channel backing
    for y in range(4, 16):
        for x in range(6, 342):
            if y == 4:
                im.putpixel((x, y), (8, 8, 14, 255))
            elif y == 15:
                im.putpixel((x, y), (20, 20, 30, 230))
            else:
                im.putpixel((x, y), (12, 10, 18, 250))

    # Top and bottom gilded rails
    for x in range(5, 343):
        im.putpixel((x, 1), (120, 95, 50, 255))
        im.putpixel((x, 2), (230, 195, 110, 255)) # bright top rim
        im.putpixel((x, 3), (160, 125, 65, 255))
        im.putpixel((x, 16), (160, 125, 65, 255))
        im.putpixel((x, 17), (210, 175, 95, 255))
        im.putpixel((x, 18), (95, 70, 35, 255))

    # Winged filigree endcaps Left (X=0..5)
    for y in range(2, 18):
        im.putpixel((5, y), (180, 140, 75, 255))
    im.putpixel((4, 2), (210, 175, 95, 255))
    im.putpixel((3, 3), (235, 205, 125, 255))
    im.putpixel((2, 5), (195, 155, 80, 255))
    im.putpixel((1, 8), (245, 220, 140, 255))
    im.putpixel((0, 9), (255, 240, 180, 255))
    im.putpixel((0, 10), (255, 240, 180, 255))
    im.putpixel((1, 11), (245, 220, 140, 255))
    im.putpixel((2, 14), (195, 155, 80, 255))
    im.putpixel((3, 16), (235, 205, 125, 255))
    im.putpixel((4, 17), (160, 120, 60, 255))

    # Winged filigree endcaps Right (X=342..347)
    for y in range(2, 18):
        im.putpixel((342, y), (180, 140, 75, 255))
    im.putpixel((343, 2), (210, 175, 95, 255))
    im.putpixel((344, 3), (235, 205, 125, 255))
    im.putpixel((345, 5), (195, 155, 80, 255))
    im.putpixel((346, 8), (245, 220, 140, 255))
    im.putpixel((347, 9), (255, 240, 180, 255))
    im.putpixel((347, 10), (255, 240, 180, 255))
    im.putpixel((346, 11), (245, 220, 140, 255))
    im.putpixel((345, 14), (195, 155, 80, 255))
    im.putpixel((344, 16), (235, 205, 125, 255))
    im.putpixel((343, 17), (160, 120, 60, 255))

    # 4 Corner Diamond Rivets
    for rx, ry in [(8, 2), (339, 2), (8, 17), (339, 17)]:
        im.putpixel((rx, ry), (255, 245, 180, 255))
        im.putpixel((rx-1, ry), (200, 160, 80, 255))
        im.putpixel((rx+1, ry), (200, 160, 80, 255))
        im.putpixel((rx, ry-1), (200, 160, 80, 255))
        im.putpixel((rx, ry+1), (150, 110, 50, 255))

    frame_path = os.path.join(UI_DIR, "loading_bar_frame.png")
    im.save(frame_path)
    print("Saved", frame_path)

    # Loading bar fill: 336 x 12
    fw, fh = 336, 12
    im_fill = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    for x in range(fw):
        prog = x / float(fw)
        # Lunar-blue to cyan gradient with celestial energy waves
        r_base = int(35 + prog * 45)
        g_base = int(120 + prog * 85)
        b_base = int(195 + prog * 55)

        for y in range(fh):
            if y == 0:
                im_fill.putpixel((x, y), (min(255, r_base + 110), min(255, g_base + 70), 255, 255))
            elif y == 1:
                im_fill.putpixel((x, y), (min(255, r_base + 60), min(255, g_base + 40), 245, 255))
            elif y == fh - 1:
                im_fill.putpixel((x, y), (max(0, r_base - 15), max(0, g_base - 20), b_base - 30, 255))
            else:
                im_fill.putpixel((x, y), (r_base, g_base, b_base, 255))

    fill_path = os.path.join(UI_DIR, "loading_bar_fill.png")
    im_fill.save(fill_path)
    print("Saved", fill_path)

def create_menu_button_assets():
    # Width 200, Height 24
    w, h = 200, 24

    # 1. Normal State
    im_norm = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Dark ironwood/stone texture with subtle horizontal grain
    for y in range(h):
        for x in range(w):
            grain = (math.sin(x * 0.1) * 3) + ((x * y) % 3)
            r = int(14 + grain)
            g = int(18 + grain)
            b = int(26 + grain)
            im_norm.putpixel((x, y), (r, g, b, 230))

    # Outer 1px subtle dark-bronze border
    for x in range(w):
        im_norm.putpixel((x, 0), (65, 60, 50, 180))
        im_norm.putpixel((x, h-1), (45, 40, 35, 200))
    for y in range(h):
        im_norm.putpixel((w-1, y), (55, 50, 42, 180))

    # Left solid bronze accent bar (3px width, X=0..2)
    for y in range(h):
        im_norm.putpixel((0, y), (135, 100, 50, 255))
        im_norm.putpixel((1, y), (195, 155, 80, 255))
        im_norm.putpixel((2, y), (145, 110, 55, 255))

    # Four Ornamental Bronze Corner Brackets
    # Top-right bracket
    im_norm.putpixel((w-2, 1), (215, 175, 95, 255))
    im_norm.putpixel((w-3, 1), (215, 175, 95, 255))
    im_norm.putpixel((w-2, 2), (215, 175, 95, 255))
    # Bottom-right bracket
    im_norm.putpixel((w-2, h-2), (180, 140, 70, 255))
    im_norm.putpixel((w-3, h-2), (180, 140, 70, 255))
    im_norm.putpixel((w-2, h-3), (180, 140, 70, 255))
    # Top-left bracket
    im_norm.putpixel((3, 1), (230, 190, 105, 255))
    im_norm.putpixel((4, 1), (230, 190, 105, 255))
    im_norm.putpixel((3, 2), (230, 190, 105, 255))
    # Bottom-left bracket
    im_norm.putpixel((3, h-2), (180, 140, 70, 255))
    im_norm.putpixel((4, h-2), (180, 140, 70, 255))
    im_norm.putpixel((3, h-3), (180, 140, 70, 255))

    norm_path = os.path.join(UI_DIR, "menu_btn_normal.png")
    im_norm.save(norm_path)
    print("Saved", norm_path)

    # 2. Hover / Focused State (Gilded glow, radiant corner filigree, 4px incandescent gold left bar)
    im_hov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y in range(h):
        for x in range(w):
            # Rich luminous tone with subtle warm golden center wash
            dist_left = x / float(w)
            warmth = max(0.0, 1.0 - dist_left * 0.8) * 18
            r = int(24 + warmth)
            g = int(30 + warmth * 0.9)
            b = int(45 + warmth * 0.4)
            im_hov.putpixel((x, y), (r, g, b, 245))

    # Top inner golden highlight rim
    for x in range(4, w-1):
        im_hov.putpixel((x, 1), (255, 240, 175, 120))

    # Outer 1px crisp gold border trim
    for x in range(w):
        im_hov.putpixel((x, 0), (225, 190, 100, 255))
        im_hov.putpixel((x, h-1), (180, 140, 65, 255))
    for y in range(h):
        im_hov.putpixel((w-1, y), (205, 165, 80, 255))

    # Left incandescent gold bar (4px width, X=0..3)
    for y in range(h):
        im_hov.putpixel((0, y), (215, 170, 70, 255))
        im_hov.putpixel((1, y), (255, 245, 170, 255)) # intense bright highlight
        im_hov.putpixel((2, y), (255, 220, 100, 255))
        im_hov.putpixel((3, y), (225, 180, 80, 255))

    # Radiant Gilded Filigree Corner Brackets (4x4 chevrons)
    # Top-right
    for dx, dy in [(1, 1), (2, 1), (3, 1), (4, 1), (1, 2), (1, 3), (1, 4), (2, 2)]:
        im_hov.putpixel((w - 1 - dx, dy), (255, 240, 150, 255))
    # Bottom-right
    for dx, dy in [(1, 1), (2, 1), (3, 1), (4, 1), (1, 2), (1, 3), (1, 4), (2, 2)]:
        im_hov.putpixel((w - 1 - dx, h - 1 - dy), (225, 185, 90, 255))
    # Top-left
    for dx, dy in [(4, 1), (5, 1), (6, 1), (4, 2), (4, 3), (5, 2)]:
        im_hov.putpixel((dx, dy), (255, 245, 170, 255))
    # Bottom-left
    for dx, dy in [(4, 1), (5, 1), (6, 1), (4, 2), (4, 3), (5, 2)]:
        im_hov.putpixel((dx, h - 1 - dy), (225, 185, 90, 255))

    hov_path = os.path.join(UI_DIR, "menu_btn_hover.png")
    im_hov.save(hov_path)
    print("Saved", hov_path)

    # 3. Pressed State (Warm amber compressed plaque)
    im_press = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y in range(h):
        for x in range(w):
            im_press.putpixel((x, y), (36, 28, 20, 255))
    for x in range(w):
        im_press.putpixel((x, 0), (140, 95, 45, 255))
        im_press.putpixel((x, h-1), (200, 145, 60, 255))
    for y in range(h):
        im_press.putpixel((w-1, y), (160, 110, 50, 255))
        im_press.putpixel((0, y), (180, 110, 40, 255))
        im_press.putpixel((1, y), (255, 205, 110, 255))
        im_press.putpixel((2, y), (220, 150, 60, 255))

    press_path = os.path.join(UI_DIR, "menu_btn_pressed.png")
    im_press.save(press_path)
    print("Saved", press_path)

if __name__ == "__main__":
    create_progress_track_frame()
    create_progress_track_fill()
    create_progress_pin_haliya()
    create_progress_pin_shrine()
    create_progress_pin_boss()
    create_loading_bar_assets()
    create_menu_button_assets()
    print("ALL UI ASSETS GENERATED SUCCESSFULLY!")

import os
import math
from PIL import Image, ImageDraw

UI_DIR = "assets/ui"
os.makedirs(UI_DIR, exist_ok=True)

def create_celestial_astrolabe():
    # 240 x 240 pixel art circular astrolabe ring with 7 moon phases and constellation arcs
    w, h = 240, 240
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = w // 2, h // 2

    # Concentric gold and lunar cyan rings
    rings = [
        {"r": 110, "col": (205, 165, 80, 160), "w": 1},
        {"r": 104, "col": (140, 110, 55, 120), "w": 1},
        {"r": 88,  "col": (90, 180, 235, 130), "w": 1},
        {"r": 72,  "col": (195, 155, 75, 140), "w": 1},
        {"r": 54,  "col": (120, 160, 210, 110), "w": 1},
        {"r": 36,  "col": (225, 190, 95, 150), "w": 1}
    ]

    for ring in rings:
        r = ring["r"]
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=ring["col"], width=ring["w"])

    # Radial spokes (12 zodiac / mythological spokes)
    for i in range(12):
        angle = i * (math.pi / 6.0)
        x1 = cx + math.cos(angle) * 72
        y1 = cy + math.sin(angle) * 72
        x2 = cx + math.cos(angle) * 104
        y2 = cy + math.sin(angle) * 104
        draw.line([(x1, y1), (x2, y2)], fill=(185, 145, 70, 90), width=1)

    # 7 Sacred Moon Phase Glyphs positioned around the outer ring (r=96)
    r_moons = 96
    for i in range(7):
        angle = i * (2.0 * math.pi / 7.0) - (math.pi / 2.0)
        mx = int(cx + math.cos(angle) * r_moons)
        my = int(cy + math.sin(angle) * r_moons)

        # Draw a small 9x9 moon glyph
        # Outer golden ring for moon glyph
        draw.ellipse([mx - 4, my - 4, mx + 4, my + 4], outline=(235, 200, 110, 200), width=1)
        # Moon phase interior
        if i == 0: # New moon / Dark moon
            im.putpixel((mx, my), (20, 25, 40, 220))
        elif i == 3: # Full moon / Brilliant Eclipse
            draw.ellipse([mx - 2, my - 2, mx + 2, my + 2], fill=(255, 245, 180, 255))
        else: # Crescent / Gibbous
            draw.ellipse([mx - 2, my - 2, mx + 2, my + 2], fill=(210, 230, 255, 180))
            # Cutout shadow for crescent
            draw.ellipse([mx - 1, my - 2, mx + 3, my + 2], fill=(12, 16, 24, 200))

    # Inner 8-pointed star compass at center
    for i in range(8):
        angle = i * (math.pi / 4.0)
        r_inner = 18 if (i % 2 == 0) else 10
        x = cx + math.cos(angle) * r_inner
        y = cy + math.sin(angle) * r_inner
        draw.line([(cx, cy), (x, y)], fill=(245, 215, 120, 180), width=1)

    out_path = os.path.join(UI_DIR, "celestial_astrolabe.png")
    im.save(out_path)
    print("Saved", out_path)

def create_menu_preview_panel():
    # 220 x 180 ornate dark fantasy plaque for center preview
    w, h = 220, 180
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Semi-translucent dark slate/obsidian body
    for y in range(h):
        for x in range(w):
            # Subtle stone texture
            grain = ((x * 7 + y * 13) % 5) - 2
            r = max(0, min(255, 14 + grain))
            g = max(0, min(255, 18 + grain))
            b = max(0, min(255, 28 + grain))
            im.putpixel((x, y), (r, g, b, 230))

    # Outer 1px bronze border
    draw.rectangle([0, 0, w - 1, h - 1], outline=(150, 115, 60, 240), width=1)
    # Inner 1px highlight line
    draw.rectangle([2, 2, w - 3, h - 3], outline=(70, 60, 45, 180), width=1)

    # Gilded filigree corner brackets (6x6 chevrons)
    corners = [
        (0, 0, 1, 1),
        (w - 1, 0, -1, 1),
        (0, h - 1, 1, -1),
        (w - 1, h - 1, -1, -1)
    ]
    for cx, cy, dx, dy in corners:
        # Corner diamond pip
        im.putpixel((cx + dx * 2, cy + dy * 2), (255, 235, 140, 255))
        # Filigree arms
        for step in range(1, 7):
            im.putpixel((cx + dx * step, cy + dy), (215, 175, 90, 255))
            im.putpixel((cx + dx, cy + dy * step), (215, 175, 90, 255))
        im.putpixel((cx + dx * 3, cy + dy * 3), (180, 140, 70, 255))

    # Top header banner line at Y=28
    for x in range(8, w - 8):
        im.putpixel((x, 28), (170, 135, 75, 200))
        im.putpixel((x, 29), (90, 70, 40, 150))
    # Center diamond on divider
    im.putpixel((w // 2, 28), (255, 240, 160, 255))
    im.putpixel((w // 2 - 1, 28), (210, 170, 85, 255))
    im.putpixel((w // 2 + 1, 28), (210, 170, 85, 255))
    im.putpixel((w // 2, 27), (210, 170, 85, 255))
    im.putpixel((w // 2, 29), (210, 170, 85, 255))

    # Bottom footer divider at Y=h-28
    for x in range(8, w - 8):
        im.putpixel((x, h - 28), (140, 110, 60, 180))
    im.putpixel((w // 2, h - 28), (235, 205, 115, 255))

    out_path = os.path.join(UI_DIR, "menu_preview_panel.png")
    im.save(out_path)
    print("Saved", out_path)

def create_menu_god_ray():
    # 120 x 280 soft angled volumetric light shaft
    w, h = 120, 280
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Slanted beam from top-right to bottom-left
    for y in range(h):
        prog_y = y / float(h)
        # Center of beam drifts with y
        center_x = (w * 0.7) - prog_y * (w * 0.5)
        half_width = 18.0 + prog_y * 32.0 # expands downward
        intensity_y = math.sin(prog_y * math.pi) # peaks mid-height

        for x in range(w):
            dist = abs(x - center_x)
            if dist < half_width:
                factor = (1.0 - (dist / half_width)) ** 2.0
                alpha = int(factor * intensity_y * 55) # soft max alpha ~55
                im.putpixel((x, y), (210, 230, 255, alpha))

    out_path = os.path.join(UI_DIR, "menu_god_ray.png")
    im.save(out_path)
    print("Saved", out_path)

def create_menu_column_plaque():
    # 224 x 260 subtle dark stone alcove backing for the left menu list & title
    w, h = 224, 260
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Very subtle dark obsidian wash
    for y in range(h):
        prog_y = y / float(h)
        for x in range(w):
            prog_x = x / float(w)
            # Edge fade
            fade_x = min(1.0, prog_x * 8.0) * min(1.0, (1.0 - prog_x) * 8.0)
            fade_y = min(1.0, prog_y * 8.0) * min(1.0, (1.0 - prog_y) * 8.0)
            alpha = int(fade_x * fade_y * 140)
            im.putpixel((x, y), (8, 12, 18, alpha))

    # Subtle vertical bronze guide line on left and right
    for y in range(12, h - 12):
        im.putpixel((4, y), (140, 110, 60, 60))
        im.putpixel((w - 5, y), (140, 110, 60, 45))

    out_path = os.path.join(UI_DIR, "menu_column_plaque.png")
    im.save(out_path)
    print("Saved", out_path)

if __name__ == "__main__":
    create_celestial_astrolabe()
    create_menu_preview_panel()
    create_menu_god_ray()
    create_menu_column_plaque()
    print("ALL FULLNESS ASSETS CREATED SUCCESSFULLY!")

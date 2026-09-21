import math
import os
from PIL import Image, ImageDraw

os.makedirs("assets/vfx", exist_ok=True)

def create_puddle(w, h, filename, seed=0):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pixels = img.load()
    
    cx = (w - 1) / 2.0
    cy = (h - 1) / 2.0
    rx = cx - 1.0
    ry = cy - 0.5
    
    # Palette tailored to wet grass in dark stormy forest:
    c_edge_grass = (42, 58, 48, 110)
    c_edge_water = (32, 46, 64, 140)
    c_deep       = (26, 40, 58, 185)
    c_mid        = (44, 66, 92, 195)
    c_sky        = (75, 108, 142, 210)
    c_glint      = (135, 175, 210, 235)
    c_crest      = (190, 220, 245, 250)

    for y in range(h):
        for x in range(w):
            dx = (x - cx) / rx
            dy = (y - cy) / ry
            
            angle = math.atan2(dy, dx)
            wobble = 0.07 * math.sin(angle * 3.0 + seed) + 0.05 * math.cos(angle * 5.0 - seed * 1.5)
            d = math.sqrt(dx * dx + dy * dy) + wobble
            
            if d > 1.03:
                continue
            elif d > 0.85:
                # Soft blend into grass (no harsh black border)
                pixels[x, y] = c_edge_grass if y < cy else c_edge_water
            elif d > 0.65:
                pixels[x, y] = c_edge_water
            elif d > 0.35:
                # Sky reflection streak in upper-mid
                if -0.7 < dy < 0.1:
                    pixels[x, y] = c_sky if (x + y + int(seed)) % 2 == 0 else c_mid
                else:
                    pixels[x, y] = c_deep
            else:
                # Water surface reflection
                if -0.55 < dy < -0.05 and abs(dx) < 0.6:
                    if abs(dx) < 0.35 and (x * 3 + y * 7 + int(seed * 3)) % 3 == 0:
                        pixels[x, y] = c_crest
                    else:
                        pixels[x, y] = c_glint
                else:
                    pixels[x, y] = c_sky if (x + y + int(seed)) % 3 == 0 else c_mid

    img.save(filename, "PNG")
    print(f"Created: {filename} ({w}x{h})")

def create_singed_leaf(filename):
    size = 12
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = img.load()
    
    # Handcrafted 12x12 pixel art leaf
    c_stem   = (61, 40, 22, 255)
    c_green_d = (16, 43, 20, 255)   # Narra dark
    c_green_m = (27, 67, 30, 255)   # Narra mid
    c_green_l = (55, 115, 50, 255)  # Narra light / vein
    c_gold   = (178, 131, 51, 255)  # Heat singed gold
    c_burnt  = (32, 28, 24, 255)   # Charred edge
    c_hot    = (215, 150, 50, 255)  # Glowing singe
    
    leaf_map = [
        (1, 10, c_stem), (2, 9, c_stem),
        (2, 8, c_burnt), (3, 8, c_gold), (4, 8, c_green_d),
        (2, 7, c_burnt), (3, 7, c_green_d), (4, 7, c_green_m), (5, 7, c_green_d), (6, 7, c_gold),
        (3, 6, c_gold), (4, 6, c_green_m), (5, 6, c_green_l), (6, 6, c_green_m), (7, 6, c_gold), (8, 6, c_burnt),
        (3, 5, c_green_d), (4, 5, c_green_l), (5, 5, c_green_l), (6, 5, c_green_m), (7, 5, c_hot), (8, 5, c_burnt),
        (4, 4, c_green_m), (5, 4, c_green_l), (6, 4, c_green_m), (7, 4, c_gold), (8, 4, c_burnt), (9, 4, c_burnt),
        (5, 3, c_green_m), (6, 3, c_green_l), (7, 3, c_gold), (8, 3, c_burnt),
        (6, 2, c_gold), (7, 2, c_hot), (8, 2, c_burnt),
        (7, 1, c_burnt), (8, 1, c_burnt),
        (8, 0, c_burnt)
    ]
    
    for x, y, col in leaf_map:
        pixels[x, y] = col
        
    img.save(filename, "PNG")
    print(f"Created: {filename} ({size}x{size})")

def create_camera_rain_bead(filename):
    # Empty transparent pixel to prevent modern camera beads in 2D pixel art
    img = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    img.save(filename, "PNG")
    print(f"Created: {filename} (1x1 transparent)")

def create_crater_ember(filename):
    size = 8
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = img.load()
    
    cx, cy = 3.5, 3.5
    for y in range(size):
        for x in range(size):
            d = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            if d < 1.1:
                pixels[x, y] = (255, 255, 255, 255)
            elif d < 2.0:
                pixels[x, y] = (100, 225, 255, 240)
            elif d < 2.9:
                pixels[x, y] = (255, 150, 50, 180)
            elif d < 3.8:
                pixels[x, y] = (255, 80, 20, 85)

    img.save(filename, "PNG")
    print(f"Created: {filename} ({size}x{size})")

def make_streak(w, h, filename, alpha_peak=220):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pixels = img.load()
    for y in range(h):
        t = y / float(h - 1)
        if t < 0.2:
            a = int(alpha_peak * (t / 0.2))
        elif t > 0.7:
            a = int(alpha_peak * ((1.0 - t) / 0.3))
        else:
            a = alpha_peak
        for x in range(w):
            pixels[x, y] = (195, 220, 245, a)
    img.save(filename, "PNG")
    print(f"Created: {filename} ({w}x{h})")

if __name__ == "__main__":
    create_puddle(24, 6, "assets/vfx/puddle_small.png", seed=1.7)
    create_puddle(38, 8, "assets/vfx/puddle_medium.png", seed=4.2)
    create_puddle(52, 8, "assets/vfx/puddle_large.png", seed=8.5)
    create_singed_leaf("assets/vfx/singed_leaf.png")
    create_camera_rain_bead("assets/vfx/camera_rain_bead.png")
    create_crater_ember("assets/vfx/crater_ember.png")
    make_streak(1, 6, "assets/vfx/rain_streak_bg.png", 130)
    make_streak(2, 10, "assets/vfx/rain_streak_mid.png", 190)
    make_streak(2, 16, "assets/vfx/rain_streak_fg.png", 230)
    print("All pixel-art assets generated successfully!")

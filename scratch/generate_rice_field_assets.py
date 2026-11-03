import os
from PIL import Image, ImageDraw

os.makedirs("assets/rice_field", exist_ok=True)

def create_detailed_mud_puddle(width=144, height=34):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pixels = img.load()
    
    # Generate an organic, irregular puddle basin
    cx, cy = width / 2.0, height * 0.58
    rx, ry = (width - 12) / 2.0, (height - 8) / 2.0
    
    # 1. Mud / Wet Earthen Rim & Splatter
    import math
    for y in range(height):
        for x in range(width):
            nx = (x - cx) / rx
            ny = (y - cy) / ry
            # Add organic waviness
            noise = math.sin(x * 0.22) * 0.12 + math.cos(y * 0.35 + x * 0.1) * 0.08 + math.sin(x * 0.5) * 0.04
            dist = nx * nx + ny * ny + noise
            
            if dist <= 1.25:
                # Mud border
                if dist > 0.88:
                    # Outer mud fringe with dithering
                    shade = int((dist - 0.88) / 0.37 * 3)
                    if (x + y) % 2 == 0 or dist < 1.1:
                        if shade == 0:
                            pixels[x, y] = (74, 52, 34, 250)
                        elif shade == 1:
                            pixels[x, y] = (58, 40, 26, 255)
                        else:
                            pixels[x, y] = (42, 28, 18, 220 if (x * 7 + y * 13) % 3 != 0 else 0)
                elif dist > 0.70:
                    # Inner wet muddy shelf
                    pixels[x, y] = (46, 32, 22, 255)
                else:
                    # Murky flooded water basin
                    # Depth gradient from bottom/center
                    depth = 1.0 - (dist / 0.70)
                    r = int(28 + depth * 14)
                    g = int(48 + depth * 26)
                    b = int(44 + depth * 22)
                    pixels[x, y] = (r, g, b, 255)

    # 2. Add subtle water ripple rings & sky glints
    ripples = [
        (int(cx - 30), int(cy - 2), 22, 5),
        (int(cx + 25), int(cy + 1), 28, 6),
        (int(cx - 2), int(cy - 4), 16, 4)
    ]
    for rx_c, ry_c, r_w, r_h in ripples:
        for a_deg in range(0, 360, 6):
            rad = math.radians(a_deg)
            px = int(rx_c + math.cos(rad) * r_w)
            py = int(ry_c + math.sin(rad) * r_h)
            if 0 <= px < width and 0 <= py < height and pixels[px, py][3] > 200 and pixels[px, py][1] > 40:
                if 20 <= a_deg <= 160: # Top-facing highlight reflection
                    pixels[px, py] = (105, 155, 145, 230)
                elif 200 <= a_deg <= 340: # Soft shadow edge
                    pixels[px, py] = (22, 36, 34, 240)

    # Sky reflection glints (bright 16-bit highlights)
    glints = [
        (int(cx - 20), int(cy - 3), 6),
        (int(cx + 32), int(cy), 8),
        (int(cx - 5), int(cy - 5), 5),
        (int(cx + 10), int(cy + 2), 7)
    ]
    for gx, gy, gw in glints:
        for i in range(gw):
            if 0 <= gx + i < width and 0 <= gy < height and pixels[gx + i, gy][3] > 200:
                pixels[gx + i, gy] = (150, 205, 195, 255)
                if gy + 1 < height:
                    pixels[gx + i, gy + 1] = (80, 130, 122, 240)

    # 3. Floating Rice Seedlings / Sprouts poking through the water
    sprouts = [
        (int(cx - 40), int(cy + 2)),
        (int(cx - 15), int(cy - 1)),
        (int(cx + 15), int(cy - 3)),
        (int(cx + 42), int(cy + 1)),
        (int(cx - 2), int(cy + 4)),
        (int(cx + 28), int(cy - 2)),
    ]
    for sx, sy in sprouts:
        if 0 <= sx < width and 0 <= sy < height and pixels[sx, sy][3] > 0:
            # Seedling stem & leaves
            pixels[sx, sy] = (38, 64, 28, 255)
            if sy - 1 >= 0:
                pixels[sx, sy - 1] = (62, 108, 42, 255)
            if sy - 2 >= 0:
                pixels[sx, sy - 2] = (92, 154, 56, 255)
                if sx + 1 < width:
                    pixels[sx + 1, sy - 2] = (124, 188, 68, 255)
            if sy - 3 >= 0 and sx - 1 >= 0:
                pixels[sx - 1, sy - 3] = (140, 204, 76, 255)
            # Ripple around sprout base
            if sx + 1 < width and sy < height:
                pixels[sx + 1, sy] = (90, 140, 132, 230)
            if sx - 1 >= 0 and sy < height:
                pixels[sx - 1, sy] = (90, 140, 132, 230)

    return img

def create_palay_stalks(width=32, height=38):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pixels = img.load()
    
    # Palette definition
    c_deep_green = (28, 48, 22, 255)
    c_stalk_green = (54, 92, 38, 255)
    c_bright_green = (86, 142, 54, 255)
    c_ochre_shadow = (110, 72, 20, 255)
    c_amber_base = (176, 122, 28, 255)
    c_gold_body = (230, 172, 44, 255)
    c_gold_hi = (252, 218, 92, 255)
    c_wheat_tip = (255, 242, 160, 255)
    
    # Stem curves rising from bottom (y=37) and arching gracefully
    stems = [
        # (root_x, tip_x, peak_y, arch_dir, grain_count)
        (16, 6, 8, -1, 7),
        (15, 12, 5, -1, 8),
        (17, 24, 6, 1, 8),
        (18, 28, 10, 1, 6),
        (14, 4, 14, -1, 5),
        (19, 29, 15, 1, 5),
        (16, 18, 4, 0, 9)
    ]
    
    # 1. Base root cluster & leaves
    for y in range(height - 8, height):
        spread = int((height - y) * 1.2) + 2
        for x in range(16 - spread, 16 + spread):
            if 0 <= x < width:
                d = abs(x - 16)
                if d <= 1:
                    pixels[x, y] = c_deep_green
                elif d <= 3:
                    pixels[x, y] = c_stalk_green
                else:
                    if (x + y) % 2 == 0:
                        pixels[x, y] = c_bright_green

    # 2. Draw stems
    import math
    for root_x, tip_x, peak_y, arch_dir, g_count in stems:
        steps = height - peak_y
        for s in range(steps):
            t = s / float(steps)
            cur_y = int(height - 1 - s)
            # Quadratic curve
            cur_x = int((1.0 - t) * (1.0 - t) * root_x + 2 * (1.0 - t) * t * (root_x + arch_dir * 8) + t * t * tip_x)
            if 0 <= cur_x < width and 0 <= cur_y < height:
                col = c_deep_green if cur_y > height - 12 else (c_stalk_green if cur_y > height - 22 else c_bright_green)
                pixels[cur_x, cur_y] = col
                if cur_y > height - 18 and cur_x + 1 < width and (cur_x + cur_y) % 2 == 0:
                    pixels[cur_x + 1, cur_y] = c_stalk_green

        # 3. Draw heavy drooping golden grains (Palay panicles) along the arch
        for g in range(g_count):
            gt = g / float(g_count)
            gx = int((1.0 - gt) * (root_x + arch_dir * 6) + gt * tip_x)
            gy = int((1.0 - gt) * (peak_y + 8) + gt * peak_y)
            # Grain bead (2x2 or 3x2 diamond)
            offsets = [
                (0, 0, c_gold_body),
                (0, -1, c_gold_hi),
                (arch_dir, 0, c_amber_base),
                (0, 1, c_ochre_shadow),
                (-arch_dir, 0, c_gold_hi)
            ]
            if g == g_count - 1:
                offsets.append((arch_dir * 2, -1, c_wheat_tip)) # Awn / tip bristle
                offsets.append((arch_dir * 3, -2, c_wheat_tip))
                
            for ox, oy, col in offsets:
                px, py = gx + ox, gy + oy
                if 0 <= px < width and 0 <= py < height:
                    pixels[px, py] = col

    # 4. Outward arching leafy blades
    leaf_blades = [
        # (origin_y, dir, length)
        (26, -1, 9),
        (22, 1, 10),
        (30, -1, 7),
        (28, 1, 8)
    ]
    for ly, ldir, llen in leaf_blades:
        lx = 16
        for step in range(llen):
            lt = step / float(llen)
            px = int(lx + ldir * (step * 1.3))
            py = int(ly - step * 0.8 + step * step * 0.1)
            if 0 <= px < width and 0 <= py < height:
                pixels[px, py] = c_bright_green if step > 3 else c_stalk_green

    return img

def create_palay_cluster_wide(width=64, height=38):
    # Composite a lush 3-tuft clump with variations
    base = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    tuft1 = create_palay_stalks(32, 38)
    tuft2 = tuft1.transpose(Image.FLIP_LEFT_RIGHT)
    tuft3 = create_palay_stalks(32, 38)
    
    # Paste tufts layered depth
    base.paste(tuft1, (4, 0), tuft1)
    base.paste(tuft2, (28, 0), tuft2)
    base.paste(tuft3, (16, 2), tuft3) # Center front
    return base

def create_pilapil_dike(width=112, height=28):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pixels = img.load()
    
    # Stone colors
    c_stone_dark = (38, 34, 30, 255)
    c_stone_mid = (64, 58, 52, 255)
    c_stone_light = (98, 90, 82, 255)
    c_stone_hi = (132, 124, 114, 255)
    c_mud_joint = (46, 32, 22, 255)
    
    # Grass cap colors
    c_grass_dark = (32, 58, 24, 255)
    c_grass_mid = (58, 102, 40, 255)
    c_grass_hi = (94, 154, 56, 255)
    c_grass_tip = (142, 198, 74, 255)
    
    import random
    rng = random.Random(42)
    
    # Draw stonework masonry
    # 2 rows of irregular river stones
    for y in range(4, height):
        for x in range(width):
            # stone grid cell
            cell_x = x // 18
            cell_y = (y - 4) // 11
            local_x = x % 18
            local_y = (y - 4) % 11
            
            # Staggered bond
            if cell_y % 2 == 1:
                local_x = (x + 9) % 18
                cell_x = (x + 9) // 18
                
            # Mortar joints
            if local_x == 0 or local_y == 0:
                pixels[x, y] = c_mud_joint
            else:
                # Stone interior shading
                dx = local_x - 9
                dy = local_y - 5.5
                d = (dx * dx) / 64.0 + (dy * dy) / 25.0
                if d > 1.0:
                    pixels[x, y] = c_stone_dark
                elif d > 0.65:
                    pixels[x, y] = c_stone_mid
                elif local_y < 4:
                    pixels[x, y] = c_stone_hi if local_x < 9 else c_stone_light
                else:
                    pixels[x, y] = c_stone_light
                    
    # Top grass / moss tuft cap
    for x in range(width):
        grass_len = rng.randint(2, 5)
        for gy in range(grass_len):
            py = 4 - gy
            if 0 <= py < height:
                if gy == grass_len - 1:
                    pixels[x, py] = c_grass_tip if (x % 3 == 0) else c_grass_hi
                elif gy > 1:
                    pixels[x, py] = c_grass_mid
                else:
                    pixels[x, py] = c_grass_dark
                    
    # Hanging moss fringe on stone faces
    for x in range(0, width, 4):
        if rng.random() < 0.6:
            hang_len = rng.randint(2, 6)
            for hy in range(hang_len):
                py = 5 + hy
                if py < height:
                    pixels[x, py] = c_grass_dark if hy > 2 else c_grass_mid

    return img

# Generate and save all assets
mud_wide = create_detailed_mud_puddle(160, 36)
mud_wide.save("assets/rice_field/mud_puddle_detailed.png")

mud_med = create_detailed_mud_puddle(96, 26)
mud_med.save("assets/rice_field/mud_puddle_medium.png")

palay_single = create_palay_stalks(32, 38)
palay_single.save("assets/rice_field/palay_stalks_detailed.png")

palay_wide = create_palay_cluster_wide(64, 38)
palay_wide.save("assets/rice_field/palay_cluster_wide.png")

pilapil = create_pilapil_dike(120, 26)
pilapil.save("assets/rice_field/pilapil_dike.png")

print("Generated all detailed rice field assets successfully!")

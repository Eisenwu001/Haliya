#!/usr/bin/env python3
"""
Test script to generate and verify handcrafted bioluminescent cave props with zero overlaps.
"""
import os
import numpy as np
from PIL import Image, ImageDraw

def create_cave_props_atlas() -> Image.Image:
    # 320 x 160 RGBA canvas
    img = Image.new("RGBA", (320, 160), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ──────────────────────────────────────────────────────────
    # 1. Monolithic Crystal Spire (0, 0, 64, 96)
    # ──────────────────────────────────────────────────────────
    # Rock base (x=10..54, y=72..94)
    for y in range(74, 95):
        w = int(24 * (1.0 - ((y - 74) / 21.0) * 0.2) + 6)
        x0 = 32 - w
        x1 = 32 + w
        for x in range(x0, x1 + 1):
            lum = ((x + y * 3) % 7) / 7.0
            r = int(22 + lum * 24)
            g = int(32 + lum * 32)
            b = int(54 + lum * 48)
            img.putpixel((x, y), (r, g, b, 255))
    # Rock highlights
    for x in range(16, 48, 3):
        img.putpixel((x, 75), (85, 125, 185, 255))
        img.putpixel((x + 1, 76), (65, 95, 155, 255))

    # Left secondary spire (apex at 20, 30)
    poly_l = [(20, 30), (14, 76), (25, 76)]
    draw.polygon(poly_l, fill=(45, 125, 205, 255))
    draw.polygon([(20, 30), (14, 76), (20, 76)], fill=(125, 215, 255, 255))
    draw.line([(20, 30), (20, 76)], fill=(225, 255, 255, 255), width=1)

    # Right secondary spire (apex at 44, 38)
    poly_r = [(44, 38), (38, 78), (50, 78)]
    draw.polygon(poly_r, fill=(28, 85, 165, 255))
    draw.polygon([(44, 38), (38, 78), (43, 78)], fill=(95, 195, 255, 255))
    draw.line([(44, 38), (43, 78)], fill=(205, 245, 255, 255), width=1)

    # Main central spire (apex at 32, 10, base at 23..41, 78)
    draw.polygon([(32, 10), (22, 78), (42, 78)], fill=(35, 105, 185, 255))
    # Left facet (illuminated)
    draw.polygon([(32, 10), (22, 78), (32, 78)], fill=(115, 215, 255, 255))
    # Outer left bevel
    draw.polygon([(32, 10), (22, 78), (26, 78)], fill=(165, 235, 255, 255))
    # Central ridge
    draw.line([(32, 10), (32, 78)], fill=(245, 255, 255, 255), width=1)
    # Embedded glowing runes along the spine
    for ry in [26, 40, 54, 66]:
        img.putpixel((32, ry), (255, 255, 255, 255))
        img.putpixel((31, ry), (200, 245, 255, 255))
        img.putpixel((33, ry), (200, 245, 255, 255))
        img.putpixel((32, ry - 1), (200, 245, 255, 255))
        img.putpixel((32, ry + 1), (200, 245, 255, 255))

    # ──────────────────────────────────────────────────────────
    # 2. Breakable Crystalline Geode (Cyan) (64, 0, 64, 64)
    # ──────────────────────────────────────────────────────────
    ox = 64
    # Outer rock nodule
    for gy in range(22, 58):
        for gx in range(14, 50):
            dx = (gx - 32.0) / 16.0
            dy = (gy - 40.0) / 16.0
            d = dx * dx + dy * dy
            if d <= 1.0:
                px = ox + gx
                py = gy
                if d > 0.62:
                    # Outer crust
                    if (gx + gy) % 3 == 0:
                        img.putpixel((px, py), (95, 135, 185, 255)) # highlight
                    else:
                        img.putpixel((px, py), (26, 36, 58, 255))   # slate crust
                elif d > 0.38:
                    # Inner agate band
                    img.putpixel((px, py), (42, 95, 165, 255))
                else:
                    # Hollow crystalline cavity with sparkling teeth
                    if (gx * 3 + gy * 7) % 5 == 0:
                        img.putpixel((px, py), (235, 255, 255, 255)) # bright spark
                    elif (gx + gy) % 2 == 0:
                        img.putpixel((px, py), (115, 225, 255, 255)) # cyan crystal
                    else:
                        img.putpixel((px, py), (45, 145, 225, 255))  # deep blue facet

    # ──────────────────────────────────────────────────────────
    # 3. Breakable Crystalline Geode (Amethyst) (128, 0, 64, 64)
    # ──────────────────────────────────────────────────────────
    ox = 128
    for gy in range(22, 58):
        for gx in range(14, 50):
            dx = (gx - 32.0) / 16.0
            dy = (gy - 40.0) / 16.0
            d = dx * dx + dy * dy
            if d <= 1.0:
                px = ox + gx
                py = gy
                if d > 0.62:
                    if (gx + gy) % 3 == 0:
                        img.putpixel((px, py), (135, 95, 175, 255))
                    else:
                        img.putpixel((px, py), (36, 24, 52, 255))
                elif d > 0.38:
                    img.putpixel((px, py), (88, 48, 145, 255))
                else:
                    if (gx * 3 + gy * 7) % 5 == 0:
                        img.putpixel((px, py), (255, 235, 255, 255))
                    elif (gx + gy) % 2 == 0:
                        img.putpixel((px, py), (215, 125, 255, 255))
                    else:
                        img.putpixel((px, py), (135, 45, 215, 255))

    # ──────────────────────────────────────────────────────────
    # 4. Bioluminescent Crystal Cluster (Sapphire / Cyan) (192, 0, 64, 64)
    # ──────────────────────────────────────────────────────────
    ox = 192
    # Rock crag base (y=50..58, x=12..52)
    for y in range(50, 58):
        for x in range(14, 50):
            if ((x - 32) / 18.0) ** 2 + ((y - 54) / 4.0) ** 2 <= 1.0:
                lum = ((x * 2 + y * 5) % 5) / 5.0
                img.putpixel((ox + x, y), (int(25 + lum * 35), int(35 + lum * 45), int(60 + lum * 65), 255))
    # Rock rim highlight
    for x in range(18, 46, 2):
        img.putpixel((ox + x, 51), (95, 145, 205, 255))

    # Crystal 1 (Far Left): apex at (16, 34), base (12..20, 53)
    draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 20, 53)], fill=(40, 115, 195, 255))
    draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 16, 53)], fill=(125, 225, 255, 255))
    draw.line([(ox + 16, 34), (ox + 16, 53)], fill=(225, 255, 255, 255), width=1)

    # Crystal 2 (Left): apex at (23, 22), base (18..28, 53)
    draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 29, 53)], fill=(45, 130, 210, 255))
    draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 23, 53)], fill=(145, 235, 255, 255))
    draw.line([(ox + 23, 22), (ox + 23, 53)], fill=(235, 255, 255, 255), width=1)

    # Crystal 3 (Far Right): apex at (48, 36), base (44..52, 53)
    draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 52, 53)], fill=(32, 95, 175, 255))
    draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 48, 53)], fill=(110, 210, 255, 255))
    draw.line([(ox + 48, 36), (ox + 48, 53)], fill=(215, 255, 255, 255), width=1)

    # Crystal 4 (Right): apex at (41, 24), base (35..46, 53)
    draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 46, 53)], fill=(38, 115, 195, 255))
    draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 40, 53)], fill=(135, 225, 255, 255))
    draw.line([(ox + 41, 24), (ox + 40, 53)], fill=(225, 255, 255, 255), width=1)

    # Crystal 5 (Center Master Pillar): apex at (32, 12), base (26..38, 54)
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 39, 54)], fill=(42, 125, 205, 255))
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 32, 54)], fill=(155, 240, 255, 255))
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 28, 54)], fill=(205, 250, 255, 255))
    draw.line([(ox + 32, 12), (ox + 32, 54)], fill=(255, 255, 255, 255), width=1)
    # Sparkling apex star
    img.putpixel((ox + 32, 11), (255, 255, 255, 255))
    img.putpixel((ox + 31, 12), (255, 255, 255, 255))
    img.putpixel((ox + 33, 12), (255, 255, 255, 255))
    img.putpixel((ox + 32, 13), (255, 255, 255, 255))

    # ──────────────────────────────────────────────────────────
    # 5. Bioluminescent Crystal Cluster (Amethyst / Violet) (256, 0, 64, 64)
    # ──────────────────────────────────────────────────────────
    ox = 256
    # Rock crag base
    for y in range(50, 58):
        for x in range(14, 50):
            if ((x - 32) / 18.0) ** 2 + ((y - 54) / 4.0) ** 2 <= 1.0:
                lum = ((x * 2 + y * 5) % 5) / 5.0
                img.putpixel((ox + x, y), (int(35 + lum * 35), int(22 + lum * 25), int(55 + lum * 55), 255))
    for x in range(18, 46, 2):
        img.putpixel((ox + x, 51), (145, 95, 195, 255))

    # Left crystal: apex (22, 24)
    draw.polygon([(ox + 22, 24), (ox + 16, 53), (ox + 27, 53)], fill=(110, 40, 175, 255))
    draw.polygon([(ox + 22, 24), (ox + 16, 53), (ox + 22, 53)], fill=(215, 145, 255, 255))
    draw.line([(ox + 22, 24), (ox + 22, 53)], fill=(255, 235, 255, 255), width=1)

    # Right crystal: apex (42, 26)
    draw.polygon([(ox + 42, 26), (ox + 36, 53), (ox + 47, 53)], fill=(95, 32, 155, 255))
    draw.polygon([(ox + 42, 26), (ox + 36, 53), (ox + 41, 53)], fill=(205, 135, 255, 255))
    draw.line([(ox + 42, 26), (ox + 41, 53)], fill=(255, 225, 255, 255), width=1)

    # Center crystal: apex (32, 12)
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 39, 54)], fill=(125, 45, 195, 255))
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 32, 54)], fill=(225, 155, 255, 255))
    draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 28, 54)], fill=(250, 205, 255, 255))
    draw.line([(ox + 32, 12), (ox + 32, 54)], fill=(255, 255, 255, 255), width=1)
    img.putpixel((ox + 32, 11), (255, 255, 255, 255))
    img.putpixel((ox + 31, 12), (255, 255, 255, 255))
    img.putpixel((ox + 33, 12), (255, 255, 255, 255))
    img.putpixel((ox + 32, 13), (255, 255, 255, 255))

    # ──────────────────────────────────────────────────────────
    # 6. Bioluminescent Cavern Flora & Fungi (0, 96, 64, 64)
    # ──────────────────────────────────────────────────────────
    oy = 96
    # 3 Glowing mushrooms
    shrooms = [
        (20, 136, 9, (85, 225, 255), (185, 250, 255)),   # Cyan
        (34, 130, 11, (135, 245, 255), (235, 255, 255)), # Radiant Mint
        (46, 138, 8, (215, 135, 255), (255, 215, 255)),  # Lavender
    ]
    for mx, my, mr, c_base, c_glow in shrooms:
        # Organic curved stem (my to 154)
        for sy in range(my, 154):
            dx = int(1.2 * np.sin((sy - my) * 0.15))
            img.putpixel((mx + dx, sy), (45, 65, 88, 255))
            img.putpixel((mx + dx - 1, sy), (32, 48, 68, 255))
        # Cap ellipse
        for cy in range(my - mr // 2, my + 3):
            for cx in range(mx - mr, mx + mr + 1):
                cdx = (cx - mx) / float(mr)
                cdy = (cy - my) / float(mr // 2 + 1)
                if cdx * cdx + cdy * cdy <= 1.0:
                    if cy == my - mr // 2 + 1 and abs(cx - mx) <= mr // 2:
                        img.putpixel((cx, cy), (c_glow[0], c_glow[1], c_glow[2], 255))
                    else:
                        img.putpixel((cx, cy), (c_base[0], c_base[1], c_base[2], 255))
        # Spore sparkles
        img.putpixel((mx - 2, my - mr // 2 - 3), (c_glow[0], c_glow[1], c_glow[2], 220))
        img.putpixel((mx + 3, my - mr // 2 - 5), (c_glow[0], c_glow[1], c_glow[2], 180))

    # ──────────────────────────────────────────────────────────
    # 7. Radiant Floating Pogo Crystal Geode (64, 96, 64, 48) - 100% Free-Floating
    # ──────────────────────────────────────────────────────────
    ox = 64
    oy = 96
    cx = ox + 32
    cy = oy + 24
    # Octahedral diamond facet rendering
    top_v = (cx, cy - 18)
    bot_v = (cx, cy + 18)
    left_v = (cx - 18, cy)
    right_v = (cx + 18, cy)
    front_v = (cx, cy + 4)

    # Top-left facet (very bright cyan)
    draw.polygon([top_v, left_v, front_v], fill=(165, 240, 255, 255))
    # Top-right facet (sapphire cyan)
    draw.polygon([top_v, right_v, front_v], fill=(75, 185, 245, 255))
    # Bottom-left facet (deep blue)
    draw.polygon([bot_v, left_v, front_v], fill=(45, 125, 215, 255))
    # Bottom-right facet (shadow blue)
    draw.polygon([bot_v, right_v, front_v], fill=(24, 75, 155, 255))

    # Sharp specular facet ridges
    draw.line([top_v, front_v], fill=(255, 255, 255, 255), width=1)
    draw.line([front_v, bot_v], fill=(205, 245, 255, 255), width=1)
    draw.line([left_v, front_v], fill=(235, 255, 255, 255), width=1)
    draw.line([front_v, right_v], fill=(165, 225, 255, 255), width=1)

    # Floating orbital gem motes
    orbit_coords = [(cx - 24, cy - 8), (cx + 23, cy - 6), (cx - 20, cy + 12), (cx + 21, cy + 10)]
    for oxc, oyc in orbit_coords:
        draw.polygon([(oxc, oyc - 4), (oxc - 3, oyc), (oxc, oyc + 4), (oxc + 3, oyc)], fill=(185, 245, 255, 255))
        img.putpixel((oxc, oyc), (255, 255, 255, 255))

    # ──────────────────────────────────────────────────────────
    # 8. Crystal Spike Bed (128, 96, 96, 32)
    # ──────────────────────────────────────────────────────────
    ox = 128
    oy = 96
    # 7 sharp ground spikes
    spike_specs = [(8, 18), (20, 26), (34, 22), (48, 28), (62, 20), (76, 26), (88, 18)]
    for sx, sh in spike_specs:
        base_w = 6
        apex = (ox + sx, oy + 32 - sh)
        b_l = (ox + sx - base_w, oy + 32)
        b_r = (ox + sx + base_w, oy + 32)
        draw.polygon([apex, b_l, b_r], fill=(32, 95, 165, 255))
        draw.polygon([apex, b_l, (ox + sx, oy + 32)], fill=(125, 215, 255, 255))
        draw.line([apex, (ox + sx, oy + 32)], fill=(225, 255, 255, 255), width=1)
        img.putpixel(apex, (255, 255, 255, 255))

    # ──────────────────────────────────────────────────────────
    # 9. Ceiling Stalactite Overhang (224, 96, 96, 64)
    # ──────────────────────────────────────────────────────────
    ox = 224
    oy = 96
    # Ceiling rock anchor (oy to oy+14)
    for y in range(oy, oy + 14):
        for x in range(ox, ox + 96):
            lum = ((x * 3 + y * 7) % 7) / 7.0
            img.putpixel((x, y), (int(24 + lum * 24), int(32 + lum * 32), int(54 + lum * 48), 255))
    # Hanging stalactite teeth
    st_specs = [(12, 38), (28, 52), (44, 32), (60, 56), (76, 42), (88, 30)]
    for stx, sth in st_specs:
        bw = 7
        apex = (ox + stx, oy + sth)
        t_l = (ox + stx - bw, oy + 12)
        t_r = (ox + stx + bw, oy + 12)
        draw.polygon([apex, t_l, t_r], fill=(32, 95, 175, 255))
        draw.polygon([apex, t_l, (ox + stx, oy + 12)], fill=(115, 215, 255, 255))
        draw.line([apex, (ox + stx, oy + 12)], fill=(215, 255, 255, 255), width=1)
        img.putpixel(apex, (255, 255, 255, 255))

    return img

if __name__ == "__main__":
    test_atlas = create_cave_props_atlas()
    out_path = "scratch/test_props_atlas.png"
    test_atlas.save(out_path, "PNG")
    print(f"Saved test props atlas to {out_path} ({test_atlas.size})")

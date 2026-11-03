#!/usr/bin/env python3
import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
decor = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Decor.png")).convert("RGBA")

def recolor_slate(img: Image.Image, variant: str = "sapphire") -> Image.Image:
    arr = np.array(img, dtype=np.float32)
    mask = arr[:, :, 3] > 10
    lum = (0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]) / 255.0
    if variant == "sapphire":
        r = np.where(lum <= 0.15, lum * 24.0, 18.0 + lum * 62.0)
        g = np.where(lum <= 0.15, lum * 34.0, 26.0 + lum * 84.0)
        b = np.where(lum <= 0.15, lum * 56.0, 46.0 + lum * 135.0)
    else:
        r = np.where(lum <= 0.15, lum * 36.0, 32.0 + lum * 92.0)
        g = np.where(lum <= 0.15, lum * 24.0, 22.0 + lum * 54.0)
        b = np.where(lum <= 0.15, lum * 52.0, 48.0 + lum * 125.0)
    arr[:, :, 0][mask] = r[mask]
    arr[:, :, 1][mask] = g[mask]
    arr[:, :, 2][mask] = b[mask]
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")

def build_refined_props() -> Image.Image:
    props = Image.new("RGBA", (320, 160), (0, 0, 0, 0))
    p_draw = ImageDraw.Draw(props)

    # 1. Monolithic Crystal Spire (0, 0, 64, 96)
    # Left secondary spire (apex at 20, 32)
    p_draw.polygon([(20, 32), (14, 82), (26, 82)], fill=(45, 125, 205, 255))
    p_draw.polygon([(20, 32), (14, 82), (20, 82)], fill=(125, 215, 255, 255))
    p_draw.line([(20, 32), (20, 82)], fill=(225, 255, 255, 255), width=1)

    # Right secondary spire (apex at 44, 40)
    p_draw.polygon([(44, 40), (38, 82), (50, 82)], fill=(28, 85, 165, 255))
    p_draw.polygon([(44, 40), (38, 82), (43, 82)], fill=(95, 195, 255, 255))
    p_draw.line([(44, 40), (43, 82)], fill=(205, 245, 255, 255), width=1)

    # Main central spire (apex at 32, 12, base at 22..42, 82)
    p_draw.polygon([(32, 12), (22, 82), (42, 82)], fill=(35, 105, 185, 255))
    p_draw.polygon([(32, 12), (22, 82), (32, 82)], fill=(115, 215, 255, 255))
    p_draw.polygon([(32, 12), (22, 82), (26, 82)], fill=(165, 235, 255, 255))
    p_draw.line([(32, 12), (32, 82)], fill=(245, 255, 255, 255), width=1)
    for ry in [26, 40, 54, 66]:
        props.putpixel((32, ry), (255, 255, 255, 255))
        props.putpixel((31, ry), (200, 245, 255, 255))
        props.putpixel((33, ry), (200, 245, 255, 255))

    # Base stone pile from Decor.png at (40, 198, 86, 214) (46x16)
    # Paste overlapping the bottom of spires at y=68..84
    stone_base = decor.crop((40, 198, 86, 214))
    stone_base_rec = recolor_slate(stone_base, "sapphire")
    props.paste(stone_base_rec, (9, 70), stone_base_rec)
    # Second rock wedge at y=78..92
    stone_wedge = recolor_slate(decor.crop((64, 170, 86, 184)), "sapphire")
    props.paste(stone_wedge, (21, 78), stone_wedge)

    # 2. Breakable Crystalline Geode (Cyan: 64, 0, 64, 64; Amethyst: 128, 0, 64, 64)
    for ox, is_am in [(64, False), (128, True)]:
        # Outer rough geode rock nodule (diameter ~32px, centered at x=32, y=38)
        for gy in range(22, 56):
            for gx in range(16, 48):
                dx = (gx - 32.0) / 14.0
                dy = (gy - 38.0) / 14.0
                # Add irregular perimeter noise
                noise = 0.12 * np.sin(gx * 1.5) + 0.10 * np.cos(gy * 1.8)
                d = dx * dx + dy * dy + noise
                if d <= 1.0:
                    px = ox + gx
                    py = gy
                    if is_am:
                        if d > 0.65:
                            # Dark slate crust
                            if (gx + gy) % 3 == 0:
                                props.putpixel((px, py), (145, 105, 185, 255))
                            else:
                                props.putpixel((px, py), (42, 28, 58, 255))
                        elif d > 0.38:
                            props.putpixel((px, py), (95, 48, 155, 255))
                        else:
                            # Hollow glowing cavity
                            if (gx * 3 + gy * 7) % 5 == 0:
                                props.putpixel((px, py), (255, 240, 255, 255))
                            elif (gx + gy) % 2 == 0:
                                props.putpixel((px, py), (220, 135, 255, 255))
                            else:
                                props.putpixel((px, py), (145, 55, 220, 255))
                    else:
                        if d > 0.65:
                            if (gx + gy) % 3 == 0:
                                props.putpixel((px, py), (95, 145, 195, 255))
                            else:
                                props.putpixel((px, py), (28, 38, 62, 255))
                        elif d > 0.38:
                            props.putpixel((px, py), (45, 95, 165, 255))
                        else:
                            if (gx * 3 + gy * 7) % 5 == 0:
                                props.putpixel((px, py), (245, 255, 255, 255))
                            elif (gx + gy) % 2 == 0:
                                props.putpixel((px, py), (115, 235, 255, 255))
                            else:
                                props.putpixel((px, py), (42, 145, 225, 255))

    # 3. Crystal Clusters (Cyan: 192, 0, 64, 64; Amethyst: 256, 0, 64, 64)
    for ox, is_am in [(192, False), (256, True)]:
        col_lit = (220, 155, 255, 255) if is_am else (145, 235, 255, 255)
        col_hi = (255, 235, 255, 255) if is_am else (225, 255, 255, 255)
        col_shd = (115, 45, 175, 255) if is_am else (42, 125, 205, 255)
        col_drk = (85, 30, 145, 255) if is_am else (28, 90, 165, 255)

        # 5 crystal prisms
        # 1: Far left
        p_draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 20, 53)], fill=col_drk)
        p_draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 16, 53)], fill=col_lit)
        p_draw.line([(ox + 16, 34), (ox + 16, 53)], fill=col_hi, width=1)

        # 2: Left
        p_draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 29, 53)], fill=col_shd)
        p_draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 23, 53)], fill=col_lit)
        p_draw.line([(ox + 23, 22), (ox + 23, 53)], fill=col_hi, width=1)

        # 3: Far right
        p_draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 52, 53)], fill=col_drk)
        p_draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 48, 53)], fill=col_lit)
        p_draw.line([(ox + 48, 36), (ox + 48, 53)], fill=col_hi, width=1)

        # 4: Right
        p_draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 46, 53)], fill=col_shd)
        p_draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 40, 53)], fill=col_lit)
        p_draw.line([(ox + 41, 24), (ox + 40, 53)], fill=col_hi, width=1)

        # 5: Center Master
        p_draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 39, 54)], fill=col_shd)
        p_draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 32, 54)], fill=col_lit)
        p_draw.line([(ox + 32, 12), (ox + 32, 54)], fill=(255, 255, 255, 255), width=1)
        props.putpixel((ox + 32, 11), (255, 255, 255, 255))
        props.putpixel((ox + 31, 12), (255, 255, 255, 255))
        props.putpixel((ox + 33, 12), (255, 255, 255, 255))

        # Base stone wedge overlapping bottom at y=50..56
        base_w = recolor_slate(decor.crop((64, 170, 86, 184)), "amethyst" if is_am else "sapphire")
        props.paste(base_w, (ox + 21, 46), base_w)

    # 4. Cavern Flora (0, 96, 64, 64)
    shrooms = [
        (20, 136, 9, (85, 225, 255), (185, 250, 255)),
        (34, 130, 11, (135, 245, 255), (235, 255, 255)),
        (46, 138, 8, (215, 135, 255), (255, 215, 255)),
    ]
    for mx, my, mr, c_base, c_glow in shrooms:
        for sy in range(my, 154):
            dx = int(1.2 * np.sin((sy - my) * 0.15))
            props.putpixel((mx + dx, sy), (45, 65, 88, 255))
            props.putpixel((mx + dx - 1, sy), (32, 48, 68, 255))
        for cy in range(my - mr // 2, my + 3):
            for cx in range(mx - mr, mx + mr + 1):
                cdx = (cx - mx) / float(mr)
                cdy = (cy - my) / float(mr // 2 + 1)
                if cdx * cdx + cdy * cdy <= 1.0:
                    if cy == my - mr // 2 + 1 and abs(cx - mx) <= mr // 2:
                        props.putpixel((cx, cy), (c_glow[0], c_glow[1], c_glow[2], 255))
                    else:
                        props.putpixel((cx, cy), (c_base[0], c_base[1], c_base[2], 255))
        props.putpixel((mx - 2, my - mr // 2 - 3), (c_glow[0], c_glow[1], c_glow[2], 220))
        props.putpixel((mx + 3, my - mr // 2 - 5), (c_glow[0], c_glow[1], c_glow[2], 180))

    # 5. Pogo Crystal (64, 96, 64, 48) - 100% Free-Floating
    ox, oy = 64, 96
    cx, cy = ox + 32, oy + 24
    top_v = (cx, cy - 18)
    bot_v = (cx, cy + 18)
    left_v = (cx - 18, cy)
    right_v = (cx + 18, cy)
    front_v = (cx, cy + 4)

    p_draw.polygon([top_v, left_v, front_v], fill=(165, 240, 255, 255))
    p_draw.polygon([top_v, right_v, front_v], fill=(75, 185, 245, 255))
    p_draw.polygon([bot_v, left_v, front_v], fill=(45, 125, 215, 255))
    p_draw.polygon([bot_v, right_v, front_v], fill=(24, 75, 155, 255))

    p_draw.line([top_v, front_v], fill=(255, 255, 255, 255), width=1)
    p_draw.line([front_v, bot_v], fill=(205, 245, 255, 255), width=1)
    p_draw.line([left_v, front_v], fill=(235, 255, 255, 255), width=1)
    p_draw.line([front_v, right_v], fill=(165, 225, 255, 255), width=1)

    orbit_coords = [(cx - 24, cy - 8), (cx + 23, cy - 6), (cx - 20, cy + 12), (cx + 21, cy + 10)]
    for oxc, oyc in orbit_coords:
        p_draw.polygon([(oxc, oyc - 4), (oxc - 3, oyc), (oxc, oyc + 4), (oxc + 3, oyc)], fill=(185, 245, 255, 255))
        props.putpixel((oxc, oyc), (255, 255, 255, 255))

    # 6. Spikes (128, 96, 96, 32)
    ox, oy = 128, 96
    spike_specs = [(8, 18), (20, 26), (34, 22), (48, 28), (62, 20), (76, 26), (88, 18)]
    for sx, sh in spike_specs:
        base_w = 6
        apex = (ox + sx, oy + 32 - sh)
        b_l = (ox + sx - base_w, oy + 32)
        b_r = (ox + sx + base_w, oy + 32)
        p_draw.polygon([apex, b_l, b_r], fill=(32, 95, 165, 255))
        p_draw.polygon([apex, b_l, (ox + sx, oy + 32)], fill=(125, 215, 255, 255))
        p_draw.line([apex, (ox + sx, oy + 32)], fill=(225, 255, 255, 255), width=1)
        props.putpixel(apex, (255, 255, 255, 255))

    # 7. Ceiling Stalactites (224, 96, 96, 64)
    ox, oy = 224, 96
    for y in range(oy, oy + 14):
        for x in range(ox, ox + 96):
            lum = ((x * 3 + y * 7) % 7) / 7.0
            props.putpixel((x, y), (int(24 + lum * 24), int(32 + lum * 32), int(54 + lum * 48), 255))
    st_specs = [(12, 38), (28, 52), (44, 32), (60, 56), (76, 42), (88, 30)]
    for stx, sth in st_specs:
        bw = 7
        apex = (ox + stx, oy + sth)
        t_l = (ox + stx - bw, oy + 12)
        t_r = (ox + stx + bw, oy + 12)
        p_draw.polygon([apex, t_l, t_r], fill=(32, 95, 175, 255))
        p_draw.polygon([apex, t_l, (ox + stx, oy + 12)], fill=(115, 215, 255, 255))
        p_draw.line([apex, (ox + stx, oy + 12)], fill=(215, 255, 255, 255), width=1)
        props.putpixel(apex, (255, 255, 255, 255))

    return props

if __name__ == "__main__":
    props = build_refined_props()
    out_path = os.path.join(BASE_DIR, "assets", "cave_platformer", "cave_props.png")
    props.save(out_path, "PNG")
    print(f"Saved refined cave_props.png to {out_path} ({props.size})")

#!/usr/bin/env python3
"""
Overhauls Cave TileSet, Platforms, and Props for a High-Contrast Bioluminescent Cavern:
- cave_tileset_atlas.png & cave_rock_tiles.png (288x384):
    Vibrant mineral highlights, electric cyan / amethyst crystalline rim on rock tops,
    rich subterranean slate body shading with visible geological facets.
- cave_platforms.png (224x160):
    Organic self-contained floating rock islands (island_lg, island_md, bridge, crumble, sanctuary)
    with luminous crystal rims, embedded gem nodes, and multi-layered stalactite undersides.
- cave_props.png (256x160):
    0,0,64,96: Bioluminescent Crystal Geode Spire / Shrine
    64,0,64,64: Breakable Crystalline Geode
    64,64,64,64: Bioluminescent Cavern Flora & Fungi (Glowing Mushrooms)
    96,0,64,48: Radiant Floating Pogo Crystal Geode (no poles/columns!)
    160,0,96,32: Subterranean Stalagmite & Crystal Hazard Bed
    160,32,96,64: Cavern Stalactite Cluster (Ceiling)
- assets/vfx/radial_light_falloff.png (256x256):
    Pure white smooth radial falloff.
"""

import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(BASE_DIR, "assets", "cave_platformer")
os.makedirs(OUT_DIR, exist_ok=True)


def recolor_cave_pixel_art(img: Image.Image, variant: str = "sapphire", keep_ore_crystals: bool = False) -> Image.Image:
    """
    Transforms source pixel art into a rich, high-contrast bioluminescent subterranean palette.
    """
    arr = np.array(img, dtype=np.float32)
    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]
    a = arr[:, :, 3]

    mask = a > 15.0
    lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0

    is_bright_crystal = (r > 120) & (b > 120) & (g < 170) & mask
    is_crystal_rim = (lum > 0.48) & mask

    lum_stone = np.clip((lum - 0.08) / 0.85, 0.0, 1.0)
    lum_dark = np.clip(lum / 0.12, 0.0, 1.0)
    lum_top = np.clip((lum - 0.40) / 0.60, 0.0, 1.0)

    out_r = np.zeros_like(r)
    out_g = np.zeros_like(g)
    out_b = np.zeros_like(b)

    if variant == "sapphire":
        # Rich deep subterranean lapis slate with visible geological facets
        stone_r = np.where(lum <= 0.12, lum_dark * 18.0, 18.0 + lum_stone * 54.0 + (lum_stone ** 1.6) * 64.0)
        stone_g = np.where(lum <= 0.12, lum_dark * 26.0, 26.0 + lum_stone * 88.0 + (lum_stone ** 1.6) * 78.0)
        stone_b = np.where(lum <= 0.12, lum_dark * 46.0, 46.0 + lum_stone * 132.0 + (lum_stone ** 1.5) * 88.0)
    elif variant == "amethyst":
        # Royal deep purple lunar stone with vivid amethyst facets
        stone_r = np.where(lum <= 0.12, lum_dark * 36.0, 36.0 + lum_stone * 94.0 + (lum_stone ** 1.6) * 82.0)
        stone_g = np.where(lum <= 0.12, lum_dark * 24.0, 24.0 + lum_stone * 58.0 + (lum_stone ** 1.6) * 62.0)
        stone_b = np.where(lum <= 0.12, lum_dark * 52.0, 52.0 + lum_stone * 124.0 + (lum_stone ** 1.5) * 86.0)
    else:
        stone_r = np.where(lum <= 0.12, lum_dark * 24.0, 24.0 + lum_stone * 74.0 + (lum_stone ** 1.6) * 72.0)
        stone_g = np.where(lum <= 0.12, lum_dark * 32.0, 32.0 + lum_stone * 84.0 + (lum_stone ** 1.6) * 76.0)
        stone_b = np.where(lum <= 0.12, lum_dark * 48.0, 48.0 + lum_stone * 118.0 + (lum_stone ** 1.5) * 82.0)

    out_r[mask] = stone_r[mask]
    out_g[mask] = stone_g[mask]
    out_b[mask] = stone_b[mask]

    # Vivid luminous crystalline highlights on crests
    if variant == "sapphire":
        top_r = 35.0 + lum_top * 80.0 + (lum_top ** 1.8) * 130.0
        top_g = 75.0 + lum_top * 135.0 + (lum_top ** 1.7) * 145.0
        top_b = 135.0 + lum_top * 120.0 + (lum_top ** 1.4) * 85.0
    elif variant == "amethyst":
        top_r = 85.0 + lum_top * 135.0 + (lum_top ** 1.8) * 125.0
        top_g = 45.0 + lum_top * 95.0 + (lum_top ** 1.8) * 115.0
        top_b = 135.0 + lum_top * 120.0 + (lum_top ** 1.5) * 85.0
    else:
        top_r = 55.0 + lum_top * 105.0 + (lum_top ** 1.8) * 120.0
        top_g = 75.0 + lum_top * 125.0 + (lum_top ** 1.8) * 120.0
        top_b = 120.0 + lum_top * 125.0 + (lum_top ** 1.5) * 85.0

    out_r[is_crystal_rim] = top_r[is_crystal_rim]
    out_g[is_crystal_rim] = top_g[is_crystal_rim]
    out_b[is_crystal_rim] = top_b[is_crystal_rim]

    if keep_ore_crystals:
        out_r[is_bright_crystal] = r[is_bright_crystal]
        out_g[is_bright_crystal] = g[is_bright_crystal]
        out_b[is_bright_crystal] = b[is_bright_crystal]

    # Solid uniform interior fill (18, 25, 42)
    is_interior = (np.abs(r - 34) <= 2) & (np.abs(g - 31) <= 2) & (np.abs(b - 25) <= 2) & mask
    out_r[is_interior] = 18.0
    out_g[is_interior] = 25.0
    out_b[is_interior] = 42.0

    res = np.zeros_like(arr, dtype=np.uint8)
    res[:, :, 0] = np.clip(out_r, 0, 255).astype(np.uint8)
    res[:, :, 1] = np.clip(out_g, 0, 255).astype(np.uint8)
    res[:, :, 2] = np.clip(out_b, 0, 255).astype(np.uint8)
    res[:, :, 3] = a.astype(np.uint8)
    return Image.fromarray(res, "RGBA")


def make_pure_rock_top_strip(block_img: Image.Image, variant: str = "sapphire") -> Image.Image:
    """
    Creates a 3-tile-wide (96x32) pure rocky cobble top edge with vibrant bioluminescent
    crystalline rim lighting and sparkling mineral facets.
    """
    bot_strip = block_img.crop((0, 64, 96, 96)).transpose(Image.FLIP_TOP_BOTTOM)
    arr = np.array(bot_strip, dtype=np.float32)
    mask = arr[:, :, 3] > 10

    # Luminous crest highlight on upper rock cobbles (y=0..12)
    for y in range(12):
        w = ((12 - y) / 12.0) ** 1.2
        row_mask = mask[y, :] & (arr[y, :, 2] > 30)
        if variant == "amethyst":
            arr[y, row_mask, 0] = np.clip(arr[y, row_mask, 0] + w * 65.0, 0, 255)
            arr[y, row_mask, 1] = np.clip(arr[y, row_mask, 1] + w * 42.0, 0, 255)
            arr[y, row_mask, 2] = np.clip(arr[y, row_mask, 2] + w * 88.0, 0, 255)
        else:
            arr[y, row_mask, 0] = np.clip(arr[y, row_mask, 0] + w * 45.0, 0, 255)
            arr[y, row_mask, 1] = np.clip(arr[y, row_mask, 1] + w * 82.0, 0, 255)
            arr[y, row_mask, 2] = np.clip(arr[y, row_mask, 2] + w * 115.0, 0, 255)

    # Sparkling crystal facets scattered along the rock ridge
    sparkle_x = [6, 14, 25, 38, 49, 62, 73, 85, 91]
    sparkle_y = [2, 1, 3, 2, 1, 3, 2, 1, 2]
    for sx, sy in zip(sparkle_x, sparkle_y):
        if 0 <= sy < 32 and 0 <= sx < 96 and mask[sy, sx]:
            if variant == "amethyst":
                arr[sy, sx, :3] = [235, 175, 255]
                if sy + 1 < 32:
                    arr[sy + 1, sx, :3] = [185, 110, 245]
            else:
                arr[sy, sx, :3] = [175, 245, 255]
                if sy + 1 < 32:
                    arr[sy + 1, sx, :3] = [95, 195, 255]

    return Image.fromarray(arr.astype(np.uint8), "RGBA")


def enhance_platform_surface(plat_img: Image.Image, variant: str = "sapphire") -> Image.Image:
    """
    Adds crisp bioluminescent crystal edge highlights and sparkling gem nodes to platform tops.
    """
    arr = np.array(plat_img, dtype=np.float32)
    h, w, _ = arr.shape
    alpha = arr[:, :, 3]

    # Find top edge of non-transparent pixels
    for x in range(w):
        y_top = -1
        for y in range(h):
            if alpha[y, x] > 20:
                y_top = y
                break
        if y_top >= 0 and y_top < h - 4:
            # Highlight top 3 pixels
            for dy in range(3):
                yy = y_top + dy
                intensity = (3 - dy) / 3.0
                if variant == "amethyst":
                    arr[yy, x, 0] = np.clip(arr[yy, x, 0] + intensity * 68.0, 0, 255)
                    arr[yy, x, 1] = np.clip(arr[yy, x, 1] + intensity * 45.0, 0, 255)
                    arr[yy, x, 2] = np.clip(arr[yy, x, 2] + intensity * 92.0, 0, 255)
                else:
                    arr[yy, x, 0] = np.clip(arr[yy, x, 0] + intensity * 52.0, 0, 255)
                    arr[yy, x, 1] = np.clip(arr[yy, x, 1] + intensity * 88.0, 0, 255)
                    arr[yy, x, 2] = np.clip(arr[yy, x, 2] + intensity * 118.0, 0, 255)

    return Image.fromarray(arr.astype(np.uint8), "RGBA")


def build_cave_tileset_atlas():
    floor1 = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Floor Tiles1.png")).convert("RGBA")
    ores = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Ores.png")).convert("RGBA")
    decor = Image.open(os.path.join(BASE_DIR, "assets", "platform_assets", "Decor.png")).convert("RGBA")

    crystal_src = floor1.crop((0, 384, 288, 576))
    sapphire_block = recolor_cave_pixel_art(crystal_src, "sapphire")
    amethyst_block = recolor_cave_pixel_art(crystal_src, "amethyst")

    # Pure rocky cobble top strips
    sapphire_rock_top = make_pure_rock_top_strip(sapphire_block, "sapphire")
    amethyst_rock_top = make_pure_rock_top_strip(amethyst_block, "amethyst")

    crystal_top_sapphire = sapphire_block.crop((0, 0, 96, 32))
    crystal_top_amethyst = amethyst_block.crop((0, 0, 96, 32))

    sapphire_block.paste(sapphire_rock_top, (0, 0))
    sapphire_block.paste(crystal_top_sapphire, (3 * 32, 0))

    amethyst_block.paste(amethyst_rock_top, (0, 0))
    amethyst_block.paste(crystal_top_amethyst, (3 * 32, 0))

    # 1. Save 288x384 master cave_tileset_atlas.png & cave_rock_tiles.png
    atlas = Image.new("RGBA", (288, 384), (0, 0, 0, 0))
    atlas.paste(sapphire_block, (0, 0))
    atlas.paste(amethyst_block, (0, 192))

    atlas_path = os.path.join(OUT_DIR, "cave_tileset_atlas.png")
    atlas.save(atlas_path, "PNG")
    rock_tiles_path = os.path.join(OUT_DIR, "cave_rock_tiles.png")
    atlas.save(rock_tiles_path, "PNG")
    print(f"Saved {atlas_path} and {rock_tiles_path} ({atlas.size})")

    # ── 2. Build cave_platforms.png (224x160): Organic Self-Contained Floating Rock Islands ──
    plat_img = Image.new("RGBA", (224, 160), (0, 0, 0, 0))

    # Ledge building blocks
    sap_ledge = Image.new("RGBA", (96, 32), (0, 0, 0, 0))
    sap_ledge.paste(sapphire_rock_top.crop((0, 0, 96, 18)), (0, 0))
    sap_ledge.paste(sapphire_block.crop((0, 64 + 14, 96, 96)), (0, 14))

    am_ledge = Image.new("RGBA", (96, 32), (0, 0, 0, 0))
    am_ledge.paste(amethyst_rock_top.crop((0, 0, 96, 18)), (0, 0))
    am_ledge.paste(amethyst_block.crop((0, 64 + 14, 96, 96)), (0, 14))

    teeth_m = sapphire_block.crop((7 * 32, 114, 8 * 32, 146))
    teeth_r = sapphire_block.crop((8 * 32, 114, 9 * 32, 146))
    teeth_l = teeth_r.transpose(Image.FLIP_LEFT_RIGHT)

    am_teeth_m = amethyst_block.crop((7 * 32, 114, 8 * 32, 146))
    am_teeth_r = amethyst_block.crop((8 * 32, 114, 9 * 32, 146))
    am_teeth_l = am_teeth_r.transpose(Image.FLIP_LEFT_RIGHT)

    rk_top_l = sap_ledge.crop((0, 0, 32, 20))
    rk_top_m = sap_ledge.crop((32, 0, 64, 20))
    rk_top_r = sap_ledge.crop((64, 0, 96, 20))
    rk_cap_l = sap_ledge.crop((0, 14, 32, 32))
    rk_cap_m = sap_ledge.crop((32, 14, 64, 32))
    rk_cap_r = sap_ledge.crop((64, 14, 96, 32))

    am_top_l = am_ledge.crop((0, 0, 32, 20))
    am_top_m = am_ledge.crop((32, 0, 64, 20))
    am_top_r = am_ledge.crop((64, 0, 96, 20))
    am_cap_l = am_ledge.crop((0, 14, 32, 32))
    am_cap_m = am_ledge.crop((32, 14, 64, 32))
    am_cap_r = am_ledge.crop((64, 14, 96, 32))

    # 2a. island_lg (0, 0, 128, 56) - Stepped 3-tier stalactite rock island with embedded crystals
    plat_img.paste(teeth_l, (28, 22), teeth_l)
    plat_img.paste(teeth_r, (68, 22), teeth_r)
    plat_img.paste(teeth_m, (48, 24), teeth_m)
    plat_img.paste(teeth_l, (8, 12), teeth_l)
    plat_img.paste(teeth_r, (88, 12), teeth_r)
    plat_img.paste(rk_cap_l, (20, 18), rk_cap_l)
    plat_img.paste(rk_cap_m, (48, 18), rk_cap_m)
    plat_img.paste(rk_cap_r, (76, 18), rk_cap_r)
    plat_img.paste(rk_cap_l, (0, 8), rk_cap_l)
    plat_img.paste(rk_cap_r, (96, 8), rk_cap_r)
    plat_img.paste(rk_top_l, (0, 0), rk_top_l)
    plat_img.paste(rk_top_m, (32, 0), rk_top_m)
    plat_img.paste(rk_top_m, (64, 0), rk_top_m)
    plat_img.paste(rk_top_r, (96, 0), rk_top_r)

    # 2b. island_md (128, 0, 96, 48) - Stepped 96px tapered rock island
    plat_img.paste(teeth_l, (128 + 18, 16), teeth_l)
    plat_img.paste(teeth_r, (128 + 46, 16), teeth_r)
    plat_img.paste(teeth_m, (128 + 32, 18), teeth_m)
    plat_img.paste(teeth_l, (128 + 6, 10), teeth_l)
    plat_img.paste(teeth_r, (128 + 58, 10), teeth_r)
    plat_img.paste(rk_cap_l, (128 + 16, 15), rk_cap_l)
    plat_img.paste(rk_cap_r, (128 + 48, 15), rk_cap_r)
    plat_img.paste(rk_cap_l, (128, 6), rk_cap_l)
    plat_img.paste(rk_cap_r, (128 + 64, 6), rk_cap_r)
    plat_img.paste(rk_top_l, (128, 0), rk_top_l)
    plat_img.paste(rk_top_m, (160, 0), rk_top_m)
    plat_img.paste(rk_top_r, (192, 0), rk_top_r)

    # 2c. bridge (0, 64, 128, 40) - Carved stone bridge deck with corbel brackets at ends
    plat_img.paste(am_teeth_l, (6, 64 + 8), am_teeth_l)
    plat_img.paste(am_teeth_r, (90, 64 + 8), am_teeth_r)
    plat_img.paste(am_cap_l, (0, 64 + 14), am_cap_l)
    plat_img.paste(am_cap_r, (96, 64 + 14), am_cap_r)
    plat_img.paste(am_cap_m, (32, 64 + 8), am_cap_m)
    plat_img.paste(am_cap_m, (64, 64 + 8), am_cap_m)
    plat_img.paste(am_top_l, (0, 64), am_top_l)
    plat_img.paste(am_top_m, (32, 64), am_top_m)
    plat_img.paste(am_top_m, (64, 64), am_top_m)
    plat_img.paste(am_top_r, (96, 64), am_top_r)

    # 2d. crumble (128, 64, 96, 48) - Amethyst fractured stone ledge with jagged stalactite underside
    plat_img.paste(am_teeth_l, (128 + 16, 64 + 16), am_teeth_l)
    plat_img.paste(am_teeth_r, (128 + 48, 64 + 16), am_teeth_r)
    plat_img.paste(teeth_m, (128 + 32, 64 + 18), teeth_m)
    plat_img.paste(am_cap_l, (128 + 16, 64 + 14), am_cap_l)
    plat_img.paste(am_cap_r, (128 + 48, 64 + 14), am_cap_r)
    plat_img.paste(am_cap_l, (128, 64 + 6), am_cap_l)
    plat_img.paste(am_cap_r, (128 + 64, 64 + 6), am_cap_r)
    plat_img.paste(am_top_l, (128, 64), am_top_l)
    plat_img.paste(rk_top_m, (160, 64), rk_top_m)
    plat_img.paste(am_top_r, (192, 64), am_top_r)

    # 2e. sanctuary (0, 104, 160, 56) - Wide ornate lunar sanctum tier with stepped corbel base
    plat_img.paste(am_teeth_l, (34, 104 + 22), am_teeth_l)
    plat_img.paste(teeth_m, (64, 104 + 24), teeth_m)
    plat_img.paste(am_teeth_r, (94, 104 + 22), am_teeth_r)
    plat_img.paste(am_teeth_l, (10, 104 + 12), am_teeth_l)
    plat_img.paste(am_teeth_r, (118, 104 + 12), am_teeth_r)
    plat_img.paste(am_cap_l, (20, 104 + 18), am_cap_l)
    plat_img.paste(rk_cap_m, (52, 104 + 18), rk_cap_m)
    plat_img.paste(rk_cap_m, (76, 104 + 18), rk_cap_m)
    plat_img.paste(am_cap_r, (108, 104 + 18), am_cap_r)
    plat_img.paste(am_cap_l, (0, 104 + 8), am_cap_l)
    plat_img.paste(am_cap_r, (128, 104 + 8), am_cap_r)
    plat_img.paste(am_top_l, (0, 104), am_top_l)
    plat_img.paste(am_top_m, (32, 104), am_top_m)
    plat_img.paste(rk_top_m, (64, 104), rk_top_m)
    plat_img.paste(am_top_m, (96, 104), am_top_m)
    plat_img.paste(am_top_r, (128, 104), am_top_r)

    # Enhance platform top surface with crisp crystal rim lighting
    plat_img = enhance_platform_surface(plat_img, "sapphire")

    plat_path = os.path.join(OUT_DIR, "cave_platforms.png")
    plat_img.save(plat_path, "PNG")
    print(f"Saved {plat_path} ({plat_img.size})")

    # ── 3. Build cave_props.png (320x160): 100% Organic Bioluminescent Cavern Props ─────
    props_img = Image.new("RGBA", (320, 160), (0, 0, 0, 0))
    p_draw = ImageDraw.Draw(props_img)

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

    # 3a. Monolithic Crystal Spire / Stalagmite Shrine (Rect2(0, 0, 64, 96))
    p_draw.polygon([(20, 32), (14, 82), (26, 82)], fill=(45, 125, 205, 255))
    p_draw.polygon([(20, 32), (14, 82), (20, 82)], fill=(125, 215, 255, 255))
    p_draw.line([(20, 32), (20, 82)], fill=(225, 255, 255, 255), width=1)

    p_draw.polygon([(44, 40), (38, 82), (50, 82)], fill=(28, 85, 165, 255))
    p_draw.polygon([(44, 40), (38, 82), (43, 82)], fill=(95, 195, 255, 255))
    p_draw.line([(44, 40), (43, 82)], fill=(205, 245, 255, 255), width=1)

    p_draw.polygon([(32, 12), (22, 82), (42, 82)], fill=(35, 105, 185, 255))
    p_draw.polygon([(32, 12), (22, 82), (32, 82)], fill=(115, 215, 255, 255))
    p_draw.polygon([(32, 12), (22, 82), (26, 82)], fill=(165, 235, 255, 255))
    p_draw.line([(32, 12), (32, 82)], fill=(245, 255, 255, 255), width=1)
    for ry in [26, 40, 54, 66]:
        props_img.putpixel((32, ry), (255, 255, 255, 255))
        props_img.putpixel((31, ry), (200, 245, 255, 255))
        props_img.putpixel((33, ry), (200, 245, 255, 255))

    stone_base = decor.crop((40, 198, 86, 214))
    stone_base_rec = recolor_slate(stone_base, "sapphire")
    props_img.paste(stone_base_rec, (9, 70), stone_base_rec)
    stone_wedge = recolor_slate(decor.crop((64, 170, 86, 184)), "sapphire")
    props_img.paste(stone_wedge, (21, 78), stone_wedge)

    # 3b. Breakable Crystalline Geode (Cyan: 64, 0, 64, 64; Amethyst: 128, 0, 64, 64)
    for ox, is_am in [(64, False), (128, True)]:
        for gy in range(22, 56):
            for gx in range(16, 48):
                dx = (gx - 32.0) / 14.0
                dy = (gy - 38.0) / 14.0
                noise = 0.12 * np.sin(gx * 1.5) + 0.10 * np.cos(gy * 1.8)
                d = dx * dx + dy * dy + noise
                if d <= 1.0:
                    px = ox + gx
                    py = gy
                    if is_am:
                        if d > 0.65:
                            if (gx + gy) % 3 == 0:
                                props_img.putpixel((px, py), (145, 105, 185, 255))
                            else:
                                props_img.putpixel((px, py), (42, 28, 58, 255))
                        elif d > 0.38:
                            props_img.putpixel((px, py), (95, 48, 155, 255))
                        else:
                            if (gx * 3 + gy * 7) % 5 == 0:
                                props_img.putpixel((px, py), (255, 240, 255, 255))
                            elif (gx + gy) % 2 == 0:
                                props_img.putpixel((px, py), (220, 135, 255, 255))
                            else:
                                props_img.putpixel((px, py), (145, 55, 220, 255))
                    else:
                        if d > 0.65:
                            if (gx + gy) % 3 == 0:
                                props_img.putpixel((px, py), (95, 145, 195, 255))
                            else:
                                props_img.putpixel((px, py), (28, 38, 62, 255))
                        elif d > 0.38:
                            props_img.putpixel((px, py), (45, 95, 165, 255))
                        else:
                            if (gx * 3 + gy * 7) % 5 == 0:
                                props_img.putpixel((px, py), (245, 255, 255, 255))
                            elif (gx + gy) % 2 == 0:
                                props_img.putpixel((px, py), (115, 235, 255, 255))
                            else:
                                props_img.putpixel((px, py), (42, 145, 225, 255))

    # 3c. Crystal Clusters (Cyan: 192, 0, 64, 64; Amethyst: 256, 0, 64, 64)
    for ox, is_am in [(192, False), (256, True)]:
        col_lit = (220, 155, 255, 255) if is_am else (145, 235, 255, 255)
        col_hi = (255, 235, 255, 255) if is_am else (225, 255, 255, 255)
        col_shd = (115, 45, 175, 255) if is_am else (42, 125, 205, 255)
        col_drk = (85, 30, 145, 255) if is_am else (28, 90, 165, 255)

        p_draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 20, 53)], fill=col_drk)
        p_draw.polygon([(ox + 16, 34), (ox + 12, 53), (ox + 16, 53)], fill=col_lit)
        p_draw.line([(ox + 16, 34), (ox + 16, 53)], fill=col_hi, width=1)

        p_draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 29, 53)], fill=col_shd)
        p_draw.polygon([(ox + 23, 22), (ox + 18, 53), (ox + 23, 53)], fill=col_lit)
        p_draw.line([(ox + 23, 22), (ox + 23, 53)], fill=col_hi, width=1)

        p_draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 52, 53)], fill=col_drk)
        p_draw.polygon([(ox + 48, 36), (ox + 44, 53), (ox + 48, 53)], fill=col_lit)
        p_draw.line([(ox + 48, 36), (ox + 48, 53)], fill=col_hi, width=1)

        p_draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 46, 53)], fill=col_shd)
        p_draw.polygon([(ox + 41, 24), (ox + 35, 53), (ox + 40, 53)], fill=col_lit)
        p_draw.line([(ox + 41, 24), (ox + 40, 53)], fill=col_hi, width=1)

        p_draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 39, 54)], fill=col_shd)
        p_draw.polygon([(ox + 32, 12), (ox + 25, 54), (ox + 32, 54)], fill=col_lit)
        p_draw.line([(ox + 32, 12), (ox + 32, 54)], fill=(255, 255, 255, 255), width=1)
        props_img.putpixel((ox + 32, 11), (255, 255, 255, 255))
        props_img.putpixel((ox + 31, 12), (255, 255, 255, 255))
        props_img.putpixel((ox + 33, 12), (255, 255, 255, 255))

        base_w = recolor_slate(decor.crop((64, 170, 86, 184)), "amethyst" if is_am else "sapphire")
        props_img.paste(base_w, (ox + 21, 46), base_w)

    # 3f. Bioluminescent Cavern Flora & Fungi (Rect2(0, 96, 64, 64))
    oy = 96
    shrooms = [
        (20, 136, 9, (85, 225, 255), (185, 250, 255)),   # Cyan
        (34, 130, 11, (135, 245, 255), (235, 255, 255)), # Radiant Mint
        (46, 138, 8, (215, 135, 255), (255, 215, 255)),  # Lavender
    ]
    for mx, my, mr, c_base, c_glow in shrooms:
        for sy in range(my, 154):
            dx = int(1.2 * np.sin((sy - my) * 0.15))
            props_img.putpixel((mx + dx, sy), (45, 65, 88, 255))
            props_img.putpixel((mx + dx - 1, sy), (32, 48, 68, 255))
        for cy in range(my - mr // 2, my + 3):
            for cx in range(mx - mr, mx + mr + 1):
                cdx = (cx - mx) / float(mr)
                cdy = (cy - my) / float(mr // 2 + 1)
                if cdx * cdx + cdy * cdy <= 1.0:
                    if cy == my - mr // 2 + 1 and abs(cx - mx) <= mr // 2:
                        props_img.putpixel((cx, cy), (c_glow[0], c_glow[1], c_glow[2], 255))
                    else:
                        props_img.putpixel((cx, cy), (c_base[0], c_base[1], c_base[2], 255))
        props_img.putpixel((mx - 2, my - mr // 2 - 3), (c_glow[0], c_glow[1], c_glow[2], 220))
        props_img.putpixel((mx + 3, my - mr // 2 - 5), (c_glow[0], c_glow[1], c_glow[2], 180))

    # 3g. Radiant Floating Pogo Crystal Geode (Rect2(64, 96, 64, 48)) - 100% Free-Floating (NO POLES!)
    ox = 64
    oy = 96
    cx = ox + 32
    cy = oy + 24
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
        props_img.putpixel((oxc, oyc), (255, 255, 255, 255))

    # 3h. Subterranean Stalagmite & Crystal Spike Bed (Rect2(128, 96, 96, 32))
    ox = 128
    oy = 96
    spike_specs = [(8, 18), (20, 26), (34, 22), (48, 28), (62, 20), (76, 26), (88, 18)]
    for sx, sh in spike_specs:
        base_w = 6
        apex = (ox + sx, oy + 32 - sh)
        b_l = (ox + sx - base_w, oy + 32)
        b_r = (ox + sx + base_w, oy + 32)
        p_draw.polygon([apex, b_l, b_r], fill=(32, 95, 165, 255))
        p_draw.polygon([apex, b_l, (ox + sx, oy + 32)], fill=(125, 215, 255, 255))
        p_draw.line([apex, (ox + sx, oy + 32)], fill=(225, 255, 255, 255), width=1)
        props_img.putpixel(apex, (255, 255, 255, 255))

    # 3i. Ceiling Stalactite Overhang (Rect2(224, 96, 96, 64))
    ox = 224
    oy = 96
    for y in range(oy, oy + 14):
        for x in range(ox, ox + 96):
            lum = ((x * 3 + y * 7) % 7) / 7.0
            props_img.putpixel((x, y), (int(24 + lum * 24), int(32 + lum * 32), int(54 + lum * 48), 255))
    st_specs = [(12, 38), (28, 52), (44, 32), (60, 56), (76, 42), (88, 30)]
    for stx, sth in st_specs:
        bw = 7
        apex = (ox + stx, oy + sth)
        t_l = (ox + stx - bw, oy + 12)
        t_r = (ox + stx + bw, oy + 12)
        p_draw.polygon([apex, t_l, t_r], fill=(32, 95, 175, 255))
        p_draw.polygon([apex, t_l, (ox + stx, oy + 12)], fill=(115, 215, 255, 255))
        p_draw.line([apex, (ox + stx, oy + 12)], fill=(215, 255, 255, 255), width=1)
        props_img.putpixel(apex, (255, 255, 255, 255))

    props_path = os.path.join(OUT_DIR, "cave_props.png")
    props_img.save(props_path, "PNG")
    print(f"Saved {props_path} ({props_img.size})")

    # ── 4. Build clean smooth radial light falloff (assets/vfx/radial_light_falloff.png) ──
    vfx_dir = os.path.join(BASE_DIR, "assets", "vfx")
    os.makedirs(vfx_dir, exist_ok=True)
    light_size = 256
    yy, xx = np.mgrid[0:light_size, 0:light_size].astype(np.float32)
    cx = (light_size - 1) * 0.5
    cy = (light_size - 1) * 0.5
    dist = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / (light_size * 0.5)
    falloff = np.clip(1.0 - dist, 0.0, 1.0)
    intensity = (falloff ** 2.2) * (3.0 - 2.0 * falloff)
    light_rgba = np.zeros((light_size, light_size, 4), dtype=np.uint8)
    val = np.clip(intensity * 255.0, 0, 255).astype(np.uint8)
    light_rgba[:, :, 0] = 255
    light_rgba[:, :, 1] = 255
    light_rgba[:, :, 2] = 255
    light_rgba[:, :, 3] = val
    light_path = os.path.join(vfx_dir, "radial_light_falloff.png")
    Image.fromarray(light_rgba, "RGBA").save(light_path, "PNG")
    print(f"Saved clean radial light texture {light_path} ({light_size}x{light_size})")


if __name__ == "__main__":
    build_cave_tileset_atlas()

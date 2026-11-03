#!/usr/bin/env python3
"""
Integrates AI-Generated 16-Bit Pixel Art Assets into Cave Platformer:
- Loads generated raw images:
    - platforms_raw.jpg (Levitating Crystalline Rock Islands)
    - pogo_crystal_raw.jpg (Cracked Basalt Pogo Geode with Pulsing Turquoise Crystals)
    - props_raw.jpg (Bioluminescent Cyan & Amethyst Clusters, Geodes, Monolith Spire)
- Applies clean alpha transparency keying.
- Downscales with high-fidelity sharpness and palette alignment.
- Assembles into:
    - assets/cave_platformer/cave_platforms.png (224x160)
    - assets/cave_platformer/cave_props.png (320x160)
"""

import os
import numpy as np
from PIL import Image, ImageEnhance

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "assets", "generated_raw")
OUT_DIR = os.path.join(BASE_DIR, "assets", "cave_platformer")
os.makedirs(OUT_DIR, exist_ok=True)


def extract_sprite(img_path: str, bbox: tuple, target_size: tuple, bg_thresh: float = 18.0) -> Image.Image:
    """
    Crops a sprite from pure black background, computes clean alpha transparency,
    and scales to target dimensions with crisp 16-bit pixel sharpness.
    """
    img = Image.open(img_path).convert('RGBA')
    crop = img.crop(bbox)
    arr = np.array(crop, dtype=np.float32)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    brightness = np.maximum(r, np.maximum(g, b))

    # Smooth alpha edge keying for black background
    alpha = np.where(
        brightness > bg_thresh,
        255.0,
        np.where(brightness > 6.0, (brightness - 6.0) / (bg_thresh - 6.0) * 255.0, 0.0)
    )
    arr[:, :, 3] = alpha
    clean = Image.fromarray(arr.astype(np.uint8), 'RGBA')

    resized = clean.resize(target_size, Image.Resampling.LANCZOS)
    enhancer = ImageEnhance.Sharpness(resized)
    return enhancer.enhance(1.6)


def recolor_geode_interior(geode_img: Image.Image, to_cyan: bool = True) -> Image.Image:
    """Recolors the gemstone crystals inside the cracked geode to either vibrant Cyan or royal Amethyst."""
    arr = np.array(geode_img, dtype=np.float32)
    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]
    a = arr[:, :, 3]

    # Mask for gem crystals (bright non-gray pixels)
    is_gem = (a > 30) & (b > 80) & (np.maximum(r, b) - g > 20)

    if to_cyan:
        # Shift violet/magenta gem pixels to glowing electric cyan/teal
        new_r = np.where(is_gem, r * 0.25 + g * 0.15, r)
        new_g = np.where(is_gem, np.clip(b * 0.85 + g * 0.40, 0, 255), g)
        new_b = np.where(is_gem, np.clip(b * 1.10, 0, 255), b)
    else:
        # Shift to rich amethyst violet
        new_r = np.where(is_gem, np.clip(r * 1.20 + 30.0, 0, 255), r)
        new_g = np.where(is_gem, g * 0.45, g)
        new_b = np.where(is_gem, np.clip(b * 1.15, 0, 255), b)

    arr[:, :, 0] = np.clip(new_r, 0, 255)
    arr[:, :, 1] = np.clip(new_g, 0, 255)
    arr[:, :, 2] = np.clip(new_b, 0, 255)
    return Image.fromarray(arr.astype(np.uint8), 'RGBA')


def build_integrated_platforms():
    """Assembles cave_platforms.png (224x160) using generated levitating crystalline rock islands."""
    plat_raw = os.path.join(RAW_DIR, "platforms_raw.jpg")
    plat_img = Image.new("RGBA", (224, 160), (0, 0, 0, 0))

    # 1. island_lg (Rect2(0, 0, 128, 56)): Large levitating rock island
    lg_spr = extract_sprite(plat_raw, (68, 251, 672, 608), (128, 56))
    plat_img.paste(lg_spr, (0, 0), lg_spr)

    # 2. island_md (Rect2(128, 0, 96, 48)): Medium levitating rock island
    md_spr = extract_sprite(plat_raw, (751, 266, 1073, 503), (96, 48))
    plat_img.paste(md_spr, (128, 0), md_spr)

    # 3. bridge (Rect2(0, 64, 128, 40)): Long stone bridge platform with glowing crystal facets
    # Crop the flat top and upper body of the large platform, scaled horizontally to 128x40
    bridge_spr = extract_sprite(plat_raw, (68, 251, 672, 500), (128, 40))
    plat_img.paste(bridge_spr, (0, 64), bridge_spr)

    # 4. crumble / stepping stone (Rect2(128, 64, 96, 48)): Stepping stone island with glowing tip
    sm_spr = extract_sprite(plat_raw, (1161, 266, 1305, 508), (48, 48))
    # Center stepping stone within the 96x48 crumble cell so collision and physics remain reliable
    plat_img.paste(sm_spr, (128 + 24, 64), sm_spr)

    # 5. sanctuary (Rect2(0, 104, 160, 56)): Wide 160px majestic lunar sanctum island
    sanctuary_spr = extract_sprite(plat_raw, (68, 251, 672, 608), (160, 56))
    plat_img.paste(sanctuary_spr, (0, 104), sanctuary_spr)

    out_path = os.path.join(OUT_DIR, "cave_platforms.png")
    plat_img.save(out_path, "PNG")
    print(f"[OK] Saved {out_path} ({plat_img.size})")


def extract_crystal_shard(props_raw_path: str) -> Image.Image:
    """
    Extracts the radiant hexagonal / prismatic crystal shard from the ancient monolith spire,
    producing a crisp, self-contained 32x56 floating mana crystal with zero background noise
    and a subtle dark outline for 16-bit pixel art definition.
    """
    props = Image.open(props_raw_path).convert('RGB')
    arr = np.array(props, dtype=np.float32)
    # The gem on the obelisk is at (1141, 179, 1251, 319) in props_raw.jpg
    crop_arr = arr[179:319, 1141:1251]
    r, g, b = crop_arr[:, :, 0], crop_arr[:, :, 1], crop_arr[:, :, 2]

    is_crystal = ((r > 100) & (b > 160)) | ((g > 140) & (b > 170)) | ((r > 200) & (g > 200) & (b > 200)) | ((b > 170) & (g > 110))
    from scipy import ndimage
    lbl, num = ndimage.label(is_crystal)
    sizes = ndimage.sum(is_crystal, lbl, range(num + 1))
    max_lbl = np.argmax(sizes[1:]) + 1
    main_gem = (lbl == max_lbl)
    main_gem = ndimage.binary_fill_holes(main_gem)

    y_idx, x_idx = np.where(main_gem)
    min_x, max_x = x_idx.min(), x_idx.max()
    min_y, max_y = y_idx.min(), y_idx.max()

    out = np.zeros((max_y - min_y + 1, max_x - min_x + 1, 4), dtype=np.uint8)
    crop_rgb = crop_arr[min_y:max_y+1, min_x:max_x+1]
    crop_mask = main_gem[min_y:max_y+1, min_x:max_x+1]
    outline = ndimage.binary_dilation(crop_mask, iterations=1) & ~crop_mask

    out[crop_mask, :3] = crop_rgb[crop_mask]
    out[crop_mask, 3] = 255
    out[outline, 0] = 10
    out[outline, 1] = 20
    out[outline, 2] = 35
    out[outline, 3] = 255

    clean_gem = Image.fromarray(out, 'RGBA')
    scaled = clean_gem.resize((32, 56), Image.Resampling.LANCZOS)
    enhancer = ImageEnhance.Sharpness(scaled)
    sharp = enhancer.enhance(1.8)
    return sharp


def build_integrated_props():
    """Assembles cave_props.png (320x160) using natural levitating crystal shards, spires, and brittle crystal deposits."""
    props_raw = os.path.join(RAW_DIR, "props_raw.jpg")
    props_img = Image.new("RGBA", (320, 160), (0, 0, 0, 0))

    # Keep existing mushrooms from previous atlas
    bak_path = os.path.join(OUT_DIR, "cave_props.png.bak")
    if os.path.exists(bak_path):
        prev_atlas = Image.open(bak_path).convert("RGBA")
        mushrooms = prev_atlas.crop((0, 96, 64, 160))
        props_img.paste(mushrooms, (0, 96), mushrooms)

    # 1. Ancient Crystal Monolith Spire (Rect2(0, 0, 64, 96))
    spire_spr = extract_sprite(props_raw, (1101, 99, 1286, 562), (36, 88))
    props_img.paste(spire_spr, (14, 8), spire_spr)

    # 2. Brittle Mineral Crystal Deposits (Cyan: Rect2(64, 0, 64, 64); Amethyst: Rect2(128, 0, 64, 64))
    # Angular, multi-faceted crystal outcroppings rooted in craggy rock (Zero spheres/balls!)
    brittle_cyan = extract_sprite(props_raw, (61, 184, 343, 556), (42, 46))
    brittle_am = extract_sprite(props_raw, (424, 221, 653, 556), (42, 46))
    props_img.paste(brittle_cyan, (64 + 11, 18), brittle_cyan)
    props_img.paste(brittle_am, (128 + 11, 18), brittle_am)

    # 3. Bioluminescent Crystal Clusters (Cyan: Rect2(192, 0, 64, 64); Amethyst: Rect2(256, 0, 64, 64))
    cyan_cluster = extract_sprite(props_raw, (61, 184, 343, 556), (46, 54))
    am_cluster = extract_sprite(props_raw, (424, 221, 653, 556), (46, 54))
    props_img.paste(cyan_cluster, (192 + 9, 10), cyan_cluster)
    props_img.paste(am_cluster, (256 + 9, 10), am_cluster)

    # 4. Levitating Prismatic Crystal Shard (Rect2(64, 96, 64, 64))
    # Razor-sharp, multi-faceted levitating crystal shard hovering in mid-air (Zero tilesets, zero balls!)
    shard = extract_crystal_shard(props_raw)
    props_img.paste(shard, (64 + 16, 96 + 4), shard)
    shard_path = os.path.join(RAW_DIR, "levitating_crystal_shard.png")
    shard.save(shard_path, "PNG")

    # 5. Crystal Spike Bed (Rect2(128, 96, 96, 32))
    spike_single = extract_sprite(props_raw, (80, 200, 320, 550), (32, 32))
    spike_bed = Image.new("RGBA", (96, 32), (0, 0, 0, 0))
    spike_bed.paste(spike_single, (0, 0), spike_single)
    spike_bed.paste(spike_single.transpose(Image.FLIP_LEFT_RIGHT), (32, 0), spike_single.transpose(Image.FLIP_LEFT_RIGHT))
    spike_bed.paste(spike_single, (64, 0), spike_single)
    props_img.paste(spike_bed, (128, 96), spike_bed)

    out_path = os.path.join(OUT_DIR, "cave_props.png")
    props_img.save(out_path, "PNG")
    print(f"[OK] Saved {out_path} ({props_img.size})")


if __name__ == "__main__":
    build_integrated_platforms()
    build_integrated_props()

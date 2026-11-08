#!/usr/bin/env python3
"""
tools/pixelate_import.py
Asset pipeline script for HALIYA: Mask of Sorrows.

Features:
1. Validates real alpha channel and reports transparency percentages.
2. If image is opaque with white background, flood-fills transparency from image edges only.
3. Cleans edges: converts alpha to strictly 0 or 255 (50% threshold) and removes light halos/fringes.
4. Crops to tight bounding box with 2px transparent margin.
5. Downscales using strict Nearest-Neighbor sampling (no blur).
6. Quantizes all pixels to the 15-color project palette (outlines to charcoal, never pure black).
7. Cleans up isolated single pixels and dithering noise.
8. Saves clean pixel art PNGs to res://assets/art/.

Usage:
  python tools/pixelate_import.py <input.png> <output.png> --size <width> <height>
  python tools/pixelate_import.py --incoming
"""

import os
import sys
import argparse
from collections import deque
from PIL import Image
import numpy as np
from scipy import ndimage

PROJECT_PALETTE = [
    # Charcoal
    (16, 20, 18),    # dark charcoal #101412
    (30, 36, 32),    # base charcoal #1e2420
    (45, 54, 48),    # light charcoal #2d3630

    # Slate Blue
    (39, 50, 63),    # dark slate #27323f
    (58, 74, 92),    # base slate #3a4a5c
    (109, 127, 148), # light slate #6d7f94

    # Bone Cream
    (156, 149, 121), # dark bone #9c9579
    (216, 207, 168), # base bone #d8cfa8
    (240, 235, 212), # light bone #f0ebd4

    # Muted Teal
    (41, 70, 66),    # dark teal #294642
    (63, 107, 102),  # base teal #3f6b66
    (100, 157, 150), # light teal #649d96

    # Warm Gold
    (140, 111, 46),  # dark gold #8c6f2e
    (201, 162, 74),  # base gold #c9a24a
    (222, 197, 124), # light gold #dec57c

    # Danger Red
    (90, 34, 28),    # dark danger #5a221c
    (138, 59, 50),   # base danger #8a3b32
    (175, 88, 78),   # light danger #af584e
]

DEFAULT_ASSET_SIZES = {
    "totem_shrine.png": (169, 226),
    "corner_fronds_left.png": (134, 88),
    "corner_fronds_right.png": (134, 88),
    "bottom_foliage.png": (640, 54),
    "hanging_leaves.png": (160, 76),
    "offerings_flame_0.png": (6, 8),
    "offerings_flame_1.png": (6, 8),
    "charms.png": (26, 12),
}


def find_nearest_palette_color(r: int, g: int, b: int) -> tuple[int, int, int]:
    best_dist = float("inf")
    best_color = PROJECT_PALETTE[0]
    for pr, pg, pb in PROJECT_PALETTE:
        dr = r - pr
        dg = g - pg
        db = b - pb
        dist = 2 * dr * dr + 4 * dg * dg + 3 * db * db
        if dist < best_dist:
            best_dist = dist
            best_color = (pr, pg, pb)
    return best_color


def remove_white_background_if_opaque(img: Image.Image) -> Image.Image:
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    w, h = img.size
    pix = img.load()

    # Check corners
    corners = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    is_corner_white = all(pix[cx, cy][0] > 240 and pix[cx, cy][1] > 240 and pix[cx, cy][2] > 240 for cx, cy in corners)

    alpha_channel = img.split()[-1]
    zero_alpha = sum(1 for a in alpha_channel.getdata() if a == 0)
    has_alpha = zero_alpha > (w * h * 0.05)

    if not has_alpha and is_corner_white:
        print("  [flood_fill] Detected opaque white background. Removing from edges...")
        visited = set()
        queue = deque()
        for x in range(w):
            queue.append((x, 0))
            queue.append((x, h - 1))
        for y in range(h):
            queue.append((0, y))
            queue.append((w - 1, y))

        while queue:
            cx, cy = queue.popleft()
            if (cx, cy) in visited or not (0 <= cx < w and 0 <= cy < h):
                continue
            visited.add((cx, cy))
            r, g, b, a = pix[cx, cy]
            if r > 240 and g > 240 and b > 240:
                pix[cx, cy] = (0, 0, 0, 0)
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = cx + dx, cy + dy
                    if (nx, ny) not in visited:
                        queue.append((nx, ny))
    return img


def clean_edges_and_halos(img: Image.Image, alpha_threshold: int = 128) -> Image.Image:
    w, h = img.size
    pix = img.load()

    # 1. Binary alpha
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a < alpha_threshold:
                pix[x, y] = (0, 0, 0, 0)
            else:
                pix[x, y] = (r, g, b, 255)

    # 2. Fringe/halo filter on edges
    to_clear = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] == 255:
                is_edge = False
                neighbor_lum = []
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        if dx == 0 and dy == 0:
                            continue
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            if pix[nx, ny][3] == 0:
                                is_edge = True
                            else:
                                nr, ng, nb, _ = pix[nx, ny]
                                neighbor_lum.append(0.299 * nr + 0.587 * ng + 0.114 * nb)
                        else:
                            is_edge = True
                if is_edge:
                    r, g, b, _ = pix[x, y]
                    lum = 0.299 * r + 0.587 * g + 0.114 * b
                    if neighbor_lum and lum > 140 and (sum(neighbor_lum) / len(neighbor_lum)) < 90:
                        to_clear.append((x, y))
                    elif not neighbor_lum and lum > 180:
                        to_clear.append((x, y))

    for x, y in to_clear:
        pix[x, y] = (0, 0, 0, 0)

    return img


def crop_tight_with_margin(img: Image.Image, margin: int = 2) -> Image.Image:
    alpha = img.split()[-1]
    bbox = alpha.getbbox()
    if not bbox:
        return img
    cropped = img.crop(bbox)
    new_w = cropped.width + margin * 2
    new_h = cropped.height + margin * 2
    out = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
    out.paste(cropped, (margin, margin))
    return out


def remove_isolated_pixels(img: Image.Image) -> Image.Image:
    w, h = img.size
    pix = img.load()
    to_clear = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] > 0:
                neighbors = 0
                for dy in [-1, 0, 1]:
                    for dx in [-1, 0, 1]:
                        if dx == 0 and dy == 0:
                            continue
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and pix[nx, ny][3] > 0:
                            neighbors += 1
                if neighbors <= 1:
                    to_clear.append((x, y))
    for x, y in to_clear:
        pix[x, y] = (0, 0, 0, 0)
    return img


def process_image(input_path: str, output_path: str, target_size: tuple[int, int] | None = None,
                  crop_rect: tuple[int, int, int, int] | None = None, alpha_threshold: int = 128) -> None:
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file not found: {input_path}")

    raw = Image.open(input_path).convert("RGBA")
    raw_size = raw.size
    raw_colors = len(set(raw.getdata()))
    raw_trans = sum(1 for p in raw.split()[-1].getdata() if p == 0) / (raw.width * raw.height) * 100

    raw = remove_white_background_if_opaque(raw)

    if crop_rect:
        raw = raw.crop(crop_rect)

    cleaned = clean_edges_and_halos(raw, alpha_threshold=alpha_threshold)
    tight = crop_tight_with_margin(cleaned, margin=2)

    if target_size:
        downscaled = tight.resize(target_size, resample=Image.Resampling.NEAREST)
    else:
        downscaled = tight

    # Palette quantization
    pix = downscaled.load()
    w, h = downscaled.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a < 128:
                pix[x, y] = (0, 0, 0, 0)
            else:
                qr, qg, qb = find_nearest_palette_color(r, g, b)
                pix[x, y] = (qr, qg, qb, 255)

    filtered = remove_isolated_pixels(downscaled)
    final_colors = len(set(filtered.getdata()))
    final_trans = sum(1 for p in filtered.split()[-1].getdata() if p == 0) / (w * h) * 100

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    filtered.save(output_path, "PNG")

    print(f"[pixelate_import] {os.path.basename(output_path)}:")
    print(f"  Before: {raw_size[0]}x{raw_size[1]}, {raw_colors} unique colors, {raw_trans:.1f}% transparent")
    print(f"  After:  {w}x{h}, {final_colors} palette colors, {final_trans:.1f}% transparent")


def lower_foliage_under_shrine(foliage_path: str, clearing_x_range: tuple[int, int] = (415, 550), max_row: int = 34) -> None:
    if not os.path.exists(foliage_path):
        return
    img = Image.open(foliage_path).convert("RGBA")
    w, h = img.size
    pix = img.load()
    modified = False
    for x in range(clearing_x_range[0], min(w, clearing_x_range[1] + 1)):
        for y in range(0, min(h, max_row)):
            if pix[x, y][3] > 0:
                pix[x, y] = (0, 0, 0, 0)
                modified = True
    if modified:
        img.save(foliage_path, "PNG")
        print(f"[pixelate_import] Lowered bottom foliage under shrine clearing x={clearing_x_range} to row > {max_row}")


def process_hud_trio(img_path: str, factor: int = 10, is_crescent: bool = True) -> tuple[list[Image.Image], int, int]:
    """
    Imports a 3-icon trio image (e.g. Crescent Moon Trio or Amulet Trio).
    1. Removes opaque edge white if present, enforces binary alpha.
    2. Splits into 3 equal-width slots without breaking connected components.
    3. Aligns all 3 states by the top-left edge of the main body (> 2% pixel area).
    4. Pads all three to identical canvas dimensions.
    5. Downscales with nearest-neighbor by integer factor (10).
    6. Quantizes to project palette with outlines mapped to charcoal (no pure black).
    """
    raw = Image.open(img_path).convert("RGBA")
    raw = remove_white_background_if_opaque(raw)
    raw = clean_edges_and_halos(raw, alpha_threshold=128)

    w, h = raw.size
    slot_w = w / 3.0

    slots_data = []
    for s in range(3):
        x0 = int(round(s * slot_w))
        x1 = int(round((s + 1) * slot_w))
        slot_img = raw.crop((x0, 0, x1, h))
        slot_arr = np.array(slot_img)
        alpha = slot_arr[:, :, 3] > 128

        all_rows = np.where(alpha.any(axis=1))[0]
        all_cols = np.where(alpha.any(axis=0))[0]

        lbl, num = ndimage.label(alpha)
        sizes = ndimage.sum(alpha, lbl, range(1, num + 1))
        total_px = np.sum(alpha)

        main_mask = np.zeros_like(alpha, dtype=bool)
        for c_idx, sz in enumerate(sizes, start=1):
            if sz >= total_px * 0.02:
                main_mask |= (lbl == c_idx)

        # In crescent slot 0, exclude tear (below y=282) from computing main body top-left anchor
        if is_crescent and s == 0:
            main_mask[283:, :] = False

        m_rows = np.where(main_mask.any(axis=1))[0]
        m_cols = np.where(main_mask.any(axis=0))[0]

        slots_data.append({
            "img": slot_img,
            "m_top": m_rows.min(),
            "m_left": m_cols.min(),
            "m_bottom": m_rows.max(),
            "m_right": m_cols.max(),
            "all_top": all_rows.min(),
            "all_left": all_cols.min(),
            "all_bottom": all_rows.max(),
            "all_right": all_cols.max(),
        })

    max_d_left = max(s["m_left"] - s["all_left"] for s in slots_data)
    max_d_top = max(s["m_top"] - s["all_top"] for s in slots_data)
    max_d_right = max(s["all_right"] - s["m_left"] for s in slots_data)
    max_d_bottom = max(s["all_bottom"] - s["m_top"] for s in slots_data)

    pad_w = max_d_left + max_d_right + 1
    pad_h = max_d_top + max_d_bottom + 1

    rem_w = pad_w % factor
    if rem_w != 0:
        pad_w += (factor - rem_w)
    rem_h = pad_h % factor
    if rem_h != 0:
        pad_h += (factor - rem_h)

    aligned_imgs = []
    for s in slots_data:
        canvas = Image.new("RGBA", (pad_w, pad_h), (0, 0, 0, 0))
        paste_x = max_d_left - s["m_left"]
        paste_y = max_d_top - s["m_top"]
        canvas.paste(s["img"], (paste_x, paste_y))

        target_size = (pad_w // factor, pad_h // factor)
        downscaled = canvas.resize(target_size, Image.Resampling.NEAREST)
        
        # Quantize to project palette
        pix = downscaled.load()
        dw, dh = downscaled.size
        for y in range(dh):
            for x in range(dw):
                r, g, b, a = pix[x, y]
                if a < 128:
                    pix[x, y] = (0, 0, 0, 0)
                else:
                    best_c = find_nearest_palette_color(r, g, b)
                    pix[x, y] = (best_c[0], best_c[1], best_c[2], 255)

        filtered = remove_isolated_pixels(downscaled)
        aligned_imgs.append(filtered)

    return aligned_imgs, pad_w // factor, pad_h // factor


def process_stamina_bar_frame(img_path: str, factor: int = 10, repeat_count: int = 6) -> dict[str, Image.Image]:
    """
    Imports Ornate_Pixel_Fantasy_Status_Bars.png:
    1. Splits top (empty) bar from bottom (filled) bar along the horizontal gap.
    2. Cuts into left cap (spiral + ribbon), repeating bamboo section (between joints), and right cap.
    3. Quantizes to palette and downscales with nearest neighbor by factor (10).
    4. Assembles full frame tiled to repeat_count sections (130-131px wide).
    5. Clears inner track channel so procedural fill and exhaustion flash render cleanly.
    """
    raw = Image.open(img_path).convert("RGBA")
    raw = remove_white_background_if_opaque(raw)
    raw = clean_edges_and_halos(raw, alpha_threshold=128)

    # Empty frame occupies rows 36..174, cols 33..990
    top_bar = raw.crop((33, 36, 991, 175))

    # Joints are at x=119, 299, 479, 659, 839
    left_cap_raw = top_bar.crop((0, 0, 119, top_bar.height))
    mid_sec_raw = top_bar.crop((119, 0, 299, top_bar.height))
    right_cap_raw = top_bar.crop((839, 0, top_bar.width, top_bar.height))

    def _downscale_and_quantize(im: Image.Image) -> Image.Image:
        ds = im.resize((im.width // factor, im.height // factor), Image.Resampling.NEAREST)
        pix = ds.load()
        dw, dh = ds.size
        for y in range(dh):
            for x in range(dw):
                r, g, b, a = pix[x, y]
                if a < 128:
                    pix[x, y] = (0, 0, 0, 0)
                else:
                    best_c = find_nearest_palette_color(r, g, b)
                    pix[x, y] = (best_c[0], best_c[1], best_c[2], 255)
        return remove_isolated_pixels(ds)

    left_ds = _downscale_and_quantize(left_cap_raw)
    mid_ds = _downscale_and_quantize(mid_sec_raw)
    right_ds = _downscale_and_quantize(right_cap_raw)

    # Assemble tiled frame
    total_w = left_ds.width + repeat_count * mid_ds.width + right_ds.width
    assembled = Image.new("RGBA", (total_w, left_ds.height), (0, 0, 0, 0))
    assembled.paste(left_ds, (0, 0))
    cur_x = left_ds.width
    for i in range(repeat_count):
        assembled.paste(mid_ds, (cur_x, 0))
        cur_x += mid_ds.width
    assembled.paste(right_ds, (cur_x, 0))

    # Clear inner dark track window (between left ribbon and right ribbon, rows y=3..7)
    # so code-drawn stamina fill and track exhaustion flash show through
    pix = assembled.load()
    track_start_x = left_ds.width
    track_end_x = total_w - right_ds.width
    for y in range(3, 8):
        for x in range(track_start_x, track_end_x):
            r, g, b, a = pix[x, y]
            if a > 0 and r <= 45 and g <= 54 and b <= 48:
                pix[x, y] = (0, 0, 0, 0)

    return {
        "left": left_ds,
        "mid": mid_ds,
        "right": right_ds,
        "assembled": assembled,
        "track_rect": (track_start_x, 3, track_end_x - track_start_x, 5),
    }


def make_plain_procedural_notched_frame(w: int = 78, h: int = 5) -> Image.Image:
    """
    Generates plain procedural notched stamina frame per size budget:
    1px charcoal outline (#101412) with 1px notched corners,
    transparent inner slate track window (allowing code-drawn track & fill to show),
    and 2px bone-cream end caps (#d8cfa8).
    """
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    C_CHARCOAL = (16, 20, 18, 255) # 1px charcoal outline
    C_BONE = (216, 207, 168, 255)  # 2px bone-cream end caps

    # Outline with notched corners
    for x in range(1, w - 1):
        im.putpixel((x, 0), C_CHARCOAL)
        im.putpixel((x, h - 1), C_CHARCOAL)
    for y in range(1, h - 1):
        im.putpixel((0, y), C_CHARCOAL)
        im.putpixel((w - 1, y), C_CHARCOAL)

    # 2px bone-cream end caps
    for y in range(1, h - 1):
        im.putpixel((1, y), C_BONE)
        im.putpixel((2, y), C_BONE)
        im.putpixel((w - 3, y), C_BONE)
        im.putpixel((w - 2, y), C_BONE)

    return im


def import_hud_status_assets(incoming_dir: str, ui_dir: str, factor: int = 17) -> None:
    print(f"=== Processing Incoming HUD Status Assets (Factor {factor}) ===")
    os.makedirs(ui_dir, exist_ok=True)

    # 1. HP Crescent Moon Trio
    crescent_file = os.path.join(incoming_dir, "Pixel_Art_Crescent_Moon_Trio.png")
    cw, ch = 14, 18
    if os.path.exists(crescent_file):
        c_imgs, cw, ch = process_hud_trio(crescent_file, factor=factor, is_crescent=True)
        hp_names = ["hp_full.png", "hp_empty.png", "hp_damaged.png"]
        for idx, name in enumerate(hp_names):
            out_path = os.path.join(ui_dir, name)
            c_imgs[idx].save(out_path, "PNG")
            colors = len(set(c_imgs[idx].getdata()))
            print(f"  [HP] {name}: {cw}x{ch} px, {colors} palette colors (factor={factor})")

    # 2. Shield Amulet Trio
    amulet_file = os.path.join(incoming_dir, "Pixel_Art_Amulet_Trio.png")
    aw, ah = 14, 18
    if os.path.exists(amulet_file):
        a_imgs, aw, ah = process_hud_trio(amulet_file, factor=factor, is_crescent=False)
        shield_names = ["shield_intact.png", "shield_cracked.png", "shield_broken.png"]
        for idx, name in enumerate(shield_names):
            out_path = os.path.join(ui_dir, name)
            a_imgs[idx].save(out_path, "PNG")
            colors = len(set(a_imgs[idx].getdata()))
            print(f"  [SHIELD] {name}: {aw}x{ah} px, {colors} palette colors (factor={factor})")

    # 3. Stamina Frame
    # The ornate frame (spiral caps, ribbon tails, bamboo joints) turns to mush at 5px tall.
    # Replace with plain procedural notched frame (1px charcoal outline, slate track window, 2px bone-cream end caps).
    stamina_w = 5 * cw + 4 * 2 # Matches HP row width (e.g. 5*14 + 4*2 = 78px)
    stamina_h = 5
    notched_frame = make_plain_procedural_notched_frame(w=stamina_w, h=stamina_h)
    notched_frame.save(os.path.join(ui_dir, "stamina_frame.png"), "PNG")
    print(f"  [STAMINA] stamina_frame.png: {stamina_w}x{stamina_h} px plain procedural notched frame")

    # 4. Cluster Bayer Dithered Dark Gradient (sized to cover new compact cluster)
    bg_w, bg_h = stamina_w + 26, 46 + 12 # 104x58 px
    bg_img = Image.new("RGBA", (bg_w, bg_h), (0, 0, 0, 0))
    bayer_matrix = [
        [0, 8, 2, 10],
        [12, 4, 14, 6],
        [3, 11, 1, 9],
        [15, 7, 13, 5],
    ]
    for y in range(bg_h):
        for x in range(bg_w):
            norm_x = x / float(bg_w)
            norm_y = y / float(bg_h)
            fade_x = max(0.0, 1.0 - norm_x ** 1.3)
            fade_y = max(0.0, 1.0 - norm_y ** 1.3)
            dens = fade_x * fade_y
            target_a = dens * 180.0
            bval = (bayer_matrix[y & 3][x & 3] + 0.5) / 16.0
            if (target_a / 255.0) > bval * 0.40:
                out_a = min(220, int(round(target_a * 1.3)))
                if out_a > 12:
                    bg_img.putpixel((x, y), (16, 20, 18, out_a))
    bg_img.save(os.path.join(ui_dir, "hud_cluster_bg_gradient.png"), "PNG")
    print(f"  [BG] hud_cluster_bg_gradient.png: {bg_w}x{bg_h} px")

    print("=== HUD Status Asset Import Complete ===")


def import_incoming(incoming_dir: str, art_dir: str, ui_dir: str) -> None:
    print("=== Processing Incoming Art Assets ===")

    # 1. Totem Shrine (Full piece: totem, base, roots, offerings)
    shrine_path = os.path.join(incoming_dir, "totem_shrine.png")
    if os.path.exists(shrine_path):
        process_image(shrine_path, os.path.join(art_dir, "totem_shrine.png"),
                      target_size=(169, 226))

    # 2. Corner Fronds Left
    fronds_l_path = os.path.join(incoming_dir, "corner_fronds_left.png")
    if os.path.exists(fronds_l_path):
        out_l = os.path.join(art_dir, "corner_fronds_left.png")
        process_image(fronds_l_path, out_l, target_size=(134, 88))
        # Mirror for Corner Fronds Right
        fronds_l_img = Image.open(out_l)
        fronds_r_img = fronds_l_img.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        fronds_r_path = os.path.join(art_dir, "corner_fronds_right.png")
        fronds_r_img.save(fronds_r_path, "PNG")
        print(f"[pixelate_import] corner_fronds_right.png: mirrored from left ({fronds_r_img.size[0]}x{fronds_r_img.size[1]})")

    # 3. Bottom Foliage Strip
    bottom_path = os.path.join(incoming_dir, "bottom_foliage.png")
    if os.path.exists(bottom_path):
        bot_out = os.path.join(art_dir, "bottom_foliage.png")
        process_image(bottom_path, bot_out, target_size=(640, 54))
        lower_foliage_under_shrine(bot_out, clearing_x_range=(415, 550), max_row=34)

    # 4. Hanging Leaves (optional)
    hanging_path = os.path.join(incoming_dir, "hanging_leaves.png")
    if os.path.exists(hanging_path):
        process_image(hanging_path, os.path.join(art_dir, "hanging_leaves.png"), target_size=(160, 76))

    # 5. Incoming HUD Status Assets (Crescents, Amulets, Stamina Plain Notched Frame)
    import_hud_status_assets(incoming_dir, ui_dir, factor=17)

    print("=== Incoming Asset Import Complete ===")


def main():
    parser = argparse.ArgumentParser(description="Downscale, palette-quantize, and binary-alpha PNG assets.")
    parser.add_argument("input", nargs="?", help="Input PNG file path")
    parser.add_argument("output", nargs="?", help="Output PNG file path")
    parser.add_argument("--size", nargs=2, type=int, metavar=("WIDTH", "HEIGHT"), help="Target dimensions")
    parser.add_argument("--incoming", action="store_true", help="Process all assets in res://assets/art/incoming/")
    parser.add_argument("--hud", action="store_true", help="Process HUD status assets (HP, Shield, Stamina)")
    parser.add_argument("--factor", type=int, default=17, help="Downscale factor for HUD status assets (default: 17)")
    args = parser.parse_args()

    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    incoming_dir = os.path.join(project_root, "assets", "art", "incoming")
    art_dir = os.path.join(project_root, "assets", "art")
    ui_dir = os.path.join(project_root, "assets", "ui")

    if args.hud:
        import_hud_status_assets(incoming_dir, ui_dir, factor=args.factor)
        return

    if args.incoming:
        import_incoming(incoming_dir, art_dir, ui_dir)
        return

    if not args.input:
        parser.print_help()
        sys.exit(1)

    out_path = args.output if args.output else args.input
    target_sz = (args.size[0], args.size[1]) if args.size else None
    process_image(args.input, out_path, target_size=target_sz)


if __name__ == "__main__":
    main()

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


def import_incoming(incoming_dir: str, art_dir: str) -> None:
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

    print("=== Incoming Asset Import Complete ===")


def main():
    parser = argparse.ArgumentParser(description="Downscale, palette-quantize, and binary-alpha PNG assets.")
    parser.add_argument("input", nargs="?", help="Input PNG file path")
    parser.add_argument("output", nargs="?", help="Output PNG file path")
    parser.add_argument("--size", nargs=2, type=int, metavar=("WIDTH", "HEIGHT"), help="Target dimensions")
    parser.add_argument("--incoming", action="store_true", help="Process all assets in res://assets/art/incoming/")
    args = parser.parse_args()

    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    incoming_dir = os.path.join(project_root, "assets", "art", "incoming")
    art_dir = os.path.join(project_root, "assets", "art")

    if args.incoming:
        import_incoming(incoming_dir, art_dir)
        return

    if not args.input:
        parser.print_help()
        sys.exit(1)

    out_path = args.output if args.output else args.input
    target_sz = (args.size[0], args.size[1]) if args.size else None
    process_image(args.input, out_path, target_size=target_sz)


if __name__ == "__main__":
    main()

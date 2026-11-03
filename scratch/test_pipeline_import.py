import os
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

def find_nearest_palette_color(r: int, g: int, b: int) -> tuple[int, int, int]:
    best_dist = float("inf")
    best_color = PROJECT_PALETTE[0]
    for pr, pg, pb in PROJECT_PALETTE:
        dr = r - pr
        dg = g - pg
        db = b - pb
        # Perceptually weighted Euclidean distance
        dist = 2 * dr * dr + 4 * dg * dg + 3 * db * db
        if dist < best_dist:
            best_dist = dist
            best_color = (pr, pg, pb)
    return best_color

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
                
    # 2. Remove light halo / fringe pixels along edges
    # Any edge pixel touching transparent space that is substantially brighter than interior neighbors
    to_clear = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] == 255:
                # check if touching transparent neighbor
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
                    # If this edge pixel is bright (e.g. lum > 140) while its opaque neighbors are dark (avg < 90)
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
    min_x, min_y, max_x, max_y = bbox
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

def process_asset(input_path: str, target_size: tuple[int, int], crop_rect: tuple[int, int, int, int] | None = None) -> Image.Image:
    raw = Image.open(input_path).convert("RGBA")
    raw_size = raw.size
    raw_colors = len(set(raw.getdata()))
    raw_trans = sum(1 for p in raw.split()[-1].getdata() if p == 0) / (raw.width * raw.height) * 100
    
    if crop_rect:
        raw = raw.crop(crop_rect)
        
    cleaned = clean_edges_and_halos(raw)
    tight = crop_tight_with_margin(cleaned, margin=2)
    downscaled = tight.resize(target_size, resample=Image.Resampling.NEAREST)
    
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
    
    print(f"Asset: {os.path.basename(input_path)}")
    print(f"  Before: {raw_size[0]}x{raw_size[1]}, {raw_colors} unique RGBA colors, {raw_trans:.1f}% transparent")
    print(f"  After:  {w}x{h}, {final_colors} unique RGBA colors, {final_trans:.1f}% transparent")
    return filtered

incoming_dir = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\incoming"
art_dir = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art"

# 1. Totem Shrine (stone altar platform with flat top at y=405, roots, offerings, bowls, lamps)
shrine_in = os.path.join(incoming_dir, "totem_shrine.png")
shrine_out = process_asset(shrine_in, (146, 46), crop_rect=(80, 405, 915, 660))
shrine_out.save(os.path.join(art_dir, "totem_shrine.png"), "PNG")

# 2. Corner Fronds Left
fronds_in = os.path.join(incoming_dir, "corner_fronds_left.png")
fronds_l_out = process_asset(fronds_in, (134, 88))
fronds_l_out.save(os.path.join(art_dir, "corner_fronds_left.png"), "PNG")

# Mirror for Corner Fronds Right
fronds_r_out = fronds_l_out.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
fronds_r_out.save(os.path.join(art_dir, "corner_fronds_right.png"), "PNG")
print(f"Asset: corner_fronds_right.png (mirrored from left): {fronds_r_out.size}")

# 3. Bottom Foliage Strip (640x54)
bottom_in = os.path.join(incoming_dir, "bottom_foliage.png")
bottom_out = process_asset(bottom_in, (640, 54))
bottom_out.save(os.path.join(art_dir, "bottom_foliage.png"), "PNG")

# 4. Hanging Leaves (160x76)
hanging_in = os.path.join(incoming_dir, "hanging_leaves.png")
hanging_out = process_asset(hanging_in, (160, 76))
hanging_out.save(os.path.join(art_dir, "hanging_leaves.png"), "PNG")

print("\n--- All incoming assets processed into res://assets/art/ ---")

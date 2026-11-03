import os
from collections import deque
import numpy as np
from PIL import Image
from scipy.ndimage import binary_dilation

BRAIN_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
OUT_DIR = "assets/bicol_bg"

W_TARGET = 4256
H_TARGET = 720

def remove_sky_floodfill(img_path, threshold=240):
    """
    Floodfill from the top boundary to extract sky with zero holes in content.
    Zeroes out RGB values in transparent regions to prevent color ghosting.
    Applies soft alpha feathering on the silhouette boundary.
    """
    im = Image.open(img_path).convert("RGBA")
    arr = np.array(im, dtype=np.uint8)
    H, W, _ = arr.shape

    is_white_sky = (arr[:, :, 0] > threshold) & (arr[:, :, 1] > threshold) & (arr[:, :, 2] > threshold)
    visited = np.zeros((H, W), dtype=bool)
    queue = deque()

    # Seed top row
    for x in range(W):
        if is_white_sky[0, x]:
            visited[0, x] = True
            queue.append((0, x))

    # Seed top margins
    for y in range(min(120, H)):
        for x in [0, W - 1]:
            if is_white_sky[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))

    while queue:
        y, x = queue.popleft()
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = y + dy, x + dx
            if 0 <= ny < H and 0 <= nx < W and not visited[ny, nx]:
                if is_white_sky[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))

    alpha = np.ones((H, W), dtype=np.uint8) * 255
    alpha[visited] = 0

    # Soft feather on boundary
    dilated = binary_dilation(visited, iterations=3)
    fringe = dilated & (~visited)
    for y, x in zip(*np.where(fringe)):
        brightness = (int(arr[y, x, 0]) + int(arr[y, x, 1]) + int(arr[y, x, 2])) / 3.0
        if brightness > 210:
            a = int(max(0, min(255, (255 - brightness) / 45.0 * 255)))
            alpha[y, x] = a

    # Clean transparent pixels: zero out RGB so no ghosting can ever occur
    zero_mask = alpha < 2
    arr[zero_mask, 0] = 0
    arr[zero_mask, 1] = 0
    arr[zero_mask, 2] = 0
    arr[:, :, 3] = alpha

    return Image.fromarray(arr)

def smart_overlap_blend(arrA, arrB):
    """
    Blends two overlapping slices of shape (H, W_overlap, 4).
    Where both slices have opaque content, cross-fades smoothly with a cosine ramp.
    Where only one slice has content (e.g. a palm tree in sky), preserves it with 100% opacity.
    Where neither has content, keeps transparent sky.
    """
    H, W, _ = arrA.shape
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, W))).reshape(1, W, 1)

    alphaA = arrA[:, :, 3:4]
    alphaB = arrB[:, :, 3:4]

    combined_alpha = np.maximum(alphaA, alphaB)

    rgbA = arrA[:, :, :3]
    rgbB = arrB[:, :, :3]

    both_solid = (alphaA > 15) & (alphaB > 15)
    only_A = (alphaA > 15) & (alphaB <= 15)
    only_B = (alphaB > 15) & (alphaA <= 15)
    neither = (alphaA <= 15) & (alphaB <= 15)

    out_rgb = np.zeros((H, W, 3), dtype=np.float32)
    out_rgb[only_A[:, :, 0]] = rgbA[only_A[:, :, 0]]
    out_rgb[only_B[:, :, 0]] = rgbB[only_B[:, :, 0]]
    out_rgb[both_solid[:, :, 0]] = (rgbA * (1.0 - t) + rgbB * t)[both_solid[:, :, 0]]

    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, :3] = out_rgb
    out[:, :, 3:4] = combined_alpha
    out[neither[:, :, 0]] = 0

    return out

def chain_panoramas_smart(segments, target_w=W_TARGET, target_h=H_TARGET, overlap_w=250):
    """
    Chains segments together horizontally using smart_overlap_blend,
    guaranteeing seamless horizontal wrapping with zero ghosting or transparency artifacts.
    """
    # 1. Scale all segments to target_h
    scaled_segs = []
    for s in segments:
        w = int(s.width * (target_h / s.height))
        scaled_segs.append(s.resize((w, target_h), Image.Resampling.LANCZOS))

    # 2. Build canvas incrementally
    combined_arr = np.array(scaled_segs[0], dtype=np.float32)
    idx = 1
    while combined_arr.shape[1] < target_w + overlap_w:
        next_seg = scaled_segs[idx % len(scaled_segs)]
        next_arr = np.array(next_seg, dtype=np.float32)

        cur_w = combined_arr.shape[1]
        next_w = next_arr.shape[1]

        # Slices to blend
        left_main = combined_arr[:, :cur_w - overlap_w]
        overlap_left = combined_arr[:, cur_w - overlap_w:]
        overlap_right = next_arr[:, :overlap_w]
        right_main = next_arr[:, overlap_w:]

        blended_overlap = smart_overlap_blend(overlap_left, overlap_right)

        # Concatenate horizontally
        combined_arr = np.concatenate([left_main, blended_overlap, right_main], axis=1)
        idx += 1

    # 3. Crop to target_w, and blend the right overflow into the left edge for seamless wrap
    left_edge = combined_arr[:, :overlap_w].copy()
    right_overflow = combined_arr[:, target_w:target_w + overlap_w].copy()

    # Blend right overflow into left edge
    blended_wrap = smart_overlap_blend(right_overflow, left_edge)
    final_arr = combined_arr[:, :target_w].copy()
    final_arr[:, :overlap_w] = blended_wrap

    # Also wrap the rightmost edge to match the left edge
    t_edge = (0.5 + 0.5 * np.cos(np.linspace(0, np.pi, overlap_w))).reshape(1, overlap_w, 1)
    final_arr[:, -overlap_w:] = final_arr[:, -overlap_w:] * t_edge + final_arr[:, :overlap_w] * (1.0 - t_edge)
    final_arr[:, -1] = final_arr[:, 0]

    # Clean zero alpha
    zero_mask = final_arr[:, :, 3] < 2.0
    final_arr[zero_mask] = 0

    return Image.fromarray(np.clip(final_arr, 0, 255).astype(np.uint8))

def build_all():
    os.makedirs(OUT_DIR, exist_ok=True)

    print("1. Processing Layer 4: Distant Mount Mayon + Bicol Mountain Ranges...")
    l4_mayon = remove_sky_floodfill(os.path.join(BRAIN_DIR, "mayon_realistic_distant_1791105144497.jpg"), threshold=245)
    l4_mountains = remove_sky_floodfill(os.path.join(BRAIN_DIR, "bicol_mountains_layer4_1791105664581.jpg"), threshold=245)
    # Arrange: Mountain Range -> Mayon Volcano -> Mountain Range (flipped)
    layer4 = chain_panoramas_smart([l4_mountains, l4_mayon, l4_mountains.transpose(Image.FLIP_LEFT_RIGHT)], overlap_w=280)
    layer4.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    print("   -> Rice_Field_Layer4.png saved (4256x720)!")

    print("2. Processing Layer 3: Distant Terraced Hills...")
    l3_hills1 = remove_sky_floodfill(os.path.join(BRAIN_DIR, "riceterraces_hills_layer3_1791105174318.jpg"), threshold=242)
    l3_hills2 = remove_sky_floodfill(os.path.join(BRAIN_DIR, "bicol_terraces_layer3_1791105758402.jpg"), threshold=242)
    layer3 = chain_panoramas_smart([l3_hills1, l3_hills2, l3_hills1.transpose(Image.FLIP_LEFT_RIGHT)], overlap_w=280)
    layer3.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    print("   -> Rice_Field_Layer3.png saved (4256x720)!")

    print("3. Processing Layer 2: Midground Flooded Rice Paddies...")
    l2_paddies1 = remove_sky_floodfill(os.path.join(BRAIN_DIR, "ricefield_midground_layer2_1791105211935.jpg"), threshold=242)
    l2_paddies2 = remove_sky_floodfill(os.path.join(BRAIN_DIR, "ricefield_midground_2_1791105797904.jpg"), threshold=242)
    layer2 = chain_panoramas_smart([l2_paddies1, l2_paddies2, l2_paddies1.transpose(Image.FLIP_LEFT_RIGHT)], overlap_w=280)
    layer2.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    print("   -> Rice_Field_Layer2.png saved (4256x720)!")

    print("4. Processing Layer 1: Foreground Rice Field Village & Kamalig...")
    l1_village = remove_sky_floodfill(os.path.join(BRAIN_DIR, "ricefield_fg_panorama_1791105249157.jpg"), threshold=242)
    l1_kamalig = remove_sky_floodfill(os.path.join(BRAIN_DIR, "ricefield_fg_kamalig_1791105885398.jpg"), threshold=242)
    layer1 = chain_panoramas_smart([l1_village, l1_kamalig, l1_village.transpose(Image.FLIP_LEFT_RIGHT)], overlap_w=240)
    layer1.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))
    print("   -> Rice_Field_Layer1.png saved (4256x720)!")

if __name__ == "__main__":
    build_all()

import os
from collections import deque
import numpy as np
from PIL import Image
from scipy.ndimage import binary_dilation

BRAIN_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
OUT_DIR = "assets/bicol_bg"

W_TARGET = 4256
H_TARGET = 720

def remove_sky_clean(img_path, threshold=242):
    """
    Extracts sky via top-border floodfill.
    Guarantees:
    1. Zero holes inside the mountains, huts, or trees.
    2. Transparent pixels have strictly (0, 0, 0, 0) RGBA.
    3. Soft antialiased silhouette boundary.
    """
    im = Image.open(img_path).convert("RGBA")
    arr = np.array(im, dtype=np.uint8)
    H, W, _ = arr.shape

    is_white_sky = (arr[:, :, 0] > threshold) & (arr[:, :, 1] > threshold) & (arr[:, :, 2] > threshold)
    visited = np.zeros((H, W), dtype=bool)
    queue = deque()

    for x in range(W):
        if is_white_sky[0, x]:
            visited[0, x] = True
            queue.append((0, x))

    for y in range(min(100, H)):
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

    dilated = binary_dilation(visited, iterations=2)
    fringe = dilated & (~visited)
    for y, x in zip(*np.where(fringe)):
        brightness = (int(arr[y, x, 0]) + int(arr[y, x, 1]) + int(arr[y, x, 2])) / 3.0
        if brightness > 215:
            a = int(max(0, min(255, (255 - brightness) / 40.0 * 255)))
            alpha[y, x] = a

    zero_mask = alpha < 2
    arr[zero_mask, 0] = 0
    arr[zero_mask, 1] = 0
    arr[zero_mask, 2] = 0
    arr[:, :, 3] = alpha

    return Image.fromarray(arr)

def blend_horizontal_strip(arrA, arrB, blend_w=80):
    """
    Blends two equal-height strips over blend_w columns.
    """
    H, WA, _ = arrA.shape
    _, WB, _ = arrB.shape
    
    total_w = WA + WB - blend_w
    out = np.zeros((H, total_w, 4), dtype=np.float32)
    
    out[:, :WA - blend_w] = arrA[:, :WA - blend_w]
    
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    overlapA = arrA[:, WA - blend_w:]
    overlapB = arrB[:, :blend_w]
    
    alphaA = overlapA[:, :, 3:4]
    alphaB = overlapB[:, :, 3:4]
    
    combined_alpha = np.maximum(alphaA, alphaB)
    
    both_solid = (alphaA > 15) & (alphaB > 15)
    only_A = (alphaA > 15) & (alphaB <= 15)
    only_B = (alphaB > 15) & (alphaA <= 15)
    neither = (alphaA <= 15) & (alphaB <= 15)
    
    rgb = np.zeros((H, blend_w, 3), dtype=np.float32)
    rgb[only_A[:, :, 0]] = overlapA[:, :, :3][only_A[:, :, 0]]
    rgb[only_B[:, :, 0]] = overlapB[:, :, :3][only_B[:, :, 0]]
    rgb[both_solid[:, :, 0]] = (overlapA[:, :, :3] * (1.0 - t) + overlapB[:, :, :3] * t)[both_solid[:, :, 0]]
    
    blended = np.zeros((H, blend_w, 4), dtype=np.float32)
    blended[:, :, :3] = rgb
    blended[:, :, 3:4] = combined_alpha
    blended[neither[:, :, 0]] = 0
    
    out[:, WA - blend_w:WA] = blended
    out[:, WA:] = arrB[:, blend_w:]
    
    return out

def make_seamless_loop(arr, target_w=W_TARGET, blend_w=80):
    H, cur_w, _ = arr.shape
    if cur_w < target_w + blend_w:
        raise ValueError(f"cur_w ({cur_w}) must be at least target_w + blend_w ({target_w + blend_w})")
        
    final_arr = arr[:, :target_w].copy()
    overflow = arr[:, target_w:target_w + blend_w]
    
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    
    alpha_left = final_arr[:, :blend_w, 3:4]
    alpha_over = overflow[:, :, 3:4]
    combined_alpha = np.maximum(alpha_left, alpha_over)
    
    both = (alpha_left > 15) & (alpha_over > 15)
    only_l = (alpha_left > 15) & (alpha_over <= 15)
    only_o = (alpha_over > 15) & (alpha_left <= 15)
    neither = (alpha_left <= 15) & (alpha_over <= 15)
    
    rgb = np.zeros((H, blend_w, 3), dtype=np.float32)
    rgb[only_l[:, :, 0]] = final_arr[:, :blend_w, :3][only_l[:, :, 0]]
    rgb[only_o[:, :, 0]] = overflow[:, :, :3][only_o[:, :, 0]]
    rgb[both[:, :, 0]] = (final_arr[:, :blend_w, :3] * (1.0 - t) + overflow[:, :, :3] * t)[both[:, :, 0]]
    
    final_arr[:, :blend_w, :3] = rgb
    final_arr[:, :blend_w, 3:4] = combined_alpha
    final_arr[:, :blend_w][neither[:, :, 0]] = 0
    
    final_arr[:, -1] = final_arr[:, 0]
    
    zero_mask = final_arr[:, :, 3] < 2.0
    final_arr[zero_mask] = 0
    
    return Image.fromarray(np.clip(final_arr, 0, 255).astype(np.uint8))

def build_layer_1():
    print("Building Layer 1: Authentic Philippine Village & Rice Field Foreground...")
    im_v = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_fg_panorama_1791105249157.jpg"), threshold=242)
    im_k = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_fg_kamalig_1791105885398.jpg"), threshold=242)
    
    arr_v = np.array(im_v, dtype=np.float32)
    arr_k = np.array(im_k, dtype=np.float32)
    
    # Clean cuts at open fence lines with clear sky:
    # 1. Hut 1 & palms: x=0..570
    s1 = arr_v[:, :570]
    # 2. Kamalig & resting carabao: x=100..790
    s2 = arr_k[:, 100:790]
    # 3. Banana grove & boulders: x=790..1376
    s3 = arr_k[:, 790:]
    # 4. Tall curving palm & Hut 2 & bamboo: x=570..1376
    s4 = arr_v[:, 570:]
    
    # Scale each slice to height 720
    def scale_slice(s):
        h, w, _ = s.shape
        w_scaled = int(w * (H_TARGET / h))
        return np.array(Image.fromarray(s.astype(np.uint8)).resize((w_scaled, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
        
    s1_sc = scale_slice(s1)
    s2_sc = scale_slice(s2)
    s3_sc = scale_slice(s3)
    s4_sc = scale_slice(s4)
    
    # Chain slices: s1 -> s2 -> s3 -> s4 -> s1 -> s2 -> s3
    arr = blend_horizontal_strip(s1_sc, s2_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s3_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s4_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s1_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s2_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s3_sc, blend_w=60)
    arr = blend_horizontal_strip(arr, s4_sc, blend_w=60)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=60)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))
    print("  -> Layer 1 saved successfully!")

def build_layer_2():
    print("Building Layer 2: Flooded Rice Paddies & Earthen Dikes...")
    im_p1 = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_midground_layer2_1791105211935.jpg"), threshold=242)
    im_p2 = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_midground_2_1791105797904.jpg"), threshold=242)
    
    w1 = int(im_p1.width * (H_TARGET / im_p1.height))
    w2 = int(im_p2.width * (H_TARGET / im_p2.height))
    s1 = np.array(im_p1.resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s2 = np.array(im_p2.resize((w2, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s1_flip = np.array(im_p1.transpose(Image.FLIP_LEFT_RIGHT).resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    arr = blend_horizontal_strip(s1, s2, blend_w=140)
    arr = blend_horizontal_strip(arr, s1_flip, blend_w=140)
    arr = blend_horizontal_strip(arr, s1, blend_w=140)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=140)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    print("  -> Layer 2 saved successfully!")

def build_layer_3():
    print("Building Layer 3: Distant Terraced Hills & Valleys...")
    im_h1 = remove_sky_clean(os.path.join(BRAIN_DIR, "riceterraces_hills_layer3_1791105174318.jpg"), threshold=242)
    im_h2 = remove_sky_clean(os.path.join(BRAIN_DIR, "bicol_terraces_layer3_1791105758402.jpg"), threshold=242)
    
    w1 = int(im_h1.width * (H_TARGET / im_h1.height))
    w2 = int(im_h2.width * (H_TARGET / im_h2.height))
    s1 = np.array(im_h1.resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s2 = np.array(im_h2.resize((w2, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s1_flip = np.array(im_h1.transpose(Image.FLIP_LEFT_RIGHT).resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    arr = blend_horizontal_strip(s1, s2, blend_w=140)
    arr = blend_horizontal_strip(arr, s1_flip, blend_w=140)
    arr = blend_horizontal_strip(arr, s1, blend_w=140)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=140)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    print("  -> Layer 3 saved successfully!")

def build_layer_4():
    print("Building Layer 4: Distant Mount Mayon & Bicol Mountains...")
    im_mayon = remove_sky_clean(os.path.join(BRAIN_DIR, "mayon_realistic_distant_1791105144497.jpg"), threshold=245)
    im_mtns = remove_sky_clean(os.path.join(BRAIN_DIR, "bicol_mountains_layer4_1791105664581.jpg"), threshold=245)
    
    # Mayon is 1376x768. Mountains are 1376x768.
    # Align mountains elevation with Mayon's foothill ridge (shift down by 85px)
    arr_mtns = np.array(im_mtns)
    shifted_mtns = np.zeros_like(arr_mtns)
    shifted_mtns[85:, :] = arr_mtns[:-85, :]
    im_mtns_aligned = Image.fromarray(shifted_mtns)
    
    w_m = int(im_mayon.width * (H_TARGET / im_mayon.height))
    w_mtns = int(im_mtns_aligned.width * (H_TARGET / im_mtns_aligned.height))
    
    s_mayon = np.array(im_mayon.resize((w_m, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_mtns = np.array(im_mtns_aligned.resize((w_mtns, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_mtns_flip = np.array(im_mtns_aligned.transpose(Image.FLIP_LEFT_RIGHT).resize((w_mtns, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    # Mayon is placed in the center between the mountain ranges
    arr = blend_horizontal_strip(s_mtns, s_mayon, blend_w=140)
    arr = blend_horizontal_strip(arr, s_mtns_flip, blend_w=140)
    arr = blend_horizontal_strip(arr, s_mtns, blend_w=140)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=140)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    print("  -> Layer 4 saved successfully!")

if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    build_layer_4()
    build_layer_3()
    build_layer_2()
    build_layer_1()
    print("All 4 Rice Field layers built flawlessly!")

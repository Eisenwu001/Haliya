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

    # Clean zero alpha
    zero_mask = alpha < 2
    arr[zero_mask, 0] = 0
    arr[zero_mask, 1] = 0
    arr[zero_mask, 2] = 0
    arr[:, :, 3] = alpha

    return Image.fromarray(arr)

def blend_horizontal_strip(arrA, arrB, blend_w=120):
    """
    Blends two equal-height strips over blend_w columns.
    arrA is left, arrB is right.
    """
    H, WA, _ = arrA.shape
    _, WB, _ = arrB.shape
    
    total_w = WA + WB - blend_w
    out = np.zeros((H, total_w, 4), dtype=np.float32)
    
    # Left non-overlapping
    out[:, :WA - blend_w] = arrA[:, :WA - blend_w]
    
    # Overlap region
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

def make_seamless_loop(arr, target_w=W_TARGET, blend_w=120):
    """
    Trims or wraps arr to target_w, ensuring seamless wrap at ends.
    """
    H, cur_w, _ = arr.shape
    if cur_w < target_w + blend_w:
        raise ValueError(f"cur_w ({cur_w}) must be at least target_w + blend_w ({target_w + blend_w})")
        
    final_arr = arr[:, :target_w].copy()
    overflow = arr[:, target_w:target_w + blend_w]
    
    # Blend right overflow into left margin
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
    
    # Guarantee exact pixel equality at boundary
    final_arr[:, -1] = final_arr[:, 0]
    
    # Clean zero alpha
    zero_mask = final_arr[:, :, 3] < 2.0
    final_arr[zero_mask] = 0
    
    return Image.fromarray(np.clip(final_arr, 0, 255).astype(np.uint8))

def build_layer_4():
    print("Building Layer 4 (Mount Mayon & Bicol Mountain Range)...")
    im_mayon = remove_sky_clean(os.path.join(BRAIN_DIR, "mayon_realistic_distant_1791105144497.jpg"), threshold=245)
    im_mtns = remove_sky_clean(os.path.join(BRAIN_DIR, "bicol_mountains_layer4_1791105664581.jpg"), threshold=245)
    
    # Scale to H_TARGET
    w_mayon = int(im_mayon.width * (H_TARGET / im_mayon.height))
    w_mtns = int(im_mtns.width * (H_TARGET / im_mtns.height))
    s_mayon = np.array(im_mayon.resize((w_mayon, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_mtns = np.array(im_mtns.resize((w_mtns, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_mtns_flip = np.array(im_mtns.transpose(Image.FLIP_LEFT_RIGHT).resize((w_mtns, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    # Chain: Mountains -> Mayon -> Mountains Flipped -> Mountains
    arr = blend_horizontal_strip(s_mtns, s_mayon, blend_w=160)
    arr = blend_horizontal_strip(arr, s_mtns_flip, blend_w=160)
    arr = blend_horizontal_strip(arr, s_mtns, blend_w=160)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=160)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    print("  -> Layer 4 saved!")

def build_layer_3():
    print("Building Layer 3 (Distant Terraced Hills)...")
    im_h1 = remove_sky_clean(os.path.join(BRAIN_DIR, "riceterraces_hills_layer3_1791105174318.jpg"), threshold=242)
    im_h2 = remove_sky_clean(os.path.join(BRAIN_DIR, "bicol_terraces_layer3_1791105758402.jpg"), threshold=242)
    
    w1 = int(im_h1.width * (H_TARGET / im_h1.height))
    w2 = int(im_h2.width * (H_TARGET / im_h2.height))
    s_h1 = np.array(im_h1.resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_h2 = np.array(im_h2.resize((w2, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_h1_flip = np.array(im_h1.transpose(Image.FLIP_LEFT_RIGHT).resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    arr = blend_horizontal_strip(s_h1, s_h2, blend_w=180)
    arr = blend_horizontal_strip(arr, s_h1_flip, blend_w=180)
    arr = blend_horizontal_strip(arr, s_h1, blend_w=180)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=180)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    print("  -> Layer 3 saved!")

def build_layer_2():
    print("Building Layer 2 (Midground Flooded Rice Paddies)...")
    im_p1 = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_midground_layer2_1791105211935.jpg"), threshold=242)
    im_p2 = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_midground_2_1791105797904.jpg"), threshold=242)
    
    w1 = int(im_p1.width * (H_TARGET / im_p1.height))
    w2 = int(im_p2.width * (H_TARGET / im_p2.height))
    s_p1 = np.array(im_p1.resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_p2 = np.array(im_p2.resize((w2, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    s_p1_flip = np.array(im_p1.transpose(Image.FLIP_LEFT_RIGHT).resize((w1, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    arr = blend_horizontal_strip(s_p1, s_p2, blend_w=180)
    arr = blend_horizontal_strip(arr, s_p1_flip, blend_w=180)
    arr = blend_horizontal_strip(arr, s_p1, blend_w=180)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=180)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    print("  -> Layer 2 saved!")

def build_layer_1():
    print("Building Layer 1 (Foreground Village & Kamalig)...")
    # Load source cutouts at native resolution
    im_v = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_fg_panorama_1791105249157.jpg"), threshold=242)
    im_k = remove_sky_clean(os.path.join(BRAIN_DIR, "ricefield_fg_kamalig_1791105885398.jpg"), threshold=242)
    
    # Scale to H_TARGET (720)
    w_v = int(im_v.width * (H_TARGET / im_v.height))
    w_k = int(im_k.width * (H_TARGET / im_k.height))
    sv = np.array(im_v.resize((w_v, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    sk = np.array(im_k.resize((w_k, H_TARGET), Image.Resampling.LANCZOS), dtype=np.float32)
    
    # Find the clear fence/sky gaps in scaled coordinates:
    # In im_v (orig 1376): col 580 is open fence -> 580 * 720 / 768 = 544
    # In im_k (orig 1376): col 830 is open fence -> 830 * 720 / 768 = 778
    cut_v = int(580 * (H_TARGET / im_v.height))
    cut_k = int(830 * (H_TARGET / im_k.height))
    
    # Block A: Hut 1 + banana plant (0 to cut_v)
    block_A = sv[:, :cut_v]
    # Block B: Tall palm + bamboo grove + Hut 2 (cut_v to end)
    block_B = sv[:, cut_v:]
    # Block C: Kamalig + carabao + cart (0 to cut_k)
    block_C = sk[:, :cut_k]
    # Block D: Banana grove + boulders + palm (cut_k to end)
    block_D = sk[:, cut_k:]
    
    # Sequence: Block A -> Block C -> Block B -> Block D -> Block A -> Block C -> Block B
    arr = blend_horizontal_strip(block_A, block_C, blend_w=80)
    arr = blend_horizontal_strip(arr, block_B, blend_w=80)
    arr = blend_horizontal_strip(arr, block_D, blend_w=80)
    arr = blend_horizontal_strip(arr, block_A, blend_w=80)
    arr = blend_horizontal_strip(arr, block_C, blend_w=80)
    arr = blend_horizontal_strip(arr, block_B, blend_w=80)
    arr = blend_horizontal_strip(arr, block_D, blend_w=80)
    
    out = make_seamless_loop(arr, target_w=W_TARGET, blend_w=80)
    out.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))
    print("  -> Layer 1 saved!")

if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    build_layer_4()
    build_layer_3()
    build_layer_2()
    build_layer_1()
    print("All 4 layers built successfully!")


import numpy as np
from PIL import Image
from collections import deque
from scipy.ndimage import label, binary_dilation

def extract_alpha(img_rgb, horizon_y=None, flood_thresh=30, fringe_thresh=55):
    """
    Extracts transparent sky from solid black background, defringes edge pixels,
    and removes any trapped black pockets above the horizon line.
    """
    w, h = img_rgb.size
    arr = np.array(img_rgb).astype(np.float32)
    brightness = arr.max(axis=2)
    
    # 1. Flood fill from top edge and upper borders
    bg_mask = np.zeros((h, w), dtype=bool)
    queue = deque()
    for x in range(w):
        if brightness[0, x] <= flood_thresh:
            bg_mask[0, x] = True
            queue.append((x, 0))
    for y in range(h // 2):
        if brightness[y, 0] <= flood_thresh and not bg_mask[y, 0]:
            bg_mask[y, 0] = True
            queue.append((0, y))
        if brightness[y, w - 1] <= flood_thresh and not bg_mask[y, w - 1]:
            bg_mask[y, w - 1] = True
            queue.append((w - 1, y))
            
    while queue:
        cx, cy = queue.popleft()
        for dx, dy in ((-1,0), (1,0), (0,-1), (0,1)):
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h:
                if not bg_mask[ny, nx] and brightness[ny, nx] <= flood_thresh:
                    bg_mask[ny, nx] = True
                    queue.append((nx, ny))
                    
    # 2. Also clear any trapped black pixels above horizon_y if specified
    if horizon_y is not None:
        trapped_sky = (brightness <= flood_thresh) & (np.arange(h)[:, None] < horizon_y)
        bg_mask = bg_mask | trapped_sky
        
    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    alpha[bg_mask] = 0.0
    
    # 3. Defringe transition pixels
    dilated_bg = binary_dilation(bg_mask, iterations=2)
    transition = dilated_bg & (~bg_mask)
    for y, x in zip(*np.where(transition)):
        b = brightness[y, x]
        if b < fringe_thresh:
            factor = max(0.0, (b - flood_thresh) / (fringe_thresh - flood_thresh))
            alpha[y, x] = 255.0 * factor
            
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[:, :, :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return rgba

def clean_small_components(rgba_arr, min_size=500):
    labeled, num_features = label(rgba_arr[:, :, 3] > 0)
    for i in range(1, num_features + 1):
        mask = (labeled == i)
        if mask.sum() < min_size:
            rgba_arr[mask, 3] = 0
    return rgba_arr

def seamless_blend(rgba_arr, blend_w=48):
    """
    Smooth cross-fade across the left and right border so the image tiles seamlessly horizontally.
    """
    h, w, c = rgba_arr.shape
    arr = rgba_arr.astype(np.float32)
    
    # Using cosine easing for the smoothest possible seam transition
    t = 0.5 * (1.0 - np.cos(np.linspace(0, np.pi, blend_w))) # 0.0 to 1.0
    
    for i in range(blend_w):
        weight = t[i]
        x_left = i
        x_right = w - blend_w + i
        
        c_left = arr[:, x_left].copy()
        c_right = arr[:, x_right].copy()
        
        # Blended column
        blended = (1.0 - weight) * c_right + weight * c_left
        arr[:, x_left] = (1.0 - weight) * c_left + weight * blended
        arr[:, x_right] = (1.0 - weight) * blended + weight * c_right
        
    return np.clip(arr, 0, 255).astype(np.uint8)

print("Setup helper functions...")

CANVAS_W = 2160
CANVAS_H = 720

# ── 1. LAYER 4: Mount Mayon Volcano ──────────────────────────────────────────
print("Processing Layer 4 (Mount Mayon)...")
l4_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\mayon_volcano_layer4_1791096068295.jpg")
l4_rgba = extract_alpha(l4_raw, horizon_y=490, flood_thresh=30, fringe_thresh=55)
l4_rgba = clean_small_components(l4_rgba, min_size=1000)
l4_img = Image.fromarray(l4_rgba, "RGBA").resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)
l4_arr = seamless_blend(np.array(l4_img), blend_w=64)
l4_final = Image.fromarray(l4_arr, "RGBA")
l4_final.save(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bicol_bg\Rice_Field_Layer4.png")
print("Saved Layer 4.")

# ── 2. LAYER 3: Distant Terraced Hills ────────────────────────────────────────
print("Processing Layer 3 (Distant Terraced Hills)...")
l3_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_terraces_hills_layer3_1791096044337.jpg")
l3_rgba = extract_alpha(l3_raw, horizon_y=500, flood_thresh=30, fringe_thresh=55)
l3_rgba = clean_small_components(l3_rgba, min_size=500)
l3_img = Image.fromarray(l3_rgba, "RGBA").resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)
l3_arr = seamless_blend(np.array(l3_img), blend_w=64)
l3_final = Image.fromarray(l3_arr, "RGBA")
l3_final.save(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bicol_bg\Rice_Field_Layer3.png")
print("Saved Layer 3.")

# ── 3. LAYER 2: Midground Rice Paddies & Bahay Kubo ───────────────────────────
print("Processing Layer 2 (Midground Rice Paddies)...")
l2_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_field_midground_layer2_1791096004300.jpg")
l2_rgba = extract_alpha(l2_raw, horizon_y=460, flood_thresh=30, fringe_thresh=55)
l2_rgba = clean_small_components(l2_rgba, min_size=500)
l2_img = Image.fromarray(l2_rgba, "RGBA").resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)
l2_arr = seamless_blend(np.array(l2_img), blend_w=64)
l2_final = Image.fromarray(l2_arr, "RGBA")
l2_final.save(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bicol_bg\Rice_Field_Layer2.png")
print("Saved Layer 2.")

# ── 4. LAYER 1: User's Reference Artwork ──────────────────────────────────────
print("Processing Layer 1 (User Reference Art)...")
l1_raw = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\.user_uploaded\media_1791088885584.png").convert("RGB")
l1_rgba = extract_alpha(l1_raw, horizon_y=640, flood_thresh=25, fringe_thresh=55)
l1_img = Image.fromarray(l1_rgba, "RGBA").resize((CANVAS_W, CANVAS_H), Image.Resampling.BILINEAR)
l1_arr = seamless_blend(np.array(l1_img), blend_w=64)
l1_final = Image.fromarray(l1_arr, "RGBA")
l1_final.save(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bicol_bg\Rice_Field_Layer1.png")
print("Saved Layer 1.")

print("All layers successfully finalized and saved!")

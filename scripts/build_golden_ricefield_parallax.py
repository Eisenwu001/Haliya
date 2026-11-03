import os
import math
import numpy as np
from PIL import Image, ImageFilter

W_TARGET = 4256
H_TARGET = 720

def remove_black_sky(im, threshold=16, feather_px=4):
    """
    Converts black background above the landscape to 100% alpha transparency
    using flood filling from the top and luminance thresholding.
    """
    arr = np.array(im.convert("RGBA"))
    h, w = arr.shape[:2]
    
    # Compute luminance
    lum = np.max(arr[:, :, :3], axis=2)
    
    # Find boundary: from top downwards, mark pixels that are black
    # Anything with lum <= threshold starting from top is sky
    alpha = np.ones((h, w), dtype=np.float32)
    
    # Simple column-wise scan: from top down to first non-black pixel
    for x in range(w):
        y_hit = 0
        for y in range(h):
            if lum[y, x] > threshold:
                y_hit = y
                break
        if y_hit > 0:
            alpha[:y_hit, x] = 0.0
            # Feather the transition
            for fy in range(min(feather_px, h - y_hit)):
                curr_y = y_hit + fy
                frac = float(fy + 1) / float(feather_px + 1)
                alpha[curr_y, x] = min(alpha[curr_y, x], frac)
                
    arr[:, :, 3] = np.clip(alpha * 255.0, 0, 255).astype(np.uint8)
    return Image.fromarray(arr)

def tile_seamless_cosine(im, target_w=W_TARGET, target_h=H_TARGET, repeats=3, blend_w=96):
    """
    Repeats the image horizontally with cosine edge blending to guarantee
    flawless, seamless wrapping during parallax scrolling.
    """
    single_w = int(math.ceil(target_w / float(repeats)))
    scaled_w = single_w + blend_w
    
    scaled = im.resize((scaled_w, target_h), Image.Resampling.LANCZOS)
    arr_s = np.array(scaled, dtype=np.float32)
    
    res = arr_s.copy()
    # Cosine blend weights
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    
    for _ in range(repeats - 1):
        cur_h, cur_w = res.shape[:2]
        out_w = cur_w + scaled_w - blend_w
        out = np.zeros((cur_h, out_w, 4), dtype=np.float32)
        
        # Keep left non-blended part
        out[:, :cur_w - blend_w] = res[:, :cur_w - blend_w]
        
        # Blended seam zone
        left_overlap = res[:, cur_w - blend_w:]
        right_overlap = arr_s[:, :blend_w]
        
        a_left = left_overlap[:, :, 3:4] / 255.0
        a_right = right_overlap[:, :, 3:4] / 255.0
        
        comb_a = np.maximum(a_left, a_right)
        
        blended_rgb = left_overlap[:, :, :3] * (1.0 - t) + right_overlap[:, :, :3] * t
        
        blended = np.zeros((cur_h, blend_w, 4), dtype=np.float32)
        blended[:, :, :3] = blended_rgb
        blended[:, :, 3:4] = comb_a * 255.0
        
        out[:, cur_w - blend_w:cur_w] = blended
        out[:, cur_w:] = arr_s[:, blend_w:]
        res = out
        
    final_img = Image.fromarray(np.clip(res, 0, 255).astype(np.uint8))
    # Resize to exact target dimensions
    return final_img.resize((target_w, target_h), Image.Resampling.LANCZOS)

def build_all_layers(brain_dir, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    
    # 1. Layer 4: Distant Mount Mayon Volcano & Sky
    l4_src = os.path.join(brain_dir, "mayon_volcano_golden_hour_1791206510632.jpg")
    print(f"Processing Layer 4 from {l4_src}...")
    l4_im = Image.open(l4_src).convert("RGBA")
    l4_out = tile_seamless_cosine(l4_im, repeats=3, blend_w=128)
    l4_path = os.path.join(out_dir, "Rice_Field_Layer4.png")
    l4_out.save(l4_path, "PNG")
    print(f"Saved Layer 4: {l4_path} ({l4_out.size})")
    
    # 2. Layer 3: Distant Stepped Rice Terraces & Rolling Hills
    l3_src = os.path.join(brain_dir, "rice_terraces_layer_3_1791206535074.jpg")
    print(f"Processing Layer 3 from {l3_src}...")
    l3_im = Image.open(l3_src)
    l3_clean = remove_black_sky(l3_im, threshold=16, feather_px=6)
    l3_out = tile_seamless_cosine(l3_clean, repeats=3, blend_w=96)
    l3_path = os.path.join(out_dir, "Rice_Field_Layer3.png")
    l3_out.save(l3_path, "PNG")
    print(f"Saved Layer 3: {l3_path} ({l3_out.size})")
    
    # 3. Layer 2: Midground Rice Paddies, Coconut Palms & Bahay Kubo
    l2_src = os.path.join(brain_dir, "ricefield_layer_2_midground_1791206555019.jpg")
    print(f"Processing Layer 2 from {l2_src}...")
    l2_im = Image.open(l2_src)
    l2_clean = remove_black_sky(l2_im, threshold=16, feather_px=5)
    l2_out = tile_seamless_cosine(l2_clean, repeats=3, blend_w=96)
    l2_path = os.path.join(out_dir, "Rice_Field_Layer2.png")
    l2_out.save(l2_path, "PNG")
    print(f"Saved Layer 2: {l2_path} ({l2_out.size})")
    
    # 4. Layer 1: Near Midground Rice Stalks, Talahib Grass & Taro Leaves
    l1_src = os.path.join(brain_dir, "ricefield_layer_1_foreground_1791206588538.jpg")
    print(f"Processing Layer 1 from {l1_src}...")
    l1_im = Image.open(l1_src)
    l1_clean = remove_black_sky(l1_im, threshold=18, feather_px=4)
    l1_out = tile_seamless_cosine(l1_clean, repeats=3, blend_w=96)
    l1_path = os.path.join(out_dir, "Rice_Field_Layer1.png")
    l1_out.save(l1_path, "PNG")
    print(f"Saved Layer 1: {l1_path} ({l1_out.size})")

if __name__ == "__main__":
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\c7718a4a-5c4f-4a83-8604-730ecde0e295"
    out = "assets/bicol_bg"
    build_all_layers(brain, out)

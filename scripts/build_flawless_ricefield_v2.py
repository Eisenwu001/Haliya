import os
import math
import numpy as np
from PIL import Image

BRAIN_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
OUT_DIR = "assets/bicol_bg"

W_TARGET = 4256
H_TARGET = 720

def clean_black_sky_perfect(im):
    """
    Cleans black background while strictly preserving all mountain, smoke, and tree pixels.
    """
    arr = np.array(im.convert("RGBA"))
    H, W, _ = arr.shape
    max_c = np.max(arr[:, :, :3], axis=2)
    sky_mask = (max_c < 18) & (np.arange(H)[:, None] < 530)
    arr[sky_mask, 3] = 0
    arr[sky_mask, :3] = 0
    return Image.fromarray(arr)

def tile_3_and_blend_seamless(clean_im, target_w=W_TARGET, target_h=H_TARGET, blend_w=64):
    """
    Takes an image with matching left and right edges (e.g. Mayon or Terraces)
    and tiles it across target_w with exactly 3 repeats and cosine blending,
    guaranteeing seamless wrap-around with NO clipped peaks at x=0.
    """
    effective_w = int(math.ceil(target_w / 3.0)) # 1419
    new_w = effective_w + blend_w # 1483
    
    scaled = clean_im.resize((new_w, target_h), Image.Resampling.LANCZOS)
    arr_s = np.array(scaled, dtype=np.float32)
    
    res = arr_s.copy()
    t = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    
    for _ in range(2):
        H_c, W_c, _ = res.shape
        out = np.zeros((H_c, W_c + new_w - blend_w, 4), dtype=np.float32)
        out[:, :W_c - blend_w] = res[:, :W_c - blend_w]
        
        ol_left = res[:, W_c - blend_w:]
        ol_right = arr_s[:, :blend_w]
        
        a_left = ol_left[:, :, 3:4]
        a_right = ol_right[:, :, 3:4]
        comb_a = np.maximum(a_left, a_right)
        
        both = (a_left > 10) & (a_right > 10)
        l_only = (a_left > 10) & (a_right <= 10)
        r_only = (a_right > 10) & (a_left <= 10)
        
        blended_rgb = np.zeros((H_c, blend_w, 3), dtype=np.float32)
        blended_rgb[l_only[:, :, 0]] = ol_left[:, :, :3][l_only[:, :, 0]]
        blended_rgb[r_only[:, :, 0]] = ol_right[:, :, :3][r_only[:, :, 0]]
        blended_rgb[both[:, :, 0]] = (ol_left[:, :, :3] * (1.0 - t) + ol_right[:, :, :3] * t)[both[:, :, 0]]
        
        blended = np.zeros((H_c, blend_w, 4), dtype=np.float32)
        blended[:, :, :3] = blended_rgb
        blended[:, :, 3:4] = comb_a
        
        out[:, W_c - blend_w:W_c] = blended
        out[:, W_c:] = arr_s[:, blend_w:]
        res = out

    final = res[:, :target_w].copy()
    over = res[:, target_w:target_w + blend_w]
    
    # Wrap-around blend at the boundary
    a_l = final[:, :blend_w, 3:4]
    a_o = over[:, :, 3:4]
    comb_a = np.maximum(a_l, a_o)
    both = (a_l > 10) & (a_o > 10)
    l_only = (a_l > 10) & (a_o <= 10)
    o_only = (a_o > 10) & (a_l <= 10)
    
    rgb = np.zeros((target_h, blend_w, 3), dtype=np.float32)
    rgb[l_only[:, :, 0]] = final[:, :blend_w, :3][l_only[:, :, 0]]
    rgb[o_only[:, :, 0]] = over[:, :, :3][o_only[:, :, 0]]
    rgb[both[:, :, 0]] = (final[:, :blend_w, :3] * (1.0 - t) + over[:, :, :3] * t)[both[:, :, 0]]
    
    final[:, :blend_w, :3] = rgb
    final[:, :blend_w, 3:4] = comb_a
    final[:, -1] = final[:, 0]
    
    zero_mask = final[:, :, 3] < 5.0
    final[zero_mask] = 0
    return Image.fromarray(np.clip(final, 0, 255).astype(np.uint8))

def build_all_rice_field_layers():
    print("=== Building All 4 Rice Field Layers ===")
    
    # Layer 4: Mayon Volcano
    print("1. Layer 4 (Mount Mayon)...")
    raw4 = Image.open(os.path.join(BRAIN_DIR, "mayon_volcano_layer4_1791096068295.jpg"))
    clean4 = clean_black_sky_perfect(raw4)
    out4 = tile_3_and_blend_seamless(clean4, W_TARGET, H_TARGET, blend_w=64)
    out4.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    print("   -> Saved Rice_Field_Layer4.png")
    
    # Layer 3: Terraced Hills
    print("2. Layer 3 (Emerald Terraced Hills)...")
    raw3 = Image.open(os.path.join(BRAIN_DIR, "rice_terraces_hills_layer3_1791096044337.jpg"))
    clean3 = clean_black_sky_perfect(raw3)
    out3 = tile_3_and_blend_seamless(clean3, W_TARGET, H_TARGET, blend_w=64)
    out3.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    print("   -> Saved Rice_Field_Layer3.png")
    
    # Layer 2: Midground Rice Paddies & Water Pools
    print("3. Layer 2 (Midground Paddies)...")
    raw2 = Image.open(os.path.join(BRAIN_DIR, "rice_field_midground_layer2_1791096004300.jpg"))
    clean2 = clean_black_sky_perfect(raw2)
    out2 = tile_3_and_blend_seamless(clean2, W_TARGET, H_TARGET, blend_w=64)
    out2.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    print("   -> Saved Rice_Field_Layer2.png")
    
    # Layer 1: Foreground Village, Huts, Fences, Grass
    print("4. Layer 1 (Foreground Village & Huts)...")
    raw1 = Image.open(os.path.join(BRAIN_DIR, ".user_uploaded", "media_1791102244648.png")).convert("RGBA")
    w1, h1 = raw1.size # 1024 x 359
    arr1 = np.array(raw1)
    
    # Exact flush bottom alignment:
    # 720 - 359 = 361
    y_offset = H_TARGET - h1 # 361
    
    tile1 = np.zeros((H_TARGET, w1, 4), dtype=np.uint8)
    tile1[y_offset:y_offset + h1, :] = arr1
    tile1_im = Image.fromarray(tile1)
    
    # Tile across 4256 width with 48px cosine blend on fences
    arr_tile1 = np.array(tile1_im, dtype=np.float32)
    blend_w = 48
    effective_w = w1 - blend_w
    num_tiles = int(math.ceil(float(W_TARGET + blend_w) / effective_w)) + 1
    
    strips = [arr_tile1.copy() for _ in range(num_tiles)]
    res1 = strips[0]
    t1 = (0.5 - 0.5 * np.cos(np.linspace(0, np.pi, blend_w))).reshape(1, blend_w, 1)
    
    for next_strip in strips[1:]:
        H_c, W_c, _ = res1.shape
        out = np.zeros((H_c, W_c + w1 - blend_w, 4), dtype=np.float32)
        out[:, :W_c - blend_w] = res1[:, :W_c - blend_w]
        
        ol_left = res1[:, W_c - blend_w:]
        ol_right = next_strip[:, :blend_w]
        
        a_left = ol_left[:, :, 3:4]
        a_right = ol_right[:, :, 3:4]
        comb_a = np.maximum(a_left, a_right)
        
        both = (a_left > 10) & (a_right > 10)
        l_only = (a_left > 10) & (a_right <= 10)
        r_only = (a_right > 10) & (a_left <= 10)
        
        blended_rgb = np.zeros((H_c, blend_w, 3), dtype=np.float32)
        blended_rgb[l_only[:, :, 0]] = ol_left[:, :, :3][l_only[:, :, 0]]
        blended_rgb[r_only[:, :, 0]] = ol_right[:, :, :3][r_only[:, :, 0]]
        blended_rgb[both[:, :, 0]] = (ol_left[:, :, :3] * (1.0 - t1) + ol_right[:, :, :3] * t1)[both[:, :, 0]]
        
        blended = np.zeros((H_c, blend_w, 4), dtype=np.float32)
        blended[:, :, :3] = blended_rgb
        blended[:, :, 3:4] = comb_a
        
        out[:, W_c - blend_w:W_c] = blended
        out[:, W_c:] = next_strip[:, blend_w:]
        res1 = out
        if res1.shape[1] >= W_TARGET + blend_w:
            break
            
    final1 = res1[:, :W_TARGET].copy()
    over1 = res1[:, W_TARGET:W_TARGET + blend_w]
    
    a_l = final1[:, :blend_w, 3:4]
    a_o = over1[:, :, 3:4]
    comb_a = np.maximum(a_l, a_o)
    both = (a_l > 10) & (a_o > 10)
    l_only = (a_l > 10) & (a_o <= 10)
    o_only = (a_o > 10) & (a_l <= 10)
    
    rgb = np.zeros((H_TARGET, blend_w, 3), dtype=np.float32)
    rgb[l_only[:, :, 0]] = final1[:, :blend_w, :3][l_only[:, :, 0]]
    rgb[o_only[:, :, 0]] = over1[:, :, :3][o_only[:, :, 0]]
    rgb[both[:, :, 0]] = (final1[:, :blend_w, :3] * (1.0 - t1) + over1[:, :, :3] * t1)[both[:, :, 0]]
    
    final1[:, :blend_w, :3] = rgb
    final1[:, :blend_w, 3:4] = comb_a
    final1[:, -1] = final1[:, 0]
    
    zero_mask = final1[:, :, 3] < 2.0
    final1[zero_mask] = 0
    out1 = Image.fromarray(np.clip(final1, 0, 255).astype(np.uint8))
    out1.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))
    print("   -> Saved Rice_Field_Layer1.png")
    print("All layers generated successfully!")

if __name__ == "__main__":
    build_all_rice_field_layers()

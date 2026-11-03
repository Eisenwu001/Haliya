import os
import math
import numpy as np
from PIL import Image, ImageFilter

def recolor_layer_1(src_path="assets/bicol_bg/Rice_Field_Layer1.png"):
    img = Image.open(src_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    h, w, _ = arr.shape
    
    alpha = arr[:, :, 3]
    mask = alpha > 10
    
    # Calculate luminance from original RGB
    r_orig, g_orig, b_orig = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    lum = 0.299 * r_orig + 0.587 * g_orig + 0.114 * b_orig
    # Normalize lum to 0..1 based on layer's min and max
    lum_norm = np.clip((lum - 15.0) / 130.0, 0.0, 1.0)
    
    # Define hut regions (bounding boxes with soft feathering)
    # Hut 1: x in [180, 680], y in [350, 680]
    # Hut 2: x in [860, 1260], y in [380, 680]
    # Fences: x in [0, 175], y in [520, 680] and x in [1960, 2172], y in [540, 680]
    
    x_grid = np.arange(w)[None, :]
    y_grid = np.arange(h)[:, None]
    
    # Hut 1 mask
    hut1_mask = (x_grid >= 190) & (x_grid <= 665) & (y_grid >= 360) & (y_grid <= 660) & mask
    # Hut 2 mask
    hut2_mask = (x_grid >= 880) & (x_grid <= 1250) & (y_grid >= 385) & (y_grid <= 660) & mask
    # Fence mask
    fence_mask = (
        ((x_grid <= 170) & (y_grid >= 530) & (y_grid <= 665)) |
        ((x_grid >= 1970) & (y_grid >= 540) & (y_grid <= 665))
    ) & mask
    
    # 1. Foliage Colors (Lush Philippine Rainforest Emerald):
    # Shadow: [14, 38, 26] -> Mid: [28, 86, 54] -> Highlight: [52, 138, 86]
    foliage_r = 12.0 + lum_norm * 44.0
    foliage_g = 34.0 + lum_norm * 110.0
    foliage_b = 22.0 + lum_norm * 66.0
    
    # 2. Thatch & Bamboo (Warm golden-umber nipa thatch):
    # Shadow: [38, 26, 16] -> Mid: [105, 80, 48] -> Highlight: [168, 132, 82]
    wood_r = 34.0 + lum_norm * 135.0
    wood_g = 25.0 + lum_norm * 105.0
    wood_b = 16.0 + lum_norm * 66.0
    
    # 3. Weathered Fence (Dark tropical timber):
    # Shadow: [28, 20, 15] -> Highlight: [88, 68, 50]
    fence_r = 25.0 + lum_norm * 65.0
    fence_g = 18.0 + lum_norm * 48.0
    fence_b = 14.0 + lum_norm * 36.0
    
    # Combine layers
    out_r = foliage_r.copy()
    out_g = foliage_g.copy()
    out_b = foliage_b.copy()
    
    # Apply huts
    hut_any = hut1_mask | hut2_mask
    out_r[hut_any] = wood_r[hut_any]
    out_g[hut_any] = wood_g[hut_any]
    out_b[hut_any] = wood_b[hut_any]
    
    # Apply fences
    out_r[fence_mask] = fence_r[fence_mask]
    out_g[fence_mask] = fence_g[fence_mask]
    out_b[fence_mask] = fence_b[fence_mask]
    
    # Ground darkness (subtle gradient towards the very bottom ground soil)
    ground_y = np.clip((y_grid - 620.0) / 100.0, 0.0, 1.0)
    out_r = out_r * (1.0 - ground_y * 0.35)
    out_g = out_g * (1.0 - ground_y * 0.35)
    out_b = out_b * (1.0 - ground_y * 0.35)
    
    result = np.zeros_like(arr, dtype=np.uint8)
    result[mask, 0] = np.clip(out_r[mask], 0, 255).astype(np.uint8)
    result[mask, 1] = np.clip(out_g[mask], 0, 255).astype(np.uint8)
    result[mask, 2] = np.clip(out_b[mask], 0, 255).astype(np.uint8)
    result[mask, 3] = alpha[mask].astype(np.uint8)
    
    return Image.fromarray(result, mode="RGBA")


def recolor_layer_2(src_path="assets/bicol_bg/Rice_Field_Layer2.png"):
    img = Image.open(src_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    h, w, _ = arr.shape
    
    alpha = arr[:, :, 3]
    mask = alpha > 10
    
    r_orig, g_orig, b_orig = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    lum = 0.299 * r_orig + 0.587 * g_orig + 0.114 * b_orig
    lum_norm = np.clip((lum - 5.0) / 240.0, 0.0, 1.0)
    
    y_grid = np.arange(h)[:, None]
    
    # Layer 2 has background hills (y < 350) and rice terraces (y >= 350)
    # Background hills: misty jade green fading into distance
    # Terrace paddies: vibrant emerald rice seedlings & water reflection
    hill_factor = np.clip(1.0 - (y_grid - 180.0) / 200.0, 0.0, 1.0) # 1 at top hills, 0 at lower terraces
    
    # 1. Terrace Palette:
    # Deep shadow / dikes: [18, 45, 32]
    # Mid emerald rice: [38, 108, 68]
    # Bright water reflection: [55, 138, 115]
    terrace_r = 18.0 + lum_norm * 45.0 + lum_norm**2 * 8.0
    terrace_g = 42.0 + lum_norm * 92.0 + lum_norm**2 * 15.0
    terrace_b = 30.0 + lum_norm * 70.0 + lum_norm**2 * 25.0
    
    # 2. Hill Palette (More atmospheric blue-teal haze):
    # Deep shadow: [24, 52, 54]
    # Mid hill: [42, 88, 82]
    # Misty ridge: [68, 125, 112]
    hill_r = 22.0 + lum_norm * 52.0
    hill_g = 48.0 + lum_norm * 82.0
    hill_b = 48.0 + lum_norm * 75.0
    
    out_r = terrace_r * (1.0 - hill_factor * 0.7) + hill_r * (hill_factor * 0.7)
    out_g = terrace_g * (1.0 - hill_factor * 0.7) + hill_g * (hill_factor * 0.7)
    out_b = terrace_b * (1.0 - hill_factor * 0.7) + hill_b * (hill_factor * 0.7)
    
    # Ground blend at bottom
    ground_y = np.clip((y_grid - 600.0) / 120.0, 0.0, 1.0)
    out_r = out_r * (1.0 - ground_y * 0.3)
    out_g = out_g * (1.0 - ground_y * 0.3)
    out_b = out_b * (1.0 - ground_y * 0.3)
    
    result = np.zeros_like(arr, dtype=np.uint8)
    result[mask, 0] = np.clip(out_r[mask], 0, 255).astype(np.uint8)
    result[mask, 1] = np.clip(out_g[mask], 0, 255).astype(np.uint8)
    result[mask, 2] = np.clip(out_b[mask], 0, 255).astype(np.uint8)
    result[mask, 3] = alpha[mask].astype(np.uint8)
    
    return Image.fromarray(result, mode="RGBA")


def recolor_layer_3(src_path="assets/bicol_bg/Rice_Field_Layer3.png"):
    img = Image.open(src_path).convert("RGBA")
    arr = np.array(img, dtype=np.float32)
    h, w, _ = arr.shape
    
    alpha = arr[:, :, 3]
    mask = alpha > 10
    
    r_orig, g_orig, b_orig = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    lum = 0.299 * r_orig + 0.587 * g_orig + 0.114 * b_orig
    lum_norm = np.clip((lum - 10.0) / 235.0, 0.0, 1.0)
    
    # Layer 3 is the distant misty terraces:
    # Deep silhouettes: [22, 50, 52]
    # Mid terraces: [45, 92, 88]
    # High mist / fog: [78, 130, 125]
    out_r = 20.0 + lum_norm * 62.0
    out_g = 46.0 + lum_norm * 88.0
    out_b = 48.0 + lum_norm * 82.0
    
    result = np.zeros_like(arr, dtype=np.uint8)
    result[mask, 0] = np.clip(out_r[mask], 0, 255).astype(np.uint8)
    result[mask, 1] = np.clip(out_g[mask], 0, 255).astype(np.uint8)
    result[mask, 2] = np.clip(out_b[mask], 0, 255).astype(np.uint8)
    result[mask, 3] = alpha[mask].astype(np.uint8)
    
    return Image.fromarray(result, mode="RGBA")

def preview_all():
    l1 = recolor_layer_1()
    l2 = recolor_layer_2()
    l3 = recolor_layer_3()
    l4 = Image.open("assets/bicol_bg/Rice_Field_Layer4.png").convert("RGBA")
    
    # Save recolored layers to scratch for preview
    l1.thumbnail((540, 180))
    l1.save("scratch/recolor_l1_thumb.png")
    l2.thumbnail((540, 180))
    l2.save("scratch/recolor_l2_thumb.png")
    l3.thumbnail((540, 180))
    l3.save("scratch/recolor_l3_thumb.png")
    
    # Create composite with twilight sky
    w, h = 2160, 720
    # Twilight sky gradient: deep indigo at top (#0d1527) to teal-slate at horizon (#1a2c3a)
    y_arr = np.linspace(0, 1, h)[:, None]
    sky_r = 13.0 * (1 - y_arr) + 28.0 * y_arr
    sky_g = 21.0 * (1 - y_arr) + 45.0 * y_arr
    sky_b = 39.0 * (1 - y_arr) + 62.0 * y_arr
    sky_rgb = np.dstack([sky_r, sky_g, sky_b]).astype(np.uint8)
    sky_img = Image.fromarray(np.repeat(sky_rgb, w, axis=1), mode="RGB").convert("RGBA")
    
    # Composite L4, L3, L2, L1 over sky
    comp = sky_img
    # Resize L3, L2, L1 to 2160x720 if slightly off
    l4_resized = l4.resize((w, h))
    l3_resized = recolor_layer_3().resize((w, h))
    l2_resized = recolor_layer_2().resize((w, h))
    l1_resized = recolor_layer_1().resize((w, h))
    
    comp = Image.alpha_composite(comp, l4_resized)
    comp = Image.alpha_composite(comp, l3_resized)
    comp = Image.alpha_composite(comp, l2_resized)
    comp = Image.alpha_composite(comp, l1_resized)
    
    comp_thumb = comp.copy()
    comp_thumb.thumbnail((720, 240))
    comp_thumb.save("scratch/full_scene_preview.png")
    print("Full scene preview generated at scratch/full_scene_preview.png")

if __name__ == "__main__":
    preview_all()

import os, cv2
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance

RAW_DIR = "C:/Users/Lin/.gemini/antigravity/brain/feb5818d-94e6-427e-b0af-0b238400ce42/.user_uploaded/"
OUT_DIR = "assets/bicol_bg/"
os.makedirs(OUT_DIR, exist_ok=True)

W_TARGET = 1024
H_TARGET = 360

def perfect_symmetric_seamless(img, B=40):
    arr = np.array(img).astype(float)
    H, W, C = arr.shape
    
    t = np.linspace(0, 1, B)
    w = (3 * t**2 - 2 * t**3).reshape(1, B, 1) # 0 at edge, 1 at interior
    
    # Left strip (0 .. B)
    nat_L = arr[:, :B].copy()
    # Right strip (W-1 .. W-B, reversed so k=0 is W-1)
    nat_R = arr[:, :-B-1:-1].copy()
    
    shared = 0.5 * (nat_L + nat_R)
    
    new_L = shared * (1.0 - w) + nat_L * w
    new_R = shared * (1.0 - w) + nat_R * w
    
    arr[:, :B] = new_L
    arr[:, :-B-1:-1] = new_R
    
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))

def sharpen_layer(img_rgba, radius=1.2, percent=185, sharpness=1.25, contrast=1.06):
    arr = np.array(img_rgba)
    alpha = arr[:, :, 3]
    rgb_img = Image.fromarray(arr[:, :, :3])
    
    # Apply UnsharpMask and crispness enhancements
    sh = rgb_img.filter(ImageFilter.UnsharpMask(radius=radius, percent=percent, threshold=1))
    sh = ImageEnhance.Sharpness(sh).enhance(sharpness)
    if contrast != 1.0:
        sh = ImageEnhance.Contrast(sh).enhance(contrast)
        
    sh_arr = np.array(sh)
    result_arr = np.dstack([sh_arr, alpha])
    return Image.fromarray(result_arr)

# =========================================================================
# LAYER 4: Mount Mayon Volcano with Integrated Golden Sunrise Sky
# =========================================================================
def process_layer_4():
    print("--- Processing Layer 4: Mount Mayon Volcano & Sky ---")
    p = os.path.join(RAW_DIR, "media_1792846446695_992912fa.png")
    raw = Image.open(p).convert("RGBA")
    arr = np.array(raw)
    
    rgb = arr[:, :, :3].astype(float)
    max_rgb = rgb.max(axis=2)
    alpha = np.ones((raw.height, raw.width), dtype=float) * 255.0
    
    # 1. Zero out black background (any pixel with max_rgb <= 15)
    bg_mask = (max_rgb <= 15)
    alpha[bg_mask] = 0.0
    
    # 2. Remove disconnected floating artifacts (like the 156px island on the left)
    num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats((alpha > 50).astype(np.uint8), connectivity=8)
    for i in range(1, num_labels):
        if stats[i, cv2.CC_STAT_AREA] < 1000:
            alpha[labels == i] = 0.0
            
    # 3. De-fringe border pixels anti-aliased with black: bleed color from mountain interior
    kernel = np.ones((3, 3), np.uint8)
    dilated = cv2.dilate((alpha == 0).astype(np.uint8), kernel, iterations=2)
    fringe = (dilated == 1) & (alpha > 0)
    ys, xs = np.where(fringe)
    for y, x in zip(ys, xs):
        sample_y = min(y + 4, 278)
        if alpha[sample_y, x] > 200:
            rgb[y, x] = rgb[sample_y, x]
            
    # 4. Extend bottom content down past row 278 to row 352
    for x in range(raw.width):
        col_ys = np.where(alpha[:279, x] > 200)[0]
        if len(col_ys) > 0:
            last_y = col_ys.max()
            last_col = rgb[last_y, x]
            rgb[last_y:352, x] = last_col
            alpha[last_y:352, x] = 255.0

    # 5. Create warm sunrise sky gradient matching Mount Mayon's amber lighting
    sky_arr = np.zeros((352, 1024, 3), dtype=float)
    for y in range(352):
        frac = min(1.0, y / 230.0)
        c_top = np.array([238.0, 175.0, 125.0])
        c_mid = np.array([250.0, 210.0, 155.0])
        c_bot = np.array([254.0, 236.0, 192.0])
        if frac < 0.5:
            t = frac * 2.0
            c = c_top * (1.0 - t) + c_mid * t
        else:
            t = (frac - 0.5) * 2.0
            c = c_mid * (1.0 - t) + c_bot * t
        sky_arr[y, :] = c

    # Add soft painted morning clouds in the sky
    cloud_noise = cv2.GaussianBlur(np.random.normal(0, 1, (352, 1024)), (51, 15), 0)
    cloud_mask = np.clip((cloud_noise - 0.2) * 1.5, 0.0, 1.0)
    for y in range(352):
        fade = np.exp(-((y - 70) / 45.0) ** 2)
        sky_arr[y] = sky_arr[y] * (1.0 - cloud_mask[y:y+1].T * fade * 0.35) + np.array([255.0, 245.0, 225.0]) * (cloud_mask[y:y+1].T * fade * 0.35)

    # Composite Mayon volcano over the sky
    alpha_norm = (alpha / 255.0)[:, :, np.newaxis]
    comp_rgb = rgb * alpha_norm + sky_arr * (1.0 - alpha_norm)
    comp_alpha = np.ones((352, 1024, 1), dtype=float) * 255.0 # Full opaque background
    
    comp = np.dstack([comp_rgb, comp_alpha])
    img4 = Image.fromarray(np.clip(comp, 0, 255).astype(np.uint8))
    img4 = img4.resize((W_TARGET, H_TARGET), Image.Resampling.LANCZOS)
    img4 = sharpen_layer(img4, radius=1.2, percent=185, sharpness=1.25, contrast=1.06)
    img4 = perfect_symmetric_seamless(img4, B=32)
    return img4

# =========================================================================
# LAYER 3: Distant Mountain Range & Foothills
# =========================================================================
def process_layer_3():
    print("--- Processing Layer 3: Distant Mountains ---")
    p = os.path.join(RAW_DIR, "media_1792846446686_4b80700b.png")
    raw = Image.open(p).convert("RGBA")
    arr = np.array(raw).astype(float)
    
    rgb = arr[:, :, :3]
    alpha = arr[:, :, 3]
    
    # Extend content down from y=250 to 341
    for x in range(raw.width):
        col_ys = np.where(alpha[:250, x] > 200)[0]
        if len(col_ys) > 0:
            last_y = col_ys.max()
            last_col = rgb[last_y, x]
            rgb[last_y:341, x] = last_col
            alpha[last_y:341, x] = 255.0
            
    img3 = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    img3 = img3.resize((W_TARGET, H_TARGET), Image.Resampling.LANCZOS)
    img3 = sharpen_layer(img3, radius=1.1, percent=165, sharpness=1.2, contrast=1.04)
    img3 = perfect_symmetric_seamless(img3, B=32)
    return img3

# =========================================================================
# LAYER 2: Midground Rice Terraces & Coconut Groves
# =========================================================================
def process_layer_2():
    print("--- Processing Layer 2: Midground Rice Terraces ---")
    p = os.path.join(RAW_DIR, "media_1792846446702_caf620ff.png")
    raw = Image.open(p).convert("RGBA")
    arr = np.array(raw).astype(float)
    rgb = arr[:, :, :3]
    max_rgb = rgb.max(axis=2)
    alpha = np.ones((raw.height, raw.width), dtype=float) * 255.0
    
    # Zero out top black sky (anything <= 15 in rows 0..200)
    sky_mask = (max_rgb <= 15) & (np.arange(raw.height)[:, None] <= 200)
    alpha[sky_mask] = 0.0
    
    # De-fringe the top ridge
    kernel = np.ones((3, 3), np.uint8)
    dilated = cv2.dilate((alpha == 0).astype(np.uint8), kernel, iterations=2)
    fringe = (dilated == 1) & (alpha > 0)
    ys, xs = np.where(fringe)
    for y, x in zip(ys, xs):
        sample_y = min(y + 4, 280)
        if alpha[sample_y, x] > 200:
            rgb[y, x] = rgb[sample_y, x]
            
    # Zero out bottom black letterbox (rows 290..341) and extend content
    for x in range(raw.width):
        col_ys = np.where((alpha[:290, x] > 200) & (max_rgb[:290, x] > 25))[0]
        if len(col_ys) > 0:
            last_y = col_ys.max()
            last_col = rgb[last_y, x]
            rgb[last_y:341, x] = last_col
            alpha[last_y:341, x] = 255.0
            
    res = np.dstack([np.clip(rgb, 0, 255), alpha]).astype(np.uint8)
    img2 = Image.fromarray(res)
    img2 = img2.resize((W_TARGET, H_TARGET), Image.Resampling.LANCZOS)
    img2 = sharpen_layer(img2, radius=1.2, percent=195, sharpness=1.25, contrast=1.06)
    img2 = perfect_symmetric_seamless(img2, B=32)
    return img2

# =========================================================================
# LAYER 1: Foreground Flooded Rice Paddies & Dikes
# =========================================================================
def process_layer_1():
    print("--- Processing Layer 1: Foreground Paddies ---")
    p = os.path.join(RAW_DIR, "media_1792846446682_96c8ab6c.png")
    raw = Image.open(p).convert("RGBA")
    arr = np.array(raw).astype(float)
    rgb = arr[:, :, :3]
    alpha = arr[:, :, 3]
    
    # Extend bottom from row 300 to 341
    for x in range(raw.width):
        col_ys = np.where(alpha[:301, x] > 200)[0]
        if len(col_ys) > 0:
            last_y = col_ys.max()
            last_col = rgb[last_y, x]
            rgb[last_y:341, x] = last_col
            alpha[last_y:341, x] = 255.0
            
    res = np.dstack([np.clip(rgb, 0, 255), alpha]).astype(np.uint8)
    img1 = Image.fromarray(res)
    img1 = img1.resize((W_TARGET, H_TARGET), Image.Resampling.LANCZOS)
    img1 = sharpen_layer(img1, radius=1.2, percent=185, sharpness=1.2, contrast=1.05)
    img1 = perfect_symmetric_seamless(img1, B=32)
    return img1

if __name__ == "__main__":
    l4 = process_layer_4()
    l3 = process_layer_3()
    l2 = process_layer_2()
    l1 = process_layer_1()
    
    # Save to production assets/bicol_bg/
    l4.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    l3.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    l2.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    l1.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))
    
    # Create composite preview and double loop preview
    comp = Image.new("RGBA", (1024, 360), (0, 0, 0, 255))
    comp.alpha_composite(l4)
    comp.alpha_composite(l3)
    comp.alpha_composite(l2)
    comp.alpha_composite(l1)
    comp.save("scratch/crisp_composite_final.png")
    
    double_comp = Image.new("RGBA", (2048, 360))
    double_comp.paste(comp, (0, 0))
    double_comp.paste(comp, (1024, 0))
    double_comp.save("scratch/crisp_double_final.png")
    
    print("SUCCESS: Production assets written to assets/bicol_bg/ and previews generated!")

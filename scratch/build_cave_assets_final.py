import os
import numpy as np
from PIL import Image

def remove_black_bg(img: Image.Image, threshold: int = 15, smooth: int = 15) -> Image.Image:
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=np.float32)
    rgb_max = np.max(arr[:, :, :3], axis=2)
    
    # Smooth alpha transition
    alpha = np.clip((rgb_max - threshold) / float(smooth), 0.0, 1.0) * 255.0
    
    # For very low brightness, set color to 0 to prevent dark fringes
    low_mask = alpha < 255.0
    # Unmultiply slightly where semi-transparent to preserve glowing crystal rims
    for c in range(3):
        arr[:, :, c] = np.where(alpha > 0, np.clip(arr[:, :, c] * (255.0 / np.maximum(alpha, 10.0)), 0, 255), 0)
    
    arr[:, :, 3] = alpha
    return Image.fromarray(arr.astype(np.uint8), "RGBA")

def main():
    ceiling_src = r"C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\cavern_ceiling_raw_1792489065276.jpg"
    plat_src = r"C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\platforms_and_stalactites_raw_1792489085961.jpg"
    
    out_dir = r"assets\cave_platformer"
    os.makedirs(out_dir, exist_ok=True)
    
    # ── 1. Process Cavern Ceiling ──────────────────────────────────────────
    c_img = Image.open(ceiling_src)
    c_rgba = remove_black_bg(c_img, threshold=12, smooth=12)
    
    # Crop to non-empty region
    bbox = c_rgba.getbbox()
    print("Ceiling bbox:", bbox)
    c_cropped = c_rgba.crop((0, 0, c_rgba.width, bbox[3] + 4))
    
    # Target scale: level width is 5120, viewport height 360.
    # Ceiling should be around 88 to 96 px tall.
    # Original is ~520px tall. Ratio ~ 520 / 92 = ~5.65.
    target_h = 96
    target_w = int(c_cropped.width * (target_h / c_cropped.height))
    c_scaled = c_cropped.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    # Make horizontally tileable by blending edges
    tile_w = target_w
    c_arr = np.array(c_scaled)
    blend_w = 24
    for i in range(blend_w):
        factor = i / float(blend_w)
        c_arr[:, -blend_w + i, :] = (c_arr[:, -blend_w + i, :] * (1 - factor) + c_arr[:, i, :] * factor).astype(np.uint8)
    
    c_seamless = Image.fromarray(c_arr, "RGBA")
    c_seamless.save(os.path.join(out_dir, "cavern_ceiling_modular.png"))
    print("Saved cavern_ceiling_modular.png:", c_seamless.size)
    
    # ── 2. Process Platforms & Resonant Stalactites ───────────────────────
    p_img = Image.open(plat_src)
    p_rgba = remove_black_bg(p_img, threshold=12, smooth=10)
    
    # Extract Stalactites (Top row)
    # Stalactite 1 (top left): x=54, y=43, w=182, h=256
    # Stalactite 2 (top middle): x=270, y=43, w=183, h=287
    # Stalactite 3 (top right): x=484, y=43, w=178, h=233
    stala_boxes = [
        (48, 38, 240, 305),
        (265, 38, 458, 335),
        (480, 38, 668, 280)
    ]
    
    for idx, box in enumerate(stala_boxes):
        s_crop = p_rgba.crop(box)
        # Scale to game scale: height around 90-100px, width around 48-60px
        sh = 96
        sw = int(s_crop.width * (sh / s_crop.height))
        s_scaled = s_crop.resize((sw, sh), Image.Resampling.LANCZOS)
        s_path = os.path.join(out_dir, f"pogo_stalactite_{idx+1}.png")
        s_scaled.save(s_path)
        print(f"Saved {s_path}:", s_scaled.size)
    
    # Default pogo stalactite (Stalactite 2 is the most prominent and pointed)
    s2 = Image.open(os.path.join(out_dir, "pogo_stalactite_2.png"))
    s2.save(os.path.join(out_dir, "pogo_stalactite_resonant.png"))
    
    # Extract Platforms:
    # 1. Wide mossy rock ledge (bottom left): (38, 330, 690, 725)
    plat_moss = p_rgba.crop((38, 330, 690, 725))
    # Target scale: around 160-192px wide, ~60-70px tall
    pm_w = 192
    pm_h = int(plat_moss.height * (pm_w / plat_moss.width))
    plat_moss_scaled = plat_moss.resize((pm_w, pm_h), Image.Resampling.LANCZOS)
    plat_moss_scaled.save(os.path.join(out_dir, "plat_mossy_ledge.png"))
    print("Saved plat_mossy_ledge.png:", plat_moss_scaled.size)
    
    # 2. Hexagonal basalt column (middle): (750, 160, 980, 645)
    plat_col = p_rgba.crop((750, 160, 980, 645))
    # Target scale: around 72px wide, 144px tall
    pc_w = 72
    pc_h = int(plat_col.height * (pc_w / plat_col.width))
    plat_col_scaled = plat_col.resize((pc_w, pc_h), Image.Resampling.LANCZOS)
    plat_col_scaled.save(os.path.join(out_dir, "plat_basalt_column.png"))
    print("Saved plat_basalt_column.png:", plat_col_scaled.size)
    
    # 3. Ancient runic moon platform (right): (1025, 270, 1340, 540)
    plat_runic = p_rgba.crop((1025, 270, 1340, 540))
    # Target scale: around 128px wide, 64px tall
    pr_w = 128
    pr_h = int(plat_runic.height * (pr_w / plat_runic.width))
    plat_runic_scaled = plat_runic.resize((pr_w, pr_h), Image.Resampling.LANCZOS)
    plat_runic_scaled.save(os.path.join(out_dir, "plat_runic_altar.png"))
    print("Saved plat_runic_altar.png:", plat_runic_scaled.size)

if __name__ == "__main__":
    main()

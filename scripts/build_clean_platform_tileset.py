import os
import cv2
import numpy as np
from PIL import Image

def generate_cave_platform(
    source_img: Image.Image,
    crop_box: tuple,
    target_w: int,
    target_h: int,
    plat_type: str = "island",
    moss_color: tuple = (135, 235, 248)
) -> Image.Image:
    """
    Sculpts an authentic subterranean karst cave platform:
    - 100% solid walkable rock surface at y=0..3 across the full width.
    - Top edge perfectly flush at y=0 with glowing mineral/cyan moss highlights.
    - Naturally contoured rock underbelly with sharp hanging stalactite teeth.
    - Zero wooden/bamboo or geometric artifacts: 100% pure subterranean limestone/basalt.
    """
    raw = source_img.crop(crop_box).convert("RGBA")
    arr = np.array(raw, dtype=float)
    rgb = arr[:, :, :3]
    gray = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    # Calculate background threshold
    border_pixels = np.concatenate([rgb[0, :, :], rgb[-1, :, :], rgb[:, 0, :], rgb[:, -1, :]], axis=0)
    bg_rgb = np.median(border_pixels, axis=0)
    dist = np.linalg.norm(rgb - bg_rgb, axis=2)
    
    fg_mask = (dist > 16.0) | (gray > 28.0)
    mask_u8 = (fg_mask * 255).astype(np.uint8)
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    mask_clean = cv2.morphologyEx(mask_u8, cv2.MORPH_CLOSE, kernel)
    arr[:, :, 3] = mask_clean
    masked = Image.fromarray(arr.astype(np.uint8))
    
    a_arr = np.array(masked)[:, :, 3]
    rows = np.where(a_arr.max(axis=1) > 40)[0]
    cols = np.where(a_arr.max(axis=0) > 40)[0]
    tight = masked.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1)) if (len(rows) > 0 and len(cols) > 0) else masked
    
    tw, th = target_w, target_h
    cw, ch = tight.size
    
    scaled_h = min(th, max(int(round(ch * (tw / cw))), int(th * 0.75)))
    scaled = tight.resize((tw, scaled_h), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    canvas.paste(scaled, (0, 0), scaled)
    c_arr = np.array(canvas)
    
    is_crumble = (plat_type == "crumble")
    
    # 1. Sculpt organic rock underside profile with hanging stalactites
    for x in range(tw):
        norm_x = (x - tw * 0.5) / (tw * 0.5) # -1.0 to 1.0
        
        if plat_type == "island_lg":
            # Natural karst shelf with multiple jagged stalactite teeth hanging below
            teeth = 0.18 * np.sin(x * 0.38) + 0.12 * np.cos(x * 0.75)
            max_depth = int(th * (0.86 - 0.22 * (norm_x ** 2) + teeth))
        elif plat_type == "sanctuary":
            # Broad sacred terrace: massive bedrock plateau with sculpted bedrock flanks
            teeth = 0.10 * np.sin(x * 0.28)
            max_depth = int(th * (0.92 - 0.20 * (norm_x ** 4) + teeth))
        elif plat_type == "island_md":
            # Stepping stone: central dripstone stalactite keel
            teeth = 0.20 * np.sin(x * 0.55)
            max_depth = int(th * (0.84 - 0.32 * (norm_x ** 2) + teeth))
        elif plat_type == "bridge":
            # Natural stone arch span (Tulay na Bato): rock bridge with stalactite points at ends
            arch = 0.22 * (1.0 - norm_x ** 2) # Arch curves upward in middle
            teeth = 0.14 * np.sin(x * 0.45)
            max_depth = int(th * (0.82 - arch + teeth))
        elif is_crumble:
            # Brittle fractured shelf: jagged stepped breakoffs
            break_step = (x // 20) % 3
            teeth = 0.15 * np.sin(x * 0.65)
            max_depth = int(th * (0.76 - 0.25 * (norm_x ** 2) - break_step * 0.10 + teeth))
        else:
            max_depth = th
            
        max_depth = max(min(max_depth, th), 14)
        c_arr[max_depth:th, x, 3] = 0
        
        # Ensure pixels from y=0 down to min(max_depth, 16) are 100% solid
        first_y = 0
        while first_y < max_depth and c_arr[first_y, x, 3] < 120:
            first_y += 1
        if 0 < first_y < max_depth:
            fill_col = c_arr[first_y, x].copy()
            fill_col[3] = 255
            for fy in range(first_y):
                c_arr[fy, x] = fill_col
        elif first_y >= max_depth:
            c_arr[0:max_depth, x] = c_arr[0:max_depth, max(0, x - 1)] if x > 0 else [45, 60, 75, 255]
            
        # Guarantee 100% solid alpha for walkable surface y=0..3
        for wy in range(min(4, max_depth)):
            c_arr[wy, x, 3] = 255
            
    # 2. Add high-contrast cave mineral highlight rim (y=0..2)
    for x in range(tw):
        if is_crumble:
            is_crack = (x % 16 in [0, 1])
            if is_crack:
                for cy in range(min(16, th)):
                    if c_arr[cy, x, 3] > 0:
                        c_arr[cy, x, :3] = [20, 25, 32]
            else:
                c_arr[0, x, :3] = [225, 235, 245]
                c_arr[1, x, :3] = [180, 195, 208]
                c_arr[2, x, :3] = [130, 145, 160]
        else:
            # Bioluminescent karst rim with natural stone texture
            c_arr[0, x, :3] = [moss_color[0], moss_color[1], moss_color[2]]
            c_arr[1, x, :3] = [int(moss_color[0] * 0.78), int(moss_color[1] * 0.85), int(moss_color[2] * 0.90)]
            c_arr[2, x, :3] = [int(moss_color[0] * 0.55), int(moss_color[1] * 0.65), int(moss_color[2] * 0.70)]
            
    # 3. Clean dark pixel boundary outline around side and bottom edges
    alpha = c_arr[:, :, 3]
    edge_mask = cv2.Canny(alpha, 100, 200)
    for y in range(th):
        for x in range(tw):
            if edge_mask[y, x] > 0 and alpha[y, x] > 50:
                if y > 2: # Keep top rim luminous
                    c_arr[y, x, :3] = (c_arr[y, x, :3].astype(float) * 0.52).astype(np.uint8)
                    
    return Image.fromarray(c_arr)

def build_perfect_cave_platforms():
    sheet_path = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg"
    master = Image.open(sheet_path)
    
    # 384 x 256 Clean Layout
    sheet = Image.new("RGBA", (384, 256), (0, 0, 0, 0))
    
    # 1. island_lg: (0, 0, 160, 56) - Massive karst limestone shelf
    p_lg = generate_cave_platform(master, (929, 340, 929+202, 340+110), 160, 56, "island_lg", (135, 235, 248))
    sheet.paste(p_lg, (0, 0), p_lg)
    
    # 2. sanctuary: (160, 0, 192, 56) - Ancient pre-colonial cave altar plateau
    p_sanc = generate_cave_platform(master, (727, 340, 727+185, 340+110), 192, 56, "sanctuary", (150, 245, 225))
    sheet.paste(p_sanc, (160, 0), p_sanc)
    
    # 3. island_md: (0, 64, 112, 48) - Subterranean limestone stepping stone
    p_md = generate_cave_platform(master, (46, 341, 46+110, 341+73), 112, 48, "island_md", (125, 220, 240))
    sheet.paste(p_md, (0, 64), p_md)
    
    # 4. crumble: (112, 64, 112, 48) - Brittle chalky limestone fracture shelf
    p_crm = generate_cave_platform(master, (170, 342, 170+111, 342+72), 112, 48, "crumble")
    sheet.paste(p_crm, (112, 64), p_crm)
    
    # 5. bridge: (224, 64, 160, 44) - Tulay na Bato (Natural Karst Limestone Rock Span)
    p_brg = generate_cave_platform(master, (295, 341, 295+230, 341+80), 160, 44, "bridge", (140, 230, 245))
    sheet.paste(p_brg, (224, 64), p_brg)
    
    out_target = "assets/cave_platformer/cave_platforms.png"
    sheet.save(out_target)
    sheet.save("scratch/cave_platforms_perfect.png")
    print(f"Successfully generated pure cave platform spritesheet: {out_target} (384x256)")

if __name__ == "__main__":
    build_perfect_cave_platforms()

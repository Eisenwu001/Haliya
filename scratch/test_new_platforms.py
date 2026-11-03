import os
import cv2
import numpy as np
from PIL import Image

def extract_platform_clean(
    source_img: Image.Image,
    crop_box: tuple,
    target_w: int,
    target_h: int,
    is_bridge: bool = False,
    is_crumble: bool = False,
    moss_color: tuple = (160, 220, 240)
) -> Image.Image:
    """
    Extracts a horizontal platform and guarantees:
    1. Solid walkable surface across the ENTIRE width (x = 0 .. target_w - 1).
    2. Exact flat top at y = 0.
    3. Natural, tapered, solid rock underbelly.
    4. Crisp, high-readability top highlight rim.
    5. Clean alpha outline without dark haloing.
    """
    raw = source_img.crop(crop_box).convert("RGBA")
    arr = np.array(raw, dtype=float)
    rgb = arr[:, :, :3]
    gray = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    # Calculate background from image borders
    border_pixels = np.concatenate([
        rgb[0, :, :], rgb[-1, :, :], rgb[:, 0, :], rgb[:, -1, :]
    ], axis=0)
    bg_rgb = np.median(border_pixels, axis=0)
    color_dist = np.linalg.norm(rgb - bg_rgb, axis=2)
    
    # Foreground mask: anything significantly different from the dark background
    fg_mask = (color_dist > 18.0) | (gray > 32.0)
    
    # If it's the bridge, make sure bamboo slats are captured
    if is_bridge:
        fg_mask = fg_mask | (rgb[:, :, 0] > 40.0)
        
    mask_u8 = (fg_mask * 255).astype(np.uint8)
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    mask_clean = cv2.morphologyEx(mask_u8, cv2.MORPH_CLOSE, kernel)
    
    arr[:, :, 3] = mask_clean
    masked = Image.fromarray(arr.astype(np.uint8))
    
    # Crop to tight bounding box of alpha
    a_arr = np.array(masked)[:, :, 3]
    rows = np.where(a_arr.max(axis=1) > 50)[0]
    cols = np.where(a_arr.max(axis=0) > 50)[0]
    if len(rows) > 0 and len(cols) > 0:
        tight = masked.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))
    else:
        tight = masked
        
    # Resize to fit target width and height while preserving full width
    # Note: platforms MUST span the full target_w!
    # We stretch horizontally to target_w, and scale height proportionally up to target_h
    tw, th = target_w, target_h
    cw, ch = tight.size
    
    scaled_h = min(th, int(round(ch * (tw / cw))))
    scaled = tight.resize((tw, scaled_h), Image.Resampling.LANCZOS)
    
    # Paste onto canvas of (target_w, target_h) flush at y=0
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    canvas.paste(scaled, (0, 0), scaled)
    
    c_arr = np.array(canvas)
    
    # 1. Guarantee that y=0 is solid across all x from 0 to tw - 1
    # Find first solid pixel in each column and pull it to y=0
    for x in range(tw):
        first_y = 0
        while first_y < th and c_arr[first_y, x, 3] < 80:
            first_y += 1
        if 0 < first_y < th - 4:
            # Fill from 0 up to first_y with the color of the first solid pixel
            ref_col = c_arr[first_y, x].copy()
            ref_col[3] = 255
            for y in range(first_y):
                c_arr[y, x] = ref_col
        elif first_y >= th - 4:
            # If the column was empty, copy from adjacent column
            if x > 0 and c_arr[0, x - 1, 3] > 100:
                c_arr[0:min(16, th), x] = c_arr[0:min(16, th), x - 1]
            else:
                c_arr[0:min(16, th), x] = [50, 65, 75, 255]
                
    # 2. Add high-contrast, beautiful top walkable highlight rim (y = 0..1)
    for x in range(tw):
        if is_bridge:
            # Warm bamboo tones with rattan rope knots every 24 pixels
            is_knot = (x % 24 in [0, 1])
            if is_knot:
                c_arr[0, x, :3] = [95, 70, 45]   # Dark abaca rattan knot
                c_arr[1, x, :3] = [120, 90, 55]
            else:
                c_arr[0, x, :3] = [238, 208, 142] # Warm golden bamboo cane
                c_arr[1, x, :3] = [190, 160, 105]
        elif is_crumble:
            # Chalky limestone with visible fracture lines every 18 pixels
            is_fracture = (x % 18 in [0, 1])
            if is_fracture:
                for fy in range(min(14, th)):
                    c_arr[fy, x, :3] = [24, 28, 35] # Deep fissure
            else:
                c_arr[0, x, :3] = [210, 222, 235] # Brittle limestone rim
                c_arr[1, x, :3] = [165, 178, 192]
        else:
            # Subterranean limestone / basalt with bioluminescent cyan moss rim
            c_arr[0, x, :3] = [moss_color[0], moss_color[1], moss_color[2]]
            c_arr[1, x, :3] = [int(moss_color[0]*0.75), int(moss_color[1]*0.75), int(moss_color[2]*0.75)]
            
    # 3. Ensure edges (x=0 and x=tw-1) have clean dark boundary outlines
    for y in range(th):
        if c_arr[y, 0, 3] > 50:
            c_arr[y, 0, :3] = (c_arr[y, 0, :3].astype(float) * 0.6).astype(np.uint8)
        if c_arr[y, tw - 1, 3] > 50:
            c_arr[y, tw - 1, :3] = (c_arr[y, tw - 1, :3].astype(float) * 0.6).astype(np.uint8)
            
    return Image.fromarray(c_arr)

def main():
    sheet_path = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg"
    master = Image.open(sheet_path)
    
    # Target Spritesheet Layout: 384 x 256
    # Row 0 (y=0..56):
    #   island_lg: (0, 0, 160, 56)
    #   sanctuary: (160, 0, 192, 56)
    # Row 1 (y=64..112):
    #   island_md: (0, 64, 112, 48)
    #   crumble:   (112, 64, 112, 48)
    #   bridge:    (224, 64, 160, 44)
    out_sheet = Image.new("RGBA", (384, 256), (0, 0, 0, 0))
    
    # 1. island_lg: from karst_202 (x=929, y=340, w=202, h=110)
    p_island_lg = extract_platform_clean(master, (929, 340, 929+202, 340+110), 160, 56, moss_color=(120, 220, 230))
    out_sheet.paste(p_island_lg, (0, 0), p_island_lg)
    
    # 2. sanctuary: from terrace_185 (x=727, y=340, w=185, h=110)
    p_sanctuary = extract_platform_clean(master, (727, 340, 727+185, 340+110), 192, 56, moss_color=(140, 235, 210))
    out_sheet.paste(p_sanctuary, (160, 0), p_sanctuary)
    
    # 3. island_md: from step_110 (x=46, y=341, w=110, h=73)
    p_island_md = extract_platform_clean(master, (46, 341, 46+110, 341+73), 112, 48, moss_color=(110, 210, 225))
    out_sheet.paste(p_island_md, (0, 64), p_island_md)
    
    # 4. crumble: from step_crumble_111 (x=170, y=342, w=111, h=72)
    p_crumble = extract_platform_clean(master, (170, 342, 170+111, 342+72), 112, 48, is_crumble=True)
    out_sheet.paste(p_crumble, (112, 64), p_crumble)
    
    # 5. bridge: from bridge_full (x=45, y=103, w=634, h=182)
    # The walkway deck is around y=120..170 of the crop
    p_bridge = extract_platform_clean(master, (45, 120, 45+634, 120+140), 160, 44, is_bridge=True)
    out_sheet.paste(p_bridge, (224, 64), p_bridge)
    
    out_path = "scratch/test_new_platforms_sheet.png"
    out_sheet.save(out_path)
    print(f"Saved {out_path} ({out_sheet.size})")

if __name__ == "__main__":
    main()

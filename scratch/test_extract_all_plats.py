import cv2
import numpy as np
from PIL import Image

plat_raw = Image.open('C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/philippine_cave_platforms_spritesheet_1792544043909.jpg')

def extract_clean_plat(crop_box, target_w, target_h, top_offset_trim=0, left_offset_trim=0):
    c = plat_raw.crop(crop_box).convert("RGBA")
    arr = np.array(c)
    h, w = arr.shape[:2]
    
    # Background seed pixels in dark charcoal
    is_bg_seed = (arr[:, :, 0] < 28) & (arr[:, :, 1] < 28) & (arr[:, :, 2] < 32)
    
    mask = np.zeros((h + 2, w + 2), np.uint8)
    seed_img = (is_bg_seed * 255).astype(np.uint8)
    
    # Flood fill from all 4 borders
    for bx in range(w):
        if seed_img[0, bx] == 255 and mask[1, bx+1] == 0:
            cv2.floodFill(seed_img, mask, (bx, 0), 128)
        if seed_img[h-1, bx] == 255 and mask[h, bx+1] == 0:
            cv2.floodFill(seed_img, mask, (bx, h-1), 128)
    for by in range(h):
        if seed_img[by, 0] == 255 and mask[by+1, 1] == 0:
            cv2.floodFill(seed_img, mask, (0, by), 128)
        if seed_img[by, w-1] == 255 and mask[by+1, w] == 0:
            cv2.floodFill(seed_img, mask, (w-1, by), 128)
            
    bg_filled = (mask[1:h+1, 1:w+1] == 1)
    
    arr[:, :, 3] = 255
    arr[bg_filled, 3] = 0
    
    if top_offset_trim > 0:
        arr[:top_offset_trim, :, 3] = 0
    if left_offset_trim > 0:
        arr[:, :left_offset_trim, 3] = 0
        
    # Crop tight to foreground
    a = arr[:, :, 3]
    rows = np.where(a.max(axis=1) > 0)[0]
    cols = np.where(a.max(axis=0) > 0)[0]
    if len(rows) == 0 or len(cols) == 0:
        tight = Image.fromarray(arr)
    else:
        tight = Image.fromarray(arr).crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))
        
    tw, th = target_w, target_h
    cw, ch = tight.size
    scale = tw / float(cw)
    new_h = min(th, int(round(ch * scale)))
    scaled = tight.resize((tw, new_h), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    canvas.paste(scaled, (0, 0), scaled)
    
    # Ensure top row y=0..1 is 100% solid where platform exists for flush physics
    c_arr = np.array(canvas)
    for x in range(tw):
        ys = np.where(c_arr[:, x, 3] > 60)[0]
        if len(ys) > 0:
            top_y = ys[0]
            if 0 < top_y <= 6:
                col = c_arr[top_y, x].copy()
                for fy in range(0, top_y):
                    c_arr[fy, x] = col
                    c_arr[fy, x, 3] = 255
    return Image.fromarray(c_arr)

# Test the 5 platforms:
# 1. island_lg (160x56): Ledge 2 (wide karst shelf) x: 860..1080, y: 115..310
p_lg = extract_clean_plat((860, 115, 1080, 310), 160, 56)
p_lg.save('scratch/plat_test_island_lg.png')

# 2. sanctuary (192x56): Wide karst terrace x: 855..1085, y: 115..310
p_sanc = extract_clean_plat((855, 115, 1085, 310), 192, 56)
p_sanc.save('scratch/plat_test_sanctuary.png')

# 3. island_md (112x48): Ledge 4 (hanging rock with roots) x: 1218..1320, y: 120..310
p_md = extract_clean_plat((1218, 120, 1320, 310), 112, 48)
p_md.save('scratch/plat_test_island_md.png')

# 4. crumble (112x48): Shelf 3 (fractured shelf with falling debris) x: 282..515, y: 350..460
p_crm = extract_clean_plat((282, 350, 515, 460), 112, 48)
p_crm.save('scratch/plat_test_crumble.png')

# 5. bridge (160x44): Shelf 1 (solid stone shelf) x: 45..155, y: 350..450
p_brg = extract_clean_plat((45, 350, 155, 450), 160, 44)
p_brg.save('scratch/plat_test_bridge.png')

print("All 5 platforms extracted and saved to scratch/plat_test_*.png")

import cv2
import numpy as np
from PIL import Image

def extract_alpha(img_crop: Image.Image, bg_thresh: float = 24.0) -> Image.Image:
    """Extracts transparent alpha from dark charcoal background (#111111 ~ #17181c)."""
    rgba = img_crop.convert("RGBA")
    arr = np.array(rgba, dtype=float)
    rgb = arr[:, :, :3]
    gray = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    # Corners are dark background
    corners = np.array([rgb[0, 0], rgb[0, -1], rgb[-1, 0], rgb[-1, -1]])
    bg = np.median(corners, axis=0)
    dist = np.linalg.norm(rgb - bg, axis=2)
    
    # Foreground mask: pixels that deviate from background or have brightness
    fg = (dist > bg_thresh) | (gray > 32.0)
    mask_u8 = (fg * 255).astype(np.uint8)
    
    # Clean noise with morphological close
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    clean_mask = cv2.morphologyEx(mask_u8, cv2.MORPH_CLOSE, kernel)
    
    arr[:, :, 3] = clean_mask
    
    # Find bounding box of foreground
    rows = np.where(clean_mask.max(axis=1) > 0)[0]
    cols = np.where(clean_mask.max(axis=0) > 0)[0]
    if len(rows) > 0 and len(cols) > 0:
        tight = Image.fromarray(arr.astype(np.uint8)).crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))
        return tight
    return Image.fromarray(arr.astype(np.uint8))

def fit_to_box(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Fits the extracted platform into target_w x target_h, aligned flush to top."""
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    # Scale proportionally to target_w
    w, h = img.size
    scale = target_w / float(w)
    new_h = min(target_h, int(round(h * scale)))
    scaled = img.resize((target_w, new_h), Image.Resampling.LANCZOS)
    
    # Paste flush at y=0
    canvas.paste(scaled, (0, 0), scaled)
    
    # Ensure walkable surface at top (y=0..2) is 100% solid where platform exists
    c_arr = np.array(canvas)
    for x in range(target_w):
        # find first non-zero alpha
        ys = np.where(c_arr[:, x, 3] > 80)[0]
        if len(ys) > 0:
            top_y = ys[0]
            if 0 < top_y <= 6:
                # extend top up to y=0 to ensure flush walkable physics
                col = c_arr[top_y, x].copy()
                for fy in range(0, top_y):
                    c_arr[fy, x] = col
    return Image.fromarray(c_arr)

# Test extraction
sheet = Image.open('C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/philippine_cave_platforms_spritesheet_1792544043909.jpg')

# 1. island_lg: Ledge 2 (wide) x: 834..1080, y: 110..310
crop_lg = sheet.crop((834, 110, 1080, 310))
p_lg = fit_to_box(extract_alpha(crop_lg), 160, 56)
p_lg.save('scratch/test_plat_island_lg.png')

# 2. crumble: x: 280..510, y: 350..460
crop_crm = sheet.crop((280, 350, 510, 460))
p_crm = fit_to_box(extract_alpha(crop_crm), 112, 48)
p_crm.save('scratch/test_plat_crumble.png')

# 3. island_md: Ledge 4 (hanging rock with roots) x: 1220..1320, y: 115..310
crop_md = sheet.crop((1220, 115, 1320, 310))
p_md = fit_to_box(extract_alpha(crop_md), 112, 48)
p_md.save('scratch/test_plat_island_md.png')

# 4. bridge: shelf 1 (solid stone shelf) x: 45..155, y: 350..450
crop_brg = sheet.crop((45, 350, 155, 450))
p_brg = fit_to_box(extract_alpha(crop_brg), 160, 44)
p_brg.save('scratch/test_plat_bridge.png')

# 5. sanctuary: wide stone plateau combining karst rock
crop_sanc = sheet.crop((834, 110, 1080, 310))
p_sanc = fit_to_box(extract_alpha(crop_sanc), 192, 56)
p_sanc.save('scratch/test_plat_sanctuary.png')

print('Generated test platforms successfully!')

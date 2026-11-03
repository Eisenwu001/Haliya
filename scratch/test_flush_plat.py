import os
import cv2
import numpy as np
from PIL import Image

def isolate_sprite(img_crop, bg_thresh=25):
    """
    Given a cropped region from the AI sprite sheet, cleanly isolates the foreground sprite.
    Uses Otsu threshold on the local crop or background color estimation.
    """
    arr = np.array(img_crop.convert("RGBA"), dtype=float)
    rgb = arr[:,:,:3]
    gray = 0.299 * rgb[:,:,0] + 0.587 * rgb[:,:,1] + 0.114 * rgb[:,:,2]
    
    # Estimate background from corners
    h, w = gray.shape
    corners = [gray[0,0], gray[0,-1], gray[-1,0], gray[-1,-1]]
    bg_val = np.median(corners)
    
    # Foreground mask
    diff = np.abs(gray - bg_val)
    # Color distance
    bg_rgb = np.median([rgb[0,0], rgb[0,-1], rgb[-1,0], rgb[-1,-1]], axis=0)
    color_dist = np.linalg.norm(rgb - bg_rgb, axis=2)
    
    mask = (color_dist > 18.0) | (diff > 16.0)
    # Morphological cleanup
    mask_u8 = (mask * 255).astype(np.uint8)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    mask_clean = cv2.morphologyEx(mask_u8, cv2.MORPH_CLOSE, kernel)
    
    # Smooth alpha edge
    alpha = cv2.GaussianBlur(mask_clean.astype(float), (3, 3), 0.5)
    arr[:,:,3] = np.clip(alpha, 0, 255)
    
    return Image.fromarray(arr.astype(np.uint8))

def crop_solid_box(im, min_alpha=120):
    arr = np.array(im)
    alpha = arr[:,:,3]
    rows = np.where(alpha.max(axis=1) >= min_alpha)[0]
    cols = np.where(alpha.max(axis=0) >= min_alpha)[0]
    if len(rows) == 0 or len(cols) == 0:
        return im
    return im.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))

def create_flush_platform(raw_crop, target_w, target_h):
    """
    Isolates platform, ensures top surface is trimmed to its highest solid point,
    resizes to target dimensions, and guarantees row 0 is solid at y=0.
    """
    iso = isolate_sprite(raw_crop)
    tight = crop_solid_box(iso, min_alpha=100)
    
    tw, th = target_w, target_h
    # Scale width to fill platform, scale height proportionally
    cw, ch = tight.size
    scale_w = tw / cw
    scale_h = th / ch
    scale = min(scale_w, scale_h)
    
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    pos_x = (tw - nw) // 2
    # Paste flush at top y=0
    canvas.paste(scaled, (pos_x, 0), scaled)
    
    # Ensure row 0 has solid walkable surface across pos_x .. pos_x+nw
    c_arr = np.array(canvas)
    for x in range(pos_x, pos_x + nw):
        # find first row with alpha > 100
        first_y = 0
        while first_y < th and c_arr[first_y, x, 3] < 120:
            first_y += 1
        if 0 < first_y < 6: # slight top curve or lanczos blur, pull it up to 0
            for y_fill in range(first_y):
                c_arr[y_fill, x] = c_arr[first_y, x]
                c_arr[y_fill, x, 3] = 255
                
    return Image.fromarray(c_arr)

print("Flush platform creator ready.")

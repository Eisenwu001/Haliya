import os
import cv2
import numpy as np
from PIL import Image

def remove_dark_bg(img, bg_thresh=18, feather=1.5):
    """Cleanly removes dark background while preserving semi-translucent glow and anti-aliasing."""
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=float)
    rgb = arr[:,:,:3]
    brightness = 0.299 * rgb[:,:,0] + 0.587 * rgb[:,:,1] + 0.114 * rgb[:,:,2]
    
    # Smooth alpha ramp
    alpha = np.clip((brightness - bg_thresh) / (bg_thresh * feather) * 255.0, 0, 255)
    
    # For very bright or saturated pixels (like fire or pearls), ensure full opacity
    max_c = np.max(rgb, axis=2)
    min_c = np.min(rgb, axis=2)
    saturation = max_c - min_c
    boost = np.clip((saturation - 15.0) / 20.0 * 255.0, 0, 255)
    alpha = np.maximum(alpha, boost)
    
    arr[:,:,3] = alpha
    return Image.fromarray(arr.astype(np.uint8))

def crop_content(img, min_alpha=15):
    """Crops transparent borders around content."""
    arr = np.array(img)
    if arr.shape[2] < 4:
        return img
    alpha = arr[:,:,3]
    pts = np.where(alpha > min_alpha)
    if len(pts[0]) == 0 or len(pts[1]) == 0:
        return img
    y0, y1 = pts[0].min(), pts[0].max() + 1
    x0, x1 = pts[1].min(), pts[1].max() + 1
    return img.crop((x0, y0, x1, y1))

print("Helper functions defined successfully.")

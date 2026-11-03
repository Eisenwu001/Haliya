import os
import numpy as np
from PIL import Image
from scipy.ndimage import binary_fill_holes, binary_dilation

def solidify_sprite(img_rgba: Image.Image, black_thresh: int = 18) -> Image.Image:
    arr = np.array(img_rgba, dtype=np.uint8)
    rgb = arr[:, :, :3]
    orig_alpha = arr[:, :, 3]
    
    # 1. Identify non-black pixels
    max_c = np.max(rgb, axis=2)
    is_sprite = max_c > black_thresh
    
    # Also include any pixels that were already opaque
    is_sprite = np.logical_or(is_sprite, orig_alpha > 30)
    
    # 2. Fill all internal holes enclosed by the sprite body
    solid_mask = binary_fill_holes(is_sprite)
    
    # 3. Create clean alpha:
    # Interior pixels get 255 (completely solid)
    # Boundary pixels get smooth falloff
    dilated = binary_dilation(solid_mask)
    edge_pixels = np.logical_and(dilated, ~solid_mask)
    
    new_alpha = np.zeros_like(orig_alpha)
    new_alpha[solid_mask] = 255
    new_alpha[edge_pixels] = 140
    
    # For pixels that were previously filled holes (where rgb was 0,0,0),
    # fill with average dark stone/clay color so it doesn't leave black spots
    hole_pixels = np.logical_and(solid_mask, max_c <= black_thresh)
    if np.any(hole_pixels):
        # find mean color of surrounding sprite
        mean_r = int(np.mean(rgb[solid_mask, 0]))
        mean_g = int(np.mean(rgb[solid_mask, 1]))
        mean_b = int(np.mean(rgb[solid_mask, 2]))
        # Dark shadow tone: 40% of mean color
        arr[hole_pixels, 0] = max(18, int(mean_r * 0.45))
        arr[hole_pixels, 1] = max(16, int(mean_g * 0.45))
        arr[hole_pixels, 2] = max(24, int(mean_b * 0.45))
    
    arr[:, :, 3] = new_alpha
    return Image.fromarray(arr, 'RGBA')

print('solidify_sprite function defined successfully')

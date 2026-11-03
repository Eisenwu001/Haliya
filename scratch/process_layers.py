import numpy as np
from PIL import Image
from collections import deque

def extract_alpha_from_black(img_rgb, flood_threshold=25, fringe_threshold=55):
    """
    Flood fills from the top corners to find the background black region,
    then creates a smooth, defringed alpha mask preserving all internal dark details.
    """
    w, h = img_rgb.size
    arr = np.array(img_rgb).astype(np.float32)
    
    # Max channel for brightness check
    brightness = arr.max(axis=2)
    
    # Visited mask for flood fill
    bg_mask = np.zeros((h, w), dtype=bool)
    
    # Seeds: top row, left and right edges near top
    queue = deque()
    for x in range(w):
        if brightness[0, x] <= flood_threshold:
            bg_mask[0, x] = True
            queue.append((x, 0))
    for y in range(h // 2):
        if brightness[y, 0] <= flood_threshold and not bg_mask[y, 0]:
            bg_mask[y, 0] = True
            queue.append((0, y))
        if brightness[y, w - 1] <= flood_threshold and not bg_mask[y, w - 1]:
            bg_mask[y, w - 1] = True
            queue.append((w - 1, y))
            
    while queue:
        cx, cy = queue.popleft()
        for dx, dy in ((-1,0), (1,0), (0,-1), (0,1)):
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h:
                if not bg_mask[ny, nx] and brightness[ny, nx] <= flood_threshold:
                    bg_mask[ny, nx] = True
                    queue.append((nx, ny))
                    
    # Alpha mask: 0 where bg_mask is True, 255 where False
    alpha = np.ones((h, w), dtype=np.float32) * 255.0
    alpha[bg_mask] = 0.0
    
    # Defringe transition pixels directly neighboring bg_mask
    from scipy.ndimage import binary_dilation
    dilated_bg = binary_dilation(bg_mask, iterations=2)
    transition = dilated_bg & (~bg_mask)
    
    # For transition pixels with low brightness, scale alpha proportionally to brightness
    for y, x in zip(*np.where(transition)):
        b = brightness[y, x]
        if b < fringe_threshold:
            a_factor = max(0.0, (b - flood_threshold) / (fringe_threshold - flood_threshold))
            alpha[y, x] = 255.0 * a_factor
            
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[:, :, :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    
    return Image.fromarray(rgba, mode="RGBA")

def make_seamless_horizontal(img_rgba, blend_width=32):
    """
    Seamlessly blends the left and right edges so it tiles horizontally without any seam.
    """
    w, h = img_rgba.size
    arr = np.array(img_rgba).astype(np.float32)
    
    # Cross fade rightmost `blend_width` pixels with leftmost `blend_width` pixels
    for i in range(blend_width):
        t = (i + 1) / (blend_width + 1) # 0 to 1
        x_left = i
        x_right = w - blend_width + i
        
        # Weighted blend
        left_col = arr[:, x_left].copy()
        right_col = arr[:, x_right].copy()
        
        # Blend into left and right
        blended = (1.0 - t) * right_col + t * left_col
        arr[:, x_left] = (1.0 - t) * left_col + t * blended
        arr[:, x_right] = (1.0 - t) * blended + t * right_col
        
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), mode="RGBA")

print("Module defined successfully")

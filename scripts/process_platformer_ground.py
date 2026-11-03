import os
import numpy as np
from PIL import Image
from collections import deque

def remove_black_bg_flood(img, threshold=20):
    img = img.convert('RGBA')
    w, h = img.size
    pixels = img.load()
    visited = [[False for _ in range(h)] for _ in range(w)]
    queue = deque()
    
    def is_bg(x, y):
        r, g, b, a = pixels[x, y]
        return max(r, g, b) <= threshold

    for x in range(w):
        if is_bg(x, 0) and not visited[x][0]:
            queue.append((x, 0))
            visited[x][0] = True
        if is_bg(x, h - 1) and not visited[x][h - 1]:
            queue.append((x, h - 1))
            visited[x][h - 1] = True
            
    for y in range(h):
        if is_bg(0, y) and not visited[0][y]:
            queue.append((0, y))
            visited[0][y] = True
        if is_bg(w - 1, y) and not visited[w - 1][y]:
            queue.append((w - 1, y))
            visited[w - 1][y] = True

    while queue:
        cx, cy = queue.popleft()
        pixels[cx, cy] = (0, 0, 0, 0)
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                visited[nx][ny] = True
                if is_bg(nx, ny):
                    queue.append((nx, ny))
    return img

def clean_frame_with_trim(img, min_x, max_x, is_pure_electric=False):
    img = img.convert('RGBA')
    arr = np.array(img).copy()
    
    # 1. Clear any pixels outside [min_x, max_x]
    arr[:, :min_x, 3] = 0
    arr[:, max_x:, 3] = 0
    
    # 2. For pure electric frames (0, 1, 2), clear all dark pixels including enclosed pockets
    if is_pure_electric:
        dark = np.max(arr[:, :, :3], axis=2) <= 32
        arr[dark, 3] = 0
    else:
        # For scorch frames (3, 4), clear dark background outside the rock
        bg = np.max(arr[:, :, :3], axis=2) <= 18
        arr[bg, 3] = 0
        
    return Image.fromarray(arr)

def process_platformer_ground():
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
    src_path = os.path.join(brain, "platformer_ground_lightning_1791081258127.jpg")
    src = Image.open(src_path)
    
    # Ground baseline row in source image:
    SRC_BASELINE_Y = 418
    
    # 5 slots:
    slots_info = [
        # (crop_box, center_x, min_x_in_crop, max_x_in_crop, is_pure_electric)
        ((20, 255, 275, 424), 147, 10, 245, True),   # 0: Ground Impact Burst
        ((275, 305, 550, 424), 415, 12, 260, True),  # 1: Active Horizontal Crackle
        ((550, 335, 825, 424), 690, 15, 258, True),  # 2: Low Surface Crackle
        ((825, 365, 1100, 455), 960, 30, 245, False), # 3: Flat Surface Scorch
        ((1100, 365, 1365, 455), 1235, 30, 240, False) # 4: Cooling Charred Scorch
    ]
    
    FRAME_W = 256
    FRAME_H = 160
    TARGET_BASELINE_Y = 120  # Flat floor contact line at y = 120
    TARGET_CENTER_X = 128    # Center of frame
    
    master = Image.new("RGBA", (FRAME_W * len(slots_info), FRAME_H), (0, 0, 0, 0))
    
    for i, (box, center_x_in_src, min_x, max_x, is_electric) in enumerate(slots_info):
        crop = src.crop(box)
        crop_clean = remove_black_bg_flood(crop, threshold=18)
        crop_trimmed = clean_frame_with_trim(crop_clean, min_x, max_x, is_electric)
        
        # Calculate paste position relative to ground baseline
        crop_baseline_y = SRC_BASELINE_Y - box[1] # Row of baseline within crop
        crop_center_x = center_x_in_src - box[0]   # Col of center within crop
        
        paste_x = TARGET_CENTER_X - crop_center_x
        paste_y = TARGET_BASELINE_Y - crop_baseline_y
        
        frame_canvas = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
        frame_canvas.paste(crop_trimmed, (paste_x, paste_y), crop_trimmed)
        
        master.paste(frame_canvas, (i * FRAME_W, 0), frame_canvas)
        print(f"Platformer Frame {i}: center at {paste_x + crop_center_x}, baseline at {paste_y + crop_baseline_y}")
        
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_path = os.path.join(base_dir, "assets", "vfx", "vfx_lightning_scorch.png")
    master.save(out_path, "PNG")
    print(f"Saved Updated 2D Platformer Ground Spritesheet: {out_path} ({master.size})")

if __name__ == "__main__":
    process_platformer_ground()

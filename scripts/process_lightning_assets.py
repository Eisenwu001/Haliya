import os
import numpy as np
from PIL import Image
from collections import deque

def remove_black_bg_flood(img, threshold=20):
    """Flood-fills from borders to make black background transparent while preserving interior textures."""
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

def clean_electric_alpha(img, black_threshold=28, glow_power=1.4):
    """Calculates alpha based on electric luminance and energy."""
    img = img.convert('RGBA')
    arr = np.array(img).astype(np.float32)
    rgb = arr[:, :, :3]
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    
    # Electric energy metric: white core is ~255, cyan plasma is ~210, dark navy background is < 40
    energy = np.maximum(g * 0.95 + b * 0.55, r * 1.0)
    
    alpha = np.clip((energy - black_threshold) / (255.0 - black_threshold), 0.0, 1.0)
    alpha = np.power(alpha, glow_power) * 255.0
    arr[:, :, 3] = alpha
    return Image.fromarray(arr.astype(np.uint8))

def process_strike_spritesheet(src_path, out_path):
    src = Image.open(src_path)
    
    # 6 panels in source image:
    # Each panel x-bounds and y-bounds (87 to 615 gives 528px height, ground at 615)
    panels = [
        (14, 87, 228, 615),     # 0: Sky Ionization
        (239, 87, 455, 615),    # 1: Main Strike & Impact Detonation
        (467, 87, 682, 615),    # 2: Peak Explosion & Shockwave
        (695, 87, 908, 615),    # 3: Return Stroke & Arc Flicker
        (922, 87, 1135, 615),   # 4: Dispersing Plasma Filaments
        (1149, 87, 1361, 615),  # 5: Fading Remnants
    ]
    
    FRAME_W = 256
    FRAME_H = 544
    BASELINE_Y = 536  # ground impact baseline
    CENTER_X = 128    # center of the frame
    
    master = Image.new("RGBA", (FRAME_W * len(panels), FRAME_H), (0, 0, 0, 0))
    
    # Contact centers in crops
    contact_centers = [107, 105, 104, 103, 108, 109]
    
    for i, box in enumerate(panels):
        crop = src.crop(box)
        # Apply electric alpha transparency
        crop_clean = clean_electric_alpha(crop, black_threshold=32, glow_power=1.4)
        
        # Center horizontally based on ground blast point
        cx = contact_centers[i]
        cw, ch = crop_clean.size
        
        paste_x = CENTER_X - cx
        paste_y = BASELINE_Y - ch
        
        frame_canvas = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
        frame_canvas.paste(crop_clean, (paste_x, paste_y), crop_clean)
        
        master.paste(frame_canvas, (i * FRAME_W, 0), frame_canvas)
        print(f"Processed strike frame {i}: paste at ({paste_x}, {paste_y})")
        
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved Lightning Strike Spritesheet: {out_path} ({master.size})")

def process_crater_spritesheet(src_path, out_path):
    src = Image.open(src_path)
    
    # 4 crater variations from lightning_ground_crater
    # Tighter crop boxes to cleanly isolate each crater:
    crater_boxes = [
        (350, 310, 670, 455),   # Crater 0: Wide cracked scorch with cyan plasma
        (720, 298, 1015, 445),  # Crater 1: Sizzling ground crackle with electric arcs
        (1055, 325, 1335, 435), # Crater 2: Cooling charred scorch with dim embers
    ]
    
    FRAME_W = 256
    FRAME_H = 128
    
    # 4 frames: 0 = fresh glowing scorch, 1 = sizzling arcs, 2 = cooling embers, 3 = faint carbon ash
    master = Image.new("RGBA", (FRAME_W * 4, FRAME_H), (0, 0, 0, 0))
    
    # Process Crater 0 (Fresh glowing scorch)
    c0 = remove_black_bg_flood(src.crop(crater_boxes[0]), threshold=16)
    # Scale to fit nicely in 256x128 (width ~200px)
    c0_scale = 190.0 / c0.width
    c0_resized = c0.resize((int(c0.width * c0_scale), int(c0.height * c0_scale)), Image.Resampling.LANCZOS)
    px0 = (FRAME_W - c0_resized.width) // 2
    py0 = (FRAME_H - c0_resized.height) // 2
    master.paste(c0_resized, (0 * FRAME_W + px0, py0), c0_resized)
    
    # Process Crater 1 (Sizzling crackle)
    c1 = remove_black_bg_flood(src.crop(crater_boxes[1]), threshold=16)
    c1_resized = c1.resize((int(c1.width * c0_scale), int(c1.height * c0_scale)), Image.Resampling.LANCZOS)
    px1 = (FRAME_W - c1_resized.width) // 2
    py1 = (FRAME_H - c1_resized.height) // 2
    master.paste(c1_resized, (1 * FRAME_W + px1, py1), c1_resized)
    
    # Process Crater 2 (Cooling embers)
    c2 = remove_black_bg_flood(src.crop(crater_boxes[2]), threshold=16)
    c2_resized = c2.resize((int(c2.width * c0_scale), int(c2.height * c0_scale)), Image.Resampling.LANCZOS)
    px2 = (FRAME_W - c2_resized.width) // 2
    py2 = (FRAME_H - c2_resized.height) // 2
    master.paste(c2_resized, (2 * FRAME_W + px2, py2), c2_resized)
    
    # Frame 3: Dimmed dark carbon scorch ash
    arr2 = np.array(c2_resized).copy().astype(np.float32)
    # Dim cyan embers and darken charred rock
    arr2[:, :, :3] *= 0.55
    arr2[:, :, 3] *= 0.75
    c3 = Image.fromarray(arr2.astype(np.uint8))
    master.paste(c3, (3 * FRAME_W + px2, py2), c3)
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved Ground Scorch Spritesheet: {out_path} ({master.size})")

if __name__ == "__main__":
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2"
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    strike_src = os.path.join(brain, "lightning_strike_vfx_1791079109255.jpg")
    ground_src = os.path.join(brain, "lightning_ground_crater_1791079135305.jpg")
    
    strike_out = os.path.join(base_dir, "assets", "vfx", "vfx_lightning_strike.png")
    ground_out = os.path.join(base_dir, "assets", "vfx", "vfx_lightning_scorch.png")
    
    process_strike_spritesheet(strike_src, strike_out)
    process_crater_spritesheet(ground_src, ground_out)
